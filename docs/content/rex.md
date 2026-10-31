---
title: "Rex"
---

Rex (Rex Beta) is the native macOS multiplexer that replaces Ghostty on space 1 (`meh + a`). Rex runs its sessions on a server, so the Mac app can attach to sessions on other machines over Tailscale.

## Source of truth

- `dotfiles/rex/.config/rex/init.lua` - key bindings and the resize mode
- `dotfiles/rex/.config/rex/actions.lua` - Lua actions: `session_goto`, `session_toggle`, `host_goto`, `tab_cycle`, `session_renumber`, `session_layout`, `layout_goto`, `tab_renumber`, `tab_goto`, `home`, `fingers`, `project_pick`, `agent_next`, `agent_pick`, `agent_attention` (the old in-Lua scan, kept until `rexboard next` is proven live), `copy_mode`, `pane_label`, `open_pr`
- `dotfiles/rex/.config/rex/layout.lua` - the sessions kept at the top of this Mac's sidebar (see [Session layout](#session-layout))
- `dotfiles/rex/.config/rex/hosts.json` - every machine that runs Rex, defined once: `label`, `device`, macOS `hostname`, and the app `icon`. Its order is the `Ctrl-Alt-1..9` number
- `dotfiles/rex/.config/rex/hosts.lua` - reads `hosts.json`, works out which entry is this Mac, and declares the others as Rex hosts
- `dotfiles/rexboard/.config/rexboard/config.toml` - [rexboard](https://github.com/vanducng/rexboard)'s config. The app client is left to the default, the only Rex app on the unix socket. The rexboard keys and the cockpit's board tab find `rexboard` in `$HOMEBREW_PREFIX/bin`, `/opt/homebrew/bin`, `/usr/local/bin`, `~/.local/bin`, then `PATH`, and say `brew install vanducng/tap/rexboard` when it is missing
- `dotfiles/rexboard/.config/rexboard/extensions/openrig/` - the [OpenRig extension](#openrig-extension) config.toml enables: each seat's rig, project and role on rexboard's rows, and a message to the seat (`x s` on the board)
- `dotfiles/bin/.local/bin/rex-title-spinner` and `rex-hooks-sync` - Claude Code's title glyph in a Rex pane, and the hook merge for it and cursor-agent (see [Agent status](#agent-status))
- `dotfiles/cursor/.cursor/hooks/rex-status.py` - cursor-agent's OSC 7501 status hook (see [Agent status](#agent-status))
- `dotfiles/bin/.local/bin/rex-pane-titles` - automatic pane labels and visible titles across agent CLIs (see [Pane names](#pane-names))
- `dotfiles/bin/.local/bin/rex-agent-status` - kept for a release: hooks merged before `rexboard hook`, and the old tmux replay hook, still run it. It hands each call to `rexboard hook` or `rexboard hooks replay`, and does nothing when rexboard has no `hooks` command, so a hook never fails. `make rex-hooks-apply` and a restow replace those callers
- `dotfiles/rex/.config/rex/copy-mode.nvim.lua` - settings applied after the normal AstroNvim config loads: clipboard yanking, `q` / `Ctrl-C` to close, and the full-screen capture notice. Copy mode includes the usual plugins and motion keys (`s` for Flash, `f` / `t` for character jumps)
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
| `C-x Space` | Pick a URL or file path from the pane's latest 500 lines, newest first, in a floating pane centered over the window: `Enter` opens, `Ctrl-Y` copies, `Ctrl-E` edits (Herdr's `herdr-fingers`) |
| `C-x p` | Pick a session or a project folder in a floating pane (`rex-project-picker`, like `tmux-sessionizer`). Sessions come first and the current one last. A `+` row is a folder under `~/personal`, `~/projects`, `~/git/personal`, `~/git/work` or `~/git/dataplanelabs` with no session yet; `Enter` opens it in a new numbered session (`5-api`). A folder already open in a session (its first tab's pane is in it) shows only as that session, so a second pick reuses it. `Esc` returns to the pane. This Mac only |
| `C-x [` | Copy mode: the screen and scrollback in Neovim over the pane, with wrapped lines joined. `v` to select, `y` copies to the clipboard, `q` or `Ctrl-C` closes and returns to the pane, zoomed if it was (over a zoomed pane the popup fills the window, since Rex unzooms when focus leaves the pane). A full-screen app (Claude Code, nvim, less) has no scrollback, so only its visible screen shows, and a bar at the top says so |
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
| `Alt-Shift-1` | The board: `1-cockpit` tab 1 (replaces `C-x Shift-O`). Made first if missing. From any app, Caps+B (skhd's `hyper - b`) brings Rex forward and does the same |
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

The `session_layout` action makes the missing ones, reopens a layout tab you closed, and moves the three to positions 1-3. It finds sessions and tabs by name without the number, so `cockpit` or `5-cockpit` counts, and a tab you added yourself never stands in for a closed layout tab. It skips a session whose folder this Mac lacks, and never kills or restarts a session. Every session's number is its `Ctrl-1..9` position, so with all three present the rest start at 4 (`1-warp-factory-setup` becomes `4-warp-factory-setup`); with one skipped, the rest close the gap. Only the number prefix changes, never the name.

The server restores sessions itself (see [Restarts and upgrades](#restarts-and-upgrades)), so after a restart `session_layout` usually finds all three and changes nothing. It runs from `make setup-rex` and at login (the `dev.vanducng.rex-session-layout` LaunchAgent in the `launchd` package), which writes failures to `~/Library/Logs/rex-session-layout.log`. No key runs the whole layout: `Alt-Shift-1..5` make or complete only their own session before going to it, or say its folder does not exist. By hand:

```bash
rex do ~/.config/rex/actions.lua --action session_layout dry_run=true   # print the plan, change nothing
rex do ~/.config/rex/actions.lua --action session_layout
```

## Restarts and upgrades

From Mac 0.1.0-preview.23 and Linux server 0.1.0-preview.11, a Rex server saves its sessions when it stops and brings them back when it starts: sessions, tabs, splits, floating panes, labels and IDs. Each terminal comes back as a new shell in the folder it was in. Programs are not restarted and scrollback is not restored, so agents need resuming (`claude -c`, `codex resume --last`, `pi -c`, `cursor-agent resume`). OpenRig seats run in tmux and are not affected, but their tiles do not come back: a tile runs `tmux attach` and closes when that ends, so the rig's session returns with no tabs. Remove the empty session (`rex kill <id>`), reopen the tiles with `rig terminal open <rig> --provider rex`, and renumber with `C-x Shift-I`.

The save happens on a clean stop: an app update, `rex server stop`, or `systemctl --user restart rex-personal.service`. A crash or power loss may lose changes made since the server started. `rex server stop --discard` deletes the saved sessions, and `rex server run --restore=false` starts without them.

To upgrade:

- **Mac:** update Rex Beta (Check for Updates). The first launch after an update can still start the old embedded server; `rex server status` shows its version. If it is old, quit the app, run `rex server stop`, and open the app again.
- **Linux:** `sudo apt-get install --only-upgrade rex`, then `systemctl --user restart rex-personal.service`. The package does not restart a personal server by itself. The sudo password for `mini-01` and `linux-01` is `op://personal-rig/host-sudo/password`, readable with `op-sa --sa personal-rig read`; pipe it to `sudo -S`, never pass it as an argument.

Drive a restart from somewhere that survives it: a tmux session, or an ssh tab from another machine. A restart ends every Rex pane on that server, including the one running the command.

## Machines

Each Mac's Rex server joins the tailnet as its own device, `rex-<ssh alias>`, through Rex's built-in Tailscale. The system Tailscale node cannot be reused: the Tailscale GUI app has no `tailscaled` socket, and the Rex app starts its server with fixed flags. Tailscale still takes the direct LAN path at home.

On a new Mac, open Rex Beta once, then:

```bash
make stow-rex
make setup-rex   # Option as Alt, Tailscale node rex-<alias>, config reload
rex server status   # first run only: open the Tailscale sign-in link it prints
rex -S mini-01 ls
```

On the Linux box (`linux-01`, ssh alias the same), there is no Rex app, so the personal server runs headless as the login user. It is in hosts.json like the Macs (its `hostname` is the Linux short hostname; `hosts.lua` falls back to `hostname -s` where there is no `scutil`), and the same stowed `init.lua` keybindings apply to its sessions. Two things differ from a Mac:

- The unit is `rex-personal.service` from the rex package (`.config/systemd/user/`): a foreground `rex server run` with `Restart=on-failure`, enabled under the user manager with linger on, so it starts at boot and comes back after a crash. `make setup-rex-linux` (`scripts/rex-linux-setup.sh`, re-runnable) stows rex, checks linger, enables the unit, and checks the config. It never runs the rexboard hooks step.
- It listens two ways: its own Tailscale node `rex-linux-01` (built-in Tailscale, the address `hosts.lua` declares; sign it in once from the link `rex server status` prints), and `tailnet://:7297` on the host's own system Tailscale node (`http://linux01.<tailnet>:7297`), which needs no second sign-in and is what a Mac's stored `linux-01` host label points at. From a Mac, both work; the GUI's Remote Hosts entry comes from `make setup-rex` there once hosts.json lists linux-01.

The package's system `rex.service` (one shared server as the `rex` account) is not used on the Linux box; `rex-linux-setup.sh` prints the `sudo systemctl disable --now rex.service` line for the operator instead of running it.

Host labels follow `<kind>-<nn>`: `mbp`, `mini` or `linux`, then a two-digit number, the same as the machine's ssh alias (`mbp-01`, `mini-01`, `linux-01`). Each Mac's Rex server joins Tailscale as `rex-<label>`. `hosts.lua` reads `hosts.json`, finds this Mac's entry by its macOS `LocalHostName` (`scutil --get LocalHostName`), and declares every other entry as a Rex host at `https://rex-<label>.<tailnet domain>`. It reads the tailnet domain from the Tailscale app at load, so the domain stays out of this repository. `rex hosts` lists what it declared. A new machine needs only an entry in `hosts.json`; `rex-setup.sh` reads the same file for this Mac's label and the app icons.

`make release` (`scripts/release.sh`) ships a release to every machine in `hosts.json`. It merges the open release-please PR once GitHub reports it clean, waits for the `release` run to tag it, then pulls `~/dotfiles` here and over ssh on each other machine. Local edits to tracked files survive: an edit to a file upstream also changed is lifted off as a patch and put back after the pull, and if it no longer applies the local file stays as it was and the script names it. When the rex config changed, it runs `rex config check` and then `rex config reload`. With no release pending it only pulls.

The Mac app ignores `hosts.lua` and keeps its own Remote Hosts list in the `RexSync.servers` preference. `rex-setup.sh` adds each missing Mac there with the same address and leaves existing records alone, since the app fills in their IDs on first connect. Quit and reopen Rex Beta after it reports "Remote Hosts updated".

## Pane names

Automatic pane labels use `repo · app · task`, for example `api · claude · Fix login`, `api · grok · Add search`, or `api · cursor · Review login`. The task appears when the agent reports a title. A shell uses `repo · shell`; other programs use their executable or script name. Agent subprocesses retain the parent agent's identity. Idle shell titles show the folder, and remote shell prompts show the short hostname without the username.

`rex-pane-titles` watches Rex process, directory, and title events. It pins the repo, harness, and first task title in the block label for each agent process, so tool calls and later progress titles keep the same identity. Braille and rotating title frames are stripped from labels. Shell labels resume when the agent exits. The running program controls its visible terminal title; the watcher never writes a competing title to the terminal. Rex currently displays the terminal title in pane headers even when a block label is set.

One watcher runs per Rex server, started by a new interactive Rex shell on macOS or Linux. It preserves manually assigned labels, including labels from `C-x ,`. Run `rex-pane-titles --start` to start it in an existing shell, or `rex-pane-titles --once` to update current automatic panes once. The watcher uses the local Rex CLI. Explicit session and tab names stay unchanged; unnamed tabs follow the terminal title. Codex's native title leaves out its animated `activity` item; existing Codex processes pick that setting up on their next launch.

## Agent status

Rex shows an agent's status (working, waiting on you, done) from OSC 7501, an escape sequence the agent prints into its pane. Rex keeps it on the pane as a status record with a state, an optional kind and a message (`msg`). The sidebar, `C-x o` and [rexboard](https://github.com/vanducng/rexboard) all read that record.

Every agent hook runs `rexboard hook <harness> <EVENT>` with the hook's JSON on stdin. It works out where the agent runs and who has to send the status:

| Agent | Straight in a Rex pane | Inside tmux (an OpenRig seat) |
| --- | --- | --- |
| Claude Code | Claude reports on its own. `rexboard hook` adds a `turn` record with the final message, and the spinner hook puts the title glyph back (below) | `rexboard hook` reports for it |
| Codex (experimental) | Codex reports on its own, and the hook writes nothing | `rexboard hook` reports for it, once trusted in Codex |
| pi | pi reports nothing, so rexboard's extension writes the status to pi's tty | The extension reports through the seat's pane |
| cursor-agent | cursor-agent reports nothing and rexboard has no harness for it, so `~/.cursor/hooks/rex-status.py` writes the status to the agent's tty: `idle` at start, `working` with the prompt, command, MCP tool or edited file, then `done` (`idle` if aborted, `error` if failed), cleared at session end. Cursor's hooks have no permission event, so it never reports `blocked` | Not reported |

An OpenRig seat needs this because its Rex tile only runs `tmux attach`, and tmux stops the sequence. `rexboard hook` wraps the status in tmux passthrough (`allow-passthrough on` in `.tmux.conf`) and keeps the last one on the pane as `@rex_status`. The tmux `client-attached` and `client-session-changed` hooks run `rexboard hooks replay`, so a tile opened later shows it at once. rexboard's [`hook` docs](https://github.com/vanducng/rexboard/blob/main/docs/cli.md#rexboard-hook) have the event mapping and message limits.

Inside tmux, Claude Code adds its own title glyph. Straight in a Rex pane each Claude hook also runs the legacy-named `rex-title-spinner`, which acts only outside tmux. It records the state under `$TMPDIR` and starts one background reporter per pane. The reporter writes a static `●` when work starts, `◉` while waiting, and removes its marker when idle. It writes only on state changes and exits with Claude. The pane-title watcher maintains the fixed repo, harness, and task text in the block label.

### Install and update the hooks

`rexboard hooks install` merges rexboard's hooks into `~/.claude/settings.json` and `~/.codex/hooks.json`, wraps Claude's status line with `rexboard usage claude`, and writes pi's extension (`~/.pi/agent/extensions/rexboard.js`). It leaves a symlinked file alone, so a host that stows `claude` or `codex` gets the same hooks from `dotfiles/claude/.claude/settings.json` and `dotfiles/codex/.codex/hooks.json`. On a host that does not stow them, `rex-hooks-sync` merges the one hook rexboard does not ship, the title spinner, in place, and leaves every other key and hook alone. It also merges cursor-agent's status hook from `dotfiles/cursor/.cursor/hooks/rex-status.json` into `~/.cursor/hooks.json`, which other tools (moshi, herdr, omnigent) also write, so it is never stowed.

```bash
make rex-hooks         # what rexboard hooks install and the spinner merge would change
make rex-hooks-apply   # write them, after a backup beside each file (<file>.bak-<UTC>)
```

`make stow-rex` and `make stow-install` run the apply step after stowing rex. Without a `rexboard` that has `hooks` on `PATH`, they print how to install it and merge only the spinner. A second run changes nothing. A running Claude Code picks up the merged hooks without a restart; cursor-agent needs a new session. Codex asks you to review and trust new hooks once, which only you can do in Codex, and pi loads its extension at its next start.

### Troubleshooting

Start from what Rex has. rexboard's detail pane shows a row's `source` and message, and its [agent status page](https://github.com/vanducng/rexboard/blob/main/docs/agent-status.md#a-row-looks-wrong) covers rows that look wrong. For a seat, `tmux show-options -p -t <pane> @rex_status` shows the last status sent. `rexboard hooks status` says whether each harness has the hooks.

To see what the hooks do, set `REXBOARD_HOOK_LOG=<file>` in the agent's env. Each call appends one line with the event, which of `TMUX`, `TMUX_PANE` and `REX_BLOCK` were set, the pane it found, and what it did, never the hook's text.

To test it without an agent, send a fake Stop through a throwaway tmux session, set up the way a resumed seat is:

```bash
tmux new-session -d -s zz-probe
tmux send-keys -t zz-probe "unset TMUX TMUX_PANE REX_BLOCK; export TERM=tmux-256color; echo '{\"hook_event_name\":\"Stop\",\"last_assistant_message\":\"probe ok\"}' | rexboard hook claude Stop" Enter
for i in $(seq 50); do tmux show-options -p -t zz-probe -v @rex_status 2>/dev/null && break; sleep 0.2; done   # app=claude-code:state=done:msg=cHJvYmUgb2s=
tmux kill-session -t zz-probe
```

Codex's hooks are experimental and do nothing until trusted in Codex. Running seats natively in Rex instead of tmux is tracked on the OpenRig fork.

## OpenRig extension

rexboard runs `extensions/openrig` (enabled in `config.toml`) every 10 seconds over its [extension contract](https://github.com/vanducng/rexboard/blob/main/docs/extensions.md). The adapter is POSIX `sh` with `jq` and `yq`. It asks `rig ps --nodes -A --json` on this Mac, and `rig ps --host <label>` for each other host in the rows, so a Rex host's label must be its OpenRig host id (`mini-01`). The other hosts are asked at once and get until 2.5 seconds after this Mac answers, inside the extension's 5 second timeout, so a host that is asleep or off the network only loses its own rows.

- **Matching:** a row is a seat when its title, with the leading status glyph or without it, is the seat's `canonicalSessionName` (`dev-impl@rexboard`), or else when its pane label is the seat's `logicalId` (`dev.impl`) inside the rig's tab (`openrig:rig:<rig>#…`) or `<n>-<rig>` session. That covers a Codex seat whose title the harness set. A row two seats could be is left out.
- **Fields:** `rig` (`rigName`), `role` (`logicalId`), and `project`: the id of the project in `~/projects/workspace.yaml` (`settings.workspace`, else `$PROJECTS_ROOT`, else `~/projects`) whose `rigs` lists the rig. A `workspace.yaml` that does not parse leaves `project` empty and logs one line to `serve.log`.
- **Session:** the seat's `canonicalSessionName`, as a hidden field: no column, but the send action below and `rexboard ls --json` read it.
- **Status,** for a seat with no status record of its own: `needsAttention` or `needs-input` is `blocked` (kind `input`), `running` is `working`, and `idle` is `idle`. Anything else gives none. A seat whose bridge reports keeps its own status.
- **Failure:** with `rig` missing, or `rig ps` failing on this Mac, the run fails with one line on stderr, and rexboard's top bar shows `ext openrig failed`. `rexboard ext ls` shows how the last run went.

- **Send a message:** `x s` on a seat's row opens one input line, then a red confirm line naming the seat and host and showing the text in quotes (`send to seat-b@web on mini: "ready for review?"`, with `· it waits on a dialog` when the seat is blocked), then `y`. The `send` script runs `rig send [--host <label>] --verify -- SESSION TEXT`, with `--host` only when the row's host is not `local`, so a seat on `mini-01` is reached through its own OpenRig daemon. `--verify` makes it fail when the text does not reach the pane. Nothing is sent before `y`, a row that is not a seat has no action, and a failure stays in red in the footer. From the shell: `rexboard ext run openrig send <key> --text "…" --yes` (`--dry-run` prints what it would run). Needs a rexboard with [extension actions](https://github.com/vanducng/rexboard/blob/main/docs/extensions.md#actions); an older one marks this extension broken and shows no OpenRig fields.
- **Sender:** a message sent from the operator's board is signed `captain@global`: `sender = "captain@global"` under `[extensions.settings.openrig]` in `config.toml`, which the script exports as `OPENRIG_SESSION_NAME` (the board is not an OpenRig seat, so without it the seat would see `From: <unknown sender>`). A caller that already has `OPENRIG_SESSION_NAME` is a seat, for example the lead running `rexboard ext run openrig send ...`, and speaks as itself: its own name is kept and `sender` is ignored for it. `wait_for_idle = 30` (seconds, at most 30; more is refused; not set in this repo) waits for an idle seat and sends nothing if it stays busy. The action's timeout is 45 seconds, so the longest wait still leaves 15 for the delivery; `scripts/ci/test-rexboard-openrig.sh` checks that, and the sender rules.

`rexboard ext test openrig` runs it once against the live rows. `scripts/ci/test-rexboard-openrig.sh` (in `make test`) runs it, and the send script, on generic fixtures with a fake `rig`, then `rexboard ext test openrig --rows` on them when rexboard is installed.

## Option key

Rex defaults the Option key to `automatic`, which types special characters (`alt+p` gives `π`). `rex-setup.sh` sets `Workspace.terminalOptionKeyBehavior` to `actsAsAlt`, the same as Ghostty's `macos-option-as-alt = true`. The other values are `composesText`, `leftActsAsAlt`, and `rightActsAsAlt`. Right Option plus a letter still launches apps through Karabiner before Rex sees it.
