# CI/CD Documentation

## Overview

This dotfiles repository implements a comprehensive CI/CD pipeline to ensure configuration quality, cross-platform compatibility, and reliable deployments. The system validates syntax, tests installations, and maintains security standards across multiple platforms.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Validation    │────▶│   Installation   │────▶│    Release      │
│  (Syntax/Lint)  │     │    Testing       │     │   Automation    │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │                       │                         │
         ▼                       ▼                         ▼
   ┌──────────┐           ┌──────────┐             ┌──────────┐
   │  JSON    │           │  Ubuntu  │             │  GitHub  │
   │  YAML    │           │  macOS   │             │ Release  │
   │  TOML    │           │  Arch    │             │ Archive  │
   │  Lua     │           │  Docker  │             │  Notes   │
   │  Shell   │           └──────────┘             └──────────┘
   └──────────┘
```

## Components

### 1. Validation Framework (`scripts/ci/validate.sh`)

Validates configuration file syntax across all supported formats:

- **JSON**: Using `jq`
- **YAML**: Using `yq` or Python `yaml`
- **TOML**: Using Python `tomllib` (3.11+) or `toml`
- **Lua**: Using `luac` or `lua`
- **Shell**: Using `shellcheck` or `bash -n`

```bash
# Run validation locally
./scripts/ci/validate.sh
```

### 2. Dependency Checker (`scripts/ci/check-dependencies.sh`)

Verifies required and optional tools are available:

- **Required**: Core tools needed for basic functionality
- **Optional**: Enhanced features and tool-specific dependencies
- **Platform-specific**: Tools exclusive to certain operating systems

```bash
# Check dependencies
./scripts/ci/check-dependencies.sh
```

### 3. Installation Testing (`scripts/ci/test-install.sh`)

Tests the stow-based installation process:

- Creates isolated test environment
- Validates symlink creation
- Tests individual tool installation
- Verifies full installation workflow

```bash
# Test installation
./scripts/ci/test-install.sh
```

### 4. Platform Testing (`scripts/ci/test-platforms.sh`)

Cross-platform compatibility validation:

- Platform detection (macOS, Ubuntu, Arch)
- Tool compatibility matrix
- Docker-based testing for Linux distributions
- Platform-specific exclusions

```bash
# Test current platform
./scripts/ci/test-platforms.sh

# Test with Docker
./scripts/ci/test-platforms.sh --docker

# Test specific platform
./scripts/ci/test-platforms.sh --platform ubuntu
```

## GitHub Actions Workflows

### Main CI Pipeline (`.github/workflows/ci.yml`)

Runs on all pushes and PRs:

1. **Syntax Validation**: Checks all config files
2. **Dependency Check**: Verifies tool availability
3. **Installation Test**: Tests stow process
4. **Linting**: ShellCheck and LuaCheck
5. **Documentation**: Validates markdown and links
6. **Security Scan**: Checks for secrets and permissions

### PR Validation (`.github/workflows/pr-validation.yml`)

Specialized checks for pull requests:

- Detects changed tools
- Validates only modified configurations
- Tests installation of changed tools
- Posts validation summary as PR comment

### Release Automation (`.github/workflows/release.yml`)

Handles version releases:

- Generates changelog from commits
- Creates release archives
- Publishes GitHub releases
- Updates documentation

## Platform Support

### Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| macOS (latest) | ✅ Full | All tools supported |
| macOS (13) | ✅ Full | Legacy support |
| Ubuntu (latest) | ✅ Partial | Excludes macOS-only tools |
| Ubuntu (22.04) | ✅ Partial | LTS support |
| Arch Linux | ✅ Partial | Via Docker testing |

### Platform-Specific Tools

**macOS Only:**
- `hammerspoon` - Automation framework
- `karabiner` - Keyboard customization
- `skhd` - Hotkey daemon
- `yabai` - Window manager
- `sketchybar` - Status bar

**Cross-Platform:**
- All other tools in the repository

## Local Development

### Running Tests Locally

```bash
# Full test suite
make test

# Individual components
./scripts/ci/validate.sh
./scripts/ci/check-dependencies.sh
./scripts/ci/test-install.sh

# Platform testing
./scripts/ci/test-platforms.sh

# Docker-based testing
docker build -t dotfiles-test:ubuntu -f tests/ci/Dockerfile.ubuntu .
docker run --rm dotfiles-test:ubuntu
```

### Pre-commit Hooks

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
./scripts/ci/validate.sh || exit 1
```

## Security Considerations

The CI pipeline includes several security measures:

1. **Secret Detection**: Scans for API keys, passwords, tokens
2. **Permission Validation**: Ensures files don't have overly permissive modes
3. **Dependency Verification**: Checks tool sources and versions
4. **Isolated Testing**: Uses temporary directories and Docker containers

## Troubleshooting

### Common Issues

**Validation Failures:**
- Ensure required tools are installed (`jq`, `yq`, etc.)
- Check file syntax matches expected format
- Run validators individually to isolate issues

**Installation Test Failures:**
- Verify GNU Stow is installed
- Check for existing files blocking symlinks
- Ensure proper permissions in home directory

**Platform Test Failures:**
- Confirm platform detection is correct
- Check tool compatibility matrix
- Review platform-specific exclusions

### Debug Mode

Enable verbose output:

```bash
# Add debug flag to any script
DEBUG=1 ./scripts/ci/validate.sh

# Or use bash -x
bash -x ./scripts/ci/test-install.sh
```

## Contributing

When adding new tools or configurations:

1. Update `platform-matrix.json` with compatibility info
2. Add appropriate validation in `validate.sh`
3. Test on multiple platforms using Docker
4. Ensure CI passes before submitting PR

## Maintenance

### Regular Tasks

- Update Docker base images quarterly
- Review and update tool versions
- Audit security scan rules
- Update platform compatibility matrix

### CI Performance

Current metrics:
- Full CI run: ~3-5 minutes
- PR validation: ~2 minutes
- Docker tests: ~5-7 minutes per platform

Optimization opportunities:
- Cache Docker layers
- Parallelize platform tests
- Skip unchanged tool validation