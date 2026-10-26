-- Dev only. Crafting end to end in a loaded save, through the debug commands
-- (dev/redscript/PreemDev/PreemDebug.reds):
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/craft-e2e.lua -HoldSec 40
-- 1. Lexington (Power, semi-auto pistol) + Smart barrel, Full-auto trigger, Thermal rounds:
--    crafts Items.Preset_Lexington_Default_PreemSmart (Smart), the three mods sit in their first
--    slots, and once equipped the weapon fires Full-auto.
-- 2. Katana + Thermal blade, Rubberized grip: crafted as itself, both mods in their first slots.
-- 3. Lexington + Burst trigger: its own trigger mode is Full-auto on 2.5, so this one shows the
--    trigger mod changing it: once equipped it fires Burst.
-- Expected values are the 2.2.5 behaviour. PreemExpectTest logs "[PreemCheck] FAIL e2e ..." per
-- mismatch, which fails the boot check, or "[PreemDev] e2e: PASS <label>".
local steps = {
  { at = 0, run = function() Game.PreemCraftTest("Items.Preset_Lexington_Default", "Barrel_Smart, Trigger_FullAuto, Mag_Thermal") end },
  { at = 3, run = function() Game.PreemEquipTest() end },
  { at = 9, run = function()
      Game.PreemDump()
      Game.PreemExpectTest("ranged", "Items.Preset_Lexington_Default_PreemSmart", "Smart", "FullAuto",
        "PreemBarrelMod01=Barrel_Smart, PreemTriggerMod01=Trigger_FullAuto, PreemMagazineMod01=Mag_Thermal")
    end },
  { at = 10, run = function() Game.PreemCraftTest("Items.Preset_Katana_Default", "Blade_Thermal, Handle_RubberizedGrip") end },
  { at = 13, run = function()
      Game.PreemDump()
      Game.PreemExpectTest("melee", "Items.Preset_Katana_Default", "", "",
        "PreemBladeMod01=Blade_Thermal, PreemHandleMod01=Handle_RubberizedGrip")
    end },
  { at = 14, run = function() Game.PreemCraftTest("Items.Preset_Lexington_Default", "Trigger_Burst") end },
  { at = 17, run = function() Game.PreemEquipTest() end },
  { at = 23, run = function()
      Game.PreemDump()
      Game.PreemExpectTest("trigger change", "Items.Preset_Lexington_Default", "Power", "Burst",
        "PreemTriggerMod01=Trigger_Burst")
    end },
}
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
