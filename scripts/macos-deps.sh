#!/usr/bin/env bash
set -euo pipefail

brew install obsidian
brew install fzf
brew install zsh-syntax-highlighting
brew install firefox
brew install skhd
brew install istat-menus
brew install docker
brew install docker-compose
brew install alfred
brew install trash
brew install the_silver_searcher
brew install tree
brew install yt-dlp
brew install jsonpp
brew install jq

brew install exa
brew install z

# spark, fantastical, cardhop, shush, kaleidoscope

brew install ksdiff
brew install whatsapp
# brew install alt-tab
brew install neovim

brew install fnm
brew install tmux
brew install rust

# Core dependencies intentionally fail fast; Tinycast below is the only optional, guarded step.
# Only Tinycast is guarded with a warning, everything else should abort on failure.
# Tinycast launcher (Raycast replacement). Apple silicon, macOS 26+.
tinycast_install_ok=true
if brew help trust >/dev/null 2>&1; then
  brew trust --tap abue-ammar/tinycast || tinycast_install_ok=false
fi
if [ "$tinycast_install_ok" = true ]; then
  brew tap abue-ammar/tinycast || tinycast_install_ok=false
  brew install --cask tinycast || tinycast_install_ok=false
fi
if [ "$tinycast_install_ok" = false ]; then
  echo "warning: Tinycast install failed; continuing with core dependencies" >&2
fi
