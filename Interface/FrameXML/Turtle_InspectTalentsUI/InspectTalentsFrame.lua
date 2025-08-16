local function inSend(to, data)
    SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. to .. ">", data, "GUILD")
end

local loadedFor = ""

function InspectFrameTalentsTab_OnClick()
	if loadedFor ~= UnitName('target') then
		Ins_Init()
		inSend(UnitName('target'), "INSShowTalents")
	else
		TWInspectTalents_Show()
	end
end

if LoadAddOn("Blizzard_TalentUI") and LoadAddOn("Blizzard_InspectUI") then
	local TWInspectFrame_Show = InspectFrame_Show
	if TWInspectFrame_Show then
		InspectFrame_Show = function(unit)
			TWInspectFrame_Show(unit)
			if UnitName('target') then
				inSend(UnitName('target'), "INSShowTransmogs")
				if InspectFrame.selectedTab == 3 then
					Ins_Init()
					inSend(UnitName('target'), "INSShowTalents")
				end
			end
			if not InspectFrameTab3 then
				CreateFrame('Button', 'InspectFrameTab3', InspectFrame, 'CharacterFrameTabButtonTemplate')
				InspectFrameTab3:SetPoint("LEFT", InspectFrameTab2, "RIGHT", -16, 0)
				InspectFrameTab3:SetID(3)
				InspectFrameTab3:SetText(TALENTS)
				InspectFrameTab3:SetScript("OnEnter", function()
					GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
					GameTooltip:SetText(TALENTS, 1.0,1.0,1.0 );
				end)
				InspectFrameTab3:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				InspectFrameTab3:SetScript("OnClick", function()
					InspectFrameTalentsTab_OnClick()
					PlaySound("igCharacterInfoTab");
				end)
				InspectFrameTab3:Show()
				PanelTemplates_TabResize(0, InspectFrameTab3);

				tinsert(INSPECTFRAME_SUBFRAMES, "InspectTalentsFrame")
				UIPanelWindows["InspectFrame"].pushable = 4

				PanelTemplates_SetNumTabs(InspectFrame, 3)
				PanelTemplates_SetTab(InspectFrame, 1)
			end
		end
	end
end

local TWTalent = {}

local inspectCom = CreateFrame("Frame")
inspectCom.SPEC = {}
for i = 1, 3 do
	inspectCom.SPEC[i] = { name = "", iconTexture = "", pointsSpent = 0, numTalents = 0 }
end
inspectCom.SPEC.class = ""
inspectCom.transmogs = {}

function Ins_Init()
	local _, class = UnitClass("target")
    inspectCom.SPEC.class = class

	inspectCom.SPEC[1].name = Turtle_TalentsData[class][1].name
	inspectCom.SPEC[1].iconTexture = ""
	inspectCom.SPEC[1].pointsSpent = 0
	inspectCom.SPEC[1].numTalents = 0

    inspectCom.SPEC[2].name = Turtle_TalentsData[class][2].name
    inspectCom.SPEC[2].iconTexture = ""
    inspectCom.SPEC[2].pointsSpent = 0
    inspectCom.SPEC[2].numTalents = 0

	inspectCom.SPEC[3].name = Turtle_TalentsData[class][3].name
	inspectCom.SPEC[3].iconTexture = ""
	inspectCom.SPEC[3].pointsSpent = 0
	inspectCom.SPEC[3].numTalents = 0
end

TWTalent.TALENT_BRANCH_ARRAY = {}
inspectCom:RegisterEvent("CHAT_MSG_ADDON")
inspectCom:SetScript("OnEvent", function()
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
				loadedFor = UnitName('target')
				if TWTalentFrame:IsVisible() then
					TWTalentFrame:Hide()
					TWTalentFrame:Show()
				elseif CanInspect("target") then
					TWInspectTalents_Show()
				end

				return true
			end

			if string.find(message, "INSTalentTabInfo;", 1, true) then
				local talentEx = explode(message, ';')
				local index = tonumber(talentEx[2])
				local name = talentEx[3]
				local pointsSpent = tonumber(talentEx[4])
				local numTalents = tonumber(talentEx[5])

				-- inspectCom.SPEC[index].name = name
				inspectCom.SPEC[index].pointsSpent = pointsSpent
				inspectCom.SPEC[index].numTalents = numTalents

				return true
			end

			if string.find(message, "INSTalentInfo;", 1, true) then

				local talentEx = explode(message, ';')

				local tree = tonumber(talentEx[2])
				local i = tonumber(talentEx[3])
				local name = talentEx[4]
				local tier = tonumber(talentEx[5])
				local column = tonumber(talentEx[6])
				local currRank = tonumber(talentEx[7])
				local maxRank = tonumber(talentEx[8])
				local meetsPrereq = talentEx[9] == '1'

				local ptier = nil
				local pcolumn = nil
				local isLearnable = true --WTF??

				if talentEx[10] ~= '-1' then
					ptier = tonumber(talentEx[10])
				end
				if talentEx[11] ~= '-1' then
					pcolumn = tonumber(talentEx[11])
				end
				--if talentEx[12] == '-1' then
				--    isLearnable = true
				--end

				if not inspectCom.SPEC[tree][i] then
					inspectCom.SPEC[tree][i] = {}
				end

				if Turtle_TalentsData[inspectCom.SPEC.class] and Turtle_TalentsData[inspectCom.SPEC.class][tree]
					and Turtle_TalentsData[inspectCom.SPEC.class][tree][i] and Turtle_TalentsData[inspectCom.SPEC.class][tree][i].name then
					
					inspectCom.SPEC[tree][i].name = Turtle_TalentsData[inspectCom.SPEC.class][tree][i].name
					inspectCom.SPEC[tree][i].tier = tier
					inspectCom.SPEC[tree][i].column = column
					inspectCom.SPEC[tree][i].rank = currRank
					inspectCom.SPEC[tree][i].maxRank = maxRank
					inspectCom.SPEC[tree][i].meetsPrereq = meetsPrereq

					inspectCom.SPEC[tree][i].ptier = ptier
					inspectCom.SPEC[tree][i].pcolumn = pcolumn
					inspectCom.SPEC[tree][i].isLearnable = isLearnable
				end

				return true
			end

			if string.find(message, "INSTransmogs:", 1, true) then

				local tEx = explode(message, ':')

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
	end
end)

function TWInspectTalents_Show()
    ToggleInspect("InspectTalentsFrame");
    TWTalentFrame:Show()
end

function TWTalentOnClick(tab, id)
    if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
        local name = TWTalentName(tab, id);
        local talent = "|cFF71D5FF|Htalent:" .. tab .. ":" .. id .. ":" .. UnitName("target") .. ":|h[" .. name .. "]|h|r"
        ChatFrameEditBox:Insert(talent)
        return
    end
end

function TWTalentName(i, j)
	if Turtle_TalentsData[inspectCom.SPEC.class][i][j] and Turtle_TalentsData[inspectCom.SPEC.class][i][j].name then
		return Turtle_TalentsData[inspectCom.SPEC.class][i][j].name
	end
	return UNKNOWN
end

function TWTalentDescription(i, j)
	if Turtle_TalentsData[inspectCom.SPEC.class][i][j] then
		return Turtle_TalentsData[inspectCom.SPEC.class][i][j].desc[inspectCom.SPEC[i][j].rank > 0 and inspectCom.SPEC[i][j].rank or 1]
	end
	return UNKNOWN
end

function TWTalentRank(i, j)
	if inspectCom.SPEC[i] and inspectCom.SPEC[i][j] and inspectCom.SPEC[i][j].rank and inspectCom.SPEC[i][j].maxRank then
		return format(TOOLTIP_TALENT_RANK, inspectCom.SPEC[i][j].rank, inspectCom.SPEC[i][j].maxRank)
	end
	return format(TOOLTIP_TALENT_RANK, 1, 1)
end

function TWTalent.GetTalentTabInfo(i)
    local name = Turtle_TalentsData[inspectCom.SPEC.class][i].name
    local iconTexture = ""
    local pointsSpent = inspectCom.SPEC[i].pointsSpent
    local fileName = Turtle_TalentsData[inspectCom.SPEC.class][i].background

    return name, iconTexture, pointsSpent, fileName
end

function TWTalent.GetNumTalents(i)
    return inspectCom.SPEC[i].numTalents
end

function TWTalent.GetTalentInfo(i, j)
    local name = Turtle_TalentsData[inspectCom.SPEC.class][i][j] and Turtle_TalentsData[inspectCom.SPEC.class][i][j].name or ""
    local texture = Turtle_TalentsData[inspectCom.SPEC.class][i][j] and Turtle_TalentsData[inspectCom.SPEC.class][i][j].icon or "inv_misc_questionmark"
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
        tab = _G['TWTalentFrameTab' .. i]
        name, iconTexture, pointsSpent = TWTalent.GetTalentTabInfo(i)
        if i == TWTalentFrame.selectedTab then
            -- If tab is the selected tab set the points spent info
            TWTalentFrame.pointsSpent = pointsSpent
        end

        tab:SetText(name)
        tab:Show()

        PanelTemplates_TabResize(-8, tab)
    end

    PanelTemplates_SetNumTabs(TWTalentFrame, numTabs)
    PanelTemplates_UpdateTabs(TWTalentFrame)

    TWTalentFrame.talentPoints = UnitLevel('target') - 9 - inspectCom.SPEC[1].pointsSpent - inspectCom.SPEC[2].pointsSpent - inspectCom.SPEC[3].pointsSpent

    local talentTabName = TWTalent.GetTalentTabInfo(TWTalentFrame.selectedTab)
    local base
    local name, texture, points, fileName = TWTalent.GetTalentTabInfo(TWTalentFrame.selectedTab)
    if talentTabName then
        base = "Interface\\TalentFrame\\" .. fileName .. "-"
    else
        base = "Interface\\TalentFrame\\MageFire-"
    end

    TWTalentFrameBackgroundTopLeft:SetTexture(base .. "TopLeft")
    TWTalentFrameBackgroundTopRight:SetTexture(base .. "TopRight")
    TWTalentFrameBackgroundBottomLeft:SetTexture(base .. "BottomLeft")
    TWTalentFrameBackgroundBottomRight:SetTexture(base .. "BottomRight")

    local numTalents = TWTalent.GetNumTalents(TWTalentFrame.selectedTab)

    if numTalents > MAX_NUM_TALENTS then
        message("Too many talents in talent frame!")
    end

    TWTalent.TalentFrame_ResetBranches()

    local tier, column, rank, maxRank, isLearnable, meetsPrereq
    local forceDesaturated, tierUnlocked
    for i = 1, MAX_NUM_TALENTS do
        button = _G['TWTalentFrameTalent' .. i]
        if i <= numTalents then
            -- Set the button info
            name, iconTexture, tier, column, rank, maxRank, meetsPrereq = TWTalent.GetTalentInfo(TWTalentFrame.selectedTab, i)
            _G['TWTalentFrameTalent' .. i .. 'Rank']:SetText(rank)
            SetTalentButtonLocation(button, tier, column)
            TWTalent.TALENT_BRANCH_ARRAY[tier][column].id = button:GetID()

            -- If player has no talent points then show only talents with points in them
            if TWTalentFrame.talentPoints <= 0 and rank == 0 then
                forceDesaturated = 1
            else
                forceDesaturated = nil
            end

            -- If the player has spent at least 5 talent points in the previous tier
            if ((tier - 1) * 5) <= TWTalentFrame.pointsSpent then
                tierUnlocked = 1
            else
                tierUnlocked = nil
            end

            SetItemButtonTexture(button, iconTexture)

            -- Talent must meet prereqs or the player must have no points to spend
            local a5, a6, a7 = TWTalent.GetTalentPrereqs(TWTalentFrame.selectedTab, i)
            if TWTalent.TalentFrame_SetPrereqs(tier, column, forceDesaturated, tierUnlocked, a5, a6, a7) and meetsPrereq then

                SetItemButtonDesaturated(button, nil)

                if rank < maxRank then
                    -- Rank is green if not maxed out
                    _G['TWTalentFrameTalent' .. i .. 'Slot']:SetVertexColor(0.1, 1.0, 0.1)
                    _G['TWTalentFrameTalent' .. i .. 'Rank']:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                else
                    _G['TWTalentFrameTalent' .. i .. 'Slot']:SetVertexColor(1.0, 0.82, 0)
                    _G['TWTalentFrameTalent' .. i .. 'Rank']:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
                end
                _G['TWTalentFrameTalent' .. i .. 'RankBorder']:Show()
                _G['TWTalentFrameTalent' .. i .. 'Rank']:Show()
            else
                SetItemButtonDesaturated(button, 1, 0.65, 0.65, 0.65)
                _G["TWTalentFrameTalent" .. i .. "Slot"]:SetVertexColor(0.5, 0.5, 0.5)
                if rank == 0 then
                    _G["TWTalentFrameTalent" .. i .. "RankBorder"]:Hide()
                    _G["TWTalentFrameTalent" .. i .. "Rank"]:Hide()
                else
                    _G["TWTalentFrameTalent" .. i .. "RankBorder"]:SetVertexColor(0.5, 0.5, 0.5)
                    _G["TWTalentFrameTalent" .. i .. "Rank"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
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

    TWTalentFrame.textureIndex = 1

    TWTalentFrame.arrowIndex = 1

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
        TWTalentFrameScrollFrame:UpdateScrollChildRect()
    end
    -- Hide any unused branch textures
    for i = TWTalentFrame.textureIndex, MAX_NUM_BRANCH_TEXTURES do
        _G["TWTalentFrameBranch" .. i]:Hide()
    end
    -- Hide and unused arrow textures
    for i = TWTalentFrame.arrowIndex, MAX_NUM_ARROW_TEXTURES do
        _G["TWTalentFrameArrow" .. i]:Hide()
    end
end

function TWTalentFrame_OnShow()

	if loadedFor ~= UnitName("target") then
		PanelTemplates_SetTab(TWTalentFrame, 1)
	else
		PanelTemplates_SetTab(TWTalentFrame, TWTalentFrame.selectedTab)
	end
    for i = 1, MAX_NUM_TALENT_TIERS do
        TWTalent.TALENT_BRANCH_ARRAY[i] = {}
        for j = 1, NUM_TALENT_COLUMNS do
            TWTalent.TALENT_BRANCH_ARRAY[i][j] = { id = nil, up = 0, left = 0, right = 0, down = 0, leftArrow = 0, rightArrow = 0, topArrow = 0 }
        end
    end

    -- PlaySound("TalentScreenOpen")
    TWTalentFrame_Update()
    TWTalentFrameScrollFrame:UpdateScrollChildRect()
end

function TWTalentFrame_OnHide()
    -- PlaySound("TalentScreenClose")
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
    local branchTexture = _G["TWTalentFrameBranch" .. TWTalentFrame.textureIndex]
    TWTalentFrame.textureIndex = TWTalentFrame.textureIndex + 1
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
    local arrowTexture = _G["TWTalentFrameArrow" .. TWTalentFrame.arrowIndex]
    TWTalentFrame.arrowIndex = TWTalentFrame.arrowIndex + 1
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
    PanelTemplates_SetTab(TWTalentFrame, this:GetID())
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
    InspectTabardSlot,
    InspectShirtSlot,
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

                local tLabel = _G[GameTooltip:GetName() .. "TextLeft2"]

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
