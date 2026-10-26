-- Dev only. Smoke test for the crafting debug commands (dev/redscript/PreemDev/PreemDebug.reds),
-- run in a loaded save by the boot check:
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/debug-smoke.lua -HoldSec 30
-- Crafts the Ajax with a Smart barrel and a Full-auto trigger, dumps it once the install
-- requests have had time to finish, equips it and dumps again. Results are [PreemDev] lines in
-- the boot check's output. Starts 3 s after game time starts moving (loading screen dismissed).
local steps = {
  { at = 0, run = function() Game.PreemCraftTest("Items.Preset_Ajax_Default", "Barrel_Smart, Trigger_FullAuto") end },
  { at = 3, run = function() Game.PreemDump() end },
  { at = 4, run = function() Game.PreemEquipTest() end },
  { at = 10, run = function() Game.PreemDump() end },
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
