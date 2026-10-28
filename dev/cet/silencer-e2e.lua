-- Dev only. The Silencer in a barrel slot with its hidden muzzle part (ADR 0002), in a loaded save:
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/silencer-e2e.lua -HoldSec 90
-- 1. Craft an Ajax with the Silencer: the Silencer is in PreemBarrelMod01 and the hidden part
--    (Items.PreemSilencerMuzzle) in the muzzle slot; read-back shows only the Silencer. In hand,
--    IsSilenced() is true, CanSilentKill is 1 (the part adds no stats) and the shot is the Ajax's
--    suppressed one.
-- 2. Apply "Barrel_Recoil" to that owned weapon while it is in hand: the Silencer and the hidden
--    part come off and no Silencer item is left in the inventory. Again on a new Ajax that isn't
--    equipped (changing parts on the weapon in hand unequips it, and it doesn't re-equip in this
--    run), then equipped: IsSilenced() is false and the shot is the plain one.
-- 3. A 2.4.x weapon: craft with the Silencer, then put the Silencer back in the muzzle slot by
--    hand (as 2.4.x installed it; the record allows that slot only for this run) and drop the
--    hidden part. Applying "Barrel_Silencer" moves it to a barrel slot and installs the part.
-- E2e lines are "[PreemDev] e2e: PASS <label>" or "[PreemCheck] FAIL e2e ..." (fail the boot
-- check); IsSilenced and the hidden-part count go to scripting.log as "[PreemSilencerE2e]".
local muzzle = "AttachmentSlots.PowerModule"
local barrel1 = "AttachmentSlots.PreemBarrelMod01"
local part = "Items.PreemSilencerMuzzle"
local watch = "w_gun_rifle_power_ajax_fire_single, w_gun_rifle_power_ajax_fire_auto, w_gun_rifle_power_ajax_fire_suppressor_single, w_gun_rifle_power_ajax_fire_suppressor_auto"

local function report(label)
  local player = Game.GetPlayer()
  local ts = Game.GetTransactionSystem()
  local weapon = ts:GetItemInSlot(player, TweakDBID.new("AttachmentSlots.WeaponRight"))
  local silenced = weapon and tostring(weapon:IsSilenced()) or "no weapon in hand"
  local parts = 0
  local ok, items = ts:GetItemList(player)
  if ok then
    for _, data in ipairs(items) do
      if TDBID.ToStringDEBUG(data:GetID().id) == part then parts = parts + data:GetQuantity() end
    end
  end
  print(string.format("[PreemSilencerE2e] %s: IsSilenced=%s, hidden parts in inventory=%d", label, silenced, parts))
end

local function fire(label)
  return {
    { 0, function() Game.PreemEquipTest() end },
    { 2, function() Game.PreemSoundDraw() end },
    { 4, function() report(label) end },
    { 5, function() Game.PreemSoundFire("SemiAuto") end },
    { 5.3, function() Game.PreemSoundFire("SemiAuto") end },
    { 5.6, function() Game.PreemSoundFire("SemiAuto") end },
    { 5.9, function() Game.PreemSoundFire("SemiAuto") end },
    { 6.5, function() print(string.format("[PreemSilencerE2e] %s: fired", label)) end },
  }
end

local plan = {
  { 0, function()
      Game.PreemSoundWatch(watch)
      Game.AddToInventory("Ammo.RifleAmmo", 3000)
      Game.PreemCraftTest("Items.Preset_Ajax_Default", "Barrel_Silencer")
    end },
  { 3, function()
      Game.PreemExpectTest("Silencer crafted", "Items.Preset_Ajax_Default", "", "", "PreemBarrelMod01=Barrel_Silencer, PowerModule=" .. part)
      Game.PreemReadBackTest("Silencer read back", "PreemBarrelMod01=Barrel_Silencer")
    end },
  { 4, fire("1 crafted with Silencer") },
  { 12, function() Game.PreemStatDump("CanSilentKill") end },
  { 14, function() Game.PreemApplyTest("Barrel_Recoil") end },
  { 17, function() Game.PreemReadBackTest("Silencer removed in hand", "PreemBarrelMod01=Barrel_Recoil") end },
  { 18, function() Game.PreemCraftTest("Items.Preset_Ajax_Default", "Barrel_Silencer") end },
  { 21, function() Game.PreemApplyTest("Barrel_Recoil") end },
  { 24, function()
      Game.PreemExpectTest("Silencer removed", "", "", "", "PreemBarrelMod01=Barrel_Recoil")
      Game.PreemReadBackTest("Recoil read back", "PreemBarrelMod01=Barrel_Recoil")
    end },
  { 25, fire("2 Silencer removed") },
  { 34, function() Game.PreemCraftTest("Items.Preset_Ajax_Default", "Barrel_Silencer") end },
  { 37, function()
      TweakDB:SetFlat("Items.PreemBarrelModSilencer.placementSlots", { TweakDBID.new(muzzle), TweakDBID.new(barrel1) })
      local id = Game.GetScriptableSystemsContainer():Get("PreemDev.PreemDevSystem").lastTestItem
      local ts = Game.GetTransactionSystem()
      local player = Game.GetPlayer()
      local helper = ts:RemovePart(player, id, TweakDBID.new(muzzle), true)
      ts:RemoveItem(player, helper, 1)
      local silencer = ts:RemovePart(player, id, TweakDBID.new(barrel1), true)
      print(string.format("[PreemSilencerE2e] 3 made 2.4.x: silencer back in the muzzle %s",
        tostring(ts:AddPart(player, id, silencer, TweakDBID.new(muzzle)))))
    end },
  { 39, function()
      Game.PreemExpectTest("2.4.x Silencer", "", "", "", "PowerModule=Barrel_Silencer")
      Game.PreemReadBackTest("2.4.x read back", "PowerModule=Barrel_Silencer")
      Game.PreemApplyTest("Barrel_Silencer")
    end },
  { 42, function()
      Game.PreemExpectTest("2.4.x Silencer moved", "", "", "", "PreemBarrelMod01=Barrel_Silencer, PowerModule=" .. part)
      Game.PreemReadBackTest("moved read back", "PreemBarrelMod01=Barrel_Silencer")
    end },
  { 43, fire("3 2.4.x Silencer moved") },
  { 52, function() Game.PreemSoundSummary() end },
}

local steps = {}
for _, p in ipairs(plan) do
  if type(p[2]) == "function" then
    table.insert(steps, { at = p[1], run = p[2] })
  else
    for _, s in ipairs(p[2]) do table.insert(steps, { at = p[1] + s[1], run = s[2] }) end
  end
end
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
