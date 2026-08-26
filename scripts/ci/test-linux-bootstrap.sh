#!/usr/bin/env bash
# Guard the Linux bootstrap against the failures seen on host lab.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FAIL=0

fail() { echo "FAIL: $*" >&2; FAIL=1; }
pass() { echo "OK: $*"; }

[[ -f "$ROOT/scripts/linux-deps.sh" ]] && pass "linux-deps.sh exists" || fail "missing scripts/linux-deps.sh"
[[ -f "$ROOT/dotfiles/mise/.config/mise/conf.d/linux.toml" ]] && pass "linux.toml exists" || fail "missing linux.toml"
[[ -f "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" ]] && pass "linux.sh exists" || fail "missing linux.sh"
[[ -f "$ROOT/dotfiles/git/.config/git/work.gitconfig" ]] && pass "work.gitconfig exists" || fail "missing work.gitconfig"
[[ -f "$ROOT/dotfiles/git/.config/git/work-initech.gitconfig" ]] && pass "work-initech.gitconfig exists" || fail "missing work-initech.gitconfig"
[[ -f "$ROOT/dotfiles/git/.config/git/work-globex.gitconfig" ]] && pass "work-globex.gitconfig exists" || fail "missing work-globex.gitconfig"
[[ -f "$ROOT/dotfiles/git/.config/git/work-umbrella.gitconfig" ]] && pass "work-umbrella.gitconfig exists" || fail "missing work-umbrella.gitconfig"

bash -n "$ROOT/scripts/linux-deps.sh" && pass "linux-deps.sh parses" || fail "linux-deps.sh syntax"
bash -n "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" && pass "linux.sh parses" || fail "linux.sh syntax"

if grep -vE '^[[:space:]]*#' "$ROOT/dotfiles/mise/.config/mise/conf.d/linux.toml" | grep -q 'aqua:tmux/tmux'; then
  fail "linux.toml still uses aqua:tmux/tmux (not in aqua registry)"
else
  pass "linux.toml does not use aqua:tmux/tmux"
fi

if grep -vE '^[[:space:]]*#' "$ROOT/dotfiles/mise/.config/mise/conf.d/linux.toml" | grep -qE '^[[:space:]]*git-delta[[:space:]]*='; then
  fail "linux.toml uses git-delta (not a mise registry name)"
else
  pass "linux.toml does not use git-delta"
fi

if grep -vE '^[[:space:]]*#' "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" | grep -qE '/opt/homebrew|/Users/'; then
  fail "linux.sh contains macOS-only paths"
else
  pass "linux.sh has no macOS-only paths"
fi

if grep -q 'me@acme.example' "$ROOT/dotfiles/git/.config/git/work.gitconfig"; then
  pass "work.gitconfig has Acme email"
else
  fail "work.gitconfig missing Acme email"
fi
if grep -q 'me@vanducng.dev' "$ROOT/dotfiles/git/.config/git/work-initech.gitconfig"; then
  pass "work-initech.gitconfig has personal email"
else
  fail "work-initech.gitconfig missing personal email"
fi
if grep -q 'me@globex.example' "$ROOT/dotfiles/git/.config/git/work-globex.gitconfig"; then
  pass "work-globex.gitconfig has YDS email"
else
  fail "work-globex.gitconfig missing YDS email"
fi
if grep -q 'me@acme.example' "$ROOT/dotfiles/git/.config/git/work-umbrella.gitconfig"; then
  pass "work-umbrella.gitconfig has Acme email"
else
  fail "work-umbrella.gitconfig missing Acme email"
fi
example="$ROOT/dotfiles/git/.config/git/gitconfig.linux.example"
if grep -q 'gitdir:~/work/initech/' "$example" && grep -q 'gitdir:~/work/globex/' "$example" && grep -q 'gitdir:~/work/umbrella/' "$example"; then
  pass "gitconfig.linux.example has per-company includeIf"
else
  fail "gitconfig.linux.example missing per-company includeIf"
fi
if grep -qE 'includeIf "gitdir:~/work/"' "$example"; then
  fail "gitconfig.linux.example still has catch-all ~/work/ includeIf"
else
  pass "gitconfig.linux.example has no catch-all ~/work/ includeIf"
fi

folders="$(make --no-print-directory -s -C "$ROOT" PLATFORM=Linux stow-folders)"
echo "$folders" | grep -qx nvim && pass "Linux stow includes nvim" || fail "Linux stow missing nvim"
echo "$folders" | grep -qx herdr && pass "Linux stow includes herdr" || fail "Linux stow missing herdr"
echo "$folders" | grep -qx git && pass "Linux stow includes git" || fail "Linux stow missing git"
echo "$folders" | grep -qx claude && pass "Linux stow includes claude" || fail "Linux stow missing claude"
echo "$folders" | grep -qx kitty && pass "Linux stow includes kitty" || fail "Linux stow missing kitty"
echo "$folders" | grep -qx shell-linux && pass "Linux stow includes shell-linux" || fail "Linux stow missing shell-linux"
if echo "$folders" | grep -qx yabai; then fail "Linux stow includes yabai"; else pass "Linux stow excludes yabai"; fi
if echo "$folders" | grep -qx skhd; then fail "Linux stow includes skhd"; else pass "Linux stow excludes skhd"; fi
if echo "$folders" | grep -qx karabiner; then fail "Linux stow includes karabiner"; else pass "Linux stow excludes karabiner"; fi
if echo "$folders" | grep -qx grok; then fail "Linux stow auto-includes grok"; else pass "Linux stow skips grok (opt-in)"; fi

darwin="$(make --no-print-directory -s -C "$ROOT" PLATFORM=Darwin stow-folders)"
echo "$darwin" | grep -qx yabai && pass "Darwin stow includes yabai" || fail "Darwin stow missing yabai"

if grep -q 'linux-deps' "$ROOT/Makefile"; then
  pass "Makefile has linux-deps target"
else
  fail "Makefile missing linux-deps"
fi

if [[ $FAIL -ne 0 ]]; then
  echo "test-linux-bootstrap: FAILED" >&2
  exit 1
fi
echo "test-linux-bootstrap: OK"
