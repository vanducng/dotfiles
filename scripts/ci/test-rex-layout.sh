#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REX="$ROOT/dotfiles/rex/.config/rex"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

# Rex runs Lua 5.1; luajit is the closest local stand-in, lua 5.4 the fallback.
LUA=$(command -v luajit || command -v lua || true)
[ -n "$LUA" ] || fail "no lua or luajit to run the layout tests"

out=$(HOME=/home/test "$LUA" - "$REX/?.lua" 2>&1 <<'LUA'
package.path = arg[1] .. ";" .. package.path
local layout = require("layout")

local function check(got, want, what)
  if got ~= want then error(what .. ": got " .. tostring(got) .. ", want " .. tostring(want), 0) end
end

local function labels(plan)
  local out = {}
  for i, p in ipairs(plan) do out[i] = p.want end
  return table.concat(out, " ")
end

local function rerun(plan, here)
  local next = {}
  for i, p in ipairs(plan) do next[i] = { id = p.id, label = p.want } end
  return layout.plan(next, here)
end

local function names(list)
  local out = {}
  for i, l in ipairs(list) do out[i] = { id = tostring(i), label = l } end
  return out
end

check(layout.base("2-3-foo"), "foo", "a stacked prefix is stripped whole")
check(layout.base("1-warp-factory-setup"), "warp-factory-setup", "one prefix is stripped")
check(layout.base("rexboard"), "rexboard", "a plain label stays")

local today = {
  { id = "a", label = "1-warp-factory-setup" },
  { id = "b", label = "2-3-foo" },
  { id = "c", label = "5-cockpit" },
  { id = "d", label = "notes" },
  { id = "e", label = "cnb" },
}
local plan = layout.plan(today, true)
check(labels(plan), "1-cockpit 2-warp-factory-setup 3-foo 4-notes 5-cnb",
  "the layout's session goes first and the rest are renumbered by position")
check(plan[1].id .. plan[2].id .. plan[3].id, "cab", "order is layout first, then the rest as they were")
check(labels(rerun(plan, true)), labels(plan), "a rerun changes nothing")
for i, p in ipairs(rerun(plan, true)) do check(p.label, p.want, "rerun label " .. i) end

plan = layout.plan({ { id = "x", label = "cockpit" }, { id = "y", label = "4-cockpit" } }, true)
check(labels(plan), "1-cockpit 2-cockpit", "a duplicate cockpit is not a second layout session")
check(labels(rerun(plan, true)), labels(plan), "a duplicate stays put on a rerun")

check(labels(layout.plan(names({ "cnb", "foo" }), true)), "1-cnb 2-foo",
  "with no cockpit, every number is the real Ctrl-N position")
plan = layout.plan(names({ "abs" }), false)
check(labels(plan), "1-abs", "a remote host numbers by plain position")
plan = layout.plan(names({ "foo", "3-abs", "cockpit" }), false)
check(labels(plan), "1-foo 2-abs 3-cockpit", "a remote host keeps its order")
check(labels(rerun(plan, false)), labels(plan), "a remote rerun changes nothing")
plan = layout.plan(names({ "foo", "" }), false)
check(labels(plan), "1-foo 2-", "an empty name keeps its number")
check(labels(rerun(plan, false)), labels(plan), "an empty name is stable on a rerun")

-- rexboard: $HOMEBREW_PREFIX/bin, /opt/homebrew/bin, /usr/local/bin, ~/.local/bin, then PATH.
local real_exists = layout.exists
local function find(installed, env)
  layout.exists = function(p) return installed[p] == true end
  local got = layout.rexboard(function(k) return env[k] end)
  layout.exists = real_exists
  return got
end
local env = { HOME = "/home/test", PATH = "/usr/bin:/home/test/bin", HOMEBREW_PREFIX = "/brew" }
local all = { ["/brew/bin/rexboard"] = true, ["/opt/homebrew/bin/rexboard"] = true,
  ["/usr/local/bin/rexboard"] = true, ["/home/test/.local/bin/rexboard"] = true,
  ["/home/test/bin/rexboard"] = true }
local order = { "/brew/bin/rexboard", "/opt/homebrew/bin/rexboard", "/usr/local/bin/rexboard",
  "/home/test/.local/bin/rexboard", "/home/test/bin/rexboard" }
for _, want in ipairs(order) do
  check(find(all, env), want, "rexboard resolves in order")
  all[want] = nil
end
check(find({}, env), nil, "no rexboard anywhere is nil")
check(find({ ["/opt/homebrew/bin/rexboard"] = true }, { HOME = "/home/test" }), "/opt/homebrew/bin/rexboard",
  "no HOMEBREW_PREFIX and no PATH still finds Homebrew's default")
layout.exists = function(p) return p == "/home/test/.local/bin/rexboard" end
local tab = layout.sessions[1].tabs[1].command()
check(tab[1] .. " " .. tab[2], "/home/test/.local/bin/rexboard board", "the cockpit's board tab resolves when made")
layout.exists = function() return false end
check(layout.sessions[1].tabs[1].command()[1], "rexboard", "a missing rexboard falls back to the tab shell's PATH")
layout.exists = real_exists
check(layout.sessions[1].tabs[3].dir, "/home/test/projects", "a tab's own folder comes from HOME")
for i, k in ipairs(layout.keys) do
  local e = layout.entry(k[1])
  if not (e and e.tabs[k[2]]) then error("alt+shift+" .. i .. " names no layout tab: " .. k[1] .. " " .. k[2], 0) end
end
LUA
) || fail "layout numbering: $out"
pass "layout numbering: stacked prefixes, an existing 1- session, gaps, remote hosts, reruns; rexboard resolution order"
