#!/usr/bin/env bash
# Prove pi-home-layout.sh is idempotent and does not assume a Linux store path.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="${ROOT}/scripts/pi-home-layout.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

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
HOME="$fresh" "$SCRIPT" >/dev/null
assert_real_pi "$fresh"
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
HOME="$reloc" "$SCRIPT" >/dev/null
assert_real_pi "$reloc"
[[ -L "${reloc}/.pi/agent/npm" ]] || fail "second run dropped the npm store link"
pass "wholesale ~/.pi symlink unwraps and stays idempotent"

explicit="${workdir}/explicit"
custom="${workdir}/custom-store"
mkdir -p "${explicit}" "${custom}/agent/git"
HOME="$explicit" PI_STORE="$custom" "$SCRIPT" >/dev/null
assert_real_pi "$explicit"
[[ -L "${explicit}/.pi/agent/git" ]] || fail "PI_STORE git dir was not linked"
HOME="$explicit" PI_STORE="$custom" "$SCRIPT" >/dev/null
assert_real_pi "$explicit"
pass "PI_STORE is honored and idempotent"

echo "test-pi-home-layout: OK"
