-- Dev only, never shipped. tools/boot-check.ps1 installs this CET mod, waits for the
-- "main-menu" line in boot-marker.txt, then removes it.
-- A file, not a log: CET writes its logs only when the game exits, so they can't be polled.
-- SingleplayerMenuGameController is the main menu's controller. Its OnInitialize runs once the
-- menu is built, about 25 s after launch on 2.5, while the intro video still plays over it.
--
-- With boot-check -LoadSave, the script writes load-save.txt next to this file. Then, once the
-- menu knows the newest save (OnSaveMetadataReady for save 0), this mod loads it the way the
-- menu's Continue does (LoadModdedSave for a save made with mods, else LoadLastCheckpoint),
-- writes "in-game" when the session has left the pre-game state with a player, and "playing"
-- once game time moves (the loading screen has been dismissed).
local function mark(text)
  local f = io.open("boot-marker.txt", "a")
  if f then
    f:write(((os and os.date) and os.date("%Y-%m-%d %H:%M:%S") or "?") .. " " .. text .. "\n")
    f:close()
  end
end

local loadSave = io.open("load-save.txt", "r") ~= nil
local loadRequested, inGame = false, false

registerForEvent("onInit", function()
  mark("cet-init")
  Observe("SingleplayerMenuGameController", "OnInitialize", function() mark("main-menu") end)
  if loadSave then
    Observe("SingleplayerMenuGameController", "OnSaveMetadataReady", function(self, info)
      if loadRequested or info.saveIndex ~= 0 or not info.isValid then return end
      loadRequested = true
      mark("load-save modded=" .. tostring(info.isModded))
      if info.isModded then
        self:LoadModdedSave(0)
      else
        self:GetSystemRequestsHandler():LoadLastCheckpoint(false)
      end
    end)
  end
end)

-- After loading, the game waits on "Press Space to continue" with the world paused; the boot
-- check presses Space until this mod reports "playing" (game time has started moving).
local playing, startTime = false, nil

registerForEvent("onUpdate", function()
  if not loadRequested or playing then return end
  if not inGame then
    local player = Game.GetPlayer()
    if player and not Game.GetSystemRequestsHandler():IsPreGame() then
      inGame = true
      mark("in-game")
    end
    return
  end
  local now = Game.GetTimeSystem():GetGameTimeStamp()
  if startTime == nil then
    startTime = now
  elseif now > startTime then
    playing = true
    mark("playing")
  end
end)
