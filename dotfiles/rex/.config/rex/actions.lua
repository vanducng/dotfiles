local term = "com.superlogical.terminal"
local env = { PATH = "/opt/homebrew/bin:/usr/local/bin:" .. (os.getenv("PATH") or "/usr/bin:/bin") }
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

local function pane_dir(block_id)
  local r, err = rex.block.call(term, "pwd", { block_id = block_id })
  if not (r and r.pwd) then error(err or "pane has no working directory", 0) end
  return (r.pwd:gsub("^file://[^/]*", ""):gsub("%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end))
end

local function git(dir, ...)
  local r, err = rex.exec({ "git", "-C", dir, ... }, { env = env, timeout = 5 })
  if not r then rex.log("warn", "git did not run: " .. tostring(err)) end
  if r and r.ok then return (r.stdout:gsub("%s+$", "")) end
end

local function basename(path)
  return path:match("([^/]+)/*$") or path
end

-- Same numbering as the session picker: this Mac first, then each remote host.
-- Remote hosts are asked only when the index runs past the local sessions.
-- Returns the session and, for a remote one, its host label.
local function session_at(index)
  local list = sessions()
  if list[index] then return list[index] end
  for _, label in ipairs(rex.servers()) do
    local r, err = rex.server(label).call("session.list")
    if not r then rex.log("warn", "session_goto: " .. label .. " skipped: " .. tostring(err)) end
    for _, s in ipairs(r and r.sessions or {}) do
      list[#list + 1] = s
      if list[index] then return s, label end
    end
  end
end

-- session.select only finds sessions on the server that queued it, so a remote
-- session is selected by asking the caller's app, through that host, to do it.
-- Each server gives the app its own client ID, so it is matched by label.
local function select_remote(host, session_id, client_id)
  local me = client_id and rex.call("client.inspect", { client_id = client_id })
  local name = me and me.client.info and me.client.info.label
  if not name then error("no Rex app to switch", 0) end
  local srv = rex.server(host)
  local r, err = srv.call("client.list")
  if not r then error(err, 0) end
  for _, c in ipairs(r.clients or {}) do
    if c.info and c.info.kind == "app" and c.info.label == name then
      local _, perr = srv.call("client.perform", {
        client_id = c.client_id, action = "session.select", args = { session_id = session_id }, origin = "key",
      })
      if perr then error(perr, 0) end
      return
    end
  end
  error(name .. " is not connected to " .. host, 0)
end

rex.action{
  name = "session_goto",
  title = "Go to Session N",
  category = "Session",
  args = { index = "integer" },
  run = function(ctx, args)
    local s, label = session_at(args.index)
    if not s then error("no session " .. args.index, 0) end
    if label then return select_remote(label, s.session_id, ctx.client_id) end
    rex.client.queue("session.select", { session_id = s.session_id })
  end,
}

rex.action{
  name = "home",
  title = "Home: First Session, Tab, and Pane",
  category = "Session",
  run = function(ctx)
    local s = sessions()[1]
    if not s then error("no sessions", 0) end
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
    if pick.session_id ~= ctx.session_id then
      rex.client.queue("session.select", { session_id = pick.session_id })
    end
  end,
}

-- ponytail: whole scrollback in one read; page with max_bytes + blob_read if it ever fails with too_large.
rex.action{
  name = "copy_mode",
  title = "Copy Mode",
  description = "Opens the pane's screen and scrollback in Neovim over the pane. y copies, q closes.",
  category = "Pane",
  run = function(ctx)
    local r, err = rex.block.call(term, "format", { block_id = ctx.block_id, format = "text", trim = true })
    if not r then error(err, 0) end
    local path = os.tmpname()
    local f = assert(io.open(path, "w"))
    f:write(r.content or "")
    f:close()
    local script = 'trap \'rm -f "$1"\' EXIT HUP INT TERM; PATH="' .. env.PATH .. '"; nvim -n -R + -c "set clipboard=unnamedplus" -c "nnoremap <buffer> q <cmd>qa!<cr>" "$1"'
    local _, lerr = rex.session.new_layer{
      bounds = { 0, 0, 1, 1 },
      focus = true,
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        options = { shell = "none", command = { "/bin/sh", "-c", script, "sh", path } },
      },
    }
    if lerr then
      os.remove(path)
      error(lerr, 0)
    end
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
  title = "Open Pull Request",
  description = "Opens the current branch's pull request, or the repo's pull request list.",
  category = "Pane",
  run = function(ctx)
    local root = git(pane_dir(ctx.block_id), "rev-parse", "--show-toplevel")
    if not root then error("no git project in this pane", 0) end
    local opts = { cwd = root, env = env, timeout = 10 }
    local view = rex.exec({ "gh", "pr", "view", "--web" }, opts)
    if view and view.ok then return end
    local list, err = rex.exec({ "gh", "pr", "list", "--web" }, opts)
    if not list then error(err, 0) end
    if not list.ok then error(list.stderr, 0) end
  end,
}
