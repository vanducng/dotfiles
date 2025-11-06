#!/usr/bin/env bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔄 Refreshing Neovim configuration...${NC}"

# Step 1: Clean nvim cache and state
echo -e "${GREEN}→ Cleaning nvim cache and state directories...${NC}"
rm -rf ~/.local/state/nvim ~/.cache/nvim

# Step 2: Sync plugins with ARM64 architecture
echo -e "${GREEN}→ Syncing plugins for ARM64...${NC}"
arch -arm64 /bin/zsh -c 'export ARCHFLAGS="-arch arm64"; export CFLAGS="-arch arm64"; export CXXFLAGS="-arch arm64"; /opt/homebrew/bin/nvim --headless "+Lazy! sync" "+qall"'

# Step 3: Clean up temp directories and old parsers
echo -e "${GREEN}→ Cleaning up TreeSitter temp directories...${NC}"
rm -rf ~/.local/share/nvim/tree-sitter-*-tmp ~/.local/share/nvim/*-tmp 2>/dev/null

echo -e "${GREEN}→ Removing old TreeSitter parsers...${NC}"
rm -f ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.dylib

echo -e "${GREEN}→ Rebuilding TreeSitter parsers for ARM64...${NC}"
arch -arm64 /bin/zsh -c 'export ARCHFLAGS="-arch arm64"; export CFLAGS="-arch arm64"; export CXXFLAGS="-arch arm64"; /opt/homebrew/bin/nvim --headless "+TSInstallSync lua vim python yaml json markdown markdown_inline bash sql typescript tsx javascript jsdoc c query vimdoc luap html css jsonc" "+qall"'

# Step 4: Rebuild blink.cmp if it exists
if [ -d ~/.local/share/nvim/lazy/blink.cmp ]; then
    echo -e "${GREEN}→ Rebuilding blink.cmp for ARM64...${NC}"
    cd ~/.local/share/nvim/lazy/blink.cmp && arch -arm64 /bin/zsh -c 'export ARCHFLAGS="-arch arm64"; cargo build --release'
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ blink.cmp built successfully${NC}"
    else
        echo -e "${RED}✗ blink.cmp build failed${NC}"
    fi
fi

# Step 5: Rebuild markdown-preview if it exists
if [ -d ~/.local/share/nvim/lazy/markdown-preview.nvim ]; then
    echo -e "${GREEN}→ Rebuilding markdown-preview...${NC}"
    cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app && npm install
fi

echo -e "${GREEN}✅ Neovim refresh complete!${NC}"
echo -e "${YELLOW}You can now open nvim. First launch may take a moment to finish setup.${NC}"
