---@type LazySpec
return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
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
    global_keymaps = false,
    ui = {
      syntax_hl = {
        ["@punctuation.bracket.kulala_http"] = "Number",
        ["@character.special.kulala_http"] = "Special",
        ["@operator.kulala_http"] = "Special",
        ["@variable.kulala_http"] = "Identifier",
        ["@redirect_path.kulala_http"] = "Number",
        ["@external_body_path.kulala_http"] = "String",
        ["@query_param.name.kulala_http"] = "Number",
        ["@query_param.value.kulala_http"] = "String",
        ["@form_param_name.kulala_http"] = "Number",
        ["@form_param_value.kulala_http"] = "String",
        ["@function.method.kulala_http"] = "Function",
        ["@constant.kulala_http"] = "Constant",
        ["@string.special.url.kulala_http"] = "Underlined",
        ["@keyword.kulala_http"] = "Keyword",
        ["@string.special.kulala_http"] = "Special",
      },
    },
  },
  config = function(_, opts)
    require("kulala").setup(opts)

    -- AstroCore only auto-starts TS for nvim-treesitter installed langs; kulala_http is custom.
    local function highlight_http(buf)
      if not vim.api.nvim_buf_is_valid(buf) then return end
      vim.treesitter.language.register("kulala_http", { "http", "rest" })
      pcall(vim.treesitter.start, buf, "kulala_http")
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("kulala_http_highlight", { clear = true }),
      pattern = { "http", "rest" },
      callback = function(ev) highlight_http(ev.buf) end,
    })

    if vim.bo.filetype == "http" or vim.bo.filetype == "rest" then
      highlight_http(vim.api.nvim_get_current_buf())
    end
  end,
}
