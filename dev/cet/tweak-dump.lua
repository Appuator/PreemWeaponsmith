-- Dev only. Dumps every flat of every Items.Preem* and AttachmentSlots.Preem* TweakDB record
-- (inline stat records are Items.Preem*_inlineN, so they are included) to tweak-dump.txt in this
-- mod's folder, one "<record>.<flat> = <value>" line each, sorted. Run at the main menu:
--   pwsh tools/tweak-dump.ps1            (boots, then compares with dev/baseline/tweak-dump.txt)
-- Record types come from Codeware reflection (every class derived from gamedataTweakDBRecord);
-- a record's flats are its getters with no parameters, the flat name being the getter name with
-- a lower-case first letter (or the getter name itself, as in OnAttach); a list of record
-- references only has GetXCount() and friends, so GetXCount stands for flat x; a foreign key's extra
-- XHandle getter is skipped. Resource references are written as their hash. A getter with no flat
-- under either name is written as "<no flat>". The last line, "-- end: ...", says the dump is
-- complete; the file is written in one go after it is sorted.
local outFile = "tweak-dump.txt"
local prefixes = { "Items.Preem", "AttachmentSlots.Preem" }
local baseRecord = "gamedataTweakDBRecord"
local done = false

local function cnameText(c)
  if c == nil then return "" end
  if type(c) == "string" then return c end
  return c.value or Game.NameToString(c)
end

local function isPreem(name)
  for _, p in ipairs(prefixes) do
    if name:sub(1, #p) == p then return true end
  end
  return false
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

-- Every record class, the base included (GetDerivedClasses may list direct children only).
local function recordClasses()
  local seen, list, queue = {}, {}, { baseRecord }
  while #queue > 0 do
    local name = table.remove(queue)
    if not seen[name] then
      seen[name] = true
      table.insert(list, name)
      for _, c in ipairs(Reflection.GetDerivedClasses(name) or {}) do
        table.insert(queue, cnameText(c:GetName()))
      end
    end
  end
  return list
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
  local lines, records, flats, seen = {}, 0, 0, {}
  for _, className in ipairs(recordClasses()) do
    for _, rec in ipairs(TweakDB:GetRecords(className) or {}) do
      local name = TDBID.ToStringDEBUG(rec:GetID())
      if isPreem(name) and not seen[name] then
        seen[name] = true
        records = records + 1
        flats = flats + dumpRecord(lines, name, cnameText(rec:GetClassName()))
      end
    end
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
    print("[PreemDev] tweak dump " .. result[#result])
  else
    f:write("-- error: ", tostring(result), "\n")
    print("[PreemDev] tweak dump error: " .. tostring(result))
  end
  f:close()
end)
