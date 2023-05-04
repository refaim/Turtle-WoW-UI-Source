local continents = { 'Kalimdor', 'Eastern Kingdoms' }
continentsLength = table.getn(continents);

function Set(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local dungeonEntranceMaps = Set {
  'Gates of Ahn\'Qiraj', 'Blackrock Mountain', 'Gnomeregan',
  'Scarlet Monastery', 'The Deadmines', 'Uldaman', 'Maraudon',
  'Wailing Caverns',
}

local _GetMapContinents = GetMapContinents
function GetMapContinents() return unpack(continents) end

function GetCustomMapZones(continentId)
  local continents = { _GetMapContinents() }
  local zones = { GetMapZones(continentId) }

  local filtered = {};

  if (continentId > continentsLength) then
    table.insert(filtered, continents[continentId])
  end

  for i, v in ipairs(zones) do
    if (continentId > continentsLength or not dungeonEntranceMaps[v]) then
      table.insert(filtered, v)
    end
  end
  return unpack(filtered);
end

function GetFullListZoneId()
  local id = this:GetID();
  local zones = { GetMapZones(GetCurrentMapContinent()) }

  local diff = 0;
  for i = 1, id do
    if (dungeonEntranceMaps[zones[i + diff]]) then diff = diff + 1 end
  end
  return id + diff
end

function GetListUpdateZoneId()
  local id = GetCurrentMapZone();
  local zones = { GetMapZones(GetCurrentMapContinent()) }

  if (dungeonEntranceMaps[zones[id]]) then return 0 end
  local diff = 0;
  for i = 1, id do if (dungeonEntranceMaps[zones[i]]) then diff = diff + 1 end end
  return id - diff
end
