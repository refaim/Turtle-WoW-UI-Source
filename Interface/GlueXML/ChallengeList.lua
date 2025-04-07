local NUM_CHALLENGES = 8
local SELECTED_IDS = 0
local challenges = {}
challenges[1] = { selected = false, id = 1, name = HARDCORE, text = HARDCORE_TEXT, icon = "Interface\\Icons\\Ability_FiegnDead", }
challenges[2] = { selected = false, id = 2, name = SLOW_AND_STEADY, text = SLOW_AND_STEADY_TEXT, icon = "Interface\\Icons\\Spell_Nature_TimeStop", }
challenges[3] = { selected = false, id = 4, name = WAR_MODE, text = WAR_MODE_TEXT, icon = "Interface\\Icons\\Ability_DualWield", }
challenges[4] = { selected = false, id = 8, name = VAGRANT, text = VAGRANT_TEXT, icon = "Interface\\Icons\\Ability_Warrior_Disarm", }
challenges[5] = { selected = false, id = 16, name = CRAFTMASTER, text = CRAFTMASTER_TEXT, icon = "Interface\\Icons\\Ability_Repair", }
challenges[6] = { selected = false, id = 32, name = LUNATIC, text = LUNATIC_TEXT, icon = "Interface\\Icons\\inv_pet_mouse", }
challenges[7] = { selected = false, id = 64, name = BOARING, text = BOARING_TEXT, icon = "Interface\\Icons\\Spell_Magic_PolymorphPig", }
challenges[8] = { selected = false, id = 128, name = EXHAUSTION, text = EXHAUSTION_TEXT, icon = "Interface\\Icons\\Spell_Nature_Sleep", }

function ChallengeList_OnLoad()
    for i = 1, NUM_CHALLENGES do
        local entry = getglobal("ChallengeEntry"..i)
        local icon = getglobal("ChallengeEntry"..i.."Icon")
        local name = getglobal("ChallengeEntry"..i.."Name")
        icon:SetTexture(challenges[i].icon)
        name:SetText(challenges[i].name)
        entry.tooltip = challenges[i].text
    end
    for i = 1, NUM_CHALLENGES do
        getglobal("ChallengeIcon"..i.."Border"):SetVertexColor(1, 0.82, 0)
        getglobal("ChallengeIcon"..i.."Border"):Hide()
    end
    ChallengeIconsHeader.tooltip = nil
    ChallengeIconsHeaderBorder:SetVertexColor(1, 0.82, 0)
    ChallengeIconsHeaderBorder:Hide()
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
    for i = 1, NUM_CHALLENGES do
        local selected = getglobal("ChallengeEntry"..i.."Selected")
        if challenges[i].selected then
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
        if challenges[i].selected then
            icon:SetNormalTexture(challenges[i].icon)
            icon.name = challenges[i].name
            icon.tooltip = challenges[i].text
            icon:Show()
            iconIndex = iconIndex + 1
        end
    end
end

function ChallengeListScrollFrame_OnVerticalScroll()
    
end

function ChallengeListEntry_OnMouseUp()
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
	local titleHeight = ChallengesTooltipTitle:GetHeight()
	local notesHeight = ChallengesTooltipNotes:GetHeight()
	ChallengesTooltip:SetHeight(10 + titleHeight + 2 + notesHeight + 12)
end

function ChallengeList_Save()
    SELECTED_IDS = 0
    for i = 1, NUM_CHALLENGES do
        local selected = getglobal("ChallengeEntry"..i.."Selected")
        if selected:IsShown() then
            challenges[i].selected = true
            SELECTED_IDS = SELECTED_IDS + challenges[i].id
        else
            challenges[i].selected = false
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
    for i in pairs(challenges) do
        challenges[i].selected = false
    end
    ChallengeList_OnHide()
end
