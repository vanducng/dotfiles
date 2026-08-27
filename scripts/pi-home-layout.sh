#!/usr/bin/env bash
# Idempotent pi home layout for Linux and macOS.
# ~/.pi stays a real directory under $HOME so stow relative links and
# pi-subagents schedule roots resolve inside the home directory.
# A wholesale ~/.pi symlink is unwrapped; only npm/sessions/git may live
# on a runtime store. Never creates a store unless one already exists or
# PI_STORE is set.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PI_HOME="${HOME}/.pi"
STORE=""
UNWRAPPED=0
MAY_MIGRATE=0

log() { printf 'pi-home-layout: %s\n' "$*"; }

die() {
  printf 'pi-home-layout: %s\n' "$*" >&2
  exit 1
}

realpath_portable() {
  python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"
}

infer_store() {
  local candidate="${HOME}/work/store/pi"
  if [[ -d "${candidate}/agent/npm" || -d "${candidate}/agent/sessions" || -d "${candidate}/agent/git" ]]; then
    printf '%s\n' "$candidate"
  fi
}

if ! command -v stow >/dev/null 2>&1; then
  die "stow is required"
fi

if [[ -L "$PI_HOME" ]]; then
  STORE="$(realpath_portable "$PI_HOME")"
  UNWRAPPED=1
  MAY_MIGRATE=1
  log "replacing ~/.pi symlink with a real directory; bulky runtime stays at $STORE"
  rm "$PI_HOME"
fi

if [[ -n "${PI_STORE:-}" ]]; then
  STORE="$PI_STORE"
  MAY_MIGRATE=1
elif [[ $UNWRAPPED -eq 0 ]]; then
  STORE="$(infer_store || true)"
fi

mkdir -p "$PI_HOME"

(
  cd "${REPO_ROOT}/dotfiles"
  stow --no-folding -D -t "${HOME}" pi 2>/dev/null || true
  stow --no-folding -t "${HOME}" pi
)

mkdir -p "${PI_HOME}/agent/extensions"

link_store_dir() {
  local name="$1"
  [[ -n "$STORE" ]] || return 0
  local dest="${PI_HOME}/agent/${name}"
  local src="${STORE}/agent/${name}"

  if [[ -L "$dest" ]]; then
    ln -sfn "$src" "$dest"
    return
  fi
  if [[ $MAY_MIGRATE -eq 1 && -d "$dest" && ! -L "$dest" && ! -e "$src" ]]; then
    mkdir -p "$(dirname "$src")"
    mv "$dest" "$src"
  fi
  if [[ -d "$src" ]]; then
    if [[ -d "$dest" && ! -L "$dest" ]]; then
      rmdir "$dest" 2>/dev/null || {
        log "${name} exists in \$HOME and is not empty; leaving it"
        return 0
      }
    fi
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$src" "$dest"
    log "linked ~/.pi/agent/${name} -> store"
  fi
}

if [[ -n "$STORE" ]]; then
  for name in npm sessions git; do
    link_store_dir "$name"
  done
fi

copy_if_missing() {
  local rel="$1"
  [[ -n "$STORE" ]] || return 0
  local src="${STORE}/agent/${rel}"
  local dest="${PI_HOME}/agent/${rel}"
  if [[ -e "$src" && ! -e "$dest" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp -a "$src" "$dest"
    log "copied ${rel} from store"
  fi
}

copy_if_missing auth.json
copy_if_missing models-store.json
copy_if_missing extensions/moshi-hooks.ts
copy_if_missing extensions/herdr-agent-state.ts

if [[ -n "$STORE" && -d "${STORE}/agent/skills" && ! -e "${PI_HOME}/agent/skills" ]]; then
  cp -a "${STORE}/agent/skills" "${PI_HOME}/agent/skills"
  log "copied agent/skills from store"
fi

theme="${PI_HOME}/agent/themes/rose-pine-moon.json"
if [[ -L "$PI_HOME" ]]; then
  die "~/.pi is still a symlink"
fi
if [[ ! -e "$theme" ]]; then
  die "theme missing or dangling: ${theme}"
fi

log "ok (~/.pi is a real directory; theme readable)"
