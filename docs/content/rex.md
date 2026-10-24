---
title: "Rex"
---

Rex (Rex Beta) is the native macOS multiplexer that replaces Ghostty on space 1 (`meh + a`). Rex runs its sessions on a server, so the Mac app can attach to sessions on other machines over Tailscale.

## Source of truth

- `dotfiles/rex/.config/rex/init.lua` - key bindings and the resize mode
- `dotfiles/rex/.config/rex/actions.lua` - Lua actions: `session_goto`, `session_renumber`, `tab_goto`, `home`, `fingers`, `agent_attention`, `copy_mode`, `pane_label`, `open_pr`
- `dotfiles/rex/.config/rex/hosts.lua` - the other machines, one Rex host per ssh alias
- `scripts/rex-setup.sh` (`make setup-rex`) - app settings that live in UserDefaults: Option as Alt, vertical tabs, compact panes, the Tailscale node name, and the app's Remote Hosts list. The app reads them at launch, so quit and reopen Rex Beta after a run; sessions live in the server and survive

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
| `C-x [` | Copy mode: the screen and scrollback in Neovim over the pane, with wrapped lines joined. `v` to select, `y` copies to the clipboard, `q` closes and returns to the pane, zoomed if it was (over a zoomed pane the popup fills the window, since Rex unzooms when focus leaves the pane). A full-screen app (Claude Code, nvim, less) has no scrollback, so only its visible screen shows, and a bar at the top says so |
| `C-x c` | New tab |
| `C-x 1..9` | Go to tab N in this session (`9` is the last tab) |
| `C-x Shift-T` | Rename tab |
| `C-x Shift-X` | Close tab |
| `C-x Shift-1..9` | Go to session |
| `C-x Shift-Left/Right` | Previous / next session |
| `C-x g` / `C-x w` / `C-x s` | Session picker |
| `C-x 0` | Home: first session, first tab, first pane |
| `C-x Shift-N` | New session |
| `C-x Shift-S` / `C-x Shift-W` | Rename session |
| `C-x Shift-I` | Number every session's label with its `Ctrl-1..9` number (`3-api`), here and on remote hosts; rerun after adding, closing, or renaming one |
| `C-x Shift-D` | Close session |
| `C-x Shift-M` | Switch machine (host) |
| `C-x Shift-Down` / `C-x o` | Next agent that needs you: blocked, then error, done, idle |
| `C-x Shift-Up` | Previous agent that needs you |
| `C-x b` | Toggle sidebar (vertical tabs only; `shift+cmd+s` switches tab style) |
| `C-x Shift-R` | Reload config |
| `C-x Shift-G` | Open the repo's pull requests on GitHub (`/pulls`) |
| `C-x ?` | Command palette |

`C-x a` (last pane) has no equivalent: Rex config Lua cannot track focus history.

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
| `Ctrl-1..9` | Go to session |
| `Alt-Cmd-]` / `Alt-Cmd-[` | Next / previous session |
| `Cmd-k` | Session picker |
| `Shift-Cmd-k` | Switch machine (host) |
| `Ctrl-Alt-a` | Next agent that needs you |
| `Cmd-b` | Toggle sidebar (also `Cmd-/`) |
| `Cmd-.` | Toggle Activity |
| `Shift-Cmd-s` | Toggle vertical / horizontal tabs |
| `Cmd-Up` / `Cmd-Down` | Previous / next shell prompt |
| `Shift-Cmd-p` | Command palette |

`Ctrl-1..9` and `C-x Shift-1..9` number sessions like the session picker: this Mac's first, then each remote host's, so `Ctrl-7` can open a session on `mini-01`. Remote sessions count only when the key is pressed in the app, because an action sees the hosts of the client that ran it. The numbers stay the same while you view a session on another Mac. To open a remote session, the action asks that host to have your app select it, so keep Remote Control on (Settings, Server, Client Info). `Ctrl-Shift-Tab` never reaches Rex because skhd uses it for yabai stacks, so use `Shift-Cmd-[` for the previous tab.

## Machines

Each Mac's Rex server joins the tailnet as its own device, `rex-<ssh alias>`, through Rex's built-in Tailscale. The system Tailscale node cannot be reused: the Tailscale GUI app has no `tailscaled` socket, and the Rex app starts its server with fixed flags. Tailscale still takes the direct LAN path at home.

On a new Mac, open Rex Beta once, then:

```bash
make stow-rex
make setup-rex   # Option as Alt, Tailscale node rex-<alias>, config reload
rex server status   # first run only: open the Tailscale sign-in link it prints
rex -S mini-01 ls
```

`hosts.lua` declares every other Mac as a host. It reads the tailnet domain from the Tailscale app at load, so the domain stays out of this repository, and it skips the Mac it runs on. A new machine needs its label in `hosts.lua` and in two places in `rex-setup.sh`: the `case` and the `icons` map.

The Mac app ignores `hosts.lua` and keeps its own Remote Hosts list in the `RexSync.servers` preference. `rex-setup.sh` adds each missing Mac there with the same address and leaves existing records alone, since the app fills in their IDs on first connect. Quit and reopen Rex Beta after it reports "Remote Hosts updated".

## Option key

Rex defaults the Option key to `automatic`, which types special characters (`alt+p` gives `π`). `rex-setup.sh` sets `Workspace.terminalOptionKeyBehavior` to `actsAsAlt`, the same as Ghostty's `macos-option-as-alt = true`. The other values are `composesText`, `leftActsAsAlt`, and `rightActsAsAlt`. Right Option plus a letter still launches apps through Karabiner before Rex sees it.
