#!/usr/bin/env sh
# Put every pinned app back on its desktop. Runs from yabai startup, display
# hotplug, and the post-login retry. The pin is the space index in the list
# below; a reload always moves the window there.

set -u

lockdir="${TMPDIR:-/tmp}/yabai-apply-layout.lock"
if [ -d "$lockdir" ]; then
    now=$(date +%s)
    mtime=$(stat -f %m "$lockdir" 2>/dev/null || echo 0)
    if [ $((now - mtime)) -gt 60 ]; then
        rmdir "$lockdir" 2>/dev/null || true
    fi
fi
i=0
while ! mkdir "$lockdir" 2>/dev/null; do
    i=$((i + 1))
    [ "$i" -gt 100 ] && exit 0
    sleep 0.2
done
trap 'rmdir "$lockdir" 2>/dev/null || true' EXIT INT TERM

# app:space. Spaces 1-8 are the main display. Spaces 9-17 are the built-in.
# Names contain spaces, so the list is one pin per line.
read_pins() {
    cat <<'EOF'
Ghostty:1
LibreOffice:2
soffice:2
Dia:3
Google Chrome:4
Aside:4
Cursor:5
Preview:6
Foxit PDF Reader:6
Alter:7
Obsidian:8
Discord:12
WhatsApp:12
Arc:13
Slack:14
Cliq:14
kitty:15
Codex:16
ChatGPT:16
Claude:16
Grok Bot:16
ego lite:17
EOF
}

window_ids() {
    app=$1
    yabai -m query --windows 2>/dev/null | jq -r --arg a "$app" '
        .[]
        | select(
            (.app | gsub("\u200e"; "")) == $a
            and (."is-sticky" != true)
            and ((.title // "") | test("^(sysmon|notes-vault|herdr-bar)") | not)
          )
        | .id
    '
}

"$HOME/.config/yabai/arrange-displays.sh"

# Stack the shared desktops before the moves so a new neighbor does not
# bsp-split the window already there.
yabai -m space 12 --layout stack >/dev/null 2>&1 || true
yabai -m space 14 --layout stack >/dev/null 2>&1 || true
yabai -m space 16 --layout stack >/dev/null 2>&1 || true

read_pins | while IFS= read -r pin; do
    [ -n "$pin" ] || continue
    app=${pin%:*}
    sp=${pin#*:}
    for id in $(window_ids "$app"); do
        [ -n "$id" ] || continue
        cur=$(yabai -m query --windows --window "$id" 2>/dev/null | jq -r '.space // empty')
        [ "$cur" = "$sp" ] && continue
        yabai -m window "$id" --space "$sp" >/dev/null 2>&1 || true
    done
done

# Rules only fire for new windows. Reapply them so a reload puts every
# matching window back, including ones the id loop could not address.
yabai -m rule --apply >/dev/null 2>&1 || true

# Zalo and Telegram belong on the built-in display. Their numbered desktops
# (11 and 12) count only when those desktops are actually on display 2.
# Otherwise each gets its own empty built-in desktop, skipping Slack, kitty,
# the AI apps, and ego.
place_on_builtin() {
    app=$1
    preferred=$2
    ids=$(window_ids "$app")
    [ -n "$ids" ] || return 0
    target=""
    disp=$(yabai -m query --spaces --space "$preferred" 2>/dev/null | jq -r '.display // empty')
    cur_space=$(yabai -m query --windows --window "$(printf '%s\n' "$ids" | head -1)" 2>/dev/null | jq -r '.space // empty')
    cur_disp=$(yabai -m query --spaces --space "$cur_space" 2>/dev/null | jq -r '.display // empty')
    others=1
    if [ -n "$cur_space" ]; then
        others=$(yabai -m query --windows --space "$cur_space" 2>/dev/null | jq --arg app "$app" '[.[] | select(."is-sticky"!=true and ((.app|gsub("\u200e";"")) != $app))] | length')
    fi
    # Stay put only when this app already has that built-in desktop to itself.
    if [ "$cur_disp" = "2" ] && [ "$others" -eq 0 ] && [ "$cur_space" != "14" ] && [ "$cur_space" != "15" ] && [ "$cur_space" != "16" ] && [ "$cur_space" != "17" ]; then
        return 0
    fi
    if [ "$disp" = "2" ]; then
        target=$preferred
    else
        wins=$(yabai -m query --windows 2>/dev/null)
        target=$(yabai -m query --spaces --display 2 2>/dev/null | jq -r --arg app "$app" --argjson wins "$wins" '
            [ .[] | select(."is-native-fullscreen"==false) | .index ] as $spaces
            | [ $spaces[] | select(. != 14 and . != 15 and . != 16 and . != 17) ] as $cands
            | [ $cands[] | select(. as $s |
                [ $wins[]
                  | select(
                      ."is-sticky" != true
                      and .space == $s
                      and ((.app | gsub("\u200e"; "")) != $app)
                    )
                ] | length == 0
              )
            ][0] // $cands[0] // $spaces[0] // empty
        ')
    fi
    [ -n "$target" ] || return 0
    for id in $ids; do
        [ -n "$id" ] || continue
        cur=$(yabai -m query --windows --window "$id" 2>/dev/null | jq -r '.space // empty')
        [ "$cur" = "$target" ] && continue
        yabai -m window "$id" --space "$target" >/dev/null 2>&1 \
            || yabai -m window "$id" --display 2 >/dev/null 2>&1 \
            || true
    done
}
place_on_builtin "Zalo" 11
place_on_builtin "Telegram" 12

"$HOME/.config/yabai/arrange-displays.sh"
