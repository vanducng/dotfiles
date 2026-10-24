#!/bin/sh
# Mac mini over Jump Desktop on space 10: focus its open session, or connect over Fluid.
set -eu

servers="$HOME/Library/Containers/com.p5sys.jump.mac.viewer/Data/Documents/JumpDesktop/Viewer/Servers"

session() {
  yabai -m query --windows | jq -r '[.[] | select(.app == "Jump Desktop" and ."has-ax-reference" and (.title | test("mac01|mini-01"; "i")))][0].id // empty'
}

yabai -m space 10 --layout stack 2>/dev/null || true
id="$(session)"

if [ -z "$id" ]; then
  yabai -m space --focus 10 2>/dev/null || true
  # Found by Connect hostname, which viewer renames keep. A file named like a saved
  # computer gets a "Different Computers With Same Name" confirm, so open a renamed copy.
  entry="$(jq -r 'select(.ConnectDisplayName == "mac01") | input_filename' "$servers"/*.jump 2>/dev/null | head -1)"
  copy="${TMPDIR:-/tmp}/jump-mac-mini-fluid.jump"
  if [ -z "$entry" ] || ! jq '.DisplayName = "mini-01 (Fluid)"' "$entry" >"$copy"; then
    open -a "Jump Desktop"
    exit 0
  fi
  open -a "Jump Desktop" "$copy"
  i=0
  while [ -z "$id" ] && [ "$i" -lt 40 ]; do
    sleep 0.5
    i=$((i + 1))
    id="$(session)"
  done
  [ -n "$id" ] || exit 0
fi

yabai -m window "$id" --space 10 2>/dev/null || true
yabai -m window "$id" --focus
