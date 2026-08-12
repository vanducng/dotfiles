# Portable Home Paths

Hard rule for managed configs, hooks, scripts, docs examples, and stow packages.

## Never hardcode

Do not write absolute personal home paths or usernames into files that are
shared, stowed, committed, or reused:

- `/Users/<username>/...`
- `/home/<username>/...`
- Literal machine usernames in path strings

## Prefer (in order)

1. Tool-native home vars when the host expands them: `$CODEX_HOME`, `$GROK_HOME`, `$XDG_CONFIG_HOME`, …
2. Portable forms that are actually expanded at runtime: `$HOME` / `${HOME}` (and `~` only where the host documents tilde expansion)
3. Relative paths from a known root (`./…`, package-local `cwd`)
4. Runtime discovery (`os.path.expanduser("~")`, `Path.home()`, env lookup) in scripts

**Spawn caveat:** process spawn APIs do **not** expand `~`. For MCP `command`/`cwd` that are exec'd without a shell, wrap with `/bin/bash -lc '…$HOME/…'` or use a form the host expands. Bare `~` in a command path is often wrong.

## Examples

```toml
# bad
command = "/Users/<username>/.codex/computer-use/…/SkyComputerUseClient"

# good (shell expands $HOME)
command = "/bin/bash"
args = ["-lc", "exec \"$HOME/.codex/computer-use/…/SkyComputerUseClient\" mcp"]
```

```bash
# bad
python3 /Users/<username>/skills/hooks/agent-notify.py codex

# good
python3 "$HOME/skills/hooks/agent-notify.py" codex
# or: python3 "$HOME/.codex/hooks/agent-notify.py" codex
```

## Allowed absolute paths

Only when they are fixed system locations, not personal homes:

- `/Applications/…`, `/usr/bin/…`, `/opt/homebrew/bin/…`, `/etc/…`

## Exceptions (narrow)

- Live runtime state that the tool rewrites itself and is **not** repo-managed
  (e.g. auto-generated project-trust maps) may contain absolute paths.
- Do not copy those absolute paths back into stow packages or shared templates
  unless the file is explicitly machine-local and gitignored.

## Before finishing a config change

Scan the diff for `/Users/` and `/home/`. Replace personal home prefixes with
`~` / `$HOME` / the tool's home var before commit.
