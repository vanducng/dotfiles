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
    jq -n --arg cwd "$HERDR_RENAME_CWD" --arg agent "${HERDR_RENAME_AGENT:-claude}" \
      '{result:{pane:{pane_id:"w1:p1",cwd:$cwd,foreground_cwd:$cwd,agent:$agent,terminal_title_stripped:"Fix auth bug"}}}'
    ;;
  'pane read')
    printf 'recent agent output\n'
    ;;
  'pane rename')
    printf '%s\t%s\n' "$3" "$4" >"$HERDR_RENAME_CAPTURE"
    ;;
  'notification show')
    ;;
  *) exit 2 ;;
esac
EOF
chmod +x "$test_dir/herdr"

cat >"$test_dir/claude" <<'EOF'
#!/usr/bin/env bash
printf 'Fix Auth Token Refresh\n'
EOF
chmod +x "$test_dir/claude"

cat >"$test_dir/claude-long" <<'EOF'
#!/usr/bin/env bash
printf 'Investigate Flaky Integration Test Timeouts\n'
EOF
chmod +x "$test_dir/claude-long"

cat >"$test_dir/claude-broken" <<'EOF'
#!/usr/bin/env bash
printf 'Invalid API key · Fix external API key\n'
exit 1
EOF
chmod +x "$test_dir/claude-broken"

cat >"$test_dir/codex" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
out=""
prev=""
for arg in "$@"; do
  [[ "$prev" == "--output-last-message" ]] && out="$arg"
  prev="$arg"
done
printf 'Ship Codex Rename\n' >"$out"
EOF
chmod +x "$test_dir/codex"

git_dir="$test_dir/widget-worktree"
mkdir -p "$git_dir/subdir"
git -C "$git_dir" init -q
git -C "$git_dir" switch -q -c feature/pane
git -C "$git_dir" remote add origin git@github.com:acme/widget.git

capture="$test_dir/capture"
missing="$test_dir/missing-bin"

assert_label() {
  local desc="$1" expected="$2" actual
  actual="$(cat "$capture")"
  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL: %s\n  expected: %q\n  actual:   %q\n' "$desc" "$expected" "$actual" >&2
    exit 1
  fi
}

run() {
  HERDR_ACTIVE_PANE_ID="w1:p1" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_RENAME_CAPTURE="$capture" \
  XDG_STATE_HOME="$test_dir/state" \
  "$@" \
    "$project_root/dotfiles/bin/.local/bin/herdr-pane-rename" >/dev/null
}

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "claude intent" $'w1:p1\twidget:fix-auth-token-refresh'

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-long" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "intent truncated at word boundary" $'w1:p1\twidget:investigate-flaky'

long_dir="$test_dir/long-project"
mkdir -p "$long_dir"
git -C "$long_dir" init -q
git -C "$long_dir" switch -q -c main
git -C "$long_dir" remote add origin git@github.com:acme/cnb-web-services-suite.git

run env HERDR_RENAME_CWD="$long_dir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-long" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "long project budgets intent" $'w1:p1\tcnb-web-services-suite:investigate-flaky'

run env HERDR_RENAME_CWD="$git_dir/subdir" HERDR_RENAME_AGENT="codex" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude" HERDR_RENAME_CODEX_BIN="$test_dir/codex"
assert_label "codex pane routes to codex" $'w1:p1\twidget:ship-codex-rename'

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-broken" HERDR_RENAME_CODEX_BIN="$test_dir/codex"
assert_label "broken claude falls back to codex" $'w1:p1\twidget:ship-codex-rename'

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-broken" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "no llm falls back to repo:branch" $'w1:p1\twidget:feature/pane'

folder="$test_dir/plain folder"
mkdir -p "$folder"
run env HERDR_RENAME_CWD="$folder" \
  HERDR_RENAME_CLAUDE_BIN="$missing" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "non-git falls back to folder name" $'w1:p1\tplain folder'

printf 'herdr-pane-rename test: ok\n'
