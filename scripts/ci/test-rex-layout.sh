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
  { id = "c", label = "5-dashboard" },
  { id = "d", label = "notes" },
  { id = "e", label = "cnb" },
}
local plan = layout.plan(today, true)
check(labels(plan), "1-dashboard 2-cnb 3-warp-factory-setup 4-foo 5-notes",
  "the layout's sessions go first and the rest are renumbered by position")
check(plan[1].id .. plan[2].id .. plan[3].id, "cea", "order is layout first, then the rest as they were")

local full = {
  { id = "a", label = "1-warp-factory-setup" },
  { id = "b", label = "dashboard" },
  { id = "c", label = "2-cnb" },
  { id = "d", label = "3-abs" },
  { id = "e", label = "2-3-foo" },
}
plan = layout.plan(full, true)
check(labels(plan), "1-dashboard 2-cnb 3-abs 4-warp-factory-setup 5-foo",
  "with all three layout sessions, the rest number from 4")
check(labels(rerun(plan, true)), labels(plan), "a rerun changes nothing")
for i, p in ipairs(rerun(plan, true)) do check(p.label, p.want, "rerun label " .. i) end

plan = layout.plan({ { id = "x", label = "dashboard" }, { id = "y", label = "4-dashboard" } }, true)
check(labels(plan), "1-dashboard 2-dashboard", "a duplicate dashboard is not a second layout session")
check(labels(rerun(plan, true)), labels(plan), "a duplicate stays put on a rerun")

check(labels(layout.plan(names({ "dashboard", "abs", "foo" }), true)), "1-dashboard 2-abs 3-foo",
  "a missing middle layout session leaves no repeated number")
check(labels(layout.plan(names({ "cnb", "foo" }), true)), "1-cnb 2-foo",
  "every number is the real Ctrl-N position")
plan = layout.plan(names({ "abs" }), false)
check(labels(plan), "1-abs", "a remote host numbers by plain position")
plan = layout.plan(names({ "foo", "3-abs", "dashboard" }), false)
check(labels(plan), "1-foo 2-abs 3-dashboard", "a remote host keeps its order")
check(labels(rerun(plan, false)), labels(plan), "a remote rerun changes nothing")

check(layout.sessions[1].tabs[1].command[1], "/home/test/.local/bin/rexboard", "paths come from HOME")
for i, k in ipairs(layout.keys) do
  local e = layout.entry(k[1])
  if not (e and e.tabs[k[2]]) then error("alt+shift+" .. i .. " names no layout tab: " .. k[1] .. " " .. k[2], 0) end
end
LUA
) || fail "layout numbering: $out"
pass "layout numbering: stacked prefixes, an existing 1- session, gaps, remote hosts, reruns"
