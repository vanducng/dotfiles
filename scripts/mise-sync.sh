#!/usr/bin/env bash
# Install the pinned mise toolset, then repoint files that baked any other node
# path (OpenRig writes process.execPath into seat hooks and its rig wrapper).
# Run on every host after pulling a pin bump. Re-runnable.
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

candidates() {
  local root
  for root in "${OPENRIG_HOME}" "${PROJECTS_ROOT}"; do
    [[ -d "${root}" ]] || continue
    find "${root}/" \( -name node_modules -o -name .cache -o -name .worktrees -o -name .git \) -prune \
      -o -path '*/.claude/settings*.json' -type f -print 2>/dev/null
  done
  [[ -f "${HOME}/.local/bin/rig" ]] && echo "${HOME}/.local/bin/rig"
}

node_path_re='/[^"'\'' ]*/mise/installs/node/[^/"'\'' ]+/bin/node'
fixed=0
while IFS= read -r file; do
  paths="$(grep -oE "${node_path_re}" "${file}" || true)"
  if [[ -z "${paths}" ]] || ! grep -qvxF "${node_bin}" <<<"${paths}"; then continue; fi
  NODE_BIN="${node_bin}" RE="${node_path_re}" perl -pi -e 's{$ENV{RE}}{$ENV{NODE_BIN}}g' "${file}"
  echo "repointed: ${file}"
  fixed=$((fixed + 1))
done < <(candidates)
echo "files repointed: ${fixed}"

daemon_node="$(ps -axo command= | awk '/@openrig\/cli\/daemon\/dist\/index.js/ && !/awk/ && !seen++ {print $1}')"
if [[ -n "${daemon_node}" && "$(realpath "${daemon_node}" 2>/dev/null)" != "$(realpath "${node_bin}")" ]]; then
  echo "OpenRig daemon runs ${daemon_node}; restart it (rig daemon stop, then start with its usual flags)" >&2
fi
