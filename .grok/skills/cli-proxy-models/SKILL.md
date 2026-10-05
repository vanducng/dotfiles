---
name: cli-proxy-models
description: >
  Recheck the CLI Proxy catalog for this dotfiles repo and rewrite the model
  status page. Activates when the user says "update the model catalog",
  "recheck cli proxy models", "which models work", "test all proxy models",
  or invokes /cli-proxy-models. Do not use for Codex profile edits or for
  adding a single ccx example. That stays on the Claude Code page.
metadata:
  short-description: Refresh which CLI Proxy models work
---

# CLI Proxy models

> Rewrite `docs/content/ai/cli-proxy-models.md` from a live probe. That page is the inventory.

## Hard rules

1. Run `python3 .grok/skills/cli-proxy-models/scripts/probe.py` from the repo root. It lists `/v1/models`, probes chat ids through `ccx`, image ids through `/v1/images/generations`, and video ids through `/v1/videos/generations`, then rewrites the status page.
2. Leave `CLI_PROXY_API_KEY` in the environment. Do not print it, log it, or write it into the page.
3. If the script exits 2, `ccx` is sending the proxy token to the wrong host. Fix that before recording the catalog as down.
4. Keep an id that `/v1/models` still lists when the upstream model is missing. Record it as a gap. Do not delete it to make the page look clean.
5. The status page is the only model inventory. Link to it from other docs. Do not paste the tables into this skill.
6. Documented `ccx` examples stay in `docs/content/ai/claude-code.md`. The probe reads those lines and records whether they still answer.
7. Do not commit or open a PR unless the user asks to ship.

## Done when

- The script exits 0 and prints `wrote`.
- The status page date is the probe date, it has `title:` frontmatter, and every live catalog id appears once.
- `python3 .grok/skills/cli-proxy-models/scripts/probe.py --self-test` exits 0.
