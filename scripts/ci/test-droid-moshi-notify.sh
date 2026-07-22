#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
hook="$project_root/dotfiles/agents/.factory/hooks/droid-moshi-notify.sh"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/droid-moshi-notify-test.XXXXXX")"
trap 'rm -r "$test_dir"' EXIT

cat >"$test_dir/moshi-hook" <<'EOF'
#!/usr/bin/env bash
if [[ "${DROID_MOSHI_DEFAULT_SESSION:-0}" == 1 ]]; then
    printf '%s\n' '{"kind":"herdr","herdr":{"session":"connection-label","rawSession":""}}'
else
    printf '%s\n' '{"kind":"herdr","herdr":{"session":"connection-label","rawSession":"mobile-work"}}'
fi
EOF

cat >"$test_dir/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
while (($#)); do
    case "$1" in
        -d)
            printf '%s' "$2" >"$DROID_MOSHI_PAYLOAD"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done
EOF

cat >"$test_dir/gopass" <<'EOF'
#!/usr/bin/env bash
[[ -n "${DROID_MOSHI_GOPASS_TOKEN:-}" ]] || exit 1
printf '%s' "$DROID_MOSHI_GOPASS_TOKEN"
EOF

chmod +x "$test_dir/moshi-hook" "$test_dir/curl" "$test_dir/gopass"

payload="$test_dir/payload.json"
printf '%s\n' '{"hook_event_name":"Notification","message":"Approval needed"}' |
    PATH="$test_dir:$PATH" \
    MOSHI_WEBHOOK_TOKEN="test-token" \
    MOSHI_HERDR_DEEP_LINK=1 \
    DROID_MOSHI_PAYLOAD="$payload" \
    "$hook"

jq -e '
    .token == "test-token" and
    .title == "Droid needs input" and
    .message == "Approval needed" and
    .data.url == "moshi://herdr?name=mobile-work"
' "$payload" >/dev/null

rm "$payload"
printf '%s\n' '{"hook_event_name":"Notification"}' |
    PATH="$test_dir:$PATH" \
    MOSHI_WEBHOOK_TOKEN="test-token" \
    HERDR_SESSION="named-work" \
    MOSHI_HERDR_DEEP_LINK=1 \
    DROID_MOSHI_PAYLOAD="$payload" \
    "$hook"
jq -e '.data.url == "moshi://herdr?name=named-work"' "$payload" >/dev/null

rm "$payload"
printf '%s\n' '{"hook_event_name":"Stop"}' |
    PATH="$test_dir:$PATH" \
    DROID_MOSHI_GOPASS_TOKEN="stored-token" \
    DROID_MOSHI_DEFAULT_SESSION=1 \
    MOSHI_HERDR_DEEP_LINK=1 \
    DROID_MOSHI_PAYLOAD="$payload" \
    "$hook"
jq -e '
    .token == "stored-token" and
    .title == "Droid finished" and
    .data.url == "moshi://herdr?name=default"
' "$payload" >/dev/null

rm "$payload"
printf '%s\n' '{"hook_event_name":"Stop"}' |
    PATH="$test_dir:$PATH" \
    DROID_MOSHI_GOPASS_TOKEN="stored-token" \
    DROID_MOSHI_PAYLOAD="$payload" \
    "$hook"
jq -e 'has("data") | not' "$payload" >/dev/null

rm "$payload"
printf '%s\n' '{"hook_event_name":"Stop"}' |
    PATH="$test_dir:$PATH" \
    DROID_MOSHI_PAYLOAD="$payload" \
    "$hook"
[[ ! -e "$payload" ]]

printf 'droid-moshi-notify test: ok\n'
