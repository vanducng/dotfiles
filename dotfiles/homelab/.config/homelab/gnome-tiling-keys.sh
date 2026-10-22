#!/usr/bin/env bash
# GNOME + Pop Shell keybindings mirroring the macOS yabai/skhd setup.
# Mac keys arrive over Jump as: cmd -> Super, meh = ctrl+alt+shift, hyper = cmd+ctrl+alt+shift.
# Re-runnable. Takes effect on the next login (new extensions only load at login on Wayland).
set -euo pipefail

POP_DIR="$HOME/.local/share/gnome-shell/extensions/pop-shell@system76.com/schemas"
pop() { gsettings --schemadir "$POP_DIR" set org.gnome.shell.extensions.pop-shell "$@"; }
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

# --- Extensions: Pop Shell + Run or Raise on, Ubuntu's tiling-assistant off (it fights Pop Shell) ---
python3 - <<'PY'
import ast, subprocess
get = lambda k: ast.literal_eval(subprocess.check_output(["gsettings", "get", "org.gnome.shell", k], text=True).replace("@as ", ""))
on, off = get("enabled-extensions"), get("disabled-extensions")
want_on = ["pop-shell@system76.com", "run-or-raise@edvard.cz"]
want_off = ["tiling-assistant@ubuntu.com"]
on = [e for e in on if e not in want_off] + [e for e in want_on if e not in on]
off = [e for e in off if e not in want_on] + [e for e in want_off if e not in off]
subprocess.check_call(["gsettings", "set", "org.gnome.shell", "enabled-extensions", str(on)])
subprocess.check_call(["gsettings", "set", "org.gnome.shell", "disabled-extensions", str(off)])
print("enabled:", on)
PY
echo "keybindings applied"
