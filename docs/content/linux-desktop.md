---
title: "Linux desktop (Sway / Ghostty)"
---

Wayland tiling setup that mirrors macOS **yabai + skhd + Karabiner + Ghostty**.

Sway is i3 on Wayland. Caps is Hyper (`xkb_options caps:hyper`), matching Karabiner's Caps → `cmd+ctrl+opt+shift`. App launchers stay on **meh** (`ctrl+alt+shift`).

## Install

```bash
cd ~/.dotfiles
make linux-desktop
```

That script:

1. Installs **Ghostty** (AppImage → `~/.local/bin/ghostty`) and **JetBrainsMono Nerd Font** with no sudo.
2. `apt install`s Sway, waybar, wofi, mako, grim/slurp when passwordless sudo works.
3. Otherwise extracts the same debs into `~/.local/opt/wm` and wraps them with `start-sway`.
4. Stows `sway` `waybar` `wofi` `mako` `ghostty`.
5. On GNOME, applies interim workspace keybinds so Alt/Hyper work before you switch sessions.

Full system packages (type the sudo password):

```bash
sudo apt install sway swaybg swayidle swaylock waybar wofi mako-notifier grim slurp wl-clipboard jq python3-i3ipc fonts-font-awesome xwayland
sudo cp ~/.local/share/wayland-sessions/sway.desktop /usr/share/wayland-sessions/sway.desktop
```

Then log out of GNOME and pick **Sway** at GDM. From a TTY: `start-sway`. Nested smoke test inside GNOME:

```bash
WLR_BACKENDS=wayland start-sway
```

This host (dpl) uses **nouveau** on an RTX 2070. Sway 1.7 is fine on nouveau. If you later install the proprietary NVIDIA driver, add to `~/.config/sway/config` or the environment:

```bash
export WLR_NO_HARDWARE_CURSORS=1
```

## Keybind map (skhd → sway)

| macOS (skhd) | Linux (sway) | Action |
|---|---|---|
| meh-a | Ctrl+Alt+Shift+a | Ghostty focus/launch |
| meh-f | Ctrl+Alt+Shift+f | kitty |
| meh-s / d / z | Ctrl+Alt+Shift+s/d/z | Firefox (Dia/Arc/Zen stand-in) |
| meh-g | Ctrl+Alt+Shift+g | Cursor / code |
| Super+Space | Super+Space | wofi launcher (Raycast-ish) |
| ctrl+shift h/j/k/l | Ctrl+Shift+h/j/k/l | focus |
| cmd+shift h/l | Super+Shift+h/l | warp/move |
| hyper + h/j/k/l or arrows | Caps+h/j/k/l or Caps+arrows | resize |
| hyper+space | Caps+space | toggle float |
| hyper-f | Caps+f | fullscreen |
| alt-1..9 | Alt+1..9 | focus workspace |
| hyper-1..9 | Caps+1..9 | send to workspace |
| cmd+ctrl n/p | Super+Ctrl+n/p | send + follow |
| cmd+ctrl ←/→ | Super+Ctrl+arrows | send to output + follow |
| hyper-e | Caps+e | balance |
| ctrl+alt+cmd-r | Ctrl+Alt+Super+r | reload sway |
| cmd+s then v/m/h/j/k/l | Super+s then v/m/h/j/k/l | Ghostty splits (same as macOS) |

meh = `ctrl+alt+shift`. hyper = Caps (Mod3) or the physical four-mod chord.

## Caps tap = Escape

xkb cannot do tap-hold. Optional **kanata** config is stowed at `~/.config/kanata/kanata.kbd` and needs `/dev/uinput`:

```bash
sudo usermod -aG input "$USER"
echo 'KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-uinput.rules
# cargo install kanata  (or sudo apt if packaged)
kanata --cfg ~/.config/kanata/kanata.kbd
```

## Files

- `dotfiles/sway/.config/sway/config`
- `dotfiles/waybar/.config/waybar/`
- `dotfiles/wofi/.config/wofi/`
- `dotfiles/mako/.config/mako/config`
- `dotfiles/ghostty/.config/ghostty/config` (Linux Super aliases)
- `scripts/linux-desktop.sh`
- `scripts/linux-gnome-keys.sh`
