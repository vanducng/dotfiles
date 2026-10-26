---
title: "Rex"
---

Rex (Rex Beta) is the native macOS multiplexer that replaces Ghostty on space 1 (`meh + a`). Rex runs its sessions on a server, so the Mac app can attach to sessions on other machines over Tailscale.

## Source of truth

- `dotfiles/rex/.config/rex/init.lua` - key bindings and the resize mode
- `dotfiles/rex/.config/rex/actions.lua` - Lua actions: `session_goto`, `session_toggle`, `host_goto`, `tab_cycle`, `session_renumber`, `session_layout`, `layout_goto`, `tab_renumber`, `tab_goto`, `home`, `fingers`, `agent_next`, `agent_pick`, `agent_attention` (the old in-Lua scan, kept until `rexboard next` is proven live), `copy_mode`, `pane_label`, `open_pr`
- `dotfiles/rex/.config/rex/layout.lua` - the sessions kept at the top of this Mac's sidebar (see [Session layout](#session-layout))
- `dotfiles/rex/.config/rex/hosts.json` - every machine that runs Rex, defined once: `label`, `device`, macOS `hostname`, and the app `icon`. Its order is the `Ctrl-Alt-1..9` number
- `dotfiles/rex/.config/rex/hosts.lua` - reads `hosts.json`, works out which entry is this Mac, and declares the others as Rex hosts
- `dotfiles/rexboard/.config/rexboard/config.toml` - [rexboard](https://github.com/vanducng/rexboard)'s config. The app client is left to the default, the only Rex app on the unix socket. The rexboard keys and the cockpit's board tab find `rexboard` in `$HOMEBREW_PREFIX/bin`, `/opt/homebrew/bin`, `/usr/local/bin`, `~/.local/bin`, then `PATH`, and say `brew install vanducng/tap/rexboard` when it is missing
- `dotfiles/rex/.config/rex/copy-mode.nvim.lua` - the small Neovim config copy mode starts with (`nvim -u`), so it opens in tens of milliseconds instead of loading the full Neovim setup
- `scripts/rex-setup.sh` (`make setup-rex`) - app settings that live in UserDefaults: Option as Alt, vertical tabs, compact panes, Program Activity sounds (an agent finished or is waiting on you), the Tailscale node name, and the app's Remote Hosts list. The app reads them at launch, so quit and reopen Rex Beta after a run; sessions live in the server and survive

Rex reads the config when it starts. After an edit, run `rex config reload` or press `C-x Shift-R`. Run `rex config check` first to catch mistakes, and `rex keymap` to see what loaded.

## Prefix keys

Rex uses Herdr's `C-x` prefix and letters, so moving between the two needs no relearning. Prefix keys use physical key codes, so they work with a Vietnamese input source too. Press `C-x C-x` to send `C-x` to the terminal, for example to a Herdr session over ssh. Holding ctrl through the second key does the same as the plain letter (`C-x C-z` zooms), so a held ctrl never sends `ctrl+z` to the shell and suspends it.

| Key | Action |
|---|---|
| `C-x Shift-H/J/K/L` | Move pane |
| `C-x Tab` / `C-x Shift-Tab` | Next / previous pane |
| `C-x z` | Zoom pane |
| `C-x m` / `C-x v` | Split right / down |
| `C-x x` | Close pane |
| `C-x e` | Balance splits |
| `C-x r` | Resize mode: `h/j/k/l` or arrows, `Shift` for bigger steps, `=` balance, `Esc` or `Enter` to leave |
| `C-x ,` / `C-x Shift-P` | Label the pane `repo:branch`, or the folder name outside git |
| `C-x Space` | Pick a URL or file path from the pane's latest 500 lines, newest first: `Enter` opens, `Ctrl-Y` copies, `Ctrl-E` edits (Herdr's `herdr-fingers`) |
| `C-x [` | Copy mode: the screen and scrollback in Neovim over the pane, with wrapped lines joined. `v` to select, `y` copies to the clipboard, `q` or `Ctrl-C` closes and returns to the pane, zoomed if it was (over a zoomed pane the popup fills the window, since Rex unzooms when focus leaves the pane). The popup covers just the pane only when the pane is in the window's top-left corner, and fills the window otherwise: Rex Beta 1408 draws a popup's `[x, y, w, h]` as left, top, right, bottom, so any other placement comes out empty. The `C-x Space` picker fills the window for the same reason. A full-screen app (Claude Code, nvim, less) has no scrollback, so only its visible screen shows, and a bar at the top says so |
| `C-x c` | New tab |
| `C-x 1..9` | Go to tab N in this session (`9` is the last tab) |
| `C-x Shift-T` | Rename tab |
| `C-x Shift-X` | Close tab |
| `C-x a` | Back to the last session; press again to return. It remembers jumps made with `Ctrl-1..9`, `Alt-Shift-1..5`, `C-x 0` and `C-x a`, not `Cmd-k` or sidebar clicks, and a config reload forgets it |
| `C-x Shift-Right` | Next session (the session picker is `Cmd-k`) |
| `C-x 0` | Home: first session, first tab, first pane |
| `C-x Shift-N` | New session |
| `C-x Shift-S` | Rename session |
| `C-x Shift-W` | Open the session on the web |
| `C-x Shift-I` | Put the layout's sessions first on this Mac, then number every session's label with its `Ctrl-1..9` number (`4-api`), on this Mac and the remote hosts. A remote host keeps its order. A stacked prefix (`2-3-api`) is replaced whole, and a second run changes nothing. Rerun after adding, closing, or renaming one |
| `C-x i` | Number every tab's label with its `Cmd-1..9` number (`2-api`) in each session on the Mac you are viewing, replacing a stacked prefix whole; a tab without a name of its own takes its pane's folder |
| `C-x Shift-D` | Close session |
| `C-x Shift-M` | Switch machine (host) |
| `C-x Shift-Down` / `C-x o` | Next agent that needs you, across every host (`rexboard next`) |
| `C-x Shift-Up` | Previous agent that needs you (`rexboard next --back`) |
| `C-x f` | Pick an agent from a list over the window (`rexboard pick`): `Enter` jumps, `Esc` returns to the pane, and a failed jump's reason stays up until `Enter`. Over a pane on another host it goes to the board in `1-cockpit` instead |
| `C-x b` | Toggle sidebar (vertical tabs only; `shift+cmd+s` switches tab style) |
| `C-x Shift-R` | Reload config |
| `C-x Shift-G` | Open the repo's pull requests on GitHub (`/pulls`) |
| `C-x ?` | Command palette |

Herdr's `C-x a` (last pane) has no equivalent, since Rex config Lua cannot track focus history, so `C-x a` toggles to the last session here.

## Direct keys

| Key | Action |
|---|---|
| `Ctrl-Alt-h/j/k/l` | Focus pane (also `Cmd-Alt-arrows`) |
| `Alt-Shift-arrows` | Move pane (also `C-x Shift-H/J/K/L`) |
| `Ctrl-Alt-z` | Zoom pane (also `Shift-Cmd-Enter`) |
| `Cmd-]` / `Cmd-[` | Next / previous pane |
| `Cmd-d` / `Shift-Cmd-d` | Split right / down |
| `Cmd-w` | Close pane, else tab, else window |
| `Alt-Cmd-w` | Close tab |
| `Cmd-1..9` | Go to tab N in this session (`Cmd-9` is the last tab). Rex's default counts the tabs of every session in the sidebar |
| `Cmd-t` | New tab |
| `Shift-Cmd-]` / `Shift-Cmd-[` | Next / previous tab |
| `Ctrl-Alt-.` / `Ctrl-Alt-,` | Next / previous tab in sidebar order across every session and host, wrapping at the end |
| `Shift-Cmd-Up` / `Shift-Cmd-Down` (also `Left` / `Right`) | Move tab up / down. Replaces Rex's `Ctrl-Shift-Up/Down`, which never reached the app, and its `Shift-Cmd-arrow` splits (`C-x m` / `C-x v` split) |
| `Ctrl-1..9` | Go to session N on the host you are viewing |
| `Alt-Shift-1` | The board: `1-cockpit` tab 1 (replaces `C-x Shift-O`). Made first if missing |
| `Alt-Shift-2` | `rig tui`: `1-cockpit` tab 2. Made first if missing |
| `Alt-Shift-3` | `foreman`: `1-cockpit` tab 3, `claude` in `~/projects`. Made first if missing |
| `Alt-Shift-4` / `Alt-Shift-5` | `2-cnb` / `3-abs`. Made first if missing, or says its folder does not exist |
| `Ctrl-v` | On a pane on another host, sends the clipboard image there over ssh as `/tmp/rex-images/<time>.png` and pastes the path, so Claude Code there attaches it (Herdr's `remote_image_paste`). On a local pane, or with no image on the clipboard, it is a plain `Ctrl-v`. Needs `pngpaste` and key-based ssh to the host's alias |
| `Ctrl-Alt-1..9` | Go to host N: 1 MacBook Pro (`mbp-01`), 2 `mini-01`, 3 kept for `linux-01`; lands on the session you last had there, else its first |
| `Alt-Cmd-]` | Next session |
| `Cmd-k` | Session picker |
| `Shift-Cmd-k` | Switch machine (host) |
| `Ctrl-Alt-a` | Next agent that needs you (`rexboard next`) |
| `Cmd-b` | Toggle sidebar (also `Cmd-/`) |
| `Cmd-.` | Toggle Activity |
| `Alt-Cmd-.` | Dismiss a notice, such as an "Action failed" toast (replaces Rex's `Shift-Cmd-.`) |
| `Shift-Cmd-s` | Toggle vertical / horizontal tabs |
| `Cmd-Up` / `Cmd-Down` | Previous / next shell prompt |
| `Shift-Cmd-p` | Command palette |

Each host numbers its own sessions, so `Ctrl-1..9` stays short however many machines there are: pick the machine with `Ctrl-Alt-1..9`, then the session with `Ctrl-1..9`. The host numbers follow the order of `hosts.json` and are the same on every Mac. `Ctrl-Alt-N` remembers the session you left on each host, per app, until a config reload. To open a session on another Mac, the action asks that host to have your app select it, so keep Remote Control on (Settings, Server, Client Info). `Ctrl-Shift-Tab` never reaches Rex because skhd uses it for yabai stacks, so use `Shift-Cmd-[` for the previous tab.

## Session layout

`layout.lua` keeps three sessions at the top of this Mac's sidebar:

| # | Session | Tabs |
|---|---|---|
| 1 | `1-cockpit` | `rexboard` (the board), `rig` (`rig tui`), `foreman` (`claude` in `~/projects`) |
| 2 | `2-cnb` | `claude` in `~/git/work/cnb` |
| 3 | `3-abs` | `claude` in `~/git/work/ab-spectrum` |

The `session_layout` action makes the missing ones, reopens a layout tab you closed, and moves the three to positions 1-3. It finds them by name without the number, so `cockpit` or `5-cockpit` counts. It skips a session whose folder this Mac lacks, and never kills or restarts a session. Every session's number is its `Ctrl-1..9` position, so with all three present the rest start at 4 (`1-warp-factory-setup` becomes `4-warp-factory-setup`); with one skipped, the rest close the gap. Only the number prefix changes, never the name.

It runs from `make setup-rex` and at login (the `dev.vanducng.rex-session-layout` LaunchAgent in the `launchd` package), which writes failures to `~/Library/Logs/rex-session-layout.log`. No key runs the whole layout: `Alt-Shift-1..5` make or complete only their own session before going to it, or say its folder does not exist. By hand:

```bash
rex do ~/.config/rex/actions.lua --action session_layout dry_run=true   # print the plan, change nothing
rex do ~/.config/rex/actions.lua --action session_layout
```

## Machines

Each Mac's Rex server joins the tailnet as its own device, `rex-<ssh alias>`, through Rex's built-in Tailscale. The system Tailscale node cannot be reused: the Tailscale GUI app has no `tailscaled` socket, and the Rex app starts its server with fixed flags. Tailscale still takes the direct LAN path at home.

On a new Mac, open Rex Beta once, then:

```bash
make stow-rex
make setup-rex   # Option as Alt, Tailscale node rex-<alias>, config reload
rex server status   # first run only: open the Tailscale sign-in link it prints
rex -S mini-01 ls
```

Host labels follow `<kind>-<nn>`: `mbp`, `mini` or `linux`, then a two-digit number, the same as the machine's ssh alias (`mbp-01`, `mini-01`, `linux-01`). Each Mac's Rex server joins Tailscale as `rex-<label>`. `hosts.lua` reads `hosts.json`, finds this Mac's entry by its macOS `LocalHostName` (`scutil --get LocalHostName`), and declares every other entry as a Rex host at `https://rex-<label>.<tailnet domain>`. It reads the tailnet domain from the Tailscale app at load, so the domain stays out of this repository. `rex hosts` lists what it declared. A new machine needs only an entry in `hosts.json`; `rex-setup.sh` reads the same file for this Mac's label and the app icons.

`make release` (`scripts/release.sh`) ships a release to every machine in `hosts.json`. It merges the open release-please PR once GitHub reports it clean, waits for the `release` run to tag it, then pulls `~/dotfiles` here and over ssh on each other machine. Local edits to tracked files survive: an edit to a file upstream also changed is lifted off as a patch and put back after the pull, and if it no longer applies the local file stays as it was and the script names it. When the rex config changed, it runs `rex config check` and then `rex config reload`. With no release pending it only pulls.

The Mac app ignores `hosts.lua` and keeps its own Remote Hosts list in the `RexSync.servers` preference. `rex-setup.sh` adds each missing Mac there with the same address and leaves existing records alone, since the app fills in their IDs on first connect. Quit and reopen Rex Beta after it reports "Remote Hosts updated".

## Agents inside tmux (OpenRig seats)

Rex shows an agent's status (working, waiting on you, done) from OSC 7501, an escape sequence Claude Code and Codex send on their own when they run straight in a Rex pane. An OpenRig seat runs its agent inside tmux, and its Rex tile only runs `tmux attach`, so the sequence stops at tmux and the tile looks like plain tmux.

`~/.local/bin/rex-agent-status` bridges that for Claude Code. Hooks in `~/.claude/settings.json` (session start and end, prompt, each tool, permission request, stop) call it when `$TMUX` or `$REX_BLOCK` is set, or when `$TERM` starts with `tmux` or `screen`. That last case covers a seat whose launcher started Claude without `TMUX` and `TMUX_PANE` (OpenRig's resume does): the script then finds the seat's pane by the agent's tty (`tmux list-panes -a`), and does nothing unless exactly one pane matches. Inside tmux it turns the event into an OSC 7501 status, wraps it in tmux passthrough, and writes it to the seat's pane. tmux (`allow-passthrough on` in `.tmux.conf`) forwards it to the attached Rex tile, which then counts as a `claude-code` agent for the sidebar status and `C-x o`. `set-titles` passes the agent's title (`✳ <task>`) to the tile as well. The last status is also kept on the seat's pane (`@rex_status`), and a tmux hook resends it when a client attaches or switches to the session, so a tile opened later shows it at once. A running seat picks the hooks up at its next start. To see what a hook did, set `REX_AGENT_STATUS_LOG=<file>` in the agent's env: each call appends one line with the event, which of `TMUX`, `TMUX_PANE` and `REX_BLOCK` were set, the pane it found and what it did, never the hook's text.

Inside tmux, Claude Code also spins a glyph at the front of its title (`◐` working, `✳` idle), so a seat's pane header shows its state. Straight in a Rex pane it leaves the glyph out, because Rex already has the status, and the header shows only the task. Outside tmux, the same hooks put it back. Each hook records the status in a file under `$TMPDIR` and starts one background spinner for the pane (`rex-agent-status --spin`). The spinner reads the title with `rex block call title` and writes it back with `◐`/`◑` flipping every 0.96 s while Claude works, `◉` while it waits on you, and no glyph when it is idle. It exits with Claude.

Codex seats need the same hooks in `~/.codex/hooks.json`, but Codex asks you to review new hooks before they run, so they are not wired yet. Running seats natively in Rex instead of tmux is tracked on the OpenRig fork.

## Option key

Rex defaults the Option key to `automatic`, which types special characters (`alt+p` gives `π`). `rex-setup.sh` sets `Workspace.terminalOptionKeyBehavior` to `actsAsAlt`, the same as Ghostty's `macos-option-as-alt = true`. The other values are `composesText`, `leftActsAsAlt`, and `rightActsAsAlt`. Right Option plus a letter still launches apps through Karabiner before Rex sees it.
