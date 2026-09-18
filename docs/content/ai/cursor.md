---
title: "Cursor Agent CLI"
---

Cursor Agent CLI configuration is managed from this repository with GNU Stow.

## Install

```bash
make stow-cursor
```

This links `dotfiles/cursor/.cursor/cli-config.json` to `~/.cursor/cli-config.json`.

:::note
If `~/.cursor/cli-config.json` already exists as a real file, back it up before the first stow so Stow can create the symlink.
:::

## Managed Settings

- Commit and PR attribution are **off** (`attribution.attributeCommitsToAgent` / `attributePRsToAgent` both `false`), so local Agent CLI commits and PRs do not get Cursor co-author trailers or "Made with Cursor" footers.
- Display defaults to zen mode with line numbers, thinking blocks, and status indicators off.
- Terminal notifications, hints, model slash commands, and `/rewind` are on.
- Explore subagent model stays on Cursor's default (`exploreSubagentModel: "default"`).
- Network stays on HTTP/2 for agent connections (`useHttp1ForAgent: false`). Flip to `true` only if a corporate proxy requires HTTP/1.1 SSE.
- Permissions start minimal (`Shell(ls)` allow). Expand `permissions.allow` / `deny` as needed; project overrides can also live in `.cursor/cli.json`.

## Local State (Do Not Stow)

Keep these local under `~/.cursor/` and out of the repo:

- `authInfo` / login cache (CLI may rewrite into `cli-config.json` at runtime)
- `mcp.json` when it holds tokens
- `ide_state.json`, `agent-cli-state.json`, extensions, projects, plans, worktrees

:::danger
Do not commit `authInfo`, `privacyCache`, API tokens, or the full live `~/.cursor/mcp.json` if it contains secrets. Add only non-secret MCP entries (for example `miudb`) to an existing local `mcpServers` object.
:::

## IDE Attribution

CLI attribution is separate from the Cursor IDE toggle. In the app: **Settings → Git & PRs → Attribution** (or **Agents → Attribution** on older builds) and turn off Commit Attribution and PR Attribution.

Cloud / background agents use a different path and may still author as Cursor; that is not controlled by `cli-config.json`.

## Checks

```bash
make stow-cursor
./scripts/ci/test-cursor-config.sh
```

Confirm the live file is the stow symlink and attribution stays off:

```bash
readlink ~/.cursor/cli-config.json
jq '.attribution' ~/.cursor/cli-config.json
```

Expected:

```json
{
  "attributeCommitsToAgent": false,
  "attributePRsToAgent": false
}
```
