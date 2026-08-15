---
title: "Codex"
---

Codex CLI configuration is managed from this repository with GNU Stow.

## Install

```bash
make stow-codex
```

This links `dotfiles/codex/.codex/config.toml` to `~/.codex/config.toml` and installs the managed hook scripts under `~/.codex/hooks/`.

## Managed Settings

- `model = "gpt-5.6-sol"` (Souls) with high reasoning effort and pragmatic personality — 5.6 is default (372k context vs 272k on 5.5/5.4, latest router mapping).
- `web_search = "cached"` for default web access with lower live-page prompt-injection exposure.
- `/goal` is pinned on with `features.goals = true`.
- Agent workflow features are pinned on, including multi-agent tools, hooks, shell snapshots, workspace dependencies, browser use, computer use, image generation, and plugin support.
- TUI Vim mode starts enabled with `tui.vim_mode_default = true`.
- TUI notifications are enabled and set to fire even when the terminal is focused.
- The status line is ordered for workflow state first: run state, current directory, git branch, model/reasoning, context remaining, context used, and task progress.
- The terminal title shows activity, project, and model.
- Sound hooks play on approval requests and turn completion.
- OpenAI developer docs MCP is configured as `openaiDeveloperDocs`.
- Current Codex plugins for Browser, GitHub, Documents, Spreadsheets, and Presentations stay enabled.

## miudb MCP

`miudb mcp serve --transport stdio` works with any stdio MCP host. It reads saved database connections from `~/.config/miu/db`, redacts secrets, and keeps `query_run` read-only by default.

Cursor uses `~/.cursor/mcp.json`. Add only this server entry to the existing `mcpServers` object:

:::danger
Do not commit the full live `~/.cursor/mcp.json` if it contains existing tokens. Add only the `miudb` entry below to the existing `mcpServers` object.
:::

```json
{
  "mcpServers": {
    "miudb": {
      "command": "miudb",
      "args": ["mcp", "serve", "--transport", "stdio"]
    }
  }
}
```

Restart the host after changing MCP configuration.

## Attention Sounds

Codex does not currently expose Claude Code's `Notification` hook event. The closest user-attention event is `PermissionRequest`, which fires before Codex asks for approval. Turn completion uses `Stop`.

- `PermissionRequest` runs `~/.codex/hooks/attention-sound.sh permission` and plays `~/.claude/notification.mp3` when available, falling back to the macOS `Pop.aiff` sound.
- `Stop` runs `~/.codex/hooks/attention-sound.sh stop` and plays the macOS `Glass.aiff` sound.
- Native TUI notifications are also enabled through `tui.notifications = true`, `tui.notification_condition = "always"`, and `tui.notification_method = "auto"`.

:::note
Restart Codex after changing hooks. If Codex prompts to trust hooks for a workspace, accept the trust prompt before expecting hook execution.
:::

## Feature Checks

```bash
codex features list
codex mcp list
miudb connections list --output json
codex plugin list
codex doctor --summary --ascii
```

If `/goal` is missing from slash commands, check:

```bash
codex features list | rg '^goals'
```

Expected state:

```text
goals  stable  true
```

Restart Codex after changing feature flags because TUI command availability is loaded at startup.

## CLI Proxy API key (Desktop vs CLI)

Custom provider `cli_proxy` reads `CLI_PROXY_API_KEY` from the **process environment** (`env_key` in `config.toml`). Codex CLI inherits your shell exports; **Codex Desktop** (ChatGPT.app launched from Dock/Spotlight) does not.

macOS-only LaunchAgent `local.cli-proxy-gui-env` bridges that gap:

1. Stow packages: `make stow-bin stow-launchd`
2. Load the agent (once after install or login):

```bash
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/local.cli-proxy-gui-env.plist" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/local.cli-proxy-gui-env.plist"
launchctl kickstart -k "gui/$(id -u)/local.cli-proxy-gui-env"
```

3. Fully quit and reopen ChatGPT/Codex Desktop.

The agent runs `~/.local/bin/set-cli-proxy-gui-env.sh`, which reads the key from gopass (`personal/saas/cli-proxy/code-01-api-key` by default, overridable with `CLI_PROXY_GOPASS_PATH`) and runs `launchctl setenv CLI_PROXY_API_KEY ...`. It no-ops once the var is set, and retries every 5 minutes if gopass was locked at login.

Verify:

```bash
launchctl getenv CLI_PROXY_API_KEY | wc -c   # non-zero length
tail -5 "${XDG_STATE_HOME:-$HOME/.local/state}/cli-proxy-gui-env.log"
```

Manual one-shot without waiting for the agent:

```bash
"$HOME/.local/bin/set-cli-proxy-gui-env.sh"
```

## Local State

Only `config.toml` and hook scripts under `~/.codex/hooks/` are repo-managed.

:::danger
Do not commit `~/.codex/auth.json`, account files, SQLite databases, history, logs, generated images, model caches, or temporary plugin snapshots.
:::
