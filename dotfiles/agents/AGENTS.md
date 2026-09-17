# Global Agent Instructions

## Writing

- Never use the em dash character. Use plain dash "-" instead.
- Keep status updates, PR descriptions, review summaries, tickets, and operational messages concise, factual, and action-oriented. Lead with the outcome, blocker, or next action.
- Outbound email and chat as Duc, to a coworker: write like him, not a runbook. Short, warm, one or two beats. Match their register. No numbered playbook in a reply unless they asked how to do it. Do not restate an attachment they already have. Ban: "No mistake.", "say the word", "which is expected", "the correct X path", "If you want me to X". If it could be a chatbot closing, cut it.

## Work schedule

Remote. Timezone `Asia/Ho_Chi_Minh` (GMT+7).

- Typical wake: 02:00-03:00.
- Work window: 08:00 through 02:00 next day. Night is leftover or personal platform, not a second daytime.
- US meetings land evening/night GMT+7. Protect afternoon for deep work.
- Structured and calendars: timed blocks with gaps. Do not pack the day. Do not create recurring or subscribed tasks unless asked. Untimed follow-ups go to Structured inbox plus the vault `0 Inbox/Follow-ups.md`.

## Scope and Authority

- Preserve existing user changes and stay within the named repo, branch, and task. Surface unrelated UI, lint, test, or flakiness issues separately; do not silently fix or include them without approval.
- Match the requested operation and authority. Keep reviews and investigations read-only unless asked to modify. Implementation and validation do not authorize merge, production changes, destructive actions, or external messages.

## Engineering

- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For bug fixes, reproduce at the closest realistic boundary before editing, trace affected callers, and fix the shared root cause. Prefer user-facing E2E for product bugs and live data, logs, or runtime evidence for operational and data bugs.
- When end-to-end testing a product, be picky about the UI and aim for pixel perfection.
- Treat lint failures, test failures, and test flakiness as real defects, not background noise.
- Never manually modify `CHANGELOG.md` files or any files marked as auto-generated.

## Delivery and Review

- Ground decisions in the current repo and authoritative live state. Verify the real source, artifact, test output, runtime, data, or deployed version before declaring success.
- When asked to ship or finish, continue through the explicitly authorized endpoint and verify the outcome. Do not stop at local edits or PR creation.
- "hotfix", "ship", and Jira labels do not authorize merge or production deploy. Merge only when the user says merge / land it / merge anyway, or passes `--merge` / `--auto`.
- Never `gh pr merge --admin`. Never bypass required reviews. If merge is blocked on review, stop and ask.
- For read-only reviews, report only confirmed actionable defects ordered by severity, with exact file:line, concrete failure mode, and a one-line fix. Skip style nits and speculation.
- Before merge or the next ship step, refresh the current head, required checks, approvals, and unresolved review threads. Address valid feedback, reply or resolve, then re-check until the authorized gate is reached.
- When writing commit messages, NEVER auto-add your agent name as co-author.

## Agent Orchestration

- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.

## Code Comments

Across ALL projects, default to writing ZERO comments. Add one only when a future reader would be surprised without it (hidden constraint, workaround for a specific bug, non-obvious invariant).

- Never write WHAT comments - names + signature already say what.
- Never reference current task / PR / fix in code - belongs in commit msg / PR description.
- One short line max per comment. No multi-line preambles or docstring paragraphs.
- Exported funcs needing GoDoc: one line, the WHY not the signature restatement.

## Portable Home Paths

- Never hardcode `/Users/<name>/…` or `/home/<name>/…` (or literal usernames) in managed configs, hooks, scripts, stow packages, or shared docs.
- Prefer tool-native vars (`$CODEX_HOME`, `$GROK_HOME`, `$XDG_CONFIG_HOME`), then `$HOME` / `${HOME}`, then relative paths or runtime `expanduser`/`Path.home()`.
- Do not use bare `~` for process-spawned MCP `command`/`cwd` unless the host documents tilde expansion - spawn APIs do not expand tilde. Prefer `/bin/bash -lc '…$HOME/…'` or an expanded form.
- Absolute system paths are fine (`/Applications`, `/usr/bin`, `/opt/homebrew/bin`, `/etc`).
- Before finishing config work, scan the diff for `/Users/` and `/home/` and replace personal home prefixes.
- Full detail: `rules/portable-home-paths.md`.

## Reusable Skill Privacy

- Treat every reusable skill, reference, example, test fixture, and asset as potentially publishable.
- Do not include private repository or organization names, internal URLs or hostnames, customer names, ticket contents, usernames, emails, absolute personal paths, production identifiers, connection names, credentials, secrets, or sensitive business data.
- Use generic placeholders such as `<org>/<repo>`, `<repo-root>`, `<connection>`, `<database>`, and `<internal-host>`.
- Discover private values at runtime from the current repository, environment, or private repo-local configuration. Keep that context out of reusable skill files.
- Before completing a skill change, scan changed skill files for private or sensitive identifiers and replace them with placeholders.
