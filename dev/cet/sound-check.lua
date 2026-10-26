-- Dev only. Fire-mode sound check (Phase 3), run in a loaded save by the boot check:
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/sound-check.lua -HoldSec <12 s per weapon + 15>
-- with `action = "charge"` also start tools/hold-trigger.ps1 in the background first.
-- Edit the settings below. For each weapon in turn: crafts it with the trigger mods, equips and draws
-- it, then
--   action "fire":   fires 8 quick shots through AIWeapon.Fire with the requested trigger `mode`
--                    (the game's own shot path; same sound events as the real trigger, Phase 3
--                    first slice);
--   action "charge": switches the weapon to its Charge trigger mode (as the fire-mode switch
--                    does), calls the NPC charge-start sound once, then raises trigger-now.txt so
--                    tools/hold-trigger.ps1 holds the real trigger (the player's charge path).
-- The listener (PreemSoundListener.reds, needs Audioware) logs every watched event with the record
-- of the player's weapon, then the counts. Count only lines "on player's weapon <record>"
-- (HANDOFF §3).
-- Each weapon: record, the mods PreemCraftTest installs, and the requested trigger mode for
-- action "fire" (a gamedataTriggerMode name).
local weapons = {
  { "Items.Preset_Grad_Panam", "Trigger_FullAuto", "FullAuto" },
  { "Items.Preset_Grad_Panam", "Trigger_Burst", "Burst" },
  { "Items.Preset_Grad_Panam", "Barrel_Silencer, Trigger_FullAuto", "FullAuto" },
}
local action = "fire"
local watch = table.concat({
  "w_gun_sniper_power_grad_fire_suppressor", "w_gun_sniper_power_grad_fire",
  "w_gun_revol_power_overture_fire_suppressor_auto", "w_gun_revol_power_overture_fire_suppressor_auto_stop",
  "w_gun_smg_tech_senkoh_fire_burst",
}, ", ")
local ammo = { "Ammo.HandgunAmmo", "Ammo.RifleAmmo", "Ammo.ShotgunAmmo", "Ammo.SniperRifleAmmo" }

local function raiseTrigger()
  local f = io.open("trigger-now.txt", "w")
  if f then f:write("now"); f:close() end
end

local steps = { { at = 0, run = function()
  Game.PreemSoundWatch(watch)
  for _, a in ipairs(ammo) do Game.AddToInventory(a, 300) end
end } }
for n, w in ipairs(weapons) do
  local weapon, mods, mode = w[1], w[2], w[3]
  local t = (n - 1) * 12
  table.insert(steps, { at = t, run = function() Game.PreemCraftTest(weapon, mods) end })
  table.insert(steps, { at = t + 2, run = function() Game.PreemEquipTest() end })
  table.insert(steps, { at = t + 4, run = function() Game.PreemSoundDraw() end })
  table.insert(steps, { at = t + 7, run = function() Game.PreemDump() end })
  if action == "charge" then
    table.insert(steps, { at = t + 7.5, run = function() Game.PreemSoundTriggerMode("Charge") end })
    table.insert(steps, { at = t + 8, run = function() Game.PreemSoundChargeAI() end })
    table.insert(steps, { at = t + 8.5, run = raiseTrigger })
  else
    for i = 0, 7 do
      table.insert(steps, { at = t + 8 + i * 0.15, run = function() Game.PreemSoundFire(mode) end })
    end
  end
end
table.insert(steps, { at = #weapons * 12 + 2, run = function() Game.PreemSoundSummary() end })
table.sort(steps, function(a, b) return a.at < b.at end)

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
