local Challenges = {}
Challenges[1] = { selected = false, id = 1, name = CHALLENGE_HARDCORE, text = CHALLENGE_HARDCORE_TEXT, icon = "Interface\\Icons\\Ability_FiegnDead", }
Challenges[2] = { selected = false, id = 2, name = CHALLENGE_SLOW_AND_STEADY, text = CHALLENGE_SLOW_AND_STEADY_TEXT, icon = "Interface\\Icons\\Spell_Nature_TimeStop", }
-- Challenges[3] = { selected = false, id = 4, name = CHALLENGE_WAR_MODE, text = CHALLENGE_WAR_MODE_TEXT, icon = "Interface\\Icons\\Ability_DualWield", }
Challenges[3] = { selected = false, id = 8, name = CHALLENGE_VAGRANT, text = CHALLENGE_VAGRANT_TEXT, icon = "Interface\\Icons\\Ability_Warrior_Disarm", }
Challenges[4] = { selected = false, id = 16, name = CHALLENGE_CRAFTMASTER, text = CHALLENGE_CRAFTMASTER_TEXT, icon = "Interface\\Icons\\Ability_Repair", }
Challenges[5] = { selected = false, id = 32, name = CHALLENGE_LUNATIC, text = CHALLENGE_LUNATIC_TEXT, icon = "Interface\\Icons\\inv_pet_mouse", }
Challenges[6] = { selected = false, id = 64, name = CHALLENGE_BOARING, text = CHALLENGE_BOARING_TEXT, icon = "Interface\\Icons\\Spell_Magic_PolymorphPig", }
Challenges[7] = { selected = false, id = 128, name = CHALLENGE_EXHAUSTION, text = CHALLENGE_EXHAUSTION_TEXT, icon = "Interface\\Icons\\Spell_Nature_Sleep", }
Challenges[8] = { selected = false, id = 256, name = CHALLENGE_BREWMASTER, text = CHALLENGE_BREWMASTER_TEXT, icon = "Interface\\Icons\\INV_Cask_03", }

local NUM_CHALLENGES = getn(Challenges)
local SELECTED_IDS = 0

function ChallengeList_OnLoad()
	for i = 1, NUM_CHALLENGES do
		local entry = CreateFrame("Frame", "ChallengeEntry"..i, ChallengeListScrollFrameScrollChildFrame, "ChallengeEntryTemplate")
		if i == 1 then
			entry:SetPoint("TOPLEFT", ChallengesText, "BOTTOMLEFT", -6, -5)
		elseif i == ceil(NUM_CHALLENGES / 2) + 1 then
			entry:SetPoint("TOPLEFT", ChallengeEntry1, "TOPRIGHT", 0, 0)
		else
			entry:SetPoint("TOP", "ChallengeEntry"..(i-1), "BOTTOM", 0, 0)
		end
		entry:SetID(i)
		local icon = getglobal("ChallengeEntry"..i.."Icon")
		local name = getglobal("ChallengeEntry"..i.."Name")
		icon:SetTexture(Challenges[i].icon)
		name:SetText(Challenges[i].name)
		entry.tooltip = Challenges[i].text
	end
	for i = 1, NUM_CHALLENGES do
		local icon = CreateFrame("Button", "ChallengeIcon"..i, CharacterCreateFrame, "ChallengeIconTemplate")
		icon:SetPoint("TOP", i == 1 and "ChallengeIconsHeader" or "ChallengeIcon"..(i-1), "BOTTOM", 0, -5)
	end
end

function ChallengeList_OnKeyDown()
	if arg1 == "PRINTSCREEN" then
		Screenshot()
	elseif arg1 == "ESCAPE" then
		ChallengeList_Reset()
		ChallengeList:Hide()
	elseif arg1 == "ENTER" then
		ChallengeList_Save()
		ChallengeList:Hide()
	end
end

function ChallengeList_Update()
	local serverName, isPVP, isRP = GetServerName()
	ChallengeList.isPVP = isPVP
	for i = 1, NUM_CHALLENGES do
		local selected = getglobal("ChallengeEntry"..i.."Selected")
		if Challenges[i].selected then
			selected:Show()
		else
			selected:Hide()
		end
	end
end

function ChallengeList_OnHide()
	-- Update icons
	local iconIndex = 1
	for i = 1, NUM_CHALLENGES do
		getglobal("ChallengeIcon"..i):Hide()
	end
	for i = 1, NUM_CHALLENGES do
		local icon = getglobal("ChallengeIcon"..iconIndex)
		if Challenges[i].selected then
			icon:SetNormalTexture(Challenges[i].icon)
			icon.name = Challenges[i].name
			icon.tooltip = Challenges[i].text
			icon:Show()
			iconIndex = iconIndex + 1
		end
	end
end

function ChallengeListEntry_OnMouseUp()
	if ChallengeList.isPVP and getglobal(this:GetName().."Name"):GetText() == CHALLENGE_WAR_MODE then
		return
	end
	local selected = getglobal(this:GetName().."Selected")
	if selected:IsShown() then
		selected:Hide()
	else
		selected:Show()
	end
end

function ChallengeList_OnOk()
	ChallengeList_Save()
	ChallengeList:Hide()
	PlaySound("gsLoginChangeRealmOK")
end

function ChallengeList_OnCancel()
	ChallengeList_Reset()
	ChallengeList:Hide()
	PlaySound("gsLoginChangeRealmCancel")
end

function ChallengesTooltip_Update(title, text)
	ChallengesTooltipTitle:SetText(title)
	ChallengesTooltipNotes:SetText(text)
	if title == CHALLENGE_WAR_MODE and ChallengeList.isPVP then
		ChallengesTooltipNotes:SetText(text.."\n\n|cffFF0000"..CHALLENGES_RESTRICTED)
	end
	local titleHeight = ChallengesTooltipTitle:GetHeight()
	local notesHeight = ChallengesTooltipNotes:GetHeight()
	ChallengesTooltip:SetHeight(10 + titleHeight + 2 + notesHeight + 12)
end

function ChallengeList_Save()
	SELECTED_IDS = 0
	for i = 1, NUM_CHALLENGES do
		local selected = getglobal("ChallengeEntry"..i.."Selected")
		if selected:IsShown() then
			Challenges[i].selected = true
			SELECTED_IDS = SELECTED_IDS + Challenges[i].id
		else
			Challenges[i].selected = false
		end
	end
	SetSelectedChallengeModes(SELECTED_IDS)
end

function ChallengeList_Reset()
	SELECTED_IDS = GetSelectedChallengeModes()
end

local CharacterCreate_OnShow_Original = CharacterCreate_OnShow
function CharacterCreate_OnShow()
	CharacterCreate_OnShow_Original()
	SELECTED_IDS = 0
	SetSelectedChallengeModes(0)
	for i in pairs(Challenges) do
		Challenges[i].selected = false
	end
	ChallengeList_OnHide()
end