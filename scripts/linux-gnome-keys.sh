#!/usr/bin/env bash
# GNOME Wayland interim keybinds matching skhd, until Sway is the session.
# No sudo. Safe to re-run. Caps → Hyper via xkb (tap-escape needs kanata).
set -euo pipefail

have() { command -v "$1" >/dev/null 2>&1; }
have gsettings || { echo "linux-gnome-keys: gsettings not found" >&2; exit 1; }

gset() {
  if gsettings set "$1" "$2" "$3" 2>/dev/null; then
    return 0
  fi
  echo "linux-gnome-keys: skip $1 $2" >&2
}

# Caps hold = Hyper_L (Mod3), same role as Karabiner Hyper.
gset org.gnome.desktop.input-sources xkb-options "['caps:hyper']"

# Static 9 workspaces like skhd alt-1..9 (plus a 10th spare).
gset org.gnome.mutter dynamic-workspaces false
gset org.gnome.desktop.wm.preferences num-workspaces 10

# Super+1..9 launches dock apps on Ubuntu; clear so Alt/Hyper can own the numbers.
for i in 1 2 3 4 5 6 7 8 9; do
  gset org.gnome.shell.keybindings "switch-to-application-${i}" "[]"
done

for i in 1 2 3 4 5 6 7 8 9; do
  gset org.gnome.desktop.wm.keybindings "switch-to-workspace-${i}" "['<Alt>${i}']"
  # Hyper+N sends the window (skhd hyper - N). Also the physical 4-mod combo.
  gset org.gnome.desktop.wm.keybindings "move-to-workspace-${i}" \
    "['<Hyper>${i}', '<Primary><Alt><Shift><Super>${i}']"
done

gset org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Primary><Super>p']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Primary><Super>n']"
gset org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Hyper>f']"
gset org.gnome.desktop.wm.keybindings toggle-maximized "['<Hyper>n']"
gset org.gnome.desktop.wm.keybindings toggle-floating "['<Hyper>space']" 2>/dev/null || true

# App launcher (Raycast-ish): Super+space already opens GNOME overview on Ubuntu.
# Leave overview on Super; meh is not bindable as a single modifier in gsettings.

echo "linux-gnome-keys: Caps=Hyper, Alt+1..9 workspaces, Hyper+1..9 move window"
echo "linux-gnome-keys: log out of GNOME or pick Sway at GDM for full tiling"
