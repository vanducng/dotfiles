# Contributing to Dotfiles

## Quick Start

```bash
# Clone and setup
git clone <repo>
cd dotfiles

# Run tests before making changes
./scripts/ci/validate.sh
./scripts/ci/check-dependencies.sh

# Make your changes
# ...

# Test your changes
./scripts/ci/test-install.sh

# Commit with conventional commits
git commit -m "feat(tool): add new feature"
```

## Development Workflow

### 1. Adding a New Tool

```bash
# Create tool directory structure
mkdir -p dotfiles/newtool/.config/newtool

# Add configuration files
# ...

# Update Makefile to include new tool
# Add stow-newtool and unstow-newtool targets

# Test installation
make stow-newtool

# Update platform matrix if needed
vim tests/ci/platform-matrix.json
```

### 2. Modifying Existing Tools

```bash
# Make changes
vim dotfiles/toolname/.config/toolname/config

# Validate syntax
./scripts/ci/validate.sh

# Test installation
TEST_HOME=/tmp/test make stow-toolname

# Run full test suite
./scripts/ci/test-install.sh
```

### 3. Testing Changes

**Local Testing:**
```bash
# Syntax validation
./scripts/ci/validate.sh

# Dependency check
./scripts/ci/check-dependencies.sh

# Installation test
./scripts/ci/test-install.sh

# Platform compatibility
./scripts/ci/test-platforms.sh
```

**Docker Testing:**
```bash
# Test on Ubuntu
docker build -t test:ubuntu -f tests/ci/Dockerfile.ubuntu .
docker run --rm test:ubuntu

# Test on Arch
docker build -t test:arch -f tests/ci/Dockerfile.arch .
docker run --rm test:arch
```

## Commit Guidelines

Use conventional commits:

- `feat(tool):` New features
- `fix(tool):` Bug fixes
- `docs:` Documentation changes
- `chore:` Maintenance tasks
- `refactor:` Code restructuring
- `test:` Test additions/changes

Examples:
```bash
git commit -m "feat(nvim): add markdown preview plugin"
git commit -m "fix(tmux): correct status bar colors"
git commit -m "docs: update installation instructions"
```

## CI/CD Pipeline

All PRs must pass:

1. ✅ Syntax validation
2. ✅ Dependency checks
3. ✅ Installation tests
4. ✅ Linting (ShellCheck, LuaCheck)
5. ✅ Security scan
6. ✅ Documentation validation

## Platform Compatibility

When adding macOS-only tools:

1. Add to `excluded_tools` in `platform-matrix.json`
2. Document platform requirement in tool README
3. Add platform check in installation script

## Best Practices

### Configuration Files

- Use consistent formatting
- Add comments for complex configurations
- Follow existing patterns in the repository
- Test on fresh systems

### Shell Scripts

- Use `set -euo pipefail`
- Add proper error handling
- Include help text
- Make scripts POSIX-compatible when possible

### Documentation

- Update README when adding tools
- Document non-obvious configurations
- Include examples
- Keep it concise

## Testing Checklist

Before submitting PR:

- [ ] Syntax validation passes
- [ ] Installation works on clean system
- [ ] No hardcoded paths
- [ ] Documentation updated
- [ ] Conventional commit messages
- [ ] Platform compatibility checked
- [ ] No secrets or sensitive data

## Getting Help

- Check existing issues
- Review CI logs for failures
- Ask in discussions
- Reference documentation in `/docs`