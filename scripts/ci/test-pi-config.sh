#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
agent_dir="$project_root/dotfiles/pi/.pi/agent"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/pi-config-test.XXXXXX")"
trap 'rm -r "$test_dir"' EXIT

jq empty "$agent_dir/settings.json" "$agent_dir/models.json" "$agent_dir/themes/rose-pine-moon.json"
jq -e '
	.defaultProvider == "openai-codex" and
	.defaultModel == "gpt-5.6-sol" and
	.transport == "sse"
' "$agent_dir/settings.json" >/dev/null
node --check "$agent_dir/extensions/terminal-status-title.js"
PI_CODING_AGENT_DIR="$test_dir" PI_OFFLINE=1 pi --no-skills --no-prompt-templates --no-themes \
  --extension "$agent_dir/extensions/calm/index.ts" --list-models >/dev/null

printf 'pi config test: ok\n'
