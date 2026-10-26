-- Dev only. Fire-mode sound check (Phase 3), run in a loaded save by the boot check:
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/sound-check.lua -HoldSec <12 s per weapon + 15>
-- Edit the lists below. For each weapon in turn: crafts it with the trigger mods, equips and draws
-- it, and fires 8 quick shots through AIWeapon.Fire (the game's own shot path; it plays the same
-- sound events as the real trigger, Phase 3 first slice). The listener (PreemSoundListener.reds,
-- needs Audioware) logs every watched event with the record of the player's weapon, then the
-- counts. Count only lines "on player's weapon <record>" (HANDOFF §3).
local weapons = {
  "Items.Preset_Unity_Default",
  "Items.Preset_Metel_Default",
  "Items.Preset_Burya_Default",
  "Items.Preset_Carnage_Default",
  "Items.Preset_Ashura_Default",
}
local mods = "Trigger_FullAuto"
local watch = table.concat({
  "w_gun_pistol_power_lexington_fire_auto", "w_gun_pistol_power_lexington_fire_auto_stop",
  "w_gun_rifle_power_ajax_fire_auto", "w_gun_rifle_power_ajax_fire_auto_stop",
  "w_gun_revol_tech_quasar_fire_auto", "w_gun_revol_tech_quasar_fire_auto_stop",
  "w_gun_rifle_power_pozhar_fire_auto", "w_gun_rifle_power_pozhar_fire_auto_stop",
  "w_gun_smg_smart_sidewinder_fire_auto", "w_gun_smg_smart_sidewinder_fire_auto_stop",
}, ", ")

local steps = { { at = 0, run = function() Game.PreemSoundWatch(watch) end } }
for n, weapon in ipairs(weapons) do
  local t = (n - 1) * 12
  table.insert(steps, { at = t, run = function() Game.PreemCraftTest(weapon, mods) end })
  table.insert(steps, { at = t + 2, run = function() Game.PreemEquipTest() end })
  table.insert(steps, { at = t + 4, run = function() Game.PreemSoundDraw() end })
  table.insert(steps, { at = t + 7, run = function() Game.PreemDump() end })
  for i = 0, 7 do
    table.insert(steps, { at = t + 8 + i * 0.15, run = function() Game.PreemSoundFire(true) end })
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
