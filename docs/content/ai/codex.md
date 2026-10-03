---
title: "Codex"
---

Codex CLI configuration is managed from this repository with GNU Stow.

## Install

```bash
make stow-codex
```

This links `dotfiles/codex/.codex/config.toml`, `cliproxy.config.toml`, and `cliproxy-muse.config.toml` into `~/.codex/`, along with the managed attention-sound hook.

## Managed Settings

- High reasoning effort and pragmatic personality. The managed config does not pin `model` or `model_provider`, so Codex keeps the ChatGPT account default.
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

The other commands in `hooks.json` use Python scripts installed separately under `~/.codex/hooks/`. After changing a hook command, review it in Codex with `/hooks`. Codex skips changed hooks until they are trusted.

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

## CLI Proxy

### Select a CLI Proxy model

The base config keeps ChatGPT OAuth as the default. The single `cliproxy` profile selects the `cli_proxy` provider and defaults to Grok 4.7 with high effort. Override the model with `-m` and effort with lowercase `-c`. Uppercase `-C` sets the working directory.

```bash
codex -p cliproxy -m claude-opus-5-5 -c model_reasoning_effort='"high"'
```

Use these exact gateway model IDs for the requested choices:

| Model | ID | Effort |
| --- | --- | --- |
| Grok 4.7 | `grok-4.7` | `high` |
| Opus 5.5 | `claude-opus-5-5` | `high` |
| Sonnet 5.5 | `claude-sonnet-5-5` | `medium` |
| GLM 5.3 | `glm-5.3` | `high` |
| Muse Spark 1.3 Contributor | `muse-spark-1.3-contributor` | `high` |
| Sol 6.1 | `gpt-6.1-sol` | `high` |
| Astra 6 | `gpt-6-astra` | `high` |

For Muse Contributor, add `--disable apps` because the gateway rejects Codex's Apps tool schema for that model:

```bash
codex -p cliproxy -m muse-spark-1.3-contributor -c model_reasoning_effort='"high"' --disable apps
```

The `cliproxy-muse` profile does the same without the flag, for launchers that cannot pass it, such as OpenRig seats: `codex -p cliproxy-muse`.

For a single non-interactive prompt, use `codex exec -p cliproxy -m claude-opus-5-5 -c model_reasoning_effort='"high"' 'Summarize this repository'`.

Pi's `cliproxyapi` and Codex's `cli_proxy` use the same gateway model IDs, but their local model lists are independent. Pi currently lists six of the seven IDs above; it does not list `claude-sonnet-5-5`.

In Codex CLI 0.160.0, `/model` shows the bundled GPT catalog, not the proxy's full model list. It can also save a selected GPT model into the symlinked profile. Use `-m` to choose a proxy model explicitly.

### Resume a stopped session with another model

Run these from the same project directory as the saved session:

```bash
codex resume -p cliproxy -m claude-sonnet-5-5 -c model_reasoning_effort='"medium"' --last
codex resume -p cliproxy -m gpt-6-astra -c model_reasoning_effort='"high"' "<session-id>"
```

`--last` resumes the most recent session in the current directory. Use a session ID to select a specific conversation, or run `codex resume -p cliproxy -m claude-opus-5-5` to pick one. Add `--all` to the picker if the session was started in another directory. Codex prints the session ID when you exit. After an interrupted turn, tell the new model what work to continue. [Codex resume reference](https://learn.chatgpt.com/docs/developer-commands)

This keeps the saved conversation while changing the model for the next turn. A Grok to Sonnet switch and a Sonnet to Sol switch both kept context in CLI 0.160.0. All models in this profile share the same CLI Proxy gateway, so a gateway outage or provider-wide quota limit affects them all. Switching a CLI Proxy session to ChatGPT OAuth failed in a local test with `invalid_encrypted_content`; [Codex tracks this cross-provider history issue](https://github.com/openai/codex/issues/17541). Keep the saved session and retry when the gateway is available.

If Claude returns `not supported when using Codex with a ChatGPT account`, Codex selected the default `openai` provider. Add `-p cliproxy` and check that `CLI_PROXY_API_KEY` is set. Codex reads the key from the environment; it does not store the key in the profile. [Codex configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)

The profile pins `model_provider = "cli_proxy"`. An invalid proxy key returned HTTP 401 in a live test, without falling back to ChatGPT OAuth.

Effort support depends on the model and gateway. Start with `low`, `medium`, or `high`. Try `xhigh` or `max` only when the model supports them.

The CLI Proxy `/v1/models` endpoint returned these 57 IDs on 2026-10-04:

| Family | Model IDs |
| --- | --- |
| Claude | `claude-3-5-haiku-20241022`, `claude-3-7-sonnet-20250219`, `claude-fable-5`, `claude-fable-5-1`, `claude-haiku-4-5-20251001`, `claude-opus-4-1-20250805`, `claude-opus-4-20250514`, `claude-opus-4-5-20251101`, `claude-opus-4-6`, `claude-opus-4-7`, `claude-opus-4-8`, `claude-opus-5`, `claude-opus-5-5`, `claude-sonnet-4-20250514`, `claude-sonnet-4-5-20250929`, `claude-sonnet-4-6`, `claude-sonnet-5`, `claude-sonnet-5-5` |
| GLM | `glm-5.2`, `glm-5.3` |
| GPT | `gpt-5.5`, `gpt-5.6-luna`, `gpt-5.6-sol`, `gpt-5.6-terra`, `gpt-6-astra`, `gpt-6-luna`, `gpt-6-sol`, `gpt-6.1-sol` |
| Grok | `grok-3-mini`, `grok-3-mini-fast`, `grok-4.20-0309-non-reasoning`, `grok-4.20-0309-reasoning`, `grok-4.20-multi-agent-0309`, `grok-4.3`, `grok-4.5`, `grok-4.6`, `grok-4.7`, `grok-4.7-build-fast`, `grok-build-0.1`, `grok-composer-2.5-fast` |
| Muse | `muse-spark-1.1`, `muse-spark-1.2`, `muse-spark-1.2-contributor`, `muse-spark-1.3`, `muse-spark-1.3-contributor` |
| Specialized | `codex-auto-review`, `gpt-image-1.5`, `gpt-image-2`, `gpt-image-2.5`, `gpt-image-2.5-flare`, `gpt-image-2.5-sunburst`, `grok-imagine-image`, `grok-imagine-image-2.0`, `grok-imagine-image-quality`, `grok-imagine-video`, `grok-imagine-video-1.5`, `grok-imagine-video-1.5-preview` |

The endpoint lists availability, not Codex compatibility or supported effort levels. Image, video, and `codex-auto-review` IDs are specialized models, not general Codex chat choices. Use the CLIProxyAPI key and URL to check the current catalog:

```bash
curl -fsS -H "Authorization: Bearer ${CLI_PROXY_API_KEY:?Set CLI_PROXY_API_KEY}" "${CLI_PROXY_BASE_URL:?Set CLI_PROXY_BASE_URL}/v1/models" | jq -r '.data[].id' | sort
```

### API key for Desktop

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

After rotating the gopass secret, refresh the GUI session value (no reboot):

```bash
"$HOME/.local/bin/set-cli-proxy-gui-env.sh" refresh
# or clear it:
"$HOME/.local/bin/set-cli-proxy-gui-env.sh" unset
# launchctl unsetenv CLI_PROXY_API_KEY
```

Then fully quit and reopen ChatGPT/Codex Desktop.

## Local State

The base config, `cliproxy.config.toml`, `hooks.json`, `hooks/attention-sound.sh`, and `bin/node-repl-mcp.sh` are repo-managed.

:::danger
Do not commit `~/.codex/auth.json`, account files, SQLite databases, history, logs, generated images, model caches, or temporary plugin snapshots.
:::
