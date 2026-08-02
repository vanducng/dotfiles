# Duc's Digital Workspace

AI-native macOS development environment centered on Herdr workspaces.

[![Docs](https://img.shields.io/badge/docs-dotfiles.vanducng.dev-7c3aed?style=flat-square)](https://dotfiles.vanducng.dev)
![macOS](https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white)
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=flat-square&logo=neovim&logoColor=white)

## Features

- **Window Management** - Yabai + SKHD for tiling and hotkeys
- **Terminal** - Ghostty + Herdr + Zsh with persistent agent workspaces
- **Editor** - Neovim (AstroNvim) with LSP and AI integration
- **AI Tools** - CodeCompanion, GitHub Copilot, Database AI
- **Utilities** - Atuin, Yazi, Starship, Mise, Direnv, Karabiner, Hammerspoon

## Documentation

Full setup guide, keybindings, and workflows: **[dotfiles.vanducng.dev](https://dotfiles.vanducng.dev)**

## Nix profiles

The flake provides a shared Home Manager profile for macOS and Linux. The
current Kubernetes coding-agent pod remains Ubuntu-based and should consume
the prebuilt image rather than installing Nix at runtime.

```bash
# Check the flake and enter its portable development shell.
nix flake check
nix develop

# First activation on macOS.
nix run home-manager/release-26.05 -- switch --flake .#macbook

# Later activations.
home-manager switch --flake .#macbook
home-manager switch --flake .#coding-agent

# Update pinned Nix inputs deliberately.
nix flake update nixpkgs home-manager herdr
```

The `flake.lock` file is committed so all machines use the same input
revisions. Codex, Pi, and Moshi continue to use their official installers.

## Remote browser

The coding-agent profile stows `agent-browser-connect` from the `bin` package.
When `BROWSER_CDP_URL` points at a Kubernetes Chrome service, run:

```bash
agent-browser-connect
agent-browser open https://example.com
agent-browser snapshot -i
agent-browser close
```

The helper resolves the service to its pod IP, attaches to the persistent
non-headless Chrome profile, and rejects accidental standalone HeadlessChrome
sessions.

## License

MIT
