---
title: "AI Tools Troubleshooting"
---

## Codex CLI

### `/goal` Not Visible

```bash
codex features list | rg '^goals'
```

The expected state is `stable true`. If it is false, reinstall the repo-managed config and restart Codex:

```bash
make stow-codex
codex features enable goals
```

The dotfiles config also pins `features.goals = true` directly in `~/.codex/config.toml`.

### Config Health

```bash
codex doctor --summary --ascii
codex mcp list
codex plugin list
```

Only `~/.codex/config.toml` is managed by this repo. Auth files, history, SQLite state, logs, and caches should remain local.

### miudb MCP

Check the shared `miudb` MCP entry from each host:

```bash
codex mcp list | rg miudb
claude mcp get miudb
miudb describe mcp serve --output json
```

Cursor reads the same server from `~/.cursor/mcp.json`.

:::caution
Keep `~/.cursor/mcp.json` local-only — existing MCP server entries may carry tokens. The `miudb` entry should be:
:::

```json
{
  "command": "miudb",
  "args": ["mcp", "serve", "--transport", "stdio"]
}
```

## CodeCompanion Issues

### API Key Problems
```bash
# Check Gemini API key
echo $GEMINI_API_KEY

# Set API key temporarily
:lua vim.env.GEMINI_API_KEY = "your-key-here"
```

### Chat Not Responding
```bash
# Check network
ping generativelanguage.googleapis.com

# Restart CodeCompanion
:CodeCompanion reset
```

## Supermaven Issues

### Suggestions Not Appearing
```bash
# Check if Supermaven is running (auto-starts)
# Try restarting Neovim

# Ensure not in a large file (>100KB can disable AI)
```

### Performance Issues
```bash
# Supermaven uses proprietary model
# Check system resources
# Large files may slow suggestions
```

## Database (miudb) Issues

### Connection Failures
```bash
# List saved connections
:MiuDBConnections

# Select active connection
:MiuDBSelectConnection

# Check miudb CLI directly
miudb connections list --output json
```

### Query Problems
```bash
# Run from Neovim
:MiuDBQuery

# Run from shell for debugging
miudb query run --connection <name> --sql 'select 1 as one' --output json
```
