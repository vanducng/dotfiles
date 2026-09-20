local function prepend(dir)
  if dir == nil or dir == "" or vim.fn.isdirectory(dir) ~= 1 then
    return
  end
  local path = vim.env.PATH or ""
  if path == dir or path:sub(1, #dir + 1) == dir .. ":" then
    return
  end
  vim.env.PATH = dir .. ":" .. path
end

if vim.fn.isdirectory "/opt/homebrew/bin" == 1 then
  prepend "/opt/homebrew/bin"
elseif vim.fn.isdirectory "/usr/local/bin" == 1 then
  prepend "/usr/local/bin"
end

local home = vim.env.HOME
if home and home ~= "" then
  prepend(home .. "/.local/bin")
end
