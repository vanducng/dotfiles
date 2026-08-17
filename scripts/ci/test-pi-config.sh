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

jq empty "$agent_dir/settings.json" "$agent_dir/models.json" "$agent_dir/themes/rose-pine-moon.json"
jq -e '
	.defaultProvider == "cliproxyapi" and
	.defaultModel == "grok-4.6" and
	.transport == "sse"
' "$agent_dir/settings.json" >/dev/null
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
node --check "$agent_dir/extensions/terminal-status-title.js"
PI_CODING_AGENT_DIR="$test_dir" PI_OFFLINE=1 pi --no-skills --no-prompt-templates --no-themes \
  --extension "$agent_dir/extensions/calm/index.ts" --list-models >/dev/null

printf 'pi config test: ok\n'
