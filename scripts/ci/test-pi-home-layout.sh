#!/usr/bin/env bash
# Prove pi-home-layout.sh is idempotent and does not assume a Linux store path.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="${ROOT}/scripts/pi-home-layout.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

snapshot() {
  python3 -c 'import os, sys
path = sys.argv[1]
if os.path.islink(path) or os.path.exists(path):
    print(os.path.realpath(path), os.lstat(path).st_ino, os.readlink(path) if os.path.islink(path) else "")
else:
    print("missing")
' "$1"
}

[[ -x "$SCRIPT" ]] || chmod +x "$SCRIPT"
bash -n "$SCRIPT" || fail "pi-home-layout.sh syntax"
pass "pi-home-layout.sh parses"

command -v stow >/dev/null 2>&1 || fail "stow is required"
command -v python3 >/dev/null 2>&1 || fail "python3 is required"

assert_real_pi() {
  local home="$1"
  [[ -d "${home}/.pi" ]] || fail "${home}/.pi is not a directory"
  [[ ! -L "${home}/.pi" ]] || fail "${home}/.pi is a symlink"
  [[ -e "${home}/.pi/agent/themes/rose-pine-moon.json" ]] || fail "theme missing in ${home}"
  [[ -e "${home}/.pi/agent/extensions/subagent/config.json" ]] || fail "subagent config missing in ${home}"
}

workdir="$(mktemp -d "${TMPDIR:-/tmp}/pi-home-layout-test.XXXXXX")"
trap 'rm -rf -- "$workdir"' EXIT

fresh="${workdir}/fresh"
mkdir -p "$fresh"
HOME="$fresh" "$SCRIPT" >/dev/null
assert_real_pi "$fresh"
[[ ! -e "${fresh}/work/store/pi" ]] || fail "fresh home created a store"
before="$(snapshot "${fresh}/.pi/agent/themes/rose-pine-moon.json")"
HOME="$fresh" "$SCRIPT" >/dev/null
assert_real_pi "$fresh"
after="$(snapshot "${fresh}/.pi/agent/themes/rose-pine-moon.json")"
[[ "$before" == "$after" ]] || fail "second run mutated the theme link: ${before} -> ${after}"
pass "fresh home is idempotent and creates no store"

reloc="${workdir}/reloc"
store="${reloc}/var/pi-store"
mkdir -p "${store}/agent/npm" "${store}/agent/sessions"
echo store-npm >"${store}/agent/npm/marker"
ln -s "$store" "${reloc}/.pi"
HOME="$reloc" "$SCRIPT" >/dev/null
assert_real_pi "$reloc"
[[ -L "${reloc}/.pi/agent/npm" ]] || fail "npm was not linked to the unwrapped store"
[[ -L "${reloc}/.pi/agent/sessions" ]] || fail "sessions was not linked to the unwrapped store"
[[ -d "${store}/agent/npm" ]] || fail "store npm dir was lost"
npm_before="$(snapshot "${reloc}/.pi/agent/npm")"
HOME="$reloc" "$SCRIPT" >/dev/null
assert_real_pi "$reloc"
npm_after="$(snapshot "${reloc}/.pi/agent/npm")"
[[ "$npm_before" == "$npm_after" ]] || fail "second unwrap run mutated npm: ${npm_before} -> ${npm_after}"
pass "wholesale ~/.pi symlink unwraps and stays idempotent"

explicit="${workdir}/explicit"
custom="${workdir}/custom-store"
mkdir -p "${explicit}" "${custom}/agent/git"
HOME="$explicit" PI_STORE="$custom" "$SCRIPT" >/dev/null
assert_real_pi "$explicit"
[[ -L "${explicit}/.pi/agent/git" ]] || fail "PI_STORE git dir was not linked"
git_before="$(snapshot "${explicit}/.pi/agent/git")"
HOME="$explicit" PI_STORE="$custom" "$SCRIPT" >/dev/null
assert_real_pi "$explicit"
git_after="$(snapshot "${explicit}/.pi/agent/git")"
[[ "$git_before" == "$git_after" ]] || fail "second PI_STORE run mutated git: ${git_before} -> ${git_after}"
pass "PI_STORE is honored and idempotent"

migrate="${workdir}/migrate"
empty_store="${workdir}/empty-store"
mkdir -p "${migrate}/.pi/agent/npm"
echo payload >"${migrate}/.pi/agent/npm/kept.txt"
HOME="$migrate" PI_STORE="$empty_store" "$SCRIPT" >/dev/null
assert_real_pi "$migrate"
[[ -L "${migrate}/.pi/agent/npm" ]] || fail "migrate did not replace npm with a store link"
[[ -f "${empty_store}/agent/npm/kept.txt" ]] || fail "migrate did not move npm contents into the store"
[[ "$(cat "${empty_store}/agent/npm/kept.txt")" == payload ]] || fail "migrated npm contents changed"
pass "PI_STORE migrates an existing local npm dir"

conflict="${workdir}/conflict"
conflict_store="${conflict}/old-store"
other_store="${workdir}/other-store"
mkdir -p "${conflict_store}/agent/npm" "$other_store"
ln -s "$conflict_store" "${conflict}/.pi"
if HOME="$conflict" PI_STORE="$other_store" "$SCRIPT" >/dev/null 2>"${workdir}/conflict.err"; then
  fail "expected PI_STORE vs unwrapped store to be a hard error"
fi
grep -q 'differs from unwrapped' "${workdir}/conflict.err" || fail "conflict error did not mention unwrapped store"
pass "PI_STORE conflict with an unwrapped symlink is a hard error"

HOME="$explicit" PI_STORE="$custom" "$SCRIPT" --uninstall >/dev/null
[[ ! -e "${explicit}/.pi/agent/settings.json" ]] || fail "uninstall left stow settings"
[[ ! -L "${explicit}/.pi/agent/git" ]] || fail "uninstall left the git store link"
[[ -d "${custom}/agent/git" ]] || fail "uninstall deleted store data"
[[ -d "${explicit}/.pi" ]] || fail "uninstall removed ~/.pi"
pass "uninstall removes stow files and store links only"

echo "test-pi-home-layout: OK"
