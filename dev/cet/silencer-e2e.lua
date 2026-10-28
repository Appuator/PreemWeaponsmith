-- Dev only. The Silencer in a barrel slot with its hidden muzzle part (ADR 0002), in a loaded save:
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/silencer-e2e.lua -HoldSec 150
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
-- 4. Muzzle brakes (ADR 0002 addendum): an Ajax with a rifle brake installed the vanilla way
--    (ItemModificationSystem request, as the mod screen does) keeps the brake and fires plain; a
--    fresh one with the same brake then the Silencer applied holds the brake's Silenced twin, fires
--    suppressed, and has the same brake stats (PreemStatDump of the brake's stat types, compare the
--    two dumps by hand); applying Recoil in hand gives the plain brake back on the weapon. Then the
--    vanilla path on a Silencer gun: another rifle brake installed goes in as its twin and the
--    hidden part is deleted; removing it the vanilla way gives back the plain brake. Last, a twin and
--    a hidden part put in the inventory are taken back by the sweep the crafting screen runs.
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

local brakeA = "Items.w_muzzle_brake_01"
local brakeB = "Items.w_muzzle_brake_06"

-- What the save already holds of each brake (counted at the start), so stock checks are relative.
local held = {}
local function stockOf(record)
  local n = 0
  local ok, items = Game.GetTransactionSystem():GetItemList(Game.GetPlayer())
  if ok then
    for _, data in ipairs(items) do
      if TDBID.ToStringDEBUG(data:GetID().id) == record then n = n + data:GetQuantity() end
    end
  end
  return n
end
local function expectBrakes(label, record, extra)
  Game.PreemExpectStock(label, record, (held[record] or 0) + extra)
end

local function testItem()
  return Game.GetScriptableSystemsContainer():Get("PreemDev.PreemDevSystem").lastTestItem
end

-- Gives the player the part and installs it through ItemModificationSystem, as the mod screen does.
local function vanillaInstall(record)
  local part = ItemID.FromTDBID(TweakDBID.new(record))
  Game.GetTransactionSystem():GiveItem(Game.GetPlayer(), part, 1)
  local req = InstallItemPart.new()
  req:Set(Game.GetPlayer(), testItem(), part, TweakDBID.new(muzzle))
  Game.GetScriptableSystemsContainer():Get("ItemModificationSystem"):QueueRequest(req)
end

local function vanillaRemove()
  local req = RemoveItemPart.new()
  req:Set(Game.GetPlayer(), testItem(), TweakDBID.new(muzzle))
  Game.GetScriptableSystemsContainer():Get("ItemModificationSystem"):QueueRequest(req)
end

-- The stat types a record's statModifiers change, as "A, B" for PreemStatDump.
local function brakeStats(record)
  local out = {}
  for _, mod in ipairs(TweakDB:GetFlat(record .. ".statModifiers") or {}) do
    local stat = TweakDB:GetFlat(TDBID.ToStringDEBUG(mod) .. ".statType")
    if stat then table.insert(out, (string.gsub(TDBID.ToStringDEBUG(stat), "^BaseStats%.", ""))) end
  end
  print("[PreemSilencerE2e] " .. record .. " stats: " .. table.concat(out, ", "))
  return table.concat(out, ", ")
end

local plan = {
  { 0, function()
      Game.PreemSoundWatch(watch)
      held[brakeA] = stockOf(brakeA)
      held[brakeB] = stockOf(brakeB)
      print(string.format("[PreemSilencerE2e] save holds %d %s, %d %s", held[brakeA], brakeA, held[brakeB], brakeB))
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
  { 52, function()
      Game.PreemCraftTest("Items.Preset_Ajax_Default", "")
      vanillaInstall(brakeA)
    end },
  { 55, function()
      Game.PreemExpectTest("4 brake installed", "", "", "", "PowerModule=" .. brakeA)
      expectBrakes("4 brake used up", brakeA, 0)
      Game.PreemStatDump(brakeStats(brakeA))
    end },
  { 55, fire("4 plain brake") },
  { 64, function()
      Game.PreemCraftTest("Items.Preset_Ajax_Default", "")
      vanillaInstall(brakeA)
    end },
  { 67, function() Game.PreemApplyTest("Barrel_Silencer") end },
  { 70, function()
      Game.PreemExpectTest("5 brake + Silencer", "", "", "", "PreemBarrelMod01=Barrel_Silencer, PowerModule=Items.PreemSilenced_w_muzzle_brake_01")
      expectBrakes("5 brake used up", brakeA, 0)
      Game.PreemExpectStock("5 no twin left", "Items.PreemSilenced_w_muzzle_brake_01", 0)
      Game.PreemStatDump(brakeStats(brakeA))
    end },
  { 70, fire("5 brake twin") },
  { 79, function() Game.PreemApplyTest("Barrel_Recoil") end },
  { 82, function()
      Game.PreemExpectTest("6 Silencer off, brake back", "", "", "", "PreemBarrelMod01=Barrel_Recoil, PowerModule=" .. brakeA)
      expectBrakes("6 brake not duplicated", brakeA, 0)
      Game.PreemExpectStock("6 twin deleted", "Items.PreemSilenced_w_muzzle_brake_01", 0)
    end },
  { 83, function() Game.PreemCraftTest("Items.Preset_Ajax_Default", "Barrel_Silencer") end },
  { 86, function() vanillaInstall(brakeB) end },
  { 88, function()
      Game.PreemExpectTest("7 vanilla brake on a Silencer gun", "", "", "", "PreemBarrelMod01=Barrel_Silencer, PowerModule=Items.PreemSilenced_w_muzzle_brake_06")
      expectBrakes("7 brake used up", brakeB, 0)
      Game.PreemExpectStock("7 hidden part deleted", part, 0)
      Game.PreemExpectStock("7 no twin left", "Items.PreemSilenced_w_muzzle_brake_06", 0)
    end },
  { 88, fire("7 vanilla brake twin") },
  { 97, function() vanillaRemove() end },
  { 99, function()
      Game.PreemExpectTest("8 vanilla removal", "", "", "", "PreemBarrelMod01=Barrel_Silencer")
      expectBrakes("8 plain brake given back", brakeB, 1)
      Game.PreemExpectStock("8 twin deleted", "Items.PreemSilenced_w_muzzle_brake_06", 0)
      report("8 after vanilla removal")
    end },
  { 101, function()
      local ts = Game.GetTransactionSystem()
      ts:GiveItem(Game.GetPlayer(), ItemID.FromTDBID(TweakDBID.new("Items.PreemSilenced_w_muzzle_brake_06")), 1)
      ts:GiveItem(Game.GetPlayer(), ItemID.FromTDBID(TweakDBID.new(part)), 1)
      Game.PreemTakeBackStrayTest()
    end },
  { 102, function()
      expectBrakes("9 stray twin swapped for its brake", brakeB, 2)
      Game.PreemExpectStock("9 stray twin gone", "Items.PreemSilenced_w_muzzle_brake_06", 0)
      Game.PreemExpectStock("9 stray hidden part gone", part, 0)
    end },
  { 103, function() Game.PreemSoundSummary() end },
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
