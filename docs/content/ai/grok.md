---
title: "Grok"
---

Grok CLI configuration is managed from this repository with GNU Stow, following the official Grok config and hooks layout under `~/.grok/`.

## Install

```bash
make stow-grok
```

This links:

- `dotfiles/grok/.grok/config.toml` → `~/.grok/config.toml`
- `dotfiles/grok/.grok/hooks/` → `~/.grok/hooks/`

Runtime state stays local and unstowed: `auth.json`, `sessions/`, `marketplace-cache/`, logs, and credentials.

:::note
If `~/.grok/config.toml` already exists as a real file, back it up before the first stow so Stow can create the symlink.
:::

## Managed Settings

- Default model `grok-4.5` with auto permission mode (fewer prompts, deny rules and hooks still apply).
- Vim scrollback navigation on (`vim_mode = true`); prompt stays readline (`simple_mode = true`).
- Attention sounds and Telegram notify fire from native lifecycle hooks (`Stop` / `Notification`).
- Claude/Cursor **skills, rules, agents, and MCPs** stay enabled via `[compat.*]`.
- Claude/Cursor **hooks** are disabled (`hooks = false`) so native `~/.grok/hooks` own lifecycle automation and do not double-fire.
- Extra skill root: `~/skills`.
- Native MCP servers: `miudb`, `playwright` (no secrets in the managed file).

## Hooks

Native hooks live in `~/.grok/hooks/lifecycle.json` (official discovery path: `~/.grok/hooks/*.json`).

| Event | Purpose |
|-------|---------|
| `SessionStart` | `session-init.py`, herdr agent-state |
| `UserPromptSubmit` | herdr pane rename, dev-rules reminder |
| `PreToolUse` | `pr-merge-guard`, `scout-block` (via camelCase adapter), ask-user sound |
| `SubagentStart` | team context + subagent init |
| `Stop` | langfuse trace; Telegram notify only if `AGENT_NOTIFY_STOP=always` (no per-turn sound by default) |
| `SessionEnd` | langfuse trace |
| `Notification` | single sound + Telegram on permission/idle only (not every notification type) |

Grok emits camelCase tool envelopes. `hooks/bin/claude-compat-stdin.py` normalizes them to the Claude Code shape so shared scripts under `~/.claude/hooks` keep working.

## miudb MCP

```toml
[mcp_servers.miudb]
command = "miudb"
args = ["mcp", "serve", "--transport", "stdio"]
enabled = true
```

Secret-bearing servers (for example Atlassian tokens) stay on Claude/Cursor MCP sources so they are not committed into the stow package. Prefer `${ENV_VAR}` expansion if you promote them into `~/.grok/config.toml` later.

## Checks

```bash
make stow-grok
./scripts/ci/test-grok-config.sh
grok inspect
grok mcp list
grok mcp doctor
```

In a Grok session, run `/hooks` to confirm global hooks loaded from `~/.grok/hooks`.

## Local State

Only `config.toml` and `hooks/` under `~/.grok/` are repo-managed.

:::danger
Do not commit `~/.grok/auth.json`, sessions, marketplace caches, MCP credentials, or logs.
:::
