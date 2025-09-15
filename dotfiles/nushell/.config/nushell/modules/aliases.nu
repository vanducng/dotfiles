# Aliases - Common command shortcuts

# File listing aliases
export alias ll = ls -la
export alias la = ls -a
export alias l = ls

# Git aliases
export alias g = git
export alias gs = git status
export alias ga = git add
export alias gc = git commit
export alias gp = git push
export alias gl = git log --oneline

# Navigation
export alias .. = cd ..
export alias ... = cd ../..
export alias .... = cd ../../..

# Editor
export alias v = nvim
export alias vim = nvim

# System
export alias cls = clear
export alias h = history

# Common directories (adjust paths as needed)
export alias cdeg = cd /Volumes/exs/git

# Python/Poetry
export alias av = ansible-vault

# Snowflake
export alias snowsql = /Applications/SnowSQL.app/Contents/MacOS/snowsql

# GitHub Copilot (will be overridden by gh copilot if available)
export alias ghcs = gh copilot suggest
export alias ghce = gh copilot explain

# Quick config edits
export alias zshconfig = nvim ~/.zshrc
export alias nuconfig = nvim ~/.config/nushell/config.nu
export alias ghosttyconfig = nvim ~/.config/ghostty/config

# File operations - Nushell commands work differently
# export alias rm = rm -i   # Nushell rm is interactive by default
# export alias cp = cp -i   # Nushell cp doesn't have -i flag
# export alias mv = mv -i   # Nushell mv doesn't have -i flag

# Process management
export alias psa = ps

# Tree with reasonable defaults (if tree command exists)
# export alias tree = tree -a -I '.git|node_modules|.venv|__pycache__'