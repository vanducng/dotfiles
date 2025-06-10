---@type LazySpec
return {
  {
    "PedramNavid/dbtpal",
    ft = { "sql" },
    config = function()
      require("dbtpal").setup {
        path_to_dbt = "dbt",
        path_to_dbt_project = "",
        path_to_dbt_profiles_dir = vim.fn.expand "~/.dbt",
        extended_path_search = true,
        protect_compiled_files = true,
      }

      -- Optional: Add telescope integration
      require("telescope").load_extension "dbtpal"
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
}
