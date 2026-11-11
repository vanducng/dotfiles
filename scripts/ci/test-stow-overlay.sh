#!/usr/bin/env bash
# stow-overlay.sh: no overlay or a dangling link is a no-op; a present overlay stows the
# packages its `packages` file lists for this platform, and --check reports their drift.
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
command -v stow >/dev/null 2>&1 || { echo "SKIP: stow not installed"; exit 0; }
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
repo="$work/repo"
overlay="$work/overlay"
export HOME="$work/home"
mkdir -p "$HOME" "$repo/scripts" "$overlay/both/.cfg" "$overlay/other/.cfg"
cp "$project_root/scripts/stow-package.sh" "$project_root/scripts/stow-overlay.sh" "$repo/scripts/"
case "$(uname -s)" in Darwin) here=macos there=linux ;; *) here=linux there=macos ;; esac
printf '# package platform\nboth all\nother %s\n' "$there" >"$overlay/packages"
printf 'a\n' >"$overlay/both/.cfg/one"
printf 'b\n' >"$overlay/other/.cfg/two"
git -C "$overlay" init -q && git -C "$overlay" add . && git -C "$overlay" -c user.name=t -c user.email=t@t commit -qm seed
run() { DOTFILES_OVERLAY="$1" "$repo/scripts/stow-overlay.sh" "${@:2}" 2>&1; }

out="$(run "$work/none")" || fail "no overlay exited non-zero: $out"
[[ "$out" == *"no overlay"* ]] || fail "no overlay message: $out"
ln -s "$work/unmounted" "$work/dangling"
out="$(run "$work/dangling")" || fail "dangling link exited non-zero: $out"
[[ "$out" == *"not there"* ]] || fail "dangling link message: $out"

out="$(run "$overlay" --check)" && fail "--check before stowing exited 0: $out"
[[ "$out" == *"~/.cfg/one is not linked from both"* ]] || fail "--check drift: $out"

mkdir -p "$HOME/.cfg"
ln -s "$work/gone/one" "$HOME/.cfg/one"   # a link left behind when the file left dotfiles
run "$overlay" >/dev/null || fail "stow failed"
[ "$(cat "$HOME/.cfg/one")" = a ] || fail "both/.cfg/one not linked"
[ ! -e "$HOME/.cfg/two" ] || fail "a package for the other platform was stowed"
run "$overlay" --check >/dev/null || fail "--check after stowing reported drift"
run "$overlay" "$here-only" >/dev/null || fail "a filter naming no listed package failed"
out="$(run "$overlay" '*')" || fail "a glob argument failed: $out"
[[ "$out" != *Stowing* ]] || fail "a glob argument matched a package: $out"

# An overlay that is not a git work tree must fail loudly, not report "no drift".
plain="$work/plain"
mkdir -p "$plain/both/.cfg"
printf 'both all\n' >"$plain/packages"
printf 'p\n' >"$plain/both/.cfg/p"
out="$(run "$plain" --check)" && fail "--check on a non-git overlay exited 0: $out"
[[ "$out" == *"not a git work tree"* ]] || fail "non-git overlay message: $out"
echo "stow-overlay: ok"
