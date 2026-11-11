#!/usr/bin/env bash
# Stow this machine's private overlay, if it has one: $DOTFILES_OVERLAY (default
# ~/.dotfiles-overlay), a folder of stow packages laid out like dotfiles/. Its `packages`
# file lists one "<package> <macos|linux|all>" per line. Host names, client work dirs and
# work identities live there, never in this repo. No overlay, or a link to a volume that
# is not mounted, is a no-op. Re-runnable.
#   stow-overlay.sh [--check] [package...]   only the listed packages named here
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
overlay="${DOTFILES_OVERLAY:-${HOME}/.dotfiles-overlay}"
mode=""
if [[ "${1:-}" == --check ]]; then mode=--check; shift; fi

if [[ ! -r "${overlay}/packages" ]]; then
  if [[ -L "${overlay}" ]]; then
    echo "overlay: ${overlay} points at $(readlink "${overlay}"), which is not there; skipped"
  else
    echo "overlay: no overlay at ${overlay}; skipped"
  fi
  exit 0
fi

case "${PLATFORM:-$(uname -s)}" in Darwin | macos) platform=macos ;; *) platform=linux ;; esac
pkgs=""
while read -r pkg where _; do
  [[ -z "${pkg}" || "${pkg}" == \#* ]] && continue
  [[ "${where}" == all || "${where}" == "${platform}" ]] || continue
  [[ $# -eq 0 || " $* " == *" ${pkg} "* ]] || continue
  pkgs="${pkgs} ${pkg}"
done <"${overlay}/packages"
[[ -n "${pkgs}" ]] || exit 0

# Word splitting is the point: package names have no spaces. No arrays, for macOS bash 3.2.
# shellcheck disable=SC2086
DOTFILES_PKG_DIR="${overlay}" "${here}/stow-package.sh" ${mode} ${pkgs}
