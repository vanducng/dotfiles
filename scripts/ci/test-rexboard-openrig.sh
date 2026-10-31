#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
EXT="$ROOT/dotfiles/rexboard/.config/rexboard/extensions/openrig"
FIX="$ROOT/scripts/ci/fixtures/rexboard-openrig"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

for tool in jq yq; do
  command -v "$tool" >/dev/null || fail "$tool is needed for the openrig adapter"
done
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# The request rexboard would send for the rows in rows.json.
request=$(jq -c --arg ws "$FIX" '{contract: 1, extension: "openrig", settings: {workspace: $ws},
  rows: [.[] | {key, host, session, tab, pane, title, process, harness, state, source}]}' "$FIX/rows.json")

got=$(printf '%s' "$request" | PATH="$FIX/bin:$PATH" "$EXT/adapter")
[ "$(printf '%s' "$got" | jq -S .)" = "$(jq -S . "$FIX/expected.json")" ] ||
  fail "answer differs:
$(diff <(printf '%s' "$got" | jq -S .) <(jq -S . "$FIX/expected.json") || true)"
pass "title, label and session matches; ambiguous, plain, wrong-host and unreachable rows left out; project, session and status"

# A host that hangs (asleep, off the network) loses only its own rows, inside the 5 s timeout.
asleep=$(printf '%s' "$request" | jq -c '.rows += [.rows[0] + {key: "asleep/b-title", host: "asleep"}]')
start=$SECONDS
got=$(printf '%s' "$asleep" | PATH="$FIX/bin:$PATH" "$EXT/adapter")
took=$((SECONDS - start))
[ "$took" -lt 5 ] || fail "a hanging host held the run for ${took}s"
[ "$(printf '%s' "$got" | jq -S .)" = "$(jq -S . "$FIX/expected.json")" ] || fail "a hanging host changed the answer: $got"
pass "a hanging host: answered in ${took}s without its rows"

# A workspace.yaml that does not parse costs the project field only, with one stderr line.
mkdir "$TMP/badws"
printf 'projects: [\n  - id: demo\n' >"$TMP/badws/workspace.yaml"
badws=$(printf '%s' "$request" | jq -c --arg ws "$TMP/badws" '.settings.workspace = $ws')
got=$(printf '%s' "$badws" | PATH="$FIX/bin:$PATH" "$EXT/adapter" 2>"$TMP/badws/err") || fail "a broken workspace.yaml failed the run"
[ "$(printf '%s' "$got" | jq -S .)" = "$(jq -S '.rows[].fields.project = null' "$FIX/expected.json")" ] ||
  fail "a broken workspace.yaml changed more than project: $got"
[ "$(wc -l <"$TMP/badws/err" | tr -d ' ')" = 1 ] || fail "want one stderr line, got: $(cat "$TMP/badws/err")"
pass "a broken workspace.yaml: no project, \"$(cat "$TMP/badws/err")\""

# Without rig, or with rig failing here, the run fails with one line, so rexboard shows its alert.
mkdir "$TMP/empty"
for case in missing failing; do
  if [ $case = missing ]; then
    path="$TMP/empty:/usr/bin:/bin" failing=""
    ln -sf "$(command -v jq)" "$TMP/empty/jq"
  else
    path="$FIX/bin:$PATH" failing=1
  fi
  set +e
  err=$(printf '%s' "$request" | PATH="$path" FAKE_RIG_FAIL=$failing "$EXT/adapter" 2>&1 >/dev/null)
  code=$?
  set -e
  [ $code = 1 ] || fail "rig $case: exit $code, want 1"
  [ "$(printf '%s\n' "$err" | wc -l | tr -d ' ')" = 1 ] || fail "rig $case: want one stderr line, got: $err"
  pass "rig $case: exit 1, \"$err\""
done

# The send action turns what rexboard confirmed into one `rig send`: --host only for another host,
# --verify always, the text after `--` as one argument, whatever it holds.
send() { # HOST SESSION TEXT [settings json]
  rm -f "$TMP/sent"
  local settings=${4-}
  [ -n "$settings" ] || settings='{}'
  REXBOARD_SETTINGS="$settings" FAKE_RIG_SENT="$TMP/sent" PATH="$FIX/bin:$PATH" "$EXT/send" "${@:1:3}"
}
sent() { tr '\n' ' ' <"$TMP/sent" | sed 's/ $//'; }

OPENRIG_SESSION_NAME=some-seat@elsewhere send local dev-impl@api "hello there" >/dev/null
[ "$(sent)" = "sender=<unset> arg=--verify arg=-- arg=dev-impl@api arg=hello there" ] || fail "local send: $(sent)"
send mini-01 lead-owner@web "hello there" >/dev/null
[ "$(sent)" = "sender=<unset> arg=--host arg=mini-01 arg=--verify arg=-- arg=lead-owner@web arg=hello there" ] || fail "remote send: $(sent)"
pass "send: local without --host, another host with --host HOST, --verify, session and text after --; no sender even from a seat's shell"

for text in "-rf --help" "it's \"quoted\"; \$(touch pwned) \`id\` *" "日本語 🙂 é" "  padded  " "--host evil"; do
  send local dev-impl@api "$text" >/dev/null
  [ "$(sed -n '$p' "$TMP/sent")" = "arg=$text" ] && [ "$(grep -c '^arg=' "$TMP/sent")" = 4 ] || fail "text $text: $(sent)"
done
[ ! -e pwned ] || fail "the text ran"
pass "send: dashes, quotes, ; \$( ) backticks, a glob, unicode and spaces arrive as one argument"

send local dev-impl@api "hi" '{"wait_for_idle": 30, "sender": "operator@desk"}' >/dev/null
[ "$(sent)" = "sender=operator@desk arg=--verify arg=--wait-for-idle arg=30 arg=-- arg=dev-impl@api arg=hi" ] || fail "settings: $(sent)"
set +e
send local dev-impl@api "hi" '{"wait_for_idle": "soon"}' 2>"$TMP/err" >/dev/null
code=$?
set -e
if [ $code != 2 ] || [ -e "$TMP/sent" ] || ! grep -q "whole number of seconds" "$TMP/err"; then
  fail "a bad wait_for_idle: exit $code, $(cat "$TMP/err")"
fi
set +e
send local 2>"$TMP/err" >/dev/null; [ $? = 2 ] || fail "too few arguments"
FAKE_RIG_SEND_EXIT=3 send local dev-impl@api "hi" 2>"$TMP/err" >/dev/null
code=$?
set -e
if [ $code != 3 ] || ! grep -q "not delivered" "$TMP/err"; then
  fail "a failed rig send: exit $code, $(cat "$TMP/err")"
fi
# The wait the script allows must fit inside the action's timeout with a delivery budget, or
# rexboard kills a send that is still waiting: a wait that is accepted always has time to finish.
max_wait=$(sed -n 's/^max_wait=\([0-9][0-9]*\).*/\1/p' "$EXT/send")
timeout=$(yq -p toml -o json '.actions[0].timeout' "$EXT/extension.toml")
[ -n "$max_wait" ] && [ "$timeout" -ge $((max_wait + 15)) ] ||
  fail "the action timeout (${timeout:-?}s) must be at least max_wait (${max_wait:-?}s) plus 15s to deliver"
send local dev-impl@api "hi" "{\"wait_for_idle\": $max_wait}" >/dev/null || fail "wait_for_idle at the cap ($max_wait) was refused"
set +e
send local dev-impl@api "hi" "{\"wait_for_idle\": $((max_wait + 1))}" 2>"$TMP/err" >/dev/null
code=$?
set -e
if [ $code != 2 ] || [ -e "$TMP/sent" ] || ! grep -q "at most $max_wait seconds" "$TMP/err"; then
  fail "a wait over the cap: exit $code, $(cat "$TMP/err")"
fi
pass "send: wait_for_idle up to $max_wait s, inside the ${timeout}s action timeout; more is refused"

pass "send: wait_for_idle and sender only from settings; a bad wait or a failed rig send fails with its message"

# rexboard's own check, when it is installed: the manifest loads and the answer keeps contract 1.
if command -v rexboard >/dev/null && rexboard ext run --help >/dev/null 2>&1; then
  mkdir -p "$TMP/config/rexboard/extensions"
  cp -R "$EXT" "$TMP/config/rexboard/extensions/"
  printf '[extensions.settings.openrig]\nworkspace = "%s"\n' "$FIX" > "$TMP/config/rexboard/config.toml"
  PATH="$FIX/bin:$PATH" XDG_CONFIG_HOME="$TMP/config" XDG_STATE_HOME="$TMP/state" TMPDIR="$TMP" \
    rexboard ext test openrig --rows "$FIX/rows.json" >/dev/null || fail "rexboard ext test openrig"
  pass "rexboard ext test openrig --rows rows.json"
else
  echo "SKIP: rexboard with actions (ext run) not installed"
fi
