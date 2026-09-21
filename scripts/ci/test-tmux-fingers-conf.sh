#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONF="$ROOT/dotfiles/tmux/.tmux.conf"
KITTY="$ROOT/dotfiles/kitty/.config/kitty/kitty.conf"
THEME="$ROOT/dotfiles/kitty/.config/kitty/current-theme.conf"
DEPS="$ROOT/scripts/macos-deps.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

[[ -f "$CONF" ]] || fail "missing $CONF"

grep -q '/opt/homebrew/bin/tmux-fingers' "$CONF" || fail "tmux.conf should prefer the arm64 Homebrew binary"
grep -q "command -v tmux-fingers" "$CONF" && fail "tmux.conf still uses command -v tmux-fingers (hits leftover x86_64 /usr/local)"
grep -q '@fingers-copy-command' "$CONF" && fail "tmux.conf still sets removed @fingers-copy-command"
grep -q '@fingers-use-system-clipboard' "$CONF" || fail "tmux.conf should set @fingers-use-system-clipboard"
grep -q 'brew install tmux-fingers' "$DEPS" || fail "macos-deps.sh should install tmux-fingers"
grep -q 'bind-key -n C-1 select-window' "$CONF" || fail "tmux should bind Ctrl+1 to a window"
grep -q 'xterm-kitty:.*extkeys' "$CONF" || fail "tmux should enable kitty extended keys"
grep -q 'map ctrl+1 send_text all' "$KITTY" || fail "kitty should forward Ctrl+1 as CSI-u"
grep -q 'Duskfox' "$KITTY" || fail "kitty theme comment should be Duskfox"
grep -q 'background #232136' "$THEME" || fail "current-theme.conf should be Duskfox"
pass "tmux.conf prefers a runnable tmux-fingers"

if [[ -x /opt/homebrew/bin/tmux-fingers ]] && command -v tmux >/dev/null 2>&1; then
  file /opt/homebrew/bin/tmux-fingers | grep -q 'arm64' || fail "Homebrew tmux-fingers is not arm64"
  socket="tmux-fingers-conf-$$"
  err="$(mktemp "${TMPDIR:-/tmp}/tmux-fingers-conf.XXXXXX")"
  trap 'tmux -L "$socket" kill-server >/dev/null 2>&1 || true; rm -f -- "$err"' EXIT
  tmux -L "$socket" -f "$CONF" new-session -d -s t -n hold sleep 20 2>"$err" || true
  sleep 0.6
  if grep -q "tmux-fingers load-config' returned 126" "$err"; then
    tmux -L "$socket" kill-server >/dev/null 2>&1 || true
    fail "load-config still 126: $(cat "$err")"
  fi
  if grep -q "Unknown option: copy_command" "$err"; then
    tmux -L "$socket" kill-server >/dev/null 2>&1 || true
    fail "load-config still rejects copy_command: $(cat "$err")"
  fi
  tmux -L "$socket" run-shell "/opt/homebrew/bin/tmux-fingers load-config" 2>"$err"
  if grep -q "returned 1\|returned 126\|Unknown option" "$err"; then
    tmux -L "$socket" kill-server >/dev/null 2>&1 || true
    fail "explicit load-config failed: $(cat "$err")"
  fi
  binds="$(tmux -L "$socket" list-keys -T prefix)"
  printf '%s\n' "$binds" | grep -q 'fingers' || fail "prefix table missing fingers bind: $binds"
  tmux -L "$socket" kill-server >/dev/null 2>&1 || true
  rm -f "$err"
  pass "load-config succeeds and registers fingers"
fi
