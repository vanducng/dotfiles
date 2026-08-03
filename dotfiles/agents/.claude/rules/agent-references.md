# Agent References

Detailed protocols live in `~/.claude/references/` and are **not** auto-loaded.
Read the file when its trigger fires — they are too long to keep resident, and
each applies to a minority of sessions.

| Read this | When |
|---|---|
| `references/orchestration-protocol.md` | Spawning subagents: chaining, parallel fan-out, status protocol, context isolation, prompt template |
| `references/team-coordination.md` | Operating as a teammate in an Agent Team (file ownership, messaging, shutdown). No effect on normal sessions |
| `references/documentation-management.md` | Writing project docs, roadmap/changelog updates, or plan/phase files |

## Always applies (do not defer to the reference)

When spawning a subagent, its prompt MUST carry:

1. **Work context** — the git root of the files being changed, which is *not*
   always the cwd.
2. **Reports / Plans paths** — the hook-injected `Reports:` and `Plans:` values
   for that work context. Never construct them by hand.

Subagents get a fresh context: state the task, the exact files, and the
acceptance criteria. Never "continue from where we left off".
