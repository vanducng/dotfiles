#!/bin/bash
# Notify (macOS banner) when a Codex usage window resets, and warn when one is nearly exhausted.
# Reads the latest rate_limits snapshot Codex writes into ~/.codex/sessions/.../*.jsonl.
# Installed as a LaunchAgent (local.codex-reset-notify); runs every 30 min.
set -u
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

SESSIONS="$HOME/.codex/sessions"
STATE_DIR="$HOME/.local/state"
STATE="$STATE_DIR/codex-reset-notify.state"
mkdir -p "$STATE_DIR"

notify() { terminal-notifier -title "Codex limits" -message "$1" -group codex-reset -sound default >/dev/null 2>&1; }

# Latest rate_limits line from the newest session file that has one.
line=""
for f in $(ls -t "$SESSIONS"/*/*/*/*.jsonl 2>/dev/null | head -40); do
  l=$(grep '"rate_limits"' "$f" 2>/dev/null | tail -1)
  [ -n "$l" ] && { line="$l"; break; }
done
[ -z "$line" ] && exit 0

field() { # $1=window (primary|secondary) $2=field -> number or empty
  printf '%s' "$line" | grep -oE "\"$1\":\{[^}]*\}" | grep -oE "\"$2\":[0-9.]+" | grep -oE '[0-9.]+' | head -1
}
ge() { awk "BEGIN{exit !(${1:-0} >= $2)}"; }   # float >=
lt() { awk "BEGIN{exit !(${1:-0} <  $2)}"; }   # float <

p_used=$(field primary used_percent);   p_reset=$(field primary resets_at)
s_used=$(field secondary used_percent);  s_reset=$(field secondary resets_at)

# Previous state (defaults for first run).
P_USED=0; S_USED=0; P_WARN=0; S_WARN=0
[ -f "$STATE" ] && . "$STATE"

check() { # $1=label $2=cur_used $3=prev_used $4=reset_epoch $5=warn_var_name $6=prev_warn
  local label="$1" cur="$2" prev="$3" reset="$4" warnvar="$5" warn="$6" when=""
  [ -n "$reset" ] && when=$(date -r "$reset" '+%a %b %-d, %H:%M')
  # Reset: usage dropped from meaningful to near-zero.
  if ge "$prev" 40 && lt "$cur" 10; then
    notify "✅ Codex $label limit reset — was ${prev}%, now ${cur}%. You're good to go."
    warn=0
  # Near-limit: crossed 90% (warn once until it resets).
  elif ge "$cur" 90 && [ "$warn" = "0" ]; then
    notify "⚠️ Codex $label at ${cur}% — resets ${when:-soon}. Pace your usage."
    warn=1
  elif lt "$cur" 80; then
    warn=0
  fi
  eval "$warnvar=$warn"
}

check "5-hour" "${p_used:-0}" "$P_USED" "${p_reset:-}" P_WARN_NEW "$P_WARN"
check "weekly" "${s_used:-0}" "$S_USED" "${s_reset:-}" S_WARN_NEW "$S_WARN"

cat > "$STATE" <<EOF
P_USED=${p_used:-0}
S_USED=${s_used:-0}
P_WARN=${P_WARN_NEW:-0}
S_WARN=${S_WARN_NEW:-0}
EOF
