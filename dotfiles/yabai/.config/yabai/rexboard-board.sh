#!/bin/sh
# Makes the rexboard board window a narrow right column on space 1: the board is the right
# side of a side-by-side split, at 22% of it. Runs from the yabairc title signal.
set -u
id=$1
field() { yabai -m query --windows --window "$id" | jq -r "$1"; }
[ "$(field '."is-floating"')" = false ] || exit 0
yabai -m window "$id" --space 1 2>/dev/null || true
[ "$(field '."split-type"')" = horizontal ] && yabai -m window "$id" --toggle split
[ "$(field '."split-child"')" = first_child ] && yabai -m window "$id" --swap east
yabai -m window "$id" --ratio abs:0.78
