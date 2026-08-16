#!/usr/bin/env bash
# Validate the SKHD / yabai Grok Bot launcher (meh-v).
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKHD="$PROJECT_ROOT/dotfiles/skhd/.config/skhd/skhdrc"
YABAI="$PROJECT_ROOT/dotfiles/yabai/.config/yabai/yabairc"
ERRORS=0

pass() { echo "[OK] $1"; }
fail() { echo "[FAIL] $1" >&2; ERRORS=$((ERRORS + 1)); }

if [[ ! -f "$SKHD" ]]; then
  fail "missing $SKHD"
else
  pass "skhdrc present"
  if grep -Eq '^meh - v :' "$SKHD"; then
    pass "skhdrc binds meh - v"
  else
    fail "skhdrc missing meh - v binding"
  fi
  if grep -q 'open -a "Grok Bot"' "$SKHD"; then
    pass "skhdrc launches Grok Bot via Launch Services"
  else
    fail "skhdrc must use open -a \"Grok Bot\" so non-/Applications installs resolve"
  fi
  if grep -q 'select(.app == "Grok Bot")' "$SKHD"; then
    pass "skhdrc focuses an existing Grok Bot window"
  else
    fail "skhdrc must focus an existing Grok Bot yabai window before launching"
  fi
fi

if [[ ! -f "$YABAI" ]]; then
  fail "missing $YABAI"
else
  pass "yabairc present"
  if grep -q 'app="^Grok Bot$"' "$YABAI"; then
    pass "yabairc has a Grok Bot application_activated focus signal"
  else
    fail "yabairc missing Grok Bot application_activated focus signal"
  fi
fi

if [[ "$ERRORS" -gt 0 ]]; then
  echo "skhd grok test: $ERRORS error(s)" >&2
  exit 1
fi

echo "skhd grok test: ok"
