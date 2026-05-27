#!/usr/bin/env bash
set -euo pipefail

event="${1:-attention}"

# Consume hook input so Codex never sees a broken pipe if it writes JSON to stdin.
if [[ ! -t 0 ]]; then
  cat >/dev/null || true
fi

case "$event" in
  permission)
    title="Codex needs attention"
    message="Approval is waiting"
    if [[ -f "${HOME}/.claude/notification.mp3" ]]; then
      sound="${HOME}/.claude/notification.mp3"
    else
      sound="/System/Library/Sounds/Pop.aiff"
    fi
    ;;
  stop)
    title="Codex turn complete"
    message="The current turn has stopped"
    sound="/System/Library/Sounds/Glass.aiff"
    ;;
  *)
    title="Codex notification"
    message="Codex has an update"
    sound="/System/Library/Sounds/Ping.aiff"
    ;;
esac

if [[ "${CODEX_ATTENTION_SOUND_DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

if [[ -f "$sound" ]] && command -v afplay >/dev/null 2>&1; then
  (afplay "$sound" >/dev/null 2>&1 &)
fi

if command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"${message}\" with title \"${title}\"" >/dev/null 2>&1 || true
fi
