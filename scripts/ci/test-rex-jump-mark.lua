-- The jump and mark modes (actions.lua rb_*): the digit buffer against rexboard's exit codes, and
-- where each command runs (BOARD_HOST), with the exact argv. No Rex app or server: rex is a fake.
local root = assert(arg[1])
package.path = root .. "/dotfiles/rex/.config/rex/?.lua;" .. package.path
local hosts = { order = { "mac-a", "mac-b", "box-c" }, self = "mac-a" }
package.loaded.hosts = hosts
local actions, queued, ran = {}, {}, {}
local answer = function() return { ok = true, code = 0, stdout = "", stderr = "" } end
rex = {
  action = function(a) actions[a.name] = a end,
  log = function() end,
  json = { decode = function(d) return d end },
  client = { queue = function(action, args) queued[#queued + 1] = action .. (args and args.name and (" " .. args.name) or "") end },
  exec = function(argv, opts)
    ran[#ran + 1] = { argv = argv, opts = opts }
    return answer(argv)
  end,
}
require("layout").rexboard = function() return "/bin/rexboard" end
dofile(root .. "/dotfiles/rex/.config/rex/actions.lua")

local env_host
local getenv = os.getenv
os.getenv = function(k) if k == "BOARD_HOST" then return env_host end return getenv(k) end

local here = { session_id = "s", block_id = "block:b1" }
local remote_pane = { session_id = "s", block_id = "block:b2", server = "box-c" }
local function reset() queued, ran = {}, {} end
local function code(n, err) return function() return { ok = n == 0, code = n, stdout = "", stderr = err or "" } end end
local function last() return ran[#ran] end
local function argv() return table.concat(last().argv, " ") end
local function press(name, ctx, args) return pcall(actions[name].run, ctx or here, args or {}) end

-- C-x ' enters the jump mode with an empty buffer; C-x " the mark mode.
actions.rb_jump_mode.run(here)
actions.rb_mark_mode.run(here)
assert(queued[1] == "client.mode.enter jump" and queued[2] == "client.mode.enter mark", "the chords enter the modes")

-- Digits, here (no BOARD_HOST): exit 3 waits, exit 0 jumps and leaves.
reset(); actions.rb_jump_mode.run(here); reset()
answer = code(3)
assert(press("rb_row", here, { digit = "1" }))
assert(argv() == "/bin/rexboard jump --shown 1 --partial", "first digit asks with --partial: " .. argv())
assert(#queued == 0, "exit 3 stays in the mode")
assert(last().opts.timeout == 35, "a jump may wait 30 s for the app, so the call waits 35")
answer = code(0)
assert(press("rb_row", here, { digit = "2" }))
assert(argv() == "/bin/rexboard jump --shown 12 --partial", "the buffer grows: " .. argv())
assert(queued[1] == "client.mode.exit", "exit 0 leaves the mode")
reset()
assert(press("rb_row", here, { digit = "4" }))
assert(argv() == "/bin/rexboard jump --shown 4 --partial", "a jump clears the buffer: " .. argv())

-- An error clears the buffer, leaves, and shows rexboard's reason.
reset(); answer = code(3)
press("rb_row", here, { digit = "1" })
answer = code(1, "NOT_FOUND no row 19 · rows 1-12 on the board\n")
local ok, err = press("rb_row", here, { digit = "9" })
assert(not ok and err == "NOT_FOUND no row 19 · rows 1-12 on the board", "the reason is shown: " .. tostring(err))
assert(queued[#queued] == "client.mode.exit", "an error leaves the mode")
answer = code(0); reset()
press("rb_row", here, { digit = "3" })
assert(argv() == "/bin/rexboard jump --shown 3 --partial", "an error cleared the buffer: " .. argv())

-- A failed run (no result) leaves too.
reset(); answer = function() return nil, "timed out" end
ok, err = press("rb_row", here, { digit = "5" })
assert(not ok and err == "timed out" and queued[1] == "client.mode.exit", "a run that fails leaves")
answer = code(0)

-- Each client types its own number: a digit from a second app on the same server starts afresh.
reset(); answer = code(3)
press("rb_row", { session_id = "s", block_id = "block:b1", client_id = "app-1" }, { digit = "1" })
press("rb_row", { session_id = "s", block_id = "block:b1", client_id = "app-2" }, { digit = "2" })
assert(argv() == "/bin/rexboard jump --shown 2 --partial", "a second client has its own buffer: " .. argv())
press("rb_row", { session_id = "s", block_id = "block:b1", client_id = "app-1" }, { digit = "1" })
assert(argv() == "/bin/rexboard jump --shown 11 --partial", "the first client kept its digits: " .. argv())
actions.rb_leave.run({ client_id = "app-1" }); actions.rb_leave.run({ client_id = "app-2" })
answer = code(0)

-- enter runs the whole number without --partial; with nothing typed it only leaves.
reset(); answer = code(3)
press("rb_row", here, { digit = "1" })
answer = code(0)
assert(press("rb_row_enter", here))
assert(argv() == "/bin/rexboard jump --shown 1", "enter: " .. argv())
assert(queued[#queued] == "client.mode.exit")
reset()
assert(press("rb_row_enter", here))
assert(#ran == 0 and queued[1] == "client.mode.exit", "enter with no digits only leaves")

-- escape clears: the next digit starts a new number.
reset(); answer = code(3)
press("rb_row", here, { digit = "1" })
actions.rb_leave.run(here)
press("rb_row", here, { digit = "7" })
assert(argv() == "/bin/rexboard jump --shown 7 --partial", "escape cleared the buffer: " .. argv())
actions.rb_leave.run(here)
answer = code(0)

-- Marks: a letter jumps to its pane, or marks this one (REX_BLOCK here).
reset()
assert(press("rb_mark_jump", here, { letter = "a" }))
assert(argv() == "/bin/rexboard jump @a" and queued[1] == "client.mode.exit", "jump @a: " .. argv())
reset()
assert(press("rb_mark_set", here, { letter = "q" }))
assert(argv() == "/bin/rexboard mark set q", "mark set: " .. argv())
assert(last().opts.env.REX_BLOCK == "block:b1", "mark set names this pane by REX_BLOCK")
reset()
assert(press("rb_mark_set", remote_pane, { letter = "q" }))
assert(argv() == "/bin/rexboard mark set q --key box-c/block:b2", "another host's pane goes by its key: " .. argv())
assert(last().opts.env.REX_BLOCK == nil)
answer = code(2, "pane shell has no label of its own: label it in Rex\n")
ok, err = press("rb_mark_set", here, { letter = "q" })
assert(not ok and err:match("label it in Rex") and queued[#queued] == "client.mode.exit", "a refused mark leaves with the reason")
answer = code(0)

-- Nothing but a digit or a letter reaches rexboard.
reset()
for _, bad in ipairs({ { "rb_row", { digit = "1; rm -rf /" } }, { "rb_mark_jump", { letter = "A" } },
  { "rb_mark_set", { letter = "$(x)" } } }) do
  assert(press(bad[1], here, bad[2]))
end
assert(#ran == 0, "a bad key argument runs nothing")

-- BOARD_HOST from hosts.json ("board": true), then the environment: commands go there over ssh.
local function ssh_check(want_host, want_remote)
  local a = last().argv
  assert(a[1] == "ssh" and a[6] == want_host and a[7] == "--", "ssh to the board host: " .. argv())
  assert(#a == 8, "one remote command string, then nothing")
  assert(a[8] == 'PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH" exec rexboard ' .. want_remote,
    "remote command: " .. a[8])
  assert(table.concat(a, " ", 2, 5) == "-o BatchMode=yes -o ConnectTimeout=5", "no prompt, short connect")
end
hosts.board = "mac-b"
reset(); answer = code(3)
press("rb_row", here, { digit = "1" })
ssh_check("mac-b", "'jump' '--shown' '1' '--partial'")
answer = code(0)
press("rb_row", here, { digit = "0" })
ssh_check("mac-b", "'jump' '--shown' '10' '--partial'")
press("rb_mark_set", here, { letter = "c" })
ssh_check("mac-b", "'mark' 'set' 'c' '--key' 'mac-a/block:b1'")
assert(last().opts.env.REX_BLOCK == nil, "REX_BLOCK means nothing on the board host")
press("rb_mark_set", remote_pane, { letter = "c" })
ssh_check("mac-b", "'mark' 'set' 'c' '--key' 'box-c/block:b2'")
press("rb_mark_set", { session_id = "s", block_id = "block:b3", server = "mac-b" }, { letter = "d" })
ssh_check("mac-b", "'mark' 'set' 'd' '--key' 'local/block:b3'")
press("rb_mark_jump", here, { letter = "d" })
ssh_check("mac-b", "'jump' '@d'")

env_host = "box-c"
press("rb_mark_jump", here, { letter = "e" })
ssh_check("box-c", "'jump' '@e'")
env_host = "mac-a"
press("rb_mark_jump", here, { letter = "e" })
assert(argv() == "/bin/rexboard jump @e", "BOARD_HOST naming this host runs here: " .. argv())
env_host = "box-c; touch /tmp/x"
ok, err = press("rb_mark_jump", here, { letter = "e" })
assert(not ok and err:match("not a host label"), "a BOARD_HOST that is not a label is refused")
env_host = nil

-- A pane key that is not a plain word is refused before anything runs.
reset()
ok, err = press("rb_mark_set", { session_id = "s", block_id = "b'; touch /tmp/x; '", server = "box-c" }, { letter = "a" })
assert(not ok and err:match("not a plain rexboard argument") and #ran == 0, "a strange pane id runs nothing")

-- A host missing from hosts.json cannot name its panes for another host.
hosts.self = nil
ok, err = press("rb_mark_set", here, { letter = "a" })
assert(not ok and err:match("not in hosts.json"), "no key without this host's label")
hosts.self, hosts.board = "mac-a", nil

-- agent_next waits as long as a jump does.
reset()
actions.agent_next.run(here, {})
assert(last().opts.timeout == 35, "agent_next waits 35 s")

-- hosts.lua: the first "board": true entry wins, and a second one is logged, not taken.
local tmp = os.tmpname()
os.remove(tmp)
os.execute("mkdir -p " .. tmp)
local f = assert(io.open(tmp .. "/hosts.json", "w"))
f:write("two boards")
f:close()
local logs = {}
local saved = rex
rex = {
  exec = function() return { ok = false, code = 1, stdout = "", stderr = "" } end,
  log = function(level, msg) logs[#logs + 1] = level .. " " .. msg end,
  json = { decode = function() return {
    { label = "mac-a", hostname = "a" }, { label = "mac-b", hostname = "b", board = true },
    { label = "box-c", hostname = "c", board = true } } end },
  host = function() end,
}
os.getenv = function(k) if k == "REX_CONFIG" then return tmp .. "/init.lua" end return getenv(k) end
package.loaded.hosts = nil
local h = dofile(root .. "/dotfiles/rex/.config/rex/hosts.lua")
assert(h.board == "mac-b", "the first board entry wins: " .. tostring(h.board))
assert(table.concat(logs, "\n"):match("box%-c is also marked board; using mac%-b"), "a second board is logged")
os.remove(tmp .. "/hosts.json")
os.remove(tmp)
rex = saved

os.getenv = getenv
print("rex jump and mark: digit buffer, marks and BOARD_HOST argv passed")
