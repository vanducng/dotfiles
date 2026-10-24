local hosts = require("hosts")
local term = "com.superlogical.terminal"
local env ={ PATH = "/opt/homebrew/bin:/usr/local/bin:" .. (os.getenv("PATH") or "/usr/bin:/bin") }
local attention = { blocked = 1, error = 2, done = 3, idle = 4 }

local function sessions()
  local r, err = rex.call("session.list")
  if not r then error(err, 0) end
  return r.sessions or {}
end

-- Calls on a session other than the action's own fail until the stream attaches to all of them.
local function attach_all()
  local _, err = rex.call("session.attach_all", { event_scope = "session" })
  if err then error(err, 0) end
end

-- session_id is needed for a pane outside the action's own session.
local function pane_dir(block_id, session_id)
  local r = rex.block.call(term, "pwd", { block_id = block_id, session_id = session_id })
  if r and r.pwd then
    return (r.pwd:gsub("^file://[^/]*", ""):gsub("%%(%x%x)", function(h)
      return string.char(tonumber(h, 16))
    end))
  end
  -- A program that never reports its directory still runs in one.
  local p, err = rex.block.call(term, "process", { block_id = block_id, session_id = session_id })
  local cwd = p and p.foreground and p.foreground.cwd
  if not cwd then error(err or "pane has no working directory", 0) end
  return cwd
end

local function git(dir, ...)
  local r, err = rex.exec({ "git", "-C", dir, ... }, { env = env, timeout = 5 })
  if not r then rex.log("warn", "git did not run: " .. tostring(err)) end
  if r and r.ok then return (r.stdout:gsub("%s+$", "")) end
end

local function basename(path)
  return path:match("([^/]+)/*$") or path
end

-- The server's PATH has no rex; on macOS the CLI ships inside the server app.
local rex_cli = (os.getenv("HOME") or "") .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
local cli_file = io.open(rex_cli)
if cli_file then
  cli_file:close()
else
  rex_cli = "rex"
  rex.log("warn", "actions: no bundled rex CLI, using rex from PATH")
end

-- While the app shows another host's session, ctx.server names that host and
-- rex.call goes there, so this machine's sessions come from its own socket.
local function local_sessions(ctx)
  if not ctx.server then return sessions() end
  local r, err = rex.exec({ rex_cli, "ls", "--json" }, { env = env, timeout = 5 })
  if not (r and r.ok) then error(err or (r.stderr ~= "" and r.stderr) or "rex ls failed", 0) end
  local ok, d = pcall(rex.json.decode, r.stdout)
  if not ok then error("rex ls returned unreadable output", 0) end
  return d.sessions or {}
end

-- Sessions on one host, in its own order: host is a remote label, or nil for this Mac.
local function host_sessions(ctx, host)
  if not host then return local_sessions(ctx) end
  local r, err = rex.server(host).call("session.list")
  if not r then error(err, 0) end
  return r.sessions or {}
end

-- A queued session.select only finds sessions on this machine's server, so a
-- session on another host is selected by asking the app, through that host, to
-- do it. Host calls travel over the app's own connection, so whoami there names
-- the app's node.
local function select_session(session_id, host, window_id)
  local args = { session_id = session_id, window_id = window_id }
  if not host then return rex.client.queue("session.select", args) end
  local srv = rex.server(host)
  local me, err = srv.call("server.whoami")
  local node = me and me.principal and me.principal.node
  if not node then error(err or ("no Tailscale identity on " .. host), 0) end
  local r, lerr = srv.call("client.list")
  if not r then error(lerr, 0) end
  for _, c in ipairs(r.clients or {}) do
    if c.info and c.info.kind == "app" and c.principal and c.principal.node == node then
      local _, perr = srv.call("client.perform", {
        client_id = c.client_id, action = "session.select", args = args, origin = "key",
      })
      if perr then error(perr, 0) end
      return
    end
  end
  error("this Mac's Rex app is not connected to " .. host, 0)
end

-- The session each app left on its last jump by key, for session_toggle. Memory only: a config
-- reload forgets it, and jumps through cmd+k or the sidebar are not seen.
local came_from = {}

local function remember(ctx, target_id)
  if ctx.client_id and target_id ~= ctx.session_id then
    came_from[ctx.client_id] = { id = ctx.session_id, host = ctx.server }
  end
end

rex.action{
  name = "session_goto",
  title = "Go to Session N",
  description = "Goes to session N on the host being viewed; ctrl+alt+N picks the host.",
  category = "Session",
  args = { index = "integer" },
  run = function(ctx, args)
    local s = host_sessions(ctx, ctx.server)[args.index]
    if not s then error("no session " .. args.index .. (ctx.server and " on " .. ctx.server or ""), 0) end
    remember(ctx, s.session_id)
    select_session(s.session_id, ctx.server)
  end,
}

rex.action{
  name = "session_toggle",
  title = "Toggle Last Session",
  description = "Goes back to the session you left with Ctrl-1..9, C-x 0 or this key; press again to return.",
  category = "Session",
  run = function(ctx)
    local back = ctx.client_id and came_from[ctx.client_id]
    if not back or back.id == ctx.session_id then error("no session to go back to yet", 0) end
    remember(ctx, back.id)
    select_session(back.id, back.host)
  end,
}

-- The session each app last had on each host, so going back to a host lands where you left it.
local last_on = {}

rex.action{
  name = "host_goto",
  title = "Go to Host N",
  description = "Switches to host N in hosts.lua order, on the session you last had there, else its first.",
  category = "Session",
  args = { index = "integer" },
  run = function(ctx, args)
    local label = hosts.order[args.index]
    if not label then error("no host " .. args.index, 0) end
    local host
    if label ~= hosts.self then
      for _, s in ipairs(rex.servers()) do
        if s == label then host = label end
      end
      if not host then error(label .. " is not connected", 0) end
    end
    if host == ctx.server then return end
    local mem = ctx.client_id and last_on[ctx.client_id] or {}
    mem[ctx.server or hosts.self or "local"] = ctx.session_id
    if ctx.client_id then last_on[ctx.client_id] = mem end
    local list = host_sessions(ctx, host)
    local target = list[1]
    for _, s in ipairs(list) do
      if s.session_id == mem[label] then target = s end
    end
    if not target then error("no sessions on " .. label, 0) end
    remember(ctx, target.session_id)
    select_session(target.session_id, host)
  end,
}

-- This machine's sessions go through its own socket while ctx.server points
-- rex.call at another host.
local function set_label(ctx, host, session_id, label)
  local args = { session_id = session_id, label = label }
  if host then return rex.server(host).call("session.set_label", args) end
  if not ctx.server then return rex.call("session.set_label", args) end
  local r, err = rex.exec({ rex_cli, "session", "rename", session_id, label }, { env = env, timeout = 5 })
  if r and r.ok then return true end
  return nil, err or (r.stderr ~= "" and r.stderr) or "rex session rename failed"
end

-- Prefixes each session label with its ctrl+N number on its own host ("3-api"),
-- like Herdr's tab renumbering. A leading "<digits>-" is replaced, so reruns don't stack.
rex.action{
  name = "session_renumber",
  title = "Number Sessions for Ctrl+N",
  category = "Session",
  run = function(ctx)
    local groups = { { sessions = local_sessions(ctx) } }
    for _, host in ipairs(rex.servers()) do
      local r, err = rex.server(host).call("session.list")
      if not r then rex.log("warn", "session_renumber: " .. host .. " skipped: " .. tostring(err)) end
      groups[#groups + 1] = { host = host, sessions = r and r.sessions or {} }
    end
    local failed = {}
    for _, g in ipairs(groups) do
      local n = 0
      if g.host then
        rex.server(g.host).call("session.attach_all", { event_scope = "session" })
      elseif not ctx.server then
        attach_all()
      end
      for _, s in ipairs(g.sessions) do
        n = n + 1
        local label = n .. "-" .. (s.label or ""):gsub("^%d+%-", "")
        if label ~= s.label then
          local ok, err = set_label(ctx, g.host, s.session_id, label)
          if not ok then failed[#failed + 1] = label .. ": " .. tostring(err) end
        end
      end
    end
    if #failed > 0 then error("not renamed: " .. table.concat(failed, "; "), 0) end
  end,
}

-- Prefixes each tab label with its cmd+N number ("2-api") in every session on
-- the Mac being viewed. A tab still on its default "Window 1a2b3c4d" label (or
-- only a number) is named after its focused pane's folder instead.
rex.action{
  name = "tab_renumber",
  title = "Number Tabs for Cmd+N",
  category = "Tab",
  run = function(ctx)
    attach_all()
    local failed = {}
    for _, s in ipairs(sessions()) do
      local v = rex.session.view{ session_id = s.session_id }
      for i, w in ipairs(v and v.windows or {}) do
        local base = (w.label or ""):gsub("^%d+%-", "")
        if base:match("^%d*$") or base:match("^Window %x+$") then
          local ok, dir = pcall(pane_dir, w.focused_block_id, s.session_id)
          if not ok then rex.log("warn", "tab_renumber: tab " .. i .. " has no folder: " .. tostring(dir)) end
          base = not ok and "" or dir == os.getenv("HOME") and "~" or basename(dir)
        end
        local label = base == "" and tostring(i) or i .. "-" .. base
        if label ~= w.label then
          local _, err = rex.call("session.set_window_label", { session_id = s.session_id, window_id = w.window_id, label = label })
          if err then failed[#failed + 1] = label .. ": " .. tostring(err) end
        end
      end
    end
    if #failed > 0 then error("not renamed: " .. table.concat(failed, "; "), 0) end
  end,
}

-- client.tab.goto counts the tabs of every session in the sidebar; this counts
-- only the current session's, like a browser window. 9 is the last tab.
rex.action{
  name = "tab_goto",
  title = "Go to Tab N in This Session",
  category = "Tab",
  args = { index = "integer" },
  run = function(ctx, args)
    local v, err = rex.session.view{ session_id = ctx.session_id }
    if not v then error(err, 0) end
    local tabs = v.windows or {}
    local w = tabs[args.index == 9 and #tabs or args.index]
    if not w then error("no tab " .. args.index, 0) end
    select_session(ctx.session_id, ctx.server, w.window_id)
  end,
}

rex.action{
  name = "home",
  title = "Home: First Session, Tab, and Pane",
  category = "Session",
  run = function(ctx)
    local s = local_sessions(ctx)[1]
    if not s then error("no sessions", 0) end
    remember(ctx, s.session_id)
    -- The tab and pane calls below would go to the other host.
    if ctx.server then return select_session(s.session_id) end
    attach_all()
    local v, err = rex.session.view{ session_id = s.session_id }
    if not v then error(err, 0) end
    local w = (v.windows or {})[1]
    if not w then error("session has no tabs", 0) end
    local blk = ((w.layers or {})[1] or {}).blocks
    if blk and blk[1] then
      rex.session.focus_block{ session_id = s.session_id, block_id = blk[1].block_id }
    end
    rex.client.queue("session.select", { session_id = s.session_id, window_id = w.window_id })
  end,
}

local function urgency(session_id, block_id)
  local st = rex.block.call(term, "program_status", { session_id = session_id, block_id = block_id })
  local rank
  for _, rec in ipairs(st and st.records or {}) do
    local n = attention[rec.state]
    if n and (not rank or n < rank) then rank = n end
  end
  return rank
end

-- Cycles agents that need you, most urgent state first (blocked, error, done, idle).
rex.action{
  name = "agent_attention",
  title = "Next Agent Needing You",
  category = "Session",
  args = { back = "boolean?" },
  run = function(ctx, args)
    attach_all()
    local hits = {}
    for _, s in ipairs(sessions()) do
      local b = rex.session.list_blocks{ session_id = s.session_id }
      for _, blk in ipairs(b and b.blocks or {}) do
        local rank = blk.creator_name == term and blk.placement == "placed" and urgency(s.session_id, blk.block_id)
        if rank then
          hits[#hits + 1] = { rank = rank, order = #hits, session_id = s.session_id, block_id = blk.block_id }
        end
      end
    end
    if #hits == 0 then error("no agent needs you", 0) end
    table.sort(hits, function(a, b)
      if a.rank ~= b.rank then return a.rank < b.rank end
      return a.order < b.order
    end)
    local pick = hits[1]
    for i, h in ipairs(hits) do
      if h.block_id == ctx.block_id then pick = hits[(args.back and i - 2 or i) % #hits + 1] break end
    end
    rex.session.focus_block{ session_id = pick.session_id, block_id = pick.block_id }
    if pick.session_id ~= ctx.session_id then select_session(pick.session_id, ctx.server) end
  end,
}

-- Overlays run on whichever host owns the pane. Rex zooms only the focused
-- block, so a focused popup unzooms the window: over a zoomed pane it fills the
-- window to hide that, and re-zooms the pane on quit.
local overlay_tail = [=[
if [ -n "$2" ]; then "$REX_BIN_DIR/rex" zoom --on "$1"; else "$REX_BIN_DIR/rex" focus "$1"; fi >/dev/null 2>&1]=]

local function pane_rect(node, block_id)
  if not node then return nil end
  if node.block_id == block_id then return node.rect end
  local s = node.split
  return s and (pane_rect(s.before, block_id) or pane_rect(s.after, block_id))
end

-- Script args: $1 the pane, $2 "1" if it was zoomed, $3 a file holding the
-- pane's text ("" when the overlay must capture it), then the caller's.
-- With no bounds the overlay covers the pane it was opened from, or the window.
local function overlay(ctx, bounds, script, file, ...)
  local function fail(msg)
    if file ~= "" then os.remove(file) end
    error(msg, 0)
  end
  local zoomed, rect, win = "", nil, nil
  local v, verr = rex.session.view{ session_id = ctx.session_id }
  if not v then rex.log("warn", "overlay: zoom state unknown: " .. tostring(verr)) end
  for _, w in ipairs(v and v.windows or {}) do
    if w.zoomed_block_id == ctx.block_id then zoomed = "1" end
    for _, l in ipairs(w.layers or {}) do
      if l.kind == "tiled" and not rect then
        rect = pane_rect(l.layout, ctx.block_id)
        if rect then win = w.window_id end
      end
      -- A popup over a popup traps focus: directional keys cannot leave a floating layer.
      for _, b in ipairs(l.kind == "floating" and l.blocks or {}) do
        if b.block_id == ctx.block_id then fail("already in a popup; close it first") end
      end
    end
  end
  local area = zoomed == "1" and { 0, 0, 1, 1 } or bounds or rect or { 0, 0, 1, 1 }
  -- Rex Beta 1408 draws bounds as [left, top, right, bottom]; only a rect at the origin shows right.
  if area[1] > 0 or area[2] > 0 then area = { 0, 0, 1, 1 } end
  -- Without window_id the layer goes to the session's active tab, not always the pane's.
  local _, err = rex.session.new_layer{
    window_id = win,
    bounds = area,
    focus = true,
    layout = rex.layout.block{
      flavor = "com.superlogical.terminal.shell",
      options = { shell = "none", command = { "/bin/sh", "-c", script .. "\n" .. overlay_tail, "sh", ctx.block_id, zoomed, file, ... } },
    },
  }
  if err then fail(err) end
end

-- Reading the pane here saves the overlay a rex CLI launch (~40-90ms). A pane on
-- another host is left to the overlay there, which cannot see a file made here.
local function capture_file(ctx, last_lines)
  if ctx.server then return "" end
  local r = rex.block.call(term, "format", {
    session_id = ctx.session_id, block_id = ctx.block_id, format = "text", trim = true, unwrap = true,
  })
  if not (r and r.content) then return "" end
  -- trim drops blank cells, not spaces a program printed, so strip those too.
  local text = r.content:gsub("[ \t]+\n", "\n"):gsub("[ \t]+$", ""):gsub("\n$", "")
  if last_lines then
    local lines = {}
    for line in (text .. "\n"):gmatch("(.-)\n") do lines[#lines + 1] = line end
    text = table.concat(lines, "\n", math.max(1, #lines - last_lines + 1))
  end
  local path = os.tmpname()
  local f = io.open(path, "w")
  if not f then return "" end
  local ok = f:write(text, "\n")
  f:close()
  if not ok then
    os.remove(path)
    return ""
  end
  return path
end

local copy_script = [=[f=$3; [ -n "$f" ] || f=$(mktemp) || exit
trap 'rm -f "$f"' EXIT HUP INT TERM
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
if [ -z "$3" ]; then
  text=$("$REX_BIN_DIR/rex" capture -b "$1" --unwrap 2>&1) || set -- "$1" "$2" "" " rex capture failed"
  printf '%s\n' "$text" | sed 's/[[:space:]]*$//' >"$f"
fi
init="$HOME/.config/rex/copy-mode.nvim.lua"
if [ -r "$init" ]; then
  REX_COPY_NOTE="$4" nvim -u "$init" -i NONE -n -R + "$f"
else
  nvim -u NONE -i NONE -n -R + -c "set clipboard=unnamedplus" -c "nnoremap q <cmd>qa!<cr>" -c "nnoremap <C-c> <cmd>qa!<cr>" "$f"
fi]=]

rex.action{
  name = "copy_mode",
  title = "Copy Mode",
  description = "Opens the pane's screen and scrollback in Neovim over the pane. y copies, q closes.",
  category = "Pane",
  run = function(ctx)
    -- A full-screen app (Claude Code, nvim, less) draws on the alternate screen,
    -- which has no scrollback, so only what is visible comes back.
    local m = rex.block.call(term, "modes", { block_id = ctx.block_id })
    local note = m and m.screen == "alternate" and " Full-screen app: only the visible screen is here" or ""
    overlay(ctx, nil, copy_script, capture_file(ctx), note)
  end,
}

-- A popup shows the pane below wherever its program paints no background, so
-- fzf paints one (merino-dark's raised surface).
local fingers_script = [=[f=$3; [ -n "$f" ] || f=$(mktemp) || exit
trap 'rm -f "$f"' EXIT HUP INT TERM
PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --color=bg:#1e2023,bg+:#2b2f34"
if [ -n "$3" ] || text=$("$REX_BIN_DIR/rex" capture -b "$1" --unwrap 2>&1); then
  [ -n "$3" ] || printf '%s\n' "$text" | tail -n 500 >"$f"
  HERDR_FINGERS_TEXT_FILE="$f" HERDR_ACTIVE_PANE_CWD="$4" herdr-fingers || { printf '\nPress Enter to close.'; read -r _; }
else
  printf '%s\n\nPress Enter to close.' "$text"; read -r _
fi]=]

-- Herdr's prefix+space picker on the pane's latest 500 lines, newest first:
-- Enter opens, Ctrl-Y copies, Ctrl-E edits.
rex.action{
  name = "fingers",
  title = "Pick a URL or Path",
  category = "Pane",
  run = function(ctx)
    local ok, dir = pcall(pane_dir, ctx.block_id)
    overlay(ctx, { 0.1, 0.1, 0.8, 0.8 }, fingers_script, capture_file(ctx, 500), ok and dir or "")
  end,
}

-- ponytail: repo:branch label only; herdr-pane-rename's LLM naming not ported.
rex.action{
  name = "pane_label",
  title = "Label Pane from Repo and Branch",
  category = "Pane",
  run = function(ctx)
    local dir = pane_dir(ctx.block_id)
    local root = git(dir, "rev-parse", "--show-toplevel")
    local label = basename(dir)
    if root then
      local branch = git(dir, "symbolic-ref", "--quiet", "--short", "HEAD") or git(dir, "rev-parse", "--short", "HEAD")
      label = basename(root) .. (branch and (":" .. branch) or "")
    end
    local _, err = rex.session.set_block_label{ block_id = ctx.block_id, label = label }
    if err then error(err, 0) end
  end,
}

rex.action{
  name = "open_pr",
  title = "Open Pull Requests",
  description = "Opens the repo's pull request list on GitHub.",
  category = "Pane",
  run = function(ctx)
    local root = git(pane_dir(ctx.block_id), "rev-parse", "--show-toplevel")
    if not root then error("no git project in this pane", 0) end
    local r, err = rex.exec({ "gh", "pr", "list", "--web" }, { cwd = root, env = env, timeout = 10 })
    if not r then error(err, 0) end
    if not r.ok then error(r.stderr, 0) end
  end,
}
