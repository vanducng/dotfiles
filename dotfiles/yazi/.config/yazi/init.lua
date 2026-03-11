-- Yazi init.lua configuration
-- This file runs synchronously when yazi starts

-- Custom keybindings can be defined here
-- Example: require("relative-motions"):setup({ show_numbers = "relative" })

-- Enable borders
require("full-border"):setup()

-- Capture initial directory from env var
-- YAZI_INITIAL_DIR: set by yy shell function
-- NVIM_CWD: set by yazi.nvim when launched from neovim
YAZI_INITIAL_DIR = os.getenv("YAZI_INITIAL_DIR") or os.getenv("NVIM_CWD")

-- Custom linemode for showing size and modification time
function Linemode:size_and_mtime()
    local time = math.floor(self._file.cha.mtime or 0)
    if time == 0 then
        time = ""
    elseif os.date("%Y", time) == os.date("%Y") then
        time = os.date("%b %d %H:%M", time)
    else
        time = os.date("%b %d %Y", time)
    end

    local size = self._file:size()
    return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

