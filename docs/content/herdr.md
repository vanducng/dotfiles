---
title: "Herdr"
---

Herdr is the terminal workspace manager for coding agents. It is unrelated to Laravel Herd.

## Source of truth

The repository owns both parts of the setup:

- `dotfiles/herdr/.config/herdr/config.toml` - theme, notifications, terminal behavior, and keys
- `dotfiles/mise/.config/mise/config.toml` - Herdr binary installation and updates

Stow links the config to `~/.config/herdr/config.toml`. Logs and session state in that directory remain local and are not committed.

## Install

Install the prerequisites first.

macOS:

```bash
brew install git stow mise fzf jq ripgrep node
```

Debian or Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y git stow fzf jq ripgrep nodejs npm xdg-utils wl-clipboard xclip
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
```

Other Linux distributions can use the matching method in the [mise installation guide](https://mise.jdx.dev/installing-mise.html) and their package manager's GNU Stow package. Linux path copying needs one of `wl-copy`, `xclip`, or `xsel`, and URL opening needs `xdg-open`.

The `C-x Space` file-opening action also expects the `vd:file-browser` skill at `$HOME/skills/skills/file-browser`. Without it, the picker can still copy paths and open external URLs, but it cannot render local files in the browser.

Then clone the repository and run:

```bash
make stow-install
mise install
mise exec -- herdr --version
mise exec -- herdr
```

The mise GitHub backend is used because it works on macOS and Linux, including mise versions that do not yet expose the short `herdr` registry name.

If `~/.config/herdr/config.toml` already exists as a regular file, preserve it before Stow takes ownership:

```bash
mv ~/.config/herdr/config.toml ~/.config/herdr/config.toml.pre-dotfiles
make stow-herdr
```

## Tmux-style keys

Herdr uses the same `C-x` prefix as this repository's tmux setup. Prefix chords always work. Direct `Ctrl` / `Ctrl-Alt` chords are extras for Ghostty and Kitty.

More modifiers means a bigger jump: panes, then tabs, then workspaces, then machines.

| Key | Action |
|---|---|
| `C-x h/j/k/l` | Focus pane |
| `Ctrl-Alt-h/j/k/l` | Focus pane (direct) |
| `C-x Tab` | Next pane |
| `C-x a` | Last pane |
| `C-x z` | Zoom pane |
| `C-x m` | Split right, side by side |
| `C-x v` | Split down, stacked |
| `C-x ,` | Name pane from its active task context |
| `C-x 0` | Home: first workspace, first tab, first pane |
| `C-x 1..9` | Switch tab |
| `Ctrl-1..9` | Switch tab (direct) |
| `C-x n` / `C-x p` | Next / previous tab |
| `C-x c` | New tab |
| `C-x Shift-T` | Rename tab |
| `C-x Shift-1..9` | Switch workspace |
| `Ctrl-Alt-1..9` | Switch workspace (direct) |
| `C-x Shift-Left/Right` | Previous / next workspace |
| `C-x w` | Workspace picker |
| `C-x s` | Switch named Herdr session |
| `C-x Shift-S` | Settings |
| `C-x g` / `C-x Shift-M` | Jump to a machine, workspace, tab, or pane |
| `C-x Shift-Up/Down` | Previous / next agent |
| `C-x Alt-1..9` | Focus agent 1-9 |
| `C-x f` | Find an agent by `workspace.tab.pane` address |
| `C-x Space` | Pick a recent path or URL |
| `C-x [` | Copy mode |
| `C-x Shift-G` | Open the current branch's pull request, or the repository's pull request list |
| `C-x Shift-I` | Renumber visible tab labels from 1 in each workspace |
| `C-x r` | Resize mode |
| `C-x R` | Reload config |
| `C-x ?` | Active key help |

Herdr keeps tab IDs stable after closes, so `C-x Shift-I` renumbers the visible label prefixes without changing IDs such as `wR:t5`.

Herdr 0.9.0 has no machine key. `C-x 0` is home on the machine you are viewing: workspace 1, tab 1, first pane (the Local orchestrator when you are on Local). From another machine, `C-x g` then `Home` then `Enter` selects Local; the first navigator row is Local. `C-x Shift-Left/Right` also walks workspaces across machines. `C-x w` stays the portable workspace jump when numbered workspace chords do not reach Herdr.

`Ctrl-Alt-1..9` is the direct workspace jump on macOS Ghostty. Kitty on macOS defaults Option+digit to unicode (¡™£), so the same chord never reaches Herdr during `herdr --remote` even though `Ctrl-Alt-hjkl` and `Ctrl-1..9` work. `kitty.conf` sets `macos_option_as_alt yes` and maps `ctrl+alt+1..9` to kitty CSI-u; restart Kitty after that change. Moshi/mosh still lack that protocol, so use `C-x 1..9` for tabs and `C-x w` for workspaces there. Ghostty unbinds `shift+arrows` so `C-x Shift-Left/Right` can reach Herdr instead of adjusting a terminal selection.

The picker scans the latest 500 rows of the focused pane and lists matching paths and URLs newest-first. Press `Enter` to open in the file browser, `Ctrl-Y` to copy, or `Ctrl-E` to open in the editor. External URLs open in the default browser, existing localhost viewer URLs restart the file browser when needed, and relative paths resolve from the pane's working directory. Exiting the temporary picker returns to the original pane.

`C-x ,` names the pane `<repo>:<task>` from the pane's branch, latest commit, changed files, terminal title, and recent output using the same agent CLI the pane runs - `codex exec` for Codex panes, `claude -p` (Haiku) otherwise - so it reuses the CLI's existing subscription login and needs no API key. The repository name comes from the pane's Git remote, while the model supplies only a specific task label. Common secret-like values and key blocks are redacted before context is sent, but the filter is best-effort; do not use the action while secrets are visible in the pane. Labels may use up to 80 characters and keep the repository name stable. If the preferred CLI is missing or fails it tries the other, then falls back to `<repo>:<branch>` from the pane's Git context, or the folder name outside Git. It runs only when pressed and needs no background service.

Use `C-x f` when the target is an agent. Each row starts with a stable address such as `1.2.30`, meaning workspace 1, tab 2, pane 30. Use `C-x g` for machines and for the native searchable tree when the target may be a shell pane. `C-x Shift-Up/Down` remains the fastest way to cycle agents without choosing a specific address.

`C-x s` lists named Herdr sessions (separate servers) and attaches to one. Type a new name and press Enter to create it. From a normal shell it attaches in this terminal. From inside Herdr it opens a new Ghostty or Kitty window, because one client cannot swap servers. `C-x g` still jumps within the current session. Workspaces remain the everyday project switch; use named sessions when you want isolated sockets and runtime state.

## Reload and update

Reload most config changes without stopping panes:

```bash
herdr server reload-config
```

Inspect both client and server before updating the mise-managed binary:

```bash
herdr status
mise upgrade github:ogulcancelik/herdr
```

An updated client can remain attached only when the old server uses a compatible protocol. The 0.7.0 to 0.7.4 update changes protocol 14 to 16, so defer that switch until the old server's pane processes can safely exit:

```bash
mise exec -- herdr --version
herdr server stop
if [ -x "$HOME/.local/bin/herdr" ]; then
  mv "$HOME/.local/bin/herdr" "$HOME/.local/bin/herdr.pre-mise"
fi
mise exec -- herdr
```

After that session exits, start a fresh Zsh and confirm `herdr --version` resolves the mise-managed release.

## Diagnostics

```bash
herdr --version
herdr status
tail -f ~/.config/herdr/herdr-server.log
```

Herdr falls back to safe defaults and reports a startup warning when a config value is invalid. The in-app help at `C-x ?` shows the bindings actually loaded by the running session.

## References

- [Herdr configuration](https://herdr.dev/docs/configuration/)
- [Herdr keyboard guide](https://herdr.dev/docs/keyboard/)
- [Herdr installation](https://herdr.dev/docs/install/)
