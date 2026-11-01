-- The sessions session_layout keeps at the top of this Mac's sidebar, in order. Pure Lua, so
-- scripts/ci/test-rex-layout.sh can test the numbering without Rex.
local M = {}

local home = os.getenv("HOME") or ""

-- Whether a file is there to run. Tests swap it for a fake.
function M.exists(path)
  local f = io.open(path)
  if f then f:close() end
  return f ~= nil
end

-- rexboard's path, or nil: Homebrew's prefix, the usual Homebrew and install.sh places, then
-- PATH. Rex actions can run with a minimal PATH, so the known places come first.
function M.rexboard(getenv)
  getenv = getenv or os.getenv
  local dirs = {}
  local prefix = getenv("HOMEBREW_PREFIX")
  if prefix and prefix ~= "" then dirs[#dirs + 1] = prefix .. "/bin" end
  for _, d in ipairs({ "/opt/homebrew/bin", "/usr/local/bin", (getenv("HOME") or "") .. "/.local/bin" }) do
    dirs[#dirs + 1] = d
  end
  for d in (getenv("PATH") or ""):gmatch("[^:]+") do dirs[#dirs + 1] = d end
  for _, d in ipairs(dirs) do
    if M.exists(d .. "/rexboard") then return d .. "/rexboard" end
  end
end

M.sessions = {
  { name = "1-cockpit", tabs = {
    -- Resolved when the tab is made; a bare name falls back to the tab shell's PATH.
    { label = "rexboard", command = function() return { M.rexboard() or "rexboard", "board" } end },
    { label = "rig", command = { "rig", "tui" } },
    { label = "pi", dir = home .. "/projects", command = { "pi" } },
  } },
}

-- alt+shift+1..3: { session, tab number }.
M.keys = { { "1-cockpit", 1 }, { "1-cockpit", 2 }, { "1-cockpit", 3 } }

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
