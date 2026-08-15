---
title: "AI Tools Troubleshooting"
---

## Codex CLI

### Desktop: `Missing environment variable: CLI_PROXY_API_KEY`

Codex CLI works but Desktop fails when the key is only exported in the shell. GUI apps do not load `~/.zshrc`.

macOS fix (stow-managed LaunchAgent):

```bash
make stow-bin stow-launchd
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/local.cli-proxy-gui-env.plist" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/local.cli-proxy-gui-env.plist"
launchctl kickstart -k "gui/$(id -u)/local.cli-proxy-gui-env"
# Fully quit ChatGPT.app (Cmd+Q), then reopen
launchctl getenv CLI_PROXY_API_KEY | wc -c
```

If the log shows gopass failures, unlock gpg once (`gopass show personal/saas/cli-proxy/code-01-api-key`) and re-run `kickstart`.

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

Check the `miudb` MCP command exposed by the CLI:

```bash
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
