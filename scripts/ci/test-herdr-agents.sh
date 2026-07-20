#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/herdr-agents-test.XXXXXX")"
trap '[[ -n "${test_dir:-}" ]] && rm -r "$test_dir"' EXIT

cat >"$test_dir/herdr" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "$1 $2" in
  'workspace list')
    printf '%s\n' '{"result":{"workspaces":[{"workspace_id":"wA","number":1}]}}'
    ;;
  'tab list')
    printf '%s\n' '{"result":{"tabs":[{"workspace_id":"wA","tab_id":"wA:t2","number":2}]}}'
    ;;
  'agent list')
    [[ "${HERDR_AGENTS_HERDR_FAIL:-0}" == 0 ]] || exit 7
    if [[ "${HERDR_AGENTS_HERDR_MALFORMED:-0}" == 1 ]]; then
      printf '%s\n' '{}'
      exit 0
    fi
    printf '%s\n' '{"result":{"agents":[{"workspace_id":"wA","tab_id":"wA:t2","pane_id":"wA:pY","focused":true,"label":"review","agent":"codex","agent_status":"working","foreground_cwd":"/tmp/project"}]}}'
    ;;
  'agent focus')
    [[ "${HERDR_AGENTS_FOCUS_FAIL:-0}" == 0 ]] || exit 8
    printf '%s\n' "${3:-}" >"${HERDR_AGENTS_FOCUS_CAPTURE:?}"
    ;;
  *) exit 2 ;;
esac
EOF

cat >"$test_dir/fzf" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat >"$HERDR_AGENTS_CHOICES"
[[ "${HERDR_AGENTS_FZF_STATUS:-0}" == 0 ]] || exit "$HERDR_AGENTS_FZF_STATUS"
grep -m1 '1\.2\.30' "$HERDR_AGENTS_CHOICES"
EOF

chmod +x "$test_dir/herdr" "$test_dir/fzf"
choices="$test_dir/choices"
focus_capture="$test_dir/focus"

PATH="$test_dir:$PATH" \
HERDR_BIN_PATH="$test_dir/herdr" \
HERDR_AGENTS_CHOICES="$choices" \
HERDR_AGENTS_FOCUS_CAPTURE="$focus_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-agents"

grep -q '^\* 1\.2\.30  review  codex  working  /tmp/project' "$choices"
[[ "$(cat "$focus_capture")" == "wA:pY" ]]

if HERDR_AGENTS_HERDR_FAIL=1 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_AGENTS_CHOICES="$choices" \
  HERDR_AGENTS_FOCUS_CAPTURE="$focus_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-agents" 2>"$test_dir/herdr-error"; then
  exit 1
fi
grep -q 'failed to list agents' "$test_dir/herdr-error"

if HERDR_AGENTS_HERDR_MALFORMED=1 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_AGENTS_CHOICES="$choices" \
  HERDR_AGENTS_FOCUS_CAPTURE="$focus_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-agents" 2>"$test_dir/herdr-format-error"; then
  exit 1
fi
grep -q 'unexpected herdr response format' "$test_dir/herdr-format-error"

if HERDR_AGENTS_FZF_STATUS=2 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_AGENTS_CHOICES="$choices" \
  HERDR_AGENTS_FOCUS_CAPTURE="$focus_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-agents" 2>"$test_dir/fzf-error"; then
  exit 1
else
  fzf_status=$?
fi
[[ "$fzf_status" == 2 ]]
grep -q 'fzf exited with code 2' "$test_dir/fzf-error"

if HERDR_AGENTS_FOCUS_FAIL=1 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_AGENTS_CHOICES="$choices" \
  HERDR_AGENTS_FOCUS_CAPTURE="$focus_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-agents" 2>"$test_dir/focus-error"; then
  exit 1
fi
grep -q 'failed to focus agent wA:pY' "$test_dir/focus-error"
printf 'herdr-agents test: ok\n'
