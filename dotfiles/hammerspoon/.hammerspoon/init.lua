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

hs.loadSpoon("AClock")
hs.hotkey.bind(hyper, "C", function()
	spoon.AClock:toggleShow()
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
