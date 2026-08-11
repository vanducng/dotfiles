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
    printf 'API_TOKEN=do-not-send\n'
    printf '{"apiKey":"json-secret-value"}\n'
    printf "api_key: 'single-secret-value'\n"
    printf 'DATABASE_URL=postgres://user:pass@host\n'
    printf 'Authorization: Bearer bearer-secret-value-12345\n'
    printf 'github_pat_%s\n' 'abcdefghijklmnopqrstuvwxyz1234567890'
    printf '%s%s\n' 'AKIA' 'ABCDEFGHIJKLMNOP'
    printf '%s\n' '-----BEGIN PRIVATE KEY-----' 'multi-line-key-material' '-----END PRIVATE KEY-----'
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
set -euo pipefail
prompt="$(cat)"
fail_prompt() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}
assert_prompt_contains() {
  local needle="$1"
  [[ "$prompt" == *"$needle"* ]] || fail_prompt "prompt missing: $needle"
}
assert_prompt_absent() {
  local needle="$1"
  [[ "$prompt" != *"$needle"* ]] || fail_prompt "prompt leaked: $needle"
}
assert_prompt_contains 'Repository: widget'
assert_prompt_contains 'Branch: feature/token-refresh'
assert_prompt_contains $'Changed files:\n[redacted sensitive context]'
assert_prompt_contains 'Terminal title: Fix auth bug'
assert_prompt_contains 'Recent output (untrusted terminal scrollback'
assert_prompt_contains '[redacted sensitive context]'
assert_prompt_absent 'do-not-send'
assert_prompt_absent '.env.production'
assert_prompt_absent 'id_rsa'
assert_prompt_absent 'certificate.p12'
assert_prompt_absent 'json-secret-value'
assert_prompt_absent 'single-secret-value'
assert_prompt_absent 'postgres://user:pass@host'
assert_prompt_absent 'bearer-secret-value-12345'
assert_prompt_absent 'abcdefghijklmnopqrstuvwxyz1234567890'
aws_access_key_prefix='AKIA'
aws_access_key_suffix='ABCDEFGHIJKLMNOP'
assert_prompt_absent "${aws_access_key_prefix}${aws_access_key_suffix}"
assert_prompt_absent 'multi-line-key-material'
assert_prompt_absent 'BEGIN PRIVATE KEY'
assert_prompt_absent 'END PRIVATE KEY'
assert_prompt_contains '80 characters or fewer'
printf 'Fix Auth Token Refresh\n'
EOF
chmod +x "$test_dir/claude"

cat >"$test_dir/claude-long" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'Investigate Flaky Integration Test Timeouts\n'
EOF
chmod +x "$test_dir/claude-long"

cat >"$test_dir/claude-too-long" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'context-word-%.0s' {1..10}
EOF
chmod +x "$test_dir/claude-too-long"

cat >"$test_dir/claude-long-project" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
prompt="$(cat)"
[[ "$prompt" == *'Repository: cnb-web-services-suite'* ]] || {
  printf 'FAIL: expected exact repository in prompt\n' >&2
  exit 1
}
printf 'Investigate Flaky Integration Test Timeouts\n'
EOF
chmod +x "$test_dir/claude-long-project"

cat >"$test_dir/claude-legacy" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'other-project:Keep Auth Flow\n'
EOF
chmod +x "$test_dir/claude-legacy"

cat >"$test_dir/claude-ticket" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'ELT-3451:Fix Lead Performance\n'
EOF
chmod +x "$test_dir/claude-ticket"

cat >"$test_dir/claude-colon-task" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'refactor:split-handler\n'
EOF
chmod +x "$test_dir/claude-colon-task"

cat >"$test_dir/claude-sensitive-branch" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
prompt="$(cat)"
if [[ "$prompt" != *'Branch: [redacted sensitive context]'* ]]; then
  printf 'FAIL: sensitive branch leaked into prompt\n' >&2
  exit 1
fi
printf 'Investigate API Key Rotation\n'
EOF
chmod +x "$test_dir/claude-sensitive-branch"

cat >"$test_dir/claude-broken" <<'EOF'
#!/usr/bin/env bash
printf 'invalid:Invalid API key · Fix external API key\n'
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
cat >/dev/null
printf 'Ship Codex Rename\n' >"$out"
EOF
chmod +x "$test_dir/codex"

git_dir="$test_dir/widget-worktree"
mkdir -p "$git_dir/subdir"
git -C "$git_dir" init -q
git -C "$git_dir" switch -q -c feature/token-refresh
git -C "$git_dir" remote add origin git@github.com:acme/widget.git
touch "$git_dir/.env.production"
touch "$git_dir/id_rsa" "$git_dir/certificate.p12"

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
assert_label "label can exceed old limit" $'w1:p1\twidget:investigate-flaky-integration-test-timeouts'

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-too-long" HERDR_RENAME_CODEX_BIN="$missing"
expected_long="widget:$(printf 'context-word-%.0s' {1..5})context"
assert_label "label is capped at a word boundary" $'w1:p1\t'"$expected_long"

long_dir="$test_dir/long-project"
mkdir -p "$long_dir"
git -C "$long_dir" init -q
git -C "$long_dir" switch -q -c main
git -C "$long_dir" remote add origin git@github.com:acme/cnb-web-services-suite.git

run env HERDR_RENAME_CWD="$long_dir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-long-project" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "task stays paired with exact repository" $'w1:p1\tcnb-web-services-suite:investigate-flaky-integration-test-timeouts'

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-legacy" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "legacy project prefix cannot override repository" $'w1:p1\twidget:keep-auth-flow'

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-ticket" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "ticket prefix stays in task" $'w1:p1\twidget:elt-3451-fix-lead-performance'

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-colon-task" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "lowercase colon task keeps its context" $'w1:p1\twidget:refactor-split-handler'

run env HERDR_RENAME_CWD="$git_dir/subdir" HERDR_RENAME_AGENT="codex" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude" HERDR_RENAME_CODEX_BIN="$test_dir/codex"
assert_label "codex pane routes to codex" $'w1:p1\twidget:ship-codex-rename'

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-broken" HERDR_RENAME_CODEX_BIN="$test_dir/codex"
assert_label "broken claude falls back to codex" $'w1:p1\twidget:ship-codex-rename'

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-broken" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "no llm falls back to slugified repo:branch" $'w1:p1\twidget:feature-token-refresh'

git -C "$git_dir" branch -m feature/api-key

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-sensitive-branch" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "sensitive branch is redacted for prompts" $'w1:p1\twidget:investigate-api-key-rotation'

run env HERDR_RENAME_CWD="$git_dir/subdir" \
  HERDR_RENAME_CLAUDE_BIN="$test_dir/claude-broken" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "sensitive branch falls back without branch text" $'w1:p1\twidget:branch'

folder="$test_dir/plain folder"
mkdir -p "$folder"
run env HERDR_RENAME_CWD="$folder" \
  HERDR_RENAME_CLAUDE_BIN="$missing" HERDR_RENAME_CODEX_BIN="$missing"
assert_label "non-git falls back to folder name" $'w1:p1\tplain folder'

printf 'herdr-pane-rename test: ok\n'
