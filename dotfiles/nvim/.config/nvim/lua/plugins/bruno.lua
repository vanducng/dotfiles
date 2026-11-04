local function request_file()
  local current = vim.fn.expand("%:p")
  local name = vim.fn.fnamemodify(current, ":t")
  if vim.fn.fnamemodify(current, ":e") == "bru" and name ~= "folder.bru" then
    vim.g.last_bruno_file = current
    return current
  end
  local last = vim.g.last_bruno_file
  if type(last) == "string" and vim.fn.filereadable(last) == 1 then
    return last
  end
  vim.notify("Open a Bruno request first", vim.log.levels.WARN)
  return nil
end

local function collection_root(start)
  local dir = vim.fn.fnamemodify(start, ":p:h")
  while dir and dir ~= "" do
    if vim.fn.filereadable(dir .. "/bruno.json") == 1 then
      return dir
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      return nil
    end
    dir = parent
  end
end

local function request_paths(dir)
  local paths = vim.fn.glob(dir .. "/*.bru", false, true)
  local requests = {}
  for _, path in ipairs(paths) do
    if vim.fn.fnamemodify(path, ":t") ~= "folder.bru" then
      table.insert(requests, path)
    end
  end
  table.sort(requests)
  return requests
end

local function jump(delta)
  local current = vim.fn.expand("%:p")
  if vim.fn.fnamemodify(current, ":e") ~= "bru" then
    return
  end
  local requests = request_paths(vim.fn.fnamemodify(current, ":h"))
  local index
  for i, path in ipairs(requests) do
    if path == current then
      index = i
      break
    end
  end
  if not index then
    return
  end
  local target = requests[index + delta]
  if target then
    vim.cmd("edit " .. vim.fn.fnameescape(target))
  end
end

local function output_buf()
  local name = "Bruno Folder"
  local existing = vim.fn.bufnr(name)
  vim.cmd("botright vsplit")
  vim.cmd("vertical resize 80")
  local buf
  if existing ~= -1 then
    buf = existing
    vim.api.nvim_set_current_buf(buf)
  else
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, name)
    vim.api.nvim_set_current_buf(buf)
  end
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "text"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  return buf
end

local function append(buf, lines)
  if not vim.api.nvim_buf_is_valid(buf) or not lines then
    return
  end
  local start = vim.api.nvim_buf_line_count(buf)
  if start == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "" then
    start = 0
  end
  vim.api.nvim_buf_set_lines(buf, start, -1, false, lines)
end

local function run_folder()
  local file = request_file()
  if not file then
    return
  end
  local dir = vim.fn.fnamemodify(file, ":h")
  local root = collection_root(file)
  if not root then
    vim.notify("Bruno collection root not found", vim.log.levels.WARN)
    return
  end
  local cmd = { "bru", "run", dir, "--noproxy" }
  local env = require("bruno").current_env
  if type(env) == "string" and env ~= "" then
    vim.list_extend(cmd, { "--env", env })
  end
  local buf = output_buf()
  append(buf, { "Running " .. vim.fn.fnamemodify(dir, ":.") })
  local function on_data(_, data)
    if data then
      vim.schedule(function()
        append(buf, data)
      end)
    end
  end
  vim.fn.jobstart(cmd, {
    cwd = root,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = on_data,
    on_stderr = on_data,
  })
end

---@type LazySpec
return {
  "romek-codes/bruno.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "ibhagwan/fzf-lua" },
  cmd = { "BrunoRun", "BrunoEnv", "BrunoSearch", "BrunoToggleFormat" },
  ft = "bru",
  keys = {
    { "<leader>;r", "<cmd>BrunoRun<cr>", desc = "Send request" },
    { "<leader>;a", run_folder, desc = "Send all requests in folder" },
    { "<leader>;t", "<cmd>BrunoToggleFormat<cr>", desc = "Toggle body/headers" },
    { "<leader>;s", "<cmd>BrunoSearch<cr>", desc = "Search requests" },
    { "<leader>;e", "<cmd>BrunoEnv<cr>", desc = "Select environment" },
    { "[r", function() jump(-1) end, desc = "Previous request", ft = "bru" },
    { "]r", function() jump(1) end, desc = "Next request", ft = "bru" },
  },
  opts = {
    picker = "fzf-lua",
    collection_paths = {},
    show_formatted_output = true,
  },
  init = function()
    vim.filetype.add({ extension = { bru = "bru" } })
  end,
  config = function(_, opts)
    require("bruno").setup(opts)
  end,
}
