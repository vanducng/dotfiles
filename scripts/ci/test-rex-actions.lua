local root = assert(arg[1])
package.path = root .. "/dotfiles/rex/.config/rex/?.lua;" .. package.path
package.loaded.hosts = { order = {}, self = "mac-a" }
local actions, created, windows = {}, {}, {}
local context = { session_id = "s", block_id = "source", client_id = "app" }
local layer
rex = {
  action = function(a) actions[a.name] = a end,
  log = function() end,
  json = { decode = function(d) return d end, encode = function(d) return d end },
  layout = { block = function(b) return { block = b } end },
  client = { queue = function() end },
  servers = function() return {} end,
  server = function() return { call = function(method)
    if method == "server.whoami" then return { principal = { node = "mac" } } end
    if method == "client.list" then
      return { clients = { { client_id = "other", info = { kind = "app" }, principal = { node = "mini" } },
        { client_id = "mac-there", info = { kind = "app" }, principal = { node = "mac" } } } }
    end
  end } end,
  call = function(method)
    if method == "session.list" then
      return { sessions = { { session_id = "s", label = "1-cockpit" }, { session_id = "t", label = "2-api\tx" } } }
    end
    return {}
  end,
  session = {
    view = function(d)
      return { windows = { { window_id = "w", focused_block_id = d.session_id == "t" and "api" or "source",
        zoomed_block_id = d.session_id == "z" and "source" or nil, layers = {
        { kind = "tiled", layout = { block_id = "source", rect = { 0.5, 0, 0.5, 1 } } },
      } } } }
    end,
    new_layer = function(d) layer = d; return { layer_id = "popup" } end,
  },
  block = { call = function(_, method, d)
    if method == "pwd" then return { pwd = d.block_id == "api" and "file:///work/api%20v2" or "file:///work/home" } end
    if method == "format" then return { content = "https://example.com\n" } end
  end },
  exec = function(argv)
    local op = argv[2]
    if op == "ls" then return { ok = true, stdout = { sessions = { { session_id = "s", label = "1-cockpit" } } } } end
    if op == "session" and argv[3] == "inspect" then return { ok = true, stdout = { windows = windows } } end
    if op == "window" and argv[3] == "new" then
      created[#created + 1] = argv[6]
      windows[#windows + 1] = { window_id = "added", label = argv[6] }
      return { ok = true, stdout = {} }
    end
    error("unexpected command " .. table.concat(argv, " "))
  end,
}
require("layout").rexboard = function() return "/mac/rexboard" end
dofile(root .. "/dotfiles/rex/.config/rex/actions.lua")

actions.fingers.run(context)
os.remove(layer.layout.block.options.command[7])
assert(layer.bounds[1] == 0.1 and layer.bounds[2] == 0.1, "URL picker must remain centered")
assert(layer.window_id == "w", "popup must belong to the source window")

actions.project_pick.run(context)
local cmd = layer.layout.block.options.command
assert(layer.bounds[1] == 0.15 and layer.focus, "project picker floats centered with focus")
local f = assert(io.open(cmd[7]))
local list = f:read("*a")
f:close()
os.remove(cmd[7])
assert(list == "s\t1-cockpit\t/work/home\t1\nt\t2-api x\t/work/api v2\t\n", "session list: " .. list)
assert(cmd[8] == "app", "picker switches the app that pressed the key")
local ok, err = pcall(actions.project_pick.run, { session_id = "s", block_id = "source", server = "host-b" })
assert(not ok and err:match("local session"), "project picker stays on this Mac")

layer = nil
actions.agent_pick.run({ session_id = "s", block_id = "source", client_id = "app", server = "host-b" })
cmd = assert(layer, "agent picker floats on another host's pane").layout.block.options.command
assert(layer.window_id == "w" and layer.focus, "agent picker opens over the pane's own window")
assert(layer.bounds[1] == 0.08 and layer.bounds[3] == 0.84, "agent picker floats centered, not full window")
assert(cmd[3]:match("ssh %-qt") and cmd[3]:match("board %-%-once"), "a remote pane runs this Mac's board over ssh")
assert(cmd[8] == "/mac/rexboard" and cmd[9] == "mac-a", "ssh to this Mac and run its rexboard")
actions.agent_pick.run(context)
cmd = layer.layout.block.options.command
assert(cmd[8] == "/mac/rexboard" and cmd[9] == "", "a local pane runs the board here, no ssh")
actions.agent_pick.run({ session_id = "z", block_id = "source", client_id = "app" })
assert(layer.bounds[1] == 0 and layer.bounds[3] == 1 and layer.bounds.fill_zoomed == nil,
  "over a zoomed pane the board fills the window, so the unzoomed tabs never show")
assert(layer.layout.block.options.command[6] == "1", "and re-zooms the pane on quit")
assert(layer.layout.block.options.command[10] == "z", "and names its session for a jump's re-zoom")

local view, calls = rex.session.view, {}
local function rezoom(active, focused)
  calls = {}
  rex.session.view = function() return { active_window_id = active, windows = {
    { window_id = "w", focused_block_id = active == "w" and focused or "popup", layers = {
      { kind = "tiled", layout = { split = { before = { block_id = "source", rect = {} }, after = { block_id = "b", rect = {} } } } },
      { kind = "floating", blocks = { { block_id = "popup" } } } } },
    { window_id = "w2", focused_block_id = "c", layers = { { kind = "tiled", layout = { block_id = "c", rect = {} } } } },
  } } end
  rex.session.zoom_block = function(d) calls[#calls + 1] = "zoom " .. d.block_id end
  rex.session.focus_block = function(d) calls[#calls + 1] = "focus " .. d.block_id end
  actions.agent_pick_rezoom.run({}, { session = "z", block = "source" })
  return table.concat(calls, ",")
end
assert(rezoom("w", "b") == "zoom b", "a jump inside the window zooms the pane it lands on")
assert(rezoom("w2", "c") == "zoom source,focus c", "a jump to another tab re-zooms the pane left, keeping focus")
assert(rezoom("w", "popup") == "zoom source", "a jump to another session re-zooms the pane left")
rex.session.view = view
actions.fingers.run({ session_id = "z", block_id = "source", client_id = "app" })
os.remove(layer.layout.block.options.command[7])
assert(layer.bounds[1] == 0.1 and layer.bounds[3] == 0.8, "other sized popups keep their size over a zoomed pane")
actions.copy_mode.run({ session_id = "z", block_id = "source", client_id = "app" })
assert(layer.bounds[3] == 1 and layer.bounds[4] == 1, "an overlay without bounds still fills a zoomed window")
os.remove(layer.layout.block.options.command[7])

windows = { { window_id = "board", label = "1-rexboard" }, { window_id = "pi", label = "pi" },
  { window_id = "custom", label = "notes" } }
actions.session_layout.run(context, {})
assert(#created == 1 and created[1] == "rig", "restore the missing named tab despite unrelated tabs")
actions.session_layout.run(context, {})
assert(#created == 1, "layout recovery must be idempotent")
print("rex actions: floating pickers and named-tab recovery passed")
