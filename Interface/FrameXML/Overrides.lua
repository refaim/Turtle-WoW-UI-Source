CONTINENTS_LENGTH = 2

local _GetMapContinents = GetMapContinents
function GetMapContinents()
	local kalimdor, azeroth = _GetMapContinents()
	return kalimdor, azeroth
end
