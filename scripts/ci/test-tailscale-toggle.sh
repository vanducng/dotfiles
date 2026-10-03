#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/dotfiles/bin/.local/bin/tailscale-toggle"
CATALOG="$ROOT/scripts/tinycast/custom-commands.json"
SETUP="$ROOT/scripts/tinycast-setup.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

[[ -x "$SCRIPT" ]] || chmod +x "$SCRIPT"
bash -n "$SCRIPT" || fail "tailscale-toggle syntax"
bash -n "$SETUP" || fail "tinycast-setup.sh syntax"
pass "scripts parse"
grep -q '6f1a9c3e-8b24-4d70-a5e2-1c7d4b9e0f33' "$SETUP" && fail "setup hardcodes the Tailscale id"
grep -q 'catalog_id "Tailscale"' "$SETUP" || fail "setup does not derive the Tailscale id"
grep -q 'TS_ID}" -string "$(combo 17 2304)"' "$SETUP" || fail "Tailscale hotkey should be cmd+opt+T"
pass "setup derives Tailscale id"

python3 -m json.tool "$CATALOG" >/dev/null || fail "custom-commands.json is invalid"
python3 - "$CATALOG" <<'PY' || fail "Tailscale catalog schema"
import json
import sys
from pathlib import Path

commands = json.loads(Path(sys.argv[1]).read_text())
command = next(item for item in commands if item["id"] == "6f1a9c3e-8b24-4d70-a5e2-1c7d4b9e0f33")
if command["name"] != "Tailscale":
    raise SystemExit(f"name {command['name']!r}")
if 'tailscale-toggle"' not in command["command"]:
    raise SystemExit("command does not invoke tailscale-toggle")
if "/Users/" in command["command"] or "/home/" in command["command"]:
    raise SystemExit("command has a personal home path")
if command["requiresConfirmation"] or command["loadsShellEnvironment"]:
    raise SystemExit("must run without confirmation or rc load")
PY
pass "custom-commands.json"

workdir="$(mktemp -d "${TMPDIR:-/tmp}/tailscale-toggle-test.XXXXXX")"
trap 'rm -rf -- "$workdir"' EXIT

cat >"$workdir/tailscale" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
state_file="${TAILSCALE_FAKE_STATE:?}"
log="${TAILSCALE_FAKE_LOG:?}"
printf '%s\n' "$*" >>"$log"
case "$1" in
  status)
    printf '{"BackendState":"%s"}\n' "$(cat "$state_file")"
    ;;
  up)
    if [[ -n "${TAILSCALE_FAKE_UP_SLEEP:-}" ]]; then
      sleep "$TAILSCALE_FAKE_UP_SLEEP"
    fi
    if [[ "${TAILSCALE_FAKE_UP_FAIL:-}" == "1" ]]; then
      exit 1
    fi
    printf '%s\n' "Running" >"$state_file"
    ;;
  down)
    printf '%s\n' "Stopped" >"$state_file"
    ;;
  ip)
    printf '%s\n' "100.64.0.1"
    ;;
  *)
    exit 1
    ;;
esac
EOF
cat >"$workdir/osascript" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${TAILSCALE_FAKE_NOTIFY:?}"
EOF
cat >"$workdir/open" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${TAILSCALE_FAKE_OPEN:?}"
EOF
chmod +x "$workdir/tailscale" "$workdir/osascript" "$workdir/open"

export TAILSCALE_BIN="$workdir/tailscale"
export TAILSCALE_TOGGLE_QUIET=1
export TAILSCALE_FAKE_STATE="$workdir/state"
export TAILSCALE_FAKE_LOG="$workdir/log"
export TAILSCALE_FAKE_NOTIFY="$workdir/notify"
export TAILSCALE_FAKE_OPEN="$workdir/open.log"
export PATH="$workdir:$PATH"
: >"$TAILSCALE_FAKE_LOG"
: >"$TAILSCALE_FAKE_NOTIFY"
: >"$TAILSCALE_FAKE_OPEN"

printf '%s\n' "Stopped" >"$TAILSCALE_FAKE_STATE"
out="$("$SCRIPT" status)"
[[ "$out" == "Stopped" ]] || fail "status printed $out"
pass "status"

out="$("$SCRIPT")"
[[ "$out" == $'Tailscale\nConnected 100.64.0.1' ]] || fail "connect output: $out"
[[ "$(cat "$TAILSCALE_FAKE_STATE")" == "Running" ]] || fail "state did not become Running"
grep -q 'up --timeout 20s' "$TAILSCALE_FAKE_LOG" || fail "did not call tailscale up"
pass "stopped connects"

: >"$TAILSCALE_FAKE_LOG"
out="$("$SCRIPT")"
[[ "$out" == $'Tailscale\nDisconnected' ]] || fail "disconnect output: $out"
[[ "$(cat "$TAILSCALE_FAKE_STATE")" == "Stopped" ]] || fail "state did not become Stopped"
grep -qx 'down' "$TAILSCALE_FAKE_LOG" || fail "did not call tailscale down"
pass "running disconnects"

printf '%s\n' "NeedsLogin" >"$TAILSCALE_FAKE_STATE"
: >"$TAILSCALE_FAKE_LOG"
: >"$TAILSCALE_FAKE_OPEN"
set +e
out="$("$SCRIPT")"
code=$?
set -e
[[ "$code" -ne 0 ]] || fail "needs login should fail"
[[ "$out" == $'Tailscale\nNeeds login' ]] || fail "needs-login output: $out"
grep -q 'up --timeout' "$TAILSCALE_FAKE_LOG" && fail "needs login must not call up"
grep -q '^-g -a Tailscale$' "$TAILSCALE_FAKE_OPEN" || fail "needs login should open the app"
pass "needs login does not toggle"

printf '%s\n' "Stopped" >"$TAILSCALE_FAKE_STATE"
: >"$TAILSCALE_FAKE_LOG"
export TAILSCALE_FAKE_UP_SLEEP=2
export TAILSCALE_TOGGLE_LOCK="$workdir/lock"
"$SCRIPT" >/dev/null &
first=$!
sleep 0.2
"$SCRIPT"
wait "$first"
ups="$(grep -c 'up --timeout 20s' "$TAILSCALE_FAKE_LOG" || true)"
[[ "$ups" == "1" ]] || fail "second press should not start another up (count=$ups)"
pass "second press is ignored while connecting"

unset TAILSCALE_FAKE_UP_SLEEP
printf '%s\n' "Stopped" >"$TAILSCALE_FAKE_STATE"
export TAILSCALE_FAKE_UP_FAIL=1
: >"$TAILSCALE_FAKE_LOG"
rm -rf "$TAILSCALE_TOGGLE_LOCK"
set +e
out="$("$SCRIPT")"
code=$?
set -e
[[ "$code" -ne 0 ]] || fail "failed up should fail"
[[ "$out" == $'Tailscale\nCould not connect' ]] || fail "failed-up output: $out"
[[ ! -d "$TAILSCALE_TOGGLE_LOCK" ]] || fail "lock left behind after failure"
pass "failed connect releases the lock"

printf 'tailscale-toggle test: ok\n'
