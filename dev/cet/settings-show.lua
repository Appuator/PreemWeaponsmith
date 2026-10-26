-- Dev only. Second half of the settings save/load check (first half: settings-save.lua):
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/settings-show.lua -HoldSec 10
-- Prints the settings of the loaded (newest) save. After settings-save.lua they must read
-- unlock 0, limit 1, layout 1, not the built-in 1, 0, 0.
local startTime, playingFor, done = nil, nil, false

registerForEvent("onUpdate", function(delta)
  if done then return end
  if playingFor == nil then
    if not Game.GetPlayer() or Game.GetSystemRequestsHandler():IsPreGame() then return end
    local now = Game.GetTimeSystem():GetGameTimeStamp()
    if startTime == nil then startTime = now elseif now > startTime then playingFor = 0 end
    return
  end
  playingFor = playingFor + delta
  if playingFor >= 3 then
    done = true
    Game.PreemShowSettings()
  end
end)
