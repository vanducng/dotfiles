#!/usr/bin/env bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔄 Refreshing Neovim configuration...${NC}"

# Step 1: Clean nvim directories
echo -e "${GREEN}→ Cleaning nvim cache and data directories...${NC}"
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim

# Step 2: Remove plugin lock file
echo -e "${GREEN}→ Removing lazy plugin lock file...${NC}"
rm -rf ~/.config/nvim/lazy-lock.json

# Step 3: Reinstall plugins with ARM64 architecture
echo -e "${GREEN}→ Reinstalling plugins for ARM64...${NC}"
arch -arm64 nvim --headless "+Lazy! sync" +qa

# Step 4: Clean up temp directories and old parsers
echo -e "${GREEN}→ Cleaning up TreeSitter temp directories...${NC}"
rm -rf ~/.local/share/nvim/tree-sitter-*-tmp ~/.local/share/nvim/*-tmp 2>/dev/null

echo -e "${GREEN}→ Removing old TreeSitter parsers...${NC}"
rm -f ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.dylib

echo -e "${GREEN}→ Rebuilding TreeSitter parsers for ARM64...${NC}"
cd ~/.local/share/nvim/lazy/nvim-treesitter 2>/dev/null && \
    arch -arm64 nvim --headless -c "TSInstallSync sql csv go hcl terraform yaml bash python json jsonc javascript typescript tsx jsx lua markdown html css vim vimdoc dockerfile" -c "q"

# Step 5: Rebuild blink.cmp if it exists
if [ -d ~/.local/share/nvim/lazy/blink.cmp ]; then
    CURRENT_ARCH=$(arch)
    echo -e "${GREEN}→ Rebuilding blink.cmp for ${CURRENT_ARCH}...${NC}"
    cd ~/.local/share/nvim/lazy/blink.cmp && cargo build --release
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ blink.cmp built successfully${NC}"
    else
        echo -e "${RED}✗ blink.cmp build failed${NC}"
    fi
fi

# Step 6: Rebuild markdown-preview if it exists
if [ -d ~/.local/share/nvim/lazy/markdown-preview.nvim ]; then
    echo -e "${GREEN}→ Rebuilding markdown-preview...${NC}"
    cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app && npm install
fi

echo -e "${GREEN}✅ Neovim refresh complete!${NC}"
echo -e "${YELLOW}You can now open nvim. First launch may take a moment to finish setup.${NC}"
