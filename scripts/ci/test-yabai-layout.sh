#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
YABAI="$ROOT/dotfiles/yabai/.config/yabai"
ARRANGE="$YABAI/arrange-displays.sh"
APPLY="$YABAI/apply-layout.sh"
RC="$YABAI/yabairc"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

sh -n "$ARRANGE" || fail "arrange-displays.sh syntax"
sh -n "$APPLY" || fail "apply-layout.sh syntax"
sh -n "$RC" || fail "yabairc syntax"
pass "yabai scripts parse"

grep -q 'TARGET_D1=8' "$ARRANGE" || fail "main display target is not 8"
grep -q 'TARGET_D2=9' "$ARRANGE" || fail "built-in display target is not 9"
grep -q 'space --create "$display"' "$ARRANGE" || fail "missing desktops are not created on the short display"
grep -q 'is-sticky' "$ARRANGE" || fail "sticky overlays still count as desktop occupants"
grep -q 'fill_display 2' "$ARRANGE" || fail "built-in display is not filled before the main display is trimmed"
pass "desktop counts are per display"

# The old loop destroyed the global last desktop whenever the total was high.
# That last desktop belongs to the built-in display, so a restart trimmed it away.
if grep -q 'while \[ "$count" -gt "$TARGET_TOTAL" \]' "$ARRANGE" \
  && ! grep -q 'fill_display 2' "$ARRANGE"; then
  fail "surplus desktops are still destroyed from the global tail"
fi
pass "built-in desktops are not trimmed to satisfy the total"

grep -q 'apply-layout.sh' "$RC" || fail "yabairc does not run apply-layout"
grep -q 'event=display_added' "$RC" || fail "display_added does not reapply the layout"
grep -q 'event=display_removed' "$RC" || fail "display_removed does not reapply the layout"
grep -q 'sleep 8' "$RC" || fail "layout is not retried after the built-in display appears"
pass "layout is reapplied on hotplug and after login"

grep -q 'window "$id" --space "$sp"' "$APPLY" || fail "reload does not move a window onto its pinned desktop"
grep -q 'rule --apply' "$APPLY" || fail "reload does not reapply yabai rules"
if grep -q 'target_disp' "$APPLY"; then
  fail "reload still skips a pin when the desktop is on the other display"
fi
grep -q 'Aside:4' "$APPLY" || fail "Aside pin missing"
grep -q 'ego lite:17' "$APPLY" || fail "ego lite pin missing"
if grep -q 'Vivaldi' "$APPLY" || grep -q 'Vivaldi' "$RC"; then
  fail "Vivaldi is still pinned"
fi
grep -q 'place_on_builtin "Zalo"' "$APPLY" || fail "reload does not keep Zalo on the built-in display"
grep -q 'place_on_builtin "Telegram"' "$APPLY" || fail "reload does not keep Telegram on the built-in display"
grep -q 'app="^Zalo$".*display=2' "$RC" || fail "Zalo rule does not target the built-in display"
grep -q 'app="^Telegram$".*display=2' "$RC" || fail "Telegram rule does not target the built-in display"
if grep -q 'Zalo:11' "$APPLY" || grep -q 'Telegram:12' "$APPLY"; then
  fail "reload still pins Zalo or Telegram to a main-display desktop"
fi
pass "reload puts every pinned window on its desktop"
