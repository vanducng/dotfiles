---
title: "pi"
---

pi's user settings are managed by this repo: `dotfiles/pi/.pi/agent/settings.json` is
stowed to `~/.pi/agent/settings.json`, so the default provider/model, theme, and the
`packages` list (extensions) are all reproducible. Sessions, auth, and installed
package artifacts stay local.

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
