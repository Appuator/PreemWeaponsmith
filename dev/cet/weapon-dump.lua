-- Dev only. Dumps every flat of every WeaponItem TweakDB record (vanilla weapons, the Preem
-- evolution variants <base>_Preem<Evolution>, and EnhancedCraft's when installed) to
-- weapon-dump.txt in this mod's folder, one "<record>.<flat> = <value>" line each, sorted; about
-- 70 MB. Run at the main menu:
--   pwsh tools/variant-markers.ps1        (boots, then compares each variant with vanilla weapons)
-- Same flat walk as tweak-dump.lua (see its header): getters from Codeware reflection, list getters
-- via GetXCount, resource references as their hash, "<no flat>" for a getter with no flat, and a
-- last line "-- end: ..." once the dump is complete.
local outFile = "weapon-dump.txt"
local weaponRecord = "gamedataWeaponItem_Record"
local baseRecord = "gamedataTweakDBRecord"
local done = false

local function cnameText(c)
  if c == nil then return "" end
  if type(c) == "string" then return c end
  return c.value or Game.NameToString(c)
end

local function fmt(v)
  local t = type(v)
  if t == "number" then return string.format("%.9g", v) end
  if t == "boolean" then return tostring(v) end
  if t == "string" then return string.format("%q", v) end
  if t == "table" then
    local parts = {}
    for i, x in ipairs(v) do parts[i] = fmt(x) end
    return "[" .. table.concat(parts, ", ") .. "]"
  end
  local s = tostring(v)
  if s:find("^ToTweakDBID") then return "t\"" .. TDBID.ToStringDEBUG(v) .. "\"" end
  if s:find("^ToCName") then return "n\"" .. cnameText(v) .. "\"" end
  -- Resource references print as an address; their path hash is stable.
  if s:find("^userdata") then
    local ok, hash = pcall(function() return v.hash end)
    if ok and hash ~= nil then return "r\"" .. tostring(hash) .. "\"" end
    return "<userdata>"
  end
  return s
end

-- Getter names of a record class and its parents, up to the base record class.
local getterCache = {}
local function getters(className)
  if getterCache[className] then return getterCache[className] end
  local names, seen = {}, {}
  local c = Reflection.GetClass(className)
  while c and cnameText(c:GetName()) ~= baseRecord do
    for _, f in ipairs(c:GetFunctions() or {}) do
      local n = cnameText(f:GetName())
      if #(f:GetParameters() or {}) == 0 and f:GetReturnType() ~= nil then
        -- A list of record references X has no plain getter, only X(out list), GetXCount()
        -- and GetXItem(i); its flat is x.
        if n:sub(1, 3) == "Get" and n:sub(-5) == "Count" and #n > 8 then n = n:sub(4, -6)
        elseif n:sub(1, 3) == "Get" then n = nil end
        if n and not seen[n] then
          seen[n] = true
          table.insert(names, n)
        end
      end
    end
    c = c:GetParent()
  end
  -- A foreign key X also has an XHandle getter returning the record; it has no flat of its own.
  local flatNames = {}
  for _, n in ipairs(names) do
    if not (n:sub(-6) == "Handle" and seen[n:sub(1, -7)]) then table.insert(flatNames, n) end
  end
  getterCache[className] = flatNames
  return flatNames
end

local function dumpRecord(lines, name, className)
  table.insert(lines, name .. ".$type = " .. className)
  local flats = 0
  for _, g in ipairs(getters(className)) do
    local lower = g:sub(1, 1):lower() .. g:sub(2)
    local field, value = lower, TweakDB:GetFlat(name .. "." .. lower)
    if value == nil and lower ~= g then field, value = g, TweakDB:GetFlat(name .. "." .. g) end
    if value == nil then
      table.insert(lines, name .. "." .. lower .. " = <no flat>")
    else
      table.insert(lines, name .. "." .. field .. " = " .. fmt(value))
      flats = flats + 1
    end
  end
  return flats
end

local function dump()
  local lines, records, flats = {}, 0, 0
  for _, rec in ipairs(TweakDB:GetRecords(weaponRecord) or {}) do
    records = records + 1
    flats = flats + dumpRecord(lines, TDBID.ToStringDEBUG(rec:GetID()), cnameText(rec:GetClassName()))
  end
  table.sort(lines)
  table.insert(lines, string.format("-- end: %d records, %d flats", records, flats))
  return lines
end

registerForEvent("onUpdate", function()
  if done or not Game.GetPlayer() then return end
  done = true
  local ok, result = pcall(dump)
  local f = io.open(outFile, "w")
  if not f then return end
  if ok then
    f:write(table.concat(result, "\n"), "\n")
    print("[PreemDev] weapon dump " .. result[#result])
  else
    f:write("-- error: ", tostring(result), "\n")
    print("[PreemDev] weapon dump error: " .. tostring(result))
  end
  f:close()
end)
