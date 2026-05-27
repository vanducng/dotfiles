# Research: Codex Config Management From Dotfiles

_Date: 2026-05-27 - Mode: deep - Queries: 6_

## TL;DR

- **Recommendation:** Manage `~/.codex/config.toml` as a normal GNU Stow package in this dotfiles repo, because this matches the repository's existing install model and keeps the editable Codex surface explicit.
- **Runner-up:** A generated/merge script that patches `~/.codex/config.toml` wins if Codex starts writing high-churn state into the same file or if this config must become portable across multiple usernames and machines.
- **Avoid:** Managing the whole `~/.codex` directory, because it contains auth, accounts, history, logs, SQLite state, generated images, caches, and temporary plugin snapshots.

## The Question

Add repo-managed Codex configuration that fits this dotfiles workflow and enables missing workflow features such as `/goal`.

## Evaluation Criteria

- **Safety:** Do not commit auth, account files, logs, history, SQLite state, or generated artifacts.
- **Operability:** Preserve the current Codex CLI workflow: GPT-5.5, high reasoning, pragmatic style, plugins, MCP, browser/document/GitHub tooling, and goals.
- **Stow fit:** Use the repo's existing `dotfiles/<tool>/...` layout and `make stow-<tool>` targets.
- **Upgrade tolerance:** Avoid removed flags and prefer current `codex features list` plus official config docs.
- **Reversibility:** Make it easy to back out to a local `~/.codex/config.toml`.
- **Portability:** Keep the repo usable on a future machine, while accepting this is a personal macOS dotfiles repo with some absolute paths.

## Options Considered

- **Stow-managed `config.toml`** - Commit `dotfiles/codex/.codex/config.toml` and add `codex` to `STOW_FOLDERS`.
- **Merge script** - Commit a desired-state TOML fragment and run a script to patch the live config.
- **Imperative CLI setup** - Document `codex features enable ...`, `codex mcp add ...`, and plugin commands without owning the config file.

## Comparison Matrix

| Criterion | Stow-managed config | Merge script | Imperative CLI setup |
|---|---|---|---|
| Safety | Good if only `config.toml` is stowed; dangerous if expanding to whole `.codex`. | Good; can explicitly preserve local state. | Good; almost nothing committed. |
| Operability | Best for this repo because active settings are visible in one file. | Good, but generated state is less transparent. | Weak; drift is likely and `/goal` can silently disappear. |
| Stow fit | Excellent; matches the Makefile and install docs. | Medium; adds a different management path. | Weak; bypasses the repo's core workflow. |
| Upgrade tolerance | Good if stale flags are pruned; strict config can catch issues. | Best if the script validates against current CLI before writing. | Weak; state depends on command history. |
| Reversibility | Good: unstow and restore backup. | Good: keep a backup before patching. | Good, but there is no reproducible target state. |
| Portability | Medium because plugin marketplace roots are machine-local. | Best for multi-host config if templated. | Medium; commands must be rerun manually. |
| Dealbreaker | Can overwrite local project trust entries unless curated. | More code to maintain for one TOML file. | Not actually dotfile-managed. |

## Per-Option Deep Dive

### Stow-managed `config.toml`

- **Strengths:** Native to this repo; easy to review; `make stow-codex` is consistent with the rest of the dotfiles.
- **Weaknesses:** Codex may update `config.toml` for feature toggles, plugin state, or trusted projects, which means live changes become git diffs.
- **Dealbreaker:** Do not use this approach for the entire `~/.codex` directory.
- **Recent evidence:** OpenAI docs define `~/.codex/config.toml` as the user config and document `[features]` toggles, `web_search`, MCP, and plugin-related config. The local CLI is `codex-cli 0.134.0`, and `codex features list` reports `goals` as stable.

### Merge Script

- **Strengths:** Handles local-only project trust entries and machine-specific marketplace paths cleanly.
- **Weaknesses:** Adds a custom TOML merge tool for one config file; shell-based TOML mutation is brittle unless backed by a parser.
- **Dealbreaker:** Overkill unless multiple machines start needing different config overlays.
- **Recent evidence:** Codex supports `-c key=value`, `--enable`, `--disable`, and `codex features enable`, so imperative mutation is supported, but it still writes to the same config surface.

### Imperative CLI Setup

- **Strengths:** Lowest file-management risk; uses first-party commands.
- **Weaknesses:** Not reproducible from the repo; config drift is invisible in review.
- **Dealbreaker:** Fails the user's request to manage Codex config from this dotfiles repo.
- **Recent evidence:** OpenAI documents feature enabling via `[features]`, `codex --enable`, and direct CLI commands; `/goal` docs explicitly say to add `goals = true` under `[features]` when hidden.

## Failure Modes

| Option | Mode | Symptom | Mitigation | Recovery cost |
|---|---|---|---|---|
| Stow-managed config | Existing live file blocks Stow | `stow` reports a conflict for `.codex/config.toml` | Back up the live file, then run `make stow-codex` | Low |
| Stow-managed config | Machine-local plugin paths missing | Plugins disappear or `codex plugin list` is incomplete | Run `codex plugin marketplace list`, restore marketplace roots, or reinstall plugins | Medium |
| Stow-managed config | Removed feature flag kept | `codex --strict-config` or future startup complains | Prune removed flags; current config removes `steer` | Low |
| Merge script | Bad TOML mutation | Config parse failure | Use Python `tomllib`/`tomli-w` or a real TOML tool, keep backups | Medium |
| Imperative CLI setup | Drift | `/goal` or plugins missing after reinstall | Re-run documented commands | Low but recurring |

## Migration Paths

- **Current unmanaged file -> Stow-managed config:** copy curated settings into `dotfiles/codex/.codex/config.toml`, back up `~/.codex/config.toml`, run `make stow-codex`, then verify with `codex features list`, `codex mcp list`, `codex plugin list`, and `codex doctor`.
- **Stow-managed config -> merge script:** keep the same TOML as desired state, move machine-local sections into a template or patch list, then generate the live file.
- **Stow-managed config -> local-only:** `make unstow-codex`, move the backup or copied config back to `~/.codex/config.toml`.

## Operational War Stories

No public post-mortems were found for Codex config management failures. The operational risk is visible from local state shape: `~/.codex` contains credentials, account registry, history, SQLite state, WAL files, logs, generated images, plugin cache, and model cache. That makes whole-directory sync the wrong boundary.

## Performance Under Realistic Load

The chosen approach does not affect model latency. The performance-relevant flags are `shell_snapshot = true`, `unified_exec = true`, `enable_request_compression = true`, and `fast_mode = true`. These are CLI features rather than app benchmarks; no independent performance benchmark was found for dotfile-managed Codex configuration.

## Decision Reversibility

Stow is reversible because it only owns one symlink. The only meaningful lock-in is Git history containing local project paths and marketplace roots. If that becomes a problem, move those sections to a merge script or machine-local profile.

## Recommendation

Use Stow for `~/.codex/config.toml`, but keep the managed boundary narrow. Pin `features.goals = true`, prune removed flags, configure OpenAI Docs MCP, and preserve the plugin set that supports the current agent workflow. Do not manage auth, history, SQLite, logs, generated images, or caches.

## Implementation Notes

- Add `codex` to `STOW_FOLDERS`.
- Add `dotfiles/codex/.codex/config.toml`.
- Back up the current live file before installing the symlink.
- Validate TOML and Codex health after installing.
- Restart Codex after feature flag changes so slash commands are rebuilt.

## References

- OpenAI Codex config basics: https://developers.openai.com/codex/config-basic
- OpenAI Codex config reference: https://developers.openai.com/codex/config-reference
- OpenAI `/goal` use case and enablement: https://developers.openai.com/codex/use-cases/follow-goals
- OpenAI Docs MCP setup: https://developers.openai.com/learn/docs-mcp
- Local verification: `codex-cli 0.134.0`, `codex features list`, `codex plugin list`, `codex mcp list`

## Open Questions

- Whether plugin marketplace roots should stay in git long term or move to a machine-local bootstrap step.
- Whether project trust entries should stay committed or be generated from a private/local overlay.
- Whether `prevent_idle_sleep = true` should remain on after testing long `/goal` runs on battery.
