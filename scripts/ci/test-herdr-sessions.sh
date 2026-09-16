#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$project_root/dotfiles/bin/.local/bin/herdr-sessions"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/herdr-sessions-test.XXXXXX")"
trap '[[ -n "${test_dir:-}" ]] && rm -r "$test_dir"' EXIT

cat >"$test_dir/herdr" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == --session ]]; then
  printf '%s\n' "${2:-}" >"${HERDR_SESSIONS_ATTACH_CAPTURE:?}"
  exit 0
fi
case "${1:-} ${2:-}" in
  'session list')
    [[ "${HERDR_SESSIONS_LIST_FAIL:-0}" == 0 ]] || exit 7
    if [[ "${HERDR_SESSIONS_MALFORMED:-0}" == 1 ]]; then
      printf '%s\n' '{}'
      exit 0
    fi
    printf '%s\n' '{"sessions":[
      {"default":true,"name":"default","running":true,"session_dir":"/tmp/herdr","socket_path":"/tmp/herdr/herdr.sock"},
      {"default":false,"name":"work","running":false,"session_dir":"/tmp/herdr/sessions/work","socket_path":"/tmp/herdr/sessions/work/herdr.sock"}
    ]}'
    ;;
  *) exit 2 ;;
esac
EOF

cat >"$test_dir/fzf" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat >"$HERDR_SESSIONS_CHOICES"
printf '%s\n' "${HERDR_SESSIONS_QUERY:-}"
if [[ -n "${HERDR_SESSIONS_PICK:-}" ]]; then
  grep -m1 "$HERDR_SESSIONS_PICK" "$HERDR_SESSIONS_CHOICES" || true
fi
exit "${HERDR_SESSIONS_FZF_STATUS:-0}"
EOF

chmod +x "$test_dir/herdr" "$test_dir/fzf"
choices="$test_dir/choices"
attach="$test_dir/attach"
open_capture="$test_dir/open"
: >"$attach"

outside=(env -u HERDR_ENV -u HERDR_SOCKET_PATH -u HERDR_PANE_ID -u HERDR_TAB_ID -u HERDR_WORKSPACE_ID)

PATH="$test_dir:$PATH" \
HERDR_BIN_PATH="$test_dir/herdr" \
HERDR_SESSIONS_CHOICES="$choices" \
HERDR_SESSIONS_ATTACH_CAPTURE="$attach" \
HERDR_SESSIONS_PICK=$'\twork' \
  "${outside[@]}" "$script"

grep -q '^  default  running  default' "$choices"
grep -q '^  work  stopped' "$choices"
[[ "$(cat "$attach")" == "work" ]]

: >"$attach"
PATH="$test_dir:$PATH" \
HERDR_BIN_PATH="$test_dir/herdr" \
HERDR_ENV=1 \
HERDR_SOCKET_PATH="/tmp/herdr/herdr.sock" \
HERDR_SESSIONS_CHOICES="$choices" \
HERDR_SESSIONS_ATTACH_CAPTURE="$attach" \
HERDR_SESSIONS_OPEN_CAPTURE="$open_capture" \
HERDR_SESSIONS_PICK=$'\twork' \
  "$script"

grep -q '^\* default  running  default' "$choices"
[[ "$(cat "$open_capture")" == "work" ]]
[[ ! -s "$attach" ]]

if [[ "$(uname -s)" == Darwin && -d /Applications/Ghostty.app ]]; then
  cat >"$test_dir/open" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
env | awk -F= '/^HERDR_(ENV|SOCKET_PATH|PANE_ID|TAB_ID|WORKSPACE_ID)=/ { print $1 }' >"${HERDR_SESSIONS_OPEN_ENV:?}"
printf '%s\n' "$@" >"${HERDR_SESSIONS_OPEN_ARGS:?}"
EOF
  chmod +x "$test_dir/open"
  : >"$attach"
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_ENV=1 \
  HERDR_SOCKET_PATH="/tmp/herdr/herdr.sock" \
  HERDR_PANE_ID="wB:p1" \
  HERDR_TAB_ID="wB:t1" \
  HERDR_WORKSPACE_ID="wB" \
  HERDR_SESSIONS_CHOICES="$choices" \
  HERDR_SESSIONS_ATTACH_CAPTURE="$attach" \
  HERDR_SESSIONS_OPEN_ENV="$test_dir/open-env" \
  HERDR_SESSIONS_OPEN_ARGS="$test_dir/open-args" \
  HERDR_SESSIONS_PICK=$'\twork' \
    "$script"
  [[ ! -s "$test_dir/open-env" ]]
  grep -q 'Ghostty.app' "$test_dir/open-args"
  [[ ! -s "$attach" ]]
fi

: >"$attach"
rm -f "$open_capture"
PATH="$test_dir:$PATH" \
HERDR_BIN_PATH="$test_dir/herdr" \
HERDR_ENV=1 \
HERDR_SOCKET_PATH="/tmp/herdr/herdr.sock" \
HERDR_SESSIONS_CHOICES="$choices" \
HERDR_SESSIONS_ATTACH_CAPTURE="$attach" \
HERDR_SESSIONS_OPEN_CAPTURE="$open_capture" \
HERDR_SESSIONS_PICK=$'\tdefault' \
  "$script"

[[ ! -e "$open_capture" ]]
[[ ! -s "$attach" ]]

: >"$attach"
PATH="$test_dir:$PATH" \
HERDR_BIN_PATH="$test_dir/herdr" \
HERDR_SESSIONS_CHOICES="$choices" \
HERDR_SESSIONS_ATTACH_CAPTURE="$attach" \
HERDR_SESSIONS_FZF_STATUS=1 \
HERDR_SESSIONS_QUERY="side-project" \
  "${outside[@]}" "$script"

[[ "$(cat "$attach")" == "side-project" ]]

if PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_SESSIONS_CHOICES="$choices" \
  HERDR_SESSIONS_ATTACH_CAPTURE="$attach" \
  HERDR_SESSIONS_FZF_STATUS=1 \
  HERDR_SESSIONS_QUERY="bad name" \
  "${outside[@]}" "$script" 2>"$test_dir/invalid-error"; then
  exit 1
fi
grep -q 'invalid session name' "$test_dir/invalid-error"

if HERDR_SESSIONS_LIST_FAIL=1 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_SESSIONS_CHOICES="$choices" \
  HERDR_SESSIONS_ATTACH_CAPTURE="$attach" \
  "${outside[@]}" "$script" 2>"$test_dir/list-error"; then
  exit 1
fi
grep -q 'failed to list sessions' "$test_dir/list-error"

if HERDR_SESSIONS_MALFORMED=1 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_SESSIONS_CHOICES="$choices" \
  HERDR_SESSIONS_ATTACH_CAPTURE="$attach" \
  "${outside[@]}" "$script" 2>"$test_dir/format-error"; then
  exit 1
fi
grep -q 'unexpected herdr response format' "$test_dir/format-error"

if PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_SESSIONS_CHOICES="$choices" \
  HERDR_SESSIONS_ATTACH_CAPTURE="$attach" \
  HERDR_SESSIONS_FZF_STATUS=2 \
  "${outside[@]}" "$script" 2>"$test_dir/fzf-error"; then
  exit 1
else
  fzf_status=$?
fi
[[ "$fzf_status" == 2 ]]
grep -q 'fzf exited with code 2' "$test_dir/fzf-error"

printf 'herdr-sessions test: ok\n'
