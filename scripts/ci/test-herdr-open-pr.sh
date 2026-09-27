#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$project_root/dotfiles/bin/.local/bin/herdr-open-pr"
config="$project_root/dotfiles/herdr/.config/herdr/config.toml"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/herdr-open-pr-test.XXXXXX")"
trap '[[ -n "${test_dir:-}" ]] && rm -r "$test_dir"' EXIT

grep -Fq 'new_worktree = ""' "$config"
grep -Fq "command = \"/bin/bash \\\"\$HOME/.local/bin/herdr-open-pr\\\"\"" "$config"

mkdir -p "$test_dir/repo" "$test_dir/bin"
git -C "$test_dir/repo" init >/dev/null

cat >"$test_dir/bin/herdr" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "$1 $2" in
  'notification show')
    printf '%s\n' "$3" >>"$HERDR_PR_NOTIFY"
    ;;
  'pane get')
    printf '%s\n' '{"result":{"pane":{"cwd":"'"$HERDR_PR_PANE_CWD"'","foreground_cwd":"'"$HERDR_PR_PANE_CWD"'"}}}'
    ;;
  *) exit 2 ;;
esac
EOF

cat >"$test_dir/bin/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$HERDR_PR_GH"
case "$*" in
  --version) exit 0 ;;
  'pr view --json url')
    [[ "${HERDR_PR_HAS_PR:-0}" == 1 ]] || { printf 'no pull requests found\n' >&2; exit 1; }
    printf '%s\n' '{"url":"https://example.test/pr/1"}'
    ;;
  'pr view --web'|'pr list --web') exit 0 ;;
  *) exit 2 ;;
esac
EOF
chmod +x "$test_dir/bin/herdr" "$test_dir/bin/gh"

notify="$test_dir/notify"
gh_log="$test_dir/gh"
: >"$notify"
: >"$gh_log"

run_script() {
  PATH="$test_dir/bin:/usr/bin:/bin" \
  HERDR_BIN_PATH="$test_dir/bin/herdr" \
  HERDR_PR_NOTIFY="$notify" \
  HERDR_PR_GH="$gh_log" \
    "$script"
}

: >"$notify"
: >"$gh_log"
HERDR_ACTIVE_PANE_CWD="$test_dir/repo" HERDR_PR_HAS_PR=1 run_script
grep -qx 'pr view --json url' "$gh_log"
grep -qx 'pr view --web' "$gh_log"
! grep -q 'pr list --web' "$gh_log"
[[ ! -s "$notify" ]]

: >"$notify"
: >"$gh_log"
HERDR_ACTIVE_PANE_CWD="$test_dir/repo" HERDR_PR_HAS_PR=0 run_script
grep -qx 'pr list --web' "$gh_log"
! grep -q 'pr view --web' "$gh_log"

: >"$notify"
: >"$gh_log"
HERDR_ACTIVE_PANE_CWD="$test_dir" run_script
grep -qx 'no git project in this pane' "$notify"
[[ ! -s "$gh_log" ]]

printf 'herdr-open-pr test: ok\n'
