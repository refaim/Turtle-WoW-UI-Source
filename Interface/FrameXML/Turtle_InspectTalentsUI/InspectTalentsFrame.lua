local TWTalent = {}
local currentTab = 1

function InspectFrameSelectTalentTree(tree)

    PanelTemplates_DeselectTab(InspectTalentsFrameToggleTab1)
    PanelTemplates_DeselectTab(InspectTalentsFrameToggleTab2)
    PanelTemplates_DeselectTab(InspectTalentsFrameToggleTab3)

    PanelTemplates_SelectTab(this)
    PanelTemplates_TabResize(0);

    getglobal(this:GetName() .. "HighlightTexture"):SetWidth(this:GetTextWidth() + 31)

    if this == InspectTalentsFrameToggleTab1 then
        currentTab = 1
    end
    if this == InspectTalentsFrameToggleTab2 then
        currentTab = 2
    end
    if this == InspectTalentsFrameToggleTab3 then
        currentTab = 3
    end

end

local __ins_find = string.find
local __ins_substr = string.sub
local __ins_tinsert = table.insert
local __ins_parseint = tonumber

function __ins_explode(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = __ins_find(str, delimiter, from, 1, true)
    while delim_from do
        __ins_tinsert(result, __ins_substr(str, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = __ins_find(str, delimiter, from, true)
    end
    __ins_tinsert(result, __ins_substr(str, from))
    return result
end

function inSend(to, data)
    SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. to .. ">", data, "GUILD")
end

local inspectCom = CreateFrame("Frame")

inspectCom.transmogs = {}

inspectCom:RegisterEvent("CHAT_MSG_ADDON")
inspectCom:RegisterEvent("PLAYER_TARGET_CHANGED")
inspectCom:SetScript("OnEvent", function()
    if event then
        if event == "CHAT_MSG_ADDON" then

            if arg1 == "TW_CHAT_MSG_WHISPER" then

                local message = arg2
                local from = arg4

                if string.find(message, "INSShowTalents", 1, true) then

                    for tree = 1, GetNumTalentTabs() do
                        local treeName, iconTexture, pointsSpent = GetTalentTabInfo(tree)
                        local numTalents = GetNumTalents(tree)

                        inSend(from, 'INSTalentTabInfo;' .. tree .. ';' .. treeName .. ';' .. pointsSpent .. ';' .. numTalents)

                        for i = 1, GetNumTalents(tree) do
                            local name, icon, tier, column, currRank, maxRank, _, meetsPrereq = GetTalentInfo(tree, i)
                            local ptier, pcolumn, isLearnable = GetTalentPrereqs(tree, i)
                            if not ptier then
                                ptier = -1
                            end
                            if not pcolumn then
                                pcolumn = -1
                            end
                            if not isLearnable then
                                isLearnable = -1
                            end

                            if not meetsPrereq then
                                meetsPrereq = 0
                            end

                            inSend(from, 'INSTalentInfo;' .. tree .. ';' .. i .. ';' ..
                                    name .. ';' .. tier .. ';' .. column .. ';' ..
                                    currRank .. ';' .. maxRank .. ';' .. meetsPrereq .. ';' ..
                                    ptier .. ';' .. pcolumn .. ';' .. isLearnable)

                        end
                    end

                    inSend(from, 'INSTalentEND;')

                    return true
                end

                if string.find(message, "INSTalentEND;", 1, true) then
                    if TWTalentFrame:IsVisible() then
                        TWTalentFrame:Hide()
                        TWTalentFrame:Show()
                    else
                        TWInspectTalents_Show()
                    end

                    return true
                end

                if string.find(message, "INSTalentTabInfo;", 1, true) then
                    local talentEx = __ins_explode(message, ';')
                    local index = __ins_parseint(talentEx[2])
                    local name = talentEx[3]
                    local pointsSpent = __ins_parseint(talentEx[4])
                    local numTalents = __ins_parseint(talentEx[5])

                    inspectCom.SPEC[index].name = name
                    inspectCom.SPEC[index].pointsSpent = pointsSpent
                    inspectCom.SPEC[index].numTalents = numTalents

                    return true
                end

                if string.find(message, "INSTalentInfo;", 1, true) then

                    local talentEx = __ins_explode(message, ';')

                    local tree = __ins_parseint(talentEx[2])
                    local i = __ins_parseint(talentEx[3])
                    local name = talentEx[4]
                    local tier = __ins_parseint(talentEx[5])
                    local column = __ins_parseint(talentEx[6])
                    local currRank = __ins_parseint(talentEx[7])
                    local maxRank = __ins_parseint(talentEx[8])
                    local meetsPrereq = talentEx[9] == '1'

                    local ptier = nil
                    local pcolumn = nil
                    local isLearnable = true --WTF??

                    if talentEx[10] ~= '-1' then
                        ptier = __ins_parseint(talentEx[10])
                    end
                    if talentEx[11] ~= '-1' then
                        pcolumn = __ins_parseint(talentEx[11])
                    end
                    --if talentEx[12] == '-1' then
                    --    isLearnable = true
                    --end

                    if not inspectCom.SPEC[tree][i] then
                        inspectCom.SPEC[tree][i] = {}
                    end

                    inspectCom.SPEC[tree][i].name = name
                    inspectCom.SPEC[tree][i].tier = tier
                    inspectCom.SPEC[tree][i].column = column
                    inspectCom.SPEC[tree][i].rank = currRank
                    inspectCom.SPEC[tree][i].maxRank = maxRank
                    inspectCom.SPEC[tree][i].meetsPrereq = meetsPrereq

                    inspectCom.SPEC[tree][i].ptier = ptier
                    inspectCom.SPEC[tree][i].pcolumn = pcolumn
                    inspectCom.SPEC[tree][i].isLearnable = isLearnable

                    return true
                end

                if string.find(message, "INSTransmogs:", 1, true) then

                    local tEx = __ins_explode(message, ':')

                    if tEx[2] == "start" then
                        inspectCom.transmogs = {}
                    elseif tEx[2] == "end" then

                    else
                        if tEx[3] then
                            inspectCom.transmogs[tEx[2]] = tEx[3]
                        end
                    end
                end

            end
        elseif event == "PLAYER_TARGET_CHANGED" then
            if InspectFrame:IsVisible() and TWTalentFrame:IsVisible() then
                InspectFrameTalentsTab_OnClick()
            end
        end

    end
end)

function TWInspectTalents_Show()
    ToggleInspect("InspectTalentsFrame");
    getglobal('TWTalentFrame'):Show()
end

inspectCom.SPEC = {}

function Ins_Init()
    inspectCom.SPEC = {
        class = UnitClass('target'),
        {
            name = 'Arms',
            iconTexture = "interface\\icons\\ability_warrior_cleave",
            pointsSpent = 27,
            numTalents = 18
        },
        {
            name = 'Fury',
            iconTexture = "interface\\icons\\ability_warrior_cleave",
            pointsSpent = 24,
            numTalents = 17
        },
        {
            name = 'Protection',
            iconTexture = "interface\\icons\\ability_warrior_cleave",
            pointsSpent = 0,
            numTalents = 17
        }
    }
end

TWTalent.TALENT_BRANCH_ARRAY = {}

function TWTalentOnClick(tab, id)

    if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
        local name = GetTalentInfo(tab, id);
        local talent = "|cFF71D5FF|Htalent:" .. tab .. ":" .. id .. ":" .. UnitName("target") .. ":|h[" .. name .. "]|h|r"
        ChatFrameEditBox:Insert(talent)
        return
    end

end

function TWTalentName(i, j)
    return inspectCom.SPEC[i][j].name
end

function TWTalentDescription(i, j)

    if not Turtle_TalentsData[inspectCom.SPEC.class .. inspectCom.SPEC[i].name] then
        return ''
    end

    for _, d in Turtle_TalentsData[inspectCom.SPEC.class .. inspectCom.SPEC[i].name] do
        if d.name == inspectCom.SPEC[i][j].name then
            return d.desc[inspectCom.SPEC[i][j].rank > 0 and inspectCom.SPEC[i][j].rank or 1]
        end
    end
    return ''
end

function TWTalentRank(i, j)
    return 'Rank ' .. inspectCom.SPEC[i][j].rank .. '/' .. inspectCom.SPEC[i][j].maxRank
end

function TWTalent.GetTalentTabInfo(i)
    local name = inspectCom.SPEC[i].name
    local iconTexture = ''
    local pointsSpent = inspectCom.SPEC[i].pointsSpent

    local spec = name

    if name == 'Affliction' then
        spec = 'Curses'
    elseif name == 'Demonology' then
        spec = 'Summoning'
    elseif name == 'Feral Combat' then
        spec = 'FeralCombat'
    elseif name == 'Beast Mastery' then
        spec = 'BeastMastery'
    elseif name == 'Retribution' then
        spec = 'Combat'
    elseif name == 'Elemental' then
        spec = 'ElementalCombat'
    end

    local fileName = inspectCom.SPEC.class .. spec

    return name, iconTexture, pointsSpent, fileName
end

function TWTalent.GetNumTalents(i)
    local num = inspectCom.SPEC[i].numTalents
    return num
end

function TWTalent.GetTalentInfo(i, j)

    local name = inspectCom.SPEC[i][j].name
    local texture = 'inv_misc_questionmark'

    if Turtle_TalentsData[inspectCom.SPEC.class .. inspectCom.SPEC[i].name] then
        for _, d in Turtle_TalentsData[inspectCom.SPEC.class .. inspectCom.SPEC[i].name] do
            if d.name == name then
                texture = d.icon
            end
        end
    end
    local iconTexture = "Interface\\Icons\\" .. texture

    local tier = inspectCom.SPEC[i][j].tier
    local column = inspectCom.SPEC[i][j].column
    local rank = inspectCom.SPEC[i][j].rank
    local maxRank = inspectCom.SPEC[i][j].maxRank
    local meetsPrereq = inspectCom.SPEC[i][j].meetsPrereq

    return name, iconTexture, tier, column, rank, maxRank, meetsPrereq

end

function TWTalent.GetTalentPrereqs(i, j)
    local tier = inspectCom.SPEC[i][j].ptier
    local column = inspectCom.SPEC[i][j].pcolumn
    local isLearnable = inspectCom.SPEC[i][j].isLearnable
    return tier, column, isLearnable
end

function TWTalentFrame_Update()
    -- Setup Tabs
    local tab, name, iconTexture, pointsSpent, button
    local numTabs = 3
    for i = 1, numTabs do
        tab = getglobal('TWTalentFrameTab' .. i)
        name, iconTexture, pointsSpent = TWTalent.GetTalentTabInfo(i)
        if i == PanelTemplates_GetSelectedTab(getglobal('TWTalentFrame')) then
            -- If tab is the selected tab set the points spent info
            getglobal('TWTalentFrame').pointsSpent = pointsSpent
        end

        tab:SetText(name)
        tab:Show()

        PanelTemplates_TabResize(-8, tab)
    end

    PanelTemplates_SetNumTabs(getglobal('TWTalentFrame'), numTabs)
    PanelTemplates_UpdateTabs(getglobal('TWTalentFrame'))

    local cp = UnitLevel('target') - 9 - inspectCom.SPEC[1].pointsSpent - inspectCom.SPEC[2].pointsSpent - inspectCom.SPEC[3].pointsSpent

    getglobal('TWTalentFrame').talentPoints = cp

    local talentTabName = TWTalent.GetTalentTabInfo(PanelTemplates_GetSelectedTab(getglobal('TWTalentFrame')))
    local base
    local name, texture, points, fileName = TWTalent.GetTalentTabInfo(PanelTemplates_GetSelectedTab(getglobal('TWTalentFrame')))
    if talentTabName then
        base = "Interface\\TalentFrame\\" .. fileName .. "-"
    else
        base = "Interface\\TalentFrame\\MageFire-"
    end

    getglobal('TWTalentFrameBackgroundTopLeft'):SetTexture(base .. "TopLeft")
    getglobal('TWTalentFrameBackgroundTopRight'):SetTexture(base .. "TopRight")
    getglobal('TWTalentFrameBackgroundBottomLeft'):SetTexture(base .. "BottomLeft")
    getglobal('TWTalentFrameBackgroundBottomRight'):SetTexture(base .. "BottomRight")

    local numTalents = TWTalent.GetNumTalents(PanelTemplates_GetSelectedTab(getglobal('TWTalentFrame')))

    if numTalents > MAX_NUM_TALENTS then
        message("Too many talents in talent frame!")
    end

    TWTalent.TalentFrame_ResetBranches()

    local tier, column, rank, maxRank, isLearnable, meetsPrereq
    local forceDesaturated, tierUnlocked
    for i = 1, MAX_NUM_TALENTS do
        button = getglobal('TWTalentFrameTalent' .. i)
        if i <= numTalents then
            -- Set the button info
            name, iconTexture, tier, column, rank, maxRank, meetsPrereq = TWTalent.GetTalentInfo(PanelTemplates_GetSelectedTab(getglobal('TWTalentFrame')), i)
            getglobal('TWTalentFrameTalent' .. i .. 'Rank'):SetText(rank)
            SetTalentButtonLocation(button, tier, column)
            TWTalent.TALENT_BRANCH_ARRAY[tier][column].id = button:GetID()

            -- If player has no talent points then show only talents with points in them
            if getglobal('TWTalentFrame').talentPoints <= 0 and rank == 0 then
                forceDesaturated = 1
            else
                forceDesaturated = nil
            end

            -- If the player has spent at least 5 talent points in the previous tier
            if ((tier - 1) * 5) <= getglobal('TWTalentFrame').pointsSpent then
                tierUnlocked = 1
            else
                tierUnlocked = nil
            end

            SetItemButtonTexture(button, iconTexture)

            -- Talent must meet prereqs or the player must have no points to spend
            local a5, a6, a7 = TWTalent.GetTalentPrereqs(PanelTemplates_GetSelectedTab(getglobal('TWTalentFrame')), i)
            if TWTalent.TalentFrame_SetPrereqs(tier, column, forceDesaturated, tierUnlocked, a5, a6, a7) and meetsPrereq then

                SetItemButtonDesaturated(button, nil)

                if rank < maxRank then
                    -- Rank is green if not maxed out
                    --_G['TWTalentFrameTalent' .. i .. 'Slot']:SetVertexColor(0.1, 1.0, 0.1)
                    --_G['TWTalentFrameTalent' .. i .. 'Rank']:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                    getglobal('TWTalentFrameTalent' .. i .. 'Slot'):SetVertexColor(1.0, 0.82, 0)
                    getglobal('TWTalentFrameTalent' .. i .. 'Rank'):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
                else
                    getglobal('TWTalentFrameTalent' .. i .. 'Slot'):SetVertexColor(1.0, 0.82, 0)
                    getglobal('TWTalentFrameTalent' .. i .. 'Rank'):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
                end
                getglobal('TWTalentFrameTalent' .. i .. 'RankBorder'):Show()
                getglobal('TWTalentFrameTalent' .. i .. 'Rank'):Show()
            else
                SetItemButtonDesaturated(button, 1, 0.65, 0.65, 0.65)
                getglobal("TWTalentFrameTalent" .. i .. "Slot"):SetVertexColor(0.5, 0.5, 0.5)
                if rank == 0 then
                    getglobal("TWTalentFrameTalent" .. i .. "RankBorder"):Hide()
                    getglobal("TWTalentFrameTalent" .. i .. "Rank"):Hide()
                else
                    getglobal("TWTalentFrameTalent" .. i .. "RankBorder"):SetVertexColor(0.5, 0.5, 0.5)
                    getglobal("TWTalentFrameTalent" .. i .. "Rank"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
                end
            end

            button:Show()
        else
            button:Hide()
        end
    end


    -- Draw the prerq branches
    local node
    local textureIndex = 1
    local xOffset, yOffset
    local texCoords
    -- Variable that decides whether or not to ignore drawing pieces
    local ignoreUp
    local tempNode

    getglobal('TWTalentFrame').textureIndex = 1

    getglobal('TWTalentFrame').arrowIndex = 1

    for i = 1, MAX_NUM_TALENT_TIERS do
        --8
        for j = 1, NUM_TALENT_COLUMNS do
            --4

            node = TWTalent.TALENT_BRANCH_ARRAY[i][j]

            -- Setup offsets
            xOffset = ((j - 1) * 63) + INITIAL_TALENT_OFFSET_X + 2
            yOffset = -((i - 1) * 63) - INITIAL_TALENT_OFFSET_Y - 2

            if node.id then
                -- Has talent
                if node.up ~= 0 then
                    if not ignoreUp then
                        TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset, yOffset + TALENT_BUTTON_SIZE)
                    else
                        ignoreUp = nil
                    end
                end
                if node.down ~= 0 then
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset, yOffset - TALENT_BUTTON_SIZE + 1)
                end
                if node.left ~= 0 then
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset - TALENT_BUTTON_SIZE, yOffset)
                end
                if node.right ~= 0 then
                    -- See if any connecting branches are gray and if so color them gray
                    tempNode = TWTalent.TALENT_BRANCH_ARRAY[i][j + 1]
                    if tempNode.left ~= 0 and tempNode.down < 0 then
                        TWTalent.TalentFrame_SetBranchTexture(i, j - 1, TALENT_BRANCH_TEXTURECOORDS["right"][tempNode.down], xOffset + TALENT_BUTTON_SIZE, yOffset)
                    else
                        TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + TALENT_BUTTON_SIZE + 1, yOffset)
                    end

                end
                -- Draw arrows
                if node.rightArrow ~= 0 then
                    TWTalent.TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["right"][node.rightArrow], xOffset + TALENT_BUTTON_SIZE / 2 + 5, yOffset)
                end
                if node.leftArrow ~= 0 then
                    TWTalent.TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["left"][node.leftArrow], xOffset - TALENT_BUTTON_SIZE / 2 - 5, yOffset)
                end
                if node.topArrow ~= 0 then
                    TWTalent.TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["top"][node.topArrow], xOffset, yOffset + TALENT_BUTTON_SIZE / 2 + 5)
                end
            else
                -- Doesn't have a talent
                if node.up ~= 0 and node.left ~= 0 and node.right ~= 0 then
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["tup"][node.up], xOffset, yOffset)
                elseif node.down ~= 0 and node.left ~= 0 and node.right ~= 0 then
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["tdown"][node.down], xOffset, yOffset)
                elseif node.left ~= 0 and node.down ~= 0 then
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["topright"][node.left], xOffset, yOffset)
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset, yOffset - 32)
                elseif node.left ~= 0 and node.up ~= 0 then
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["bottomright"][node.left], xOffset, yOffset)
                elseif node.left ~= 0 and node.right ~= 0 then
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + TALENT_BUTTON_SIZE, yOffset)
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset + 1, yOffset)
                elseif node.right ~= 0 and node.down ~= 0 then
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["topleft"][node.right], xOffset, yOffset)
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset, yOffset - 32)
                elseif node.right ~= 0 and node.up ~= 0 then
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["bottomleft"][node.right], xOffset, yOffset)
                elseif node.up ~= 0 and node.down ~= 0 then
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset, yOffset)
                    TWTalent.TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset, yOffset - 32)
                    ignoreUp = 1
                end
            end
        end
        getglobal('TWTalentFrameScrollFrame'):UpdateScrollChildRect()
    end
    -- Hide any unused branch textures
    for i = getglobal('TWTalentFrame').textureIndex, MAX_NUM_BRANCH_TEXTURES do
        getglobal("TWTalentFrameBranch" .. i):Hide()
    end
    -- Hide and unused arrow textures
    for i = getglobal('TWTalentFrame').arrowIndex, MAX_NUM_ARROW_TEXTURES do
        getglobal("TWTalentFrameArrow" .. i):Hide()
    end
end

function TWTalentFrame_OnShow()

    PanelTemplates_SetNumTabs(getglobal('TWTalentFrame'), 3)
    PanelTemplates_SetTab(getglobal('TWTalentFrame'), 1)

    for i = 1, MAX_NUM_TALENT_TIERS do
        TWTalent.TALENT_BRANCH_ARRAY[i] = {}
        for j = 1, NUM_TALENT_COLUMNS do
            TWTalent.TALENT_BRANCH_ARRAY[i][j] = { id = nil, up = 0, left = 0, right = 0, down = 0, leftArrow = 0, rightArrow = 0, topArrow = 0 }
        end
    end

    PlaySound("TalentScreenOpen")
    TWTalentFrame_Update()
    getglobal('TWTalentFrameScrollFrame'):UpdateScrollChildRect()
end

function TWTalentFrame_OnHide()
    PlaySound("TalentScreenClose")
end

function TWTalent.TalentFrame_ResetBranches()
    for i = 1, MAX_NUM_TALENT_TIERS do
        for j = 1, NUM_TALENT_COLUMNS do
            TWTalent.TALENT_BRANCH_ARRAY[i][j].id = nil
            TWTalent.TALENT_BRANCH_ARRAY[i][j].up = 0
            TWTalent.TALENT_BRANCH_ARRAY[i][j].down = 0
            TWTalent.TALENT_BRANCH_ARRAY[i][j].left = 0
            TWTalent.TALENT_BRANCH_ARRAY[i][j].right = 0
            TWTalent.TALENT_BRANCH_ARRAY[i][j].rightArrow = 0
            TWTalent.TALENT_BRANCH_ARRAY[i][j].leftArrow = 0
            TWTalent.TALENT_BRANCH_ARRAY[i][j].topArrow = 0
        end
    end
end

function TWTalent.TalentFrame_GetBranchTexture()
    local branchTexture = getglobal("TWTalentFrameBranch" .. getglobal('TWTalentFrame').textureIndex)
    getglobal('TWTalentFrame').textureIndex = getglobal('TWTalentFrame').textureIndex + 1
    if not branchTexture then
        message("Not enough branch textures")
    else
        branchTexture:Show()
        return branchTexture
    end
end

function TWTalent.TalentFrame_SetBranchTexture(tier, column, texCoords, xOffset, yOffset)
    local branchTexture = TWTalent.TalentFrame_GetBranchTexture()
    branchTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4])
    branchTexture:SetPoint("TOPLEFT", "TWTalentFrameScrollChildFrame", "TOPLEFT", xOffset, yOffset)
end

function TWTalent.TalentFrame_GetArrowTexture()
    local arrowTexture = getglobal("TWTalentFrameArrow" .. getglobal('TWTalentFrame').arrowIndex)
    getglobal('TWTalentFrame').arrowIndex = getglobal('TWTalentFrame').arrowIndex + 1
    if (not arrowTexture) then
        message("Not enough arrow textures")
    else
        arrowTexture:Show()
        return arrowTexture
    end
end

function TWTalent.TalentFrame_SetArrowTexture(tier, column, texCoords, xOffset, yOffset)
    local arrowTexture = TWTalent.TalentFrame_GetArrowTexture()
    arrowTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4])
    arrowTexture:SetPoint("TOPLEFT", "TWTalentFrameArrowFrame", "TOPLEFT", xOffset, yOffset)
end

function TWTalent.TalentFrame_SetPrereqs(t, c, fd, tu, a5, a6, a7)
    local buttonTier = t
    local buttonColumn = c
    local forceDesaturated = fd
    local tierUnlocked = tu
    local tier, column, isLearnable
    local requirementsMet
    if tierUnlocked and not forceDesaturated then
        requirementsMet = 1
    else
        requirementsMet = nil
    end
    if a5 and a6 and a7 then
        tier = a5
        column = a6
        isLearnable = a7
        if not isLearnable or forceDesaturated then
            requirementsMet = nil
        end
        TWTalent.TalentFrame_DrawLines(buttonTier, buttonColumn, tier, column, requirementsMet)
    end
    return requirementsMet
end

function TWTalent.TalentFrame_DrawLines(buttonTier, buttonColumn, tier, column, requirementsMet)
    if requirementsMet then
        requirementsMet = 1
    else
        requirementsMet = -1
    end

    -- Check to see if are in the same column
    if buttonColumn == column then
        -- Check for blocking talents
        if (buttonTier - tier) > 1 then
            -- If more than one tier difference
            for i = tier + 1, buttonTier - 1 do
                if TWTalent.TALENT_BRANCH_ARRAY[i][buttonColumn].id then
                    -- If there's an id, there's a blocker
                    message("Error this layout is blocked vertically " .. TWTalent.TALENT_BRANCH_ARRAY[buttonTier][i].id)
                    return
                end
            end
        end

        -- Draw the lines
        for i = tier, buttonTier - 1 do
            TWTalent.TALENT_BRANCH_ARRAY[i][buttonColumn].down = requirementsMet
            if (i + 1) <= (buttonTier - 1) then
                TWTalent.TALENT_BRANCH_ARRAY[i + 1][buttonColumn].up = requirementsMet
            end
        end

        -- Set the arrow
        TWTalent.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].topArrow = requirementsMet
        return
    end
    -- Check to see if they're in the same tier
    if buttonTier == tier then
        local left = min(buttonColumn, column)
        local right = max(buttonColumn, column)

        -- See if the distance is greater than one space
        if (right - left) > 1 then
            -- Check for blocking talents
            for i = left + 1, right - 1 do
                if TWTalent.TALENT_BRANCH_ARRAY[tier][i].id then
                    -- If there's an id, there's a blocker
                    message("there's a blocker")
                    return
                end
            end
        end
        -- If we get here then we're in the clear
        for i = left, right - 1 do
            TWTalent.TALENT_BRANCH_ARRAY[tier][i].right = requirementsMet
            TWTalent.TALENT_BRANCH_ARRAY[tier][i + 1].left = requirementsMet
        end
        -- Determine where the arrow goes
        if (buttonColumn < column) then
            TWTalent.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].rightArrow = requirementsMet
        else
            TWTalent.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].leftArrow = requirementsMet
        end
        return
    end
    -- Now we know the prereq is diagonal from us
    local left = min(buttonColumn, column)
    local right = max(buttonColumn, column)
    -- Don't check the location of the current button
    if left == column then
        left = left + 1
    else
        right = right - 1
    end
    -- Check for blocking talents
    local blocked = nil
    for i = left, right do
        if TWTalent.TALENT_BRANCH_ARRAY[tier][i].id then
            -- If there's an id, there's a blocker
            blocked = 1
        end
    end
    left = min(buttonColumn, column)
    right = max(buttonColumn, column)
    if not blocked then
        TWTalent.TALENT_BRANCH_ARRAY[tier][buttonColumn].down = requirementsMet
        TWTalent.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].up = requirementsMet

        for i = tier, buttonTier - 1 do
            TWTalent.TALENT_BRANCH_ARRAY[i][buttonColumn].down = requirementsMet
            TWTalent.TALENT_BRANCH_ARRAY[i + 1][buttonColumn].up = requirementsMet
        end

        for i = left, right - 1 do
            TWTalent.TALENT_BRANCH_ARRAY[tier][i].right = requirementsMet
            TWTalent.TALENT_BRANCH_ARRAY[tier][i + 1].left = requirementsMet
        end
        -- Place the arrow
        TWTalent.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].topArrow = requirementsMet
        return
    end
    -- If we're here then we were blocked trying to go vertically first so we have to go over first, then up
    if left == buttonColumn then
        left = left + 1
    else
        right = right - 1
    end
    -- Check for blocking talents
    for i = left, right do
        if TWTalent.TALENT_BRANCH_ARRAY[buttonTier][i].id then
            -- If there's an id, then throw an error
            message("Error, this layout is undrawable " .. TWTalent.TALENT_BRANCH_ARRAY[buttonTier][i].id)
            return
        end
    end
    -- If we're here we can draw the line
    left = min(buttonColumn, column)
    right = max(buttonColumn, column)
    --TWTalent.TALENT_BRANCH_ARRAY[tier][column].down = requirementsMet
    --TWTalent.TALENT_BRANCH_ARRAY[buttonTier][column].up = requirementsMet

    for i = tier, buttonTier - 1 do
        TWTalent.TALENT_BRANCH_ARRAY[i][column].up = requirementsMet
        TWTalent.TALENT_BRANCH_ARRAY[i + 1][column].down = requirementsMet
    end

    -- Determine where the arrow goes
    if buttonColumn < column then
        TWTalent.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].rightArrow = requirementsMet
    else
        TWTalent.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].leftArrow = requirementsMet
    end
end

function TWTalentFrameTab_OnClick()
    PanelTemplates_SetTab(getglobal('TWTalentFrame'), this:GetID())
    TWTalentFrame_Update()
    PlaySound("igCharacterInfoTab")

    TWTalentFrameScrollFrame:SetVerticalScroll(0)
end

local paperDollFrames = {
    InspectHeadSlot,
    InspectShoulderSlot,
    InspectBackSlot,
    InspectChestSlot,
    InspectWristSlot,
    InspectHandsSlot,
    InspectWaistSlot,
    InspectLegsSlot,
    InspectFeetSlot,
    InspectMainHandSlot,
    InspectSecondaryHandSlot,
    InspectRangedSlot,
}

local InspectTransmogTooltip = CreateFrame("Frame", "InspectTransmogTooltip", GameTooltip)
InspectTransmogTooltip:SetScript("OnShow", function()

    if not InspectPaperDollFrame:IsVisible() then
        return
    end

    if GameTooltip.itemLink then

        local _, _, itemLink = string.find(GameTooltip.itemLink, "(item:%d+:%d+:%d+:%d+)");

        if not itemLink then
            return false
        end

        for _, frame in next, paperDollFrames do
            if GameTooltip:IsOwned(frame) == 1 then
                local itemName = GetItemInfo(itemLink)

                local tLabel = getglobal(GameTooltip:GetName() .. "TextLeft2")

                if tLabel and tLabel:GetText() and inspectCom.transmogs[itemName] then
                    tLabel:SetText('|cfff471f5Transmogrified to:\n' .. inspectCom.transmogs[itemName] .. '\n|cffffffff' .. tLabel:GetText())
                end

                GameTooltip:Show()

                return
            end
        end

    end
end)

InspectTransmogTooltip:SetScript("OnHide", function()
    GameTooltip.itemLink = nil
end)
