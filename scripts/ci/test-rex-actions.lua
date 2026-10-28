local root = assert(arg[1])
package.path = root .. "/dotfiles/rex/.config/rex/?.lua;" .. package.path
package.loaded.hosts = { order = {} }
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
  call = function(method)
    if method == "session.list" then
      return { sessions = { { session_id = "s", label = "1-cockpit" }, { session_id = "t", label = "2-api\tx" } } }
    end
    return {}
  end,
  session = {
    view = function(d)
      return { windows = { { window_id = "w", focused_block_id = d.session_id == "t" and "api" or "source", layers = {
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
    -- Only the cockpit has no folder, so the other layout sessions are skipped here.
    if argv[1] == "test" then return { ok = false } end
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
local ok, err = pcall(actions.project_pick.run, { session_id = "s", block_id = "source", server = "mini-01" })
assert(not ok and err:match("local session"), "project picker stays on this Mac")

windows = { { window_id = "board", label = "1-rexboard" }, { window_id = "foreman", label = "foreman" },
  { window_id = "custom", label = "notes" } }
actions.session_layout.run(context, {})
assert(#created == 1 and created[1] == "rig", "restore the missing named tab despite unrelated tabs")
actions.session_layout.run(context, {})
assert(#created == 1, "layout recovery must be idempotent")
print("rex actions: floating pickers and named-tab recovery passed")
