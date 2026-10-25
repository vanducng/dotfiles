-- The sessions session_layout keeps at the top of this Mac's sidebar, in order. Pure Lua, so
-- scripts/ci/test-rex-layout.sh can test the numbering without Rex.
local M = {}

local home = os.getenv("HOME") or ""

M.sessions = {
  { name = "1-dashboard", tabs = {
    { label = "rexboard", command = { home .. "/.local/bin/rexboard", "board" } },
    { label = "rig", command = { "rig", "tui" } },
  } },
  { name = "2-cnb", dir = home .. "/git/work/cnb", tabs = { { label = "claude", command = { "claude" } } } },
  { name = "3-abs", dir = home .. "/git/work/abs", tabs = { { label = "claude", command = { "claude" } } } },
}

-- A label without its leading "<n>-" run: "2-3-foo" and "foo" are both "foo".
function M.base(label)
  local s, n = label or "", 1
  while n > 0 do s, n = s:gsub("^%d+%-", "", 1) end
  return s
end

-- The layout entry a session label stands for, by base name, or nil.
function M.entry(label)
  local b = M.base(label)
  for i, e in ipairs(M.sessions) do
    if M.base(e.name) == b then return e, i end
  end
end

-- sessions: { { id, label } } in sidebar order. Returns them with the layout's own first, in
-- layout order, and the rest after in their current order, each with the label it should have:
-- the layout's name, or its position and base name ("4-warp-factory-setup"). A second
-- layout-named session (a duplicate "dashboard") counts as one of the rest.
function M.plan(sessions)
  local slot, rest = {}, {}
  for _, s in ipairs(sessions) do
    local e, i = M.entry(s.label)
    if e and not slot[i] then slot[i] = { id = s.id, label = s.label, want = e.name }
    else rest[#rest + 1] = s end
  end
  local out = {}
  for i = 1, #M.sessions do
    if slot[i] then out[#out + 1] = slot[i] end
  end
  for _, s in ipairs(rest) do
    local b = M.base(s.label)
    out[#out + 1] = { id = s.id, label = s.label, want = b == "" and tostring(#out + 1) or (#out + 1) .. "-" .. b }
  end
  return out
end

return M
