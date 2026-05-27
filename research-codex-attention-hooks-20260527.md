# Research: Codex Attention Hooks

_Date: 2026-05-27 - Mode: deep - Sources: 3 official OpenAI docs + local Codex CLI/schema checks_

## TL;DR

- **Recommendation:** Use Codex native `PermissionRequest` and `Stop` command hooks backed by a small `afplay` script, plus native TUI notifications set to `always`.
- **Runner-up:** Native TUI notifications only - acceptable if terminal-level notifications are enough and sound choice does not matter.
- **Avoid:** Claude-style `Notification` hook syntax in Codex - Codex does not expose that event, and the old `[[hooks]] event = "..."` examples are stale.

## The Question

How should this dotfiles repo configure Codex so it plays attention sounds when Codex needs the user, while also enabling Vim mode and a better status bar?

## Decision Context

The workflow already uses Claude Code settings with Vim mode, Ghostty notifications, push notifications, and sound hooks. Codex should mirror the useful parts where the current Codex config surface supports them, without depending on undocumented session files or stale hook syntax.

## Evaluation Criteria

- **Correctness:** Uses the current Codex hook/config schema.
- **Attention signal quality:** Plays a distinct sound for approval-needed and completion events.
- **Maintainability:** Lives in this dotfiles repo and installs cleanly through GNU Stow.
- **Safety:** Does not auto-approve or deny permission requests; it only notifies.
- **Portability:** Degrades cleanly on macOS if custom sounds are missing.
- **Operational burden:** Requires minimal extra moving parts.
- **Lock-in:** Avoids brittle polling of Codex internals.

## Options Considered

- **Native Codex hooks + TUI notifications:** `PermissionRequest` and `Stop` command hooks run a local script; TUI notifications stay enabled.
- **TUI notifications only:** Let Codex and the terminal handle notifications without custom sound hooks.
- **External watcher/log polling:** Watch Codex logs/session files and infer state transitions.
- **Claude hook syntax parity:** Try to port Claude Code `Notification` hooks directly.

## Comparison Matrix

| Criterion | Native hooks + TUI | TUI only | External watcher | Claude-style hooks |
|---|---|---|---|---|
| Correctness | Uses documented Codex hook events and TUI config. | Uses documented TUI config. | Depends on undocumented runtime state. | Incorrect for Codex today. |
| Attention signal | Strong: distinct approval and completion sounds. | Medium: depends on terminal notification support. | Potentially strong, but inference can be wrong. | None; event is unavailable. |
| Maintainability | Low burden: one stowed script and config. | Lowest burden. | High burden; watchers need session scoping. | High churn; stale syntax breaks. |
| Safety | Safe: no permission decision returned. | Safe. | Risky if it misreads state and spams. | Risky because config may not load as intended. |
| Portability | macOS-focused because it uses `afplay`; falls back between available sounds. | Terminal-dependent. | OS- and Codex-version-dependent. | Not portable to Codex. |
| Lock-in | Low; uses public Codex hooks. | Low; uses public TUI config. | High; tied to private files/logs. | High; tied to a different product's schema. |
| Failure mode | Hook trust not accepted, missing `afplay`, sound file missing. | Terminal does not emit sound/notification. | Missed events, duplicate events, wrong session. | No useful event fires. |

## Per-Option Deep Dive

### Native Codex Hooks + TUI Notifications

**Strengths:** This is the cleanest mapping to Codex's current surface. OpenAI documents `PermissionRequest` as the event that runs when Codex is about to ask for approval, and `Stop` as a turn-stop event. Command hook handlers support `command`, `timeout`, and `statusMessage`, which is enough for a short notification script. The config reference also documents TUI notification controls and Vim-mode startup.

**Weaknesses:** `PermissionRequest` is not a general "Codex is idle and wants the user" event. It only covers approval flows. Hook execution may require trusting hooks for the workspace before they run.

**Dealbreaker:** If the desired behavior is "notify on every possible conversational pause", Codex does not currently expose that exact event. The implementation should not pretend otherwise.

### TUI Notifications Only

**Strengths:** Smallest config surface. `tui.notifications = true`, `tui.notification_method = "auto"`, and `tui.notification_condition = "always"` are documented.

**Weaknesses:** Sound behavior depends on terminal support. It does not provide distinct sounds for approval versus completion.

**Dealbreaker:** Not enough control if the requirement is specific audible cues.

### External Watcher or Log Polling

**Strengths:** Could potentially approximate extra notification events not exposed as hooks.

**Weaknesses:** It would depend on private files, log formats, and session timing. Multiple Codex sessions would need disambiguation.

**Dealbreaker:** Fragile by design. It is not worth adding until Codex exposes no supported primitive for a required event.

### Claude-Style Hook Syntax

**Strengths:** Familiar from the existing Claude settings.

**Weaknesses:** Codex does not expose a `Notification` event in the documented hooks page, and current Codex hook config is section-based, such as `[[hooks.PermissionRequest]]`, not `[[hooks]]` plus `event = "..."`.

**Dealbreaker:** It is not a current Codex config surface.

## Failure Modes

| Option | Mode | Symptom | Mitigation | Recovery cost |
|---|---|---|---|---|
| Native hooks + TUI | Hooks not trusted | No sound on approval/stop | Accept Codex hook trust prompt and restart Codex | Low |
| Native hooks + TUI | Missing custom sound | Approval sound falls back to `Pop.aiff` | Keep fallback in script | Low |
| Native hooks + TUI | macOS audio unavailable | No audible sound | Native TUI notification still fires | Low |
| TUI only | Terminal notification unsupported | No visible/audible cue | Use hook script path | Low |
| External watcher | Wrong session detected | Spurious sounds | Avoid this design | Medium |
| Claude-style hooks | Stale syntax | Hooks do not fire | Replace with Codex section-based hook tables | Low |

## Migration Paths

- **Current dotfiles config -> native hooks:** Add `dotfiles/codex/.codex/hooks/attention-sound.sh`, add `hooks.PermissionRequest` and `hooks.Stop`, then run `make stow-codex`.
- **Claude settings -> Codex equivalent:** Map `editorMode = "vim"` to `tui.vim_mode_default = true`; map Claude Notification hooks to Codex `PermissionRequest` where possible; map turn-complete sounds to `Stop`.
- **Old Codex hook snippets -> current syntax:** Replace `[[hooks]] event = "PostToolUse"` with `[[hooks.PostToolUse]]` plus nested `[[hooks.PostToolUse.hooks]]`.
- **Rollback:** Remove the two hook tables and keep native TUI notifications. No data migration is involved.

## Performance and Operational Notes

The hook command is intentionally short-lived. It consumes hook stdin, starts `afplay` in the background, optionally sends a macOS notification through `osascript`, and exits. Hook timeout is set to 5 seconds to prevent notification tooling from blocking Codex turns.

No `vd-cli` code change is needed for this decision. Current `vd-cli` Codex support manages skill installation paths, while the requested behavior is user-level Codex config and hook scripts managed by dotfiles.

## Implemented Configuration

```toml
[[hooks.PermissionRequest]]
matcher = ".*"

[[hooks.PermissionRequest.hooks]]
type = "command"
command = "bash ~/.codex/hooks/attention-sound.sh permission"
timeout = 5
statusMessage = "Play attention sound"

[[hooks.Stop]]

[[hooks.Stop.hooks]]
type = "command"
command = "bash ~/.codex/hooks/attention-sound.sh stop"
timeout = 5
statusMessage = "Play completion sound"
```

The configured status line is:

```toml
status_line = [
  "run-state",
  "current-dir",
  "git-branch",
  "model-with-reasoning",
  "context-remaining",
  "context-used",
  "task-progress",
]
```

This puts operational state first, then location, branch, model, context budget, and active task progress.

## References

- OpenAI Codex Hooks: https://developers.openai.com/codex/hooks
- OpenAI Codex Config Reference: https://developers.openai.com/codex/config-reference
- OpenAI Codex Config Schema: https://developers.openai.com/codex/config-schema.json

## Open Questions

- Codex does not currently document a direct equivalent to Claude Code's `Notification` event. If OpenAI adds one later, approval-needed and idle/user-question sounds can be split more precisely.
- The exact visual rendering of extra `status_line` identifiers is TUI-version-dependent. `codex --strict-config doctor` accepts the config, but the final visual layout should be judged in an interactive Codex session after restart.
