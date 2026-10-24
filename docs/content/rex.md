---
title: "Rex"
---

Rex (Rex Beta) is the native macOS multiplexer that replaces Ghostty on space 1 (`meh + a`). Rex runs its sessions on a server, so the Mac app can attach to sessions on other machines over Tailscale.

## Source of truth

- `dotfiles/rex/.config/rex/init.lua` - key bindings and the resize mode
- `dotfiles/rex/.config/rex/actions.lua` - Lua actions: `session_goto`, `session_toggle`, `session_renumber`, `tab_renumber`, `tab_goto`, `home`, `fingers`, `agent_attention`, `copy_mode`, `pane_label`, `open_pr`
- `dotfiles/rex/.config/rex/hosts.json` - every machine that runs Rex, defined once: `label`, `device`, macOS `hostname`, and the app `icon`. Its order is the `Ctrl-Alt-1..9` number
- `dotfiles/rex/.config/rex/hosts.lua` - reads `hosts.json`, works out which entry is this Mac, and declares the others as Rex hosts
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
| `C-x a` | Back to the last session; press again to return. It remembers jumps made with `Ctrl-1..9`, `C-x 0` and `C-x a`, not `Cmd-k` or sidebar clicks, and a config reload forgets it |
| `C-x Shift-Right` | Next session (the session picker is `Cmd-k`) |
| `C-x 0` | Home: first session, first tab, first pane |
| `C-x Shift-N` | New session |
| `C-x Shift-S` | Rename session |
| `C-x Shift-W` | Open the session on the web |
| `C-x Shift-I` | Number every session's label with its `Ctrl-1..9` number on its own host (`3-api`), on this Mac and the remote hosts; rerun after adding, closing, or renaming one |
| `C-x i` | Number every tab's label with its `Cmd-1..9` number (`2-api`) in each session on the Mac you are viewing; a tab without a name of its own takes its pane's folder |
| `C-x Shift-D` | Close session |
| `C-x Shift-M` | Switch machine (host) |
| `C-x Shift-Down` / `C-x o` | Next agent that needs you: blocked, then error, done, idle |
| `C-x Shift-Up` | Previous agent that needs you |
| `C-x b` | Toggle sidebar (vertical tabs only; `shift+cmd+s` switches tab style) |
| `C-x Shift-R` | Reload config |
| `C-x Shift-G` | Open the repo's pull requests on GitHub (`/pulls`) |
| `C-x ?` | Command palette |

Herdr's `C-x a` (last pane) has no equivalent, since Rex config Lua cannot track focus history, so `C-x a` toggles to the last session here.

## Direct keys

| Key | Action |
|---|---|
| `Ctrl-Alt-h/j/k/l` | Focus pane (also `Cmd-Alt-arrows`) |
| `Ctrl-Alt-z` | Zoom pane (also `Shift-Cmd-Enter`) |
| `Cmd-]` / `Cmd-[` | Next / previous pane |
| `Cmd-d` / `Shift-Cmd-d` | Split right / down |
| `Cmd-w` | Close pane, else tab, else window |
| `Alt-Cmd-w` | Close tab |
| `Cmd-1..9` | Go to tab N in this session (`Cmd-9` is the last tab). Rex's default counts the tabs of every session in the sidebar |
| `Cmd-t` | New tab |
| `Shift-Cmd-]` / `Shift-Cmd-[` | Next / previous tab |
| `Shift-Cmd-Up` / `Shift-Cmd-Down` (also `Left` / `Right`) | Move tab up / down. Replaces Rex's `Ctrl-Shift-Up/Down`, which never reached the app, and its `Shift-Cmd-arrow` splits (`C-x m` / `C-x v` split) |
| `Ctrl-1..9` | Go to session N on the host you are viewing |
| `Ctrl-Alt-1..9` | Go to host N: 1 MacBook Pro (`mbp-01`), 2 `mini-01`, 3 kept for `linux-01`; lands on the session you last had there, else its first |
| `Alt-Cmd-]` | Next session |
| `Cmd-k` | Session picker |
| `Shift-Cmd-k` | Switch machine (host) |
| `Ctrl-Alt-a` | Next agent that needs you |
| `Cmd-b` | Toggle sidebar (also `Cmd-/`) |
| `Cmd-.` | Toggle Activity |
| `Alt-Cmd-.` | Dismiss a notice, such as an "Action failed" toast (replaces Rex's `Shift-Cmd-.`) |
| `Shift-Cmd-s` | Toggle vertical / horizontal tabs |
| `Cmd-Up` / `Cmd-Down` | Previous / next shell prompt |
| `Shift-Cmd-p` | Command palette |

Each host numbers its own sessions, so `Ctrl-1..9` stays short however many machines there are: pick the machine with `Ctrl-Alt-1..9`, then the session with `Ctrl-1..9`. The host numbers follow the order of `hosts.json` and are the same on every Mac. `Ctrl-Alt-N` remembers the session you left on each host, per app, until a config reload. To open a session on another Mac, the action asks that host to have your app select it, so keep Remote Control on (Settings, Server, Client Info). `Ctrl-Shift-Tab` never reaches Rex because skhd uses it for yabai stacks, so use `Shift-Cmd-[` for the previous tab.

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

The Mac app ignores `hosts.lua` and keeps its own Remote Hosts list in the `RexSync.servers` preference. `rex-setup.sh` adds each missing Mac there with the same address and leaves existing records alone, since the app fills in their IDs on first connect. Quit and reopen Rex Beta after it reports "Remote Hosts updated".

## Agents inside tmux (OpenRig seats)

Rex shows an agent's status (working, waiting on you, done) from OSC 7501, an escape sequence Claude Code and Codex send on their own when they run straight in a Rex pane. An OpenRig seat runs its agent inside tmux, and its Rex tile only runs `tmux attach`, so the sequence stops at tmux and the tile looks like plain tmux.

`~/.local/bin/rex-agent-status` bridges that for Claude Code. Hooks in `~/.claude/settings.json` (session start and end, prompt, each tool, permission request, stop) call it only when `$TMUX` is set; it turns the event into an OSC 7501 status, wraps it in tmux passthrough, and writes it to the seat's pane. tmux (`allow-passthrough on` in `.tmux.conf`) forwards it to the attached Rex tile, which then counts as a `claude-code` agent for the sidebar status and `C-x o`. `set-titles` passes the agent's title (`✳ <task>`) to the tile as well. A running seat picks the hooks up at its next start.

Codex seats need the same hooks in `~/.codex/hooks.json`, but Codex asks you to review new hooks before they run, so they are not wired yet. Running seats natively in Rex instead of tmux is tracked on the OpenRig fork.

## Option key

Rex defaults the Option key to `automatic`, which types special characters (`alt+p` gives `π`). `rex-setup.sh` sets `Workspace.terminalOptionKeyBehavior` to `actsAsAlt`, the same as Ghostty's `macos-option-as-alt = true`. The other values are `composesText`, `leftActsAsAlt`, and `rightActsAsAlt`. Right Option plus a letter still launches apps through Karabiner before Rex sees it.
