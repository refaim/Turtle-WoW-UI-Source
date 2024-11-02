local continents = { 'Kalimdor', 'Eastern Kingdoms' }
continentsLength = table.getn(continents);

function Set(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local hiddenMaps = Set {
  'Gates of Ahn\'Qiraj', 'Blackrock Mountain', 'Gnomeregan',
  'Scarlet Monastery', 'The Deadmines', 'Uldaman', 'Maraudon',
  'Wailing Caverns', 'Caverns of Time', 'GM Island',
}

local _GetMapContinents = GetMapContinents
function GetMapContinents() return unpack(continents) end

function GetCustomMapZones(continentId)
  local zones = { GetMapZones(continentId) }

  local filtered = {};
  for i, v in ipairs(zones) do
    if (not hiddenMaps[v]) then table.insert(filtered, v) end
  end
  return unpack(filtered);
end

function GetFullListZoneId()
  local id = this:GetID();
  local zones = { GetMapZones(GetCurrentMapContinent()) }

  local diff = 0
  for i = 1, id do
    while hiddenMaps[zones[i + diff]] do
        diff = diff + 1
    end
  end

  return id + diff
end

function GetListUpdateZoneId()
  local id = GetCurrentMapZone();
  local zones = { GetMapZones(GetCurrentMapContinent()) }

  if (hiddenMaps[zones[id]]) then return 0 end
  local diff = 0;
  for i = 1, id do if (hiddenMaps[zones[i]]) then diff = diff + 1 end end
  return id - diff
end
