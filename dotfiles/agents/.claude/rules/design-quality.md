# Design Quality Defaults

Applies to any substantive UI / design / frontend work, in every session.

- **Default quality target = 9/10**, not perfectionist 9.5. Reserve >9 effort only when the user explicitly asks for it, and warn them about diminishing returns and critic oscillation.
- **Drive quality with a render → screenshot → score → refactor loop** against the *running* UI — score from what is rendered, not from reading code. A credible design score requires seeing the actual screen.
- **Score with an independent multi-lens critic** (visual / UX / skeptic) that reads the screenshots against an explicit rubric; synthesize by **median**, never the harshest single voice.
- **Stop rule:** a "never concede" critic is asymptotic and oscillates — it invents new minor/subjective items each round and will reverse its own prior advice. STOP when the median ≥ target AND remaining items are subjective / contradictory / edge-case. Do not chase unanimity.
- **Separate capture artifacts from real gaps** before acting (a drawer clipped mid-animation or a wrong-record screenshot is a capture bug, not a design bug).
- **Native-integration wins:** when the UI must fit an existing app (internal/operator tools especially), match the app's design language and component library — consistency over a bold/distinctive art direction.

Full process, anti-slop rules, and the capture recipes live in the `uiuxdesign` and `agent-browser` skills.
