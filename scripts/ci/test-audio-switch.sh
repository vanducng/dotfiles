#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/dotfiles/bin/.local/bin/audio-switch"
CATALOG="$ROOT/scripts/tinycast/custom-commands.json"
SETUP="$ROOT/scripts/tinycast-setup.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

[[ -x "$SCRIPT" ]] || chmod +x "$SCRIPT"
bash -n "$SCRIPT" || fail "audio-switch syntax"
bash -n "$SETUP" || fail "tinycast-setup.sh syntax"
pass "scripts parse"
grep -q 'tell application "System Events"' "$SCRIPT" || fail "picker does not host the list in System Events"
grep -q 'activate' "$SCRIPT" || fail "picker does not activate System Events for focus"
pass "picker activates System Events"

command -v python3 >/dev/null 2>&1 || fail "python3 is required"
python3 -m json.tool "$CATALOG" >/dev/null || fail "custom-commands.json is invalid"
python3 - "$CATALOG" <<'PY' || fail "custom-commands.json schema"
import json
import sys
from pathlib import Path

required = {
    "7c8e1a2b-4d3f-4a91-9b6e-0f2c8d1a5e70": ("Switch Audio", "pick"),
    "3a9f2d81-6c14-4e08-b7a5-21d0e84c9f33": ("Audio: Mac Speakers", "speakers"),
    "b5e0c472-18a9-4d6f-8c31-7a2e9f0b4d16": ("Audio: Disconnect", "disconnect"),
}
commands = json.loads(Path(sys.argv[1]).read_text())
by_id = {item["id"]: item for item in commands}
if set(by_id) != set(required):
    raise SystemExit(f"unexpected command ids: {sorted(by_id)}")
for command_id, (name, verb) in required.items():
    command = by_id[command_id]
    if command["name"] != name:
        raise SystemExit(f"{command_id} name {command['name']!r} != {name!r}")
    if f'audio-switch" {verb}' not in command["command"]:
        raise SystemExit(f"{name} command does not invoke {verb}")
    if "/Users/" in command["command"] or "/home/" in command["command"]:
        raise SystemExit(f"{name} command has a personal home path")
    if command["requiresConfirmation"] or command["loadsShellEnvironment"]:
        raise SystemExit(f"{name} must run without confirmation or rc load")
PY
pass "custom-commands.json"
if grep -q '7c8e1a2b-4d3f-4a91-9b6e-0f2c8d1a5e70' "$SETUP"; then
  fail "tinycast-setup.sh hardcodes the Switch Audio id"
fi
grep -q 'c["name"]=="Switch Audio"' "$SETUP" || grep -q "c\[\"name\"\]==\"Switch Audio\"" "$SETUP" || fail "setup does not derive PICK_ID from the catalog"
pass "setup derives pick id"

workdir="$(mktemp -d "${TMPDIR:-/tmp}/audio-switch-test.XXXXXX")"
trap 'rm -rf -- "$workdir"' EXIT

cat >"$workdir/SwitchAudioSource" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
state_dir="${AUDIO_SWITCH_STATE:?}"
type="output"
action=""
value=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t) type="$2"; shift 2 ;;
    -f) shift 2 ;;
    -a) action="all"; shift ;;
    -c) action="current"; shift ;;
    -s) action="set"; value="$2"; shift 2 ;;
    *) shift ;;
  esac
done
case "$type" in
  output) list=$'MacBook Pro Speakers\nAirPods Pro\nJabra Evolve2 65' ;;
  input) list=$'MacBook Pro Microphone\nAirPods Pro\nJabra Evolve2 65' ;;
  *) list="" ;;
esac
current_file="$state_dir/$type"
[[ -f "$current_file" ]] || printf '%s\n' "AirPods Pro" >"$current_file"
case "$action" in
  all) printf '%s\n' "$list" ;;
  current) cat "$current_file" ;;
  set)
    if ! printf '%s\n' "$list" | grep -Fxq -- "$value"; then
      echo "unknown device: $value" >&2
      exit 1
    fi
    printf '%s\n' "$value" >"$current_file"
    ;;
  *) exit 2 ;;
esac
EOF
chmod +x "$workdir/SwitchAudioSource"

cat >"$workdir/blueutil" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
state="${AUDIO_SWITCH_STATE:?}/bt"
[[ -f "$state" ]] || printf '%s\n' "11-22-33-44-55-66	AirPods Pro	1" >"$state"
action=""
format="text"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --format) format="$2"; shift 2 ;;
    --paired) action="paired"; shift ;;
    --disconnect) action="disconnect"; address="$2"; shift 2 ;;
    --wait-disconnect) shift 2 ;;
    *) shift ;;
  esac
done
case "$action" in
  paired)
    if [[ "$format" == "json" ]]; then
      python3 - "$state" <<'PY'
import json
import sys

rows = []
for line in open(sys.argv[1]):
    address, name, connected = line.rstrip("\n").split("\t")
    rows.append({"address": address, "name": name, "connected": connected == "1"})
print(json.dumps(rows))
PY
    else
      while IFS=$'\t' read -r address name connected; do
        if [[ "$connected" == "1" ]]; then
          printf 'address: %s, connected (master, -40 dBm), not favourite, paired, name: "%s"\n' "$address" "$name"
        else
          printf 'address: %s, not connected, not favourite, paired, name: "%s"\n' "$address" "$name"
        fi
      done <"$state"
    fi
    ;;
  disconnect)
    tmp="$(mktemp)"
    while IFS=$'\t' read -r row_address name connected; do
      if [[ "$row_address" == "$address" ]]; then
        connected=0
      fi
      printf '%s\t%s\t%s\n' "$row_address" "$name" "$connected"
    done <"$state" >"$tmp"
    mv "$tmp" "$state"
    ;;
  wait) ;;
  *) exit 2 ;;
esac
EOF
chmod +x "$workdir/blueutil"

export SWITCH_AUDIO_BIN="$workdir/SwitchAudioSource"
export BLUEUTIL_BIN="$workdir/blueutil"
export AUDIO_SWITCH_STATE="$workdir/state"
mkdir -p "$AUDIO_SWITCH_STATE"
export PATH="$workdir:$PATH"

out="$("$SCRIPT" status)"
printf '%s\n' "$out" | grep -q 'output: AirPods Pro' || fail "status output: $out"
printf '%s\n' "$out" | grep -q 'input: AirPods Pro' || fail "status input: $out"
pass "status"

out="$("$SCRIPT" list)"
printf '%s\n' "$out" | grep -q 'AirPods Pro' || fail "list missing AirPods: $out"
printf '%s\n' "$out" | grep -q 'Jabra Evolve2 65' || fail "list missing Jabra: $out"
pass "list"

out="$(AUDIO_SWITCH_SELECT="Jabra Evolve2 65" "$SCRIPT" pick)"
printf '%s\n' "$out" | grep -q 'output: Jabra Evolve2 65' || fail "pick: $out"
[[ "$(cat "$AUDIO_SWITCH_STATE/output")" == "Jabra Evolve2 65" ]] || fail "pick did not set output"
[[ "$(cat "$AUDIO_SWITCH_STATE/input")" == "Jabra Evolve2 65" ]] || fail "pick did not pair input"
pass "pick"

out="$("$SCRIPT" speakers)"
printf '%s\n' "$out" | grep -q 'output: MacBook Pro Speakers' || fail "speakers: $out"
[[ "$(cat "$AUDIO_SWITCH_STATE/output")" == "MacBook Pro Speakers" ]] || fail "speakers output"
[[ "$(cat "$AUDIO_SWITCH_STATE/input")" == "MacBook Pro Microphone" ]] || fail "speakers input"
pass "speakers"

out="$("$SCRIPT" set air)"
printf '%s\n' "$out" | grep -q 'output: AirPods Pro' || fail "set air: $out"
pass "set"

if "$SCRIPT" set pro >/dev/null 2>"$workdir/err"; then
  fail "ambiguous set should fail"
fi
grep -q 'ambiguous match' "$workdir/err" || fail "ambiguous error: $(cat "$workdir/err")"
pass "ambiguous set"

out="$(AUDIO_SWITCH_SELECT="AirPods Pro" "$SCRIPT" disconnect)"
printf '%s\n' "$out" | grep -q 'disconnected: AirPods Pro' || fail "disconnect: $out"
grep -q $'11-22-33-44-55-66\tAirPods Pro\t0' "$AUDIO_SWITCH_STATE/bt" || fail "disconnect did not drop device"
pass "disconnect"

if grep -R -nE '/Users/|/home/[a-z]' "$SCRIPT" "$CATALOG" "$SETUP" >/dev/null; then
  fail "personal home path leaked into managed files"
fi
pass "no personal home paths"
