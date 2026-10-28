-- Dev only (Phase 9 console-mode probes): calls the two static methods dev/modio/wrap-probe patches,
-- at the main menu and then every 5 s, and writes each new result to probe-check.txt (boot-check
-- copies it to the log folder). Vanilla: status=1 authorize=9. Patch loaded: status=7777.
-- Own-name call in the wrapper runs the original: authorize=1009.
-- Doesn't work while a c77 script mod is loaded: CET's game types and ObserveAfter are nil then (2026-10-28).
-- Run with: pwsh tools/console-boot.ps1 -Mod dev/modio/wrap-probe -Run dev/cet/modio-probe-check.lua -HoldSec 90
local function write(text)
  local f = io.open("probe-check.txt", "a")
  if f then
    f:write(((os and os.date) and os.date("%H:%M:%S") or "?") .. " " .. text .. "\n")
    f:close()
  end
end

local function call(name)
  local ok, value = pcall(function() return DefaultActionsParametersHolder[name]() end)
  return ok and tostring(value) or ("error: " .. tostring(value))
end

local last, elapsed = nil, 0
local function check(where)
  local now = "status=" .. call("GetStatusClearance") .. " authorize=" .. call("GetAuthorizeUserClearance")
  if now ~= last then write(where .. ": " .. now); last = now end
end

registerForEvent("onInit", function()
  write("probe-check ready")
  check("init")
  ObserveAfter("SingleplayerMenuGameController", "OnInitialize", function() check("main menu") end)
end)

registerForEvent("onUpdate", function(delta)
  elapsed = elapsed + delta
  if elapsed >= 5 then elapsed = 0; check("poll") end
end)
