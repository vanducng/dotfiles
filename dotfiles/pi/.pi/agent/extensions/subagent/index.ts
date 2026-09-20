import { spawn } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getAgentDir, parseFrontmatter } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const MAX_TASKS = 4;
const MAX_OUTPUT_BYTES = 50 * 1024;

type Agent = {
	name: string;
	description: string;
	tools: string[];
	prompt: string;
};

type RunResult = {
	agent: string;
	task: string;
	output: string;
	error?: string;
};

function discoverAgents(): Agent[] {
	const dir = join(getAgentDir(), "agents");
	if (!existsSync(dir)) return [];

	return readdirSync(dir, { withFileTypes: true })
		.filter((entry) => (entry.isFile() || entry.isSymbolicLink()) && entry.name.endsWith(".md"))
		.flatMap((entry) => {
			try {
				const { frontmatter, body } = parseFrontmatter<{
					name?: unknown;
					description?: unknown;
					tools?: unknown;
				}>(readFileSync(join(dir, entry.name), "utf8"));
				if (typeof frontmatter.name !== "string" || typeof frontmatter.description !== "string") {
					console.warn(`subagent: skipping ${entry.name}: name and description are required`);
					return [];
				}
				const rawTools = Array.isArray(frontmatter.tools)
					? frontmatter.tools
					: typeof frontmatter.tools === "string"
						? frontmatter.tools.split(",")
						: [];
				return [{
					name: frontmatter.name,
					description: frontmatter.description,
					tools: rawTools.filter((tool): tool is string => typeof tool === "string").map((tool) => tool.trim()).filter(Boolean),
					prompt: body.trim(),
				}];
			} catch (error) {
				console.warn(`subagent: skipping ${entry.name}: ${error instanceof Error ? error.message : String(error)}`);
				return [];
			}
		});
}

function piInvocation(args: string[]): { command: string; args: string[] } {
	const script = process.argv[1];
	if (script && !script.startsWith("/$bunfs/root/") && existsSync(script)) {
		return { command: process.execPath, args: [script, ...args] };
	}
	return /^(node|bun)(\.exe)?$/i.test(basename(process.execPath))
		? { command: "pi", args }
		: { command: process.execPath, args };
}

function capOutput(text: string): string {
	const bytes = Buffer.from(text, "utf8");
	if (bytes.length <= MAX_OUTPUT_BYTES) return text;
	const output = bytes.subarray(0, MAX_OUTPUT_BYTES).toString("utf8").replace(/\uFFFD$/, "");
	return `${output}\n\n[Output truncated]`;
}

function appendTail(current: string, chunk: string): string {
	const bytes = Buffer.from(current + chunk, "utf8");
	if (bytes.length <= MAX_OUTPUT_BYTES) return current + chunk;
	return bytes.subarray(bytes.length - MAX_OUTPUT_BYTES).toString("utf8").replace(/^\uFFFD/, "");
}

async function runAgent(
	agent: Agent,
	task: string,
	cwd: string,
	model: string | undefined,
	thinking: string | undefined,
	signal: AbortSignal | undefined,
): Promise<RunResult> {
	if (!existsSync(cwd) || !statSync(cwd).isDirectory()) {
		return { agent: agent.name, task, output: "", error: `Invalid working directory: ${cwd}` };
	}
	const tempDir = mkdtempSync(join(tmpdir(), "pi-subagent-"));
	const promptPath = join(tempDir, "prompt.md");
	writeFileSync(promptPath, agent.prompt, { mode: 0o600 });

	const args = ["--mode", "json", "-p", "--no-session", "--append-system-prompt", promptPath];
	if (model) args.push("--model", model);
	if (thinking) args.push("--thinking", thinking);
	if (agent.tools.length) args.push("--tools", agent.tools.join(","));
	args.push(`Task: ${task}`);

	try {
		return await new Promise((resolve) => {
			const invocation = piInvocation(args);
			const child = spawn(invocation.command, invocation.args, { cwd, stdio: ["ignore", "pipe", "pipe"] });
			let stdout = "";
			let stderr = "";
			let buffer = "";
			let finalOutput = "";
			let modelError = "";
			let stopReason = "";
			let killTimer: NodeJS.Timeout | undefined;
			let settled = false;

			const abort = () => {
				child.kill("SIGTERM");
				killTimer = setTimeout(() => child.kill("SIGKILL"), 5000);
			};
			const complete = (result: RunResult) => {
				if (settled) return;
				settled = true;
				if (killTimer) clearTimeout(killTimer);
				signal?.removeEventListener("abort", abort);
				resolve(result);
			};
			const consume = (line: string) => {
				if (!line.trim()) return;
				try {
					const event = JSON.parse(line);
					if (event.type !== "message_end" || event.message?.role !== "assistant") return;
					modelError = event.message.errorMessage ?? modelError;
					stopReason = event.message.stopReason ?? stopReason;
					const messageText = (event.message.content ?? [])
						.filter((part: { type?: string }) => part.type === "text")
						.map((part: { text?: string }) => part.text ?? "")
						.join("");
					if (messageText) finalOutput = messageText;
				} catch {
					stdout = appendTail(stdout, `${line}\n`);
				}
			};

			child.stdout.on("data", (chunk) => {
				buffer += chunk.toString();
				const lines = buffer.split("\n");
				buffer = lines.pop() ?? "";
				for (const line of lines) consume(line);
			});
			child.stderr.on("data", (chunk) => { stderr = appendTail(stderr, chunk.toString()); });
			child.on("error", (error) => complete({ agent: agent.name, task, output: "", error: error.message }));
			child.on("close", (code) => {
				consume(buffer);
				const failed = code !== 0 || stopReason === "error" || stopReason === "aborted";
				const error = failed ? modelError || stderr.trim() || `pi stopped: ${stopReason || `exit ${code}`}` : undefined;
				complete({ agent: agent.name, task, output: capOutput(finalOutput || stdout.trim()), error });
			});

			if (signal?.aborted) abort();
			else signal?.addEventListener("abort", abort, { once: true });
		});
	} finally {
		rmSync(tempDir, { recursive: true, force: true });
	}
}

const Task = Type.Object({
	agent: Type.String({ description: "Agent name" }),
	task: Type.String({ description: "Bounded task and expected output" }),
	cwd: Type.Optional(Type.String({ description: "Working directory, defaults to the parent cwd" })),
});

const Parameters = Type.Object({
	agent: Type.Optional(Type.String({ description: "Agent name for one task" })),
	task: Type.Optional(Type.String({ description: "Task for one agent" })),
	cwd: Type.Optional(Type.String({ description: "Working directory for one task" })),
	tasks: Type.Optional(Type.Array(Task, { maxItems: MAX_TASKS, description: "Independent tasks to run in parallel" })),
});

export default function (pi: ExtensionAPI) {
	const agents = discoverAgents();
	const available = agents.map((agent) => `${agent.name}: ${agent.description}`).join("; ") || "none";

	pi.registerTool({
		name: "subagent",
		label: "Subagent",
		description: `Delegate one focused task or up to ${MAX_TASKS} independent parallel tasks to fresh Pi child processes. Available agents: ${available}.`,
		promptSnippet: "Delegate focused work to a fresh specialist child process",
		promptGuidelines: [
			"Use subagent only when delegation materially helps; prefer one focused child over orchestration ceremony.",
			"Use subagent tasks only for independent parallel work. Sequence dependent work in the parent.",
		],
		parameters: Parameters,
		async execute(_id, params, signal, onUpdate, ctx) {
			const single = Boolean(params.agent && params.task);
			const parallel = Boolean(params.tasks?.length);
			if (!single && !parallel) throw new Error("Provide agent + task or at least one task");
			if (single && parallel) throw new Error("Provide either agent + task or tasks, not both");

			const requested = single
				? [{ agent: params.agent!, task: params.task!, cwd: params.cwd }]
				: params.tasks!;
			const unknown = requested.map((item) => item.agent).filter((name) => !agents.some((agent) => agent.name === name));
			if (unknown.length) throw new Error(`Unknown agent(s): ${unknown.join(", ")}. Available: ${available}`);

			onUpdate?.({ content: [{ type: "text", text: `Running ${requested.length} subagent${requested.length === 1 ? "" : "s"}...` }] });
			const model = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined;
			const results = await Promise.all(requested.map((item) => runAgent(
				agents.find((agent) => agent.name === item.agent)!,
				item.task,
				item.cwd ?? ctx.cwd,
				model,
				ctx.thinkingLevel,
				signal,
			)));

			if (results.length === 1 && results[0].error) throw new Error(results[0].error);
			const text = results.map((result) => [
				`## ${result.agent}${result.error ? " - failed" : ""}`,
				result.error || result.output || "(no output)",
			].join("\n\n")).join("\n\n---\n\n");
			const failures = results.filter((result) => result.error).length;
			const summary = failures ? `FAILURE: ${failures}/${results.length} subagents failed\n\n${text}` : text;
			return { content: [{ type: "text", text: summary }], details: { results } };
		},
	});
}
