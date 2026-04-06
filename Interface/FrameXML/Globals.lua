-- constants
_G = getfenv(0)

TURTLE_WOW_VERSION = "1.18.1";

ADDON_MSG_ARRAY_DELIMITER = ":"
ADDON_MSG_FIELD_DELIMITER = ";"
ADDON_MSG_SUBFIELD_DELIMITER = "|"

TW_CLASS_TOKEN = {
	-- enUS
	["Warrior"] = "WARRIOR",
	["Paladin"] = "PALADIN",
	["Hunter"] = "HUNTER",
	["Rogue"] = "ROGUE",
	["Priest"] = "PRIEST",
	["Shaman"] = "SHAMAN",
	["Mage"] = "MAGE",
	["Warlock"] = "WARLOCK",
	["Druid"] = "DRUID",
	-- deDE
	["Krieger"] = "WARRIOR",
	-- ["Paladin"] = "PALADIN",
	["Jäger"] = "HUNTER",
	["Schurke"] = "ROGUE",
	["Priester"] = "PRIEST",
	["Schamane"] = "SHAMAN",
	["Magier"] = "MAGE",
	["Hexenmeister"] = "WARLOCK",
	["Druide"] = "DRUID",
	-- zhCN
	["战士"] = "WARRIOR",
	["圣骑士"] = "PALADIN",
	["猎人"] = "HUNTER",
	["盗贼"] = "ROGUE",
	["牧师"] = "PRIEST",
	["萨满祭司"] = "SHAMAN",
	["法师"] = "MAGE",
	["术士"] = "WARLOCK",
	["德鲁伊"] = "DRUID",
	-- ruRU
	["Воин"] = "WARRIOR",
	["Паладин"] = "PALADIN",
	["Охотник"] = "HUNTER",
	["Разбойник"] = "ROGUE",
	["Жрец"] = "PRIEST",
	["Шаман"] = "SHAMAN",
	["Маг"] = "MAGE",
	["Чернокнижник"] = "WARLOCK",
	["Друид"] = "DRUID",
	-- esES
	["Guerrero"] = "WARRIOR",
	["Paladín"] = "PALADIN",
	["Cazador"] = "HUNTER",
	["Pícaro"] = "ROGUE",
	["Sacerdote"] = "PRIEST",
	["Chamán"] = "SHAMAN",
	["Mago"] = "MAGE",
	["Brujo"] = "WARLOCK",
	["Druida"] = "DRUID",
	-- ptBR
	["Guerreiro"] = "WARRIOR",
	["Paladino"] = "PALADIN",
	["Caçador"] = "HUNTER",
	["Ladino"] = "ROGUE",
	["Sarcedote"] = "PRIEST",
	["Xamã"] = "SHAMAN",
	-- ["Mago"] = "MAGE",
	["Bruxo"] = "WARLOCK",
	["Druída"] = "DRUID",
}

Turtle_AvailableChallenges = {
	LEVELING_CHALLENGE_SLOWSTEADY,
	LEVELING_CHALLENGE_EXHAUSTION,
	LEVELING_CHALLENGE_WARMODE,
	LEVELING_CHALLENGE_HARDCORE,
	LEVELING_CHALLENGE_VAGRANT,
	LEVELING_CHALLENGE_BOARING,
	LEVELING_CHALLENGE_LUNATIC,
	LEVELING_CHALLENGE_CRAFTMASTER,
	LEVELING_CHALLENGE_BREWMASTER,
	LEVELING_CHALLENGE_HEROIC,
}

GAME_YELLOW = "|cffffff00"

-- utils
local getn = table.getn
local concat = table.concat
local tinsert = table.insert
local tremove = table.remove
local rawset = rawset
local strfind = string.find
local strsub = string.sub
local gsub = string.gsub
local tostring = tostring
local type = type

function print(...)
	for i = 1, arg.n do
		arg[i] = tostring(arg[i])
	end
	local msg = concat(arg, ", ")
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(msg)
	end
	return msg
end

function sizeof(t)
	if type(t) ~= "table" then
		return 0
	end
	local s = 0
	for i in pairs(t) do
		s = s + 1
	end
	return s
end

function trim(s)
	return (gsub(s or "", "^%s*(.-)%s*$", "%1"))
end

function wipe(t)
	if type(t) ~= "table" then
		return {}
	end
	for i = getn(t), 1, -1 do
		tremove(t, i)
	end
	for k in pairs(t) do
		rawset(t, k, nil)
	end
	return t
end

local wipe = wipe

function explode(str, delimiter, t)
	local result = wipe(t)
	local from = 1
	local delim_from, delim_to = strfind(str, delimiter, from, true)
	while delim_from do
		tinsert(result, strsub(str, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = strfind(str, delimiter, from, true)
	end
	tinsert(result, strsub(str, from))
	return result
end
