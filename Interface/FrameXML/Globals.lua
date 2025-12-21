_G = getfenv(0)

TURTLE_WOW_VERSION = "1.18.0";

-- constants
ADDON_MSG_ARRAY_DELIMITER = ":"
ADDON_MSG_FIELD_DELIMITER = ";"
ADDON_MSG_SUBFIELD_DELIMITER = "|"

TW_CLASS_TOKEN = {
	enUS = {
		["Warrior"] = "WARRIOR",
		["Paladin"] = "PALADIN",
		["Hunter"] = "HUNTER",
		["Rogue"] = "ROGUE",
		["Priest"] = "PRIEST",
		["Shaman"] = "SHAMAN",
		["Mage"] = "MAGE",
		["Warlock"] = "WARLOCK",
		["Druid"] = "DRUID",
	},
	deDE = {
		["Krieger"] = "WARRIOR",
		["Paladin"] = "PALADIN",
		["Jäger"] = "HUNTER",
		["Schurke"] = "ROGUE",
		["Priester"] = "PRIEST",
		["Schamane"] = "SHAMAN",
		["Magier"] = "MAGE",
		["Hexenmeister"] = "WARLOCK",
		["Druide"] = "DRUID",
	},
	zhCN = {
		["战士"] = "WARRIOR",
		["圣骑士"] = "PALADIN",
		["猎人"] = "HUNTER",
		["盗贼"] = "ROGUE",
		["牧师"] = "PRIEST",
		["萨满祭司"] = "SHAMAN",
		["法师"] = "MAGE",
		["术士"] = "WARLOCK",
		["德鲁伊"] = "DRUID",
	},
	ruRU = {
		["Воин"] = "WARRIOR",
		["Паладин"] = "PALADIN",
		["Охотник"] = "HUNTER",
		["Разбойник"] = "ROGUE",
		["Жрец"] = "PRIEST",
		["Шаман"] = "SHAMAN",
		["Маг"] = "MAGE",
		["Чернокнижник"] = "WARLOCK",
		["Друид"] = "DRUID",
	},
	esES = {
		["Guerrero"] = "WARRIOR",
		["Paladín"] = "PALADIN",
		["Cazador"] = "HUNTER",
		["Pícaro"] = "ROGUE",
		["Sacerdote"] = "PRIEST",
		["Chamán"] = "SHAMAN",
		["Mago"] = "MAGE",
		["Brujo"] = "WARLOCK",
		["Druida"] = "DRUID",
	},
	ptBR = {
		["Guerreiro"] = "WARRIOR",
		["Paladino"] = "PALADIN",
		["Caçador"] = "HUNTER",
		["Ladino"] = "ROGUE",
		["Sarcedote"] = "PRIEST",
		["Xamã"] = "SHAMAN",
		["Mago"] = "MAGE",
		["Bruxo"] = "WARLOCK",
		["Druída"] = "DRUID",
	},
}

Turtle_AvailableChallenges = {
	{ name = LEVELING_CHALLENGE_SLOWSTEADY },
	{ name = LEVELING_CHALLENGE_EXHAUSTION },
	{ name = LEVELING_CHALLENGE_WARMODE },
	{ name = LEVELING_CHALLENGE_HARDCORE },
	{ name = LEVELING_CHALLENGE_VAGRANT },
	{ name = LEVELING_CHALLENGE_BOARING },
	{ name = LEVELING_CHALLENGE_LUNATIC },
	{ name = LEVELING_CHALLENGE_CRAFTMASTER },
	{ name = LEVELING_CHALLENGE_BREWMASTER },
}

GAME_YELLOW = "|cffffff00"

-- utils
function print(...)
	local size = getn(arg)
	for i = 1, size do
		arg[i] = tostring(arg[i])
	end
	local msg = size > 1 and table.concat(arg, ", ") or tostring(arg[1])
	DEFAULT_CHAT_FRAME:AddMessage(msg)
	return msg
end

function sizeof(t)
	if type(t) ~= "table" then
		return 0
	end
	local s = 0
	for i in t do
		s = s + 1
	end
	return s
end

function trim(s)
	return (string.gsub(s or "", "^%s*(.-)%s*$", "%1"))
end

function wipe(t)
	if type(t) ~= "table" then
		return
	end
	for i = table.getn(t), 1, -1 do
		table.remove(t, i)
	end
	for k in next, t do
		rawset(t, k, nil)
	end
end

local wipe = wipe

function explode(str, delimiter, t)
	wipe(t)
	local result = t or {}
	local from = 1
	local delim_from, delim_to = string.find(str, delimiter, from, true)
	while delim_from do
		table.insert(result, string.sub(str, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(str, delimiter, from, true)
	end
	table.insert(result, string.sub(str, from))
	return result
end