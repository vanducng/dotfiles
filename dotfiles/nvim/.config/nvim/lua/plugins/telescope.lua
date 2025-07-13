return {
  "nvim-telescope/telescope.nvim",
  priority = 100,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = function(_, opts)
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"

    -- Custom buffer delete function
    local delete_buffer_action = function(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      if selection and selection.bufnr then
        vim.api.nvim_buf_delete(selection.bufnr, { force = false })
        actions.close(prompt_bufnr)
      end
    end

    opts = opts or {}
    opts.pickers = opts.pickers or {}
    opts.pickers.buffers = opts.pickers.buffers or {}

    -- Use attach_mappings for more reliable buffer-specific mappings
    opts.pickers.buffers.attach_mappings = function(prompt_bufnr, map)
      map("n", "dd", delete_buffer_action)
      return true
    end

    return opts
  end,
}
