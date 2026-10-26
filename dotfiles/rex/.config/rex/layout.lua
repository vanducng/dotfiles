-- The sessions session_layout keeps at the top of this Mac's sidebar, in order. Pure Lua, so
-- scripts/ci/test-rex-layout.sh can test the numbering without Rex.
local M = {}

local home = os.getenv("HOME") or ""

M.sessions = {
  { name = "1-cockpit", tabs = {
    { label = "rexboard", command = { home .. "/.local/bin/rexboard", "board" } },
    { label = "rig", command = { "rig", "tui" } },
    { label = "foreman", dir = home .. "/projects", command = { "claude" } },
  } },
  { name = "2-cnb", dir = home .. "/git/work/cnb", tabs = { { label = "claude", command = { "claude" } } } },
  { name = "3-abs", dir = home .. "/git/work/ab-spectrum", tabs = { { label = "claude", command = { "claude" } } } },
}

-- alt+shift+1..5: { session, tab number }.
M.keys = { { "1-cockpit", 1 }, { "1-cockpit", 2 }, { "1-cockpit", 3 }, { "2-cnb", 1 }, { "3-abs", 1 } }

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

-- sessions: { { id, label } } in sidebar order. Returns them in the order they should have,
-- each labelled "<Ctrl-N position>-<base name>". On this Mac (here) the layout's sessions go
-- first, in layout order; a second "cockpit" counts as one of the rest. Elsewhere the order
-- stays as it is.
function M.plan(sessions, here)
  local slot, rest = {}, {}
  for _, s in ipairs(sessions) do
    local _, i = M.entry(s.label)
    if here and i and not slot[i] then slot[i] = s else rest[#rest + 1] = s end
  end
  local out = {}
  for i = 1, #M.sessions do
    if slot[i] then out[#out + 1] = slot[i] end
  end
  for _, s in ipairs(rest) do out[#out + 1] = s end
  -- An empty name keeps its dash ("4-"), so a rerun reads it as empty again, not as "4".
  for i, s in ipairs(out) do out[i] = { id = s.id, label = s.label, want = i .. "-" .. M.base(s.label) } end
  return out
end

return M
