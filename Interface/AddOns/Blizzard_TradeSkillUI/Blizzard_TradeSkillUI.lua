
TRADE_SKILLS_DISPLAYED = 19
MAX_TRADE_SKILL_REAGENTS = 8;
TRADE_SKILL_HEIGHT = 16;

TradeSkillTypeColor = { };
TradeSkillTypeColor["optimal"]	= { r = 1.00, g = 0.50, b = 0.25 };
TradeSkillTypeColor["medium"]	= { r = 1.00, g = 1.00, b = 0.00 };
TradeSkillTypeColor["easy"]		= { r = 0.25, g = 0.75, b = 0.25 };
TradeSkillTypeColor["trivial"]	= { r = 0.50, g = 0.50, b = 0.50 };
TradeSkillTypeColor["header"]	= { r = 1.00, g = 0.82, b = 0 };

UIPanelWindows["TradeSkillFrame"] =	{ area = "left", pushable = 10 };

TradeSkillIcons =
{
	["Alchemy"] = "Trade_Alchemy",
	["Blacksmithing"] = "Trade_Blacksmithing",
	["Cooking"] = "inv_misc_food_15",
	["Engineering"] = "Trade_Engineering",
	["First Aid"] = "spell_holy_sealofsacrifice",
	["Jewelcrafting"] = "inv_helmet_44",
	["Leatherworking"] = "inv_misc_armorkit_17",
	["Mining"] = "spell_fire_flameblades",
	["Tailoring"] = "Trade_Tailoring",
}

local searchResults = {}

function TradeSkillFrame_Search()
	searchResults = {}

	local query = strlower(TradeSkillSearchBox:GetText())
	local isMatsChecked = TradeSkillMatsCheckButton:GetChecked()
	local isSkillChecked = TradeSkillSkillCheckButton:GetChecked()

	if query ~= "search" and query ~= "" or isMatsChecked or isSkillChecked then
		local lastHeaderPos = -1

		for i = 1, GetNumTradeSkills() do
			local skillName, skillType, available = GetTradeSkillInfo(i)
			if skillType == "header" then
				ExpandTradeSkillSubClass(i)

				table.insert(searchResults, i)

				-- if difference between this header and last header position
				-- is 1, it means they this header is followed by the previous
				-- and it has no matching results and can be removed from the list
				if table.getn(searchResults) - lastHeaderPos == 1 then
					table.remove(searchResults, lastHeaderPos)
				end
				lastHeaderPos = table.getn(searchResults)
			else
				if query ~= "search" and query ~= "" then
					if strfind(strlower(skillName), query) then
						table.insert(searchResults, i)

						if (isMatsChecked and available == 0) or (isSkillChecked and skillType == "trivial") then
							table.remove(searchResults, table.getn(searchResults))
						end
					end
				else
					if isMatsChecked and available > 0 or not isMatsChecked then
						if isSkillChecked and skillType ~= "trivial" or not isSkillChecked then
							table.insert(searchResults, i)
						end
					end
				end
			end
		end

		-- if the last result is a header with no children results, remove it
		if lastHeaderPos == table.getn(searchResults) then
			table.remove(searchResults, lastHeaderPos)
		end

		TradeSkillListScrollFrame:SetVerticalScroll(1)
	end

	TradeSkillFrame_Update()
end

function TradeSkillFrame_Show()
	searchResults = {}

	TradeSkillMatsCheckButton:SetChecked(0)
	TradeSkillSkillCheckButton:SetChecked(0)
	TradeSkillSearchBox:SetText("Search")

	CloseDropDownMenus();
	TradeSkillSubClassDropDown:Hide();
	TradeSkillSubClassDropDown:Show();
	TradeSkillInvSlotDropDown:Hide();
	TradeSkillInvSlotDropDown:Show();
	ShowUIPanel(TradeSkillFrame);
	TradeSkillCreateButton:Disable();
	TradeSkillCreateAllButton:Disable();
	if ( GetTradeSkillSelectionIndex() == 0 ) then
		TradeSkillFrame_SetSelection(GetFirstTradeSkill());
	else
		TradeSkillFrame_SetSelection(GetTradeSkillSelectionIndex());
	end
	FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
	TradeSkillListScrollFrameScrollBar:SetMinMaxValues(0, 0);
	TradeSkillListScrollFrameScrollBar:SetValue(0);
	local icon = TradeSkillIcons[format(TEXT(TRADE_SKILL_TITLE), GetTradeSkillLine())]
	if icon then
		SetPortraitToTexture(TradeSkillFramePortrait, "Interface\\Icons\\" .. icon)
	else
		SetPortraitTexture(TradeSkillFramePortrait, "player");
	end
	TradeSkillFrame_Update();
end

function TradeSkillFrame_Hide()
	HideUIPanel(TradeSkillFrame);
end

function TradeSkillFrame_OnLoad()
	this:RegisterEvent("BAG_UPDATE");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("TRADE_SKILL_UPDATE");
	this:RegisterEvent("UPDATE_TRADESKILL_RECAST");
end

function TradeSkillFrame_OnEvent()
	if ( not TradeSkillFrame:IsVisible() ) then
		return;
	end
	if ( event == "TRADE_SKILL_UPDATE" ) then
		TradeSkillCreateButton:Disable();
		TradeSkillCreateAllButton:Disable();
		if ( GetTradeSkillSelectionIndex() > 1 and GetTradeSkillSelectionIndex() <= GetNumTradeSkills() ) then
			TradeSkillFrame_SetSelection(GetTradeSkillSelectionIndex());
		else
			if ( GetNumTradeSkills() > 0 ) then
				TradeSkillFrame_SetSelection(GetFirstTradeSkill());
				FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
			end
			TradeSkillListScrollFrameScrollBar:SetValue(0);
		end
		TradeSkillFrame_Update();
	elseif ( event == "UPDATE_TRADESKILL_RECAST" ) then
		TradeSkillInputBox:SetNumber(GetTradeskillRepeatCount());
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		TradeSkillFrame_Hide();
	elseif ( event == "BAG_UPDATE" ) then
		TradeSkillFrame_Search();
	end
end

function TradeSkillFrame_Update()
	local numTradeSkills = GetNumTradeSkills();
	local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame);
	-- If no tradeskills
	if ( numTradeSkills == 0 ) then
		TradeSkillFrameTitleText:SetText(format(TEXT(TRADE_SKILL_TITLE), GetTradeSkillLine()));
		TradeSkillSkillName:Hide();
--		TradeSkillSkillLineName:Hide();
		TradeSkillSkillIcon:Hide();
		TradeSkillRequirementLabel:Hide();
		TradeSkillRequirementText:SetText("");
		TradeSkillCollapseAllButton:Disable();
		for i=1, MAX_TRADE_SKILL_REAGENTS, 1 do
			getglobal("TradeSkillReagent"..i):Hide();
		end
	else
		TradeSkillSkillName:Show();
--		TradeSkillSkillLineName:Show();
		TradeSkillSkillIcon:Show();
		TradeSkillCollapseAllButton:Enable();
	end

	-- ScrollFrame update
	local results = table.getn(searchResults)
	local recipepsToUpdate = results == 0 and numTradeSkills or results

	FauxScrollFrame_Update(TradeSkillListScrollFrame, recipepsToUpdate, TRADE_SKILLS_DISPLAYED, TRADE_SKILL_HEIGHT, nil, nil, nil, TradeSkillHighlightFrame, 290, 292 );

	TradeSkillHighlightFrame:Hide()
	TradeSkillFrameNoResultsText:Hide()

	for i=1, TRADE_SKILLS_DISPLAYED, 1 do
		local skillIndex = 0

		if TradeSkillSearchBox:GetText() ~= "Search" or TradeSkillMatsCheckButton:GetChecked() or TradeSkillSkillCheckButton:GetChecked() then
			if results > 0 then
				if searchResults[i + skillOffset] then
					skillIndex = searchResults[i + skillOffset]
				end
			else
				TradeSkillFrameNoResultsText:Show()

				skillIndex = -1
			end
		else
			skillIndex = i + skillOffset;
		end
		local skillName, skillType, numAvailable, isExpanded = GetTradeSkillInfo(skillIndex);
		local skillButton = getglobal("TradeSkillSkill"..i);
		if ( skillIndex > 0 and skillIndex <= numTradeSkills ) then
			skillButton:SetWidth(293);
			local color = TradeSkillTypeColor[skillType];
			if ( color ) then
				skillButton:SetTextColor(color.r, color.g, color.b);
			end

			skillButton:SetID(skillIndex);
			skillButton:Show();
			-- Handle headers
			if ( skillType == "header" ) then
				skillButton:SetText(skillName);
				if ( isExpanded ) then
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
				else
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				end
				getglobal("TradeSkillSkill"..i.."Highlight"):SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
				getglobal("TradeSkillSkill"..i):UnlockHighlight();
			else
				if ( not skillName ) then
					return;
				end
				skillButton:SetNormalTexture("");
				getglobal("TradeSkillSkill"..i.."Highlight"):SetTexture("");
				if ( numAvailable == 0 ) then
					skillButton:SetText(" "..skillName);
				else
					skillButton:SetText(" "..skillName.." ["..numAvailable.."]");
				end

				-- Place the highlight and lock the highlight state
				if ( GetTradeSkillSelectionIndex() == skillIndex ) then
					TradeSkillHighlightFrame:SetPoint("TOPLEFT", "TradeSkillSkill"..i, "TOPLEFT", 0, 0);
					TradeSkillHighlightFrame:Show();
					getglobal("TradeSkillSkill"..i):LockHighlight();
				else
					getglobal("TradeSkillSkill"..i):UnlockHighlight();
				end
			end

		else
			skillButton:Hide();
		end
	end

	-- Set the expand/collapse all button texture
	local numHeaders = 0;
	local notExpanded = 0;
	for i=1, numTradeSkills, 1 do
		local skillName, skillType, numAvailable, isExpanded = GetTradeSkillInfo(i);
		if ( skillName and skillType == "header" ) then
			numHeaders = numHeaders + 1;
			if ( not isExpanded ) then
				notExpanded = notExpanded + 1;
			end
		end
		if ( GetTradeSkillSelectionIndex() == i ) then
			-- Set the max makeable items for the create all button
			TradeSkillFrame.numAvailable = numAvailable;
		end
	end
	-- If all headers are not expanded then show collapse button, otherwise show the expand button
	if ( notExpanded ~= numHeaders ) then
		TradeSkillCollapseAllButton.collapsed = nil;
		TradeSkillCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
	else
		TradeSkillCollapseAllButton.collapsed = 1;
		TradeSkillCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
	end
end

function TradeSkillFrame_SetSelection(id)
	local skillName, skillType, numAvailable, isExpanded = GetTradeSkillInfo(id);
	TradeSkillHighlightFrame:Show();
	if ( skillType == "header" ) then
		TradeSkillHighlightFrame:Hide();
		if (table.getn(searchResults) == 0) then
			if ( isExpanded ) then
				CollapseTradeSkillSubClass(id);
			else
				ExpandTradeSkillSubClass(id);
			end
		end
		return;
	end
	TradeSkillFrame.selectedSkill = id;
	SelectTradeSkill(id);
	if ( GetTradeSkillSelectionIndex() > GetNumTradeSkills() ) then
		return;
	end
	local color = TradeSkillTypeColor[skillType];
	if ( color ) then
		TradeSkillHighlight:SetVertexColor(color.r, color.g, color.b);
	end

	-- General Info
	local skillLineName, skillLineRank, skillLineMaxRank = GetTradeSkillLine();
	TradeSkillFrameTitleText:SetText(format(TEXT(TRADE_SKILL_TITLE), skillLineName));
	-- Set statusbar info
	TradeSkillRankFrameSkillName:SetText(skillLineName);
	TradeSkillRankFrame:SetStatusBarColor(0.0, 0.0, 1.0, 0.5);
	TradeSkillRankFrameBackground:SetVertexColor(0.0, 0.0, 0.75, 0.5);
	TradeSkillRankFrame:SetMinMaxValues(0, skillLineMaxRank);
	TradeSkillRankFrame:SetValue(skillLineRank);
	TradeSkillRankFrameSkillRank:SetText(skillLineRank.."/"..skillLineMaxRank);

	TradeSkillSkillName:SetText(skillName);
	if ( GetTradeSkillCooldown(id) ) then
		TradeSkillSkillCooldown:SetText(COOLDOWN_REMAINING.." "..SecondsToTime(GetTradeSkillCooldown(id)));
	else
		TradeSkillSkillCooldown:SetText("");
	end
	TradeSkillSkillIcon:SetNormalTexture(GetTradeSkillIcon(id));
	local minMade,maxMade = GetTradeSkillNumMade(id);
	if ( maxMade > 1 ) then
		if ( minMade == maxMade ) then
			TradeSkillSkillIconCount:SetText(minMade);
		else
			TradeSkillSkillIconCount:SetText(minMade.."-"..maxMade);
		end
		if ( TradeSkillSkillIconCount:GetWidth() > 39 ) then
			TradeSkillSkillIconCount:SetText("~"..floor((minMade + maxMade)/2));
		end
	else
		TradeSkillSkillIconCount:SetText("");
	end

	-- Reagents
	local creatable = 1;
	local numReagents = GetTradeSkillNumReagents(id);
	for i=1, numReagents, 1 do
		local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i);
		local reagent = getglobal("TradeSkillReagent"..i)
		local name = getglobal("TradeSkillReagent"..i.."Name");
		local count = getglobal("TradeSkillReagent"..i.."Count");
		if ( not reagentName or not reagentTexture ) then
			reagent:Hide();
		else
			reagent:Show();
			SetItemButtonTexture(reagent, reagentTexture);
			name:SetText(reagentName);
			-- Grayout items
			if ( playerReagentCount < reagentCount ) then
				SetItemButtonTextureVertexColor(reagent, 0.5, 0.5, 0.5);
				name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				creatable = nil;
			else
				SetItemButtonTextureVertexColor(reagent, 1.0, 1.0, 1.0);
				name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			end
			if ( playerReagentCount >= 100 ) then
				playerReagentCount = "*";
			end
			count:SetText(playerReagentCount.." /"..reagentCount);
		end
	end
	-- Place reagent label
	local reagentToAnchorTo = numReagents;
	if ( (numReagents > 0) and (mod(numReagents, 2) == 0) ) then
		reagentToAnchorTo = reagentToAnchorTo - 1;
	end

	for i=numReagents + 1, MAX_TRADE_SKILL_REAGENTS, 1 do
		getglobal("TradeSkillReagent"..i):Hide();
	end

	local spellFocus = BuildColoredListString(GetTradeSkillTools(id));
	if ( spellFocus ) then
		TradeSkillRequirementLabel:Show();
		TradeSkillRequirementText:SetText(spellFocus);
	else
		TradeSkillRequirementLabel:Hide();
		TradeSkillRequirementText:SetText("");
	end

	if ( creatable ) then
		TradeSkillCreateButton:Enable();
		TradeSkillCreateAllButton:Enable();
	else
		TradeSkillCreateButton:Disable();
		TradeSkillCreateAllButton:Disable();
	end
	TradeSkillDetailScrollFrame:UpdateScrollChildRect();

	-- Reset the number of items to be created
	TradeSkillInputBox:SetNumber(GetTradeskillRepeatCount());
end

function TradeSkillSkillButton_OnClick(button)
	if ( button == "LeftButton" ) then
		TradeSkillFrame_SetSelection(this:GetID());
		TradeSkillFrame_Update();
	end
end

function TradeSkillCollapseAllButton_OnClick()
	if (this.collapsed) then
		this.collapsed = nil;
		ExpandTradeSkillSubClass(0);
	else
		this.collapsed = 1;
		TradeSkillListScrollFrameScrollBar:SetValue(0);
		CollapseTradeSkillSubClass(0);
	end
end

function TradeSkillSubClassDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, TradeSkillSubClassDropDown_Initialize);
	UIDropDownMenu_SetWidth(120);
	UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, 1);
end

function TradeSkillSubClassDropDown_OnShow()
	UIDropDownMenu_Initialize(this, TradeSkillSubClassDropDown_Initialize);
	if ( GetTradeSkillSubClassFilter(0) ) then
		UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, 1);
	end
end

function TradeSkillSubClassDropDown_Initialize()
	TradeSkillFilterFrame_LoadSubClasses(GetTradeSkillSubClasses());
end

function TradeSkillFilterFrame_LoadSubClasses(...)
	local allChecked = GetTradeSkillSubClassFilter(0);
	local info = {};
	if ( arg.n > 1 ) then
		info.text = TEXT(ALL_SUBCLASSES);
		info.func = TradeSkillSubClassDropDownButton_OnClick;
		info.checked = allChecked;
		UIDropDownMenu_AddButton(info);
	end

	local checked;
	for i=1, arg.n, 1 do
		if ( allChecked and arg.n > 1 ) then
			checked = nil;
			UIDropDownMenu_SetText(TEXT(ALL_SUBCLASSES), TradeSkillSubClassDropDown);
		else
			checked = GetTradeSkillSubClassFilter(i);
			if ( checked ) then
				UIDropDownMenu_SetText(arg[i], TradeSkillSubClassDropDown);
			end
		end
		info = {};
		info.text = arg[i];
		info.func = TradeSkillSubClassDropDownButton_OnClick;
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

function TradeSkillInvSlotDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, TradeSkillInvSlotDropDown_Initialize);
	UIDropDownMenu_SetWidth(120);
	UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, 1);
end

function TradeSkillInvSlotDropDown_OnShow()
	UIDropDownMenu_Initialize(this, TradeSkillInvSlotDropDown_Initialize);
	if ( GetTradeSkillInvSlotFilter(0) ) then
		UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, 1);
	end
end

function TradeSkillInvSlotDropDown_Initialize()
	TradeSkillFilterFrame_LoadInvSlots(GetTradeSkillInvSlots());
end

function TradeSkillFilterFrame_LoadInvSlots(...)
	local allChecked = GetTradeSkillInvSlotFilter(0);
	local info = {}
	if ( arg.n > 1 ) then
		info.text = TEXT(ALL_INVENTORY_SLOTS);
		info.func = TradeSkillInvSlotDropDownButton_OnClick;
		info.checked = allChecked;
		UIDropDownMenu_AddButton(info);
	end

	local checked;
	for i=1, arg.n, 1 do
		if ( allChecked and arg.n > 1 ) then
			checked = nil;
			UIDropDownMenu_SetText(TEXT(ALL_INVENTORY_SLOTS), TradeSkillInvSlotDropDown);
		else
			checked = GetTradeSkillInvSlotFilter(i);
			if ( checked ) then
				UIDropDownMenu_SetText(arg[i], TradeSkillInvSlotDropDown);
			end
		end
		info = {};
		info.text = arg[i];
		info.func = TradeSkillInvSlotDropDownButton_OnClick;
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

function TradeSkillSubClassDropDownButton_OnClick()
	UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, this:GetID());
	SetTradeSkillSubClassFilter(this:GetID() - 1, 1, 1);

	TradeSkillFrame_Search()
end

function TradeSkillInvSlotDropDownButton_OnClick()
	UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, this:GetID())
	SetTradeSkillInvSlotFilter(this:GetID() - 1, 1, 1);

	TradeSkillFrame_Search()
end

function TradeSkillFrameIncrement_OnClick()
	if ( TradeSkillInputBox:GetNumber() < 100 ) then
		TradeSkillInputBox:SetNumber(TradeSkillInputBox:GetNumber() + 1);
	end
end

function TradeSkillFrameDecrement_OnClick()
	if ( TradeSkillInputBox:GetNumber() > 0 ) then
		TradeSkillInputBox:SetNumber(TradeSkillInputBox:GetNumber() - 1);
	end
end