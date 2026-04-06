TWReportName = nil;

UNITPOPUP_TITLE_HEIGHT = 26;
UNITPOPUP_BUTTON_HEIGHT = 15;
UNITPOPUP_BORDER_HEIGHT = 8;
UNITPOPUP_BORDER_WIDTH = 19;

UNITPOPUP_NUMBUTTONS = 9;
UNITPOPUP_TIMEOUT = 5;

UNITPOPUP_SPACER_SPACING = 6;

UnitPopupButtons = {};
UnitPopupButtons["XP"] = { text = UNIT_POPUP_XP, dist = 0 };
UnitPopupButtons["MOVE"] = { text = UNIT_POPUP_MOVE, dist = 0 };
UnitPopupButtons["MOVE_RESET"] = { text = UNIT_POPUP_MOVE_RESET, dist = 0 };
UnitPopupButtons["CANCEL"] = { text = CANCEL, dist = 0, space = 1 };
UnitPopupButtons["TRADE"] = { text = TRADE, dist = 2 };
UnitPopupButtons["INSPECT"] = { text = INSPECT, dist = 1 };
UnitPopupButtons["TARGET"] = { text = TARGET, dist = 0 };
UnitPopupButtons["DUEL"] = { text = DUEL, dist = 3, space = 1 };
UnitPopupButtons["WHISPER"]	= { text = WHISPER, dist = 0 };
UnitPopupButtons["INVITE"]	= { text = PARTY_INVITE, dist = 0 };
UnitPopupButtons["UNINVITE"] = { text = PARTY_UNINVITE, dist = 0 };
UnitPopupButtons["PROMOTE"] = { text = PARTY_PROMOTE, dist = 0 };
UnitPopupButtons["GUILD_PROMOTE"] = { text = GUILD_PROMOTE, dist = 0 };
UnitPopupButtons["GUILD_LEAVE"] = { text = GUILD_LEAVE, dist = 0 };
UnitPopupButtons["LEAVE"] = { text = PARTY_LEAVE, dist = 0 };
UnitPopupButtons["FOLLOW"] = { text = FOLLOW, dist = 4 };
UnitPopupButtons["PET_PASSIVE"] = { text = PET_PASSIVE, dist = 0 };
UnitPopupButtons["PET_DEFENSIVE"] = { text = PET_DEFENSIVE, dist = 0 };
UnitPopupButtons["PET_AGGRESSIVE"] = { text = PET_AGGRESSIVE, dist = 0 };
UnitPopupButtons["PET_WAIT"] = { text = PET_WAIT, dist = 0 };
UnitPopupButtons["PET_FOLLOW"] = { text = PET_FOLLOW, dist = 0 };
UnitPopupButtons["PET_ATTACK"] = { text = PET_ATTACK, dist = 0 };
UnitPopupButtons["PET_DISMISS"] = { text = PET_DISMISS, dist = 0 };
UnitPopupButtons["PET_ABANDON"] = { text = PET_ABANDON, dist = 0 };
UnitPopupButtons["PET_PAPERDOLL"] = { text = PET_PAPERDOLL, dist = 0 };
UnitPopupButtons["PET_RENAME"] = { text = PET_RENAME, dist = 0 };
UnitPopupButtons["REPORT"] = { text = REPORT, dist = 0 };
UnitPopupButtons["IGNORE"] = { text = IGNORE_PLAYER, dist = 0 };
UnitPopupButtons["LOOT_METHOD"] = { text = LOOT_METHOD, dist = 0, nested = 1 };
UnitPopupButtons["FREE_FOR_ALL"] = { text = LOOT_FREE_FOR_ALL, dist = 0 };
UnitPopupButtons["ROUND_ROBIN"] = { text = LOOT_ROUND_ROBIN, dist = 0 };
UnitPopupButtons["MASTER_LOOTER"] = { text = LOOT_MASTER_LOOTER, dist = 0 };
UnitPopupButtons["GROUP_LOOT"] = { text = LOOT_GROUP_LOOT, dist = 0 };
UnitPopupButtons["NEED_BEFORE_GREED"] = { text = LOOT_NEED_BEFORE_GREED, dist = 0 };
UnitPopupButtons["RESET_INSTANCES"] = { text = RESET_INSTANCES, dist = 0 };

UnitPopupButtons["LOOT_THRESHOLD"] = { text = LOOT_THRESHOLD, dist = 0, nested = 1 };
UnitPopupButtons["LOOT_PROMOTE"] = { text = LOOT_PROMOTE, dist = 0 };
UnitPopupButtons["ITEM_QUALITY2_DESC"] = { text = ITEM_QUALITY2_DESC, dist = 0, color = ITEM_QUALITY_COLORS[2] };
UnitPopupButtons["ITEM_QUALITY3_DESC"] = { text = ITEM_QUALITY3_DESC, dist = 0, color = ITEM_QUALITY_COLORS[3] };
UnitPopupButtons["ITEM_QUALITY4_DESC"] = { text = ITEM_QUALITY4_DESC, dist = 0, color = ITEM_QUALITY_COLORS[4] };

UnitPopupButtons["RAID_LEADER"] = { text = NEW_LEADER, dist = 0 };
UnitPopupButtons["RAID_PROMOTE"] = { text = PROMOTE, dist = 0 };
UnitPopupButtons["RAID_DEMOTE"] = { text = DEMOTE, dist = 0 };
UnitPopupButtons["RAID_REMOVE"] = { text = REMOVE, dist = 0 };

UnitPopupButtons["RAID_TARGET_ICON"] = { text = RAID_TARGET_ICON, dist = 0, nested = 1 };
UnitPopupButtons["RAID_TARGET_1"] = { text = RAID_TARGET_1, dist = 0, checkable = 1, color = {r = 1.0, g = 0.92, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0, tCoordRight = 0.25, tCoordTop = 0, tCoordBottom = 0.25 };
UnitPopupButtons["RAID_TARGET_2"] = { text = RAID_TARGET_2, dist = 0, checkable = 1, color = {r = 0.98, g = 0.57, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.25, tCoordRight = 0.5, tCoordTop = 0, tCoordBottom = 0.25 };
UnitPopupButtons["RAID_TARGET_3"] = { text = RAID_TARGET_3, dist = 0, checkable = 1, color = {r = 0.83, g = 0.22, b = 0.9}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.5, tCoordRight = 0.75, tCoordTop = 0, tCoordBottom = 0.25 };
UnitPopupButtons["RAID_TARGET_4"] = { text = RAID_TARGET_4, dist = 0, checkable = 1, color = {r = 0.04, g = 0.95, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.75, tCoordRight = 1, tCoordTop = 0, tCoordBottom = 0.25 };
UnitPopupButtons["RAID_TARGET_5"] = { text = RAID_TARGET_5, dist = 0, checkable = 1, color = {r = 0.7, g = 0.82, b = 0.875}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0, tCoordRight = 0.25, tCoordTop = 0.25, tCoordBottom = 0.5 };
UnitPopupButtons["RAID_TARGET_6"] = { text = RAID_TARGET_6, dist = 0, checkable = 1, color = {r = 0, g = 0.71, b = 1}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.25, tCoordRight = 0.5, tCoordTop = 0.25, tCoordBottom = 0.5 };
UnitPopupButtons["RAID_TARGET_7"] = { text = RAID_TARGET_7, dist = 0, checkable = 1, color = {r = 1.0, g = 0.24, b = 0.168}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.5, tCoordRight = 0.75, tCoordTop = 0.25, tCoordBottom = 0.5 };
UnitPopupButtons["RAID_TARGET_8"] = { text = RAID_TARGET_8, dist = 0, checkable = 1, color = {r = 0.98, g = 0.98, b = 0.98}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.75, tCoordRight = 1, tCoordTop = 0.25, tCoordBottom = 0.5 };
UnitPopupButtons["RAID_TARGET_NONE"] = { text = NONE, dist = 0, checkable = 1, };

-- First level menus
UnitPopupMenus = {};
UnitPopupMenus["SELF"] = { "LOOT_METHOD", "LOOT_THRESHOLD", "LOOT_PROMOTE", "LEAVE", "RESET_INSTANCES", "RAID_TARGET_ICON", "XP", "MOVE", "MOVE_RESET", "CANCEL" };
UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
UnitPopupMenus["PARTY"] = { "WHISPER", "PROMOTE", "LOOT_PROMOTE", "UNINVITE", "INSPECT", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "REPORT", "IGNORE", "MOVE", "MOVE_RESET", "CANCEL" };
UnitPopupMenus["PLAYER"] = { "WHISPER", "PROMOTE", "LOOT_PROMOTE", "UNINVITE", "INSPECT", "INVITE", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "REPORT", "IGNORE", "MOVE", "MOVE_RESET", "CANCEL" };
UnitPopupMenus["RAID"] = { "RAID_LEADER", "LOOT_PROMOTE", "RAID_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "REPORT", "IGNORE", "CANCEL" };
UnitPopupMenus["FRIEND"] = { "WHISPER", "INVITE", "TARGET", "GUILD_PROMOTE", "GUILD_LEAVE", "REPORT", "IGNORE", "CANCEL" };
UnitPopupMenus["RAID_TARGET_ICON"] = { "RAID_TARGET_1", "RAID_TARGET_2", "RAID_TARGET_3", "RAID_TARGET_4", "RAID_TARGET_5", "RAID_TARGET_6", "RAID_TARGET_7", "RAID_TARGET_8", "RAID_TARGET_NONE" };

-- Second level menus
UnitPopupMenus["LOOT_METHOD"] = { "FREE_FOR_ALL", "ROUND_ROBIN", "MASTER_LOOTER", "GROUP_LOOT", "NEED_BEFORE_GREED", "CANCEL" };
UnitPopupMenus["LOOT_THRESHOLD"] = { "ITEM_QUALITY2_DESC", "ITEM_QUALITY3_DESC", "ITEM_QUALITY4_DESC", "CANCEL" };

UnitPopupShown = {};
UnitPopupShown[1] = {};
UnitPopupShown[2] = {};
UnitPopupShown[3] = {};

UnitLootMethod = {};
UnitLootMethod["freeforall"] = { text = LOOT_FREE_FOR_ALL, tooltipText = NEWBIE_TOOLTIP_UNIT_FREE_FOR_ALL };
UnitLootMethod["roundrobin"] = { text = LOOT_ROUND_ROBIN, tooltipText = NEWBIE_TOOLTIP_UNIT_ROUND_ROBIN };
UnitLootMethod["master"] = { text = LOOT_MASTER_LOOTER, tooltipText = NEWBIE_TOOLTIP_UNIT_MASTER_LOOTER };
UnitLootMethod["group"] = { text = LOOT_GROUP_LOOT, tooltipText = NEWBIE_TOOLTIP_UNIT_GROUP_LOOT };
UnitLootMethod["needbeforegreed"] = { text = LOOT_NEED_BEFORE_GREED, tooltipText = NEWBIE_TOOLTIP_UNIT_NEED_BEFORE_GREED };


UnitPopupFrames = {
	"PlayerFrameDropDown",
	"TargetFrameDropDown",
	"PartyMemberFrame1DropDown",
	"PartyMemberFrame2DropDown",
	"PartyMemberFrame3DropDown",
	"PartyMemberFrame4DropDown",
	"FriendsDropDown"
};

function UnitPopup_OnLoad()
	this:RegisterEvent("CHAT_MSG_SYSTEM");
	this:RegisterEvent("PLAYER_LOGIN");
	this.xp = true;
end

function UnitPopup_OnEvent()
	if ( event == "CHAT_MSG_SYSTEM" ) then
		if ( arg1 == "XP gain is ON" or arg1 == "XP gain is now ON" ) then
			this.xp = true;
			UnitPopupButtons["XP"].text = GREEN_FONT_COLOR_CODE .. UNIT_POPUP_XP_ON;
		end
		if ( arg1 == "XP gain is OFF" or arg1 == "XP gain is now OFF" ) then
			this.xp = false;
			UnitPopupButtons["XP"].text = RED_FONT_COLOR_CODE .. UNIT_POPUP_XP_OFF;
		end
		return;
	end
	if ( event == "PLAYER_LOGIN" ) then
		SendChatMessage(".xp", "GUILD");
		return;
	end
end

function UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData)
	-- Init variables
	local server;
	dropdownMenu.which = which;
	dropdownMenu.unit = unit;
	if ( unit and not name ) then
		name, server = UnitName(unit, true);
	end
	dropdownMenu.name = name;
	dropdownMenu.userData = userData;
	dropdownMenu.server = server;

	-- Determine which buttons should be shown or hidden
	UnitPopup_HideButtons();

	-- If only one menu item (the cancel button) then don't show the menu
	local count = 0;
	for index, value in ipairs(UnitPopupMenus[which]) do
		if ( UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] == 1 and value ~= "CANCEL" ) then
			count = count + 1;
		end
	end
	if ( count < 1 ) then
		return;
	end

	local lootMethod = GetLootMethod();
	local lootThreshold = GetLootThreshold();
	-- Determine which loot method and which loot threshold are selected and set the corresponding buttons to the same text
	dropdownMenu.selectedLootMethod = UnitLootMethod[lootMethod].text;
	dropdownMenu.selectedLootThreshold = _G["ITEM_QUALITY"..lootThreshold.."_DESC"];
	UnitPopupButtons["LOOT_METHOD"].text = dropdownMenu.selectedLootMethod;
	UnitPopupButtons["LOOT_METHOD"].tooltipText = UnitLootMethod[lootMethod].tooltipText;
	UnitPopupButtons["LOOT_THRESHOLD"].text = dropdownMenu.selectedLootThreshold;
	-- This allows player to view loot settings if he's not the leader
	if ( IsPartyLeader() ) then
		UnitPopupButtons["LOOT_METHOD"].nested = 1;
		UnitPopupButtons["LOOT_THRESHOLD"].nested = 1;
	else
		UnitPopupButtons["LOOT_METHOD"].nested = nil;
		UnitPopupButtons["LOOT_THRESHOLD"].nested = nil;
	end

	-- If level 2 dropdown
	local info;
	local color;
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		dropdownMenu.which = UIDROPDOWNMENU_MENU_VALUE;
		-- Set which menu is being opened
		if not OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] then OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] = {} end
		OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL].which = UIDROPDOWNMENU_MENU_VALUE;
		OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL].name = name;
		OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL].unit = unit;
		OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL].userData = userData;
		OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL].server = server;

		for index, value in ipairs(UnitPopupMenus[UIDROPDOWNMENU_MENU_VALUE]) do
			info = UIDropDownMenu_CreateInfo();
			info.text = UnitPopupButtons[value].text;
			info.owner = UIDROPDOWNMENU_MENU_VALUE;
			-- Set the text color
			color = UnitPopupButtons[value].color;
			if ( color ) then
				info.textR = color.r;
				info.textG = color.g;
				info.textB = color.b;
			end
			-- Icons
			info.icon = UnitPopupButtons[value].icon;
			info.tCoordLeft = UnitPopupButtons[value].tCoordLeft;
			info.tCoordRight = UnitPopupButtons[value].tCoordRight;
			info.tCoordTop = UnitPopupButtons[value].tCoordTop;
			info.tCoordBottom = UnitPopupButtons[value].tCoordBottom;
			-- Checked conditions
			if ( info.text == dropdownMenu.selectedLootMethod  ) then
				info.checked = 1;
			elseif ( info.text == dropdownMenu.selectedLootThreshold ) then
				info.checked = 1;
			elseif ( strsub(value, 1, 12) == "RAID_TARGET_" ) then
				info.checked = unit and GetRaidTargetIndex(unit) == index;
			end

			info.value = value;
			info.func = UnitPopup_OnClick;
			-- Setup newbie tooltips
			info.tooltipTitle = UnitPopupButtons[value].text;
			info.tooltipText = _G["NEWBIE_TOOLTIP_UNIT_"..value];
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		end
		return;
	end

	-- Add dropdown title
	if ( unit or name ) then
		info = UIDropDownMenu_CreateInfo();
		info.text = name or UNKNOWN;
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end

	-- Set which menu is being opened
	if not OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] then OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] = {} end
	OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL].which = which;
	OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL].name = name;
	OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL].unit = unit;
	OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL].userData = userData;
	OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL].server = server;

	-- Show the buttons which are used by this menu
	for index, value in ipairs(UnitPopupMenus[which]) do
		if ( UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] == 1 ) then
			info = UIDropDownMenu_CreateInfo();
			info.text = UnitPopupButtons[value].text;
			if ( value == "MOVE" ) then
				if ( dropdownMenu.unit == "player" ) then
					info.text = PlayerFrame.movable and UNIT_POPUP_FRAME_LOCK or UNIT_POPUP_FRAME_UNLOCK
				elseif ( dropdownMenu.unit == "target" ) then
					info.text = TargetFrame.movable and UNIT_POPUP_FRAME_LOCK or UNIT_POPUP_FRAME_UNLOCK
				end
			end
			info.value = value;
			info.owner = which;
			info.func = UnitPopup_OnClick;
			if ( not UnitPopupButtons[value].checkable ) then
				info.notCheckable = 1;
			end
			-- Text color
			if ( value == "LOOT_THRESHOLD" ) then
				-- Set the text color
				color = ITEM_QUALITY_COLORS[lootThreshold];
				info.textR = color.r;
				info.textG = color.g;
				info.textB = color.b;
			else
				color = UnitPopupButtons[value].color;
				if ( color ) then
					info.textR = color.r;
					info.textG = color.g;
					info.textB = color.b;
				end
			end
			-- Icons
			info.icon = UnitPopupButtons[value].icon;
			info.tCoordLeft = UnitPopupButtons[value].tCoordLeft;
			info.tCoordRight = UnitPopupButtons[value].tCoordRight;
			info.tCoordTop = UnitPopupButtons[value].tCoordTop;
			info.tCoordBottom = UnitPopupButtons[value].tCoordBottom;
			-- Checked conditions
			if ( strsub(value, 1, 12) == "RAID_TARGET_" ) then
				info.checked = unit and GetRaidTargetIndex("target") == index;
			end
			if ( UnitPopupButtons[value].nested ) then
				info.hasArrow = 1;
			end

			-- Setup newbie tooltips
			info.tooltipTitle = info.text;
			info.tooltipText = _G["NEWBIE_TOOLTIP_UNIT_"..value] or UnitPopupButtons[value].tooltipText;
			UIDropDownMenu_AddButton(info);
		end
	end
	PlaySound("igMainMenuOpen");
end

function UnitPopup_HideButtons()
	local dropdownMenu = _G[UIDROPDOWNMENU_INIT_MENU];
	local which = dropdownMenu.which;
	local unit = dropdownMenu.unit;
	local name = dropdownMenu.name;
	local userData = dropdownMenu.userData;

	local playerName = UnitName("player");
	local inParty = GetNumPartyMembers() + GetNumRaidMembers() > 0;
	local isLeader = IsPartyLeader();
	local isAssistant = IsRaidOfficer();
	local isGuildLeader = IsGuildLeader();
	local canCoop = unit and UnitCanCooperate("player", unit);
	local unitInRaidOrParty = unit and (UnitInRaid(unit) or UnitInParty(unit));
	local _, rank = GetRaidRosterInfo(userData or 0);
	local canAbandonPet = PetCanBeAbandoned();
	local canRenamePet = PetCanBeRenamed();
	local guildFrame = GuildFrame and GuildFrame:IsVisible();
	local noRaidMarks = UnitExists("target") and not UnitPlayerOrPetInParty("target") and not UnitPlayerOrPetInRaid("target")
						and UnitIsPlayer("target") and (not UnitCanCooperate("player", "target") and not UnitIsUnit("target", "player"));

	local lootMethod, partyIndex, raidIndex = GetLootMethod();
	local masterName;
	if ( lootMethod == "master" ) then
		if ( partyIndex ) then
			masterName = partyIndex == 0 and playerName or UnitName("party"..partyIndex);
		elseif ( raidIndex ) then
			masterName = UnitName("raid"..raidIndex);
		end
	end

	for index, value in ipairs(UnitPopupMenus[which]) do
		UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 1;

		if ( value == "INVITE" ) then
			if ( name == UnitName("party1") or name == UnitName("party2") or
				name == UnitName("party3") or name == UnitName("party4") or
				name == playerName or (unit and unitInRaidOrParty) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "REPORT" or value == "IGNORE" or value == "WHISPER") then
			if ( name == playerName ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "FOLLOW" or value == "INSPECT" ) then
			if ( not canCoop or name == playerName ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PROMOTE" or value == "UNINVITE" ) then
			if ( not inParty or not isLeader or not (unit and unitInRaidOrParty) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "GUILD_PROMOTE" ) then
			if ( not isGuildLeader or name == playerName or not guildFrame ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "GUILD_LEAVE" ) then
			if ( name ~= playerName or not guildFrame ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "LEAVE" or value == "LOOT_THRESHOLD" or value == "LOOT_METHOD" ) then
			if ( not inParty ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "FREE_FOR_ALL" ) then
			if ( not inParty or (not isLeader and lootMethod ~= "freeforall") ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "ROUND_ROBIN" ) then
			if ( not inParty or (not isLeader and lootMethod ~= "roundrobin") ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "MASTER_LOOTER" ) then
			if ( not inParty or (not isLeader and lootMethod ~= "master") ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "GROUP_LOOT" ) then
			if ( not inParty or (not isLeader and lootMethod ~= "group") ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "NEED_BEFORE_GREED" ) then
			if ( not inParty or (not isLeader and lootMethod ~= "needbeforegreed") ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "LOOT_PROMOTE" ) then
			if ( (not inParty) or (not isLeader) or (lootMethod ~= "master") or (masterName == name) or (not unitInRaidOrParty) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "RAID_LEADER" ) then
			if ( not isLeader or rank == 2 or not name ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "RAID_PROMOTE" ) then
			if ( not isLeader or rank ~= 0 or not name ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "RAID_DEMOTE" ) then
			if ( not isLeader or rank ~= 1 or not name ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "RAID_REMOVE" ) then
			if ( (not isLeader and not isAssistant) or rank == 2 ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PET_PAPERDOLL" or value == "PET_ABANDON" ) then
			if ( not canAbandonPet ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PET_RENAME" ) then
			if ( not canAbandonPet or not canRenamePet ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PET_DISMISS" ) then
			if ( canAbandonPet ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( strsub(value, 1, 12) == "RAID_TARGET_" ) then
			if ( (not inParty) or (not isLeader and not isAssistant) or (which ~= "SELF" and noRaidMarks) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "MOVE" or value == "MOVE_RESET" ) then
			if ( dropdownMenu ~= PlayerFrameDropDown and dropdownMenu ~= TargetFrameDropDown ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		end
	end
end

function UnitPopup_OnUpdate(elapsed)
	if ( not DropDownList1:IsVisible() ) then
		return;
	end
	-- If none of the untipopup frames are visible then return
	local n = getn(UnitPopupFrames);
	for i=1, n do
		if ( UIDROPDOWNMENU_OPEN_MENU == UnitPopupFrames[i] ) then
			break;
		elseif ( i == n ) then
			return;
		end
	end

	local inParty = GetNumPartyMembers() + GetNumRaidMembers() > 0;
	local isLeader = IsPartyLeader();
	local isAssistant = IsRaidOfficer();

	-- Loop through all menus and enable/disable their buttons appropriately
	for level, dropdownFrame in ipairs(OPEN_DROPDOWNMENUS) do
		if ( dropdownFrame.which ) then
			local count = 0;
			local unit = dropdownFrame.unit;
			local name = dropdownFrame.name;
			for index, value in pairs(UnitPopupMenus[dropdownFrame.which]) do
				if ( UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] == 1 ) then
					count = count + 1;
					local enable = true;
					local dist = UnitPopupButtons[value].dist;

					if ( unit and dist > 0 ) then
						if ( not CheckInteractDistance(unit, dist) ) then
							enable = false;
						end
					end

					if ( value == "TRADE" or value == "DUEL" ) then
						if ( UnitIsDeadOrGhost("player") or (unit and UnitIsDeadOrGhost(unit)) or not HasFullControl() ) then
							enable = false;
						end
					elseif ( value == "LEAVE" ) then
						if ( not inParty ) then
							enable = false;
						end
					elseif ( value == "INVITE" ) then
						if ( inParty and (not isLeader and not isAssistant)) then
							enable = false;
						end
					elseif ( value == "UNINVITE" ) then
						if ( not inParty or not isLeader ) then
							enable = false;
						end
					elseif ( value == "PROMOTE" ) then
						if ( not inParty or not isLeader or (unit and not UnitIsConnected(unit)) or (isLeader and name == UnitName("player")) ) then
							enable = false;
						end
					elseif ( value == "WHISPER" ) then
						if ( unit and not UnitIsConnected(unit) ) then
							enable = false;
						end
					elseif ( value == "INSPECT" ) then
						if ( UnitIsDeadOrGhost("player") ) then
							enable = false;
						end
					elseif ( value == "FOLLOW" ) then
						if ( UnitIsDead("player") ) then
							enable = false;
						end
					elseif ( value == "LOOT_PROMOTE" ) then
						local lootMethod, partyIndex, raidIndex = GetLootMethod();
						if ( not inParty or not isLeader or lootMethod ~= "master" ) then
							enable = false;
						else
							local master;
							if ( partyIndex == 0 ) then
								master = "player";
							elseif ( partyIndex ) then
								master = "party"..partyIndex;
							elseif ( raidIndex ) then
								master = "raid"..raidIndex;
							end
							if ( unit and master and UnitIsUnit(unit, master) ) then
								enable = false;
							end
						end
					end

					local button;
					if ( level > 1 ) then
						button = count;
					else
						button = count + 1;
					end

					if ( enable ) then
						UIDropDownMenu_EnableButton(level, button);
					else
						UIDropDownMenu_DisableButton(level, button);
					end
				end
			end
		end
	end
end

function UnitPopup_OnClick()
	local dropdownFrame = _G[UIDROPDOWNMENU_INIT_MENU];
	local button = this.value;
	local unit = dropdownFrame.unit;
	local name = dropdownFrame.name;
	local server = dropdownFrame.server;

	if ( button == "TRADE" ) then
		InitiateTrade(unit);
	elseif ( button == "WHISPER" ) then
		if ( server ) then
			ChatFrame_SendTell(name.."-"..server);
		else
			ChatFrame_SendTell(name);
		end
	elseif ( button == "INSPECT" ) then
		InspectUnit(unit);
	elseif ( button == "TARGET" ) then
		TargetByName(name, 1);
	elseif ( button == "DUEL" ) then
		StartDuelUnit(unit);
	elseif ( button == "INVITE" ) then
		if ( unit ) then
			InviteToParty(unit);
		else
			InviteByName(name);
		end
	elseif ( button == "UNINVITE" ) then
		UninviteFromParty(unit);
	elseif ( button == "PROMOTE" ) then
		PromoteToPartyLeader(unit);
	elseif ( button == "GUILD_PROMOTE" ) then
		local dialog = StaticPopup_Show("CONFIRM_GUILD_PROMOTE", name);
		dialog.data = name;
	elseif ( button == "GUILD_LEAVE" ) then
		StaticPopup_Show("CONFIRM_GUILD_LEAVE", GetGuildInfo("player"));
	elseif ( button == "LEAVE" ) then
		LeaveParty();
	elseif ( button == "XP" ) then
		if ( UnitPopup.xp ) then
			StaticPopup_Show("CONFIRM_TOGGLE_XP_OFF");
		else
			StaticPopup_Show("CONFIRM_TOGGLE_XP_ON");
		end
	elseif ( button == "REPORT" ) then
		TWReportName = name;
		ToggleHelpFrame();
	elseif ( button == "IGNORE" ) then
		AddIgnore(name);
	elseif ( button == "MOVE" ) then
		local frame;
		if ( unit == "player" )  then
			frame = PlayerFrame;
		elseif ( unit == "target" )  then
			frame = TargetFrame;
		end
		if ( frame.movable ) then
			frame.movable = nil;
		else
			frame.movable = 1;
		end
	elseif ( button == "MOVE_RESET" ) then
		if ( unit == "player" ) then
			PlayerFrame:SetPoint("TOPLEFT", -19, -4)
		elseif ( unit == "target") then
			TargetFrame:SetPoint("TOPLEFT", 250, -4)
		end
	elseif ( button == "PET_PASSIVE" ) then
		PetPassiveMode();
	elseif ( button == "PET_DEFENSIVE" ) then
		PetDefensiveMode();
	elseif ( button == "PET_AGGRESSIVE" ) then
		PetAggressiveMode();
	elseif ( button == "PET_WAIT" ) then
		PetWait();
	elseif ( button == "PET_FOLLOW" ) then
		PetFollow();
	elseif ( button == "PET_ATTACK" ) then
		PetAttack();
	elseif ( button == "PET_DISMISS" ) then
		PetDismiss();
	elseif ( button == "PET_ABANDON" ) then
		StaticPopup_Show("ABANDON_PET");
	elseif ( button == "PET_PAPERDOLL" ) then
		ToggleCharacter("PetPaperDollFrame");
	elseif ( button == "PET_RENAME" ) then
		StaticPopup_Show("RENAME_PET");
	elseif ( button == "FREE_FOR_ALL" ) then
		SetLootMethod("freeforall");
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "ROUND_ROBIN" ) then
		SetLootMethod("roundrobin");
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "MASTER_LOOTER" ) then
		SetLootMethod("master", name);
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "GROUP_LOOT" ) then
		SetLootMethod("group");
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "NEED_BEFORE_GREED" ) then
		SetLootMethod("needbeforegreed");
		UIDropDownMenu_SetButtonText(1, 2, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "LOOT_PROMOTE" ) then
		SetLootMethod("master", name);
	elseif ( button == "RESET_INSTANCES" ) then
		StaticPopup_Show("CONFIRM_RESET_INSTANCES");
	elseif ( button == "FOLLOW" ) then
		FollowByName(name, 1);
	elseif ( button == "RAID_LEADER" ) then
		PromoteByName(name);
	elseif ( button == "RAID_PROMOTE" ) then
		PromoteToAssistant(name);
	elseif ( button == "RAID_DEMOTE" ) then
		DemoteAssistant(name);
	elseif ( button == "RAID_REMOVE" ) then
		UninviteFromRaid(dropdownFrame.userData);
	elseif ( button == "ITEM_QUALITY2_DESC" or button == "ITEM_QUALITY3_DESC" or button == "ITEM_QUALITY4_DESC" ) then
		SetLootThreshold(this:GetID()+1);
		local color = ITEM_QUALITY_COLORS[this:GetID()+1];
		UIDropDownMenu_SetButtonText(1, 3, UnitPopupButtons[button].text, color.r, color.g, color.b);
	elseif ( strsub(button, 1, 12) == "RAID_TARGET_" and button ~= "RAID_TARGET_ICON" ) then
		local raidTargetIndex = strsub(button, 13);
		if ( raidTargetIndex == "NONE" ) then
			raidTargetIndex = 0;
		end
		SetRaidTargetIcon(unit, tonumber(raidTargetIndex));
	end
	PlaySound("UChatScrollButton");
end
