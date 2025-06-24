# CI Scripts

Quick reference for CI/CD testing scripts.

## Scripts

### `validate.sh`
Validates syntax of all configuration files.

```bash
./validate.sh
```

**Checks:**
- JSON files (using `jq`)
- YAML files (using `yq` or Python)
- TOML files (using Python)
- Lua files (using `luac`)
- Shell scripts (using `shellcheck`)

### `check-dependencies.sh`
Verifies required and optional tools are installed.

```bash
./check-dependencies.sh
```

**Categories:**
- Required tools (must have)
- Optional tools (nice to have)
- Platform-specific tools

### `test-install.sh`
Tests the stow installation process.

```bash
# Test in isolated environment
./test-install.sh

# Test with custom home
TEST_HOME=/tmp/test ./test-install.sh
```

### `test-platforms.sh`
Cross-platform compatibility testing.

```bash
# Test current platform
./test-platforms.sh

# Test with Docker
./test-platforms.sh --docker

# Test specific platform
./test-platforms.sh --platform ubuntu
```

## Quick Testing

```bash
# Run all tests
make test

# Run specific test
./validate.sh && ./test-install.sh

# Test in Docker
docker build -t test -f ../../tests/ci/Dockerfile.ubuntu ../..
docker run --rm test
```

## Exit Codes

- `0`: All tests passed
- `1`: One or more tests failed
- `2`: Missing dependencies
- `3`: Invalid arguments

## Environment Variables

- `DEBUG=1`: Enable verbose output
- `TEST_HOME`: Override test directory
- `NO_COLOR=1`: Disable colored output