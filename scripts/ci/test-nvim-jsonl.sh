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

if command -v luac >/dev/null 2>&1; then
  luac -p "$module"
  luac -p "$nvim_cfg/lua/polish.lua"
fi

if grep -q 'Format buffer as JSON (jq)' "$nvim_cfg/lua/plugins/astrocore.lua"; then
  printf 'error: global <leader>jf mapping is still in astrocore.lua\n' >&2
  exit 1
fi

if ! grep -q 'require("jsonl_pretty").setup()' "$nvim_cfg/lua/polish.lua"; then
  printf 'error: polish.lua does not set up jsonl_pretty\n' >&2
  exit 1
fi

if ! grep -q 'ft = "sql"' "$nvim_cfg/lua/plugins/miudb.lua"; then
  printf 'error: <leader>j is not SQL-buffer-local\n' >&2
  exit 1
fi

nvim --headless -u NONE -i NONE -n \
  --cmd "set rtp+=$nvim_cfg" \
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
assert_true(preview ~= nil, "preview opens")
assert_eq(vim.bo[preview].filetype, "json", "preview is json")
assert_eq(vim.bo[preview].buftype, "nofile", "preview is scratch")
local pretty = table.concat(vim.api.nvim_buf_get_lines(preview, 0, -1, false), "\n")
assert_true(pretty:find("%[", 1, false) and pretty:find('"a"', 1, true), "jsonl preview slurps into an array")
assert_eq(vim.api.nvim_buf_get_lines(src, 0, 1, false)[1], '{"a":1}', "preview does not mutate source")

vim.api.nvim_buf_set_lines(src, 0, -1, false, { "not-json" })
assert_true(jsonl.format_buf(src, 1, 1) == false, "invalid json fails")
assert_eq(vim.api.nvim_buf_get_lines(src, 0, 1, false)[1], "not-json", "failed format leaves buffer intact")

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
