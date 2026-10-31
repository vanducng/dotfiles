#!/usr/bin/env bash
# Install the pinned mise toolset, then repoint files that baked a node path
# mise no longer has (OpenRig writes process.execPath into seat hooks and its
# rig wrapper). Run on every host after pulling a pin bump. Re-runnable.
set -euo pipefail

PROJECTS_ROOT="${PROJECTS_ROOT:-${HOME}/projects}"
OPENRIG_HOME="${OPENRIG_HOME:-${HOME}/.openrig}"
cd "${HOME}"

# linux.toml sets libc=musl for aqua bins; it also picks musl node/python, which glibc hosts cannot exec.
if [[ "$(uname -s)" == Linux ]]; then
  MISE_LIBC=gnu mise install -y node python
fi
mise install -y
node_bin="$(mise where node)/bin/node"
[[ -x "${node_bin}" ]] || { echo "pinned node missing: ${node_bin}" >&2; exit 1; }
echo "node: ${node_bin} ($("${node_bin}" -v))"

npm_globals() {
  local f
  for f in "$1"/lib/node_modules/*/package.json "$1"/lib/node_modules/@*/*/package.json; do
    [[ -f "${f}" ]] || continue
    if [[ -L "$(dirname "${f}")" ]]; then
      echo "npm global: $(basename "$(dirname "${f}")") is npm-linked under $1; relink it on the pin by hand" >&2
      continue
    fi
    "${node_bin}" -p 'const p = require(process.argv[1]); p.name + " " + p.version' "${f}" 2>/dev/null || true
  done | { grep -vE '^(npm|corepack) ' || true; }
}

version_gt() {
  [[ "$1" != "$2" && "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -1)" == "$1" ]]
}

newest_unpinned_globals() {
  local prefix
  for prefix in "$(dirname "${node_prefix}")"/*; do
    [[ -L "${prefix}" || "${prefix}" == "${node_prefix}" || ! -d "${prefix}/lib/node_modules" ]] || npm_globals "${prefix}"
  done | sort -k1,1 -k2,2V | awk '{v[$1] = $2} END {for (n in v) print n, v[n]}'
}

# Global npm CLIs (pi, codex, plannotator) live in one node's prefix; carry the newest of each onto the pin.
node_prefix="$(dirname "$(dirname "${node_bin}")")"
pinned_globals="$(npm_globals "${node_prefix}")"
migrated=0
while read -r name version; do
  [[ -n "${name}" ]] || continue
  have="$(awk -v n="${name}" '$1 == n {print $2}' <<<"${pinned_globals}")"
  [[ -z "${have}" ]] || version_gt "${version}" "${have}" || continue
  echo "npm global: ${name}@${version} -> $(basename "${node_prefix}")"
  if NPM_CONFIG_PREFIX="" PATH="${node_prefix}/bin:${PATH}" npm install -g --loglevel=error --prefix "${node_prefix}" "${name}@${version}" >/dev/null; then
    migrated=$((migrated + 1))
  else
    echo "npm global: ${name}@${version} failed to install" >&2
  fi
done < <(newest_unpinned_globals)
echo "npm globals migrated: ${migrated}"

candidates() {
  local root
  for root in "${OPENRIG_HOME}" "${PROJECTS_ROOT}"; do
    [[ -d "${root}" ]] || continue
    find "${root}/" \( -name node_modules -o -name .cache -o -name .worktrees -o -name .git \) -prune \
      -o -path '*/.claude/settings*.json' -type f -print 2>/dev/null
  done
  [[ -f "${HOME}/.local/bin/rig" ]] && echo "${HOME}/.local/bin/rig"
}

fixed=0
while IFS= read -r file; do
  stale=0
  while IFS= read -r path; do
    [[ -x "${path}" ]] || stale=1
  done < <(grep -oE '/[^"'\'' ]*/mise/installs/node/[^/"'\'' ]+/bin/node' "${file}" | sort -u)
  [[ "${stale}" == 1 ]] || continue
  NODE_BIN="${node_bin}" perl -pi -e \
    's{/[^"'\'' ]*/mise/installs/node/[^/"'\'' ]+/bin/node}{-x $& ? $& : $ENV{NODE_BIN}}ge' "${file}"
  echo "repointed: ${file}"
  fixed=$((fixed + 1))
done < <(candidates)
echo "files repointed: ${fixed}"

daemon_node="$(ps -axo command= | awk '/@openrig\/cli\/daemon\/dist\/index.js/ && !/awk/ && !seen++ {print $1}')"
if [[ -n "${daemon_node}" && ! -x "${daemon_node}" ]]; then
  echo "OpenRig daemon runs a removed node (${daemon_node}); restart it: rig daemon stop && rig daemon start" >&2
fi
