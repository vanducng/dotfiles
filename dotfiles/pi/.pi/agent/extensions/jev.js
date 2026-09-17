import { homedir } from "node:os";
import { join } from "node:path";
import { readFileSync } from "node:fs";

const EVAL_URL = "https://ai-gateway.vercel.sh/v4/ai/evaluation-model";
const MODEL_ID = "typesafe-ai/jev";
const AUTH_FILE = "auth.json";

function parseState(state) {
	if (typeof state !== "string") return state;
	const trimmed = state.trim();
	if (!trimmed.startsWith("{") && !trimmed.startsWith("[")) return state;
	try {
		return JSON.parse(trimmed);
	} catch {
		return state;
	}
}

function buildEvalBody(params) {
	const questions = params?.questions;
	if (!Array.isArray(questions) || questions.length === 0) {
		throw new Error("questions required");
	}
	const mapped = {};
	for (const question of questions) {
		const id = question?.id?.trim();
		if (!id) throw new Error("each question needs an id");
		if (mapped[id]) throw new Error(`duplicate question id: ${id}`);
		const type = question.type === "noul" ? "boolean" : question.type;
		const instructions = question.instructions;
		if (!instructions) throw new Error(`${id}: instructions required`);
		if (type === "boolean") {
			const body = { type: "boolean", instructions };
			if (question.trueMeaning || question.falseMeaning) {
				body.criteria = {};
				if (question.trueMeaning) body.criteria.true = question.trueMeaning;
				if (question.falseMeaning) body.criteria.false = question.falseMeaning;
			}
			mapped[id] = body;
		} else if (type === "choice") {
			const options = question.options;
			if (!options || typeof options !== "object" || Array.isArray(options) || Object.keys(options).length === 0) {
				throw new Error(`${id}: choice needs options`);
			}
			mapped[id] = { type: "choice", instructions, criteria: options };
		} else if (type === "score") {
			const levels = question.levels;
			if (!Array.isArray(levels) || levels.length < 2) {
				throw new Error(`${id}: score needs at least 2 levels`);
			}
			mapped[id] = { type: "score", instructions, criteria: levels };
		} else {
			throw new Error(`${id}: type must be boolean, choice, or score`);
		}
	}
	return { state: parseState(params.state), questions: mapped };
}

function gatewayErrorText(status, bodyText) {
	if (status === 403 && /free tier/i.test(bodyText)) {
		return "Jev needs paid Vercel AI Gateway credits. The current key is on the free tier. Top up Gateway credits, then retry. Do not add typesafe-ai/jev to /model.";
	}
	if (status === 401 || status === 403) {
		return "Vercel AI Gateway rejected the key. Run /login vercel-ai-gateway or set AI_GATEWAY_API_KEY.";
	}
	const compact = bodyText.replace(/\s+/g, " ").trim().slice(0, 400);
	return `Jev request failed (${status}): ${compact || "no body"}`;
}

function formatAnswers(payload) {
	return JSON.stringify(
		{
			model: MODEL_ID,
			answers: payload?.answers ?? {},
			usage: payload?.usage,
			providerMetadata: payload?.providerMetadata,
		},
		null,
		2,
	);
}

function agentDir() {
	return process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi/agent");
}

function isGatewayKey(value) {
	return typeof value === "string" && value.trim().startsWith("vck_");
}

function resolveGatewayKey() {
	const fromEnv = process.env.AI_GATEWAY_API_KEY?.trim();
	if (isGatewayKey(fromEnv)) return fromEnv;
	const authPath = join(agentDir(), AUTH_FILE);
	let parsed;
	try {
		parsed = JSON.parse(readFileSync(authPath, "utf8"));
	} catch {
		return "";
	}
	const key = parsed?.["vercel-ai-gateway"]?.key;
	return isGatewayKey(key) ? key.trim() : "";
}

export default async function jevExtension(pi) {
	const { Type } = await import("@earendil-works/pi-ai");

	pi.registerTool({
		name: "jev",
		label: "Jev",
		description:
			"TypeSafe Jev evaluator via Vercel AI Gateway. Use for typed decisions with probabilities: boolean (P(true)), choice (one option), score (ordered rubric). Good for routing, gating, continue/retry/ask, and output checks. Cannot write code, chat, or explanations. Not a /model.",
		parameters: Type.Object({
			state: Type.String({
				description: "Text or JSON (object/array as a string) to evaluate",
			}),
			questions: Type.Array(
				Type.Object({
					id: Type.String({ description: "Answer key" }),
					type: Type.Union([
						Type.Literal("boolean"),
						Type.Literal("choice"),
						Type.Literal("score"),
					]),
					instructions: Type.String({ description: "What to decide" }),
					options: Type.Optional(
						Type.Record(Type.String(), Type.String()),
					),
					levels: Type.Optional(
						Type.Array(Type.String(), {
							description: "score: ordered labels, lowest first, at least two",
						}),
					),
					trueMeaning: Type.Optional(Type.String({ description: "boolean: what true means" })),
					falseMeaning: Type.Optional(Type.String({ description: "boolean: what false means" })),
				}),
				{ minItems: 1 },
			),
		}),
		async execute(_toolCallId, params, signal) {
			let body;
			try {
				body = buildEvalBody(params);
			} catch (error) {
				return {
					content: [{ type: "text", text: error instanceof Error ? error.message : String(error) }],
					details: { ok: false },
				};
			}
			const apiKey = resolveGatewayKey();
			if (!apiKey) {
				return {
					content: [
						{
							type: "text",
							text: "No Vercel AI Gateway key. Run /login vercel-ai-gateway or set AI_GATEWAY_API_KEY.",
						},
					],
					details: { ok: false },
				};
			}
			let response;
			try {
				response = await fetch(EVAL_URL, {
					method: "POST",
					headers: {
						Authorization: `Bearer ${apiKey}`,
						"Content-Type": "application/json",
						"ai-evaluation-model-specification-version": "4",
						"ai-model-id": MODEL_ID,
						"ai-gateway-protocol-version": "0.0.1",
						"ai-gateway-auth-method": "api-key",
					},
					body: JSON.stringify(body),
					signal,
				});
			} catch (error) {
				if (signal?.aborted) {
					return { content: [{ type: "text", text: "Jev request aborted." }], details: { ok: false } };
				}
				return {
					content: [
						{
							type: "text",
							text: `Jev request failed: ${error instanceof Error ? error.message : String(error)}`,
						},
					],
					details: { ok: false },
				};
			}
			const raw = await response.text();
			if (!response.ok) {
				return {
					content: [{ type: "text", text: gatewayErrorText(response.status, raw) }],
					details: { ok: false, status: response.status },
				};
			}
			let payload;
			try {
				payload = JSON.parse(raw);
			} catch {
				return {
					content: [{ type: "text", text: "Jev returned non-JSON." }],
					details: { ok: false },
				};
			}
			return {
				content: [{ type: "text", text: formatAnswers(payload) }],
				details: { ok: true, model: MODEL_ID },
			};
		},
	});

	pi.registerCommand("jev", {
		description: "How to use TypeSafe Jev from Pi",
		handler: async (_args, ctx) => {
			ctx.ui.notify(
				"Jev is a tool, not a /model. Ask for a boolean/choice/score decision and the jev tool runs. Keep the session model on a coding LLM. Needs paid Gateway credits.",
				"info",
			);
		},
	});
}

export {
	EVAL_URL,
	MODEL_ID,
	buildEvalBody,
	formatAnswers,
	gatewayErrorText,
	isGatewayKey,
	parseState,
};
