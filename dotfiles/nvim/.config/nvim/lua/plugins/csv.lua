---@type LazySpec
return {
  {
    "chrisbra/csv.vim",
    ft = { "csv", "tsv" },
    config = function()
      -- CSV.vim configuration
      vim.g.csv_autocmd_arrange = 1     -- Auto-arrange columns on file open
      vim.g.csv_arrange_align = 'l'     -- Left align columns
      vim.g.csv_arrange_use_all_rows = 1 -- Use all rows to determine column width
      vim.g.csv_delim_test = ',;|\t'    -- Test delimiters: comma, semicolon, pipe, tab
      vim.g.csv_nl = 1                  -- Enable newline handling
      vim.g.csv_hiGroup = "Visual"      -- Highlight group for column highlighting
      vim.g.csv_highlight_column = 'y'  -- Enable column highlighting
      vim.g.csv_disable_fdt = 1         -- Disable CSV fold text
      vim.g.csv_fold_char = ''          -- Disable fold character
      
      -- Auto-arrange CSV files when opened
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "csv", "tsv" },
        callback = function()
          vim.schedule(function()
            -- Initialize CSV plugin first
            vim.cmd("CSVInit")
            
            -- Only arrange if file is not too large (< 1000 lines)
            local line_count = vim.api.nvim_buf_line_count(0)
            if line_count < 1000 then
              vim.cmd("ArrangeColumn!")
            end
            
            -- Set buffer options for better CSV viewing
            vim.opt_local.wrap = false
            vim.opt_local.scrollbind = false
            vim.opt_local.number = true
            vim.opt_local.relativenumber = false
            vim.opt_local.cursorline = true
            vim.opt_local.cursorcolumn = true
            -- Disable folding in CSV files
            vim.opt_local.foldenable = false
            vim.opt_local.foldmethod = "manual"
            
            -- Disable TreeSitter for CSV files to prevent parsing errors
            vim.bo.syntax = "csv"
            pcall(vim.treesitter.stop, 0)
            
            -- Set up CSV navigation mappings using the actual CSV functions
            vim.keymap.set("n", "H", ":<C-U>call csv#MoveCol(-1, line('.'))<CR>", { buffer = true, silent = true, desc = "CSV: Previous column" })
            vim.keymap.set("n", "L", ":<C-U>call csv#MoveCol(1, line('.'))<CR>", { buffer = true, silent = true, desc = "CSV: Next column" })
            vim.keymap.set("n", "K", ":<C-U>call csv#MoveCol(0, line('.')-1)<CR>", { buffer = true, silent = true, desc = "CSV: Up in column" })
            vim.keymap.set("n", "J", ":<C-U>call csv#MoveCol(0, line('.')+1)<CR>", { buffer = true, silent = true, desc = "CSV: Down in column" })
          end)
        end,
        desc = "Auto-arrange CSV columns and set buffer options",
      })
    end,
    cmd = {
      "ArrangeColumn",
      "UnArrangeColumn", 
      "DeleteColumn",
      "CSVTabularize",
      "AddColumn",
      "MoveColumn",
      "SumCol",
      "MaxCol",
      "MinCol",
      "AvgCol",
      "CSVInit",
      "HiColumn",
    },
    keys = {
      { ",ca", "<cmd>ArrangeColumn<cr>", desc = "Arrange CSV columns", ft = "csv" },
      { ",cu", "<cmd>UnArrangeColumn<cr>", desc = "Un-arrange CSV columns", ft = "csv" },
      { ",ct", "<cmd>CSVTabularize<cr>", desc = "Tabularize CSV", ft = "csv" },
      { ",ch", "<cmd>HiColumn<cr>", desc = "Highlight current column", ft = "csv" },
    },
  },
}