---
title: "pi"
---

pi's user settings are managed by this repo: `dotfiles/pi/.pi/agent/settings.json` is
stowed to `~/.pi/agent/settings.json`, so the default provider/model, theme, and the
`packages` list (extensions) are all reproducible. Sessions, auth, and installed
package artifacts stay local.

## Home layout

`~/.pi` itself must be a **real directory** under `$HOME`. Do not replace it with a
symlink onto `~/work/store/pi` (or any other volume). That breaks two things:

1. Stow writes relative links for the theme and extensions. Those resolve from the
   real path of `~/.pi`, so a store symlink makes `rose-pine-moon` dangle and pi
   falls back to the dark theme.
2. Running `pi` from `$HOME` makes pi-subagents treat `~/.pi/subagents/schedules` as
   the project schedule root. If that path realpaths outside `$HOME`, the extension
   crashes on startup (`Project schedule root ... resolves outside the real project`).

`make stow-install` and `make stow-pi` run `scripts/pi-home-layout.sh` on Linux and
macOS. The script is idempotent: a fresh home gets a real `~/.pi`, a wholesale
`~/.pi` symlink is unwrapped, and a second run is a no-op besides restow. It never
creates a runtime store. Nested `npm` / `sessions` / `git` links are added only when
the old symlink target already holds them, when `$HOME/work/store/pi` already has
that runtime, or when `PI_STORE` is set. On Linux, `relocate-stores` also moves only
those children onto the 970; it must not symlink the whole `~/.pi` tree.

```bash
make stow-pi
# or, with an explicit runtime store:
PI_STORE="$HOME/work/store/pi" make stow-pi
```

Schedules are stored under `~/.local/share/pi-subagents/schedules` via the stowed
`extensions/subagent/config.json` (`scheduledRuns.storeRoot`), so a relocated `~/.pi`
cannot take the extension down even if someone runs `pi` from `$HOME`.

## Install

```bash
make stow-pi
```

pi does **not** auto-install user-level packages on a fresh machine - the stowed
`packages` list declares them, but each artifact needs one `pi install` to download.
Re-running the installs is idempotent and keeps the settings entries unchanged:

```bash
pi install npm:pi-web-access
pi install npm:pi-subagents
pi install npm:pi-langfuse
# ...one per entry in the stowed "packages" list
```

## Langfuse tracing

Observability follows the official integration:
[Trace Pi Agent with Langfuse](https://langfuse.com/integrations/developer-tools/pi-agent).
The community `pi-langfuse` extension traces in-process: one trace per prompt, a root
agent observation, a generation per model request (tokens + cost), tool observations,
and trace-level scores. It also redacts common secrets and hashes local paths.

```bash
pi install npm:pi-langfuse
```

### Credentials

No config file is used - `~/.pi/agent/pi-langfuse/config.json` would hold the keys in
plaintext, so credentials come from the environment instead. They live in `~/.envrc`
(direnv, private, not in this repo):

```bash
export LANGFUSE_PUBLIC_KEY=pk-lf-...
export LANGFUSE_SECRET_KEY=sk-lf-...
export LANGFUSE_BASE_URL="https://us.cloud.langfuse.com"   # must match the key's region
```

Launch pi from a direnv-loaded shell and it prints
`📊 Langfuse: Tracing enabled → https://us.cloud.langfuse.com` at startup.

Resolution order (verified in the extension source): `config.json` wins, but only
when it contains **both** `publicKey` and `secretKey` - a partial file is ignored.
Otherwise env vars are used. Two consequences:

- **Never run `/langfuse-setup`** - it writes the keys to
  `~/.pi/agent/pi-langfuse/config.json` in plaintext, and that file then takes
  precedence over the environment. Keeping creds env-only is what makes this
  setup trackable in dotfiles without exposing secrets.
- The extension does not read `~/.envrc` itself (direnv must have loaded it).
  pi launched outside a direnv shell (GUI app, launchd) runs untraced silently.

### Capture policy

Default preset is `full-debug` (full inputs/outputs/tool I/O). Restrict with
`LANGFUSE_PRIVACY_PRESET` (`metadata-only`, `prompts-only`, `conversations`) for
sensitive sessions, or fine-grained `LANGFUSE_CAPTURE_*` flags.

### Verify

```bash
# inside pi
/langfuse-status   # host, masked key, capture policy
/langfuse-test     # checks host + keys

# from the shell, via the Langfuse skill's CLI
export LANGFUSE_HOST="$LANGFUSE_BASE_URL"
npx langfuse-cli api observations list --limit 5
```

### History

Before `pi-langfuse`, pi was traced by a custom extension in the skills repo
(`hooks/pi/langfuse-trace`) that spawned the shared Python exporter on
`agent_settled`. That lane is retired for pi - the official extension is richer -
but the exporter still handles Claude Code and Codex, and its `--agent pi` adapter
remains for backfilling old sessions. Don't register both for pi: every turn would
be traced twice.
