# Development Rules

**IMPORTANT:** Analyze the skills catalog and activate the skills that are needed for the task during the process.
**IMPORTANT:** You ALWAYS follow these principles: **YAGNI (You Aren't Gonna Need It) - KISS (Keep It Simple, Stupid) - DRY (Don't Repeat Yourself)**

## General
- **File Naming**: Use kebab-case for file names with a meaningful name that describes the purpose of the file, doesn't matter if the file name is long, just make sure when LLMs read the file names while using Grep or other tools, they can understand the purpose of the file right away without reading the file content.
- **File Size Management**: Keep individual code files under 200 lines for optimal context management
  - Split large files into smaller, focused components/modules
  - Use composition over inheritance for complex widgets
  - Extract utility functions into separate modules
  - Create dedicated service classes for business logic
- When looking for docs, activate `docs-seeker` skill (`context7` reference) for exploring latest docs.
- Use `gh` bash command to interact with Github features if needed
- Use `psql` bash command to query Postgres database for debugging if needed
- Use `omnimedia` skill for describing or generating images, videos, audio, documents, etc. if needed (pair with `media-processing` for FFmpeg/ImageMagick edits)
- Use `debug` skill for systematic analysis and debugging if needed
- **[IMPORTANT]** Follow the codebase structure and code standards in `./docs` during implementation.
- **[IMPORTANT]** Do not just simulate the implementation or mocking them, always implement the real code.

## Code Quality Guidelines
- Read and follow codebase structure and code standards in `./docs`
- **Make sure there are no syntax errors and the code compiles.** Lint and test failures are real defects (see AGENTS.md), not noise to wave through.
- Prioritize functionality and readability over cosmetic formatting preferences
- Use try catch error handling & cover security standards
- Use `code-reviewer` agent to review code after every implementation

## Pre-commit/Push Rules
- Run linting before commit
- Run tests before push (DO NOT ignore failed tests just to pass the build or github actions)
- Keep commits focused on the actual code changes
- **DO NOT** commit and push any confidential information (such as dotenv files, API keys, database credentials, etc.) to git repository!
- Create clean, professional commit messages without AI references. Use conventional commit format.

## Visual Aids
- Use `text-diagram` for terminal-friendly ASCII architecture diagrams (no browser needed)
- Use `diagram` for rendered diagram images (system architecture, workflow, data flow, sequence, ER, C4); `--versioned` for git-trackable specs
- Use `excalidraw` for hand-drawn-style canvas diagrams (read the skill BEFORE any Excalidraw MCP call)
- For Mermaid diagrams, use `mermaidjs-v11` skill for v11 syntax rules
- Save to the hook-injected `Visuals:` path under a `{topic-slug}/` subfolder
