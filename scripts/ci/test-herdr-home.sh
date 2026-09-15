#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/herdr-home-test.XXXXXX")"
trap '[[ -n "${test_dir:-}" ]] && rm -r "$test_dir"' EXIT

cat >"$test_dir/herdr" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "$1 $2" in
  'workspace list')
    [[ "${HERDR_HOME_FAIL_LIST:-0}" == 0 ]] || exit 7
    if [[ "${HERDR_HOME_MALFORMED:-0}" == 1 ]]; then
      printf '%s\n' '{}'
      exit 0
    fi
    printf '%s\n' '{"result":{"workspaces":[
      {"workspace_id":"wB","number":2},
      {"workspace_id":"wA","number":1}
    ]}}'
    ;;
  'tab list')
    printf '%s\n' '{"result":{"tabs":[
      {"workspace_id":"wA","tab_id":"wA:t2","number":2},
      {"workspace_id":"wA","tab_id":"wA:t1","number":1},
      {"workspace_id":"wB","tab_id":"wB:t1","number":1}
    ]}}'
    ;;
  'pane list')
    printf '%s\n' '{"result":{"panes":[
      {"pane_id":"wA:p10","tab_id":"wA:t1"},
      {"pane_id":"wA:p2","tab_id":"wA:t1"},
      {"pane_id":"wA:p1","tab_id":"wA:t1"},
      {"pane_id":"wB:p1","tab_id":"wB:t1"}
    ]}}'
    ;;
  'workspace focus'|'tab focus'|'agent focus')
    printf '%s %s\n' "$1" "$3" >>"$HERDR_HOME_CAPTURE"
    ;;
  *) exit 2 ;;
esac
EOF
chmod +x "$test_dir/herdr"

capture="$test_dir/focus"
: >"$capture"

PATH="$test_dir:$PATH" \
HERDR_BIN_PATH="$test_dir/herdr" \
HERDR_HOME_CAPTURE="$capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-home"

[[ "$(cat "$capture")" == $'workspace wA\ntab wA:t1\nagent wA:p1' ]]

if HERDR_HOME_FAIL_LIST=1 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_HOME_CAPTURE="$capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-home" 2>"$test_dir/list-error"; then
  exit 1
fi
grep -q 'failed to list workspaces' "$test_dir/list-error"

if HERDR_HOME_MALFORMED=1 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_HOME_CAPTURE="$capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-home" 2>"$test_dir/format-error"; then
  exit 1
fi
grep -q 'unexpected herdr response format' "$test_dir/format-error"

printf 'herdr-home test: ok\n'
