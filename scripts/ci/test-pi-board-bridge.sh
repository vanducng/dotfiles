#!/usr/bin/env bash
# Checks the Pi board-bridge extension: board items in, the seat's prompt and reply out, in a real Pi session.
# Needs node and an installed Pi (PI_CODING_AGENT_PACKAGE overrides where its package directory is found).
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ext="$project_root/dotfiles/pi/.pi/agent/extensions/board-bridge.js"

command -v node >/dev/null 2>&1 || { printf 'error: node is required to run the pi board bridge test\n' >&2; exit 1; }

pkg="${PI_CODING_AGENT_PACKAGE:-}"
if [[ -z "$pkg" ]]; then
	for root in "${PI_MANAGED_INSTALL_ROOT:-}" "$HOME/.pi/agent/install"; do
		[[ -n "$root" && -f "$root/current-version" ]] || continue
		version="$(tr -d '[:space:]' <"$root/current-version")"
		[[ "$version" =~ ^[0-9][0-9A-Za-z._-]*$ ]] || continue
		candidate="$root/releases/$version/node_modules/@earendil-works/pi-coding-agent"
		[[ -f "$candidate/package.json" ]] && { pkg="$candidate"; break; }
	done
fi
[[ -n "$pkg" && -f "$pkg/package.json" ]] || { printf 'error: Pi is not installed (set PI_CODING_AGENT_PACKAGE to its package directory)\n' >&2; exit 1; }

node "$project_root/scripts/ci/pi-board-bridge.check.mjs" "$pkg" "$ext"
# The only seat of a rig with no human seat (fleet-fixes 34): its own process, since the extension reads the seat at load.
node "$project_root/scripts/ci/pi-board-bridge-sole-seat.check.mjs" "$pkg" "$ext"
