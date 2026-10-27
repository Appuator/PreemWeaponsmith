-- Dev only. Preem mods on the Upgrades tab (SPEC §2.1) in a loaded save, through the UI drivers
-- (dev/redscript/PreemDev/PreemUiDriver.reds) and debug commands:
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/upgrade-e2e.lua -HoldSec 45
-- 1. A crafted Tier 1 Lexington (Full-auto, Thermal) is listed (non-iconic). With the Weapon
--    Blueprints limit a Common weapon takes no Preem mods, so APPLY is blocked for Burst. With the
--    Sandbox limit the hold APPLIES Burst without an upgrade: Burst in, Thermal gone, no upgrade,
--    no Preem mod item left over.
-- 2. A fresh iconic Foxhound (Nekomata, Thermal) is upgradable: the strip is set to Electric and
--    the hold UPGRADES it once and then installs Electric over Thermal; the strip shows Electric.
-- Each check logs "[PreemDev] e2e: PASS <label>" or "[PreemCheck] FAIL e2e ..." (fails the boot
-- check). It changes the loaded save's settings (limit), which the run never saves on purpose.
local steps = {
  { at = 0, run = function()
      Game.PreemSetSettings(0, 1, 1)
      Game.PreemCraftTest("Items.Preset_Lexington_Default", "Trigger_FullAuto, Mag_Thermal")
    end },
  { at = 3, run = function() Game.PreemOpenCrafting() end },
  { at = 6, run = function() Game.PreemUiNextTab() end },
  { at = 8, run = function() Game.PreemUiSelectUpgradeTestItem() end },
  { at = 9, run = function()
      Game.PreemUiSetUpgradeMods("Trigger_Burst")
      Game.PreemExpectUpgradeButton("Blueprints limit blocks a Common weapon", false)
      Game.PreemSetSettings(0, 0, 1)
      Game.PreemUiSetUpgradeMods("Trigger_Burst")
      Game.PreemExpectUpgradeButton("Sandbox limit allows it", true)
      Game.PreemUiHoldUpgrade()
    end },
  { at = 12, run = function()
      Game.PreemUiDumpUpgrade()
      Game.PreemReadBackTest("apply on a crafted weapon", "PreemTriggerMod01=Trigger_Burst")
      Game.PreemExpectUpgradeLevel("crafted weapon not upgraded", 0)
    end },
  { at = 13, run = function() Game.PreemCraftTest("Items.Preset_Nekomata_Amazon", "Mag_Thermal") end },
  { at = 15, run = function() Game.PreemUiRefreshUpgrades() end },
  { at = 16, run = function() Game.PreemUiSelectUpgradeTestItem() end },
  { at = 17, run = function()
      Game.PreemUiSetUpgradeMods("Mag_Electric")
      Game.PreemUiDumpUpgrade()
      Game.PreemUiHoldUpgrade()
    end },
  { at = 21, run = function()
      Game.PreemUiDumpUpgrade()
      Game.PreemReadBackTest("upgrade an iconic", "PreemMagazineMod01=Mag_Electric")
      Game.PreemExpectUpgradeLevel("iconic upgraded once", 1)
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
