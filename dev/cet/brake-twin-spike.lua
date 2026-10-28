-- Dev only, spike (gate feedback 2026-10-28): can a muzzle brake count as a silencer?
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/brake-twin-spike.lua -HoldSec 90
-- Lists every part that fits the muzzle slot (tags, item type), picks a brake (no Silenced tag),
-- then on fresh Ajaxes (parts moved before equipping) puts in the muzzle slot:
--   A the plain brake (control: expect IsSilenced false, plain shot)
--   B a clone of the brake with the Silenced tag added
--   C the hidden muzzle part (control: expect IsSilenced true, suppressed shot)
--   D a clone of the hidden part carrying the brake's stats and appearance
-- Lines go to scripting.log as "[PreemBrakeSpike]"; shots to gamelog.log via the sound listener.
local muzzle = "AttachmentSlots.PowerModule"
local watch = "w_gun_rifle_power_ajax_fire_single, w_gun_rifle_power_ajax_fire_suppressor_single"
local brake = nil

local function log(fmt, ...) print("[PreemBrakeSpike] " .. string.format(fmt, ...)) end

local function names(list)
  local out = {}
  for _, v in ipairs(list or {}) do table.insert(out, Game.NameToString(v)) end
  return table.concat(out, " ")
end

local function discover()
  local count = 0
  for _, rec in ipairs(TweakDB:GetRecords("gamedataItem_Record")) do
    local id = TDBID.ToStringDEBUG(rec:GetID())
    local slots = TweakDB:GetFlat(id .. ".placementSlots")
    local fits = false
    for _, s in ipairs(slots or {}) do
      if TDBID.ToStringDEBUG(s) == muzzle then fits = true end
    end
    if fits then
      count = count + 1
      local tags = names(TweakDB:GetFlat(id .. ".tags"))
      local itemType = TDBID.ToStringDEBUG(TweakDB:GetFlat(id .. ".itemType") or TweakDBID.new(""))
      log("muzzle part %s type=%s tags=[%s]", id, itemType, tags)
      if brake == nil and not string.find(tags, "Silenced") and string.find(string.lower(id), "brake") then brake = id end
    end
  end
  log("%d muzzle parts; brake for the test: %s", count, tostring(brake))
end

local function makeTwins()
  local tags = TweakDB:GetFlat(brake .. ".tags") or {}
  table.insert(tags, CName.new("Silenced"))
  log("clone B %s", tostring(TweakDB:CloneRecord("Items.PreemSpikeBrakeTwin", brake)))
  log("B tags %s", tostring(TweakDB:SetFlat("Items.PreemSpikeBrakeTwin.tags", tags)))
  TweakDB:Update("Items.PreemSpikeBrakeTwin")
  log("clone D %s", tostring(TweakDB:CloneRecord("Items.PreemSpikeHelperTwin", "Items.PreemSilencerMuzzle")))
  for _, flat in ipairs({ "statModifiers", "statModifierGroups", "appearanceName", "appearanceResourceName", "displayName", "icon" }) do
    local v = TweakDB:GetFlat(brake .. "." .. flat)
    if v ~= nil then log("D %s %s", flat, tostring(TweakDB:SetFlat("Items.PreemSpikeHelperTwin." .. flat, v))) end
  end
  TweakDB:Update("Items.PreemSpikeHelperTwin")
  log("B tags now [%s]", names(TweakDB:GetFlat("Items.PreemSpikeBrakeTwin.tags")))
end

local function putInMuzzle(label, partRecord)
  local player = Game.GetPlayer()
  local ts = Game.GetTransactionSystem()
  local weapon = Game.GetScriptableSystemsContainer():Get("PreemDev.PreemDevSystem").lastTestItem
  local part = ItemID.FromTDBID(TweakDBID.new(partRecord))
  ts:GiveItem(player, part, 1)
  log("%s: AddPart %s -> %s", label, partRecord, tostring(ts:AddPart(player, weapon, part, TweakDBID.new(muzzle))))
end

local function report(label)
  local ts = Game.GetTransactionSystem()
  local w = ts:GetItemInSlot(Game.GetPlayer(), TweakDBID.new("AttachmentSlots.WeaponRight"))
  local part = "?"
  if w then
    local data = ts:GetItemData(Game.GetPlayer(), w:GetItemID())
    if data and data:HasPartInSlot(TweakDBID.new(muzzle)) then
      for _, p in ipairs(data:GetItemParts() or {}) do
        local slot = TDBID.ToStringDEBUG(InnerItemData.GetSlotID(p))
        if slot == muzzle then part = TDBID.ToStringDEBUG(InnerItemData.GetItemID(p).id) end
      end
    else
      part = "empty"
    end
  end
  log("%s: IsSilenced=%s, muzzle=%s", label, w and tostring(w:IsSilenced()) or "no weapon", part)
end

local function case(label, partRecord)
  return {
    { 0, function() Game.PreemCraftTest("Items.Preset_Ajax_Default", "") end },
    { 2, function() putInMuzzle(label, partRecord()) end },
    { 3, function() Game.PreemEquipTest() end },
    { 5, function() Game.PreemSoundDraw() end },
    { 7, function() report(label) end },
    { 8, function() Game.PreemSoundFire("SemiAuto") end },
    { 8.4, function() Game.PreemSoundFire("SemiAuto") end },
    { 8.8, function() Game.PreemSoundFire("SemiAuto") end },
    { 9.5, function() log("%s: fired", label) end },
  }
end

local plan = {
  { 0, function()
      Game.PreemSoundWatch(watch)
      Game.AddToInventory("Ammo.RifleAmmo", 1000)
      discover()
      if brake then makeTwins() end
    end },
  { 2, case("A plain brake", function() return brake end) },
  { 14, case("B brake + Silenced tag", function() return "Items.PreemSpikeBrakeTwin" end) },
  { 26, case("C hidden part", function() return "Items.PreemSilencerMuzzle" end) },
  { 38, case("D hidden part + brake stats", function() return "Items.PreemSpikeHelperTwin" end) },
  { 50, function() Game.PreemSoundSummary() end },
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
    local ok, err = pcall(steps[nextStep].run)
    if not ok then log("step at %.1f failed: %s", steps[nextStep].at, tostring(err)) end
    nextStep = nextStep + 1
  end
end)
