local handler = CreateFrame("Frame")

local function OnVariablesLoaded()
	Turtle_ChallengesCache = Turtle_ChallengesCache or {}
	TransmogStatus = TransmogStatus or {}
	TransmogOutfits = TransmogOutfits or {}
	LFTPresets = LFTPresets or {}
	ChronoboonBuffs = ChronoboonBuffs or {}

	if not Turtle_ChallengesCache["version"] or Turtle_ChallengesCache["version"] ~= TURTLE_WOW_VERSION then
		Turtle_ChallengesCache = {}
		Turtle_ChallengesCache["version"] = TURTLE_WOW_VERSION
	end

	local realm = GetRealmName()
	if not Turtle_ChallengesCache[realm] then
		Turtle_ChallengesCache[realm] = {}
	end
end

local function OnAddonMessage(prefix, message, channel, sender)
	if prefix == "TW_CHAT_MSG_WHISPER" then
		-- Talents Inspect Communication
		if not IsAddOnLoaded("Blizzard_InspectUI") then
			LoadAddOn("Blizzard_InspectUI")
			LoadAddOn("Blizzard_TalentUI")
		end
		if strfind(message, "INSTransmogs") then
			InspectPaperDollFrame_HandleMessage(message, sender)
		elseif strfind(message, "INSTalent") then
			InspectTalentsFrame_HandleMessage(message, sender)
		elseif strfind(message, "SpellInfo") or strfind(message, "TalentInfo") then
			SpellChatLinks_HandleMessage(message, sender)
		end
	elseif arg1 == "RESPONSE_PLAYER_CHALLENGES" then
		-- Target/mouseover player challenges
		TargetFrame_HandleChallenges(message)
	else
		-- Unhandled addon message prefix
	end
end

local function HandleEvent()
	if event == "VARIABLES_LOADED" then
		OnVariablesLoaded()
	elseif event == "CHAT_MSG_ADDON" then
		OnAddonMessage(arg1, arg2, arg3, arg4)
	end
end

handler:RegisterEvent("VARIABLES_LOADED")
handler:RegisterEvent("CHAT_MSG_ADDON")
handler:SetScript("OnEvent", HandleEvent)