---
title: "Git Troubleshooting"
---

## Lazygit cannot commit

Signed commits from lazygit fail when GPG has no GUI pinentry and no TTY.

```bash
brew install lazygit pinentry-mac
make stow-gnupg stow-zsh stow-lazygit
gpgconf --kill gpg-agent
```

Then open a new shell (so `GPG_TTY` is set) and run `lazygit`. Commit with `c`.

If lazygit is wedged at 100% CPU, it is likely the old 0.35 binary. `lazygit --version` should be 0.64 or newer.

Confirm GPG can sign without a TUI:

```bash
echo test | gpg --clearsign >/dev/null
```

A macOS pinentry window is expected when the agent cache is cold.
