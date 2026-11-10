#!/usr/bin/env bash
# The pi wrapper (dotfiles/bin/.local/bin/pi) in a fake home: Pi's managed install wins over an npm-global copy in a
# mise Node prefix, and runs on a mise Node >= 22.19 even when an older Node is first on PATH.
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
wrapper="$project_root/dotfiles/bin/.local/bin/pi"
home="$(mktemp -d "${TMPDIR:-/tmp}/pi-wrapper-test.XXXXXX")"
trap 'rm -rf -- "$home"' EXIT
fail() { printf 'pi wrapper test: %s\n' "$*" >&2; exit 1; }

stub() { mkdir -p "$(dirname "$1")"; printf '#!/bin/sh\n%s\n' "$2" > "$1"; chmod +x "$1"; }
nodes="$home/.local/share/mise/installs/node"
pkg=lib/node_modules/@earendil-works/pi-coding-agent
# An old npm-global pi under Node 22.23.4, the newest Node; an older Node 20.11.0 (a project's pin) first on PATH.
for v in 22.23.4 20.11.0; do
	stub "$nodes/$v/bin/node" "case \"\$1\" in -p) echo ${v%%.*} ;; -e) echo 0.85.1 ;; *) echo \"npm-pi \$*\" ;; esac"
done
mkdir -p "$nodes/22.23.4/$pkg/dist"; : > "$nodes/22.23.4/$pkg/dist/cli.js"; echo '{"version":"0.85.1"}' > "$nodes/22.23.4/$pkg/package.json"
run() { env -i HOME="$home" PATH="$nodes/20.11.0/bin:/usr/bin:/bin" /bin/bash "$wrapper" "$@"; }

[[ "$(run --version)" == "npm-pi $nodes/22.23.4/$pkg/dist/cli.js --version" ]] || fail "without a managed install the npm copy runs: $(run --version)"

stub "$home/.pi/agent/bin/pi" 'echo "managed $* node=$(command -v node)"'
mkdir -p "$home/.pi/agent/install"; echo 1.5.1 > "$home/.pi/agent/install/current-version"
got="$(run --version)"
[[ "$got" == "managed --version node=$nodes/22.23.4/bin/node" ]] || fail "the managed install wins, on Node 22.23.4: $got"

# A run that loops (the wrapper reaching itself again) is stopped after 10 seconds; bash only, no timeout(1) needed.
bounded() {
	local out="$home/bounded.out" pid i
	"$@" > "$out" 2>&1 & pid=$!
	for i in $(seq 1 100); do kill -0 "$pid" 2>/dev/null || { wait "$pid" || true; cat "$out"; return; }; sleep 0.1; done
	kill "$pid" 2>/dev/null || true; echo "LOOPED"
}
npm_line="npm-pi $nodes/22.23.4/$pkg/dist/cli.js --version"

# The managed entrypoint links back to this wrapper: it must not exec itself.
rm "$home/.pi/agent/bin/pi"; ln -s "$wrapper" "$home/.pi/agent/bin/pi"
got="$(bounded run --version)"
[[ "$got" == "$npm_line" ]] || fail "a managed entrypoint that is this wrapper is skipped: $got"

# The managed entrypoint runs `pi` from PATH, which is this wrapper again: the second run must not go back to it.
rm "$home/.pi/agent/bin/pi"  # the link to the wrapper: writing through it would overwrite the wrapper
stub "$home/.pi/agent/bin/pi" 'exec pi "$@"'
mkdir -p "$home/onpath"; ln -sf "$wrapper" "$home/onpath/pi"
got="$(bounded env -i HOME="$home" PATH="$home/onpath:$nodes/20.11.0/bin:/usr/bin:/bin" /bin/bash "$wrapper" --version)"
[[ "$got" == "$npm_line" ]] || fail "a managed entrypoint that calls pi again does not loop: $got"

echo "pi wrapper test: ok"
