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
2. Portable home forms the host expands: `~`, `$HOME`, `${HOME}`
3. Relative paths from a known root (`./…`, package-local `cwd`)
4. Runtime discovery (`os.path.expanduser("~")`, `Path.home()`, env lookup) in scripts

## Examples

```toml
# bad
command = "/Users/<username>/.codex/computer-use/…/SkyComputerUseClient"
cwd = "/Users/<username>/.codex/computer-use"

# good
command = "~/.codex/computer-use/…/SkyComputerUseClient"
cwd = "~/.codex/computer-use"
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
