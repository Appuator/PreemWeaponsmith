-- Dev only. Phase 3 Audioware spike driver (see PreemAudioSpike.reds next to this file):
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/spike/audioware/spike.lua -HoldSec 40
-- Gives, equips and draws a Lexington, posts two control events from script, fires 8 shots
-- through AIWeapon.Fire, then writes trigger-now.txt in this mod's folder so an outside script
-- can hold the left mouse button (the player's own trigger path), and finally prints the counts.
local steps = {
  { at = 0, run = function() Game.PreemSpikeSetup() end },
  { at = 3, run = function() Game.PreemSpikeDraw() end },
  { at = 7, run = function() Game.PreemSpikeControl() end },
}
for i = 0, 7 do
  table.insert(steps, { at = 9 + i * 0.4, run = function() Game.PreemSpikeFire(i >= 4) end })
end
table.insert(steps, { at = 14, run = function()
  local f = io.open("trigger-now.txt", "w")
  if f then f:write("now"); f:close() end
end })
table.insert(steps, { at = 24, run = function() Game.PreemSpikeSummary() end })

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
