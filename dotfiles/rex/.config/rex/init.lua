require("actions")
require("hosts")

-- Physical keys, so the bindings survive a non-ASCII input source.
local function key(s)
  return (s:gsub("(%w+)$", function(k)
    if k:match("^%a$") then return "[Key" .. k:upper() .. "]" end
    if k:match("^%d$") then return "[Digit" .. k .. "]" end
  end))
end

local function bind(k, action, args)
  rex.bind(key(k), action, args)
end

-- Same prefix and letters as Herdr (dotfiles/herdr/.config/herdr/config.toml).
-- Ctrl still held after the prefix sends ctrl+<letter>; unbound, it reaches the
-- shell, and ctrl+z suspends the program. C-x C-x stays the ctrl+x passthrough.
local function px(k, action, args)
  rex.bind("ctrl+[KeyX]>" .. key(k), action, args)
  if k:match("^%l$") and k ~= "x" then
    rex.bind("ctrl+[KeyX]>" .. key("ctrl+" .. k), action, args)
  end
end

local dirs = { h = "left", j = "down", k = "up", l = "right" }

for k, dir in pairs(dirs) do
  px("shift+" .. k, "pane.move." .. dir)
  bind("ctrl+alt+" .. k, "pane.focus." .. dir)
end
px("tab", "pane.focus_next")
px("shift+tab", "pane.focus_previous")
px("z", "pane.zoom")
bind("ctrl+alt+z", "pane.zoom")
px("m", "pane.split.right")
px("v", "pane.split.down")
px("x", "pane.close")
px("e", "pane.balance")
px("r", "client.mode.enter", { name = "resize" })
px(",", "pane_label")
px("shift+p", "pane_label")
px("space", "fingers")

px("c", "client.tab.new")
px("shift+t", "client.tab.rename")
px("shift+x", "client.tab.close")
-- Rex's own ctrl+shift+up/down never reach it; these replace its shift+cmd+arrow splits (C-x m/v split).
for _, k in ipairs({ "up", "left" }) do bind("shift+cmd+" .. k, "client.tab.move.backward") end
for _, k in ipairs({ "down", "right" }) do bind("shift+cmd+" .. k, "client.tab.move.forward") end

-- cmd+N is a tab in this session, ctrl+N is a session.
for i = 1, 9 do
  px(tostring(i), "tab_goto", { index = i })
  bind("cmd+" .. i, "tab_goto", { index = i })
  bind("ctrl+" .. i, "session_goto", { index = i })
end
px("0", "home")
-- The session picker stays on Rex's cmd+k.
px("a", "session.previous")
px("shift+right", "session.next")
bind("alt+cmd+[BracketRight]", "session.next")
px("shift+n", "session.new")
px("shift+s", "session.rename")
px("shift+w", "session.open_on_web")
px("shift+i", "session_renumber")
px("i", "tab_renumber")
px("shift+d", "session.close")

px("shift+m", "client.host.switch")
bind("shift+cmd+k", "client.host.switch")

px("shift+down", "agent_attention")
px("o", "agent_attention")
px("shift+up", "agent_attention", { back = true })
bind("ctrl+alt+a", "agent_attention")

px("b", "client.sidebar.toggle")
bind("cmd+b", "client.sidebar.toggle")
px("shift+r", "client.config.reload")
px("shift+/", "client.palette.toggle")
px("shift+g", "open_pr")
px("[BracketLeft]", "copy_mode")
px("ctrl+x", "pane.send_key", { key = "ctrl+x" })
bind("cmd+up", "client.prompt.previous")
bind("cmd+down", "client.prompt.next")
bind("cmd+escape", "client.notice.dismiss")

rex.mode("resize", { exclusive = true })
for k, dir in pairs(dirs) do
  for _, name in ipairs({ k, dir }) do
    bind("resize/" .. name, "pane.resize", { direction = dir })
    bind("resize/shift+" .. name, "pane.resize", { direction = dir, amount = 15 })
  end
end
bind("resize/=", "pane.balance")
bind("resize/enter", "client.mode.exit")
