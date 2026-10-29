-- Dev only. Crafting end to end in a loaded save, through the debug commands
-- (dev/redscript/PreemDev/PreemDebug.reds):
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/craft-e2e.lua -HoldSec 50
-- 1. Lexington (Power, semi-auto pistol) + Smart barrel, Full-auto trigger, Thermal rounds:
--    crafts Items.Preset_Lexington_Default_PreemSmart (Smart), the three mods sit in their first
--    slots, and once equipped the weapon fires Full-auto.
-- 2. Katana + Thermal blade, Rubberized grip: crafted as itself, both mods in their first slots.
-- 3. Lexington + Burst trigger: its own trigger mode is Full-auto on 2.5, so this one shows the
--    trigger mod changing it: once equipped it fires Burst.
-- 4. The dev test add-on (PreemTestAddon.reds) on: Lexington + its PreemDev.TestBarrel and Full-auto: the
--    add-on barrel sits in the first Preem barrel slot (its own record, Items.DevAddonBarrel), reads
--    back by its ID, and the Upgrades tab shows it installed. The add-on goes off again after.
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
  { at = 25, run = function()
      Game.PreemTestAddonOn(true)
      Game.PreemCraftTest("Items.Preset_Lexington_Default", "PreemDev.TestBarrel, Trigger_FullAuto")
    end },
  { at = 28, run = function()
      Game.PreemDump()
      Game.PreemExpectTest("add-on barrel", "Items.Preset_Lexington_Default", "Power", "",
        "PreemBarrelMod01=PreemDev.TestBarrel, PreemTriggerMod01=Trigger_FullAuto")
      Game.PreemReadBackTest("add-on barrel read back", "PreemBarrelMod01=PreemDev.TestBarrel, PreemTriggerMod01=Trigger_FullAuto")
      Game.PreemOpenCrafting()
    end },
  { at = 31, run = function() Game.PreemUiNextTab() end },
  { at = 33, run = function() Game.PreemUiSelectUpgradeTestItem() end },
  { at = 34, run = function()
      Game.PreemUiDumpUpgrade()
      Game.PreemExpectUpgradeSlotted("add-on barrel on the Upgrades tab", "PreemDev.TestBarrel, Trigger_FullAuto")
      Game.PreemTestAddonOn(false)
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
