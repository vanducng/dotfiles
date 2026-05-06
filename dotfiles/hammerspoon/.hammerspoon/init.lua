-- Refer: https://github.com/zzamboni/dot-hammerspoon/blob/master/init.lua
hs.logger.defaultLogLevel = "info"
hyper = { "cmd", "alt", "ctrl" }
shift_hyper = { "cmd", "alt", "ctrl", "shift" }
ctrl_cmd = { "cmd", "ctrl" }

function reloadConfig(files)
	doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end

function appID(app)
	if hs.application.infoForBundlePath(app) then
		return hs.application.infoForBundlePath(app)["CFBundleIdentifier"]
	end
end

-- Define the IDs of the various applications used to open URLs
chromeBrowser = appID("/Applications/Google Chrome.app")
braveBrowser = appID("/Applications/Brave Browser.app")
safariBrowser = appID("/Applications/Safari.app")
firefoxBrowser = appID("/Applications/Firefox.app")
arcBrowser = appID("/Applications/Arc.app")
teamsApp = appID("/Applications/Microsoft Teams.app")

hs.hotkey.bind(hyper, "W", function()
	hs.alert.show("Hello World!")
end)

--------------------------------------------
-- Floating clock with date (Hyper+C)
--
-- Replaces the AClock spoon: large HH:MM with a smaller date line below.
-- Auto-hides after a few seconds; press Esc or Hyper+C again to dismiss early.
--------------------------------------------
local clockState = {
	canvas = nil,
	tickTimer = nil,
	hideTimer = nil,
	cancelHotkey = nil,
	width = 360,
	height = 260,
	timeFont = "Impact",
	timeSize = 135,
	dateFont = "Helvetica Neue",
	dateSize = 26,
	color = { hex = "#1891C3" },
	showDuration = 4,
}

local function clockFrame()
	local res = hs.screen.primaryScreen():fullFrame()
	return {
		x = (res.w - clockState.width) / 2,
		y = (res.h - clockState.height) / 2,
		w = clockState.width,
		h = clockState.height,
	}
end

local function updateClockText()
	if not clockState.canvas then return end
	clockState.canvas[1].text = os.date("%H:%M")
	clockState.canvas[2].text = os.date("%a, %b %d %Y")
end

local function hideClock()
	if clockState.cancelHotkey then clockState.cancelHotkey:delete(); clockState.cancelHotkey = nil end
	if clockState.tickTimer then clockState.tickTimer:stop(); clockState.tickTimer = nil end
	if clockState.hideTimer then clockState.hideTimer:stop(); clockState.hideTimer = nil end
	if clockState.canvas then clockState.canvas:hide() end
end

local function showClock()
	if not clockState.canvas then
		clockState.canvas = hs.canvas.new(clockFrame())
		clockState.canvas[1] = {
			type = "text",
			text = "",
			textFont = clockState.timeFont,
			textSize = clockState.timeSize,
			textColor = clockState.color,
			textAlignment = "center",
			frame = { x = 0, y = "0.05", w = "1.0", h = "0.75" },
		}
		clockState.canvas[2] = {
			type = "text",
			text = "",
			textFont = clockState.dateFont,
			textSize = clockState.dateSize,
			textColor = clockState.color,
			textAlignment = "center",
			frame = { x = 0, y = "0.78", w = "1.0", h = "0.2" },
		}
	else
		clockState.canvas:frame(clockFrame())
	end
	updateClockText()
	clockState.canvas:show()
	clockState.tickTimer = hs.timer.doEvery(1, updateClockText)
	clockState.cancelHotkey = hs.hotkey.bind({}, "escape", hideClock)
	clockState.hideTimer = hs.timer.doAfter(clockState.showDuration, hideClock)
end

hs.hotkey.bind(hyper, "C", function()
	if clockState.canvas and clockState.canvas:isShowing() then
		hideClock()
	else
		showClock()
	end
end)

--------------------------------------------
-- URL Opening Configuration
--------------------------------------------
local urls = {
	-- Personal (Space 2)
	personal = {
		space = 2,
		shortcuts = {
			R = "https://chatgpt.com/",
		},
	},
	-- CNB (Space 1)
	cnb = {
		space = 1,
		shortcuts = {
			A = "https://github.com/careernowbrands/cnb-ds-dbt-order-form/pulls",
			S = "https://github.com/careernowbrands/cnb-ds-astro/pulls",
			D = "https://github.com/careernowbrands/cnb-ds-infra/pulls",
		},
	},
	-- Jade (Space 3)
	jade = {
		space = 3,
		shortcuts = {
			Z = "https://github.com/BHCOE/harmony/pulls",
			X = "https://github.com/BHCOE/jade-infra/pulls",
		},
	},

	-- Nora (Space 6)
	nora = {
		space = 6,
		shortcuts = {
			Q = "https://github.com/nora-health/nora-data-science/pulls",
		},
	},
}

-- Helper function to open URL in Arc browser
local function openInArc(space, url)
	os.execute(string.format("/usr/local/bin/arc space focus %d && /usr/local/bin/arc tab open %s", space, url))
end

-- Register hotkeys for all configured URLs
for _, config in pairs(urls) do
	for key, url in pairs(config.shortcuts) do
		hs.hotkey.bind(hyper, key, function()
			openInArc(config.space, url)
		end)
	end
end

--------------------------------------------
-- Dynamic Folder Opening Modal
--------------------------------------------
hs.hotkey.bind({ "cmd", "alt" }, "o", function()
	local button, result = hs.dialog.textPrompt("Open Folder", "Enter folder path:", "", "Open", "Cancel")

	if button == "Open" and result and result ~= "" then
		-- Expand ~ to home directory
		local path = result:gsub("^~", os.getenv("HOME"))

		-- Check if folder exists
		local attr = hs.fs.attributes(path)
		if attr and attr.mode == "directory" then
			os.execute("open '" .. path .. "'")
			hs.notify.new({ title = "Hammerspoon", informativeText = "Opening: " .. path }):send()
		else
			hs.notify.new({ title = "Hammerspoon", informativeText = "Folder not found: " .. path }):send()
		end
	end
end)

--------------------------------------------
-- Open clipboard content (URL or file path)
--
-- Reads the clipboard, trims whitespace, and opens the content using
-- macOS `open`, which routes URLs to the default browser and files to
-- the default app for their extension.
--------------------------------------------
local function shellEscape(s)
	return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- Extensions handled by the file-browser skill (one HTTP server, dispatches by
-- extension): markdown → novel-theme reader; image/video/audio → media viewer.
local fileBrowserExts = {
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

-- Extensions that should open in nvim (inside Ghostty) instead of LaunchServices default
local nvimExts = {
	-- docs / plain text (md/markdown/mdx handled by fileBrowserExts above)
	rst = true, adoc = true, asciidoc = true,
	txt = true, log = true, csv = true, tsv = true, tex = true,
	-- shell / scripting
	sh = true, bash = true, zsh = true, fish = true, ksh = true, ps1 = true,
	-- lua / vim
	lua = true, vim = true, vimrc = true,
	-- python / ruby / perl
	py = true, pyi = true, ipynb = true, rb = true, erb = true, pl = true, pm = true,
	-- javascript / typescript / web
	js = true, mjs = true, cjs = true, ts = true, tsx = true, jsx = true,
	html = true, htm = true, css = true, scss = true, sass = true, less = true,
	vue = true, svelte = true, astro = true,
	-- systems
	go = true, rs = true, c = true, h = true, cpp = true, hpp = true, cc = true, hh = true,
	cs = true, java = true, kt = true, kts = true, swift = true, m = true, mm = true,
	zig = true, nim = true, dart = true, scala = true, clj = true, ex = true, exs = true,
	erl = true, hs = true, ml = true, fs = true, fsx = true, jl = true, r = true,
	-- config / data
	json = true, jsonc = true, json5 = true, yaml = true, yml = true,
	toml = true, ini = true, cfg = true, conf = true, properties = true,
	xml = true, plist = true, env = true, editorconfig = true,
	gitignore = true, gitattributes = true, gitconfig = true, gitmodules = true,
	dockerfile = true, dockerignore = true, containerfile = true,
	makefile = true, mk = true, cmake = true, ninja = true, bazel = true,
	tf = true, tfvars = true, hcl = true, nomad = true,
	-- db / query
	sql = true, psql = true, prisma = true, graphql = true, gql = true,
	-- diff / patch / misc dev
	diff = true, patch = true, lock = true,
}

-- Resolve nvim once at load (Ghostty --command runs with --noprofile --norc, no PATH)
local nvimBin = (function()
	for _, p in ipairs({ "/opt/homebrew/bin/nvim", "/usr/local/bin/nvim", "/usr/bin/nvim" }) do
		if hs.fs.attributes(p) then return p end
	end
	return "nvim"
end)()

local function openInNvim(path)
	-- Wrap in `zsh -lc` so .zprofile/.zshrc populate PATH (mise, brew, etc.).
	-- Without this, nvim plugins like yazi.nvim can't find their CLI deps.
	local inner = string.format("exec %s %s", nvimBin, shellEscape(path))
	local cmd = string.format(
		"/usr/bin/open -na Ghostty --args --command=%s",
		shellEscape("/bin/zsh -lc " .. shellEscape(inner))
	)
	os.execute(cmd)
end

-- Render markdown / images / video / audio via the file-browser skill (HTTP
-- server) and open in Dia. The server dispatches by file extension:
-- .md/.markdown/.mdx → novel-theme reader; image/video/audio → media viewer.
-- Reuse server on port 3556 if running; otherwise spawn detached.
-- zsh -lc to populate PATH so node (nvm/mise) is found.
local fileBrowserScript = os.getenv("HOME") .. "/skills/skills/file-browser/scripts/server.cjs"
local fileBrowserPort = 3556
local function fileBrowserParentDir(p)
	-- Strip trailing slashes, then drop the final segment.
	-- Returns "/" for root-level files (e.g. /foo) so the URL is always well-formed.
	local trimmed = (p or ""):gsub("/+$", "")
	if trimmed == "" then return "/" end
	local parent = trimmed:match("^(.*)/[^/]+$")
	if not parent or parent == "" then return "/" end
	return parent
end
-- Walk up from `start` looking for a `.git` entry (dir for normal repos, file
-- for worktrees/submodules). Returns the project root or nil if outside any repo.
local function findGitRoot(start)
	local dir = start
	while dir and dir ~= "/" and dir ~= "" do
		local marker = hs.fs.attributes(dir .. "/.git")
		if marker then return dir end
		local parent = fileBrowserParentDir(dir)
		if parent == dir then break end
		dir = parent
	end
	return nil
end
local function openInFileBrowser(path)
	local attr = hs.fs.attributes(path)
	local isDir = attr and attr.mode == "directory"
	local route = isDir and "browse?dir" or "view?file"
	local flag = isDir and "--dir" or "--file"
	-- Tree root: prefer the .git project root so the sidebar shows the whole
	-- project; fall back to the directory itself / file's parent when not in a
	-- repo. Sent as ?root= so each Hyper+V rebases the tree, overriding any
	-- localStorage value from a prior session.
	local fallbackRoot = isDir and path or fileBrowserParentDir(path)
	local rootDir = findGitRoot(fallbackRoot) or fallbackRoot
	local rootSuffix = (rootDir and rootDir ~= "")
		and ("&root=" .. hs.http.encodeForQuery(rootDir))
		or ""
	local url = string.format(
		"http://localhost:%d/%s=%s%s",
		fileBrowserPort, route, hs.http.encodeForQuery(path), rootSuffix
	)
	-- Start server with cwd=$HOME so its allowlist (startsWith $HOME) covers
	-- any path under home. First invocation seeds whichever path was passed;
	-- subsequent calls just hit the existing server.
	local script = string.format(
		[[if ! /usr/bin/nc -z localhost %d 2>/dev/null; then
			cd "$HOME" && nohup node %s %s %s --no-open --port %d >/dev/null 2>&1 &
			for i in {1..50}; do /usr/bin/nc -z localhost %d 2>/dev/null && break; sleep 0.1; done
		fi
		/usr/bin/open -a Dia %s]],
		fileBrowserPort,
		shellEscape(fileBrowserScript), flag, shellEscape(path), fileBrowserPort,
		fileBrowserPort,
		shellEscape(url)
	)
	os.execute(string.format("nohup /bin/zsh -lc %s >/dev/null 2>&1 &", shellEscape(script)))
end

hs.hotkey.bind(hyper, "v", function()
	local raw = hs.pasteboard.getContents()
	if not raw or raw == "" then
		hs.notify.new({ title = "Open Clipboard", informativeText = "Clipboard is empty" }):send()
		return
	end

	local target = raw:match("^%s*(.-)%s*$")
	if target == "" then
		hs.notify.new({ title = "Open Clipboard", informativeText = "Clipboard is empty" }):send()
		return
	end

	-- URL: http(s), ftp, file, mailto, or bare domain like github.com/...
	local isUrl = target:match("^%a[%w+.-]*://") or target:match("^mailto:")
		or target:match("^[%w%-]+%.[%w%-%.]+/") or target:match("^[%w%-]+%.[%w%-]+$")

	if isUrl then
		os.execute("open " .. shellEscape(target))
		hs.notify.new({ title = "Open Clipboard", informativeText = "URL: " .. target }):send()
		return
	end

	-- File path: expand ~, then check existence
	local path = target:gsub("^~", os.getenv("HOME"))
	if path:sub(1, 7) == "file://" then
		path = path:sub(8)
	end

	local attr = hs.fs.attributes(path)
	if attr then
		local ext = path:match("%.([^%.%/]+)$")
		local extLower = ext and ext:lower() or nil
		if attr.mode == "file" and extLower and fileBrowserExts[extLower] then
			openInFileBrowser(path)
			hs.notify.new({ title = "Open Clipboard", informativeText = "file-browser: " .. path }):send()
		elseif attr.mode == "file" and extLower and nvimExts[extLower] then
			openInNvim(path)
			hs.notify.new({ title = "Open Clipboard", informativeText = "nvim: " .. path }):send()
		else
			os.execute("open " .. shellEscape(path))
			hs.notify.new({ title = "Open Clipboard", informativeText = "Path: " .. path }):send()
		end
	else
		hs.notify.new({ title = "Open Clipboard", informativeText = "Not a URL or existing path:\n" .. target }):send()
	end
end)

--------------------------------------------
-- Run clipboard as bash command in Ghostty (Hyper+B)
--
-- Spawns Ghostty, runs the clipboard command via login zsh (so PATH is
-- populated), then drops into an interactive shell so output stays visible.
-- WARNING: executes whatever is on the clipboard — only use when you trust it.
--------------------------------------------
hs.hotkey.bind(hyper, "b", function()
	local raw = hs.pasteboard.getContents()
	if not raw or raw:match("^%s*$") then
		hs.notify.new({ title = "Run Clipboard", informativeText = "Clipboard is empty" }):send()
		return
	end

	local cmdText = raw:match("^%s*(.-)%s*$")

	-- Run command, then keep shell open. `; exec zsh -l` replaces the wrapper
	-- so Ctrl-D / `exit` cleanly closes the window.
	local inner = cmdText .. "; exec zsh -l"
	local launch = string.format(
		"/usr/bin/open -na Ghostty --args --command=%s",
		shellEscape("/bin/zsh -lc " .. shellEscape(inner))
	)
	os.execute(launch)

	-- Follow the spawned terminal: activate Ghostty (jumps to its pinned space
	-- per yabai rule) and focus its newest window once it materializes.
	hs.timer.doAfter(0.4, function()
		local app = hs.application.find("Ghostty")
		if not app then return end
		app:activate(true)
		local wins = app:allWindows()
		table.sort(wins, function(a, b) return a:id() > b:id() end)
		if wins[1] then wins[1]:focus() end
	end)

	local preview = #cmdText > 80 and (cmdText:sub(1, 77) .. "...") or cmdText
	hs.notify.new({ title = "Run Clipboard", informativeText = preview }):send()
end)

--------------------------------------------
-- Flash a highlight border around a window
--
-- Used by the cycle helpers so you can see which window just got focus.
-- Keeps only ONE active flash at a time: rapid presses cancel the previous
-- canvas/timer so old borders never linger on stale windows.
--------------------------------------------
local activeFlashCanvas = nil
local activeFlashTimer = nil

local function flashFocus(win)
	if not win then return end
	if activeFlashTimer then activeFlashTimer:stop() end
	if activeFlashCanvas then activeFlashCanvas:delete() end

	local frame = win:frame()
	local pad = 4
	local canvas = hs.canvas.new({
		x = frame.x - pad, y = frame.y - pad,
		w = frame.w + pad * 2, h = frame.h + pad * 2,
	})
	canvas:level(hs.canvas.windowLevels.overlay)
	canvas:behavior({ "canJoinAllSpaces", "transient" })
	canvas[1] = {
		type = "rectangle",
		action = "stroke",
		strokeColor = { red = 0.2, green = 0.9, blue = 0.4, alpha = 1.0 },
		strokeWidth = 4,
		roundedRectRadii = { xRadius = 8, yRadius = 8 },
	}
	canvas:show()
	activeFlashCanvas = canvas
	activeFlashTimer = hs.timer.doAfter(0.5, function()
		if activeFlashCanvas == canvas then
			canvas:delete()
			activeFlashCanvas = nil
			activeFlashTimer = nil
		end
	end)
end

--------------------------------------------
-- Cycle windows in current Space
--
-- Gotchas:
--   * hs.window.orderedWindows() returns windows across ALL spaces, so it
--     cycles into other desktops even when they are not visible.
--   * hs.window.filter:setCurrentSpace(true) is unreliable on recent macOS
--     (stale/missing windows after space switches).
--   * hs.spaces.windowsForSpace() queries the WindowServer directly and is
--     the authoritative source for "what is on this space right now".
--------------------------------------------
local function cycleWindows(direction)
	local spaceId = hs.spaces.focusedSpace()
	local idsOnSpace = hs.spaces.windowsForSpace(spaceId) or {}
	local idSet = {}
	for _, id in ipairs(idsOnSpace) do idSet[id] = true end

	local wins = {}
	for _, w in ipairs(hs.window.orderedWindows()) do
		if idSet[w:id()] and w:isStandard() and not w:isMinimized() then
			wins[#wins + 1] = w
		end
	end
	if #wins < 2 then return end

	table.sort(wins, function(a, b) return a:id() < b:id() end)
	local focused = hs.window.focusedWindow()
	if not focused then wins[1]:focus() return end
	local currentIdx = 1
	for i, w in ipairs(wins) do
		if w:id() == focused:id() then
			currentIdx = i
			break
		end
	end
	local nextIdx = ((currentIdx - 1 + direction) % #wins) + 1
	wins[nextIdx]:focus()
	flashFocus(wins[nextIdx])
end

hs.hotkey.bind(hyper, "j", function() cycleWindows(1) end)
hs.hotkey.bind(hyper, "k", function() cycleWindows(-1) end)

--------------------------------------------
-- Cycle windows within the focused App (current Space only)
--
-- Like macOS `cmd+backtick` but space-scoped: skips windows of the same app
-- that live on other desktops.
--------------------------------------------
local function cycleAppWindows(direction)
	local focused = hs.window.focusedWindow()
	if not focused then return end
	local app = focused:application()
	if not app then return end

	local spaceId = hs.spaces.focusedSpace()
	local idsOnSpace = hs.spaces.windowsForSpace(spaceId) or {}
	local idSet = {}
	for _, id in ipairs(idsOnSpace) do idSet[id] = true end

	local wins = {}
	for _, w in ipairs(app:allWindows()) do
		if idSet[w:id()] and w:isStandard() and not w:isMinimized() then
			wins[#wins + 1] = w
		end
	end
	if #wins < 2 then return end

	table.sort(wins, function(a, b) return a:id() < b:id() end)
	local currentIdx = 1
	for i, w in ipairs(wins) do
		if w:id() == focused:id() then
			currentIdx = i
			break
		end
	end
	local nextIdx = ((currentIdx - 1 + direction) % #wins) + 1
	wins[nextIdx]:focus()
	flashFocus(wins[nextIdx])
end

hs.hotkey.bind(hyper, "q", function() cycleAppWindows(1) end)

--------------------------------------------
-- Reload config
--------------------------------------------
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
