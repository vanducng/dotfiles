---
title: "oh-my-dsh"
---

oh-my-dsh (`omdsh`) shares the official DeepSeek Harness user document at `~/.dsh/settings.yaml`. This repository manages that file with GNU Stow. Sessions, credentials, profiles, and TUI cache stay local.

## Install

```bash
make stow-dsh
```

This links `dotfiles/dsh/.dsh/settings.yaml` to `~/.dsh/settings.yaml`. If a real file already exists, back it up first so Stow can create the symlink.

```bash
mv ~/.dsh/settings.yaml ~/.dsh/settings.yaml.bak
make stow-dsh
```

## Managed providers

- Default route stays `deepseek-official` / `deepseek-v4-flash` with high reasoning effort.
- `cliproxyapi` is the same CLI Proxy gateway used by pi: `openai-responses` at `https://cli-proxy.dataplanelabs.com/v1`, authenticated by `CLI_PROXY_API_KEY`.
- Daily-driver models on that gateway include `grok-4.6`, GPT 5.6 Sol/Terra/Luna, Claude Sonnet/Opus, and Haiku.
- Reasoning pickers follow the vendor wire set: Grok 4.6 exposes `xhigh` but not `max`; GPT 5.6 and Claude Opus 4.7/4.8/5 expose both `xhigh` and `max`; GPT 5.4/5.5 expose `xhigh`; older Grok/Claude/Codex routes stop at `high`.
- `zai-coding-cn` remains the catalog Z.AI Coding route, authenticated by `ZAI_CODING_CN_API_KEY`.

Secrets stay in the environment or `~/.dsh/.credentials.yaml`. The managed file only stores `apiKeyEnv` references.

## Use a provider

Custom routes require an omdsh build that mounts `@deepseek-ai/dsh-llm-pi-ai`. Then:

```bash
omdsh --provider cliproxyapi --model grok-4.6
```

Inside the TUI, `/model` lists every registered provider. `/login` remains DeepSeek-only.

## Checks

```bash
./scripts/ci/test-dsh-config.sh
```
