vim.keymap.set("n", "<leader>yp", function()
  local relative_filepath = vim.fn.expand "%:."
  vim.fn.setreg("+", relative_filepath)
end, { noremap = true, silent = true, desc = "Copy relative file path to clipboard" })
vim.keymap.set("n", "<leader>yP", function()
  local absolute_filepath = vim.fn.expand "%:p"
  vim.fn.setreg("+", absolute_filepath)
end, { noremap = true, silent = true, desc = "Copy absolute file path to clipboard" })

-- <leader>mv — open current buffer in the file-browser skill (Dia).
-- Server's /view route dispatches by content: markdown → novel reader;
-- image/video/audio → media viewer; everything else → text/code view.
-- Directory buffers (netrw/oil) → folder gallery.
vim.keymap.set("n", "<leader>mv", function()
  local path = vim.fn.expand "%:p"
  if path == "" then
    vim.notify("No file in buffer", vim.log.levels.WARN)
    return
  end
  local isDir = vim.fn.isdirectory(path) == 1
  local target = path
  local flag = isDir and "--dir" or "--file"
  local route = isDir and "browse?dir" or "view?file"

  local server = vim.fn.expand "$HOME/skills/skills/file-browser/scripts/server.cjs"
  local port = 3556
  -- Sidebar tree root: walk up to find .git (project root); fall back to dir
  -- itself / file's parent. Sent as ?root= so each launch overrides any
  -- localStorage root from a prior session. .git can be a dir (normal repo)
  -- or a file (worktree / submodule), so check both.
  local function findGitRoot(start)
    local dir = start
    while dir and dir ~= "/" and dir ~= "" do
      local marker = dir .. "/.git"
      if vim.fn.isdirectory(marker) == 1 or vim.fn.filereadable(marker) == 1 then
        return dir
      end
      local parent = vim.fn.fnamemodify(dir, ":h")
      if parent == dir then break end
      dir = parent
    end
    return nil
  end
  local fallbackRoot = isDir and path or vim.fn.fnamemodify(path, ":h")
  local rootDir = findGitRoot(fallbackRoot) or fallbackRoot
  local function urlEncode(s)
    return vim.fn.substitute(s, [[\([^A-Za-z0-9._~/-]\)]], [[\=printf("%%%02X", char2nr(submatch(1)))]], "g")
  end
  local encoded = urlEncode(target)
  local encodedRoot = urlEncode(rootDir)
  local url = string.format("http://localhost:%d/%s=%s&root=%s", port, route, encoded, encodedRoot)
  local script = string.format(
    [[
    if ! /usr/bin/nc -z localhost %d 2>/dev/null; then
      cd "$HOME" && nohup node %q %s %q --no-open --port %d >/dev/null 2>&1 &
      for i in $(seq 1 50); do /usr/bin/nc -z localhost %d 2>/dev/null && break; sleep 0.1; done
    fi
    /usr/bin/open -a Dia %q
  ]],
    port, server, flag, target, port, port, url
  )
  vim.fn.jobstart({ "/bin/zsh", "-lc", script }, { detach = true })
  vim.notify("file-browser: " .. vim.fn.fnamemodify(target, ":t"))
end, { noremap = true, silent = true, desc = "Open in file-browser (Dia)" })
