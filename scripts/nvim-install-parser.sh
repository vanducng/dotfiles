#!/usr/bin/env bash

# Install a specific treesitter parser with ARM64 architecture
# Usage: ./nvim-install-parser.sh <parser-name>
# Example: ./nvim-install-parser.sh make

if [ -z "$1" ]; then
    echo "Usage: $0 <parser-name>"
    echo "Example: $0 make"
    exit 1
fi

PARSER_NAME="$1"

echo "Installing treesitter parser: ${PARSER_NAME}"
arch -arm64 nvim --headless -c "TSInstallSync ${PARSER_NAME}" -c "q"

echo "Verifying parser architecture:"
if [ -f ~/.local/share/nvim/lazy/nvim-treesitter/parser/${PARSER_NAME}.so ]; then
    file ~/.local/share/nvim/lazy/nvim-treesitter/parser/${PARSER_NAME}.so
else
    echo "Parser not found at expected location"
fi
