_G = getfenv(0)

TURTLE_WOW_VERSION = "1.18.0";

-- constants
ADDON_MSG_ARRAY_DELIMITER = ":"
ADDON_MSG_FIELD_DELIMITER = ";"
ADDON_MSG_SUBFIELD_DELIMITER = "|"

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