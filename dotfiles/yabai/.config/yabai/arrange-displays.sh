#!/usr/bin/env sh
# =============================================================================
# arrange-displays.sh
# Reconcile space distribution when a 2nd monitor is attached.
# Goal: display 1 holds the first TARGET_D1 spaces, display 2 holds the rest.
# Triggered at yabai startup and on display_added / display_removed signals.
# =============================================================================

TARGET_D1=8

displays=$(yabai -m query --displays | jq 'length')
[ "$displays" -lt 2 ] && exit 0

# Push surplus spaces from D1 → D2 (highest-indexed first to preserve order).
d1_count=$(yabai -m query --spaces --display 1 | jq 'length')
while [ "$d1_count" -gt "$TARGET_D1" ]; do
    last=$(yabai -m query --spaces --display 1 | jq '.[-1].index')
    yabai -m space "$last" --display 2 2>/dev/null || break
    d1_count=$((d1_count - 1))
done

# Pull spaces back from D2 → D1 if D1 dropped below target (e.g. after manual destroy).
while [ "$d1_count" -lt "$TARGET_D1" ]; do
    first=$(yabai -m query --spaces --display 2 | jq '.[0].index')
    [ -z "$first" ] || [ "$first" = "null" ] && break
    yabai -m space "$first" --display 1 2>/dev/null || break
    d1_count=$((d1_count + 1))
done
