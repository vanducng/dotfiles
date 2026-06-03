# AI Tools

Guide to using AI tools effectively in your development workflow.

## Tool Overview

| Feature | CodeCompanion | Supermaven | Database AI |
|---------|---------------|-----------|-------------|
| **Type** | Chat + Inline | Completion | SQL-specific |
| **API** | Google Gemini | Proprietary | Built-in miudb |
| **Strength** | Complex problems | Real-time coding | SQL queries |
| **Best For** | Architecture, debugging | Day-to-day coding | Database work |
| **Keybindings** | Leader-based | Auto-trigger | Context-aware |

## Codex CLI

Codex is managed from this dotfiles repo through GNU Stow. See **[Codex](codex.md)** for the repo-owned `~/.codex/config.toml`, enabled features, `/goal` troubleshooting, MCP setup, and plugin checks.

## Quick Start

```bash
# CodeCompanion (Chat with Gemini)
<leader>ac  # Open AI chat
<leader>aa  # AI actions menu
<leader>ar  # Code review
<leader>af  # Quick fixes

# Supermaven (Completion - auto-triggers)
# Just start typing, suggestions appear automatically
# Tab to accept, Ctrl+] to dismiss
```

## Documentation

<div class="dt-card-grid" markdown>
<div class="dt-card" markdown>

### [Codex](codex.md)

CLI config, features, goals, MCP, and plugin checks for the Codex terminal agent.

</div>
<div class="dt-card" markdown>

### [Workflows](workflows.md)

Daily AI workflows: code development, database AI, and common patterns.

</div>
<div class="dt-card" markdown>

### [Best Practices](best-practices.md)

Effective prompting, security guidance, and productivity tips.

</div>
</div>
