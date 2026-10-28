-- Dev only. Silenced sound sets: each row crafts a weapon whose sound group vanilla 2.5 leaves
-- without a silenced set (notes/silencer-sounds.md), with Barrel_Silencer (and a trigger mod in the
-- later rows), and fires 8 shots. In a loaded save:
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/silencer-check.lua -HoldSec 365
--   pwsh tools/sound-sweep-report.ps1
-- A row passes when its donor set's event (PreemSoundSets.Fills, playerSilenced rows) plays on the
-- player's weapon. Same steps and row lines as dev/cet/sound-sweep.lua.
local rows = {
  { set = "wea_pla_masamune_suppressor", weapon = "Items.Preset_Kenshin_Default", mode = "SemiAuto", expect = "w_gun_rifle_power_masamune_fire_suppressor_burst" },
  { set = "wea_pla_nue_suppressor", weapon = "Items.Preset_Burya_Default", mode = "SemiAuto", expect = "w_gun_pistol_power_nue_fire_suppressor" },
  { set = "wea_pla_masamune_suppressor", weapon = "Items.Preset_Shingen_Default", mode = "FullAuto", expect = "w_gun_rifle_power_masamune_fire_suppressor" },
  { set = "wea_pla_ajax_suppressor", weapon = "Items.Preset_Sidewinder_Default", mode = "FullAuto", expect = "w_gun_rifle_power_ajax_fire_suppressor_auto" },
  { set = "wea_pla_grad_suppressor", weapon = "Items.Preset_Grad_Default", mode = "SemiAuto", expect = "w_gun_sniper_power_grad_fire_suppressor" },
  { set = "wea_pla_grad_suppressor", weapon = "Items.Preset_Grad_Panam", mode = "SemiAuto", expect = "w_gun_sniper_power_grad_fire_suppressor" },
  { set = "wea_pla_grad_suppressor", weapon = "Items.Preset_Nekomata_Default", mode = "SemiAuto", expect = "w_gun_sniper_power_grad_fire_suppressor" },
  { set = "wea_pla_grad_suppressor", weapon = "Items.Preset_Carnage_Default", mode = "SemiAuto", expect = "w_gun_sniper_power_grad_fire_suppressor" },
  { set = "wea_pla_grad_suppressor", weapon = "Items.Preset_Metel_Default", mode = "SemiAuto", expect = "w_gun_sniper_power_grad_fire_suppressor" },
  { set = "wea_pla_nue_suppressor", weapon = "Items.Preset_Testera_Default", mode = "SemiAuto", expect = "w_gun_pistol_power_nue_fire_suppressor" },
  { set = "wea_pla_masamune_suppressor", weapon = "Items.Preset_Ticon_Default", mode = "SemiAuto", expect = "w_gun_rifle_power_masamune_fire_suppressor_burst" },
  { set = "wea_pla_kyubi_suppressor", weapon = "Items.Preset_Achilles_Default", mode = "SemiAuto", expect = "w_gun_rifle_power_kyubi_fire_single_suppressed" },
  { set = "wea_pla_lexington_suppressor", weapon = "Items.Preset_Kappa_Default", mode = "SemiAuto", expect = "w_gun_pistol_power_lexington_fire_suppressor_single" },
  { set = "wea_pla_defender_suppressor", weapon = "Items.Preset_MA70_Default", mode = "FullAuto", expect = "w_gun_lmg_power_defender_fire_suppressor_auto" },
  { set = "wea_pla_nova_suppressor", weapon = "Items.Preset_Nova_Hitman", mode = "SemiAuto", expect = "w_gun_revol_power_nova_fire_suppressor" },
  { set = "wea_pla_unity_suppressor", weapon = "Items.Preset_Unity_Agent", mode = "SemiAuto", expect = "w_gun_pistol_power_unity_fire_suppressor" },
  { set = "wea_pla_warden_suppressor", weapon = "Items.Preset_Warden_Boris", mode = "SemiAuto", expect = "w_gun_warden_fire_single_suppressor" },
  { set = "wea_pla_defender_suppressor", weapon = "Items.Preset_HMG_Chopper", mode = "FullAuto", expect = "w_gun_lmg_power_defender_fire_suppressor_auto" },
  -- Fire modes from trigger mods: the donor set's auto or burst event (its own or a PreemSoundSets fill).
  { set = "wea_pla_nue_suppressor", weapon = "Items.Preset_Burya_Default", mods = "Barrel_Silencer, Trigger_FullAuto", mode = "FullAuto", expect = "w_gun_rifle_power_ajax_fire_suppressor_auto" },
  { set = "wea_pla_nue_suppressor", weapon = "Items.Preset_Burya_Default", mods = "Barrel_Silencer, Trigger_Burst", mode = "Burst", expect = "w_gun_rifle_power_masamune_fire_suppressor_burst" },
  { set = "wea_pla_grad_suppressor", weapon = "Items.Preset_Carnage_Default", mods = "Barrel_Silencer, Trigger_FullAuto", mode = "FullAuto", expect = "w_gun_rifle_power_ajax_fire_suppressor_auto" },
  { set = "wea_pla_grad_suppressor", weapon = "Items.Preset_Nekomata_Default", mods = "Barrel_Silencer, Trigger_FullAuto", mode = "FullAuto", expect = "w_gun_rifle_power_ajax_fire_suppressor_auto" },
  { set = "wea_pla_masamune_suppressor", weapon = "Items.Preset_Kenshin_Default", mods = "Barrel_Silencer, Trigger_FullAuto", mode = "FullAuto", expect = "w_gun_rifle_power_ajax_fire_suppressor_auto" },
  { set = "wea_pla_grad_suppressor", weapon = "Items.Preset_Grad_Default", mods = "Barrel_Silencer, Trigger_FullAuto", mode = "FullAuto", expect = "w_gun_rifle_power_ajax_fire_suppressor_auto" },
  { set = "wea_pla_grad_suppressor", weapon = "Items.Preset_Grad_Default", mods = "Barrel_Silencer, Trigger_Burst", mode = "Burst", expect = "w_gun_smg_tech_senkoh_fire_burst" },
  { set = "wea_pla_ajax_suppressor", weapon = "Items.Preset_Sidewinder_Default", mods = "Barrel_Silencer, Trigger_Burst", mode = "Burst", expect = "w_gun_rifle_power_masamune_fire_suppressor_burst" },
  { set = "wea_pla_kyubi_suppressor", weapon = "Items.Preset_Achilles_Default", mods = "Barrel_Silencer, Trigger_FullAuto", mode = "FullAuto", expect = "w_gun_rifle_power_ajax_fire_suppressor_auto" },
  { set = "wea_pla_kyubi_suppressor", weapon = "Items.Preset_Achilles_Default", mods = "Barrel_Silencer, Trigger_Burst", mode = "Burst", expect = "w_gun_rifle_power_masamune_fire_suppressor_burst" },
  { set = "wea_pla_lexington_suppressor", weapon = "Items.Preset_Kappa_Default", mods = "Barrel_Silencer, Trigger_FullAuto", mode = "FullAuto", expect = "w_gun_pistol_power_lexington_fire_suppressor_auto" },
  { set = "wea_pla_defender_suppressor", weapon = "Items.Preset_MA70_Default", mods = "Barrel_Silencer, Trigger_Burst", mode = "Burst", expect = "w_gun_rifle_power_masamune_fire_suppressor_burst" },
  { set = "wea_pla_nova_suppressor", weapon = "Items.Preset_Nova_Hitman", mods = "Barrel_Silencer, Trigger_FullAuto", mode = "FullAuto", expect = "w_gun_pistol_power_lexington_fire_suppressor_auto" },
  { set = "wea_pla_unity_suppressor", weapon = "Items.Preset_Unity_Agent", mods = "Barrel_Silencer, Trigger_Burst", mode = "Burst", expect = "w_gun_rifle_power_masamune_fire_suppressor_burst" },
  { set = "wea_pla_warden_suppressor", weapon = "Items.Preset_Warden_Boris", mods = "Barrel_Silencer, Trigger_FullAuto", mode = "FullAuto", expect = "w_gun_warden_fire_auto_suppressor" },
}
local ammo = { "Ammo.HandgunAmmo", "Ammo.RifleAmmo", "Ammo.ShotgunAmmo", "Ammo.SniperRifleAmmo" }
-- Every fire, auto and burst event of the donor sets, so a row that plays another event of its
-- donor shows which one.
local watch = table.concat({
  "w_gun_rifle_power_ajax_fire_suppressor_single", "w_gun_rifle_power_ajax_fire_suppressor_auto",
  "w_gun_lmg_power_defender_fire_suppressor_single", "w_gun_lmg_power_defender_fire_suppressor_auto",
  "w_gun_sniper_power_grad_fire_suppressor", "w_gun_rifle_power_kyubi_fire_single_suppressed",
  "w_gun_pistol_power_lexington_fire_suppressor_single", "w_gun_pistol_power_lexington_fire_suppressor_auto",
  "w_gun_rifle_power_masamune_fire_suppressor", "w_gun_rifle_power_masamune_fire_suppressor_burst",
  "w_gun_revol_power_nova_fire_suppressor", "w_gun_pistol_power_nue_fire_suppressor",
  "w_gun_pistol_power_unity_fire_suppressor", "w_gun_warden_fire_single_suppressor",
  "w_gun_warden_fire_auto_suppressor", "w_gun_warden_fire_burst_suppressor",
  "w_gun_revol_power_overture_fire_suppressor_auto", "w_gun_smg_tech_senkoh_fire_burst",
}, ", ")

local steps = { { at = 0, run = function()
  Game.PreemSoundWatch(watch)
  for _, a in ipairs(ammo) do Game.AddToInventory(a, 3000) end
end } }
for n, s in ipairs(rows) do
  local t = (n - 1) * 9
  table.insert(steps, { at = t, run = function()
    print(string.format("[PreemSweep] %d %s %s expect %s", n, s.set, s.weapon, s.expect))
    Game.PreemCraftTest(s.weapon, s.mods or "Barrel_Silencer")
  end })
  table.insert(steps, { at = t + 2, run = function() Game.PreemEquipTest() end })
  table.insert(steps, { at = t + 4, run = function() Game.PreemSoundDraw() end })
  for i = 0, 7 do
    table.insert(steps, { at = t + 6.5 + i * 0.15, run = function() Game.PreemSoundFire(s.mode) end })
  end
end
table.insert(steps, { at = #rows * 9 + 3, run = function() Game.PreemSoundSummary() end })
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
