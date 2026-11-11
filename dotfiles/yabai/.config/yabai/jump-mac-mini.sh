#!/bin/sh
# A Jump Desktop host on space 9: a jump-desktop/names display name, or N for the Nth one listed (default 1): focus its open session, or connect over Fluid.
set -eu

servers="$HOME/Library/Containers/com.p5sys.jump.mac.viewer/Data/Documents/JumpDesktop/Viewer/Servers"
names="${XDG_CONFIG_HOME:-$HOME/.config}/jump-desktop/names"
target="${1:-1}"
case "$target" in
  *[!0-9]*) ;;
  *) resolved="$(awk -v n="$target" '$1 !~ /^#/ && NF >= 2 && ++i == n {print $2; exit}' "$names" 2>/dev/null)"
     [ -n "$resolved" ] && target="$resolved" ;;
esac
host="$(awk -v target="$target" '$1 !~ /^#/ && $2 == target {print $1; exit}' "$names")"
[ -n "$host" ] || { printf 'Jump Desktop: unknown host %s\n' "$target" >&2; exit 1; }

session() {
  yabai -m query --windows | jq -r --arg host "$host" --arg target "$target" \
    '[.[] | select(.app == "Jump Desktop" and ."has-ax-reference" and
      ((.title // "" | ascii_downcase) | contains($host | ascii_downcase) or contains($target | ascii_downcase)))][0].id // empty'
}

yabai -m space 9 --layout stack 2>/dev/null || true
id="$(session)"

if [ -z "$id" ]; then
  yabai -m space --focus 9 2>/dev/null || true
  # Found by Connect hostname, which viewer renames keep. A file named like a saved
  # computer gets a "Different Computers With Same Name" confirm, so open a renamed copy.
  entry="$(jq -r --arg host "$host" 'select(.ConnectDisplayName == $host) | input_filename' "$servers"/*.jump 2>/dev/null | head -1)"
  copy="${TMPDIR:-/tmp}/jump-$target-fluid.jump"
  if [ -z "$entry" ] || ! jq --arg name "$target (Fluid)" '.DisplayName = $name' "$entry" >"$copy"; then
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

yabai -m window "$id" --space 9 2>/dev/null || true
yabai -m window "$id" --focus
