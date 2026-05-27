# Codex

Codex CLI configuration is managed from this repository with GNU Stow.

## Install

```bash
make stow-codex
```

This links `dotfiles/codex/.codex/config.toml` to `~/.codex/config.toml`.

## Managed Settings

- `model = "gpt-5.5"` with high reasoning effort and pragmatic personality.
- `web_search = "cached"` for default web access with lower live-page prompt-injection exposure.
- `/goal` is pinned on with `features.goals = true`.
- Agent workflow features are pinned on, including multi-agent tools, hooks, shell snapshots, workspace dependencies, browser use, computer use, image generation, and plugin support.
- OpenAI developer docs MCP is configured as `openaiDeveloperDocs`.
- Current Codex plugins for Browser, GitHub, Documents, Spreadsheets, and Presentations stay enabled.

## Feature Checks

```bash
codex features list
codex mcp list
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

Only `config.toml` is repo-managed. Do not commit `~/.codex/auth.json`, account files, SQLite databases, history, logs, generated images, model caches, or temporary plugin snapshots.
