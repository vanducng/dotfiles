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
pass "title, label and session matches; ambiguous, plain, wrong-host and unreachable rows left out; project and status"

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

# rexboard's own check, when it is installed: the manifest loads and the answer keeps contract 1.
if command -v rexboard >/dev/null; then
  mkdir -p "$TMP/config/rexboard/extensions"
  cp -R "$EXT" "$TMP/config/rexboard/extensions/"
  printf '[extensions.settings.openrig]\nworkspace = "%s"\n' "$FIX" > "$TMP/config/rexboard/config.toml"
  PATH="$FIX/bin:$PATH" XDG_CONFIG_HOME="$TMP/config" XDG_STATE_HOME="$TMP/state" TMPDIR="$TMP" \
    rexboard ext test openrig --rows "$FIX/rows.json" >/dev/null || fail "rexboard ext test openrig"
  pass "rexboard ext test openrig --rows rows.json"
else
  echo "SKIP: rexboard not installed"
fi
