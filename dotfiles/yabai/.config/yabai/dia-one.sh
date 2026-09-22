#!/bin/sh
# One Dia window per profile. Extra "New Tab" windows are closed; a loaded page is kept.
set -eu

mode="${1:-dedupe}"

if [ "$mode" = focus ]; then
  yabai -m space --focus 3 2>/dev/null || true
  id="$(yabai -m query --windows | jq -r '[.[] | select((.app | gsub("\u200e"; "")) == "Dia")] | if length == 0 then empty else (first(.[] | select(."has-focus")) // min_by(.id)).id end')"
  if [ -n "$id" ]; then
    yabai -m window "$id" --focus
  else
    open "/Applications/Dia.app"
  fi
  exit 0
fi

if [ "$mode" = wait ]; then
  sleep 0.4
fi

yabai -m query --windows | python3 -c '
import json, sys
from collections import defaultdict

windows = json.load(sys.stdin)
groups = defaultdict(list)
for window in windows:
    app = (window.get("app") or "").replace("\u200e", "")
    if app != "Dia":
        continue
    title = window.get("title") or ""
    profile, sep, rest = title.partition(": ")
    if not sep:
        profile = title or "Dia"
    new_tab = rest == "New Tab" or title in {"", "New Tab"}
    groups[profile].append((window["id"], new_tab))

for items in groups.values():
    real = [wid for wid, new_tab in items if not new_tab]
    keep = min(real) if real else min(wid for wid, _ in items)
    for wid, new_tab in items:
        if new_tab and wid != keep:
            print(wid)
' | while read -r id; do
  [ -n "$id" ] || continue
  yabai -m window "$id" --close 2>/dev/null || true
done
