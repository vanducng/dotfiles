#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$project_root/scripts/release.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir "$work/tmp"
export HOME="$work" TMPDIR="$work/tmp" GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
cd "$work"

git init -q --bare -b main origin.git
git clone -q origin.git up 2>/dev/null
printf '1\n2\n3\n4\n5\n6\n' >up/a
printf 'x\n' >up/b
printf 'y\n' >up/c
printf 'old\n' >up/0-gone
git -C up add . && git -C up commit -qm seed && git -C up push -q origin main
git clone -q origin.git box

printf 'one\n2\n3\n4\n5\n6\n' >up/a
printf 'upstream\n' >up/b
git -C up rm -q 0-gone
git -C up commit -qam upstream && git -C up push -q origin main

printf '1\n2\n3\n4\n5\nsix\n' >box/a
printf 'local\n' >box/b
printf 'mine\n' >box/c
printf 'secret\n' >box/0-gone
# Machines run the sync with macOS /bin/bash 3.2.
out="$(/bin/bash "$script" --sync "$work/box" 2>&1)"

[ "$(git -C box rev-parse HEAD)" = "$(git -C up rev-parse HEAD)" ] || { echo "FAIL: box not fast-forwarded"; exit 1; }
[ "$(cat box/a)" = "$(printf 'one\n2\n3\n4\n5\nsix')" ] || { echo "FAIL: local edit not carried over"; cat box/a; exit 1; }
[ "$(cat box/b)" = local ] || { echo "FAIL: conflicting local file not kept"; exit 1; }
[ "$(cat box/c)" = mine ] || { echo "FAIL: untouched local edit lost"; exit 1; }
[ -z "$(git -C box diff --cached --name-only)" ] || { echo "FAIL: sync left files staged"; exit 1; }
grep -q "kept the local b" <<<"$out" || { echo "FAIL: no warning for b: $out"; exit 1; }
[ "$(cat box/0-gone)" = secret ] || { echo "FAIL: edit to a file deleted upstream lost"; exit 1; }

# A failed pull (an untracked file in the way) puts every lifted edit back.
printf 'more\n' >>up/a
printf 'theirs\n' >up/new
git -C up add new && git -C up commit -qam more && git -C up push -q origin main
printf 'ours\n' >box/new
before="$(cat box/a)"
if /bin/bash "$script" --sync "$work/box" >/dev/null 2>&1; then echo "FAIL: pull over an untracked file succeeded"; exit 1; fi
[ "$(cat box/a)" = "$before" ] || { echo "FAIL: edit lost after a failed pull"; exit 1; }

rm box/new
/bin/bash "$script" --sync "$work/box" >/dev/null 2>&1
[ "$(git -C box rev-parse HEAD)" = "$(git -C up rev-parse HEAD)" ] || { echo "FAIL: retry did not fast-forward"; exit 1; }
[ -z "$(ls -A "$TMPDIR")" ] || { echo "FAIL: temp copies left behind"; ls -A "$TMPDIR"; exit 1; }
echo "release sync: ok"
