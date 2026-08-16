local M = {}

local function jq(args, lines)
  if vim.fn.executable("jq") == 0 then
    vim.notify("jq is not installed", vim.log.levels.ERROR)
    return nil
  end
  local cmd = { "jq" }
  vim.list_extend(cmd, args)
  local result = vim.system(cmd, {
    stdin = table.concat(lines, "\n") .. "\n",
    text = true,
    timeout = 15000,
  }):wait()
  if result.code ~= 0 then
    local err = (result.stderr ~= "" and result.stderr) or (result.stdout or "jq failed")
    vim.notify(err:gsub("%s+$", ""), vim.log.levels.ERROR)
    return nil
  end
  local stdout = result.stdout or ""
  stdout = stdout:gsub("\n$", "")
  return vim.split(stdout, "\n", { plain = true })
end

function M.format_buf(bufnr, start_l, end_l)
  bufnr = bufnr or 0
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_l - 1, end_l, false)
  local out = jq({ "." }, lines)
  if not out then
    return false
  end
  vim.api.nvim_buf_set_lines(bufnr, start_l - 1, end_l, false, out)
  return true
end

function M.format()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype == "jsonl" then
    local line = vim.api.nvim_win_get_cursor(0)[1]
    return M.format_buf(bufnr, line, line)
  end
  return M.format_buf(bufnr, 1, vim.api.nvim_buf_line_count(bufnr))
end

function M.format_range(start_l, end_l)
  return M.format_buf(0, start_l, end_l)
end

function M.preview(src)
  src = src or vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(src, 0, -1, false)
  local args = vim.bo[src].filetype == "jsonl" and { "-s", "." } or { "." }
  local out = jq(args, lines)
  if not out then
    return nil
  end
  vim.cmd "vert new"
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "json"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
  pcall(vim.api.nvim_buf_set_name, buf, "json-preview://" .. tostring(src))
  vim.bo[buf].modified = false
  return buf
end

local function attach(ev)
  local buf = ev.buf
  vim.api.nvim_buf_create_user_command(buf, "JsonPretty", function(opts)
    M.format_range(opts.line1, opts.line2)
  end, { range = "%" })
  vim.keymap.set("n", "<leader>jf", M.format, {
    buffer = buf,
    desc = "Pretty-print JSON (jq)",
  })
  vim.keymap.set("x", "<leader>jf", ":JsonPretty<CR>", {
    buffer = buf,
    silent = true,
    desc = "Pretty-print selection (jq)",
  })
  vim.keymap.set("n", "<leader>jp", function()
    M.preview()
  end, {
    buffer = buf,
    desc = "Preview pretty JSON (scratch)",
  })
end

function M.setup()
  pcall(vim.treesitter.language.register, "json", "jsonl")
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("jsonl_pretty", { clear = true }),
    pattern = { "json", "jsonl" },
    callback = attach,
  })
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local ft = vim.bo[buf].filetype
      if ft == "json" or ft == "jsonl" then
        attach({ buf = buf })
      end
    end
  end
end

return M
