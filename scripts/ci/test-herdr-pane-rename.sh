#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/herdr-pane-rename-test.XXXXXX")"
trap '[[ -n "${test_dir:-}" ]] && rm -r "$test_dir"' EXIT

cat >"$test_dir/herdr" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "$1 $2" in
  'pane get')
    jq -n --arg cwd "$HERDR_RENAME_CWD" \
      '{result:{pane:{pane_id:"w1:p1",cwd:$cwd,foreground_cwd:$cwd}}}'
    ;;
  'pane rename')
    printf '%s\t%s\n' "$3" "$4" >"$HERDR_RENAME_CAPTURE"
    ;;
  *) exit 2 ;;
esac
EOF
chmod +x "$test_dir/herdr"

git_dir="$test_dir/widget-worktree"
mkdir -p "$git_dir/subdir"
git -C "$git_dir" init -q
git -C "$git_dir" switch -q -c feature/pane
git -C "$git_dir" remote add origin git@github.com:acme/widget.git

capture="$test_dir/capture"
HERDR_ACTIVE_PANE_ID="w1:p1" \
HERDR_BIN_PATH="$test_dir/herdr" \
HERDR_RENAME_CWD="$git_dir/subdir" \
HERDR_RENAME_CAPTURE="$capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-pane-rename" >/dev/null
[[ "$(cat "$capture")" == $'w1:p1\twidget:feature/pane' ]]

folder="$test_dir/plain folder"
mkdir -p "$folder"
HERDR_PANE_ID="w1:p1" \
HERDR_BIN_PATH="$test_dir/herdr" \
HERDR_RENAME_CWD="$folder" \
HERDR_RENAME_CAPTURE="$capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-pane-rename" >/dev/null
[[ "$(cat "$capture")" == $'w1:p1\tplain folder' ]]

printf 'herdr-pane-rename test: ok\n'
