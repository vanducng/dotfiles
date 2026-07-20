#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/herdr-fingers-test.XXXXXX")"
trap 'rm -r "$test_dir"' EXIT

cat >"$test_dir/herdr" <<'EOF'
#!/usr/bin/env bash
[[ "$*" == "pane read pane-1 --source recent-unwrapped --lines 500 --format text" ]] || exit 1
printf '%s\n' \
  'Old docs: ./README.md' \
  'Old URL: https://example.com/docs).' \
  'Device: /dev/null' \
  "Home: $HOME/" \
  'Directory: artifacts/' \
  'Newest docs: ./README.md:7.' \
  'Newest URL: https://example.com/docs.'
EOF

cat >"$test_dir/fzf" <<'EOF'
#!/usr/bin/env bash
cat >"$HERDR_FINGERS_CHOICES"
printf '%s\n' "$HERDR_FINGERS_TEST_ACTION"
grep -m1 '^./README.md:7$' "$HERDR_FINGERS_CHOICES"
EOF

cat >"$test_dir/open-path" <<'EOF'
#!/usr/bin/env bash
if [[ "${OPEN_PATH_RESOLVE_ONLY:-0}" == 1 ]]; then
  printf 'unexpected per-candidate resolver call\n' >&2
  exit 1
fi
printf '%s|%s\n' "$*" "${BASE_DIR:-}" >"$HERDR_FINGERS_CAPTURE"
EOF

cat >"$test_dir/pbcopy" <<'EOF'
#!/usr/bin/env bash
cat >"$HERDR_FINGERS_CLIPBOARD_CAPTURE"
EOF

cat >"$test_dir/uname" <<'EOF'
#!/usr/bin/env bash
printf 'Linux\n'
EOF

cat >"$test_dir/xdg-open" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$1" >"$OPEN_PATH_XDG_CAPTURE"
EOF

chmod +x "$test_dir/herdr" "$test_dir/fzf" "$test_dir/open-path" "$test_dir/pbcopy" "$test_dir/uname" "$test_dir/xdg-open"
mkdir -p "$test_dir/project/src" "$test_dir/project/artifacts"
: >"$test_dir/project/src/main.ts"
: >"$test_dir/project/README.md"
: >"$test_dir/project/Makefile"
capture="$test_dir/capture"
choices="$test_dir/choices"
clipboard_capture="$test_dir/clipboard-capture"
PATH="$test_dir:$PATH" \
HERDR_BIN_PATH="$test_dir/herdr" \
HERDR_ACTIVE_PANE_ID="pane-1" \
HERDR_ACTIVE_PANE_CWD="$test_dir/project" \
HERDR_FINGERS_CAPTURE="$capture" \
HERDR_FINGERS_CHOICES="$choices" \
HERDR_FINGERS_CLIPBOARD_CAPTURE="$clipboard_capture" \
HERDR_FINGERS_TEST_ACTION="enter" \
  "$project_root/dotfiles/bin/.local/bin/herdr-fingers"

[[ "$(cat "$capture")" == "--browser ./README.md:7|$test_dir/project" ]]
[[ "$(cat "$choices")" == $'https://example.com/docs\n./README.md:7\nartifacts/' ]]

HERDR_FINGERS_TEST_ACTION="ctrl-y" \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_ACTIVE_PANE_ID="pane-1" \
  HERDR_ACTIVE_PANE_CWD="$test_dir/project" \
  HERDR_FINGERS_CAPTURE="$capture" \
  HERDR_FINGERS_CHOICES="$choices" \
  HERDR_FINGERS_CLIPBOARD_CAPTURE="$clipboard_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-fingers"
[[ "$(cat "$clipboard_capture")" == "./README.md:7" ]]

HERDR_FINGERS_TEST_ACTION="ctrl-e" \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_ACTIVE_PANE_ID="pane-1" \
  HERDR_ACTIVE_PANE_CWD="$test_dir/project" \
  HERDR_FINGERS_CAPTURE="$capture" \
  HERDR_FINGERS_CHOICES="$choices" \
  HERDR_FINGERS_CLIPBOARD_CAPTURE="$clipboard_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-fingers"
[[ "$(cat "$capture")" == "--editor ./README.md:7|$test_dir/project" ]]

xdg_capture="$test_dir/xdg-capture"
PATH="$test_dir:$PATH" OPEN_PATH_XDG_CAPTURE="$xdg_capture" \
  "$project_root/dotfiles/bin/.local/bin/open-path" --browser "https://example.com/docs"
[[ "$(cat "$xdg_capture")" == "https://example.com/docs" ]]
printf 'herdr-fingers test: ok\n'
