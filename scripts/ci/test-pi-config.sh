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
	"$agent_dir/themes/rose-pine-moon.json"
jq -e '
	.defaultProvider == "cpa" and
	.defaultModel == "claude-opus-5-5" and
	.transport == "sse"
' "$agent_dir/settings.json" >/dev/null
# Pi runs each bash command in a non-interactive shell that inherits the PATH of whatever started pi (a tmux pane,
# the OpenRig daemon), which can lack ~/.local/bin. shellCommandPrefix appends it, so tools installed there resolve,
# without shadowing a command found earlier on the PATH (an OpenRig seat's own rig wrapper).
prefix="$(jq -r '.shellCommandPrefix // ""' "$agent_dir/settings.json")"
path_seen="$(env -i HOME="$test_dir" PATH=/usr/bin:/bin /bin/bash -c "$prefix"$'\n''printf %s "$PATH"')"
if [[ "$path_seen" != "/usr/bin:/bin:$test_dir/.local/bin" ]]; then
	printf 'error: shellCommandPrefix must append ~/.local/bin to PATH; got %s\n' "$path_seen" >&2
	exit 1
fi
path_again="$(env -i HOME="$test_dir" PATH="/usr/bin:$test_dir/.local/bin" /bin/bash -c "$prefix"$'\n''printf %s "$PATH"')"
if [[ "$path_again" != "/usr/bin:$test_dir/.local/bin" ]]; then
	printf 'error: shellCommandPrefix must not add ~/.local/bin twice; got %s\n' "$path_again" >&2
	exit 1
fi
jq -e '
	.packages
	| index("npm:pi-web-access")
	  and (map(select(test("pi-subagent"))) | length == 0)
	  and index("npm:pi-mcp-adapter")
' "$agent_dir/settings.json" >/dev/null
jq -e '
	.mcpServers.Structured.url == "https://mcp.structured.app/mcp" and
	.mcpServers.Structured.oauth.scope == "email" and
	(.mcpServers.Structured.oauth.clientId | not)
' "$agent_dir/mcp.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "grok-4.6")
	| .thinkingLevelMap
	| has("off") and has("minimal") and has("max")
	  and .xhigh == "xhigh"
	  and .off == null
	  and .minimal == null
	  and .max == null
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "gpt-6-sol")
	| .thinkingLevelMap
	| .off == "none" and .xhigh == "xhigh" and .max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "gpt-5.6-sol")
	| .thinkingLevelMap
	| .off == "none" and .xhigh == "xhigh" and .max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "claude-opus-4-7")
	| .thinkingLevelMap
	| .xhigh == "xhigh" and .max == "max"
' "$agent_dir/models.json" >/dev/null

jq -e '
	.providers.cpa.models[]
	| select(.id == "claude-opus-5")
	| .thinkingLevelMap
	| .xhigh == "xhigh" and .max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "claude-opus-5-5")
	| .contextWindow == 1000000 and .maxTokens == 65536
	  and .thinkingLevelMap.xhigh == "xhigh" and .thinkingLevelMap.max == "max"
	  and .thinkingLevelMap.off == null
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "gpt-5.5")
	| .thinkingLevelMap
	| .xhigh == "xhigh" and .max == null
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "claude-fable-5")
	| .contextWindow == 1000000 and .maxTokens == 65536
	  and .thinkingLevelMap.xhigh == "xhigh" and .thinkingLevelMap.max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "gpt-6-astra")
	| .contextWindow == 272000 and .maxTokens == 65536
	  and .thinkingLevelMap.off == null
	  and .thinkingLevelMap.xhigh == "xhigh" and .thinkingLevelMap.max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	[.providers.cpa.models[] | select(.id == "claude-fable-5-1" or .id == "claude-fable-5-2")]
	| length == 2 and all(
		.contextWindow == 1000000 and .maxTokens == 65536
		and .thinkingLevelMap.off == null
		and .thinkingLevelMap.xhigh == "xhigh" and .thinkingLevelMap.max == "max"
	)
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "grok-4.7")
	| .contextWindow == 500000 and .maxTokens == 32768
	  and .thinkingLevelMap.xhigh == "xhigh"
	  and .thinkingLevelMap.off == null
	  and .thinkingLevelMap.max == null
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "grok-4.6")
	| .contextWindow == 500000 and .maxTokens == 32768
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "gpt-6.1-sol")
	| .contextWindow == 272000 and .maxTokens == 65536
	  and .thinkingLevelMap.off == "none"
	  and .thinkingLevelMap.xhigh == "xhigh" and .thinkingLevelMap.max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "gpt-6-sol")
	| .contextWindow == 272000 and .maxTokens == 65536
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "gpt-6-luna")
	| .contextWindow == 272000 and .maxTokens == 65536
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "gpt-5.6-sol")
	| .contextWindow == 272000 and .maxTokens == 65536
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "glm-5.3")
	| .contextWindow == 1000000 and .maxTokens == 131072
	  and .thinkingLevelMap.low == "low"
	  and .thinkingLevelMap.high == "high"
	  and .thinkingLevelMap.max == "max"
' "$agent_dir/models.json" >/dev/null
jq -e '
	.providers.cpa.models[]
	| select(.id == "muse-spark-1.3-contributor")
	| .contextWindow == 1048576 and .maxTokens == 16384
	  and .thinkingLevelMap.minimal == "minimal"
	  and .thinkingLevelMap.xhigh == "xhigh"
	  and .thinkingLevelMap.max == "max"
' "$agent_dir/models.json" >/dev/null
node --check "$agent_dir/extensions/terminal-status-title.js"
node --check "$agent_dir/extensions/standby-status.js"
AGENT_DIR="$agent_dir" node --input-type=module <<'EOF'
import { join } from "node:path";
import { pathToFileURL } from "node:url";
const { crewTransitions, formatLabel, parseAgentList, siblingCrews, wakeMessage } = await import(
	pathToFileURL(join(process.env.AGENT_DIR, "extensions/standby-status.js")).href
);
const agents = parseAgentList(JSON.stringify({ result: { agents: [
  { name: "firstmate", pane_id: "wB:p1", agent_status: "idle" },
  { name: "dbt-prj-3534", pane_id: "wG:p1", agent_status: "working" },
  { name: "astro-prj-3534", pane_id: "wD:p1", agent_status: "idle" },
]}}));
const names = siblingCrews(agents, "wB:p1");
if (names.join(",") !== "dbt-prj-3534") throw new Error(names.join(","));
if (formatLabel(names) !== "standby · dbt-prj-3534") throw new Error(formatLabel(names));
const t1 = crewTransitions(
  { a: "working", b: "blocked", c: "idle" },
  { a: "idle", b: "done", c: "blocked" },
);
if (t1.settled.join(",") !== "a,b") throw new Error(t1.settled.join(","));
if (t1.blocked.join(",") !== "c") throw new Error(t1.blocked.join(","));
const t0 = crewTransitions({}, { a: "working" });
if (t0.settled.length || t0.blocked.length) throw new Error("seed must not fire");
if (wakeMessage(["dbt-prj-3534"], []) !== "Crew settled: dbt-prj-3534. Inspect that pane checkpoint/result and continue. Idle UI is not success.") {
  throw new Error(wakeMessage(["dbt-prj-3534"], []));
}
if (wakeMessage([], ["x"]) !== "Crew needs attention: x. Inspect that pane checkpoint/result and continue. Idle UI is not success.") {
  throw new Error(wakeMessage([], ["x"]));
}
if (wakeMessage([], []) !== "") throw new Error("empty wake");
EOF
mkdir -p "$test_dir/agents"
for agent in scout worker reviewer oracle; do
	test -s "$agent_dir/agents/$agent.md"
	grep -q "^name: $agent$" "$agent_dir/agents/$agent.md"
	cp "$agent_dir/agents/$agent.md" "$test_dir/agents/"
done
PI_CODING_AGENT_DIR="$test_dir" PI_OFFLINE=1 pi --no-skills --no-prompt-templates --no-themes \
  --extension "$agent_dir/extensions/calm/index.ts" \
  --extension "$agent_dir/extensions/subagent/index.ts" \
  --extension "$agent_dir/extensions/statusline.ts" --list-models >/dev/null

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
