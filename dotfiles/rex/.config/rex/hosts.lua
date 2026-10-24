-- Labels match the ssh aliases; scripts/rex-setup.sh names each Mac's Tailscale node rex-<label>.
local labels = { "mini-01", "macpro" }

local function run(argv, env)
  local r = rex.exec(argv, { timeout = 5, env = env })
  if r and r.ok then return (r.stdout:gsub("%s+$", "")) end
end

-- The tailnet domain is read at load so it stays out of the repo. Without
-- TAILSCALE_BE_CLI the Mac app binary tries to open its GUI from the Rex server.
local status = run({ "/Applications/Tailscale.app/Contents/MacOS/Tailscale", "status", "--json" }, { TAILSCALE_BE_CLI = "1" })
  or run({ "tailscale", "status", "--json" })
local ok, decoded = pcall(rex.json.decode, status or "")
local suffix = ok and decoded and decoded.MagicDNSSuffix
-- MagicDNSSuffix is empty until Tailscale connects.
if not suffix or suffix == "" then
  rex.log("warn", "hosts.lua: no tailnet found, skipping remote hosts")
  return
end

local self = run({ "defaults", "read", "com.superlogical.rex", "rex.server.tailnet-hostname" })
for _, label in ipairs(labels) do
  local node = "rex-" .. label
  if node ~= self then
    rex.host{ label = label, endpoint = "https://" .. node .. "." .. suffix }
  end
end
