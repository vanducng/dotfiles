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

- `model = "gpt-5.5"` with high reasoning effort and pragmatic personality.
- `web_search = "cached"` for default web access with lower live-page prompt-injection exposure.
- `/goal` is pinned on with `features.goals = true`.
- Agent workflow features are pinned on, including multi-agent tools, hooks, shell snapshots, workspace dependencies, browser use, computer use, image generation, and plugin support.
- TUI Vim mode starts enabled with `tui.vim_mode_default = true`.
- TUI notifications are enabled and set to fire even when the terminal is focused.
- The status line is ordered for workflow state first: run state, current directory, git branch, model/reasoning, context remaining, context used, and task progress.
- The terminal title shows activity, project, and model.
- Sound hooks play on approval requests and turn completion.
- OpenAI developer docs MCP is configured as `openaiDeveloperDocs`.
- miudb MCP is configured as `miudb` for local database inventory, schema inspection, and bounded read-only SQL.
- Current Codex plugins for Browser, GitHub, Documents, Spreadsheets, and Presentations stay enabled.

## miudb MCP

`miudb mcp serve --transport stdio` works with any stdio MCP host. It reads saved database connections from `~/.config/miu/db`, redacts secrets, and keeps `query_run` read-only by default.

Codex is managed in `dotfiles/codex/.codex/config.toml`:

```toml
[mcp_servers.miudb]
command = "miudb"
args = ["mcp", "serve", "--transport", "stdio"]
startup_timeout_sec = 10
tool_timeout_sec = 60
```

Claude Code should be installed at user scope so it is available in every project:

```bash
claude mcp add --scope user --transport stdio miudb -- miudb mcp serve --transport stdio
```

Cursor uses `~/.cursor/mcp.json`. Do not commit the full live file if it contains existing tokens. Add only this server entry to the existing `mcpServers` object:

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

Restart Codex after changing hooks. If Codex prompts to trust hooks for a workspace, accept the trust prompt before expecting hook execution.

## Feature Checks

```bash
codex features list
codex mcp list
claude mcp get miudb
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

## Local State

Only `config.toml` and hook scripts under `~/.codex/hooks/` are repo-managed. Do not commit `~/.codex/auth.json`, account files, SQLite databases, history, logs, generated images, model caches, or temporary plugin snapshots.
