-- Dev only. Live stat read, run in a loaded save by the boot check:
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/stat-check.lua -HoldSec 75
-- Edit the settings below. Crafts the weapon with the mods, equips it and calls
-- Game.PreemStatDump (dev/redscript/PreemDev/PreemStatDump.reds), which waits until that weapon is
-- in hand with its stats ready and prints "[PreemDev] stat <Name> on <record>: item, weapon,
-- player" lines. Without a weapon to craft (record = nil) it reads whatever is in hand.
-- Starts 3 s after game time starts moving (loading screen dismissed).
local record = "Items.Preset_Lexington_Default"
local mods = "Barrel_Smart"
local stats = "SmartGunHitProbability, SmartGunPlayerProjectileVelocity, HasSmartLink"

local steps = {}
if record then
  table.insert(steps, { at = 0, run = function() Game.PreemCraftTest(record, mods) end })
  table.insert(steps, { at = 3, run = function() Game.PreemEquipTest() end })
end
table.insert(steps, { at = 4, run = function() Game.PreemStatDump(stats) end })
local startTime, playingFor, nextStep = nil, nil, 1

registerForEvent("onUpdate", function(delta)
  if nextStep > #steps then return end
  if playingFor == nil then
    if not Game.GetPlayer() or Game.GetSystemRequestsHandler():IsPreGame() then return end
    local now = Game.GetTimeSystem():GetGameTimeStamp()
    if startTime == nil then startTime = now elseif now > startTime then playingFor = 0 end
    return
  end
  playingFor = playingFor + delta
  while nextStep <= #steps and playingFor - 3 >= steps[nextStep].at do
    steps[nextStep].run()
    nextStep = nextStep + 1
  end
end)
