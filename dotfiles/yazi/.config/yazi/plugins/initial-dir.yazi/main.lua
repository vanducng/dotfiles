-- Plugin to return to initial directory
-- Reads from global YAZI_INITIAL_DIR set in init.lua (from env var)

local goto_initial = ya.sync(function()
  local initial_dir = YAZI_INITIAL_DIR or os.getenv("YAZI_INITIAL_DIR")
  if initial_dir and initial_dir ~= "" then
    ya.manager_emit("cd", { initial_dir })
  else
    ya.notify {
      title = "Initial Dir",
      content = "Launch via 'yy' or neovim for g0 to work",
      timeout = 3,
      level = "warn",
    }
  end
end)

return {
  entry = function()
    goto_initial()
  end,
}
