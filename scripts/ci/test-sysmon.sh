#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/dotfiles/bin/.local/bin/sysmon"
CATALOG="$ROOT/scripts/tinycast/custom-commands.json"
SETUP="$ROOT/scripts/tinycast-setup.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

[[ -x "$SCRIPT" ]] || chmod +x "$SCRIPT"
bash -n "$SCRIPT" || fail "sysmon syntax"
pass "sysmon parses"
grep -q 'System: Processes' "$SETUP" || fail "setup missing processes command"
grep -q 'System: Disk' "$SETUP" || fail "setup missing disk command"
grep -q 'catalog_id' "$SETUP" || fail "setup hardcodes command ids"
pass "setup derives sysmon ids"

command -v python3 >/dev/null 2>&1 || fail "python3 is required"
python3 - "$CATALOG" <<'PY' || fail "sysmon catalog schema"
import json
import sys
from pathlib import Path

required = {
    "c4d8e2a1-7b19-4f3c-9e60-2a1d8c5b4f77": ("System: Processes", "processes"),
    "d9e1f3b2-8c20-4a4d-af71-3b2e9d6c5a88": ("System: Disk", "disk"),
}
commands = json.loads(Path(sys.argv[1]).read_text())
by_id = {item["id"]: item for item in commands}
for command_id, (name, verb) in required.items():
    command = by_id.get(command_id)
    if not command:
        raise SystemExit(f"missing {command_id}")
    if command["name"] != name:
        raise SystemExit(f"{command_id} name {command['name']!r} != {name!r}")
    if f'sysmon" {verb}' not in command["command"] and f'sysmon\\" {verb}' not in command["command"]:
        raise SystemExit(f"{name} command does not invoke {verb}")
    if "/Users/" in command["command"] or "/home/" in command["command"]:
        raise SystemExit(f"{name} command has a personal home path")
    if command["requiresConfirmation"] or command["loadsShellEnvironment"]:
        raise SystemExit(f"{name} must run without confirmation or rc load")
PY
pass "custom-commands.json sysmon"

workdir="$(mktemp -d "${TMPDIR:-/tmp}/sysmon-test.XXXXXX")"
trap 'rm -rf -- "$workdir"' EXIT

cat >"$workdir/btop" <<'EOF'
#!/usr/bin/env bash
echo btop
EOF
cat >"$workdir/dua" <<'EOF'
#!/usr/bin/env bash
echo dua "$@"
EOF
chmod +x "$workdir/btop" "$workdir/dua"

export SYSMON_BTOP="$workdir/btop"
export SYSMON_DUA="$workdir/dua"
export SYSMON_OPEN=1
export HOME="$workdir/home"
mkdir -p "$HOME"

out="$("$SCRIPT" processes)"
printf '%s\n' "$out" | grep -q 'open: sysmon-processes' || fail "processes open: $out"
printf '%s\n' "$out" | grep -q "$workdir/btop" || fail "processes missing btop: $out"
pass "processes opens btop"

out="$("$SCRIPT" disk)"
printf '%s\n' "$out" | grep -q 'open: sysmon-disk' || fail "disk open: $out"
printf '%s\n' "$out" | grep -q "$workdir/dua" || fail "disk missing dua: $out"
printf '%s\n' "$out" | grep -q " i $HOME" || fail "disk missing home path: $out"
pass "disk opens dua i \$HOME"

out="$("$SCRIPT" disk "$workdir/scan")"
printf '%s\n' "$out" | grep -q " i $workdir/scan" || fail "disk path: $out"
pass "disk accepts a path"

out="$(SYSMON_FOCUSED=1 "$SCRIPT" processes)"
printf '%s\n' "$out" | grep -q 'focus: sysmon-processes' || fail "reuse: $out"
printf '%s\n' "$out" | grep -q 'open:' && fail "reuse opened another window: $out"
pass "processes reuses an open window"

if grep -R -nE '/Users/|/home/[a-z]' "$SCRIPT" "$CATALOG" "$SETUP" >/dev/null; then
  fail "personal home path leaked into managed files"
fi
pass "no personal home paths"
