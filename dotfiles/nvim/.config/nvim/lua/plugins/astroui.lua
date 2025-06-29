---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "duskfox",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "#000000" },
        -- Neo-tree transparent background
        NeoTreeNormal = { bg = "NONE" },
        NeoTreeNormalNC = { bg = "NONE" },
        NeoTreeFloatBorder = { bg = "NONE" },
        NeoTreeFloatNormal = { bg = "NONE" },
        NeoTreeFloatTitle = { bg = "NONE" },
        NeoTreeTabInactive = { bg = "NONE" },
        NeoTreeTabActive = { bg = "NONE" },
        NeoTreeTabSeparatorInactive = { bg = "NONE" },
        NeoTreeTabSeparatorActive = { bg = "NONE" },
        NeoTreeWinSeparator = { bg = "NONE" },
        NeoTreeEndOfBuffer = { bg = "NONE" },
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
