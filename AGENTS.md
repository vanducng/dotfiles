# AGENTS.md

Dotfiles repository for macOS dev environment, managed with GNU Stow.

## Project Structure

```
dotfiles/          # Stow packages (each folder = one tool's config)
  zsh/, tmux/, nvim/, ghostty/, yabai/, skhd/, ...
scripts/           # Utility & CI scripts
docs/              # Astro Starlight docs site (dotfiles.vanducng.dev), self-contained
  content/         #   authored Markdown/MDX content
  src/             #   config (content.config.ts), theme (styles/theme.css), components/
Makefile           # Stow install/uninstall/test commands
```

## Docs site

The docs at `dotfiles.vanducng.dev` are built with **Astro Starlight**, kept entirely under `docs/` so the docs-site tooling never mixes with the repo's own source. Authored content lives in `docs/content/` (loaded via a glob loader in `docs/src/content.config.ts`); brand/theme in `docs/src/styles/theme.css`; React enabled (`@astrojs/react`) for occasional interactive MDX islands; `starlight-llms-txt` generates `/llms.txt`. Build locally with `cd docs && npm run build`; deployed to GitHub Pages by `.github/workflows/docs.yml` (builds `./docs`) on push to `main`. Every content page needs `title:` frontmatter.

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
