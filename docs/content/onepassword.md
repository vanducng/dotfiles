---
title: "1Password CLI - Long-Lived Unlock"
---

`op signin` session tokens expire after 30 minutes of inactivity. That timeout is
hard-coded in the CLI, there is no flag, env var, or config key to raise it. The
only way to stop retyping the master password is to let the desktop app hold the
unlock and authorize `op` with Touch ID.

## What is versioned here

| Piece | Where |
|---|---|
| `1password` + `1password-cli` casks | `scripts/macos-deps.sh` |
| zsh completion | `dotfiles/zsh/.zshrc` |

## What cannot be versioned

The three settings that actually control session length are GUI toggles inside a
sealed app container. There is no supported file to stow. Set them once per machine:

1. **Settings > Developer > Integrate with 1Password CLI** on
2. **Settings > Security > Touch ID** on
3. **Settings > Security > Auto-lock** to `Never` (or 12 hours)

Also not versioned, and must stay that way: `~/.config/op/config` holds the
account key, which is half of a working credential. Never commit it.

## Clear the manual account first

If you used `op signin` on this machine before installing the app, the CLI still
has a manually-added account in `~/.config/op/config` with its own shorthand.
Real operations resolve against that stale entry, find no session token, and fail
with `account is not signed in`, while `op account list` confusingly still shows
the account. The app integration never gets consulted.

```bash
op account forget <shorthand>
```

The account key lives in the app and your Emergency Kit, so the CLI copy is
recoverable. Confirm the app is signed in before running it.

For the same reason, do not set `OP_ACCOUNT` to a shorthand. Shorthands only
exist for CLI-added accounts and stop resolving once the app owns the account.
With a single account, `op` resolves it without help.

## Verify

```bash
op whoami          # Touch ID prompt, then account details
env | grep OP_SESSION   # must be empty
```

If `OP_SESSION_*` is still exported, a stale manual signin is shadowing the app
integration. `unset` it and drop it from any local shell rc.

## Unattended access

Biometrics need a human. For cron, CI, or a headless box, use a service account
token instead:

```bash
op service-account create cli --vault Personal:read_items --expires-in=30d --raw
```

Service accounts require a Teams or Business plan. On an individual account the
command fails, and the desktop app integration is the only option.
