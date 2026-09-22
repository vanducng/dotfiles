---
title: Tinycast
---

Tinycast is the launcher. It has no text config; `scripts/tinycast-setup.sh` is the source of truth for hotkeys, Quick Action prompts, and Custom Commands.

```bash
make stow-bin
./scripts/macos-deps.sh
make setup-tinycast
```

`setup-tinycast` quits Tinycast, writes `com.tinycast.app` UserDefaults, then relaunches it. Re-run after a rebuild. It refuses to steal `cmd+space` if Spotlight still owns that shortcut.

## Shortcuts

| Chord | Action |
|---|---|
| `cmd+space` | Palette |
| `cmd+shift+V` | Clipboard history |
| `cmd+shift+N` | Notes |
| `cmd+shift+R` | Rewrite selected text |
| `cmd+shift+T` | Summarize selected text |
| `cmd+opt+A` | Switch audio output (skips the full login zsh) |
| `meh+f` | Sysmon overlay, centered (last window; first start is `btop`) |
| `cmd+opt+G` | Overlay docked on the right (~1/4) |
| `cmd+opt+V` | Overlay docked on the left (~1/4) |

Move Alter off `cmd+shift+R` (use `cmd+shift+D`) or rewrite loses the race on launch.

## Audio

Custom Commands, not Quick Actions. The picker lists devices that are available right now.

| Command | What it does |
|---|---|
| Switch Audio | Native list of live outputs plus paired Bluetooth audio (AirPods, Jabra, and the rest). Picking an offline headset connects it, then switches. A second `cmd+opt+A` focuses the open list instead of stacking another window. |
| Audio: Mac Speakers | Built-in speakers and mic |
| Audio: Disconnect | Connected Bluetooth device to drop |

Palette search also finds `audio`, `speakers`, and `disconnect`.

The CLI is `~/.local/bin/audio-switch` (stowed from `dotfiles/bin`). Commands live in `scripts/tinycast/custom-commands.json` and are merged by setup without deleting other Custom Commands you add in the UI.

```bash
audio-switch list
audio-switch status
audio-switch set air
audio-switch hide kuycon "microsoft teams" "jump desktop"
audio-switch hidden
audio-switch unhide kuycon
```

The picker hides display and virtual devices (Kuycon, Microsoft Teams, Jump Desktop) by default. `hide` / `unhide` edit `~/.config/audio-switch/hidden` (substring match). Those devices stay installed; they are only omitted from the list.

Needs `switchaudio-osx` and `blueutil` from `scripts/macos-deps.sh`. Switching output does not disconnect Bluetooth; use Audio: Disconnect for that.

## System monitor

`meh+f` raises one kitty overlay attached to the `sysmon` tmux session, centered, and leaves whatever window you last used. Close it with `cmd+w`. `cmd+opt+G` docks the same overlay on the right at one quarter width. `cmd+opt+V` docks it on the left at that same width. The overlay floats above the app underneath, including Dia and Ghostty. Those dock chords are a Tinycast Custom Command plus a Karabiner HID rule, not skhd: `cmd+opt+F` stays with Cursor Replace in Files. First start creates `btop` as window 1 and a `herdr` window attached to the default Herdr session. Vault Neovim starts through a login zsh so AstroNvim gets the same PATH as Ghostty. Palette search still finds `processes`, `disk`, `vault`, `dock`, and `dock left`. The session loads `~/.tmux.conf`.

```bash
sysmon
sysmon dock
sysmon dock-left
sysmon processes
sysmon disk
sysmon vault
sysmon stop
```

Needs `btop`, `dua-cli`, `tmux`, and `kitty` from `scripts/macos-deps.sh`.
