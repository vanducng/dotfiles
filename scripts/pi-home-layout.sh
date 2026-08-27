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
MODE="install"

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

if [[ "${1:-}" == "--uninstall" ]]; then
  MODE="uninstall"
elif [[ -n "${1:-}" ]]; then
  die "unknown argument: $1"
fi

if ! command -v stow >/dev/null 2>&1; then
  die "stow is required"
fi
if ! command -v python3 >/dev/null 2>&1; then
  die "python3 is required"
fi

uninstall_pi() {
  (
    cd "${REPO_ROOT}/dotfiles"
    stow -t "${HOME}" -D pi 2>/dev/null || true
  )
  local name dest
  for name in npm sessions git; do
    dest="${PI_HOME}/agent/${name}"
    if [[ -L "$dest" ]]; then
      rm "$dest"
      log "removed store link ~/.pi/agent/${name}"
    fi
  done
  log "ok (stow files and store links removed; ~/.pi left in place)"
}

if [[ "$MODE" == "uninstall" ]]; then
  uninstall_pi
  exit 0
fi

if [[ -L "$PI_HOME" ]]; then
  STORE="$(realpath_portable "$PI_HOME")"
  UNWRAPPED=1
  MAY_MIGRATE=1
  log "replacing ~/.pi symlink with a real directory; bulky runtime stays at $STORE"
  rm "$PI_HOME"
fi

if [[ -n "${PI_STORE:-}" ]]; then
  if [[ $UNWRAPPED -eq 1 ]]; then
    local_unwrapped="$STORE"
    local_explicit="$(realpath_portable "$PI_STORE")"
    if [[ "$local_unwrapped" != "$local_explicit" ]]; then
      die "PI_STORE (${PI_STORE}) differs from unwrapped ~/.pi (${local_unwrapped})"
    fi
  fi
  STORE="$PI_STORE"
  MAY_MIGRATE=1
elif [[ $UNWRAPPED -eq 0 ]]; then
  STORE="$(infer_store || true)"
fi

mkdir -p "$PI_HOME"
if [[ -L "$PI_HOME" ]]; then
  die "~/.pi is still a symlink"
fi

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
  local dest_real src_real

  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      return
    fi
    dest_real="$(realpath_portable "$dest" 2>/dev/null || readlink "$dest")"
    src_real="$(realpath_portable "$src" 2>/dev/null || printf '%s' "$src")"
    if [[ "$dest_real" != "$src_real" ]]; then
      log "re-pointing ~/.pi/agent/${name} -> ${src}"
    fi
    ln -sfn "$src" "$dest"
    return
  fi
  if [[ $MAY_MIGRATE -eq 1 && -d "$dest" && ! -L "$dest" && ! -e "$src" ]]; then
    mkdir -p "$(dirname "$src")"
    mv "$dest" "$src"
  fi
  if [[ -d "$src" ]]; then
    if [[ -e "$dest" && ! -L "$dest" ]]; then
      if rmdir "$dest" 2>/dev/null; then
        :
      else
        log "leave ~/.pi/agent/${name} in \$HOME (not a store link); store has ${src}"
        return 0
      fi
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
if [[ ! -e "$theme" ]]; then
  die "theme missing or dangling: ${theme}"
fi

log "ok (~/.pi is a real directory; theme readable)"
