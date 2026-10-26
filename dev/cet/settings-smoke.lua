-- Dev only. Smoke test for the per-save settings store (PreemSettings), run at the main menu:
--   pwsh tools/boot-check.ps1 -Run dev/cet/settings-smoke.lua -HoldSec 5
-- Prints the settings (the defaults on a fresh session), changes all three and prints them again.
local done = false

registerForEvent("onInit", function()
  Observe("SingleplayerMenuGameController", "OnInitialize", function()
    if done then return end
    done = true
    Game.PreemShowSettings()
    Game.PreemSetSettings(0, 1, 1)
    Game.PreemShowSettings()
  end)
end)
