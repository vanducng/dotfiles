---
title: "Claude Code via CLI Proxy"
---

`ccx` runs one Claude Code session through the CLI Proxy gateway. Plain `claude` keeps the logged-in Claude user.

The command lives at `dotfiles/bin/.local/bin/ccx` and is stowed to `~/.local/bin/ccx`.

## Install

```bash
make stow-bin
```

`CLI_PROXY_API_KEY` must already be set in the shell. `CLI_PROXY_BASE_URL` is optional. When it is set and ends in `/v1`, `ccx` strips that suffix, because Claude Code appends `/v1/messages` itself. The default host is `https://cli-proxy.dataplanelabs.com`.

## Usage

```bash
ccx <model-id> [claude args...]
```

`ccx` always passes `--dangerously-skip-permissions`. Add `--effort` and `--autocompact` for that model. Extra arguments are forwarded to `claude`.

An empty `ANTHROPIC_BASE_URL` in `~/.claude/settings.json` overrides the process environment. Claude then sends the proxy token to Anthropic and returns `401 Invalid bearer token`. `ccx` pins the proxy host with `--settings`, so that empty value does not apply. Leave the empty entry in place when plain `claude` should ignore an ambient base URL.

Every Claude Code tier for that process, including subagents, uses the model id you pass. Check `/status` inside the session. It should show the proxy base URL.

Start a new session for a proxy model. Resume a proxy session with `ccx <model-id> --continue` from the same directory.

## Examples

Windows below are the vendor input limits already used for compaction on this gateway. `--autocompact` accepts `100k` through `1M`.

| Family | Model | ID | Window | Effort |
| --- | --- | --- | --- | --- |
| GPT | Sol 6.1 | `gpt-6.1-sol` | 272k | `high` |
| Opus | Opus 5.5 | `claude-opus-5-5` | 1M | `high` |
| Grok | Grok 4.7 Fast | `grok-4.7-build-fast` | 500k | `high` |
| GLM | GLM 5.3 | `glm-5.3` | 1M | `high` |
| Muse | Muse Spark 1.3 Contributor | `muse-spark-1.3-contributor` | 1M | `high` |

```bash
ccx gpt-6.1-sol --autocompact 272k --effort high
ccx claude-opus-5-5 --autocompact 1M --effort high
ccx grok-4.7-build-fast --autocompact 500k --effort high
ccx glm-5.3 --autocompact 1M --effort high
ccx muse-spark-1.3-contributor --autocompact 1M --effort high
```

`grok-4.7` is the same 500k model at normal speed. Grok 4.7 also accepts `xhigh`. GLM 5.3 accepts `low`, `high`, and `max`, and reasoning stays on. Opus 5.5 and Sol 6.1 also accept `xhigh` and `max`.

Other catalog ids work the same way. List the live set with:

```bash
curl -fsS -H "Authorization: Bearer ${CLI_PROXY_API_KEY:?Set CLI_PROXY_API_KEY}" \
  "${CLI_PROXY_BASE_URL:?Set CLI_PROXY_BASE_URL}/v1/models" | jq -r '.data[].id' | sort
```

## Checks

```bash
./scripts/ci/test-ccx.sh
```
