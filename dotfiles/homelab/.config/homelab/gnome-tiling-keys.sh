#!/usr/bin/env bash
# GNOME + Pop Shell keybindings mirroring the macOS yabai/skhd setup.
# Mac keys arrive over Jump as: cmd -> Super, meh = ctrl+alt+shift, hyper = cmd+ctrl+alt+shift.
# Re-runnable. Takes effect on the next login (new extensions only load at login on Wayland).
set -euo pipefail

EXT="${XDG_DATA_HOME:-$HOME/.local/share}/gnome-shell/extensions"
# Skip settings for an extension that is not installed yet (install-desktop-tiling adds it).
ext() { [[ -d "$EXT/$1/schemas" ]] || return 0; gsettings --schemadir "$EXT/$1/schemas" set "$2" "${@:3}"; }
pop() { ext pop-shell@system76.com org.gnome.shell.extensions.pop-shell "$@"; }
wm() { gsettings set org.gnome.desktop.wm.keybindings "$@"; }

HYPER='<Primary><Alt><Shift><Super>'

# --- Pop Shell: tiling behaviour (yabai: layout bsp, padding/gap 5). Pop gaps are units of 4px. ---
pop tile-by-default true
pop gap-inner 'uint32 1'
pop gap-outer 'uint32 1'
pop smart-gaps false
pop show-title true
pop active-hint true
pop hint-color-rgba 'rgba(212, 164, 255, 1)'
pop mouse-cursor-follows-active-window false

# --- Focus: ctrl+shift+hjkl (skhd) + super+arrows ---
pop focus-left  "['<Primary><Shift>h', '<Super>Left']"
pop focus-down  "['<Primary><Shift>j', '<Super>Down']"
pop focus-up    "['<Primary><Shift>k', '<Super>Up']"
pop focus-right "['<Primary><Shift>l', '<Super>Right']"

# GNOME binds super+arrows to half-tiling and maximize; Pop Shell owns them here.
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "@as []"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "@as []"
wm maximize "@as []"
wm unmaximize "['<Alt>F5']"

# --- Move/warp window: cmd+shift+hjkl (skhd: cmd+shift-h/l --warp) ---
pop tile-move-left-global  "['<Super><Shift>h']"
pop tile-move-down-global  "['<Super><Shift>j']"
pop tile-move-up-global    "['<Super><Shift>k']"
pop tile-move-right-global "['<Super><Shift>l']"
# Pop's defaults put monitor/workspace moves on super+shift+hjkl; move them to cmd+ctrl (skhd display moves).
pop pop-monitor-left  "['<Super><Primary>Left']"
pop pop-monitor-right "['<Super><Primary>Right', '<Super><Primary>bracketright']"
pop pop-monitor-up    "@as []"
pop pop-monitor-down  "@as []"
pop pop-workspace-up   "['<Super><Primary>p']"
pop pop-workspace-down "['<Super><Primary>n']"

# --- Window state: hyper layer ---
pop toggle-floating "['${HYPER}space', '<Hyper>space', '<Super>g']"
pop tile-orientation "['${HYPER}r', '<Hyper>r', '<Super>o']"
pop toggle-tiling "['<Super>y']"
# Resize has no global binding in Pop Shell: super+return enters adjust mode, then shift+hjkl resizes, enter accepts.
pop tile-enter "['<Super>Return', '${HYPER}Return']"
wm toggle-maximized "['<Super>m', '${HYPER}f', '<Hyper>f']"

# --- App search: cmd+tab opens GNOME's overview search (type to find apps); alt+tab still switches apps ---
# (Pop's own launcher needs the separate pop-launcher backend, which is not installed.)
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>Tab']"
pop activate-launcher "@as []"
wm switch-applications "['<Alt>Tab']"
wm switch-applications-backward "['<Shift><Alt>Tab']"

# --- Workspaces: alt+1..9 switch, hyper+1..9 send window there (GNOME follows the window) ---
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 9
for i in $(seq 1 9); do
  wm "switch-to-workspace-$i" "['<Alt>$i']"
  wm "move-to-workspace-$i" "['<Hyper>$i', '${HYPER}$i']"
  # GNOME's default super+N launches dock apps; free it so nothing fights the workspace keys.
  gsettings set org.gnome.shell.keybindings "switch-to-application-$i" "@as []"
done
wm switch-to-workspace-last "['<Hyper>Tab', '${HYPER}Tab']"

# --- Lean panel: no dock or desktop icons; workspaces left, clock centre, stats right ---
SB=org.gnome.shell.extensions.space-bar
ext space-bar@luchrioh "$SB.behavior" position 'left'
ext space-bar@luchrioh "$SB.behavior" position-index 0
ext space-bar@luchrioh "$SB.behavior" show-empty-workspaces false
ext space-bar@luchrioh "$SB.behavior" smart-workspace-names false
ext space-bar@luchrioh "$SB.behavior" enable-custom-label true
ext space-bar@luchrioh "$SB.behavior" custom-label-unnamed '{{number}}'
ext space-bar@luchrioh "$SB.behavior" toggle-overview false
ext space-bar@luchrioh "$SB.appearance" active-workspace-background-color 'rgba(212, 164, 255, 0.35)'
VT=org.gnome.shell.extensions.vitals
ext Vitals@CoreCoding.com "$VT" hot-sensors "['_processor_usage_', '_memory_usage_', '__network-rx_max__', '__network-tx_max__']"
ext Vitals@CoreCoding.com "$VT" include-public-ip false
ext Vitals@CoreCoding.com "$VT" position-in-panel 2
# Running apps of this workspace after the numbers, then the focused app's name.
AZ=org.gnome.shell.extensions.aztaskbar
ext aztaskbar@aztaskbar.gitlab.com "$AZ" favorites false
ext aztaskbar@aztaskbar.gitlab.com "$AZ" isolate-workspaces true
ext aztaskbar@aztaskbar.gitlab.com "$AZ" show-panel-activities-button false
ext aztaskbar@aztaskbar.gitlab.com "$AZ" icon-size 18
ext aztaskbar@aztaskbar.gitlab.com "$AZ" main-panel-height '(true, 32)'
ext aztaskbar@aztaskbar.gitlab.com "$AZ" position-offset 1
ext aztaskbar@aztaskbar.gitlab.com "$AZ" indicator-color-focused 'rgb(212, 164, 255)'
WT=org.gnome.shell.extensions.window-title-is-back
ext window-title-is-back@fthx "$WT" show-icon false
ext window-title-is-back@fthx "$WT" show-title false
# Each app opens on its own workspace (Mac: yabai space rules). The wall Chrome parks on 9.
ext auto-move-windows@gnome-shell-extensions.gcampax.github.com org.gnome.shell.extensions.auto-move-windows \
  application-list "['ghostty.desktop:1', 'google-chrome.desktop:2', 'browserclaw.desktop:3', 'grok-bot.desktop:4', 'chrome-wall.desktop:9']"
JP=org.gnome.shell.extensions.just-perfection
for k in activities-button dash workspace-popup weather world-clock events-button accessibility-menu keyboard-layout; do
  ext just-perfection-desktop@just-perfection "$JP" "$k" false
done
ext just-perfection-desktop@just-perfection "$JP" startup-status 0
ext just-perfection-desktop@just-perfection "$JP" window-demands-attention-focus true

# --- Floating windows open centred; the meh+f sysmon kitty always floats (Mac: yabai grid overlay) ---
gsettings set org.gnome.mutter center-new-windows true
python3 - <<'PY'
import json, os
p = os.path.expanduser("~/.config/pop-shell/config.json")
try:
    with open(p) as f:
        c = json.load(f)
except (OSError, ValueError):
    c = {"skiptaskbarhidden": [], "log_on_focus": False}
rules = c.setdefault("float", [])
if {"class": "sysmon"} not in rules:
    rules.append({"class": "sysmon"})
os.makedirs(os.path.dirname(p), exist_ok=True)
with open(p, "w") as f:
    json.dump(c, f, indent=2)
    f.write("\n")
PY

# --- Extensions: tiling, app keys and panel on; dock, desktop icons and tiling-assistant off ---
python3 - <<'PY'
import ast, subprocess
get = lambda k: ast.literal_eval(subprocess.check_output(["gsettings", "get", "org.gnome.shell", k], text=True).replace("@as ", ""))
on, off = get("enabled-extensions"), get("disabled-extensions")
want_on = ["pop-shell@system76.com", "run-or-raise@edvard.cz", "space-bar@luchrioh",
           "Vitals@CoreCoding.com", "just-perfection-desktop@just-perfection",
           "aztaskbar@aztaskbar.gitlab.com", "window-title-is-back@fthx",
           "auto-move-windows@gnome-shell-extensions.gcampax.github.com"]
want_off = ["tiling-assistant@ubuntu.com", "ubuntu-dock@ubuntu.com", "ding@rastersoft.com"]
on = [e for e in on if e not in want_off] + [e for e in want_on if e not in on]
off = [e for e in off if e not in want_on] + [e for e in want_off if e not in off]
subprocess.check_call(["gsettings", "set", "org.gnome.shell", "enabled-extensions", str(on)])
subprocess.check_call(["gsettings", "set", "org.gnome.shell", "disabled-extensions", str(off)])
print("enabled:", on)
PY
echo "keybindings applied"
