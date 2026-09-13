#!/usr/bin/env sh
# =============================================================================
# arrange-displays.sh
# Keep 16 managed spaces: D1 = 1-8, D2 = 9-16 (when a 2nd monitor is attached).
# Native-fullscreen spaces are macOS-owned and are left alone.
# Triggered at yabai startup and on display_added / display_removed signals.
# =============================================================================

set -u

TARGET_D1=8
TARGET_TOTAL=16

nonzero() {
    v=${1:-0}
    { [ -z "$v" ] || [ "$v" = "null" ]; } && v=0
    echo "$v"
}

count=$(nonzero "$(yabai -m query --spaces 2>/dev/null | jq '[.[] | select(."is-native-fullscreen"==false)] | length')")
while [ "$count" -lt "$TARGET_TOTAL" ]; do
    yabai -m space --create 2>/dev/null || break
    count=$((count + 1))
done

displays=$(nonzero "$(yabai -m query --displays 2>/dev/null | jq 'length')")
if [ "$displays" -ge 2 ]; then
    d1_count=$(nonzero "$(yabai -m query --spaces --display 1 2>/dev/null | jq '[.[] | select(."is-native-fullscreen"==false)] | length')")
    while [ "$d1_count" -gt "$TARGET_D1" ]; do
        last=$(yabai -m query --spaces --display 1 2>/dev/null | jq '[.[] | select(."is-native-fullscreen"==false)] | .[-1].index')
        yabai -m space "$last" --display 2 2>/dev/null || break
        d1_count=$((d1_count - 1))
    done
    while [ "$d1_count" -lt "$TARGET_D1" ]; do
        first=$(yabai -m query --spaces --display 2 2>/dev/null | jq '[.[] | select(."is-native-fullscreen"==false)] | .[0].index')
        [ -z "$first" ] || [ "$first" = "null" ] && break
        yabai -m space "$first" --display 1 2>/dev/null || break
        d1_count=$((d1_count + 1))
    done
fi

while [ "$count" -gt "$TARGET_TOTAL" ]; do
    last=$(yabai -m query --spaces 2>/dev/null | jq '[.[] | select(."is-native-fullscreen"==false)] | .[-1].index')
    [ -z "$last" ] || [ "$last" = "null" ] && break
    focused=$(yabai -m query --spaces --space 2>/dev/null | jq '.index')
    if [ "$last" = "$focused" ]; then
        yabai -m space --focus prev 2>/dev/null || yabai -m space --focus first 2>/dev/null || break
    fi
    yabai -m space "$last" --destroy 2>/dev/null || break
    count=$((count - 1))
done
