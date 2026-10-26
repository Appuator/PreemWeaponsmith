-- Dev only. Walks the settings panel in a loaded save (dev/redscript/PreemDev/PreemUiDriver.reds):
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/settings-panel.lua -HoldSec 60
-- Opens crafting, selects the first weapon recipe, then presses SETTINGS, presses all three setting buttons and
-- closes the popup, logging the screen's state ([PreemDev] ui: ...) after each stage. Each stage
-- also writes ui-step.txt in this mod's folder, so a screenshot can be taken from outside.
local steps = {
  { at = 0, run = function() Game.PreemOpenCrafting() end },
  { at = 3, run = function() Game.PreemUiSelectWeapon(0) end },
  { at = 5, run = function() Game.PreemUiDump() end, mark = "frame" },
  { at = 11, run = function() Game.PreemUiOpenSettings() end },
  { at = 13, run = function() end, mark = "popup" },
  { at = 19, run = function()
      Game.PreemUiPressSetting(0)
      Game.PreemUiPressSetting(1)
      Game.PreemUiPressSetting(2)
      Game.PreemUiDump()
    end },
  { at = 21, run = function() end, mark = "popup-changed" },
  { at = 27, run = function() Game.PreemUiCloseSettings() end },
  { at = 29, run = function() Game.PreemUiDump() end, mark = "frame-changed" },
}
local startTime, playingFor, nextStep = nil, nil, 1

local function mark(text)
  local f = io.open("ui-step.txt", "a")
  if f then f:write(text .. "\n"); f:close() end
end

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
    if steps[nextStep].mark then mark(steps[nextStep].mark) end
    nextStep = nextStep + 1
  end
end)
