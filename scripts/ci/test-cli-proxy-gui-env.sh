#!/usr/bin/env bash
# Validate the macOS CLI_PROXY_API_KEY GUI env LaunchAgent package.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$PROJECT_ROOT/dotfiles/bin/.local/bin/set-cli-proxy-gui-env.sh"
PLIST="$PROJECT_ROOT/dotfiles/launchd/Library/LaunchAgents/local.cli-proxy-gui-env.plist"
ERRORS=0

pass() { echo "[OK] $1"; }
fail() { echo "[FAIL] $1" >&2; ERRORS=$((ERRORS + 1)); }

if [[ ! -f "$SCRIPT" ]]; then
  fail "missing $SCRIPT"
else
  pass "script present"
  if [[ -x "$SCRIPT" ]]; then
    pass "script executable"
  else
    fail "script not executable: $SCRIPT"
  fi
  if bash -n "$SCRIPT"; then
    pass "script bash -n"
  else
    fail "script bash -n failed"
  fi
  if grep -q 'launchctl setenv CLI_PROXY_API_KEY' "$SCRIPT"; then
    pass "script sets CLI_PROXY_API_KEY via launchctl"
  else
    fail "script missing launchctl setenv CLI_PROXY_API_KEY"
  fi
  if grep -q 'CLI_PROXY_GOPASS_PATH' "$SCRIPT"; then
    pass "script allows CLI_PROXY_GOPASS_PATH override"
  else
    fail "script missing CLI_PROXY_GOPASS_PATH override"
  fi
  if grep -Eq '/Users/|/home/[a-zA-Z]' "$SCRIPT"; then
    fail "script hardcodes a home path"
  else
    pass "script uses portable home paths"
  fi
fi

if [[ ! -f "$PLIST" ]]; then
  fail "missing $PLIST"
else
  pass "plist present"
  if command -v plutil >/dev/null 2>&1; then
    if plutil -lint "$PLIST" >/dev/null; then
      pass "plist plutil -lint"
    else
      fail "plist plutil -lint failed"
    fi
  elif command -v python3 >/dev/null 2>&1; then
    if python3 -c "import plistlib, pathlib; plistlib.loads(pathlib.Path(r'''$PLIST''').read_bytes())"; then
      pass "plist python plistlib parse"
    else
      fail "plist python parse failed"
    fi
  else
    echo "[WARN] no plutil/python3; skipped plist parse"
  fi
  if grep -q 'local.cli-proxy-gui-env' "$PLIST"; then
    pass "plist label local.cli-proxy-gui-env"
  else
    fail "plist missing label"
  fi
  if grep -q 'set-cli-proxy-gui-env.sh' "$PLIST"; then
    pass "plist invokes set-cli-proxy-gui-env.sh"
  else
    fail "plist missing script reference"
  fi
  if grep -q '\$HOME' "$PLIST"; then
    pass "plist uses \$HOME (portable)"
  else
    fail "plist should expand via \$HOME, not a hardcoded user path"
  fi
  if grep -Eq '/Users/[^"]|/home/[a-zA-Z]' "$PLIST"; then
    fail "plist hardcodes a home path"
  else
    pass "plist has no hardcoded home path"
  fi
fi

# launchd is macOS-only in Makefile MACOS_STOW_FOLDERS
if grep -q 'launchd' "$PROJECT_ROOT/Makefile" && grep -Eq 'MACOS_STOW_FOLDERS=.*launchd' "$PROJECT_ROOT/Makefile"; then
  pass "launchd is in MACOS_STOW_FOLDERS"
else
  fail "launchd missing from MACOS_STOW_FOLDERS"
fi

if [[ "$ERRORS" -gt 0 ]]; then
  echo "test-cli-proxy-gui-env: $ERRORS failure(s)" >&2
  exit 1
fi
echo "test-cli-proxy-gui-env: all checks passed"
