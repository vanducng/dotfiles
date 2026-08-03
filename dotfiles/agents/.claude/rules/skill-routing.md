# Skill Routing

Only the routings that aren't obvious from a skill's own description. Everything
else: read the skill list.

## Workflow sequences

```
feature   plan → cook → test → code-review → ship → journal
bugfix    scout → debug → fix → test → code-review
explore   scout → debug → brainstorm → plan
```

| Intent | Start with |
|---|---|
| "implement X", "build X", "add X" | `plan`, then `cook` |
| "execute this plan" | `cook <plan-path>` |
| "X is broken", "CI is failing", "bug in X" | `fix` (scouts internally) |
| "why does X happen" | `scout`, then `debug` |
| "explore options for X" | `brainstorm`, then `plan` |
| parallel work on a shared repo | `worktree` first |

## Non-obvious picks

These are the cases where two skills look interchangeable but aren't.

| Situation | Skill | Not |
|---|---|---|
| Replicate a mockup / screenshot / video | `frontend-design` | `uiuxdesign` |
| Design-quality scoring, a11y audit, design system | `uiuxdesign` | `frontend-design` |
| Locate files, models, IaC, pipelines before editing | `scout` | plain grep |
| Run SQL against a saved connection | `miudb` | `databases` |
| Schema design, indexes, migrations | `dbdesign` | `miudb` |
| E2E a local app with a logged-in session | `web-e2e` | `agent-browser` |
| Scripted browser automation, scraping, recording | `agent-browser` | `web-e2e` |
| Docker / terraform / kubectl / helm / CI pipelines | `devops` | `deploy` |
| Push to Vercel / Netlify / Railway / Fly | `deploy` | `devops` |
| STRIDE / OWASP audit with fixes | `security` | `security-scan` |
| Secret and dependency scanning | `security-scan` | `security` |
| Terminal-friendly ASCII diagram | `text-diagram` | `diagram` |
| Rendered diagram image (PNG/SVG) | `diagram` | `text-diagram` |
| Library / framework API docs | `docs-seeker` | web search |
| Update this project's own docs | `docs` | `docs-seeker` |
| Generate or analyze image / audio / video | `omnimedia` | `media-processing` |
| FFmpeg / ImageMagick transforms | `media-processing` | `omnimedia` |

## After implementing

`code-review` before merging · `ship` to land it · `journal` while context is fresh.
