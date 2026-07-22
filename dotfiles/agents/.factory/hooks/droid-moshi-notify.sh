#!/usr/bin/env bash
set -u

input="$(cat)" || exit 0
event="$(jq -r '.hook_event_name // empty' <<<"$input" 2>/dev/null)" || exit 0

case "$event" in
    Notification)
        title="$(jq -r '.title // "Droid needs input"' <<<"$input")"
        message="$(jq -r '.message // "Droid is waiting for input"' <<<"$input")"
        ;;
    Stop)
        title="Droid finished"
        message="Droid completed a turn"
        ;;
    SessionEnd)
        title="Droid session ended"
        message="$(jq -r '"Reason: " + (.reason // "unknown")' <<<"$input")"
        ;;
    *)
        exit 0
        ;;
esac

token="${MOSHI_WEBHOOK_TOKEN:-}"
if [[ -z "$token" ]] && command -v gopass >/dev/null 2>&1; then
    token="$(gopass show -o personal/moshi/webhook-token 2>/dev/null || true)"
fi
[[ -n "$token" ]] || exit 0
webhook_url="${MOSHI_WEBHOOK_URL:-https://api.getmoshi.app/api/webhook}"

session="${HERDR_SESSION:-}"
if [[ -z "$session" ]] && command -v moshi-hook >/dev/null 2>&1; then
    session="$(
        moshi-hook context 2>/dev/null |
            jq -r '
                if (.herdr.rawSession // "") != "" then .herdr.rawSession
                elif .kind == "herdr" then "default"
                else empty
                end
            ' 2>/dev/null || true
    )"
fi

payload="$(jq -n \
    --arg token "$token" \
    --arg title "$title" \
    --arg message "$message" \
    --arg session "$session" '
        {
            token: $token,
            title: $title,
            message: $message
        }
        + if $session == "" or env.MOSHI_HERDR_DEEP_LINK != "1" then {}
          else {
              data: {
                  type: "url",
                  url: ("moshi://herdr?name=" + ($session | @uri))
              }
          }
          end
    ')"

curl -fsS --max-time 5 \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "$webhook_url" >/dev/null 2>&1 || true
