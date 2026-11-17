// Loads the statusline extension the way an OpenRig seat does: a symlinked statusline.ts in an agent dir with no lib/
// beside it, through Pi's own extension loader. Then it renders the footer and checks the model label.
// Usage: node pi-statusline-load.check.mjs <pi-coding-agent package dir> <statusline.ts>
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const [pkgDir, extFile] = process.argv.slice(2);
if (!pkgDir || !extFile) { console.error("usage: pi-statusline-load.check.mjs <pi package dir> <statusline.ts>"); process.exit(2); }

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "pi-statusline-check-"));
process.on("exit", () => fs.rmSync(tmp, { recursive: true, force: true }));
// A stand-in agent-statusline that prints the label it was given.
const bin = path.join(tmp, "home", ".local", "bin");
fs.mkdirSync(bin, { recursive: true });
fs.writeFileSync(path.join(bin, "agent-statusline"), "#!/bin/sh\nsed -E 's/.*\"display_name\":\"([^\"]*)\".*/\\1/'\n", { mode: 0o755 });
process.env.HOME = path.join(tmp, "home");
delete process.env.OPENRIG_SESSION_NAME;
const agentDir = path.join(tmp, "agent");
fs.mkdirSync(path.join(agentDir, "extensions"), { recursive: true });
fs.symlinkSync(path.resolve(extFile), path.join(agentDir, "extensions", "statusline.ts"));

const version = JSON.parse(fs.readFileSync(path.join(pkgDir, "package.json"), "utf8")).version;
const sdk = await import(pathToFileURL(path.join(path.resolve(pkgDir), "dist/index.js")).href);
const loaded = await sdk.discoverAndLoadExtensions([], tmp, agentDir);
let fail = 0;
const ok = (name, cond, info = "") => { if (!cond) fail++; console.log(`  ${cond ? "✓" : "✗"} ${name}${cond || !info ? "" : `  (${info})`}`); };
ok(`Pi ${version} loads the symlinked statusline.ts`, loaded.errors.length === 0 && loaded.extensions.length === 1, JSON.stringify(loaded.errors));

// Pi binds the runtime actions when a session starts; the footer reads only the thinking level.
loaded.runtime.getThinkingLevel = () => "high";
const start = loaded.extensions[0]?.handlers.get("session_start")?.[0];
if (start) {
	let footer;
	await start({}, {
		mode: "tui",
		cwd: tmp,
		model: { provider: "cpa", id: "acme/claude-opus-5-5" },
		getContextUsage: () => ({ percent: 1 }),
		ui: { setFooter: (f) => { footer = f; } },
	});
	let rendered;
	const done = new Promise((resolve) => { rendered = resolve; });
	const comp = footer(
		{ requestRender: () => rendered() },
		{ fg: (_c, s) => s },
		{ getGitBranch: () => null, onBranchChange: () => () => {}, getExtensionStatuses: () => new Map() },
	);
	comp.render(80);
	const timeout = new Promise((resolve) => setTimeout(() => resolve("timeout"), 5000));
	const why = await Promise.race([done, timeout]);
	const line = comp.render(80)[0];
	comp.dispose();
	ok(`Pi ${version} footer shows cpa/acme/opus-5.5`, why !== "timeout" && line === "cpa/acme/opus-5.5", line);
} else ok(`Pi ${version} statusline registers session_start`, false);
console.log(fail ? `pi statusline load (Pi ${version}): ${fail} failed` : `pi statusline load (Pi ${version}): ok`);
process.exit(fail ? 1 : 0);
