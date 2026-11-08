#!/usr/bin/env bash
# Checks the Pi tool-name-aliases extension against a real Pi session driven by a scripted model.
# Needs node and an installed Pi (PI_CODING_AGENT_PACKAGE overrides where its package directory is found).
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ext="$project_root/dotfiles/pi/.pi/agent/extensions/tool-name-aliases.js"

command -v node >/dev/null 2>&1 || { printf 'error: node is required to run the pi tool alias test\n' >&2; exit 1; }

pkg="${PI_CODING_AGENT_PACKAGE:-}"
if [[ -z "$pkg" ]]; then
	for root in "${PI_MANAGED_INSTALL_ROOT:-}" "$HOME/.pi/agent/install"; do
		[[ -n "$root" && -f "$root/current-version" ]] || continue
		candidate="$root/releases/$(tr -d '[:space:]' <"$root/current-version")/node_modules/@earendil-works/pi-coding-agent"
		[[ -f "$candidate/package.json" ]] && { pkg="$candidate"; break; }
	done
fi
[[ -n "$pkg" && -f "$pkg/package.json" ]] || { printf 'error: Pi is not installed (set PI_CODING_AGENT_PACKAGE to its package directory)\n' >&2; exit 1; }

node "$project_root/scripts/ci/pi-tool-aliases.check.mjs" "$pkg" "$ext"
