-- Machines that run Rex come from hosts.json, which scripts/rex-setup.sh reads too. Each entry:
--   label     <kind>-<nn> (mbp, mini, linux), the same as its ssh alias. Its Rex server joins
--             Tailscale as rex-<label>, and its place in the list is its ctrl+alt+N.
--   hostname  macOS LocalHostName (scutil --get LocalHostName); tells each Mac which entry it is.
--   device, icon  what it is, and the SF Symbol the Rex app shows for it.
local function run(argv, env)
  local r = rex.exec(argv, { timeout = 5, env = env })
  if r and r.ok then return (r.stdout:gsub("%s+$", "")) end
end

local dir = (os.getenv("REX_CONFIG") or ((os.getenv("HOME") or "") .. "/.config/rex/init.lua")):match("^(.*)/")
local file = io.open(dir .. "/hosts.json")
local entries = {}
if file then
  local ok, decoded = pcall(rex.json.decode, file:read("*a"))
  file:close()
  if ok and type(decoded) == "table" then entries = decoded end
end
if #entries == 0 then rex.log("warn", "hosts.lua: no hosts in " .. dir .. "/hosts.json") end

local function exists(path)
  local f = io.open(path)
  if f then f:close() end
  return f ~= nil
end

local hosts = { order = {} }
-- macOS has scutil; on Linux fall back to the short hostname (hosts.json carries it there).
local me = (exists("/usr/sbin/scutil") and run({ "scutil", "--get", "LocalHostName" })) or run({ "hostname", "-s" })
for i, h in ipairs(entries) do
  hosts.order[i] = h.label
  if h.hostname == me then hosts.self = h.label end
end

-- The tailnet domain is read at load so it stays out of the repo. Without
-- TAILSCALE_BE_CLI the Mac app binary tries to open its GUI from the Rex server.
local ts_app = "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
local status = (exists(ts_app) and run({ ts_app, "status", "--json" }, { TAILSCALE_BE_CLI = "1" }))
  or run({ "tailscale", "status", "--json" })
local ok, decoded = pcall(rex.json.decode, status or "")
local suffix = ok and decoded and decoded.MagicDNSSuffix
-- MagicDNSSuffix is empty until Tailscale connects.
if not suffix or suffix == "" then
  rex.log("warn", "hosts.lua: no tailnet found, skipping remote hosts")
  return hosts
end

for _, label in ipairs(hosts.order) do
  if label ~= hosts.self then
    rex.host{ label = label, endpoint = "https://rex-" .. label .. "." .. suffix }
  end
end
return hosts
