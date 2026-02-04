---@type LazySpec
return {
  {
    "vanducng/markdown-preview.nvim", -- Fork with Mermaid v11.12.2
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && ./install.sh",
    config = function()
      -- Configuration for markdown-preview.nvim

      -- Specify browser for preview (auto-detect by default)
      -- vim.g.mkdp_browser = 'firefox'

      -- Set to 1 to auto-start preview when opening markdown files
      vim.g.mkdp_auto_start = 0

      -- Set to 1 to auto-close preview when switching buffers
      vim.g.mkdp_auto_close = 1

      -- Set to 1 to refresh preview on save (instead of real-time)
      vim.g.mkdp_refresh_slow = 0

      -- Set to 1 to open preview in a new window
      vim.g.mkdp_command_for_global = 0

      -- Set to 1 to open preview for all file types (not just markdown)
      vim.g.mkdp_open_to_the_world = 0

      -- Use specific IP for preview server (default: 127.0.0.1)
      vim.g.mkdp_open_ip = ""

      -- Specify browser for preview
      vim.g.mkdp_browser = ""

      -- Set to 1 to echo preview page URL in command line
      vim.g.mkdp_echo_preview_url = 0

      -- Custom function to define browse behavior
      vim.g.mkdp_browserfunc = ""

      -- Preview options for markdown render
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }

      -- Use custom markdown style (must be absolute path)
      vim.g.mkdp_markdown_css = ""

      -- Use custom highlight style (must be absolute path)
      vim.g.mkdp_highlight_css = ""

      -- Use custom port for preview server
      vim.g.mkdp_port = ""

      -- Page title format
      vim.g.mkdp_page_title = "「${name}」"

      -- Recognized filetypes for preview
      vim.g.mkdp_filetypes = { "markdown" }

      -- Theme for preview: dark or light
      vim.g.mkdp_theme = "light"

      -- Auto-start preview when entering markdown buffer
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          -- Optional: Auto-start preview (uncomment to enable)
          -- vim.cmd("MarkdownPreview")

          -- Set buffer options for markdown files
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.spell = true
          vim.opt_local.conceallevel = 2
        end,
        desc = "Configure buffer options for Markdown files",
      })
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Start Markdown Preview" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", desc = "Stop Markdown Preview" },
      { "<leader>mt", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown Preview" },
      {
        "<leader>me",
        function()
          -- Extract mermaid code block from buffer
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local in_mermaid = false
          local mermaid_code = {}

          for _, line in ipairs(lines) do
            if line:match("^```mermaid") then
              in_mermaid = true
            elseif line:match("^```") and in_mermaid then
              in_mermaid = false
              break
            elseif in_mermaid then
              table.insert(mermaid_code, line)
            end
          end

          if #mermaid_code == 0 then
            vim.notify("No mermaid code block found", vim.log.levels.WARN)
            return
          end

          -- Write to temp file and export
          local tmp_mmd = "/tmp/mermaid_export.mmd"
          local tmp_png = "/tmp/mermaid_export.png"
          local file = io.open(tmp_mmd, "w")
          if file then
            file:write(table.concat(mermaid_code, "\n"))
            file:close()
          end

          -- Run mmdc and copy to clipboard (scale 3x for higher resolution)
          vim.fn.jobstart(
            string.format("mmdc -i %s -o %s -b transparent -s 3 && osascript -e 'set the clipboard to (read (POSIX file \"%s\") as JPEG picture)'", tmp_mmd, tmp_png, tmp_png),
            {
              on_exit = function(_, code)
                if code == 0 then
                  vim.notify("Mermaid diagram copied to clipboard", vim.log.levels.INFO)
                else
                  vim.notify("Failed to export mermaid diagram", vim.log.levels.ERROR)
                end
              end,
            }
          )
        end,
        desc = "Export Mermaid to clipboard",
        ft = "markdown",
      },
    },
  },
}
