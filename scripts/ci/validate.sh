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
    ERRORS=$((ERRORS + 1))
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    WARNINGS=$((WARNINGS + 1))
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
        # Check Python version - tomllib requires 3.11+
        if python3 -c "import sys; exit(0 if sys.version_info >= (3, 11) else 1)" 2>/dev/null; then
            if python3 -c "import tomllib; tomllib.load(open('$file', 'rb'))" 2>/dev/null; then
                log_success "Valid TOML: $file"
            else
                log_error "Invalid TOML: $file"
                python3 -c "import tomllib; tomllib.load(open('$file', 'rb'))" 2>&1 | sed 's/^/  /'
            fi
        else
            log_warning "Python 3.11+ required for TOML validation, skipping $file"
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
    # Skip zsh-only files — shellcheck doesn't support zsh syntax (globs, etc.)
    case "$file" in
        */.zshrc|*/.zshenv|*/.zprofile|*/.zlogin|*/.zlogout)
            log_success "Skipping zsh config (shellcheck unsupported): $file"
            return
            ;;
    esac
    local shebang
    shebang=$(head -1 "$file" 2>/dev/null)
    case "$shebang" in
        "#!/bin/zsh"|*"env zsh"*|*"env fish"*|*"/fish"*)
            log_success "Skipping non-bash shell: $file"
            return
            ;;
    esac
    if command -v shellcheck >/dev/null 2>&1; then
        # --severity=error: only true syntax/parse errors block. Style/info notes don't fail CI.
        if shellcheck --severity=error "$file"; then
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
        local relative_path="${config_file#"$PROJECT_ROOT"/dotfiles/}"
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

validate_agent_hook_commands() {
    log_info "Validating agent hook commands..."
    if ! command -v python3 >/dev/null 2>&1; then
        log_warning "Python not installed, skipping agent hook command validation"
        return
    fi

    local output
    if output=$(python3 - dotfiles/codex/.codex/hooks.json dotfiles/claude/.claude/settings.json 2>&1 <<'PY'
import json
import pathlib
import shlex
import sys

errors = []
for name in sys.argv[1:]:
    path = pathlib.Path(name)
    data = json.loads(path.read_text())
    for event, entries in data.get("hooks", {}).items():
        for entry in entries:
            for hook in entry.get("hooks", []):
                command = hook.get("command")
                if not command:
                    continue
                try:
                    executable = shlex.split(command)[0]
                except ValueError as exc:
                    errors.append(f"{path}: {event}: {exc}")
                    continue
                if not executable.startswith("/"):
                    errors.append(f"{path}: {event}: PATH-dependent command: {command}")
                elif not pathlib.Path(executable).exists():
                    errors.append(f"{path}: {event}: missing executable: {executable}")

if errors:
    print("\n".join(errors), file=sys.stderr)
    sys.exit(1)
PY
    ); then
        log_success "Agent hook commands use absolute executables"
    else
        log_error "Agent hook command validation failed"
        if [ -n "$output" ]; then
            printf '%s\n' "$output" | sed 's/^/  /'
        fi
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
    done < <(find dotfiles -name "*.yaml" -o -name "*.yml" -type f -not -path "*/.claude/commands/*" -print0)
    
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
    validate_agent_hook_commands
    
    echo
    log_info "Validation complete!"
    log_info "Errors: $ERRORS"
    log_info "Warnings: $WARNINGS"
    
    if [[ $ERRORS -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
