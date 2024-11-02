LFT_MIN_FINDER_LEVEL = 13

LFT_ADDON_PREFIX = "TW_LFG"
LFT_ADDON_CHANNEL = "GUILD"
LFT_ADDON_ARRAY_DELIMITER = ":"
LFT_ADDON_FIELD_DELIMITER = ";"

-- localization
LFT_CHAT_ERROR_COMBINATION_MSG = "LFT: Invalid party role combination. Make sure\'s there is 1 tank, 1 healer and 3 damage dealers."
LFT_CHAT_ERROR_INTERNAL_MSG = "LFT has encountered an internal error."
LFT_CHAT_ERROR_LEADER_MSG = "LFT: You are not the leader of the party."
LFT_CHAT_ERROR_MISMATCH_MSG = "LFT: Party members levels mismatch."
LFT_CHAT_OFFER_DECLINED_TEXT = "You have declined the offer. You have been removed from the queue."
LFT_CHAT_QUEUE_JOIN_TEXT = "You have joined the queue."
LFT_CHAT_SELECTED_ROLES_TEXT = " has selected these roles: "

LFT_DROPDOWN_TYPE_1 = "Suggested Dungeons"
LFT_DROPDOWN_TYPE_2 = "All Available Dungeons"
LFT_DROPDOWN_LABEL_TEXT = "Type:"

LFT_GENERAL_BROWSE_TAB_TEXT = "Browse"
LFT_GENERAL_LEAVE_QUEUE_TEXT = "Leave Queue"
LFT_GENERAL_LOW_LEVEL_TEXT = "Reach level 13 to use this feature."
LFT_GENERAL_INSTANCE_TYPE_TEXT = "Type:"
LFT_GENERAL_IN_RAID_TEXT = "You can\'t use the group finder while in a raid."

LFT_GROUP_READY_GROUP_FORMED_TEXT = "A group has been formed for:"
LFT_GROUP_READY_YOUR_ROLE_TEXT = "Your Role"
LFT_GROUP_READY_CONFIRM_TEXT = "Let\'s do this!"
LFT_GROUP_READY_STATUS_TEXT = "Ready check"
LFT_GROUP_READY_COMPLETE_TEXT = "The dungeon group is ready. Enjoy!"

LFT_ROLE_CHECK_TITLE_TEXT = "Role check"
LFT_ROLE_CHECK_CONFIRM_TEXT = "Confirm"
LFT_ROLE_CHECK_DECLINE_TEXT = "Decline"
LFT_ROLE_CHECK_INSTANCES_TEXT = "Queued for: "
LFT_ROLE_CHECK_MULTIPLE_INSTANCES_TEXT = "Queued for |cffffffffmultiple instances"

LFT_MAIN_BUTTON_FIND_GROUP_TEXT = "Find Group"
LFT_MAIN_BUTTON_FIND_MORE_TEXT = "Find More"

LFT_MINIMAP_TOOLTIP_LINE_1 = "Group Finder"
LFT_MINIMAP_TOOLTIP_LINE_2 = "Left-click to open the group finder."
LFT_MINIMAP_TOOLTIP_LINE_3 = "Hold control and drag to move."
LFT_MINIMAP_TOOLTIP_LINE_4 = "Hold control and right-click to reset position."
LFT_MINIMAP_TOOLTIP_NO_QUEUE = "You are not looking for any groups."
LFT_MINIMAP_TOOLTIP_QUEUED = "You are queued for: "


LFT_ROLE_TANK_TOOLTIP = "Indicates that you are willing to\nprotect allies from harm by\nensuring that enemies are\nattacking you instead of them."
LFT_ROLE_HEALER_TOOLTIP = "Indicates that you are willing to\nheal your allies when they take\ndamage."
LFT_ROLE_DAMAGE_TOOLTIP = "Indicates that you are willing to\ntake on the role of dealing\ndamage to enemies."

-- define instance type dropdown menu items
LFT_DropDownItems = {
	[1] = LFT_DROPDOWN_TYPE_1,
	[2] = LFT_DROPDOWN_TYPE_2,
}

-- create LFT frame and register events
LFT = CreateFrame("Frame")
LFT:RegisterEvent("CHAT_MSG_ADDON")
LFT:RegisterEvent("CHAT_MSG_SYSTEM")
LFT:RegisterEvent("PARTY_MEMBERS_CHANGED")
LFT:RegisterEvent("PARTY_LEADER_CHANGED")
LFT:RegisterEvent("PLAYER_ENTERING_WORLD")
LFT:RegisterEvent("PLAYER_LEVEL_UP")
LFT:RegisterEvent("PLAYER_TARGET_CHANGED")
LFT:RegisterEvent("UNIT_LEVEL")
LFT:RegisterEvent("VARIABLES_LOADED")

-- local variables
local COLOR_RED = "|cffff222a"
local COLOR_ORANGE = "|cffff8000"
local COLOR_GREEN = "|cff1fba1f"
local COLOR_HUNTER = "|cffabd473"
local COLOR_YELLOW = "|cffffff00"
local COLOR_WHITE = "|cffffffff"
local COLOR_DISABLED = "|cffaaaaaa"
local COLOR_DISABLED2 = "|cff666666"
local COLOR_TANK = "|cff0070de"

local inQueue = false
local selectedInstances = {}
local selectedRoles = {
	["TANK"] = false,
	["HEALER"] = false,
	["DAMAGE"] = false,
}

-- utils
local function stringsplit(str, delimiter)
	local result = {}
	local from  = 1
	local delim_from, delim_to = string.find(str, delimiter,from)
	while delim_from do
		table.insert(result, string.sub(str, from, delim_from - 1))
	  	from  = delim_to + 1
	  	delim_from, delim_to = string.find(str, delimiter, from)
	end
	table.insert(result, string.sub(str, from))
	return result
end

local function customSort(t)
	local a = {}
	for n, l in pairs(t) do
		table.insert(a, { ["code"] = l.code, ["minLevel"] = l.minLevel, ["name"] = n })
	end

	table.sort(a, function(a, b)
		return a["minLevel"] < b["minLevel"]
	end)

	local i = 0 -- iterator variable
	local iter = function()
		-- iterator function
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i]["name"], t[a[i]["name"]]
		end
	end
	return iter
end

local function GetRoleFromCode(code)
	code = string.upper(code)
	if code == "T" then
		return "TANK"
	elseif code == "H" then
		return "HEALER"
	elseif code == "D" then
		return "DAMAGE"
	end
end

-- delay frame for various uses
local LFTDelay = CreateFrame("Frame")
LFTDelay:Hide()

local function LFT_Delay(time, func)
	LFTDelay:SetScript("OnUpdate", function()
		this.elapsed = this.elapsed or 0
		if this.elapsed >= time then
			this.elapsed = 0

			func()

			this:SetScript("OnUpdate", nil)
			this:Hide()
		end
		this.elapsed = this.elapsed + arg1
	end)

	LFTDelay:Show()
end

-- handle various messages sent by the server via
-- the guild channel
local function LFT_HandleMessageFromServer(message)
	-- sent when the player or group leader joins the
	-- queue
	if strfind(message, "S2C_QUEUE_JOINED") then
		LFT_OnQueueEnter()

		DEFAULT_CHAT_FRAME:AddMessage(LFT_CHAT_QUEUE_JOIN_TEXT)
	end

	-- sent when the player or group leader leaves
	-- the queue
	if strfind(message, "S2C_QUEUE_LEFT") then
		LFT_OnQueueLeave(true)
	end

	-- sent when a group has been found and the player
	-- has to confirm that they're ready
	if strfind(message, "S2C_OFFER_NEW") then
		local params = stringsplit(message, LFT_ADDON_FIELD_DELIMITER)

		LFT_GroupReadyShow(params[2], params[3])
	end

	-- sent when a group member confirms their role
	-- during a ready check
	if strfind(message, "S2C_OFFER_UPDATE_COUNT") then
		local params = strsub(message, strlen("S2C_OFFER_UPDATE_COUNT") + 2) -- remove message type
		params = stringsplit(params, ":") -- get confirmed roles

		LFT_GroupReadyStatusUpdate(false, params[1], params[2], params[3])
	end

	-- sent when every group member confirms their
	-- ready status after a group has been found
	if strfind(message, "S2C_OFFER_COMPLETE") then
		LFT_GroupReadyStatusUpdate(true)
	end

	-- sent when a party leader initiates a role check
	if strfind(message, "S2C_ROLECHECK_START") then
		local params = strsub(message, strlen("S2C_ROLECHECK_START") + 2) -- remove message type
		params = stringsplit(params, ":") -- get queued instances

		LFT_RoleCheckStart(params)
	end

	-- sent when a group member confirms their role
	-- during a role check
	if strfind(message, "S2C_ROLECHECK_INFO") then
		if GetNumPartyMembers() > 0 then
			local params = stringsplit(message, LFT_ADDON_FIELD_DELIMITER)
			local member = params[2] -- name of the group member who confirmed their role
			local roles = ""
			params = stringsplit(params[3], ":") -- get confirmed roles
			for i = 1, table.getn(params) do
				roles = roles .. COLOR_YELLOW .. string.gsub(string.lower(GetRoleFromCode(params[i])), "^%l", string.upper) .. COLOR_WHITE .. ", "
			end

			roles = string.sub(roles, 1, -3)

			DEFAULT_CHAT_FRAME:AddMessage(COLOR_YELLOW .. member .. COLOR_WHITE .. LFT_CHAT_SELECTED_ROLES_TEXT .. roles)
		end
	end

	-- sent when an error is encountered - has
	-- multiple error definitions
	if strfind(message, "S2C_QUEUE_ERROR") then
		local err = strsub(message, strlen("S2C_QUEUE_ERROR") + 2)

		-- print a message based on the error
		if strfind(err, "not_leader") then
			DEFAULT_CHAT_FRAME:AddMessage(COLOR_RED .. LFT_CHAT_ERROR_LEADER_MSG)
		elseif strfind(err, "constellation") then
			DEFAULT_CHAT_FRAME:AddMessage(COLOR_RED .. LFT_CHAT_ERROR_COMBINATION_MSG)
		elseif strfind(err, "requirements") then
			DEFAULT_CHAT_FRAME:AddMessage(COLOR_RED .. LFT_CHAT_ERROR_MISMATCH_MSG)
		else
			DEFAULT_CHAT_FRAME:AddMessage(COLOR_RED .. LFT_CHAT_ERROR_INTERNAL_MSG)
		end
	end

	-- sent periodically to keep the client updated
	-- about the queue
	if strfind(message, "S2C_UPDATE_QUEUE_STATUS") then
		message = strsub(message, strlen("S2C_UPDATE_QUEUE_STATUS") + 2) -- remove message type
		local params = stringsplit(message, LFT_ADDON_FIELD_DELIMITER)
		if strfind(params[1], "queued") then
			inQueue = true

			LFT_Update()
			LFT_UpdateMinimapTooltip(params)
		end
	end
end

local function LFT_EnableControls()
	for _, frame in ipairs({LFTFrameInstancesListContent:GetChildren()}) do
		getglobal(frame:GetName() .. "CheckButton"):EnableMouse(1)
	end

	local _, class = UnitClass("player")
	for role, available in pairs(LFT_ClassRoles[strupper(class)]) do
		if available then
			local frame = getglobal("LFTFrameRole" .. string.gsub(strlower(role), "^%l", string.upper))

			frame:Enable()
			getglobal(frame:GetName() .. "CheckButton"):Enable()
			getglobal(frame:GetName() .. "Background"):SetDesaturated(0)
			getglobal(frame:GetName() .. "Icon"):SetDesaturated(0)
		end
	end

	LFTFrameDropDownButton:Enable()

	LFTFrameMainButton:Enable()
end

local function LFT_DisableControls()
	for _, frame in ipairs({LFTFrameInstancesListContent:GetChildren()}) do
		getglobal(frame:GetName() .. "CheckButton"):EnableMouse(0)
	end

	LFTFrameRoleTank:Disable()
	LFTFrameRoleTankCheckButton:Disable()
	LFTFrameRoleTankBackground:SetDesaturated(1)
	LFTFrameRoleTankIcon:SetDesaturated(1)

	LFTFrameRoleHealer:Disable()
	LFTFrameRoleHealerCheckButton:Disable()
	LFTFrameRoleHealerBackground:SetDesaturated(1)
	LFTFrameRoleHealerIcon:SetDesaturated(1)

	LFTFrameRoleDamage:Disable()
	LFTFrameRoleDamageCheckButton:Disable()
	LFTFrameRoleDamageBackground:SetDesaturated(1)
	LFTFrameRoleDamageIcon:SetDesaturated(1)

	LFTFrameDropDownButton:Disable()

	LFTFrameMainButton:Disable()
end

-- initialize LFT
local function LFT_Init()
	selectedRoles["DAMAGE"] = true

	for code in pairs(LFT_Instances) do
		selectedInstances[code] = false
	end

	-- update roles available to the player
	LFTFrameRoleTankCheckButton:Hide()
	LFTFrameRoleHealerCheckButton:Hide()
	LFTFrameRoleDamageCheckButton:Hide()

	LFTRoleCheckFrameRoleTank:Disable()
	LFTRoleCheckFrameRoleTankCheckButton:Hide()
	LFTRoleCheckFrameRoleTankIcon:SetDesaturated(1)

	LFTRoleCheckFrameRoleHealer:Disable()
	LFTRoleCheckFrameRoleHealerCheckButton:Hide()
	LFTRoleCheckFrameRoleHealerIcon:SetDesaturated(1)

	LFTRoleCheckFrameRoleDamage:Disable()
	LFTRoleCheckFrameRoleDamageCheckButton:Hide()
	LFTRoleCheckFrameRoleDamageIcon:SetDesaturated(1)

	local _, class = UnitClass("player")
	for role, available in pairs(LFT_ClassRoles[strupper(class)]) do
		if available then
			local frame = getglobal("LFTRoleCheckFrameRole" .. string.gsub(strlower(role), "^%l", string.upper))

			frame:Enable()
			getglobal(frame:GetName() .. "CheckButton"):Show()
			getglobal(frame:GetName() .. "Icon"):SetDesaturated(0)

			getglobal("LFTFrameRole" .. string.gsub(strlower(role), "^%l", string.upper) .. "CheckButton"):Show()
		end
	end

	-- update LFT frame
	LFT_Update()

	-- update minimap button tooltip
	LFT_UpdateMinimapTooltip()
end

function LFT_Update()
	LFT_DisableControls()
	LFT_UpdateInstances()

	if GetNumPartyMembers() > 0 then
		if IsPartyLeader() then
			if inQueue then
				LFTFrameMainButton:Enable()
				LFTFrameMainButton:SetID(2)
				LFTFrameMainButtonText:SetText(LFT_GENERAL_LEAVE_QUEUE_TEXT)
			else
				LFTFrameMainButton:SetID(1)
				LFTFrameMainButtonText:SetText(LFT_MAIN_BUTTON_FIND_MORE_TEXT)
				if GetNumPartyMembers() ~= 4 then
					LFT_EnableControls()
					LFT_CheckIfCanQueue()
				end
			end
		else
			LFTFrameMainButton:SetID(1)
			LFTFrameMainButtonText:SetText(LFT_MAIN_BUTTON_FIND_GROUP_TEXT)
		end
	else
		if inQueue then
			LFTFrameMainButton:Enable()
			LFTFrameMainButton:SetID(2)
			LFTFrameMainButtonText:SetText(LFT_GENERAL_LEAVE_QUEUE_TEXT)
		else
			LFTFrameMainButton:SetID(1)
			LFTFrameMainButtonText:SetText(LFT_MAIN_BUTTON_FIND_GROUP_TEXT)

			LFT_EnableControls()
			LFT_CheckIfCanQueue()
		end
	end
end

-- handle button click in instances tab based on the button text
function LFT_MainButtonClick()
	if this:GetID() == 1 then
		local instances = ""
		for instanceName in pairs(selectedInstances) do
			if selectedInstances[instanceName] then
				instances = instances .. instanceName .. LFT_ADDON_ARRAY_DELIMITER
			end
		end

		local roles = ""
		for roleName in pairs(selectedRoles) do
			if selectedRoles[roleName] == true then
				roles = roles .. strsub(roleName, 1, 1) .. LFT_ADDON_ARRAY_DELIMITER
			end
		end

		-- remove delimiter at the end of the string
		instances = string.lower(string.sub(instances, 1, -2))
		roles = string.lower(string.sub(roles, 1, -2))

		local message = "C2S_QUEUE_JOIN" .. LFT_ADDON_FIELD_DELIMITER .. instances .. LFT_ADDON_FIELD_DELIMITER .. roles

		SendAddonMessage(LFT_ADDON_PREFIX, message, LFT_ADDON_CHANNEL)
	else
		-- player wants to leave queue
		SendAddonMessage(LFT_ADDON_PREFIX, "C2S_QUEUE_LEAVE", LFT_ADDON_CHANNEL)
	end
end

function LFT_GroupReadyShow(instanceCode, role)
	local instance = LFT_Instances[instanceCode]

	role = string.lower(GetRoleFromCode(role))

	-- update visual elements of the group ready frame
	LFTGroupReadyFrameInstanceName:SetText(instance.name)
	LFTGroupReadyFrameBackground:SetTexture("Interface\\FrameXML\\LFT\\images\\background\\ui-lfg-background-" .. instance.background)
	LFTGroupReadyFrameRoleTexture:SetTexture("Interface\\FrameXML\\LFT\\images\\" .. role .. "2")
	LFTGroupReadyFrameRoleText:SetText(string.gsub(role, "^%l", string.upper))

	-- show the frame
	LFTGroupReadyFrame:Show()

	PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\levelup2.ogg")
end

function LFT_GroupReadyClick(confirm)
	if confirm then
		SendAddonMessage(LFT_ADDON_PREFIX, "C2S_OFFER_ACCEPT", LFT_ADDON_CHANNEL)

		-- display the group status frame
		LFTGroupReadyStatusFrameTankCheck:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-waiting")
		LFTGroupReadyStatusFrameHealerCheck:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-waiting")
		LFTGroupReadyStatusFrameDamage1Check:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-waiting")
		LFTGroupReadyStatusFrameDamage2Check:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-waiting")
		LFTGroupReadyStatusFrameDamage3Check:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-waiting")

		LFTGroupReadyStatusFrame:Show()
	else
		-- player declined the offer, leave queue
		SendAddonMessage(LFT_ADDON_PREFIX, "C2S_QUEUE_LEAVE", LFT_ADDON_CHANNEL)

		DEFAULT_CHAT_FRAME:AddMessage(LFT_CHAT_OFFER_DECLINED_TEXT)
	end

	LFTGroupReadyFrame:Hide()
end

function LFT_GroupReadyStatusUpdate(complete, tank, healer, damage)
	if complete then
		inQueue = false

		LFTGroupReadyStatusFrame:Hide()

		LFT_CheckIfCanQueue()
		LFT_UpdateMinimapTooltip()

		DEFAULT_CHAT_FRAME:AddMessage(LFT_GROUP_READY_COMPLETE_TEXT)
		return
	end

	if strfind(tank, "1") then
		LFTGroupReadyStatusFrameTankCheck:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-ready")
	end

	if strfind(healer, "1") then
		LFTGroupReadyStatusFrameHealerCheck:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-ready")
	end

	for i = 1, damage do
		getglobal("LFTGroupReadyStatusFrameDamage" .. i .. "Check"):SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-ready")
	end

	PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_rolecheck.ogg")
end

function LFT_RoleCheckStart(instances)

	for role in selectedRoles do
		-- enable role check confirm button if
		-- at least one role is selected
		if selectedRoles[role] then
			LFTRoleCheckFrameConfirmButton:Enable()
		end
		getglobal("LFTRoleCheckFrameRole" .. string.gsub(string.lower(role), "^%l", string.upper) .. "CheckButton"):SetChecked(selectedRoles[role])
	end

	if table.getn(instances) > 1 then
		local text = ""
		for i = 1, table.getn(instances) do
			text = text .. LFT_Instances[instances[i]].name .. ", "
		end
		text = string.sub(text, 1, -3)

		LFTRoleCheckFrameInstances.instances = text
		LFTRoleCheckFrameInstancesText:SetText(LFT_ROLE_CHECK_MULTIPLE_INSTANCES_TEXT)
	else
		LFTRoleCheckFrameInstances.instances = nil
		LFTRoleCheckFrameInstancesText:SetText(LFT_ROLE_CHECK_INSTANCES_TEXT .. COLOR_WHITE .. LFT_Instances[instances[1]].name)
	end

	LFTRoleCheckFrame:Show()

	PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_rolecheck.ogg")
end

function LFT_RoleCheckClick(confirm)
	if confirm then
		local roles = ""
		for roleName in pairs(selectedRoles) do
			if selectedRoles[roleName] then
				roles = roles .. string.sub(roleName, 1, 1) .. LFT_ADDON_ARRAY_DELIMITER
			end
		end

		roles = string.lower(string.sub(roles, 1, -2))

		local message = "C2S_ROLECHECK_RESPONSE" .. LFT_ADDON_FIELD_DELIMITER .. roles
		SendAddonMessage(LFT_ADDON_PREFIX, message, LFT_ADDON_CHANNEL)

		PlaySound("gsTitleOptionOK")
	else
		-- player declined the role check
		SendAddonMessage(LFT_ADDON_PREFIX, "C2S_QUEUE_LEAVE", LFT_ADDON_CHANNEL)

		PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_denied.ogg")
	end

	LFTRoleCheckFrame:Hide()
end

function LFT_OnQueueEnter()
	inQueue = true

	LFT_Update()

	LFTRoleCheckFrame:Hide()
	LFTGroupReadyFrame:Hide()
	LFTGroupReadyStatusFrame:Hide()

	LFTMinimapButton:SetScript("OnUpdate", LFT_MinimapButtonOnUpdate)

	PlaySound("PvpEnterQueue")
end

function LFT_OnQueueLeave(sound)
	inQueue = false

	LFT_Update()

	LFTRoleCheckFrame:Hide()
	LFTGroupReadyFrame:Hide()
	LFTGroupReadyStatusFrame:Hide()

	LFT_UpdateMinimapTooltip()

	if sound then
		PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_denied.ogg")
	end
end

-- update list of instances available to the player or party
function LFT_UpdateInstances()
	local level = UnitLevel("player")

	-- hide all instance list entries first
	for _, frame in pairs({ LFTFrameInstancesListContent:GetChildren() }) do
		frame:Hide()
	end

	LFTFrameWarningText:SetText("")
	-- show low level text if player's level doesn't meet the criteria
	if level and (level < LFT_MIN_FINDER_LEVEL or level == 0) then
		LFTFrameWarningText:SetText(LFT_GENERAL_LOW_LEVEL_TEXT)
		-- end here, player level is too low
		return
	end

	if GetNumRaidMembers() > 0 then
		LFTFrameWarningText:SetText(LFT_GENERAL_IN_RAID_TEXT)
		-- end here, player is in a raid
		return
	end

	if GetNumPartyMembers() > 0 then
		-- get the party member with the lowest level
		for i = 1, 4 do
			local unit = "party" .. i
			if UnitIsConnected(unit) then
				math.min(level, UnitLevel(unit))
			end
		end
	end

	local dropdown = UIDropDownMenu_GetSelectedValue(LFTFrameDropDown)
	local index = 0
	for instanceCode, instance in customSort(LFT_Instances) do
		-- show instances within a level range based on the lowest party
		-- member's level
		if (dropdown == 1 and level >= instance.minLevel and level <= instance.maxLevel) or (dropdown == 2 and level >= instance.minLevel) then
			index = index + 1

			local instanceListEntry = getglobal("LFTFrameInstancesListEntry" .. index)
			if not instanceListEntry then
				instanceListEntry = CreateFrame("Frame", "LFTFrameInstancesListEntry" .. index, LFTFrameInstancesListContent, "LFTInstanceEntryTemplate")
			end

			instanceListEntry:Show()
			instanceListEntry:ClearAllPoints()
			instanceListEntry:SetPoint("TOPLEFT", LFTFrameInstancesListContent, "TOPLEFT", 5, 20 - 24 * (index))
			instanceListEntry.instance = instanceCode

			local checkbutton = getglobal(instanceListEntry:GetName() .. "CheckButton")
			checkbutton:Enable()
			checkbutton:SetChecked(0)
			if selectedInstances[instanceCode] then
				checkbutton:SetChecked(1)
			end

			local color = COLOR_GREEN
			if instance.minLevel + 1 >= level then
				color = COLOR_RED
			elseif instance.minLevel + 2 >= level then
				color = COLOR_ORANGE
			end

			getglobal(instanceListEntry:GetName() .. "Name"):SetText(color .. instance.name)
			getglobal(instanceListEntry:GetName() .. "Levels"):SetText(color .. "(" .. instance.minLevel .. " - " .. instance.maxLevel .. ")")
		end
	end

	LFTFrameInstancesList:SetVerticalScroll(0)
	LFTFrameInstancesList:UpdateScrollChildRect()
end

function LFT_UpdateMinimapTooltip(data)
	if data then
		local instances = stringsplit(data[2], LFT_ADDON_ARRAY_DELIMITER)

		LFTMinimapButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_LEFT", 0, -110)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_1)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_2, 1, 1, 1)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_3, 1, 1, 1)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_4, 1, 1, 1)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_QUEUED)
			for i = 1, table.getn(instances) do
				local instance = LFT_Instances[instances[i]]
				GameTooltip:AddLine(instance.name, 1, 1, 1)
			end
			GameTooltip:Show()
		end)
	else
		LFTMinimapButton:SetScript("OnUpdate", nil)
		LFTMinimapButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_LEFT", 0, -110)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_1)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_2, 1, 1, 1)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_3, 1, 1, 1)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_4, 1, 1, 1)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_NO_QUEUE)
			GameTooltip:Show()
		end)

		LFTMinimapButtonEye:SetTexture("Interface\\FrameXML\\LFT\\images\\eye\\battlenetworking0")
	end
end

function LFT_QueueAs(role)
	selectedRoles[role] = this:GetChecked() == 1 and true or false

	-- enable role check confirm button if at least one
	-- role is selected
	LFTRoleCheckFrameConfirmButton:Disable()
	for role in pairs(selectedRoles) do
		if selectedRoles[role] == true then
			LFTRoleCheckFrameConfirmButton:Enable()
			break
		end
	end

	LFT_CheckIfCanQueue()
end

function LFT_QueueFor(instance)
	-- get the instance code from the parent
	selectedInstances[instance] = this:GetChecked() and true or false

	LFT_CheckIfCanQueue()
end

function LFT_CheckIfCanQueue()
	LFTFrameMainButton:Disable()

	-- player is in a party but not the leader
	if (GetNumPartyMembers() > 0 and not IsPartyLeader()) then
		LFT_DisableControls()
		return
	end

	-- check if the player has at least one role selected
	local hasRole = false
	for role in pairs(selectedRoles) do
		if selectedRoles[role] == true then
			hasRole = true
			break
		end
	end

	if not hasRole then return end

	-- check if the player has at least one instance selected
	local hasInstance = false
	for instance in pairs(selectedInstances) do
		if selectedInstances[instance] == true then
			hasInstance = true
			break
		end
	end

	if not hasInstance then return end

	-- if the player has selected a role and at least one
	-- instance, enable the main button
	LFTFrameMainButton:Enable()
end

function LFT_Toggle()
	if LFTFrame:IsVisible() then
		HideUIPanel(LFTFrame)
	else
		ShowUIPanel(LFTFrame)

		LFT_Update()

		for role in pairs(selectedRoles) do
			if selectedRoles[role] then
				getglobal("LFTFrameRole" .. string.gsub(string.lower(role), "^%l", string.upper) .. "CheckButton"):SetChecked(true)
			end
		end
	end
end

-- instances type dropdown (suggested or all available)
function LFT_InitDropDown()
	UIDropDownMenu_Initialize(this, function()
		for _, text in ipairs(LFT_DropDownItems) do
			UIDropDownMenu_AddButton({
				text = text,
				func = LFTFrameDropDownItem_OnClick
			})
		end
	end)

	UIDropDownMenu_SetWidth(160, LFTFrameDropDown)
	UIDropDownMenu_SetSelectedValue(LFTFrameDropDown, 1)
	UIDropDownMenu_SetText(LFT_DropDownItems[1], LFTFrameDropDown)
end

function LFTFrameDropDownItem_OnClick()
	local text = getglobal(this:GetName() .. "NormalText"):GetText()
	UIDropDownMenu_SetText(text, LFTFrameDropDown)
	UIDropDownMenu_SetSelectedValue(LFTFrameDropDown, this:GetID())

	LFT_UpdateInstances()
end

-- animate minimap button eye
function LFT_MinimapButtonOnUpdate()
   this.elapsed = this.elapsed or 0
	this.frameIndex = this.frameIndex or 0

	if this.elapsed > 0.08 then
		this.frameIndex = this.frameIndex < 28 and this.frameIndex + 1 or 0

		LFTMinimapButtonEye:SetTexture("Interface\\FrameXML\\LFT\\images\\eye\\battlenetworking" .. this.frameIndex)

		this.elapsed = 0
	end

	this.elapsed = this.elapsed + arg1
end

-- handle events
function LFT_OnEvent()
	if event == "VARIABLES_LOADED" then
		LFT_Init()
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == LFT_ADDON_PREFIX then
			LFT_HandleMessageFromServer(arg2)
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		-- update the UI when player leaves the party
		-- ERR_LEFT_GROUP_YOU is defined in GlobalStrings.lua
		if arg1 == ERR_LEFT_GROUP_YOU then
			inQueue = false

			LFT_Delay(0.5, LFT_Update)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- query the server to get current queue status
		-- after a UI reload and update the UI accordingly
		SendAddonMessage(LFT_ADDON_PREFIX, "C2S_GET_QUEUE_STATUS", LFT_ADDON_CHANNEL)
	else
		-- update the UI in all other cases
		LFT_Delay(0.5, LFT_Update)
	end
end
LFT:SetScript("OnEvent", LFT_OnEvent)

-- LFT command handler
SLASH_LFT1 = "/lft"
SlashCmdList["LFT"] = function(cmd)
	LFT_Toggle()
end