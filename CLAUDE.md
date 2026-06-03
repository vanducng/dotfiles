# CLAUDE.md

Dotfiles repository for macOS dev environment, managed with GNU Stow.

## Project Structure

```
dotfiles/          # Stow packages (each folder = one tool's config)
  zsh/, tmux/, nvim/, ghostty/, yabai/, skhd/, ...
scripts/           # Utility & CI scripts
docs/              # Markdown docs content (dotfiles.vanducng.dev)
astro.config.mjs   # Astro Starlight docs site (reads content from docs/)
Makefile           # Stow install/uninstall/test commands
```

## Docs site

The docs at `dotfiles.vanducng.dev` are built with **Astro Starlight**. Content lives in `docs/` (loaded via a glob loader in `src/content.config.ts`); brand/theme in `src/styles/theme.css`. Build locally with `npm run build` (output in `dist/`); deployed to GitHub Pages by `.github/workflows/docs.yml` on push to `main`. Every page needs `title:` frontmatter; the home page (`docs/index.mdx`) uses the `splash` template.

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
