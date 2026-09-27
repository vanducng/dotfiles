#!/usr/bin/env sh
# =============================================================================
# arrange-displays.sh
# Keep 17 managed desktops when two displays are attached:
#   display 1 (main):     8 desktops
#   display 2 (built-in): 9 desktops
# With one display, keep 17 desktops on it.
#
# macOS drops the built-in display's desktops on restart, and moving a desktop
# onto another display often does nothing. Missing desktops are created on the
# display that is short. Empty surplus desktops are removed only from the
# display that has too many, so a trim can never eat the built-in row.
#
# yabai on macOS 27 acknowledges space create/destroy without changing anything
# when the scripting addition does not match Dock. A command counts only if the
# desktop count actually changes.
# Native-fullscreen spaces are macOS-owned and are left alone.
# =============================================================================

set -u

TARGET_D1=8
TARGET_D2=9
TARGET_TOTAL=17

nonzero() {
    v=${1:-0}
    { [ -z "$v" ] || [ "$v" = "null" ]; } && v=0
    echo "$v"
}

managed_json() {
    yabai -m query --spaces 2>/dev/null | jq -c '[.[] | select(."is-native-fullscreen"==false) | {index, display, id}]'
}

display_count() {
    echo "$1" | jq --argjson d "$2" '[.[] | select(.display==$d)] | length'
}

# Sticky overlays are listed on every space of their display. They must not
# make an otherwise empty desktop look occupied, or surplus desktops can never
# be removed and the built-in row can never be rebuilt.
real_windows() {
    nonzero "$(yabai -m query --windows --space "$1" 2>/dev/null | jq '[.[] | select(."is-sticky"!=true)] | length')"
}

create_on_display() {
    display=$1
    before=$(display_count "$(managed_json)" "$display")
    yabai -m space --create "$display" >/dev/null 2>&1 || return 1
    sleep 0.15
    after=$(display_count "$(managed_json)" "$display")
    [ "$after" -gt "$before" ]
}

destroy_space() {
    idx=$1
    before=$(managed_json | jq 'length')
    focused=$(yabai -m query --spaces --space 2>/dev/null | jq -r '.index // empty')
    if [ "$focused" = "$idx" ]; then
        yabai -m space --focus prev >/dev/null 2>&1 || yabai -m space --focus first >/dev/null 2>&1 || return 1
    fi
    yabai -m space --destroy "$idx" >/dev/null 2>&1 || return 1
    sleep 0.15
    after=$(managed_json | jq 'length')
    [ "$after" -lt "$before" ]
}

trim_display() {
    display=$1
    target=$2
    guard=0
    spaces=$(managed_json)
    while [ "$(display_count "$spaces" "$display")" -gt "$target" ]; do
        idx=$(echo "$spaces" | jq -r --argjson d "$display" '[.[] | select(.display==$d)][-1].index')
        { [ -z "$idx" ] || [ "$idx" = "null" ]; } && break
        n=$(real_windows "$idx")
        [ "$n" -eq 0 ] || break
        destroy_space "$idx" || break
        spaces=$(managed_json)
        guard=$((guard + 1))
        [ "$guard" -lt 16 ] || break
    done
}

fill_display() {
    display=$1
    target=$2
    guard=0
    spaces=$(managed_json)
    while [ "$(display_count "$spaces" "$display")" -lt "$target" ]; do
        create_on_display "$display" || break
        spaces=$(managed_json)
        guard=$((guard + 1))
        [ "$guard" -lt 16 ] || break
    done
}

initial_id=$(yabai -m query --spaces --space 2>/dev/null | jq -r '.id // empty')
spaces=$(managed_json)
[ -n "$spaces" ] || exit 0
displays=$(nonzero "$(yabai -m query --displays 2>/dev/null | jq 'length')")

if [ "$displays" -ge 2 ]; then
    # Built-in first, so a later trim of the main display cannot be the thing
    # that restores the missing desktops by destroying them from the tail.
    fill_display 2 "$TARGET_D2"
    fill_display 1 "$TARGET_D1"
    trim_display 1 "$TARGET_D1"
    trim_display 2 "$TARGET_D2"
else
    guard=0
    count=$(echo "$spaces" | jq 'length')
    while [ "$count" -lt "$TARGET_TOTAL" ]; do
        yabai -m space --create >/dev/null 2>&1 || break
        sleep 0.15
        spaces=$(managed_json)
        new=$(echo "$spaces" | jq 'length')
        [ "$new" -gt "$count" ] || break
        count=$new
        guard=$((guard + 1))
        [ "$guard" -lt 20 ] || break
    done
    guard=0
    while [ "$count" -gt "$TARGET_TOTAL" ]; do
        idx=$(echo "$spaces" | jq -r '.[-1].index')
        { [ -z "$idx" ] || [ "$idx" = "null" ]; } && break
        n=$(real_windows "$idx")
        [ "$n" -eq 0 ] || break
        destroy_space "$idx" || break
        spaces=$(managed_json)
        count=$(echo "$spaces" | jq 'length')
        guard=$((guard + 1))
        [ "$guard" -lt 20 ] || break
    done
fi

if [ -n "$initial_id" ]; then
    spaces=$(managed_json)
    back=$(echo "$spaces" | jq -r --argjson id "$initial_id" '.[] | select(.id==$id) | .index' | head -1)
    [ -n "$back" ] && yabai -m space --focus "$back" >/dev/null 2>&1 || true
fi
