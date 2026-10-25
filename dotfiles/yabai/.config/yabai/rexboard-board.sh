#!/bin/sh
# Makes the rexboard board window a narrow right column on space 1: the board is the right
# side of a side-by-side split, 22% of the display or Rex's minimum window width (720pt,
# measured, plus gap and padding), whichever is wider. Runs from the yabairc title signal.
set -u
id=$1
field() { yabai -m query --windows --window "$id" | jq -r "$1"; }
[ "$(field '."is-floating"')" = false ] || exit 0
yabai -m window "$id" --space 1 2>/dev/null || true
[ "$(field '."split-type"')" = horizontal ] && yabai -m window "$id" --toggle split
[ "$(field '."split-child"')" = first_child ] && yabai -m window "$id" --swap east
width=$(yabai -m query --displays --window "$id" | jq '.frame.w')
ratio=$(awk -v w="$width" 'BEGIN { r = 1 - 730 / w; if (r > 0.78) r = 0.78; if (r < 0.5) r = 0.5; printf "%.3f", r }')
yabai -m window "$id" --ratio "abs:$ratio"
