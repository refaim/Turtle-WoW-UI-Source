LOOTFRAME_NUMBUTTONS = 4;
NUM_GROUP_LOOT_FRAMES = 4;
MASTER_LOOT_THREHOLD = 4;

local GroupRoster = {}
for k in pairs(RAID_CLASS_COLORS) do
	GroupRoster[k] = {}
	for k2, v2 in pairs(TW_CLASS_TOKEN[GetLocale()]) do
		if v2 == k then
			GroupRoster[k].class = k2
		end
	end
end

local lastSelectedButton = nil

function LootFrame_OnLoad()
	this:RegisterEvent("LOOT_OPENED");
	this:RegisterEvent("LOOT_SLOT_CLEARED");
	this:RegisterEvent("LOOT_CLOSED");
	this:RegisterEvent("OPEN_MASTER_LOOT_LIST");
	this:RegisterEvent("UPDATE_MASTER_LOOT_LIST");
	this:RegisterEvent("RAID_ROSTER_UPDATE")
	this:SetClampedToScreen(true)
	local OnHide = DropDownList1:GetScript("OnHide")
	DropDownList1:SetScript("OnHide", function()
		if OnHide then OnHide() end
		lastSelectedButton = nil
	end)
end

function LootFrame_OnEvent(event)
	if ( event == "LOOT_OPENED" ) then
		this.page = 1;
		ShowUIPanel(this);
		if ( not this:IsVisible() ) then
			CloseLoot(1);	-- The parameter tells code that we were unable to open the UI
			return;
		end

		if ( LOOT_WINDOW_AT_CURSOR == "1" ) then
			local x, y = GetCursorPosition()
			local scale = this:GetEffectiveScale()
			x = (x / scale) - 48
			y = (y / scale) + 106

			this:ClearAllPoints()
			this:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", x, y)
		end
	end
	if ( event == "LOOT_SLOT_CLEARED" ) then
		if ( not this:IsVisible() ) then
			return;
		end

		local numLootToShow = LOOTFRAME_NUMBUTTONS;
		if ( this.numLootItems > LOOTFRAME_NUMBUTTONS ) then
			numLootToShow = numLootToShow - 1;
		end
		local slot = arg1 - ((this.page - 1) * numLootToShow);
		if ( (slot > 0) and (slot < (numLootToShow + 1)) ) then
			local button = getglobal("LootButton"..slot);
			if ( button ) then
				button:Hide();
			end
		end
		-- try to move second page of loot items to the first page
		local button;
		local allButtonsHidden = 1;

		for index = 1, LOOTFRAME_NUMBUTTONS do
			button = getglobal("LootButton"..index);
			if ( button:IsVisible() ) then
				allButtonsHidden = nil;
			end
		end
		if ( allButtonsHidden and LootFrameDownButton:IsVisible() ) then
			LootFrame_PageDown();
		end
		return;
	end
	if ( event == "LOOT_CLOSED" ) then
		StaticPopup_Hide("LOOT_BIND");
		HideUIPanel(this);
		return;
	end
	if ( event == "OPEN_MASTER_LOOT_LIST" ) then
		LootFrame_UpdateRoster()
		if LootFrame.selectedLootButton ~= lastSelectedButton then
			DropDownList1:Hide()
			ToggleDropDownMenu(1, nil, GroupLootDropDown, LootFrame.selectedLootButton, 0, 0);
			lastSelectedButton = LootFrame.selectedLootButton
		else
			DropDownList1:Hide()
			lastSelectedButton = nil
		end
		return;
	end
	if ( event == "UPDATE_MASTER_LOOT_LIST" ) then
		UIDropDownMenu_Refresh(GroupLootDropDown);
	end
	if ( event == "RAID_ROSTER_UPDATE" ) then
		LootFrame_UpdateRoster()
	end
end

function LootFrame_UpdateRoster()
	for class in pairs(GroupRoster) do
		for i = getn(GroupRoster[class]), 1, -1 do
			tremove(GroupRoster[class], i)
		end
	end
	local class, name
	if UnitInRaid("player") then
		for i = 1, GetNumRaidMembers() do
			if GetRaidRosterInfo(i) then
				_, class = UnitClass("raid" .. i)
				name = GetRaidRosterInfo(i)
				tinsert(GroupRoster[class], name)
			end
		end
	elseif UnitInParty("player") then
		_, class = UnitClass("player")
		name = UnitName("player")
		tinsert(GroupRoster[class], name)
		for i = 1, GetNumPartyMembers() do
			if UnitName("party" .. i) then
				_, class = UnitClass("party" .. i)
				name = UnitName("party" .. i)
				tinsert(GroupRoster[class], name)
			end
		end
	end
	for k in pairs(GroupRoster) do
		sort(GroupRoster[k])
	end
end

function LootFrame_Update()
	local numLootItems = LootFrame.numLootItems;
	--Logic to determine how many items to show per page
	local numLootToShow = LOOTFRAME_NUMBUTTONS;
	if ( numLootItems > LOOTFRAME_NUMBUTTONS ) then
		numLootToShow = numLootToShow - 1;
	end
	local texture, item, quantity, quality;
	local button, countString, color;
	for index = 1, LOOTFRAME_NUMBUTTONS do
		button = getglobal("LootButton"..index);
		local slot = (numLootToShow * (LootFrame.page - 1)) + index;
		if ( slot <= numLootItems ) then
			if ( (LootSlotIsItem(slot) or LootSlotIsCoin(slot)) and index <= numLootToShow ) then
				texture, item, quantity, quality = GetLootSlotInfo(slot);
				color = ITEM_QUALITY_COLORS[quality];
				getglobal("LootButton"..index.."IconTexture"):SetTexture(texture);
				getglobal("LootButton"..index.."Text"):SetText(item);
				getglobal("LootButton"..index.."Text"):SetVertexColor(color.r, color.g, color.b);

				countString = getglobal("LootButton"..index.."Count");
				if ( quantity > 1 ) then
					countString:SetText(quantity);
					countString:Show();
				else
					countString:Hide();
				end
				button:SetSlot(slot);
				button.slot = slot;
				button.quality = quality;
				button:Show();
			else
				button:Hide();
			end
		else
			button:Hide();
		end
	end
	if ( LootFrame.page == 1 ) then
		LootFrameUpButton:Hide();
		LootFramePrev:Hide();
	else
		LootFrameUpButton:Show();
		LootFramePrev:Show();
	end
	if ( LootFrame.page == ceil(LootFrame.numLootItems / numLootToShow) or LootFrame.numLootItems == 0 ) then
		LootFrameDownButton:Hide();
		LootFrameNext:Hide();
	else
		LootFrameDownButton:Show();
		LootFrameNext:Show();
	end
end

function LootFrame_PageDown()
	LootFrame.page = LootFrame.page + 1;
	LootFrame_Update();
end

function LootFrame_PageUp()
	LootFrame.page = LootFrame.page - 1;
	LootFrame_Update();
end

function LootFrame_OnShow()
	this.numLootItems = GetNumLootItems();
	LootFrame_Update();
	LootFramePortraitOverlay:SetTexture("Interface\\TargetingFrame\\TargetDead");
	if( this.numLootItems == 0 ) then
		PlaySound("LOOTWINDOWOPENEMPTY");
	elseif( IsFishingLoot() ) then
		PlaySound("FISHING REEL IN");
		LootFramePortraitOverlay:SetTexture("Interface\\LootFrame\\FishingLoot-Icon");
	end
end

function LootFrame_OnHide()
	CloseLoot();
end

function LootFrameItem_OnClick(button)
	if ( IsControlKeyDown() ) then
		DressUpItemLink(GetLootSlotLink(this.slot));
	elseif ( IsShiftKeyDown() ) then
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:Insert(GetLootSlotLink(this.slot));
		end
	end
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");

	LootFrame.selectedLootButton = this:GetName();
	LootFrame.selectedSlot = this.slot;
	LootFrame.selectedQuality = this.quality;
	LootFrame.selectedItemName = getglobal(this:GetName().."Text"):GetText();
end

function GroupLootDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, GroupLootDropDown_Initialize, "MENU");
end

local function IsRaidMemberOffline(member)
	for i = 1, MAX_RAID_MEMBERS do
		if GetRaidRosterInfo(i) then
			local name, rank, subgroup, level, class, classToken, zone, online, isDead = GetRaidRosterInfo(i)
			if name == member and not online then
				return 1
			end
		end
	end
	return nil
end

local DropDownSorted = { "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR" }

function GroupLootDropDown_Initialize()
	local candidate, info;

	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		for _, player in ipairs(GroupRoster[UIDROPDOWNMENU_MENU_VALUE]) do
			for i = 1, MAX_RAID_MEMBERS do
				if ( player == GetMasterLootCandidate(i) )then
					info = UIDropDownMenu_CreateInfo()
					info.value = i
					info.text = player
					info.textHeight = 12
					info.notCheckable = 1
					info.textR = RAID_CLASS_COLORS[UIDROPDOWNMENU_MENU_VALUE].r
					info.textG = RAID_CLASS_COLORS[UIDROPDOWNMENU_MENU_VALUE].g
					info.textB = RAID_CLASS_COLORS[UIDROPDOWNMENU_MENU_VALUE].b
					info.disabled = IsRaidMemberOffline(player)
					info.func = GroupLootDropDown_GiveLoot
					UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
					break
				end
			end
		end
		return;
	end

	if ( GetNumRaidMembers() > 0 ) then
		-- In a raid
		info = UIDropDownMenu_CreateInfo();
		info.text = GIVE_LOOT;
		info.textHeight = 12;
		info.notCheckable = 1;
		info.isTitle = 1;
		UIDropDownMenu_AddButton(info);

		info.textHeight = 12
		info.notCheckable = 1
		info.hasArrow = 1
		info.isTitle = nil
		info.disabled = nil
		for _, classToken in ipairs(DropDownSorted) do
			info.text = GroupRoster[classToken].class
			info.textR = RAID_CLASS_COLORS[classToken].r
			info.textG = RAID_CLASS_COLORS[classToken].g
			info.textB = RAID_CLASS_COLORS[classToken].b
			info.value = classToken
			if getn(GroupRoster[classToken]) > 0 then
				UIDropDownMenu_AddButton(info)
			end
		end
	elseif ( GetNumPartyMembers() > 0 ) then
		-- In a party
		for i=1, MAX_PARTY_MEMBERS+1, 1 do
			candidate = GetMasterLootCandidate(i);
			if ( candidate ) then
				-- Add candidate button
				local class
				local unit
				if ( candidate == UnitName("player") ) then
					unit = "player"
				else
					for j = 1, 4 do
						if ( candidate == UnitName("party"..j) )then
							unit = "party"..j
							break
						end
					end
				end
				if ( unit ) then
					_, class = UnitClass(unit)
					info = UIDropDownMenu_CreateInfo();
					info.text = candidate;
					info.textR = RAID_CLASS_COLORS[class].r
					info.textG = RAID_CLASS_COLORS[class].g
					info.textB = RAID_CLASS_COLORS[class].b
					info.textHeight = 12;
					info.value = i;
					info.notCheckable = 1;
					info.func = GroupLootDropDown_GiveLoot;
					UIDropDownMenu_AddButton(info);
				end
			end
		end
	end
end

function GroupLootDropDown_GiveLoot()
	if ( LootFrame.selectedQuality >= MASTER_LOOT_THREHOLD ) then
		local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex..LootFrame.selectedItemName..FONT_COLOR_CODE_CLOSE, this:GetText());
		if ( dialog ) then
			dialog.data = this.value;
		end
	else
		GiveMasterLoot(LootFrame.selectedSlot, this.value);
	end
	CloseDropDownMenus();
end

function GroupLootFrame_OpenNewFrame(id, rollTime)
	local frame;
	for i=1, NUM_GROUP_LOOT_FRAMES do
		frame = getglobal("GroupLootFrame"..i);
		if ( not frame:IsVisible() ) then
			frame.rollID = id;
			frame.rollTime = rollTime;
			getglobal("GroupLootFrame"..i.."Timer"):SetMinMaxValues(0, rollTime);
			frame:Show();
			return;
		end
	end
end

function GroupLootFrame_OnShow()
	local texture, name, count, quality, bindOnPickUp = GetLootRollItemInfo(this.rollID);

	if ( bindOnPickUp ) then
		this:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } } );
		getglobal(this:GetName().."Corner"):SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Corner");
		getglobal(this:GetName().."Decoration"):Show();
	else
		this:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } } );
		getglobal(this:GetName().."Corner"):SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner");
		getglobal(this:GetName().."Decoration"):Hide();
	end

	getglobal("GroupLootFrame"..this:GetID().."IconFrameIcon"):SetTexture(texture);
	getglobal("GroupLootFrame"..this:GetID().."Name"):SetText(name);
	local color = ITEM_QUALITY_COLORS[quality];
	getglobal("GroupLootFrame"..this:GetID().."Name"):SetVertexColor(color.r, color.g, color.b);
end

function GroupLootFrame_OnEvent()
	if ( event == "CANCEL_LOOT_ROLL" ) then
		if ( arg1 == this.rollID ) then
			this:Hide();
		end
	end
end

function GroupLootFrame_OnUpdate()
	if ( this:IsVisible() ) then
		local left = GetLootRollTimeLeft(this:GetParent().rollID);
		local min, max = this:GetMinMaxValues();
		if ( (left < min) or (left > max) ) then
			left = min;
		end
		this:SetValue(left);
	end
end
