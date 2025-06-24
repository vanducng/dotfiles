#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ERRORS=0
WARNINGS=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    ((ERRORS++))
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++))
}

log_info() {
    echo "[INFO] $1"
}

validate_json() {
    local file="$1"
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$file" 2>/dev/null; then
            log_success "Valid JSON: $file"
        else
            log_error "Invalid JSON: $file"
            jq empty "$file" 2>&1 | sed 's/^/  /'
        fi
    else
        log_warning "jq not installed, skipping JSON validation"
    fi
}

validate_yaml() {
    local file="$1"
    if command -v yq >/dev/null 2>&1; then
        if yq eval '.' "$file" >/dev/null 2>&1; then
            log_success "Valid YAML: $file"
        else
            log_error "Invalid YAML: $file"
            yq eval '.' "$file" 2>&1 | sed 's/^/  /'
        fi
    elif command -v python3 >/dev/null 2>&1; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            log_success "Valid YAML: $file"
        else
            log_error "Invalid YAML: $file"
        fi
    else
        log_warning "No YAML validator found, skipping YAML validation"
    fi
}

validate_toml() {
    local file="$1"
    if command -v python3 >/dev/null 2>&1; then
        if python3 -c "import tomllib; tomllib.load(open('$file', 'rb'))" 2>/dev/null; then
            log_success "Valid TOML: $file"
        else
            if python3 -c "import toml; toml.load('$file')" 2>/dev/null; then
                log_success "Valid TOML: $file"
            else
                log_error "Invalid TOML: $file"
            fi
        fi
    else
        log_warning "Python not installed, skipping TOML validation"
    fi
}

validate_lua() {
    local file="$1"
    if command -v luac >/dev/null 2>&1; then
        if luac -p "$file" 2>/dev/null; then
            log_success "Valid Lua: $file"
        else
            log_error "Invalid Lua syntax: $file"
            luac -p "$file" 2>&1 | sed 's/^/  /'
        fi
    elif command -v lua >/dev/null 2>&1; then
        if lua -l "$file" -e "" 2>/dev/null; then
            log_success "Valid Lua: $file"
        else
            log_error "Invalid Lua syntax: $file"
        fi
    else
        log_warning "Lua not installed, skipping Lua validation"
    fi
}

validate_shell() {
    local file="$1"
    if command -v shellcheck >/dev/null 2>&1; then
        if shellcheck "$file"; then
            log_success "Valid shell script: $file"
        else
            log_error "Shell script issues: $file"
        fi
    else
        if bash -n "$file" 2>/dev/null; then
            log_success "Valid shell syntax: $file"
        else
            log_error "Invalid shell syntax: $file"
            bash -n "$file" 2>&1 | sed 's/^/  /'
        fi
    fi
}

validate_symlinks() {
    log_info "Validating potential symlink targets..."
    
    while IFS= read -r -d '' config_file; do
        local relative_path="${config_file#$PROJECT_ROOT/dotfiles/}"
        local tool_name="${relative_path%%/*}"
        local target_path="${relative_path#*/}"
        
        if [[ -n "$target_path" && "$target_path" != "$tool_name" ]]; then
            log_success "Valid symlink target: $config_file"
        fi
    done < <(find "$PROJECT_ROOT/dotfiles" -type f -print0)
}

validate_makefile() {
    log_info "Validating Makefile..."
    if make -n stow-install >/dev/null 2>&1; then
        log_success "Makefile syntax is valid"
    else
        log_error "Makefile has syntax errors"
        make -n stow-install 2>&1 | sed 's/^/  /'
    fi
}

main() {
    log_info "Starting dotfiles validation..."
    log_info "Project root: $PROJECT_ROOT"
    
    cd "$PROJECT_ROOT"
    
    log_info "Validating JSON files..."
    while IFS= read -r -d '' file; do
        validate_json "$file"
    done < <(find dotfiles -name "*.json" -type f -print0)
    
    log_info "Validating YAML files..."
    while IFS= read -r -d '' file; do
        validate_yaml "$file"
    done < <(find dotfiles -name "*.yaml" -o -name "*.yml" -type f -print0)
    
    log_info "Validating TOML files..."
    while IFS= read -r -d '' file; do
        validate_toml "$file"
    done < <(find dotfiles -name "*.toml" -type f -print0)
    
    log_info "Validating Lua files..."
    while IFS= read -r -d '' file; do
        validate_lua "$file"
    done < <(find dotfiles -name "*.lua" -type f -print0)
    
    log_info "Validating shell scripts..."
    while IFS= read -r -d '' file; do
        if [[ -x "$file" ]] || [[ "$file" =~ \.(sh|bash|zsh)$ ]] || head -1 "$file" | grep -q '^#!/'; then
            validate_shell "$file"
        fi
    done < <(find dotfiles scripts -type f -print0)
    
    validate_symlinks
    validate_makefile
    
    echo
    log_info "Validation complete!"
    log_info "Errors: $ERRORS"
    log_info "Warnings: $WARNINGS"
    
    if [[ $ERRORS -gt 0 ]]; then
        exit 1
    fi
}

main "$@"