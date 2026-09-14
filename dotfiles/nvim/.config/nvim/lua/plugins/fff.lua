---@type LazySpec
return {
  "dmtrKovalenko/fff",
  build = function() require("fff.download").download_or_build_binary() end,
  lazy = false,
}
