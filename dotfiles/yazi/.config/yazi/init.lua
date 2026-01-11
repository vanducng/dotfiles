-- Yazi init.lua configuration
-- This file runs synchronously when yazi starts

-- Custom keybindings can be defined here
-- Example: require("relative-motions"):setup({ show_numbers = "relative" })

-- Enable borders
require("full-border"):setup()

-- Initial directory is read by initial-dir plugin from YAZI_INITIAL_DIR env var

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

