vim.keymap.set("n", "<leader>yp", function()
  local relative_filepath = vim.fn.expand "%:."
  vim.fn.setreg("+", relative_filepath)
end, { noremap = true, silent = true, desc = "Copy relative file path to clipboard" })
vim.keymap.set("n", "<leader>yP", function()
  local absolute_filepath = vim.fn.expand "%:p"
  vim.fn.setreg("+", absolute_filepath)
end, { noremap = true, silent = true, desc = "Copy absolute file path to clipboard" })

-- <leader>mv — open current buffer in the file-browser skill (Dia).
-- Server dispatches by extension: .md → novel-theme reader; image/video/audio
-- → media viewer; anything else → folder gallery of the parent directory.
local renderable_exts = {
  -- markdown
  md = true, markdown = true, mdx = true,
  -- images
  png = true, jpg = true, jpeg = true, gif = true, webp = true, avif = true,
  svg = true, bmp = true, ico = true, heic = true, heif = true, jxl = true, apng = true,
  -- video
  mp4 = true, m4v = true, webm = true, mov = true, mkv = true, ogv = true,
  -- audio
  mp3 = true, m4a = true, aac = true, ogg = true, opus = true, wav = true, flac = true,
}
vim.keymap.set("n", "<leader>mv", function()
  local path = vim.fn.expand "%:p"
  if path == "" then
    vim.notify("No file in buffer", vim.log.levels.WARN)
    return
  end
  -- If current file is renderable → single view; otherwise → parent folder gallery.
  local ext = (path:match "%.([^%.%/]+)$" or ""):lower()
  local renderable = renderable_exts[ext] == true
  local target = renderable and path or vim.fn.fnamemodify(path, ":h")
  local flag = renderable and "--file" or "--dir"
  local route = renderable and "view?file" or "browse?dir"

  local server = vim.fn.expand "$HOME/skills/skills/file-browser/scripts/server.cjs"
  local port = 3556
  local encoded =
    vim.fn.substitute(target, [[\([^A-Za-z0-9._~/-]\)]], [[\=printf("%%%02X", char2nr(submatch(1)))]], "g")
  local url = string.format("http://localhost:%d/%s=%s", port, route, encoded)
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
