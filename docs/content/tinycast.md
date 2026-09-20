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
| `cmd+opt+S` | Processes (`btop`) |
| `cmd+opt+U` | Disk (`dua i`) |
| `cmd+opt+N` | Vault notes (`nvim`) |

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

`cmd+opt+S` opens `btop`. `cmd+opt+U` opens `dua i` on `$HOME` (not `cmd+opt+D`, which is macOS Dock hide). Both keep running in tmux after you close the window, so graphs and the disk tree stay warm. A second press focuses the same window.

`cmd+opt+N` opens the Obsidian vault in Neovim (`$OBSIDIAN_VAULT` or `$HOME/git/personal/vault`). Same persist-in-tmux behavior. `cmd+shift+N` stays Tinycast's own notes.

```bash
sysmon processes
sysmon disk
sysmon stop
notes-vault
notes-vault stop
```

Needs `btop`, `dua-cli`, `tmux`, and `kitty` from `scripts/macos-deps.sh`. Palette search also finds `processes`, `disk`, and `vault`.
