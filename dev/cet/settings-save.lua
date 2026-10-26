-- Dev only. First half of the settings save/load check (second half: settings-show.lua):
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/settings-save.lua -HoldSec 30
-- In the loaded save, prints the settings, sets them to unlock 0 (Sandbox), limit 1 (Weapon
-- Blueprints), layout 1 (Below Weapon), which differ from the built-in 1, 0, 0, and makes a manual
-- save, as the in-game save menu does. That save is then the newest one.
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
    Game.PreemSetSettings(0, 1, 1)
    Game.PreemShowSettings()
    Game.GetSystemRequestsHandler():ManualSave("ManualSave-")
  end
end)
