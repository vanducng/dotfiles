#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
agent_dir="$project_root/dotfiles/pi/.pi/agent"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/pi-config-test.XXXXXX")"
trap '[[ -n "${test_dir:-}" ]] && rm -rf -- "$test_dir"' EXIT

for command in jq node pi; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'error: %s is required to run the pi config test\n' "$command" >&2
        exit 1
    fi
done

jq empty "$agent_dir/settings.json" "$agent_dir/models.json" "$agent_dir/mcp.json" \
	"$agent_dir/themes/rose-pine-moon.json" \
	"$agent_dir/extensions/subagent/config.json"
jq -e '.scheduledRuns.storeRoot == "~/.local/share/pi-subagents/schedules"' \
	"$agent_dir/extensions/subagent/config.json" >/dev/null
jq -e '
	.defaultProvider == "cliproxyapi" and
	.defaultModel == "grok-4.6" and
	.transport == "sse"
' "$agent_dir/settings.json" >/dev/null
jq -e '
	.packages
	| index("npm:pi-web-access")
	  and index("git:github.com/vanducng/pi-subagents@aa75b3353836f7868898e3bd58234d21eaff1463")
	  and index("npm:pi-mcp-adapter")
' "$agent_dir/settings.json" >/dev/null
jq -e '
	.mcpServers.Structured.url == "https://mcp.structured.app/mcp" and
	.mcpServers.Structured.auth == "oauth" and
	.mcpServers.Structured.oauth.scope == "email" and
	(.mcpServers.Structured.oauth.clientId | not)
' "$agent_dir/mcp.json" >/dev/null
jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "grok-4.6")
	| .thinkingLevelMap
	| has("off") and has("minimal") and has("max")
	  and .xhigh == "xhigh"
	  and .off == null
	  and .minimal == null
	  and .max == null
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "gpt-5.6-sol")
	| .thinkingLevelMap
	| .off == "none" and .xhigh == "xhigh" and .max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "claude-opus-4-7")
	| .thinkingLevelMap
	| .xhigh == "xhigh" and .max == "max"
' "$agent_dir/models.json" >/dev/null

jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "claude-opus-5")
	| .thinkingLevelMap
	| .xhigh == "xhigh" and .max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "gpt-5.5")
	| .thinkingLevelMap
	| .xhigh == "xhigh" and .max == null
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "claude-fable-5")
	| .contextWindow == 1000000 and .maxTokens == 65536
	  and .thinkingLevelMap.xhigh == "xhigh" and .thinkingLevelMap.max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "gpt-6-astra")
	| .contextWindow == 272000 and .maxTokens == 65536
	  and .thinkingLevelMap.off == null
	  and .thinkingLevelMap.xhigh == "xhigh" and .thinkingLevelMap.max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "claude-fable-5-1")
	| .contextWindow == 1000000 and .maxTokens == 65536
	  and .thinkingLevelMap.off == null
	  and .thinkingLevelMap.xhigh == "xhigh" and .thinkingLevelMap.max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "grok-4.6")
	| .contextWindow == 500000 and .maxTokens == 32768
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "gpt-5.6-sol")
	| .contextWindow == 272000 and .maxTokens == 65536
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "glm-5.3")
	| .contextWindow == 1000000 and .maxTokens == 131072
	  and .thinkingLevelMap.low == "low"
	  and .thinkingLevelMap.high == "high"
	  and .thinkingLevelMap.max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cliproxyapi.models[]
	| select(.id == "muse-spark-1.3-contributor")
	| .contextWindow == 1048576 and .maxTokens == 16384
	  and .thinkingLevelMap.minimal == "minimal"
	  and .thinkingLevelMap.xhigh == "xhigh"
	  and .thinkingLevelMap.max == "max"
' "$agent_dir/models.json" >/dev/null
node --check "$agent_dir/extensions/terminal-status-title.js"
node --check "$agent_dir/extensions/standby-status.js"
node --check "$agent_dir/extensions/jev.js"
AGENT_DIR="$agent_dir" node --input-type=module <<'EOF'
import { join } from "node:path";
import { pathToFileURL } from "node:url";
const { crewTransitions, formatLabel, parseAgentList, siblingCrews, wakeMessage } = await import(
	pathToFileURL(join(process.env.AGENT_DIR, "extensions/standby-status.js")).href
);
const agents = parseAgentList(JSON.stringify({ result: { agents: [
  { name: "firstmate", pane_id: "wB:p1", agent_status: "idle" },
  { name: "dbt-elt-3534", pane_id: "wG:p1", agent_status: "working" },
  { name: "astro-elt-3534", pane_id: "wD:p1", agent_status: "idle" },
]}}));
const names = siblingCrews(agents, "wB:p1");
if (names.join(",") !== "dbt-elt-3534") throw new Error(names.join(","));
if (formatLabel(names) !== "standby · dbt-elt-3534") throw new Error(formatLabel(names));
const t1 = crewTransitions(
  { a: "working", b: "blocked", c: "idle" },
  { a: "idle", b: "done", c: "blocked" },
);
if (t1.settled.join(",") !== "a,b") throw new Error(t1.settled.join(","));
if (t1.blocked.join(",") !== "c") throw new Error(t1.blocked.join(","));
const t0 = crewTransitions({}, { a: "working" });
if (t0.settled.length || t0.blocked.length) throw new Error("seed must not fire");
if (wakeMessage(["dbt-elt-3534"], []) !== "Crew settled: dbt-elt-3534. Inspect that pane checkpoint/result and continue. Idle UI is not success.") {
  throw new Error(wakeMessage(["dbt-elt-3534"], []));
}
if (wakeMessage([], ["x"]) !== "Crew needs attention: x. Inspect that pane checkpoint/result and continue. Idle UI is not success.") {
  throw new Error(wakeMessage([], ["x"]));
}
if (wakeMessage([], []) !== "") throw new Error("empty wake");
EOF
AGENT_DIR="$agent_dir" node --input-type=module <<'EOF'
import { join } from "node:path";
import { pathToFileURL } from "node:url";
const {
	EVAL_URL,
	MODEL_ID,
	buildEvalBody,
	formatAnswers,
	gatewayErrorText,
	isGatewayKey,
	parseState,
} = await import(pathToFileURL(join(process.env.AGENT_DIR, "extensions/jev.js")).href);
if (!EVAL_URL.endsWith("/v4/ai/evaluation-model")) throw new Error(EVAL_URL);
if (MODEL_ID !== "typesafe-ai/jev") throw new Error(MODEL_ID);
if (isGatewayKey("vck_test") !== true) throw new Error("vck accepted");
if (isGatewayKey("YOUR_KEY") || isGatewayKey("$AI_GATEWAY_API_KEY") || isGatewayKey("")) {
	throw new Error("placeholder accepted");
}
if (parseState("plain") !== "plain") throw new Error("plain state");
if (parseState('{"a":1}').a !== 1) throw new Error("json state");
const body = buildEvalBody({
	state: "Refund issued.",
	questions: [
		{ id: "refunded", type: "boolean", instructions: "Was a refund issued?" },
		{
			id: "queue",
			type: "choice",
			instructions: "Which queue?",
			options: { billing: "money", support: "other" },
		},
		{ id: "urgency", type: "score", instructions: "How urgent?", levels: ["low", "high"] },
	],
});
if (body.questions.refunded.type !== "boolean") throw new Error("boolean map");
if (body.questions.queue.criteria.billing !== "money") throw new Error("choice map");
if (body.questions.urgency.criteria.length !== 2) throw new Error("score map");
try {
	buildEvalBody({ state: "x", questions: [{ id: "q", type: "choice", instructions: "pick" }] });
	throw new Error("choice should fail");
} catch (error) {
	if (!(error instanceof Error) || !error.message.includes("options")) throw error;
}
const free = gatewayErrorText(403, "Free tier users do not have access to this model");
if (!free.includes("paid Vercel AI Gateway credits")) throw new Error(free);
const formatted = formatAnswers({ answers: { refunded: { type: "boolean", probability: 0.9 } } });
if (!formatted.includes("0.9")) throw new Error(formatted);
EOF
PI_CODING_AGENT_DIR="$test_dir" PI_OFFLINE=1 pi --no-skills --no-prompt-templates --no-themes \
  --extension "$agent_dir/extensions/calm/index.ts" --list-models >/dev/null
PI_CODING_AGENT_DIR="$test_dir" PI_OFFLINE=1 pi --no-skills --no-prompt-templates --no-themes \
  --extension "$agent_dir/extensions/jev.js" --list-models >/dev/null

if [[ -e "${HOME}/.pi" || -L "${HOME}/.pi" ]]; then
	if [[ -L "${HOME}/.pi" ]]; then
		printf 'error: ~/.pi is a symlink; keep a real directory and relocate only npm/sessions/git\n' >&2
		exit 1
	fi
	live_theme="${HOME}/.pi/agent/themes/rose-pine-moon.json"
	if [[ ! -e "$live_theme" ]]; then
		printf 'error: live theme missing or dangling: %s\n' "$live_theme" >&2
		exit 1
	fi
	jq empty "$live_theme"
fi

printf 'pi config test: ok\n'
