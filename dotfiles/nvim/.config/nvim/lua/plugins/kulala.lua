---@type LazySpec
return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  keys = {
    { "<leader>;r", function() require("kulala").run() end, desc = "Send request" },
    { "<leader>;a", function() require("kulala").run_all() end, desc = "Send all requests" },
    { "<leader>;t", function() require("kulala").toggle_view() end, desc = "Toggle body/headers" },
    { "<leader>;c", function() require("kulala").copy() end, desc = "Copy as cURL" },
    { "<leader>;i", function() require("kulala").inspect() end, desc = "Inspect request" },
    { "<leader>;s", function() require("kulala").scratchpad() end, desc = "Open scratchpad" },
    { "<leader>;e", function() require("kulala").set_selected_env() end, desc = "Select environment" },
    { "[r", function() require("kulala").jump_prev() end, desc = "Previous request", ft = { "http", "rest" } },
    { "]r", function() require("kulala").jump_next() end, desc = "Next request", ft = { "http", "rest" } },
  },
  opts = {
    global_keymaps = false, -- Use explicit keymaps above to avoid conflicts
  },
}
