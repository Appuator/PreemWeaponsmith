-- Dev only. Iconic weapons with Preem mods (SPEC §2.1: iconics take every mod but evolution
-- barrels), in a loaded save, through the debug commands (dev/redscript/PreemDev/PreemDebug.reds):
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/iconic-e2e.lua -HoldSec 40
-- The weapons are given and modded through PreemCraftingSystem.ApplyMods, the path the Upgrades
-- tab uses. Iconic: the Foxhound (Items.Preset_Nekomata_Amazon).
-- 1. Without Preem mods it keeps its own record and, equipped, its record's trigger mode.
-- 2. With a Burst trigger it keeps its record and, equipped, fires Burst.
-- Each check logs "[PreemDev] e2e: PASS <label>" or "[PreemCheck] FAIL e2e ..." (fails the boot check).
local steps = {
  { at = 0, run = function() Game.PreemCraftTest("Items.Preset_Nekomata_Amazon", "") end },
  { at = 3, run = function() Game.PreemEquipTest() end },
  { at = 9, run = function()
      Game.PreemDump()
      Game.PreemReadBackTest("iconic without Preem mods", "")
      Game.PreemExpectTest("iconic keeps its trigger", "Items.Preset_Nekomata_Amazon", "", "record", "")
    end },
  { at = 10, run = function() Game.PreemCraftTest("Items.Preset_Nekomata_Amazon", "Trigger_Burst") end },
  { at = 13, run = function() Game.PreemEquipTest() end },
  { at = 19, run = function()
      Game.PreemDump()
      Game.PreemExpectTest("iconic takes a trigger mod", "Items.Preset_Nekomata_Amazon", "", "Burst",
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
