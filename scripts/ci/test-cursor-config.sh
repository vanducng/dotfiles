#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
config="$project_root/dotfiles/cursor/.cursor/cli-config.json"

command -v jq >/dev/null 2>&1 || {
	printf 'error: jq is required to run the Cursor config test\n' >&2
	exit 1
}

jq empty "$config"

jq -e '
	.attribution.attributeCommitsToAgent == false and
	.attribution.attributePRsToAgent == false
' "$config" >/dev/null

jq -e '
	(has("authInfo") | not) and
	(has("privacyCache") | not) and
	(has("model") | not) and
	(has("selectedModel") | not)
' "$config" >/dev/null

printf 'cursor config test: ok\n'
