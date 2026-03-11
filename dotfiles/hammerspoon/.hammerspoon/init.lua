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
-- Cycle windows in current Space
--------------------------------------------
local function cycleWindows(direction)
	local wins = hs.window.orderedWindows()
	if #wins < 2 then return end
	-- Sort by window ID for stable ordering across invocations
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
end

hs.hotkey.bind(hyper, "tab", function() cycleWindows(1) end)
hs.hotkey.bind(shift_hyper, "tab", function() cycleWindows(-1) end)

--------------------------------------------
-- Reload config
--------------------------------------------
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
