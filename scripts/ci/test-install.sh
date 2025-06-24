#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_HOME="${TEST_HOME:-/tmp/dotfiles-test-$$}"
ERRORS=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    ((ERRORS++))
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

cleanup() {
    if [[ -d "$TEST_HOME" ]]; then
        log_info "Cleaning up test environment..."
        rm -rf "$TEST_HOME"
    fi
}

trap cleanup EXIT

setup_test_env() {
    log_info "Setting up test environment in $TEST_HOME"
    mkdir -p "$TEST_HOME"
    
    mkdir -p "$TEST_HOME/.config"
    mkdir -p "$TEST_HOME/.local/bin"
    mkdir -p "$TEST_HOME/.local/share"
    mkdir -p "$TEST_HOME/.cache"
}

test_stow_installation() {
    local tool="$1"
    log_info "Testing installation of $tool..."
    
    cd "$PROJECT_ROOT"
    
    if HOME="$TEST_HOME" make stow-$tool 2>/dev/null; then
        log_success "Successfully installed $tool"
        
        local config_dir="$PROJECT_ROOT/dotfiles/$tool/.config"
        if [[ -d "$config_dir" ]]; then
            local expected_link="$TEST_HOME/.config/$(basename "$config_dir")"
            if [[ -L "$expected_link" ]]; then
                log_success "Config symlink created for $tool"
            else
                log_error "Config symlink missing for $tool"
            fi
        fi
        
        HOME="$TEST_HOME" make unstow-$tool 2>/dev/null || true
    else
        log_error "Failed to install $tool"
    fi
}

test_all_tools() {
    log_info "Testing individual tool installations..."
    
    local tools=($(cd "$PROJECT_ROOT/dotfiles" && find . -maxdepth 1 -type d -not -name "." | cut -d'/' -f2 | sort))
    
    for tool in "${tools[@]}"; do
        case "$OSTYPE" in
            darwin*)
                test_stow_installation "$tool"
                ;;
            linux*)
                case "$tool" in
                    hammerspoon|karabiner|skhd|yabai|sketchybar)
                        log_info "Skipping $tool (macOS only)"
                        ;;
                    *)
                        test_stow_installation "$tool"
                        ;;
                esac
                ;;
        esac
    done
}

test_full_installation() {
    log_info "Testing full installation..."
    
    cd "$PROJECT_ROOT"
    
    if HOME="$TEST_HOME" make stow-install 2>/dev/null; then
        log_success "Full installation completed"
        
        local symlinks_found=0
        while IFS= read -r -d '' link; do
            ((symlinks_found++))
        done < <(find "$TEST_HOME" -type l -print0)
        
        log_success "Created $symlinks_found symlinks"
        
        HOME="$TEST_HOME" make stow-uninstall 2>/dev/null || true
    else
        log_error "Full installation failed"
    fi
}

test_makefile_targets() {
    log_info "Testing Makefile targets..."
    
    cd "$PROJECT_ROOT"
    
    local targets=("help" "stow-status")
    for target in "${targets[@]}"; do
        if make "$target" >/dev/null 2>&1; then
            log_success "Makefile target '$target' works"
        else
            log_error "Makefile target '$target' failed"
        fi
    done
}

test_config_conflicts() {
    log_info "Checking for potential conflicts..."
    
    local configs=(
        ".config/nvim"
        ".config/tmux"
        ".config/zsh"
        ".config/kitty"
        ".config/ghostty"
    )
    
    for config in "${configs[@]}"; do
        if [[ -e "$HOME/$config" ]] && [[ ! -L "$HOME/$config" ]]; then
            log_error "Potential conflict: $HOME/$config exists and is not a symlink"
        fi
    done
}

main() {
    echo -e "${BLUE}=== Dotfiles Installation Test ===${NC}"
    echo
    
    setup_test_env
    test_makefile_targets
    test_all_tools
    test_full_installation
    test_config_conflicts
    
    echo
    log_info "Test complete!"
    log_info "Errors: $ERRORS"
    
    if [[ $ERRORS -gt 0 ]]; then
        exit 1
    fi
}

main "$@"