#!/usr/bin/env bash
#
# agent-deck-bootstrap.sh — register the standard set of work + personal
# projects as agent-deck sessions, organised by group.
#
# - Idempotent: skips sessions that already exist (matched by title+group).
# - Skips paths that don't exist on this machine (e.g. unmounted volumes).
# - Sessions are *added* (registered), not started. Press Enter in the TUI
#   to attach/start, or pass START=1 to start immediately.
#
# Usage:
#   agent-deck-bootstrap.sh           # add all (skip existing)
#   START=1 agent-deck-bootstrap.sh   # add + start with claude
#   TOOL=codex agent-deck-bootstrap.sh
#   DRY=1 agent-deck-bootstrap.sh     # print actions, don't execute

set -u
set -o pipefail

TOOL="${TOOL:-claude}"
START="${START:-0}"
DRY="${DRY:-0}"

if ! command -v agent-deck >/dev/null 2>&1; then
  echo "agent-deck not on PATH" >&2
  exit 127
fi

# Silences the once-per-process tmux 3.6a NULL-deref warning so it doesn't
# pollute our progress lines. Has no effect on a patched tmux.
export AGENTDECK_SUPPRESS_TMUX_WARNING=1

# title|group|path
SESSIONS=(
  # cnb
  "infra|cnb|/Users/vanducng/git/work/cnb/cnb-ds-infra"
  "airflow|cnb|/Users/vanducng/git/work/cnb/cnb-ds-astro"
  "dbt|cnb|/Users/vanducng/git/work/cnb/cnb-ds-dbt-order-form"
  "data-contract|cnb|/Users/vanducng/git/work/cnb/cnb-data-contract"
  "ws|cnb|/Users/vanducng/git/work/cnb/cnb-web-services"

  # abs
  "infra|abs|/Users/vanducng/git/work/ab-spectrum/infra"
  "data-platform|abs|/Users/vanducng/git/work/ab-spectrum/data-platform"

  # jade
  "infra|jade|/Users/vanducng/git/work/bhcoe/jade-infra"
  "harmony|jade|/Users/vanducng/git/work/bhcoe/harmony"

  # crashchat
  "infra|crashchat|/Users/vanducng/git/work/crashchat/infra"
  "app|crashchat|/Users/vanducng/git/work/crashchat/services/crashchat-core"

  # nlb
  "goclaw|nlb|/Users/vanducng/git/personal/nextlevelbuilder/goclaw"
  "gcplane|nlb|/Users/vanducng/git/personal/dataplanelabs/gcplane"
  "goclaw-config|nlb|/Users/vanducng/git/personal/dataplanelabs/goclaw-config"
  "goclaw-charts|nlb|/Users/vanducng/git/personal/dataplanelabs/goclaw-charts"

  # dpl
  "infra|dpl|/Users/vanducng/git/personal/dataplanelabs/infra"
  "runner|dpl|/Users/vanducng/git/personal/dataplanelabs/runnerclubs"
)

added=0
skipped_exists=0
skipped_missing=0
failed=0

run() {
  if [[ "$DRY" == "1" ]]; then
    printf 'DRY: %s\n' "$*"
    return 0
  fi
  "$@"
}

cmd_name="add"
[[ "$START" == "1" ]] && cmd_name="launch"

for entry in "${SESSIONS[@]}"; do
  IFS='|' read -r title group path <<<"$entry"

  if [[ ! -d "$path" ]]; then
    printf '  skip   %-20s %-10s  (path missing: %s)\n' "$title" "$group" "$path"
    skipped_missing=$((skipped_missing + 1))
    continue
  fi

  # Capture both stdout/stderr; treat ALREADY_EXISTS as success.
  if [[ "$DRY" == "1" ]]; then
    printf 'DRY: agent-deck %s %q -t %q -g %q -c %q --no-parent --quiet\n' \
      "$cmd_name" "$path" "$title" "$group" "$TOOL"
    added=$((added + 1))
    continue
  fi

  # Note: `agent-deck add` (in contrast to `launch`) exits 0 even when a
  # session with the same title+path already exists, only printing
  # "Session already exists ...". Detect that by grepping the output;
  # `--quiet` would hide the message, so we deliberately don't pass it.
  out=$(agent-deck "$cmd_name" "$path" -t "$title" -g "$group" -c "$TOOL" \
    --no-parent 2>&1)
  rc=$?

  if [[ $rc -ne 0 ]]; then
    printf '  FAIL   %-20s %-10s  %s\n         %s\n' "$title" "$group" "$path" "$out" >&2
    failed=$((failed + 1))
  elif grep -qiE 'already exists|ALREADY_EXISTS' <<<"$out"; then
    printf '  exist  %-20s %-10s  %s\n' "$title" "$group" "$path"
    skipped_exists=$((skipped_exists + 1))
  else
    printf '  add    %-20s %-10s  %s\n' "$title" "$group" "$path"
    added=$((added + 1))
  fi
done

echo
printf 'added=%d  existing=%d  missing=%d  failed=%d\n' \
  "$added" "$skipped_exists" "$skipped_missing" "$failed"

[[ $failed -eq 0 ]]
