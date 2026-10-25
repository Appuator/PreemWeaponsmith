-- Dev only, never shipped. tools/boot-check.ps1 installs this CET mod, waits for the
-- "main-menu" line in boot-marker.txt, then removes it.
-- A file, not a log: CET writes its logs only when the game exits, so they can't be polled.
-- SingleplayerMenuGameController is the main menu's controller. Its OnInitialize runs once the
-- menu is built, about 25 s after launch on 2.5, while the intro video still plays over it.
local function mark(text)
  local f = io.open("boot-marker.txt", "a")
  if f then
    f:write(((os and os.date) and os.date("%Y-%m-%d %H:%M:%S") or "?") .. " " .. text .. "\n")
    f:close()
  end
end

registerForEvent("onInit", function()
  mark("cet-init")
  Observe("SingleplayerMenuGameController", "OnInitialize", function() mark("main-menu") end)
end)
