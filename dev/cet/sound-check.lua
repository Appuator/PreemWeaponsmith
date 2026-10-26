-- Dev only. Fire-mode sound check (Phase 3), run in a loaded save by the boot check:
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/sound-check.lua -HoldSec 40
-- Edit the three settings below for the weapon and sound set under test. Crafts the weapon with
-- the trigger mods, equips and draws it, watches the event names (PreemSoundListener.reds, needs
-- Audioware), fires 8 quick shots through AIWeapon.Fire, then writes trigger-now.txt in this
-- mod's folder so an outside script can pull the real trigger, and prints the counts.
local weapon = "Items.Preset_Liberty_Default"
local mods = "Trigger_FullAuto"
local watch = "w_gun_pistol_power_liberty_fire_single, w_gun_pistol_power_lexington_fire_auto, w_gun_pistol_power_lexington_fire_auto_stop"

local steps = {
  { at = 0, run = function() Game.PreemSoundWatch(watch) end },
  { at = 0, run = function() Game.PreemCraftTest(weapon, mods) end },
  { at = 3, run = function() Game.PreemEquipTest() end },
  { at = 6, run = function() Game.PreemSoundDraw() end },
  { at = 10, run = function() Game.PreemDump() end },
}
for i = 0, 7 do
  table.insert(steps, { at = 12 + i * 0.15, run = function() Game.PreemSoundFire(true) end })
end
table.insert(steps, { at = 17, run = function()
  local f = io.open("trigger-now.txt", "w")
  if f then f:write("now"); f:close() end
end })
table.insert(steps, { at = 27, run = function() Game.PreemSoundSummary() end })

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
