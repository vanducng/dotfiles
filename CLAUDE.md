# CLAUDE.md

Dotfiles repository for macOS dev environment, managed with GNU Stow.

## Project Structure

```
dotfiles/          # Stow packages (each folder = one tool's config)
  zsh/, tmux/, nvim/, ghostty/, yabai/, skhd/, ...
scripts/           # Utility & CI scripts
docs/              # Mintlify docs site (dotfiles.vanducng.dev)
Makefile           # Stow install/uninstall/test commands
```

## Key Commands

```bash
make stow-install      # Install all dotfiles via stow
make stow-uninstall    # Remove all symlinks
make stow-<tool>       # Install single tool (e.g., make stow-nvim)
make unstow-<tool>     # Remove single tool
make test              # Run CI validation
make validate          # Validate config syntax
```

## How Stow Works

Each folder under `dotfiles/` mirrors `$HOME`. Running `stow --no-folding -t $HOME <folder>` creates symlinks. Example: `dotfiles/zsh/.zshrc` symlinks to `~/.zshrc`.

## Conventions

- **Config locations**: Follow XDG where supported (`~/.config/<tool>/`)
- **Shell**: Zsh with custom aliases, functions, and integrations
- **Editor**: Neovim with AstroNvim base + custom plugins in `lua/plugins/`
- **Window mgmt**: Yabai (tiling) + SKHD (hotkeys)
- **Terminal**: Ghostty + Tmux with custom session scripts

## When Modifying Configs

- Test changes work before committing (source files, restart services)
- Keep configs portable across macOS versions
- Use comments to explain non-obvious settings
- Respect existing structure - don't reorganize without reason
