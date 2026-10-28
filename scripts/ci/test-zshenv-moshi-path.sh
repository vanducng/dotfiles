#!/usr/bin/env bash
# Guard: Moshi SSH probes only load .zshenv (not .zshrc). Homebrew +
# ~/.local/bin must be on PATH there or herdr/tmux/mosh-server look missing.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ZSHENV="$ROOT/dotfiles/zsh/.zshenv"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

[[ -f "$ZSHENV" ]] || fail "missing $ZSHENV"

grep -q 'opt/homebrew/bin' "$ZSHENV" || fail ".zshenv must prepend Homebrew for Apple Silicon"
grep -q '\.local/bin' "$ZSHENV" || fail ".zshenv must prepend ~/.local/bin for herdr"
grep -q 'cargo/env' "$ZSHENV" || fail ".zshenv should still load cargo/env"
pass "zshenv declares Moshi SSH PATH contract"

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/zshenv-moshi.XXXXXX")"
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT

mkdir -p "$tmpdir/home/.local/bin" "$tmpdir/brew/bin" "$tmpdir/brew/sbin"
for b in herdr tmux mosh-server; do
  if [[ "$b" == herdr ]]; then
    dest="$tmpdir/home/.local/bin/$b"
  else
    dest="$tmpdir/brew/bin/$b"
  fi
  printf '#!/bin/sh\n' >"$dest"
  chmod +x "$dest"
done

# Mirror the .zshenv contract with fake HOME / brew roots (no real user paths).
sim="$tmpdir/zshenv"
cat >"$sim" <<EOF
if [ -d "$tmpdir/brew/bin" ]; then
  PATH="$tmpdir/brew/bin:$tmpdir/brew/sbin:\${PATH}"
fi
PATH="$tmpdir/home/.local/bin:\${PATH}"
export PATH
EOF

# PATH contract is POSIX; use bash so Linux CI does not need zsh installed.
out="$(
  PATH=/usr/bin:/bin HOME="$tmpdir/home" bash -c \
    ". \"$sim\"; command -v herdr; command -v tmux; command -v mosh-server"
)"
printf '%s\n' "$out" | grep -qx "$tmpdir/home/.local/bin/herdr" || fail "herdr not on PATH after .zshenv"
printf '%s\n' "$out" | grep -qx "$tmpdir/brew/bin/tmux" || fail "tmux not on PATH after .zshenv"
printf '%s\n' "$out" | grep -qx "$tmpdir/brew/bin/mosh-server" || fail "mosh-server not on PATH after .zshenv"
pass "non-interactive PATH exposes herdr/tmux/mosh-server"

echo "zshenv-moshi-path test: ok"
