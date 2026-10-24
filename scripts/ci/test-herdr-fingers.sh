#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/herdr-fingers-test.XXXXXX")"
trap 'rm -r "$test_dir"' EXIT

cat >"$test_dir/herdr" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ "$*" == "pane read pane-1 --source recent-unwrapped --lines 500 --format text" ]] || exit 1
[[ "${HERDR_FINGERS_HERDR_FAIL:-0}" == 0 ]] || exit 7
if [[ -n "${HERDR_FINGERS_PANE_FILE:-}" ]]; then
  cat "$HERDR_FINGERS_PANE_FILE"
  exit 0
fi
if [[ "${HERDR_FINGERS_EXPECT_WRAPPED:-0}" == 1 ]]; then
  printf '%s\n' \
    '12345678901234567890123 [link](http' \
    '         s://github.com/example/repo/issues/1206)'
  exit 0
fi
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
set -euo pipefail
cat >"$HERDR_FINGERS_CHOICES"
[[ "${HERDR_FINGERS_FZF_STATUS:-0}" == 0 ]] || exit "$HERDR_FINGERS_FZF_STATUS"
printf '%s\n' "$HERDR_FINGERS_TEST_ACTION"
[[ "${HERDR_FINGERS_EMPTY_SELECTION:-0}" == 0 ]] || exit 0
if [[ "${HERDR_FINGERS_SKIP_FZF_ASSERT:-0}" == 1 ]]; then
  head -n 1 "$HERDR_FINGERS_CHOICES"
  exit 0
fi
if [[ "${HERDR_FINGERS_EXPECT_WRAPPED:-0}" == 1 ]]; then
  grep -m1 '^https://github.com/example/repo/issues/1206$' "$HERDR_FINGERS_CHOICES"
else
  grep -m1 '^\./README.md:7$' "$HERDR_FINGERS_CHOICES"
fi
EOF

cat >"$test_dir/rg" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "--pcre2-version" ]]; then
  exit 0
fi
input="$(cat)"
if [[ "${HERDR_FINGERS_EXPECT_WRAPPED:-0}" == 1 ]]; then
  grep -Fq 'https://github.com/example/repo/issues/1206' <<<"$input"
  printf '%s\n' 'https://github.com/example/repo/issues/1206'
  exit 0
fi
printf '%s\n' \
  'https://example.com/docs.' \
  '"My Project/report.md"' \
  './README.md:7.' \
  'artifacts/' \
  "$HOME/" \
  '/dev/null' \
  'https://example.com/docs).' \
  './README.md'
EOF

cat >"$test_dir/open-path" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${OPEN_PATH_RESOLVE_ONLY:-0}" == 1 ]]; then
  printf 'unexpected per-candidate resolver call\n' >&2
  exit 1
fi
printf '%s|%s\n' "$*" "${BASE_DIR:-}" >"$HERDR_FINGERS_CAPTURE"
EOF

cat >"$test_dir/pbcopy" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat >"$HERDR_FINGERS_CLIPBOARD_CAPTURE"
[[ "${HERDR_FINGERS_CLIPBOARD_FAIL:-0}" == 0 ]] || exit 4
EOF

cat >"$test_dir/uname" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'Linux\n'
EOF

cat >"$test_dir/xdg-open" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$1" >"$OPEN_PATH_XDG_CAPTURE"
EOF

cat >"$test_dir/nvim" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$1" >"$OPEN_PATH_EDITOR_CAPTURE"
EOF

cat >"$test_dir/git" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ -z "${HERDR_FINGERS_GIT_LOG:-}" ]] || printf '%s\n' "$*" >>"$HERDR_FINGERS_GIT_LOG"
exit 1
EOF

chmod +x "$test_dir/herdr" "$test_dir/fzf" "$test_dir/rg" "$test_dir/open-path" "$test_dir/pbcopy" "$test_dir/uname" "$test_dir/xdg-open" "$test_dir/nvim" "$test_dir/git"
mkdir -p "$test_dir/project/src" "$test_dir/project/artifacts" "$test_dir/project/My Project"
: >"$test_dir/project/src/main.ts"
: >"$test_dir/project/README.md"
: >"$test_dir/project/Makefile"
: >"$test_dir/project/My Project/report.md"
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
[[ "$(cat "$choices")" == $'https://example.com/docs\nMy Project/report.md\n./README.md:7\nartifacts/' ]]

# Rex hands over the pane text as a file; no Herdr pane or binary is needed.
printf '%s\n' 'Newest docs: ./README.md:7.' >"$test_dir/pane-text"
HERDR_FINGERS_GIT_LOG="$test_dir/git-calls" \
HERDR_FINGERS_HERDR_FAIL=1 \
HERDR_FINGERS_TEXT_FILE="$test_dir/pane-text" \
HERDR_FINGERS_TEST_ACTION="enter" \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/missing-herdr" \
  HERDR_ACTIVE_PANE_CWD="$test_dir/project" \
  HERDR_FINGERS_CAPTURE="$capture" \
  HERDR_FINGERS_CHOICES="$choices" \
  HERDR_FINGERS_CLIPBOARD_CAPTURE="$clipboard_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-fingers"
[[ "$(cat "$capture")" == "--browser ./README.md:7|$test_dir/project" ]]
# Every candidate resolved under the pane folder, so git never ran.
[[ ! -s "$test_dir/git-calls" ]]

HERDR_FINGERS_EXPECT_WRAPPED=1 \
HERDR_FINGERS_PANE_WIDTH=36 \
HERDR_FINGERS_TEST_ACTION="enter" \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/missing-herdr" \
  HERDR_ACTIVE_PANE_ID="pane-1" \
  HERDR_ACTIVE_PANE_CWD="$test_dir/project" \
  HERDR_FINGERS_CAPTURE="$capture" \
  HERDR_FINGERS_CHOICES="$choices" \
  HERDR_FINGERS_CLIPBOARD_CAPTURE="$clipboard_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-fingers"
[[ "$(cat "$capture")" == "--browser https://github.com/example/repo/issues/1206|$test_dir/project" ]]
[[ "$(cat "$choices")" == "https://github.com/example/repo/issues/1206" ]]

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

if HERDR_FINGERS_CLIPBOARD_FAIL=1 \
  HERDR_FINGERS_TEST_ACTION="ctrl-y" \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_ACTIVE_PANE_ID="pane-1" \
  HERDR_ACTIVE_PANE_CWD="$test_dir/project" \
  HERDR_FINGERS_CAPTURE="$capture" \
  HERDR_FINGERS_CHOICES="$choices" \
  HERDR_FINGERS_CLIPBOARD_CAPTURE="$clipboard_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-fingers" 2>"$test_dir/clipboard-error"; then
  exit 1
else
  clipboard_status=$?
fi
[[ "$clipboard_status" == 1 ]]
grep -q 'pbcopy failed' "$test_dir/clipboard-error"

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

if HERDR_FINGERS_HERDR_FAIL=1 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_ACTIVE_PANE_ID="pane-1" \
  HERDR_ACTIVE_PANE_CWD="$test_dir/project" \
  HERDR_FINGERS_CAPTURE="$capture" \
  HERDR_FINGERS_CHOICES="$choices" \
  HERDR_FINGERS_CLIPBOARD_CAPTURE="$clipboard_capture" \
  HERDR_FINGERS_TEST_ACTION="enter" \
  "$project_root/dotfiles/bin/.local/bin/herdr-fingers" 2>"$test_dir/herdr-error"; then
  exit 1
else
  herdr_status=$?
fi
[[ "$herdr_status" == 1 ]]
grep -q 'failed to read pane pane-1' "$test_dir/herdr-error"

rm -f "$capture"
HERDR_FINGERS_EMPTY_SELECTION=1 \
  HERDR_FINGERS_TEST_ACTION="ctrl-e" \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_ACTIVE_PANE_ID="pane-1" \
  HERDR_ACTIVE_PANE_CWD="$test_dir/project" \
  HERDR_FINGERS_CAPTURE="$capture" \
  HERDR_FINGERS_CHOICES="$choices" \
  HERDR_FINGERS_CLIPBOARD_CAPTURE="$clipboard_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-fingers"
[[ ! -e "$capture" ]]

if HERDR_FINGERS_FZF_STATUS=2 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_ACTIVE_PANE_ID="pane-1" \
  HERDR_ACTIVE_PANE_CWD="$test_dir/project" \
  HERDR_FINGERS_CAPTURE="$capture" \
  HERDR_FINGERS_CHOICES="$choices" \
  HERDR_FINGERS_CLIPBOARD_CAPTURE="$clipboard_capture" \
  HERDR_FINGERS_TEST_ACTION="enter" \
  "$project_root/dotfiles/bin/.local/bin/herdr-fingers" 2>"$test_dir/fzf-error"; then
  exit 1
else
  fzf_status=$?
fi
[[ "$fzf_status" == 2 ]]
grep -q 'fzf exited with code 2' "$test_dir/fzf-error"

grep -q 'OPEN_PATH_BROWSER:=Aside' "$project_root/dotfiles/bin/.local/bin/open-path"

xdg_capture="$test_dir/xdg-capture"
PATH="$test_dir:$PATH" OPEN_PATH_XDG_CAPTURE="$xdg_capture" \
  "$project_root/dotfiles/bin/.local/bin/open-path" --browser "https://example.com/docs"
[[ "$(cat "$xdg_capture")" == "https://example.com/docs" ]]

decoded_path="$(
  PATH="$test_dir:$PATH" \
  OPEN_PATH_RESOLVE_ONLY=1 \
    "$project_root/dotfiles/bin/.local/bin/open-path" --browser \
      "http://localhost:3556/view?file=$(node -e 'process.stdout.write(encodeURIComponent(process.argv[1]))' "$test_dir/project/README.md")&root=%2Ftmp"
)"
[[ "$decoded_path" == "$(realpath "$test_dir/project/README.md")" ]]

editor_capture="$test_dir/editor-capture"
PATH="$test_dir:$PATH" \
OPEN_PATH_EDITOR_CMD="$test_dir/nvim" \
OPEN_PATH_EDITOR_CAPTURE="$editor_capture" \
BASE_DIR="$test_dir/project" \
  "$project_root/dotfiles/bin/.local/bin/open-path" --editor "My Project/report.md"
[[ "$(cat "$editor_capture")" == "$(realpath "$test_dir/project/My Project/report.md")" ]]

if PATH="$test_dir:$PATH" \
  OPEN_PATH_EDITOR_CMD="$test_dir/missing-editor" \
  BASE_DIR="$test_dir/project" \
  "$project_root/dotfiles/bin/.local/bin/open-path" --editor "README.md" 2>"$test_dir/editor-error"; then
  exit 1
else
  missing_editor_status=$?
fi
[[ "$missing_editor_status" == 1 ]]
grep -q 'editor command not found' "$test_dir/editor-error"

real_rg="$(command -v rg)"
space_root="$test_dir/space-root"
mkdir -p "$space_root/Library/Application Support/CleanShot/media/id" "$space_root/widget/demo" "$space_root/docs"
printf 'decoy\n' >"$space_root/Library/Application"
printf 'jpg\n' >"$space_root/Library/Application Support/CleanShot/media/id/CleanShot 2026-10-12 at 20.46.11@2x.jpg"
printf 'shot\n' >"$space_root/Library/Application Support/Shot 1.jpg"
printf 'guide\n' >"$space_root/docs/guide.md"
jpg="$space_root/Library/Application Support/CleanShot/media/id/CleanShot 2026-10-12 at 20.46.11@2x.jpg"
shot="$space_root/Library/Application Support/Shot 1.jpg"
decoy="$space_root/Library/Application"
pane_file="$test_dir/pane.txt"
tilde_demo='~'
{
  printf '%s\n' "${tilde_demo}/widget/demo"
  printf '%s\n' 'notes in docs/guide.md please'
  printf '%s END https://example.com/after\n' "$jpg"
  printf '%s/%s\n' "$space_root" 'Library/Application\ Support/Shot\ 1.jpg'
} >"$pane_file"
mkdir -p "$test_dir/realbin"
ln -s "$real_rg" "$test_dir/realbin/rg"
: >"$choices"
HOME="$space_root" \
HERDR_FINGERS_PANE_FILE="$pane_file" \
HERDR_FINGERS_SKIP_FZF_ASSERT=1 \
HERDR_FINGERS_TEST_ACTION="enter" \
  PATH="$test_dir/realbin:$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_ACTIVE_PANE_ID="pane-1" \
  HERDR_ACTIVE_PANE_CWD="$space_root" \
  HERDR_FINGERS_CAPTURE="$capture" \
  HERDR_FINGERS_CHOICES="$choices" \
  HERDR_FINGERS_CLIPBOARD_CAPTURE="$clipboard_capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-fingers"
grep -Fxq "${tilde_demo}/widget/demo" "$choices"
grep -Fxq 'docs/guide.md' "$choices"
grep -Fxq "$jpg" "$choices"
grep -Fxq "$shot" "$choices"
grep -Fxq 'https://example.com/after' "$choices"
if grep -Fxq "$decoy" "$choices"; then
  printf 'decoy path was offered:\n%s\n' "$(cat "$choices")" >&2
  exit 1
fi
if grep -Fq "${jpg} END" "$choices"; then
  printf 'trailing word stayed on the path:\n%s\n' "$(cat "$choices")" >&2
  exit 1
fi
printf 'herdr-fingers test: ok\n'
