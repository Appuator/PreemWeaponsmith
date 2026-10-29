-- Dev only. Checks what the stats behind some mod tooltips mean in the game (2026-10-29 tooltip
-- pass). Run in a loaded save:
--   pwsh tools/boot-check.ps1 -LoadSave -Run dev/cet/mod-stat-check.lua -HoldSec 200
-- Writes mod-stat-check.txt in this mod's folder:
--   1. TweakDB: every stat modifier on the stats in `scanStats` (vanilla values and the formulas
--      that read them as refStat), and a Katana light attack's staminaCost modifiers.
--   2. Live: crafts each weapon in `runs`, equips it and calls Game.PreemStatDump (its lines go to
--      CET's game log as "[PreemDev] stat ...").
local outFile = "mod-stat-check.txt"
local scanStats = {
  "KatanaStaminaCostReduction", "StaminaCostReduction", "CritChanceBonus", "CritDamageBonus",
  "SmartGunHipMaxLockedTargets", "SmartGunAdsMaxLockedTargets", "StealthHitDamageMultiplier",
}
local runs = {
  { record = "Items.Preset_Katana_Default", mods = "Blade_CritChance, Blade_CritDamage, Handle_StaminaReduction",
    stats = "KatanaStaminaCostReduction, StaminaCostReduction, CritChanceBonus, CritChance, CritDamageBonus, CritDamage" },
  { record = "Items.Preset_Katana_Default", mods = "",
    stats = "KatanaStaminaCostReduction, StaminaCostReduction, CritChanceBonus, CritChance, CritDamageBonus, CritDamage" },
  { record = "Items.Preset_Lexington_Default", mods = "Trigger_Burst, Barrel_Silencer",
    stats = "NumShotsInBurst, CycleTime_Burst, StealthHitDamageMultiplier, DamagePerHit, CanSilentKill" },
  { record = "Items.Preset_Lexington_Default", mods = "",
    stats = "NumShotsInBurst, CycleTime_Burst, StealthHitDamageMultiplier, DamagePerHit, CanSilentKill" },
}

local lines = {}
local function out(fmt, ...) table.insert(lines, string.format(fmt, ...)) end
local function save()
  local f = io.open(outFile, "w")
  f:write(table.concat(lines, "\n") .. "\n")
  f:close()
end

local function name(v)
  if v == nil then return "nil" end
  local ok, s = pcall(function() return TDBID.ToStringDEBUG(v:GetID()) end)
  return ok and s or tostring(v)
end
local function cname(c)
  if c == nil then return "" end
  if type(c) == "string" then return c end
  return c.value or Game.NameToString(c)
end

local function describe(rec)
  local s = string.format("%s stat=%s mod=%s", name(rec), name(rec:StatType()), cname(rec:ModifierType()))
  local ok, v = pcall(function() return rec:Value() end)
  if ok and v ~= nil then s = s .. string.format(" value=%.6g", v) end
  local okRef, ref = pcall(function() return rec:RefStat() end)
  if okRef and ref ~= nil then
    s = s .. string.format(" op=%s ref=%s obj=%s", cname(rec:OpSymbol()), name(ref), cname(rec:RefObject()))
  end
  return s
end

local function scan()
  local wanted = {}
  for _, s in ipairs(scanStats) do wanted["BaseStats." .. s] = true end
  for _, cls in ipairs({ "gamedataConstantStatModifier_Record", "gamedataCombinedStatModifier_Record",
                         "gamedataCurveStatModifier_Record" }) do
    for _, rec in ipairs(TweakDB:GetRecords(cls) or {}) do
      local okS, st = pcall(function() return name(rec:StatType()) end)
      local okR, ref = pcall(function() return name(rec:RefStat()) end)
      if (okS and wanted[st]) or (okR and wanted[ref]) then out("scan %s", describe(rec)) end
    end
  end
  -- A Katana light attack's stamina cost, to see whether it reads the stamina reduction stats.
  local attack = TweakDB:GetRecord("Attacks.Katana_Light_Attack_01") or TweakDB:GetRecord("Attacks.Katana_Combo_Attack_01")
  if attack then
    local okL, mods = pcall(function() return attack:StaminaCost() end)
    for _, m in ipairs(okL and mods or {}) do out("katana-attack %s", describe(m)) end
  else
    out("katana-attack: no Katana attack record found")
  end
  out("-- scan done")
  save()
end

local steps = { { at = 0, run = scan } }
for i, r in ipairs(runs) do
  local t = (i - 1) * 40
  table.insert(steps, { at = t + 1, run = function()
    print(string.format("[PreemDev] mod-stat-check run %d: %s [%s]", i, r.record, r.mods))
    Game.PreemCraftTest(r.record, r.mods)
  end })
  table.insert(steps, { at = t + 4, run = function() Game.PreemEquipTest() end })
  table.insert(steps, { at = t + 5, run = function() Game.PreemStatDump(r.stats) end })
end

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
    if not ok then out("step %d error: %s", nextStep, tostring(err)); save() end
    nextStep = nextStep + 1
  end
end)
