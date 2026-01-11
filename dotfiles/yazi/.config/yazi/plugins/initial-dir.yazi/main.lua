-- Plugin to return to initial directory (from YAZI_INITIAL_DIR env var)

local goto_initial = ya.sync(function()
  local initial_dir = os.getenv("YAZI_INITIAL_DIR")
  if initial_dir and initial_dir ~= "" then
    ya.manager_emit("cd", { initial_dir })
  else
    ya.notify {
      title = "Initial Dir",
      content = "Initial directory not set (YAZI_INITIAL_DIR)",
      timeout = 2,
      level = "warn",
    }
  end
end)

return {
  entry = function()
    goto_initial()
  end,
}
