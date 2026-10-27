#!/usr/bin/env bash
# The rex-agent-status shim: hands a hook to rexboard when rexboard has `hooks`, and otherwise
# does nothing, always exiting 0 (exit 2 would block the agent).
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
shim="$project_root/dotfiles/bin/.local/bin/rex-agent-status"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fail() { echo "test-rex-agent-status: $*" >&2; exit 1; }
event='{"hook_event_name":"Stop","last_assistant_message":"done"}'

run() { # run PATH ARGS...: the shim as an old hook runs it, its exit code on stdout
  local path="$1"; shift
  set +e
  printf '%s' "$event" | env -i PATH="$path" HOME="$tmp" /usr/bin/python3 "$shim" "$@" >/dev/null 2>&1
  echo $?
  set -e
}

fake() { # fake DIR HAS_HOOKS: a rexboard that logs its args and stdin, with or without `hooks`
  mkdir -p "$1"
  cat > "$1/rexboard" <<SH
#!/bin/sh
if [ "\$1 \$2" = "hooks --help" ]; then exit $([ "$2" = yes ] && echo 0 || echo 2); fi
printf '%s | %s\n' "\$*" "\$(cat)" >> "$1/calls"
SH
  chmod +x "$1/rexboard"
}

[ "$(run /usr/bin:/bin claude-code)" = 0 ] || fail "no rexboard: not exit 0"

fake "$tmp/old" no
[ "$(run "$tmp/old:/usr/bin:/bin" claude-code)" = 0 ] || fail "rexboard without hooks: not exit 0"
[ ! -e "$tmp/old/calls" ] || fail "rexboard without hooks was called"

fake "$tmp/new" yes
[ "$(run "$tmp/new:/usr/bin:/bin" claude-code)" = 0 ] || fail "with rexboard: not exit 0"
[ "$(run "$tmp/new:/usr/bin:/bin" codex)" = 0 ] || fail "codex: not exit 0"
[ "$(run "$tmp/new:/usr/bin:/bin" --replay '$7')" = 0 ] || fail "replay: not exit 0"
[ "$(run "$tmp/new:/usr/bin:/bin" some-other-app)" = 0 ] || fail "an unknown app: not exit 0"
expected="hook claude | $event
hook codex | $event
hooks replay \$7 | $event"
[ "$(cat "$tmp/new/calls")" = "$expected" ] || fail "calls were: $(cat "$tmp/new/calls")"

echo "rex-agent-status: ok"
