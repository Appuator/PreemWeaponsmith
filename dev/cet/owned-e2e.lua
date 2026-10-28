-- Dev only. Preem mods on a weapon the player already owns (the upgrade screen's case, SPEC §2.1),
-- in a loaded save, through the debug commands (dev/redscript/PreemDev/PreemDebug.reds):
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/owned-e2e.lua -HoldSec 45
-- 1. Craft a Lexington with Smart barrel, Full-auto trigger, Thermal rounds; read the three mods
--    back from its slots (PreemCraftingSystem.GetInstalledMods).
-- 2. Apply "Smart barrel, Burst trigger" to that owned weapon: the Smart barrel stays, Burst
--    replaces Full-auto, Thermal rounds come off. Same record (no new item), and no Preem mod
--    item is left in the inventory (removed and replaced mods are deleted, not refunded).
-- 3. Apply "" : every Preem mod comes off.
-- 4. The weapon in hand (Phase 7 gate, HANDOFF §4 2026-10-28): craft a Lexington with the Silencer
--    and Full-auto, equip and draw it, then apply "Barrel_Smart, Trigger_FullAuto": the Smart barrel
--    replaces the Silencer (its hidden muzzle part comes off too) and no Silencer item is left in
--    the inventory.
-- PreemExpectTest reads the slots itself; PreemReadBackTest goes through the read-back seam.
-- Each logs "[PreemDev] e2e: PASS <label>" or "[PreemCheck] FAIL e2e ..." (fails the boot check).
local steps = {
  { at = 0, run = function() Game.PreemCraftTest("Items.Preset_Lexington_Default", "Barrel_Smart, Trigger_FullAuto, Mag_Thermal") end },
  { at = 3, run = function()
      Game.PreemReadBackTest("read back crafted", "PreemBarrelMod01=Barrel_Smart, PreemTriggerMod01=Trigger_FullAuto, PreemMagazineMod01=Mag_Thermal")
      Game.PreemApplyTest("Barrel_Smart, Trigger_Burst")
    end },
  { at = 6, run = function()
      Game.PreemDump()
      Game.PreemExpectTest("owned change", "Items.Preset_Lexington_Default_PreemSmart", "Smart", "",
        "PreemBarrelMod01=Barrel_Smart, PreemTriggerMod01=Trigger_Burst")
      Game.PreemReadBackTest("read back owned change", "PreemBarrelMod01=Barrel_Smart, PreemTriggerMod01=Trigger_Burst")
      Game.PreemApplyTest("")
    end },
  { at = 9, run = function()
      Game.PreemDump()
      Game.PreemReadBackTest("owned cleared", "")
      Game.PreemCraftTest("Items.Preset_Lexington_Default", "Barrel_Silencer, Trigger_FullAuto")
    end },
  { at = 12, run = function()
      Game.PreemReadBackTest("read back Silencer crafted", "PreemBarrelMod01=Barrel_Silencer, PreemTriggerMod01=Trigger_FullAuto")
      Game.PreemEquipTest()
    end },
  { at = 14, run = function() Game.PreemSoundDraw() end },
  { at = 17, run = function() Game.PreemApplyTest("Barrel_Smart, Trigger_FullAuto") end },
  { at = 20, run = function()
      Game.PreemDump()
      Game.PreemReadBackTest("in-hand replace", "PreemBarrelMod01=Barrel_Smart, PreemTriggerMod01=Trigger_FullAuto")
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
