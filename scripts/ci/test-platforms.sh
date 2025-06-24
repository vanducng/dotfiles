#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLATFORM_CONFIG="$PROJECT_ROOT/tests/ci/platform-matrix.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

detect_platform() {
    case "$OSTYPE" in
        darwin*) echo "macos" ;;
        linux*)
            if [[ -f /etc/os-release ]]; then
                # shellcheck source=/dev/null
                source /etc/os-release
                case "$ID" in
                    ubuntu|debian) echo "ubuntu" ;;
                    arch|manjaro) echo "arch" ;;
                    *) echo "linux" ;;
                esac
            else
                echo "linux"
            fi
            ;;
        *) echo "unknown" ;;
    esac
}

get_platform_tools() {
    local platform="$1"
    local all_tools=()
    mapfile -t all_tools < <(cd "$PROJECT_ROOT/dotfiles" && find . -maxdepth 1 -type d -not -name "." | cut -d'/' -f2)
    local excluded_tools=()
    
    # Get excluded tools for platform
    if [[ -f "$PLATFORM_CONFIG" ]]; then
        case "$platform" in
            ubuntu|arch)
                mapfile -t excluded_tools < <(jq -r '.platforms.ubuntu.excluded_tools[]' "$PLATFORM_CONFIG" 2>/dev/null || true)
                ;;
        esac
    fi
    
    # Filter out excluded tools
    local valid_tools=()
    for tool in "${all_tools[@]}"; do
        local excluded=false
        for exclude in "${excluded_tools[@]}"; do
            if [[ "$tool" == "$exclude" ]]; then
                excluded=true
                break
            fi
        done
        if [[ "$excluded" == "false" ]]; then
            valid_tools+=("$tool")
        fi
    done
    
    echo "${valid_tools[@]}"
}

test_tool_compatibility() {
    local tool="$1"
    local platform="$2"
    
    if [[ ! -f "$PLATFORM_CONFIG" ]]; then
        return 0
    fi
    
    # Check platform compatibility
    local compatible_platforms
    compatible_platforms=$(jq -r ".tool_compatibility.\"$tool\".platforms[]" "$PLATFORM_CONFIG" 2>/dev/null || echo "all")
    
    if [[ "$compatible_platforms" == "all" ]]; then
        return 0
    fi
    
    for compat_platform in $compatible_platforms; do
        if [[ "$compat_platform" == "$platform" ]]; then
            return 0
        fi
    done
    
    return 1
}

check_tool_dependencies() {
    local tool="$1"
    
    if [[ ! -f "$PLATFORM_CONFIG" ]]; then
        return 0
    fi
    
    local deps=$(jq -r ".tool_compatibility.\"$tool\".dependencies[]" "$PLATFORM_CONFIG" 2>/dev/null || true)
    local missing_deps=()
    
    for dep in $deps; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "$tool requires: ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

run_docker_tests() {
    local platform="$1"
    local dockerfile="$PROJECT_ROOT/tests/ci/Dockerfile.$platform"
    
    if [[ ! -f "$dockerfile" ]]; then
        log_error "No Dockerfile found for $platform"
        return 1
    fi
    
    log_info "Building Docker image for $platform..."
    if docker build -t "dotfiles-test:$platform" -f "$dockerfile" "$PROJECT_ROOT"; then
        log_success "Docker image built successfully"
        
        log_info "Running tests in Docker container..."
        if docker run --rm "dotfiles-test:$platform"; then
            log_success "Docker tests passed for $platform"
        else
            log_error "Docker tests failed for $platform"
            return 1
        fi
    else
        log_error "Failed to build Docker image for $platform"
        return 1
    fi
}

main() {
    local platform="${1:-$(detect_platform)}"
    local docker_mode="${2:-false}"
    
    echo -e "${BLUE}=== Platform Compatibility Test ===${NC}"
    echo "Platform: $platform"
    echo
    
    if [[ "$docker_mode" == "true" ]] && command -v docker >/dev/null 2>&1; then
        log_info "Running tests in Docker containers..."
        
        for test_platform in ubuntu arch; do
            echo
            log_info "Testing $test_platform platform..."
            run_docker_tests "$test_platform" || true
        done
    else
        log_info "Testing on current platform: $platform"
        
        local tools=($(get_platform_tools "$platform"))
        local passed=0
        local failed=0
        
        for tool in "${tools[@]}"; do
            echo -n "Testing $tool... "
            
            if ! test_tool_compatibility "$tool" "$platform"; then
                echo -e "${YELLOW}[SKIP]${NC} Not compatible with $platform"
                continue
            fi
            
            if ! check_tool_dependencies "$tool"; then
                echo -e "${RED}[FAIL]${NC} Missing dependencies"
                ((failed++))
                continue
            fi
            
            # Test stow installation
            TEST_HOME="/tmp/dotfiles-platform-test-$$"
            mkdir -p "$TEST_HOME"
            
            if HOME="$TEST_HOME" make -C "$PROJECT_ROOT" stow-$tool >/dev/null 2>&1; then
                echo -e "${GREEN}[PASS]${NC}"
                ((passed++))
                HOME="$TEST_HOME" make -C "$PROJECT_ROOT" unstow-$tool >/dev/null 2>&1 || true
            else
                echo -e "${RED}[FAIL]${NC}"
                ((failed++))
            fi
            
            rm -rf "$TEST_HOME"
        done
        
        echo
        log_info "Platform test complete!"
        log_info "Passed: $passed"
        log_info "Failed: $failed"
        
        if [[ $failed -gt 0 ]]; then
            exit 1
        fi
    fi
}

# Parse arguments
case "${1:-}" in
    --docker)
        main "$(detect_platform)" "true"
        ;;
    --platform)
        main "${2:-$(detect_platform)}" "false"
        ;;
    *)
        main "$@"
        ;;
esac