#!/usr/bin/env bash
# GPG pinentry + lazygit 0.64 config needed for signed commits from a TUI.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ZSHRC="$PROJECT_ROOT/dotfiles/zsh/.zshrc"
GPG_AGENT_CONF="$PROJECT_ROOT/dotfiles/gnupg/.gnupg/gpg-agent.conf"
LAZYGIT_CONF="$PROJECT_ROOT/dotfiles/lazygit/.config/lazygit/config.yml"
MAKEFILE="$PROJECT_ROOT/Makefile"
HOME_PATH_RE='/Users/[a-zA-Z0-9_-]|/home/[a-zA-Z]'
ERRORS=0

pass() { echo "[OK] $1"; }
fail() { echo "[FAIL] $1" >&2; ERRORS=$((ERRORS + 1)); }

if [[ ! -f "$ZSHRC" ]]; then
  fail "missing $ZSHRC"
elif grep -q 'export GPG_TTY=' "$ZSHRC"; then
  pass "zshrc exports GPG_TTY"
else
  fail "zshrc missing GPG_TTY export"
fi

if [[ ! -f "$GPG_AGENT_CONF" ]]; then
  fail "missing $GPG_AGENT_CONF"
else
  pass "gpg-agent.conf present"
  if grep -q 'pinentry-program /opt/homebrew/bin/pinentry-mac' "$GPG_AGENT_CONF"; then
    pass "gpg-agent.conf uses pinentry-mac"
  else
    fail "gpg-agent.conf missing pinentry-mac"
  fi
fi

if [[ ! -f "$LAZYGIT_CONF" ]]; then
  fail "missing $LAZYGIT_CONF"
else
  pass "lazygit config present"
  if grep -q 'diffRenderers:' "$LAZYGIT_CONF" && grep -q 'delta --paging=never' "$LAZYGIT_CONF"; then
    pass "lazygit uses 0.64 diffRenderers + delta"
  else
    fail "lazygit config missing diffRenderers/delta"
  fi
  if grep -q 'subprocess: true' "$LAZYGIT_CONF"; then
    fail "lazygit customCommands still use subprocess (0.64 wants output: terminal)"
  else
    pass "lazygit customCommands do not use subprocess"
  fi
  if command -v yq >/dev/null 2>&1; then
    if yq eval '.' "$LAZYGIT_CONF" >/dev/null 2>&1; then
      pass "lazygit config yaml parses"
    else
      fail "lazygit config yaml invalid"
    fi
  elif command -v python3 >/dev/null 2>&1; then
    if python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$LAZYGIT_CONF"; then
      pass "lazygit config yaml parses"
    else
      fail "lazygit config yaml invalid"
    fi
  else
    fail "no yaml validator available (need yq or python3+pyyaml)"
  fi
fi

if grep -Eq 'MACOS_STOW_FOLDERS=.*gnupg' "$MAKEFILE"; then
  pass "gnupg is in MACOS_STOW_FOLDERS"
else
  fail "gnupg missing from MACOS_STOW_FOLDERS"
fi

if grep -q 'pinentry-mac' "$PROJECT_ROOT/scripts/ci/check-dependencies.sh"; then
  pass "check-dependencies lists pinentry-mac"
else
  fail "check-dependencies missing pinentry-mac"
fi

if [[ ! -f "$ZSHRC" ]]; then
  fail "missing $ZSHRC (home-path check)"
elif grep -E "$HOME_PATH_RE" "$ZSHRC" | grep -q 'GPG_TTY'; then
  fail "GPG_TTY line hardcodes a home path"
else
  pass "GPG_TTY line has no hardcoded home path"
fi
for file in "$GPG_AGENT_CONF" "$LAZYGIT_CONF"; do
  if [[ ! -f "$file" ]]; then
    fail "missing $file (home-path check)"
  elif grep -Eq "$HOME_PATH_RE" "$file"; then
    fail "hardcoded home path in $file"
  else
    pass "no hardcoded home path in ${file#"$PROJECT_ROOT"/}"
  fi
done

if [[ "$ERRORS" -gt 0 ]]; then
  echo "test-gpg-lazygit: $ERRORS failure(s)" >&2
  exit 1
fi
echo "test-gpg-lazygit: all checks passed"
