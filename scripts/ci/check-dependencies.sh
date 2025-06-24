#!/usr/bin/env bash
set -euo pipefail

# PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MISSING_REQUIRED=0
MISSING_OPTIONAL=0

declare -A TOOLS=(
    ["atuin"]="required:Shell history sync"
    ["direnv"]="required:Environment management"
    ["ghostty"]="optional:GPU-accelerated terminal"
    ["git"]="required:Version control"
    ["hammerspoon"]="optional:macOS automation (macOS only)"
    ["jq"]="required:JSON processing"
    ["karabiner"]="optional:Keyboard customization (macOS only)"
    ["kitty"]="optional:Terminal emulator"
    ["lazygit"]="optional:Git UI"
    ["lua"]="optional:Lua interpreter"
    ["make"]="required:Build automation"
    ["mise"]="required:Runtime version manager"
    ["nvim"]="required:Text editor"
    ["python3"]="required:Python interpreter"
    ["rg"]="required:Ripgrep search"
    ["shellcheck"]="optional:Shell script linter"
    ["skhd"]="optional:Hotkey daemon (macOS only)"
    ["starship"]="required:Shell prompt"
    ["stow"]="required:Symlink manager"
    ["task"]="optional:Task warrior"
    ["tmux"]="required:Terminal multiplexer"
    ["yabai"]="optional:Window manager (macOS only)"
    ["yazi"]="optional:File manager"
    ["yq"]="optional:YAML processor"
    ["zathura"]="optional:PDF viewer"
    ["zsh"]="required:Z shell"
)

declare -A LANGUAGE_SERVERS=(
    ["bash-language-server"]="Bash LSP"
    ["lua-language-server"]="Lua LSP"
    ["pyright"]="Python LSP"
    ["typescript-language-server"]="TypeScript LSP"
    ["yaml-language-server"]="YAML LSP"
)

check_command() {
    local cmd="$1"
    local info="$2"
    local type="${info%%:*}"
    local desc="${info#*:}"
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        case "$cmd" in
            hammerspoon|karabiner|skhd|yabai)
                echo -e "${BLUE}[SKIP]${NC} $cmd - $desc (macOS only)"
                return
                ;;
        esac
    fi
    
    if command -v "$cmd" >/dev/null 2>&1; then
        local version=""
        case "$cmd" in
            nvim) version=$(nvim --version | head -1) ;;
            git) version=$(git --version) ;;
            tmux) version=$(tmux -V) ;;
            zsh) version=$(zsh --version) ;;
            python3) version=$(python3 --version) ;;
            node) version=$(node --version) ;;
            *) version=$(command -v "$cmd") ;;
        esac
        echo -e "${GREEN}[OK]${NC} $cmd - $desc ${version:+(${version})}"
    else
        if [[ "$type" == "required" ]]; then
            echo -e "${RED}[MISSING]${NC} $cmd - $desc ${RED}(REQUIRED)${NC}"
            ((MISSING_REQUIRED++))
        else
            echo -e "${YELLOW}[MISSING]${NC} $cmd - $desc (optional)"
            ((MISSING_OPTIONAL++))
        fi
    fi
}

check_npm_package() {
    local package="$1"
    local desc="$2"
    
    if command -v npm >/dev/null 2>&1; then
        if npm list -g "$package" >/dev/null 2>&1; then
            echo -e "${GREEN}[OK]${NC} $package - $desc"
        else
            echo -e "${YELLOW}[MISSING]${NC} $package - $desc (optional)"
            ((MISSING_OPTIONAL++))
        fi
    fi
}

check_python_package() {
    local package="$1"
    local desc="$2"
    
    if command -v python3 >/dev/null 2>&1; then
        if python3 -c "import $package" 2>/dev/null; then
            echo -e "${GREEN}[OK]${NC} $package - $desc"
        elif pip3 show "$package" >/dev/null 2>&1; then
            echo -e "${GREEN}[OK]${NC} $package - $desc"
        else
            echo -e "${YELLOW}[MISSING]${NC} $package - $desc (optional)"
            ((MISSING_OPTIONAL++))
        fi
    fi
}

get_os_info() {
    echo -e "${BLUE}System Information:${NC}"
    echo "  OS: $OSTYPE"
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        echo "  Distribution: ${NAME:-Unknown} ${VERSION:-}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  macOS Version: $(sw_vers -productVersion)"
        echo "  Architecture: $(uname -m)"
    fi
    echo
}

main() {
    echo -e "${BLUE}=== Dotfiles Dependency Check ===${NC}"
    echo
    
    get_os_info
    
    echo -e "${BLUE}Core Tools:${NC}"
    for tool in "${!TOOLS[@]}"; do
        check_command "$tool" "${TOOLS[$tool]}"
    done | sort
    
    echo
    echo -e "${BLUE}Language Servers (for Neovim):${NC}"
    for lsp in "${!LANGUAGE_SERVERS[@]}"; do
        check_command "$lsp" "optional:${LANGUAGE_SERVERS[$lsp]}"
    done | sort
    
    echo
    echo -e "${BLUE}Build Tools:${NC}"
    check_command "cargo" "optional:Rust package manager"
    check_command "go" "optional:Go programming language"
    check_command "node" "optional:Node.js runtime"
    check_command "npm" "optional:Node package manager"
    
    if command -v python3 >/dev/null 2>&1; then
        echo
        echo -e "${BLUE}Python Packages:${NC}"
        check_python_package "yaml" "YAML parser"
        check_python_package "toml" "TOML parser (fallback)"
        check_python_package "tomllib" "TOML parser (Python 3.11+)"
    fi
    
    echo
    echo -e "${BLUE}Summary:${NC}"
    echo "  Required tools missing: $MISSING_REQUIRED"
    echo "  Optional tools missing: $MISSING_OPTIONAL"
    
    if [[ $MISSING_REQUIRED -gt 0 ]]; then
        echo
        echo -e "${RED}ERROR: Missing required dependencies!${NC}"
        echo "Install missing required tools before proceeding."
        exit 1
    else
        echo
        echo -e "${GREEN}All required dependencies are installed!${NC}"
    fi
}

main "$@"