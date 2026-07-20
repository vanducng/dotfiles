# Global Agent Instructions

## Writing

- Never use the em dash character. Use plain dash "-" instead.
- Keep status updates, PR descriptions, review summaries, tickets, and operational messages concise, factual, and action-oriented. Lead with the outcome, blocker, or next action.

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
