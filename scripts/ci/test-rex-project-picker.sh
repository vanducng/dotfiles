#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$project_root/dotfiles/bin/.local/bin/rex-project-picker"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/rex-project-picker-test.XXXXXX")"
trap '[[ -n "${test_dir:-}" ]] && rm -r "$test_dir"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

mkdir -p "$test_dir/bin" "$test_dir/work/api/src" "$test_dir/work/web" "$test_dir/work/.cache" "$test_dir/personal/blog.site"
cat >"$test_dir/bin/rex" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$PICKER_REX_LOG"
[[ "$1" == new ]] && printf '{"session_id":"session:new"}\n'
exit 0
EOF
cat >"$test_dir/bin/fzf" <<'EOF'
#!/usr/bin/env bash
cat >"$PICKER_CHOICES"
[[ -n "${PICKER_PICK:-}" ]] && grep -m1 -- "$PICKER_PICK" "$PICKER_CHOICES"
exit "${PICKER_FZF_STATUS:-0}"
EOF
chmod +x "$test_dir/bin/rex" "$test_dir/bin/fzf"

sessions="$test_dir/sessions"
printf '%s\t%s\t%s\t%s\n' \
  session:here 1-cockpit "$test_dir/work/web" 1 \
  session:api 2-api "$test_dir/work/api/src" "" >"$sessions"

run() {
  PATH="$test_dir/bin:$PATH" REX_BIN_DIR="$test_dir/bin" HOME="$test_dir" \
    REX_PROJECT_ROOTS="$test_dir/work:$test_dir/personal:$test_dir/missing" \
    PICKER_CHOICES="$test_dir/choices" PICKER_REX_LOG="$test_dir/rex.log" \
    "$script" --sessions "$sessions" --client client:app
}

: >"$test_dir/rex.log"
PICKER_PICK=$'\tsession\t' run
grep -q '^2-api  .*~/work/api/src	session	session:api$' "$test_dir/choices" || fail "session row: $(cat "$test_dir/choices")"
grep -q 'work/api	project' "$test_dir/choices" && fail "project open in a session is listed twice"
grep -q 'work/web	project' "$test_dir/choices" && fail "current session's project is listed twice"
grep -q '\.cache' "$test_dir/choices" && fail "hidden folders are listed"
tail -n1 "$test_dir/choices" | grep -q '1-cockpit (here).*	current	session:here$' || fail "current session must be last"
[[ "$(cat "$test_dir/rex.log")" == "-C client:app do session.select session_id=session:api" ]] || fail "select: $(cat "$test_dir/rex.log")"

: >"$test_dir/rex.log"
PICKER_PICK=$'\tproject\t' run
grep -q '^+ blog.site .*	project	'"$test_dir"'/personal/blog.site$' "$test_dir/choices" || fail "project row: $(cat "$test_dir/choices")"
grep -qx "new 3-blog_site --window blog_site -c $test_dir/personal/blog.site --json" "$test_dir/rex.log" || fail "new: $(cat "$test_dir/rex.log")"
grep -qx -- "-C client:app do session.select session_id=session:new" "$test_dir/rex.log" || fail "select new: $(cat "$test_dir/rex.log")"

for pick in $'\tcurrent\t' ""; do
  : >"$test_dir/rex.log"
  status=0
  PICKER_PICK="$pick" PICKER_FZF_STATUS=$([[ -z "$pick" ]] && echo 130 || echo 0) run || status=$?
  [[ "$status" == 130 ]] || fail "no switch must exit 130, got $status"
  [[ ! -s "$test_dir/rex.log" ]] || fail "no switch must not call rex"
done

if PICKER_FZF_STATUS=2 run 2>"$test_dir/err"; then fail "fzf failure must fail"; fi
grep -q 'fzf exited with code 2' "$test_dir/err" || fail "fzf error message"

if "$script" --sessions "$sessions" 2>"$test_dir/err"; then fail "missing client must fail"; fi
grep -q 'no Rex app' "$test_dir/err" || fail "missing client message"

printf 'rex-project-picker test: ok\n'
