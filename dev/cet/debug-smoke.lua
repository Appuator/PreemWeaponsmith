-- Dev only. Smoke test for the crafting debug commands (dev/redscript/PreemDev/PreemDebug.reds),
-- run at the main menu by the boot check:
--   pwsh tools/boot-check.ps1 -Run dev/cet/debug-smoke.lua -HoldSec 20
-- Crafts the Ajax with a Smart barrel and a Full-auto trigger, dumps it once the install
-- requests have had time to finish, equips it and dumps again. Results are [PreemDev] lines in
-- the boot check's output.
local steps = {
  { at = 0, run = function() Game.PreemCraftTest("Items.Preset_Ajax_Default", "Barrel_Smart, Trigger_FullAuto") end },
  { at = 3, run = function() Game.PreemDump() end },
  { at = 4, run = function() Game.PreemEquipTest() end },
  { at = 8, run = function() Game.PreemDump() end },
}
local started, elapsed, nextStep = false, 0, 1

registerForEvent("onInit", function()
  Observe("SingleplayerMenuGameController", "OnInitialize", function() started = true end)
end)

registerForEvent("onUpdate", function(delta)
  if not started or nextStep > #steps then return end
  elapsed = elapsed + delta
  while nextStep <= #steps and elapsed >= steps[nextStep].at do
    steps[nextStep].run()
    nextStep = nextStep + 1
  end
end)
