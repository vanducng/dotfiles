#!/bin/bash
# Force ARM64 architecture for nvim treesitter parser installation

set -e

echo "🔧 Installing nvim-treesitter parsers for ARM64..."

# Ensure we're running in ARM64 mode
if [[ $(uname -m) != "arm64" ]]; then
    echo "⚠️  Running under Rosetta, switching to ARM64..."
    exec arch -arm64 /bin/bash "$0" "$@"
fi

echo "✅ Running in ARM64 mode: $(uname -m)"

# Clean existing parsers
echo "🧹 Cleaning existing parsers..."
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so

# Set ARM64 compiler flags (safer approach)
export ARCHFLAGS="-arch arm64"
export CFLAGS="-arch arm64"
export CXXFLAGS="-arch arm64"

# Install parsers using ARM64 nvim
echo "📦 Installing treesitter parsers..."
/opt/homebrew/bin/nvim --headless "+TSInstallSync lua vim python yaml json markdown markdown_inline bash sql typescript tsx javascript jsdoc c query vimdoc luap html css jsonc" "+qall"

echo "✨ Done! Verifying parsers..."
if file ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so 2>/dev/null | grep -q "x86_64"; then
    echo "❌ Some parsers are still x86_64!"
    file ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so | grep "x86_64"
    exit 1
else
    echo "✅ All parsers are ARM64!"
    file ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so | head -5
fi
