#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
nvim_cfg="$project_root/dotfiles/nvim/.config/nvim"
module="$nvim_cfg/lua/jsonl_pretty.lua"

for command in nvim jq; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'error: %s is required to run the nvim jsonl test\n' "$command" >&2
    exit 1
  fi
done

if ! nvim --headless -u NONE --cmd 'if !has("nvim-0.10") | cquit 1 | endif' +qa! >/dev/null 2>&1; then
  printf 'error: nvim >= 0.10 is required (vim.system in jsonl_pretty.lua)\n' >&2
  exit 1
fi

if command -v luac >/dev/null 2>&1; then
  luac -p "$module"
  luac -p "$nvim_cfg/lua/polish.lua"
fi

if grep -q 'Format buffer as JSON (jq)' "$nvim_cfg/lua/plugins/astrocore.lua"; then
  printf 'error: global <leader>jf mapping is still in astrocore.lua\n' >&2
  exit 1
fi

if ! grep -Eq 'pcall[(]require, ["'\'']jsonl_pretty["'\''][)]' "$nvim_cfg/lua/polish.lua"; then
  printf 'error: polish.lua must pcall-require jsonl_pretty so a missing stow link cannot crash nvim\n' >&2
  exit 1
fi

if [[ ! -f "$module" ]]; then
  printf 'error: stow package is missing %s\n' "$module" >&2
  exit 1
fi

if ! grep -q 'ft = "sql"' "$nvim_cfg/lua/plugins/miudb.lua"; then
  printf 'error: <leader>j is not SQL-buffer-local\n' >&2
  exit 1
fi

nvim --headless -u NONE -i NONE -n \
  --cmd "let &runtimepath = '$nvim_cfg' . ',' . &runtimepath" \
  -l - <<'LUA'
local jsonl = require("jsonl_pretty")

local function assert_eq(got, want, msg)
  if got ~= want then
    error(string.format("%s: got %q want %q", msg, tostring(got), tostring(want)), 2)
  end
end

local function assert_true(cond, msg)
  if not cond then
    error(msg, 2)
  end
end

local src = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(src)
vim.bo[src].filetype = "jsonl"
vim.api.nvim_buf_set_lines(src, 0, -1, false, { '{"a":1}', '{"b":2}' })

assert_true(jsonl.format_buf(src, 1, 1), "format first jsonl record")
local after_line = vim.api.nvim_buf_get_lines(src, 0, -1, false)
assert_true(#after_line > 2, "pretty-print expands one record")
assert_eq(after_line[#after_line], '{"b":2}', "later jsonl records stay compact")

vim.api.nvim_buf_set_lines(src, 0, -1, false, { '{"a":1}', '{"b":2}' })
local preview = jsonl.preview(src)
assert_true(type(preview) == "number" and vim.api.nvim_buf_is_valid(preview), "preview opens")
assert_eq(vim.bo[preview].filetype, "json", "preview is json")
assert_eq(vim.bo[preview].buftype, "nofile", "preview is scratch")
local pretty = table.concat(vim.api.nvim_buf_get_lines(preview, 0, -1, false), "\n")
assert_true(pretty:find("%[", 1, false) and pretty:find('"a"', 1, true), "jsonl preview slurps into an array")
assert_eq(vim.api.nvim_buf_get_lines(src, 0, 1, false)[1], '{"a":1}', "preview does not mutate source")

vim.api.nvim_buf_set_lines(src, 0, -1, false, { "not-json" })
assert_true(jsonl.format_buf(src, 1, 1) == false, "invalid json fails")
assert_eq(vim.api.nvim_buf_get_lines(src, 0, 1, false)[1], "not-json", "failed format leaves buffer intact")

vim.api.nvim_buf_set_lines(src, 0, -1, false, { "{", '  "a": 1', "}" })
vim.api.nvim_set_current_buf(src)
vim.bo[src].filetype = "jsonl"
vim.api.nvim_win_set_cursor(0, { 2, 0 })
assert_true(jsonl.format() == false, "continuation line is not formatted")
assert_eq(vim.api.nvim_buf_get_lines(src, 1, 2, false)[1], '  "a": 1', "continuation line left intact")

local json_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(json_buf)
vim.bo[json_buf].filetype = "json"
vim.api.nvim_buf_set_lines(json_buf, 0, -1, false, { '{"a":1,"b":2}' })
assert_true(jsonl.format(), "format json buffer")
local json_lines = vim.api.nvim_buf_get_lines(json_buf, 0, -1, false)
assert_true(#json_lines > 1, "json buffer pretty-prints whole document")

local late = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_name(late, "session.jsonl")
vim.bo[late].filetype = "jsonl"
jsonl.setup()
local found_jf = false
for _, map in ipairs(vim.api.nvim_buf_get_keymap(late, "n")) do
  if tostring(map.lhs):find("jf", 1, true) then
    found_jf = true
    break
  end
end
assert_true(found_jf, "setup attaches jf map on already-open jsonl")

print("nvim jsonl test: ok")
os.exit(0)
LUA

missing_rtp="$(mktemp -d "${TMPDIR:-/tmp}/jsonl-missing-rtp.XXXXXX")"
trap 'rm -rf -- "$missing_rtp"' EXIT
mkdir -p "$missing_rtp/lua"
cp "$nvim_cfg/lua/polish.lua" "$missing_rtp/lua/polish.lua"
if ! nvim --headless -u NONE -i NONE -n \
  --cmd "let &runtimepath = '$missing_rtp' . ',' . &runtimepath" \
  -c 'lua require("polish")' +qa 2>"$missing_rtp/err"; then
  printf 'error: polish.lua crashed nvim when jsonl_pretty was absent\n' >&2
  cat "$missing_rtp/err" >&2
  exit 1
fi
if grep -q "module 'jsonl_pretty' not found" "$missing_rtp/err"; then
  printf 'error: missing jsonl_pretty still aborted polish.lua\n' >&2
  cat "$missing_rtp/err" >&2
  exit 1
fi
