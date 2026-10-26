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
- `dotfiles/rexboard/.config/rexboard/extensions/openrig/` - the [OpenRig extension](#openrig-extension) config.toml enables: each seat's rig, project and role on rexboard's rows
- `dotfiles/bin/.local/bin/rex-agent-status` and `rex-hooks-sync` - the status bridge for agents in tmux and the hook merge (see [Agent status](#agent-status))
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

## Agent status

Rex shows an agent's status (working, waiting on you, done) from OSC 7501, an escape sequence the agent prints into its pane. Rex keeps it on the pane as a status record with a state, an optional kind and a message (`msg`). The sidebar, `C-x o` and [rexboard](https://github.com/vanducng/rexboard) all read that record.

Where the agent runs decides who sends it:

| Agent | Straight in a Rex pane | Inside tmux (an OpenRig seat) |
| --- | --- | --- |
| Claude Code | Claude reports on its own. The hooks add the title glyph and a `turn` record with the final message (below) | The hooks report for it |
| Codex (experimental) | Codex reports on its own, and the hooks write nothing | The hooks report for it, once trusted in Codex |
| pi | pi reports nothing, so its extension writes the status to pi's tty | The extension reports through the seat's pane |

An OpenRig seat needs the bridge because its Rex tile only runs `tmux attach`, and tmux stops the sequence, so without it the tile looks like plain tmux. rexboard shows a seat's row as `bridge`, a pane that reports for itself as `native`, and a pane with no record as `inferred` (see its [agent status page](https://github.com/vanducng/rexboard/blob/main/docs/agent-status.md)).

### The bridge

Every hook runs `~/.local/bin/rex-agent-status <app>` with the hook's JSON on stdin: `claude-code` from `~/.claude/settings.json`, `codex` from `~/.codex/hooks.json`, `pi` from the `rex-status` extension. A shell gate in front of it exits at once unless `$TMUX` or `$REX_BLOCK` is set, or `$TERM` starts with `tmux` or `screen`:

```sh
[ -n "$TMUX$REX_BLOCK" ] || case "$TERM" in tmux*|screen*) ;; *) exit 0;; esac
```

The `TERM` case covers a seat whose launcher started the agent without `TMUX` and `TMUX_PANE` (OpenRig's `--resume` does). The script then finds the seat's pane by the agent's tty (`tmux list-panes -a`), and does nothing unless exactly one pane matches.

Inside tmux, the script turns the event into an OSC 7501 status, wraps it in tmux passthrough, and writes it to the seat's pane. tmux (`allow-passthrough on` in `.tmux.conf`) forwards it to the attached Rex tile, and `set-titles` passes the agent's title (`✳ <task>`) along too. The last status is also kept on the pane as `@rex_status` (the message base64-encoded), and a tmux hook resends it when a client attaches or switches to the session, so a tile opened later shows it at once. The script never fails a hook.

### What each event reports

| Event | Status | Message |
| --- | --- | --- |
| Session start | idle | |
| Prompt | working | `Working` |
| A tool | working | its description, else its name |
| AskUserQuestion | blocked, kind `question` | the first question, then each option as `1. label - description`, and `(+N more questions)` |
| The question answered | working | `Working` |
| Permission request, or Claude's permission notification | blocked, kind `permission` | `Allow <tool>?`, or the notification's text (Codex: the command's description) |
| Stop | done | the agent's final message, else `Done` |
| Stop on an API error | error | the agent's last message, else the error and its details |
| Session end | cleared | |

Codex sends the same events except AskUserQuestion, the permission notification and the API error. pi sends session start and end, each run's start (working), and its end (done, with the last assistant message, or error, with the model's error). It sends them one at a time, in order, and holds off exiting until a run's end has been sent. `pi -p` sends no session end, so its result stays up after it exits.

A message is one line, since Rex allows no control characters: each line break becomes ` ⏎ ` (rexboard splits on it), blank lines drop, and any other control character becomes a space. It is cut to Rex's limit of 2048 bytes, at a character, ending in `…`. Over a limit Rex would drop the whole report. So the agent's final message reaches Rex and anything that reads its status, such as rexboard, just as it does for an agent running straight in a Rex pane. Do not keep secrets in an agent's replies.

Straight in a Rex pane, Claude Code's own `done` carries no text. So on stop the hook also writes a `turn` sub-record (`id=turn`) with the final message to Claude's tty, and clears it at the next prompt and when the session ends. Claude's own reports leave it alone (`rex block call program_status` shows both records).

Inside tmux, Claude Code spins a glyph at the front of its title (`◐` working, `✳` idle), so a seat's pane header shows its state. Straight in a Rex pane it leaves the glyph out, because Rex already has the status, so the hooks put it back: each records the status in a file under `$TMPDIR` and starts one background spinner for the pane (`rex-agent-status --spin`). The spinner reads the title with `rex block call title` and writes it back with `◐`/`◑` flipping every 0.96 s while Claude works, `◉` while it waits on you, and no glyph when it is idle. It exits with Claude.

### Install and update the hooks

The live `~/.claude/settings.json` and `~/.codex/hooks.json` are not stowed: the agents rewrite them, and they hold private entries this repo must not see. Dotfiles owns only the rex hook entries, in `dotfiles/claude/.claude/settings.json` and `dotfiles/codex/.codex/hooks.json`, and `rex-hooks-sync` merges them in. For each event it replaces the hooks that run `rex-agent-status` with the dotfiles ones, in the same place, and leaves every other key and hook alone.

```bash
make rex-hooks         # print the lines that would change, or "up to date", for Claude and Codex
make rex-hooks-apply   # write them, after a backup beside each file (<file>.bak-<UTC>)
```

`make stow-rex` and `make stow-install` run the apply step after stowing rex. A second run changes nothing. A file that is a symlink (a host that stows it) or missing is left alone, and one that is not valid JSON fails without a write. A running Claude Code picks up the merged hooks without a restart. Codex asks you to review and trust new hooks once, which only you can do in Codex.

The pi extension, `dotfiles/pi/.pi/agent/extensions/rex-status.js`, comes with `make stow-pi`. That stops without changes when a live pi file, such as `~/.pi/agent/mcp.json`, differs from the dotfiles one. To link only the extension, make the same relative link stow would at `~/.pi/agent/extensions/rex-status.js`. pi loads it at its next start.

### Troubleshooting

Start from what Rex has. rexboard's detail pane shows a row's `source` and message, and its [agent status page](https://github.com/vanducng/rexboard/blob/main/docs/agent-status.md#a-row-looks-wrong) covers rows that look wrong. For a seat, `tmux show-options -p -t <pane> @rex_status` shows the last status the bridge sent.

To see what the hooks do, set `REX_AGENT_STATUS_LOG=<file>` in the agent's env. Each call appends one line with the event, which of `TMUX`, `TMUX_PANE` and `REX_BLOCK` were set, the pane it found, and what it did, never the hook's text. For example, `Stop env=- pane=%78 wrote done`, or `skipped: not in tmux or Rex` when the pane could not be found. A seat whose hooks never appear in the log failed the gate. In that case, check `TERM` in the agent's env, and run `make rex-hooks`.

To test the bridge without an agent, send a fake Stop through a throwaway tmux session, set up the way a resumed seat is:

```bash
tmux new-session -d -s zz-probe
tmux send-keys -t zz-probe "unset TMUX TMUX_PANE REX_BLOCK; export TERM=tmux-256color; echo '{\"hook_event_name\":\"Stop\",\"last_assistant_message\":\"probe ok\"}' | /usr/bin/python3 ~/.local/bin/rex-agent-status claude-code" Enter
for i in $(seq 50); do tmux show-options -p -t zz-probe -v @rex_status 2>/dev/null && break; sleep 0.2; done   # app=claude-code:state=done:msg=cHJvYmUgb2s=
tmux kill-session -t zz-probe
```

Known gaps:

- `pi -p` (print mode) loses its final report: the hook runs after pi exits and finds no pane, so the row stays `working`. Interactive pi reports normally.
- Codex's hooks are experimental and do nothing until trusted in Codex.

Running seats natively in Rex instead of tmux is tracked on the OpenRig fork.

## OpenRig extension

rexboard runs `extensions/openrig` (enabled in `config.toml`) every 10 seconds over its [extension contract](https://github.com/vanducng/rexboard/blob/main/docs/extensions.md). The adapter is POSIX `sh` with `jq` and `yq`. It asks `rig ps --nodes -A --json` on this Mac, and `rig ps --host <label>` for each other host in the rows, so a Rex host's label must be its OpenRig host id (`mini-01`). The other hosts are asked at once and get until 2.5 seconds after this Mac answers, inside the extension's 5 second timeout, so a host that is asleep or off the network only loses its own rows.

- **Matching:** a row is a seat when its title, with the leading status glyph or without it, is the seat's `canonicalSessionName` (`dev-impl@rexboard`), or else when its pane label is the seat's `logicalId` (`dev.impl`) inside the rig's tab (`openrig:rig:<rig>#…`) or `<n>-<rig>` session. That covers a Codex seat whose title the harness set. A row two seats could be is left out.
- **Fields:** `rig` (`rigName`), `role` (`logicalId`), and `project`: the id of the project in `~/projects/workspace.yaml` (`settings.workspace`, else `$PROJECTS_ROOT`, else `~/projects`) whose `rigs` lists the rig. A `workspace.yaml` that does not parse leaves `project` empty and logs one line to `serve.log`.
- **Status,** for a seat with no status record of its own: `needsAttention` or `needs-input` is `blocked` (kind `input`), `running` is `working`, and `idle` is `idle`. Anything else gives none. A seat whose bridge reports keeps its own status.
- **Failure:** with `rig` missing, or `rig ps` failing on this Mac, the run fails with one line on stderr, and rexboard's top bar shows `ext openrig failed`. `rexboard ext ls` shows how the last run went.

`rexboard ext test openrig` runs it once against the live rows. `scripts/ci/test-rexboard-openrig.sh` (in `make test`) runs it on generic fixtures with a fake `rig`, then `rexboard ext test openrig --rows` on them when rexboard is installed.

## Option key

Rex defaults the Option key to `automatic`, which types special characters (`alt+p` gives `π`). `rex-setup.sh` sets `Workspace.terminalOptionKeyBehavior` to `actsAsAlt`, the same as Ghostty's `macos-option-as-alt = true`. The other values are `composesText`, `leftActsAsAlt`, and `rightActsAsAlt`. Right Option plus a letter still launches apps through Karabiner before Rex sees it.
