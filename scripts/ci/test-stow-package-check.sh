#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
command -v stow >/dev/null 2>&1 || { echo "SKIP: stow not installed"; exit 0; }
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
repo="$work/repo"
export HOME="$work/home"
mkdir -p "$HOME" "$repo/scripts" "$repo/dotfiles/pkg/.cfg"
cp "$project_root/scripts/stow-package.sh" "$repo/scripts/"
printf 'a\n' >"$repo/dotfiles/pkg/.cfg/linked"
printf 'b\n' >"$repo/dotfiles/pkg/.cfg/plain"
printf 'c\n' >"$repo/dotfiles/pkg/.cfg/absolute"
printf 'd\n' >"$repo/dotfiles/pkg/.cfg/missing"
git -C "$repo" init -q && git -C "$repo" add . && git -C "$repo" -c user.name=t -c user.email=t@t commit -qm seed
printf 'e\n' >"$repo/dotfiles/pkg/.cfg/untracked"
check() { "$repo/scripts/stow-package.sh" --check "$@" 2>&1; }

if check >/dev/null; then echo "FAIL: --check with no package succeeded"; exit 1; fi

mkdir -p "$HOME/.cfg"
ln -s ../../repo/dotfiles/pkg/.cfg/linked "$HOME/.cfg/linked"
printf 'local\n' >"$HOME/.cfg/plain"
ln -s "$repo/dotfiles/pkg/.cfg/absolute" "$HOME/.cfg/absolute"
out="$(check pkg)" && { echo "FAIL: drift exited 0: $out"; exit 1; }
want="$(printf 'drift: ~/.cfg/missing is not linked from pkg\ndrift: ~/.cfg/plain is not linked from pkg')"
[ "$out" = "$want" ] || { printf 'FAIL: got\n%s\nwant\n%s\n' "$out" "$want"; exit 1; }
[ "$(cat "$HOME/.cfg/plain")" = local ] || { echo "FAIL: --check changed a live file"; exit 1; }
[ ! -e "$HOME/.cfg/missing" ] || { echo "FAIL: --check created a link"; exit 1; }

rm "$HOME/.cfg/plain"
ln -s ../../repo/dotfiles/pkg/.cfg/plain "$HOME/.cfg/plain"
ln -s ../../repo/dotfiles/pkg/.cfg/missing "$HOME/.cfg/missing"
out="$(check pkg)" || { echo "FAIL: linked package reported drift: $out"; exit 1; }
[ -z "$out" ] || { echo "FAIL: unexpected output: $out"; exit 1; }
echo "stow-package --check: ok"
