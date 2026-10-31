#!/usr/bin/env bash
# Merges the pending release-please PR, waits for its tag, then fast-forwards ~/dotfiles on
# this Mac and every other machine in hosts.json (labels are ssh aliases). Running it is the
# go-ahead to merge. With nothing pending it only syncs.
#   scripts/release.sh            release, then sync every machine
#   scripts/release.sh --sync DIR [LABEL]  fast-forward one checkout (what each machine runs)
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]:-.}")/.." && pwd)"
HOSTS="$root/dotfiles/rex/.config/rex/hosts.json"
REX="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"

release() {
  local pr state head title sha run
  pr="$(gh pr list --state open --head release-please--branches--main --json number --jq '.[0].number // empty')"
  [ -n "$pr" ] || { echo "No release pending"; return; }
  for _ in $(seq 20); do
    read -r state head title < <(gh pr view "$pr" --json mergeStateStatus,headRefOid,title --jq '"\(.mergeStateStatus) \(.headRefOid) \(.title)"')
    [ "$state" != UNKNOWN ] && break
    sleep 3
  done
  [ "$state" = CLEAN ] || { echo "#$pr is $state, not merging" >&2; exit 1; }
  # Pinned to the head that was checked: release-please can rewrite the PR in the meantime.
  gh pr merge "$pr" --squash --match-head-commit "$head"
  sha="$(gh pr view "$pr" --json mergeCommit --jq .mergeCommit.oid)"
  for _ in $(seq 20); do
    run="$(gh run list --workflow release --commit "$sha" --json databaseId --jq '.[0].databaseId // empty')"
    [ -n "$run" ] && break
    sleep 3
  done
  [ -n "$run" ] || { echo "no release run for $sha" >&2; exit 1; }
  gh run watch "$run" --exit-status >/dev/null
  gh release view "v${title##* }" --json tagName,url --jq '"Released \(.tagName): \(.url)"'
}

# A local edit to a file upstream also changed blocks a fast-forward: lift it off as a patch,
# pull, put it back. Copies still saved on exit (a failure, Ctrl-C) are restored first.
# Machines run this with macOS /bin/bash 3.2, so no arrays (empty ones trip set -u there).
put_back() {
  local n=0 f
  while IFS= read -r f; do
    n=$((n + 1))
    [ -f "$tmp/$n.keep" ] || continue
    mkdir -p "$(dirname "$f")"
    cp -p "$tmp/$n.keep" "$f"
  done <"$tmp/list"
  rm -rf "$tmp"
}

sync_here() {
  cd "$1"
  local me="${2:-$(hostname -s)}" old f n
  [ "$(git rev-parse --abbrev-ref HEAD)" = main ] || { echo "$me: not on main" >&2; exit 1; }
  git fetch -q origin
  old="$(git rev-parse HEAD)"
  tmp="$(mktemp -d)"
  comm -12 <(git diff --name-only HEAD | sort) <(git diff --name-only HEAD origin/main | sort) >"$tmp/list"
  trap put_back EXIT
  n=0
  while IFS= read -r f; do
    n=$((n + 1))
    git diff HEAD -- "$f" >"$tmp/$n.patch"
    [ ! -f "$f" ] || cp -p "$f" "$tmp/$n.keep"
  done <"$tmp/list"
  while IFS= read -r f; do
    git checkout -q HEAD -- "$f" 2>/dev/null || { echo "$me: can't lift $f off for the pull; settle it by hand" >&2; exit 1; }
  done <"$tmp/list"
  git pull -q --ff-only || { echo "$me: pull failed, local files put back" >&2; exit 1; }
  n=0
  while IFS= read -r f; do
    n=$((n + 1))
    if git apply -q --3way "$tmp/$n.patch" 2>/dev/null; then
      git restore -q --staged -- "$f" 2>/dev/null || true
    else
      git checkout -q HEAD -- "$f" 2>/dev/null || true
      [ ! -f "$tmp/$n.keep" ] || { mkdir -p "$(dirname "$f")"; cp -p "$tmp/$n.keep" "$f"; }
      echo "$me: kept the local $f; merge its upstream change by hand" >&2
    fi
    rm -f "$tmp/$n.keep"
  done <"$tmp/list"
  echo "$me: $(git log --oneline -1)"
  [ "$old" = "$(git rev-parse HEAD)" ] || converge "$me" "$old"
  [ ! -f Makefile ] || settle "$me"
}

# Over `ssh bash -s` PATH is the bare system one; stow, mise and gopass live in these.
PATH="/opt/homebrew/bin:$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

# Links what the pull added and installs a new mise pin; edits to linked files are already live.
converge() {
  local me="$1" old="$2" pkgs pkg
  if [ -f Makefile ]; then
    pkgs=" $(make -s stow-folders </dev/null | tr '\n' ' ') "
    for pkg in $(git diff --name-only --diff-filter=A "$old" HEAD -- dotfiles/ | cut -d/ -f2 | sort -u); do
      case "$pkgs" in *" $pkg "*) make -s "stow-$pkg" </dev/null || echo "$me: make stow-$pkg failed" >&2 ;; esac
    done
  fi
  if ! git diff --quiet "$old" HEAD -- dotfiles/mise && [ -x scripts/mise-sync.sh ]; then
    ./scripts/mise-sync.sh </dev/null || echo "$me: mise-sync failed; rerun scripts/mise-sync.sh" >&2
  fi
  if ! git diff --quiet "$old" HEAD -- dotfiles/rex && [ -x "$REX" ]; then
    "$REX" config check || { echo "$me: rex config check failed, not reloaded" >&2; exit 1; }
    "$REX" config reload
  fi
}

# Reports what the pull cannot fix: a missing CLI Proxy key file and files that are no longer links.
settle() {
  local me="$1"
  dotfiles/bin/.local/bin/cli-proxy-key </dev/null || echo "$me: no CLI Proxy key file; run cli-proxy-key once gopass unlocks" >&2
  # shellcheck disable=SC2046
  ./scripts/stow-package.sh --check $(make -s stow-folders </dev/null | grep -vx pi) </dev/null \
    | sed "s/^/$me: /" || echo "$me: make stow-<package> links a drifted file (the live one goes to ~/.dotfiles-backup)" >&2
}

sync_all() {
  local label host me failed=0
  me="$(scutil --get LocalHostName)"
  while read -r label host; do
    if [ "$host" = "$me" ]; then
      bash "${BASH_SOURCE[0]}" --sync "$root" "$label" </dev/null || failed=1
    else
      ssh -o BatchMode=yes -o ConnectTimeout=5 "$label" "bash -s -- --sync \"\$HOME/dotfiles\" $label" <"${BASH_SOURCE[0]}" \
        || { echo "$label: sync failed" >&2; failed=1; }
    fi
  done < <(/usr/bin/python3 -c 'import json, sys
for h in json.load(open(sys.argv[1])): print(h["label"], h["hostname"])' "$HOSTS")
  return "$failed"
}

# Machines read this file over `ssh bash -s`; the dispatch must stay its last command, so
# nothing a step runs can read the rest of it from stdin.
case "${1:-}" in
  --sync) sync_here "${2:-$HOME/dotfiles}" "${3:-}" ;;
  *) release; sync_all ;;
esac
