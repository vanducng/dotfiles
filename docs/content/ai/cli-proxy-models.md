---
title: "CLI Proxy model status"
---

Last checked: 2026-10-05. Refresh this page by invoking `/cli-proxy-models` from the dotfiles repo.

Chat ids are probed with `ccx <id> -p` and tools turned off. Image ids use `POST /v1/images/generations`. Video ids use `POST /v1/videos/generations`. A returned request id counts as accepted, and the file is not downloaded. The API key stays in the environment.

40 chat models returned text through `ccx`. 5 are still listed and fail upstream. 1 returned text from the gateway and printed blank in `ccx`. 8 image models returned an image. 3 video models accepted a job.

## Chat

### Claude

`claude-fable-5`, `claude-fable-5-1`, `claude-haiku-4-5-20251001`, `claude-opus-4-5-20251101`, `claude-opus-4-6`, `claude-opus-4-7`, `claude-opus-4-8`, `claude-opus-5`, `claude-opus-5-5`, `claude-sonnet-4-5-20250929`, `claude-sonnet-4-6`, `claude-sonnet-5`, `claude-sonnet-5-5`

### GPT

`gpt-5.5`, `gpt-5.6-luna`, `gpt-5.6-sol`, `gpt-5.6-terra`, `gpt-6-astra`, `gpt-6-luna`, `gpt-6-sol`, `gpt-6.1-sol`

### GLM

`glm-5.2`, `glm-5.3`

### Grok

`grok-3-mini`, `grok-3-mini-fast`, `grok-4.20-0309-non-reasoning`, `grok-4.20-0309-reasoning`, `grok-4.3`, `grok-4.5`, `grok-4.6`, `grok-4.7`, `grok-4.7-build-fast`, `grok-build-0.1`, `grok-composer-2.5-fast`

### Muse

`muse-spark-1.1`, `muse-spark-1.2`, `muse-spark-1.2-contributor`, `muse-spark-1.3`, `muse-spark-1.3-contributor`

### Other

`codex-auto-review`

### Gaps

| ID | Status | Detail |
| --- | --- | --- |
| `claude-3-5-haiku-20241022` | missing | Retired 2026-02-19. Upstream model not found. |
| `claude-3-7-sonnet-20250219` | missing | Retired 2026-02-19. Upstream model not found. |
| `claude-opus-4-1-20250805` | missing | Upstream model not found. |
| `claude-opus-4-20250514` | missing | Upstream model not found. |
| `claude-sonnet-4-20250514` | missing | Retired 2026-06-15. Upstream model not found. |
| `grok-4.20-multi-agent-0309` | blank | Gateway returned text. ccx printed a blank line. |

## Images

`gpt-image-1.5`, `gpt-image-2`, `gpt-image-2.5`, `gpt-image-2.5-flare`, `gpt-image-2.5-sunburst`, `grok-imagine-image`, `grok-imagine-image-2.0`, `grok-imagine-image-quality`

## Videos

| ID | Status | Detail |
| --- | --- | --- |
| `grok-imagine-video` | accepted | Accepted. Request id returned. The file was not downloaded. |
| `grok-imagine-video-1.5` | accepted | Accepted. Request id returned. The file was not downloaded. |
| `grok-imagine-video-1.5-preview` | accepted | Accepted. Request id returned. The file was not downloaded. |

## Documented launches

| Command | Status | Reply |
| --- | --- | --- |
| `ccx gpt-6.1-sol --autocompact 272k --effort high` | ok | hi |
| `ccx claude-opus-5-5 --autocompact 1M --effort high` | ok | hi |
| `ccx grok-4.7-build-fast --autocompact 500k --effort high` | ok | hi |
| `ccx glm-5.3 --autocompact 1M --effort high` | ok | hi |
| `ccx muse-spark-1.3-contributor --autocompact 1M --effort high` | ok | hi |
