#!/usr/bin/env bash
# Loads the statusline extension through a symlink in an agent dir with no lib/, as an OpenRig seat does, on every
# installed Pi release (a running seat can still be on an older one). PI_CODING_AGENT_PACKAGE checks one package dir.
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ext="$project_root/dotfiles/pi/.pi/agent/extensions/statusline.ts"

command -v node >/dev/null 2>&1 || { printf 'error: node is required to run the pi statusline load test\n' >&2; exit 1; }

pkgs=()
if [[ -n "${PI_CODING_AGENT_PACKAGE:-}" ]]; then
	pkgs=("$PI_CODING_AGENT_PACKAGE")
else
	for root in "${PI_MANAGED_INSTALL_ROOT:-}" "$HOME/.pi/agent/install"; do
		[[ -n "$root" && -d "$root/releases" ]] || continue
		for candidate in "$root"/releases/*/node_modules/@earendil-works/pi-coding-agent; do
			[[ -f "$candidate/package.json" ]] && pkgs+=("$candidate")
		done
		[[ ${#pkgs[@]} -gt 0 ]] && break
	done
fi
[[ ${#pkgs[@]} -gt 0 ]] || { printf 'error: Pi is not installed (set PI_CODING_AGENT_PACKAGE to its package directory)\n' >&2; exit 1; }

rc=0
for pkg in "${pkgs[@]}"; do
	node "$project_root/scripts/ci/pi-statusline-load.check.mjs" "$pkg" "$ext" || rc=1
done
exit "$rc"
