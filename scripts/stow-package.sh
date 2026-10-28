#!/usr/bin/env bash
# Stow one or more packages into $HOME. Re-runnable.
# A plain file (or foreign symlink) in the way is moved to $DOTFILES_BACKUP_DIR
# first, then the package is restowed in one atomic step, so a conflict never
# leaves the old links deleted.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${DOTFILES_BACKUP_DIR:-${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"
cd "${REPO_ROOT}/dotfiles"

conflicts() {
  stow --no-folding -n -R -t "${HOME}" "$1" 2>&1 | sed -nE \
    -e 's/.* over existing target (.*) since neither a link nor a directory.*/\1/p' \
    -e 's/.*existing target is not owned by stow: (.*)$/\1/p' \
    -e 's/.*existing target is neither a link nor a directory: (.*)$/\1/p'
}

failed=()
for pkg in "$@"; do
  echo "Stowing ${pkg}"
  while IFS= read -r target; do
    [[ -n "${target}" && ( -e "${HOME}/${target}" || -L "${HOME}/${target}" ) ]] || continue
    mkdir -p "$(dirname "${BACKUP_DIR}/${target}")"
    mv "${HOME}/${target}" "${BACKUP_DIR}/${target}"
    echo "  backed up ~/${target} -> ${BACKUP_DIR}/${target}"
  done < <(conflicts "${pkg}")
  stow --no-folding -R -t "${HOME}" "${pkg}" || failed+=("${pkg}")
done

if ((${#failed[@]})); then
  echo "stow failed for: ${failed[*]}" >&2
  exit 1
fi
