#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/herdr-agents-test.XXXXXX")"
trap 'rm -r "$test_dir"' EXIT

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
    printf '%s\n' '{"result":{"agents":[{"workspace_id":"wA","tab_id":"wA:t2","pane_id":"wA:pY","focused":true,"label":"review","agent":"codex","agent_status":"working","foreground_cwd":"/tmp/project"}]}}'
    ;;
  'agent focus')
    printf '%s\n' "$3" >"$HERDR_AGENTS_FOCUS_CAPTURE"
    ;;
  *) exit 2 ;;
esac
EOF

cat >"$test_dir/fzf" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat >"$HERDR_AGENTS_CHOICES"
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
printf 'herdr-agents test: ok\n'
