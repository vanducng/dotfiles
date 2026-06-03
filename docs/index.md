---
title: Home
description: AI-enhanced macOS development environment — tiling window management, terminal workflows, and integrated AI coding.
---

<div class="dt-hero" markdown>
<p class="dt-kicker">dotfiles.vanducng.dev</p>
<h1>An AI-native macOS dev environment, wired together and documented.</h1>
<p>Thirty Stow-managed tool configs that turn a fresh Mac into a keyboard-driven workspace: Yabai tiling, a Tmux + Ghostty terminal, AstroNvim, and Codex / Claude / CodeCompanion coding assistants — reproducible from one command.</p>
<div class="dt-actions" markdown>
[Install from scratch](installation.md){ .dt-button }
[Quick reference](quick-reference.md){ .dt-button .dt-button-secondary }
[AI coding setup](ai/index.md){ .dt-button .dt-button-secondary }
</div>
</div>

<div class="dt-metrics" markdown>
<div markdown>
<strong>30</strong>
<span>Stow-managed tool configs</span>
</div>
<div markdown>
<strong>4</strong>
<span>integrated AI coding assistants</span>
</div>
<div markdown>
<strong>14</strong>
<span>tiled app workspaces</span>
</div>
<div markdown>
<strong>100%</strong>
<span>keyboard-driven workflow</span>
</div>
</div>

## What's Inside

Every folder under `dotfiles/` is a GNU Stow package symlinked into your home directory. The guides below are grouped by what you're trying to do.

<div class="dt-card-grid dt-2col" markdown>
<div class="dt-card" markdown>

### [Core Tools](neovim/README.md)

Neovim (AstroNvim v6), Tmux, Atuin, SKHD hotkeys, and Zen Mode — the daily-driver editing and terminal stack.

</div>
<div class="dt-card" markdown>

### [AI Tools](ai/index.md)

Codex CLI, Claude Code, CodeCompanion, and Supermaven — how they're configured and how they fit together.

</div>
<div class="dt-card" markdown>

### [Workflows](workflows/index.md)

End-to-end patterns for coding, database work, and review & debug across the whole toolchain.

</div>
<div class="dt-card" markdown>

### [Troubleshooting](troubleshooting/index.md)

Fixes for window management, terminal, Neovim, AI tools, and performance when something misbehaves.

</div>
</div>

## Quick Help

### Reload & restart

```bash
# Window manager + hotkeys
brew services restart yabai
brew services restart skhd

# Shell + multiplexer
source ~/.zshrc
tmux source-file ~/.tmux.conf

# Plugins
:Lazy sync   # in Neovim
prefix + I   # in Tmux (prefix = Ctrl+X)
```

### Emergency recovery

```bash
# Window manager wedged
killall yabai skhd
brew services restart yabai

# Terminal broken — launch Ghostty directly
/Applications/Ghostty.app/Contents/MacOS/ghostty
```

## More

- [Codebase Summary](codebase-summary.md) — repository structure and package overview
- [GitHub repository](https://github.com/vanducng/dotfiles) — source, README, and feature highlights
