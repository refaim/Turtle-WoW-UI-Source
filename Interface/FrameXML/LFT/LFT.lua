LFT_ADDON_PREFIX = "TW_LFG"
LFT_ADDON_CHANNEL = "GUILD"
LFT_ADDON_ARRAY_DELIMITER = ":"
LFT_ADDON_FIELD_DELIMITER = ";"
LFT_MIN_FINDER_LEVEL = 13
LFTPresets = LFTPresets or {}

UIPanelWindows["LFTFrame"] = { area = "left", pushable = 1 }
tinsert(UIChildWindows, "LFTNewGroupFrame")

local Yellow = "|cffffff00"
local White = "|cffffffff"

local QUEUE_JOIN = 1
local QUEUE_LEAVE = 2
local BROWSE_TAB = 1
local QUEUE_TAB = 2
local MaxOfferAcceptTime = 90
local MaxRolecheckTime = 90
local RefreshButtonTick = 5
local CurrentTab = BROWSE_TAB
local DungeonsDisplayed = 12
local GroupsDisplayed = 8
local InstanceEntryHeight = 21
local GroupEntryHeight = 31

local ControlsDisabled = false

local QueueStatus = nil
local SelectedGroup = nil
local ListedGroup = nil
local CurrentPreset = nil

local InstanceEntryFrames = {}
local GroupEntryFrames = {}
local SelectedInstances = {}
local Groups = {}
local RolecheckResponses = {}
local InstancesSorted = {}
local GroupsFiltered = {}

local SelectedRoles = {
	false, -- Tank
	false, -- Healer
	true -- Damage
}

local DropDownItems = {
	LFT_GROUPS_TYPE1,
	LFT_GROUPS_TYPE2,
	LFT_GROUPS_TYPE3,
	LFT_GROUPS_TYPE4,
}

local DropDownText = DropDownItems[1]
local DropDownButtonID = 1

-- utils
local function IsGroupUsingRoles(group)
	if not group then return false end
	return group.limit[1] > 0 or group.limit[2] > 0 or group.limit[3] > 0
end

local function SortByMinLevel(a, b)
	if a.minLevel == b.minLevel then
		return a.maxLevel > b.maxLevel
	end
	return a.minLevel > b.minLevel
end

local function CustomSort(param1)
	if CurrentTab == BROWSE_TAB and type(param1) == "table" then
		wipe(GroupsFiltered)
		for i = 1, getn(param1) do
			local value = param1[i]
			if DropDownButtonID == value.category then
				tinsert(GroupsFiltered, value)
			end
		end
		return GroupsFiltered
	elseif CurrentTab == QUEUE_TAB and type(param1) == "number" then
		wipe(InstancesSorted)
		for key, value in pairs(LFT_Instances) do
			if param1 >= value.minLevel then
				value.code = key
				tinsert(InstancesSorted, value)
			else
				SelectedInstances[key] = nil
			end
		end
		sort(InstancesSorted, SortByMinLevel)
		return InstancesSorted
	end
end

local function GetRoleFromCode(code, ignoreLocale)
	if ignoreLocale then
		return code == "t" and "tank" or code == "h" and "healer" or code == "d" and "damage" or ""
	end
	return code == "t" and LFT_ROLE_1 or code == "h" and LFT_ROLE_2 or code == "d" and LFT_ROLE_3 or code == "0" and GENERIC_NONE or ""
end

-- delay frame for various uses
local LFTDelay = CreateFrame("Frame")
LFTDelay:Hide()

local function LFT_Delay(time, func, a1, a2, a3)
	LFTDelay:SetScript("OnUpdate", function()
		this.elapsed = this.elapsed or 0
		if this.elapsed >= time then
			this.elapsed = 0

			func(a1, a2, a3)

			this:SetScript("OnUpdate", nil)
			this:Hide()
		end
		this.elapsed = this.elapsed + arg1
	end)

	LFTDelay:Show()
end

local function InGroupOrRaid()
	return (GetNumPartyMembers() + GetNumRaidMembers()) > 0
end

local function GetPartyLeader()
	if GetNumRaidMembers() > 0 then
		local name, rank
		for i=1, MAX_RAID_MEMBERS do
			name, rank = GetRaidRosterInfo(i)
			if name and rank == 2 then
				return name
			end
		end
	elseif GetNumPartyMembers() > 0 then
		if IsPartyLeader() then
			return (UnitName("player"))
		end
		for i=1, 4 do
			if UnitIsPartyLeader("party"..i) then
				return (UnitName("party"..i))
			end
		end
	end
	return (UnitName("player"))
end

local function Send(msg)
	SendAddonMessage(LFT_ADDON_PREFIX, msg, LFT_ADDON_CHANNEL)
end

local function SendRaid(msg)
	if InGroupOrRaid() then
		SendAddonMessage(LFT_ADDON_PREFIX, msg, "RAID")
	else
		SendAddonMessage("TW_CHAT_MSG_WHISPER<"..UnitName("player")..">", msg, LFT_ADDON_CHANNEL)
	end
end

-- handle various messages sent by the server via
-- the guild channel
local function LFT_HandleMessage(message, from)
	-- sent when the player or group leader joins the
	-- queue
	if strfind(message, "S2C_QUEUE_JOINED") then
		LFT_OnQueueEnter()
	end

	-- sent when the player or group leader leaves
	-- the queue
	if strfind(message, "S2C_QUEUE_LEFT") then
		LFT_OnQueueLeave(true)
	end

	-- sent when a group has been found and the player
	-- has to confirm that they're ready
	if strfind(message, "S2C_OFFER_NEW") then
		local params = explode(message, LFT_ADDON_FIELD_DELIMITER)

		LFT_GroupReadyShow(params[2], params[3])
	end

	-- sent when a group member confirms their role
	-- during a ready check
	if strfind(message, "S2C_OFFER_UPDATE_COUNT") then
		local params = strsub(message, strlen("S2C_OFFER_UPDATE_COUNT") + 2) -- remove message type
		params = explode(params, LFT_ADDON_ARRAY_DELIMITER) -- get confirmed roles

		LFT_GroupReadyStatusUpdate(false, params[1], params[2], params[3])
	end

	-- sent when every group member confirms their
	-- ready status after a group has been found
	if strfind(message, "S2C_OFFER_COMPLETE") then
		LFT_GroupReadyStatusUpdate(true)
	end

	-- sent when a party leader initiates a role check
	if strfind(message, "S2C_ROLECHECK_START") then
		local instances = strsub(message, strlen("S2C_ROLECHECK_START") + 2) -- remove message type
		if instances and instances ~= "" then
			instances = explode(instances, LFT_ADDON_ARRAY_DELIMITER) -- get queued instances
		end
		-- if no instances sent - this is a role check for browse tab listed group
		LFT_RoleCheckShow(instances)
	end

	-- sent when a group member confirms their role
	-- during a role check
	if strfind(message, "S2C_ROLECHECK_INFO") then
		if GetNumPartyMembers() > 0 then
			local params = explode(message, LFT_ADDON_FIELD_DELIMITER)
			local member = params[2] -- name of the group member who confirmed their role
			local roles = ""
			params = explode(params[3], LFT_ADDON_ARRAY_DELIMITER) -- get confirmed roles
			for i = 1, getn(params) do
				params[i] = GetRoleFromCode(params[i])
			end
			roles = table.concat(params, ", ")

			DEFAULT_CHAT_FRAME:AddMessage(Yellow..format(LFT_CHAT_SELECTED_ROLES_TEXT, member, roles))
		end
	end

	-- sent when an error is encountered - has
	-- multiple error definitions
	if strfind(message, "S2C_QUEUE_ERROR") then
		local err = strsub(message, strlen("S2C_QUEUE_ERROR") + 2)
		local msg = _G["LFT_CHAT_ERROR_"..strupper(err or "")] or LFT_CHAT_ERROR_INTERNAL
		UIErrorsFrame:AddMessage(msg, 1, 0.1, 0.1)
		QueueStatus = nil
		LFT_Update()
	end

	-- sent periodically to keep the client updated
	-- about the queue (not true atm - sent only once)
	if strfind(message, "S2C_UPDATE_QUEUE_STATUS") then
		message = strsub(message, strlen("S2C_UPDATE_QUEUE_STATUS") + 2) -- remove message type
		local params = explode(message, LFT_ADDON_FIELD_DELIMITER)
		if strfind(params[1], "queued") then
			QueueStatus = "queued"
			local instances = explode(params[2], LFT_ADDON_ARRAY_DELIMITER)
			for k in pairs(SelectedInstances) do
				SelectedInstances[k] = nil
			end
			for _, v in ipairs(instances) do
				SelectedInstances[v] = 1
			end
			LFT_Update()
			LFT_UpdateGroupsList()
			LFT_UpdateMinimapTooltip(instances)
			local instancesStr = ""
			for instanceCode, selected in pairs(SelectedInstances) do
				if selected then
					instancesStr = instancesStr..LFT_Instances[instanceCode].name..", "
				end
			end
			if instancesStr ~= "" then
				instancesStr = strsub(instancesStr, 1, -3)
				DEFAULT_CHAT_FRAME:AddMessage(Yellow..format(LFT_CHAT_QUEUE_JOIN_TEXT, instancesStr))
			end
		elseif strfind(params[1], "pending") then
			QueueStatus = "pending"
		end
	end
	-- "C2S_GET_GROUPS_STATUS" -- sent on login to check if group list is enabled server side
	-- "C2S_GET_GROUPS_LIST" -- refresh request for groups list
	-- "C2S_NEW_GROUP" -- sent when you create new group in browse tab
	-- "C2S_DELETE_GROUP" -- sent when creator deletes listed group
	-- "C2S_UPDATE_GROUP" -- sent when creator edits listed group
	-- "C2S_ROLECHECK_START" -- sent when party leader initiates role check for listed group

	-- "S2C_GROUPS_STATUS" -- 1 if group list is enabled, 0 if not
	-- "S2C_GROUPS_LIST_UPDATE" -- received full groups list update
	-- "S2C_UPDATE_GROUP" -- received update for 1 group

	if strfind(message, "S2C_GROUPS_STATUS", 1, true) then
		local _, _, status = strfind(message, "S2C_GROUPS_STATUS"..LFT_ADDON_FIELD_DELIMITER.."(%d)")
		if tonumber(status) ~= 1 then
			LFTFrameTab2:Click()
			PanelTemplates_DisableTab(LFTFrame, 1)
			LFTNewGroupFrame:Hide()
			LFTFrameRefreshButton:Disable()
			LFTFrameNewGroupButton:Disable()
			LFTFrameDropDownButton:Disable()
		else
			PanelTemplates_EnableTab(LFTFrame, 1)
			LFTFrameRefreshButton:Enable()
			LFTFrameNewGroupButton:Enable()
			LFTFrameDropDownButton:Enable()
			Send("C2S_GET_GROUPS_LIST")
		end
		return
	end

	if strfind(message, "S2C_GROUPS_LIST_UPDATE", 1, true) then
		if strfind(message, "S2C_GROUPS_LIST_UPDATE"..LFT_ADDON_FIELD_DELIMITER.."start", 1, true) then
			wipe(Groups)
			ListedGroup = nil
		elseif strfind(message, "S2C_GROUPS_LIST_UPDATE"..LFT_ADDON_FIELD_DELIMITER.."end", 1, true) then
			if ListedGroup then
				Send("C2S_GET_GROUP_DETAILS"..LFT_ADDON_FIELD_DELIMITER..ListedGroup.id)
			elseif next(RolecheckResponses) then
				LFTRoleCheckFrame:Hide()
				wipe(RolecheckResponses)
				SendRaid("C2C_ROLECHECK_STOP")
			end
			LFT_UpdateGroupsList()
		else
			local _, _, data = strfind(message, "S2C_GROUPS_LIST_UPDATE"..LFT_ADDON_FIELD_DELIMITER.."(.+)")
			data = json.decode(data)
			if type(data) == "table" then
				for k, v in pairs(Groups) do
					if v.id and v.id == data.id then
						return
					end
				end
				if data.creator ~= UnitName("player") then
					tinsert(Groups, data)
				else
					tinsert(Groups, 1, data)
					ListedGroup = Groups[1]
					LFTNewGroupFrame:Hide()
				end
			end
		end
		return
	end

	if strfind(message, "S2C_UPDATE_GROUP", 1, true) then
		local _, _, groupID, code, data = strfind(message, "S2C_UPDATE_GROUP"..LFT_ADDON_FIELD_DELIMITER.."(%d+)"..LFT_ADDON_FIELD_DELIMITER.."([%a%d]+)"..LFT_ADDON_FIELD_DELIMITER.."?(.*)")
		-- code can be "start", "end" or a role index (0,1,2 or 3)
		groupID = tonumber(groupID)
		if groupID and code then
			local groupIndex
			for k, v in pairs(Groups) do
				if v.id == groupID then
					groupIndex = k
					break
				end
			end
			if not groupIndex then
				return
			end
			if code == "start" and data and data ~= "" then
				-- if its a start, should recieve id, title, description, limits and num confirmed
				local miscInfo = json.decode(data)
				if type(miscInfo) == "table" then
					Groups[groupIndex] = miscInfo
					Groups[groupIndex].signups = {{}, {}, {}}
				end
			elseif code == "end" then
				if Groups[groupIndex].creator == UnitName("player") then
					ListedGroup = Groups[groupIndex]
					if LFTNewGroupFrame.mode == "pending" then
						LFTNewGroupFrame.mode = nil
						if IsGroupUsingRoles(ListedGroup) then
							LFT_GroupRoleCheckStart()
						end
					end
				end
				if SelectedGroup and SelectedGroup.id == Groups[groupIndex].id then
					SelectedGroup = Groups[groupIndex]
				end
				if LFTFrame:IsShown() then
					LFT_UpdateGroupsList()
				end
			elseif code == "invalid" then
				UIErrorsFrame:AddMessage(LFT_CHAT_ERROR_INVALID, 1, 0.1, 0.1)
				SelectedGroup = nil
				LFTFrameSendMessageButton:Disable()
				Send("C2S_GET_GROUPS_LIST")
			elseif data and data ~= "" then
				-- idividual signups
				local roleIndex = tonumber(code)
				local signupData = json.decode(data)
				if roleIndex and type(signupData) == "table" then
					if roleIndex == 0 then roleIndex = 3 end
					tinsert(Groups[groupIndex].signups[roleIndex], signupData)
				end
			end
		end
		return
	end

	if strfind(message, "C2C_ROLECHECK_RESPONSE") then
		local role = strsub(message, -1)
		local roleIndex = role == "t" and 1 or role == "h" and 2 or role == "d" and 3 or 0
		DEFAULT_CHAT_FRAME:AddMessage(Yellow..format(LFT_CHAT_SELECTED_ROLES_TEXT, from, GetRoleFromCode(role)))
		if not ListedGroup then return end
		if not RolecheckResponses then RolecheckResponses = {} end
		if RolecheckResponses[from] then RolecheckResponses[from] = roleIndex end
		for _, status in pairs(RolecheckResponses) do
			if status == -1 then return end
		end
		local data = ListedGroup
		local confirmedPlayers = ""
		for name, roleID in pairs(RolecheckResponses) do
			confirmedPlayers = confirmedPlayers..name..LFT_ADDON_ARRAY_DELIMITER..roleID..LFT_ADDON_FIELD_DELIMITER
		end
		wipe(RolecheckResponses)
		Send("C2S_UPDATE_GROUP"..LFT_ADDON_FIELD_DELIMITER..data.id..LFT_ADDON_FIELD_DELIMITER..data.title..LFT_ADDON_FIELD_DELIMITER..data.description..LFT_ADDON_FIELD_DELIMITER..
			data.limit[1]..LFT_ADDON_ARRAY_DELIMITER..data.limit[2]..LFT_ADDON_ARRAY_DELIMITER..data.limit[3]..LFT_ADDON_FIELD_DELIMITER..confirmedPlayers)
		LFT_CheckIfCanQueue()
		LFT_UpdateGroupsList()
		return
	end

	if strfind(message, "C2C_ROLECHECK_START") then
		local _, _, id = strfind(message, "C2C_ROLECHECK_START;(%d+)")
		if id then
			Send("C2S_SIGNUP"..LFT_ADDON_FIELD_DELIMITER.."true"..LFT_ADDON_FIELD_DELIMITER..id..LFT_ADDON_FIELD_DELIMITER.."4")
			LFT_RoleCheckShow()
		end
		return
	end

	if message == "C2C_ROLECHECK_STOP" then
		LFTRoleCheckFrame:Hide()
		wipe(RolecheckResponses)
		LFT_Update()
		LFT_UpdateGroupsList()
		return
	end
end

local function LFT_EnableControls()
	if CurrentTab ~= QUEUE_TAB then
		return
	end
	for _, frame in ipairs(InstanceEntryFrames) do
		frame.checkButton:Enable()
		frame:SetAlpha(1)
	end

	local _, class = UnitClass("player")
	for role, available in ipairs(LFT_ClassRoles[class]) do
		LFT_ToggleRoleButton(LFTFrame, role, available)
	end

	LFTFrameMainButton:Enable()
	ControlsDisabled = false
end

local function LFT_DisableControls()
	for _, frame in ipairs(InstanceEntryFrames) do
		frame.checkButton:Disable()
		frame:SetAlpha(SelectedInstances[frame.instance] and 1 or 0.5)
	end

	for role, available in ipairs(SelectedRoles) do
		LFT_ToggleRoleButton(LFTFrame, role, false, CurrentTab == BROWSE_TAB)
	end

	LFTFrameMainButton:Disable()
	ControlsDisabled = true
end

-- initialize LFT
local function LFT_Init()
	-- update roles available to the player
	local _, class = UnitClass("player")
	for role, available in ipairs(LFT_ClassRoles[class]) do
		LFT_ToggleRoleButton(LFTFrame, role, available, true)
		LFT_ToggleRoleButton(LFTRoleCheckFrame, role, available, true)
	end

	-- update LFT frame
	LFT_Tab_OnClick(BROWSE_TAB)

	-- update minimap button tooltip
	LFT_UpdateMinimapTooltip()

	LFTPresets = LFTPresets or {}
end

function LFT_Update()
	LFT_DisableControls()

	if QueueStatus == "pending" then
		LFTFrameMainButtonText:SetText(LFT_GENERAL_LEAVE_QUEUE_TEXT)
		LFT_UpdateInstances()
		return
	end

	local numMembers = GetNumPartyMembers()

	if QueueStatus == "queued" then
		LFTFrameMainButtonText:SetText(LFT_GENERAL_LEAVE_QUEUE_TEXT)
	elseif numMembers > 0 then
		LFTFrameMainButtonText:SetText(LFT_MAIN_BUTTON_FIND_MORE_TEXT)
	else
		LFTFrameMainButtonText:SetText(LFT_MAIN_BUTTON_FIND_GROUP_TEXT)
	end

	if numMembers > 0 then
		if IsPartyLeader() then
			if QueueStatus == "queued" then
				if not next(RolecheckResponses) then
					LFTFrameMainButton:Enable()
				end
				LFTFrameMainButton:SetID(QUEUE_LEAVE)
			else
				LFTFrameMainButton:SetID(QUEUE_JOIN)
				if numMembers ~= 4 then
					LFT_EnableControls()
					LFT_CheckIfCanQueue()
				end
			end
		else
			LFTFrameMainButton:SetID(QUEUE_JOIN)
		end
	else
		if QueueStatus == "queued" then
			if not next(RolecheckResponses) then
				LFTFrameMainButton:Enable()
			end
			LFTFrameMainButton:SetID(QUEUE_LEAVE)
		else
			LFTFrameMainButton:SetID(QUEUE_JOIN)
			LFT_EnableControls()
			LFT_CheckIfCanQueue()
		end
	end

	LFT_UpdateInstances()
end

-- handle button click in instances tab
function LFT_MainButtonClick()
	if LFTFrameMainButton:GetID() == QUEUE_JOIN then
		local instances = ""
		for instanceCode in pairs(SelectedInstances) do
			instances = instances .. instanceCode .. LFT_ADDON_ARRAY_DELIMITER
		end

		local roles = ""
		for roleID, selected in ipairs(SelectedRoles) do
			local roleName = roleID == 1 and "t" or roleID == 2 and "h" or roleID == 3 and "d" or ""
			if selected then
				roles = roles .. roleName .. LFT_ADDON_ARRAY_DELIMITER
			end
		end

		-- remove delimiter at the end of the string
		instances = strlower(strsub(instances, 1, -2))
		roles = strlower(strsub(roles, 1, -2))

		Send("C2S_QUEUE_JOIN" .. LFT_ADDON_FIELD_DELIMITER .. instances .. LFT_ADDON_FIELD_DELIMITER .. roles)
		QueueStatus = "pending"
		LFT_Update()
	else
		-- player wants to leave queue
		Send("C2S_QUEUE_LEAVE")
	end
end

function LFT_GroupReadyShow(instanceCode, role)
	local instance = LFT_Instances[instanceCode]

	-- update visual elements of the group ready frame
	LFTGroupReadyFrameInstanceName:SetText(instance.name)
	LFTGroupReadyFrameBackground:SetTexture("Interface\\FrameXML\\LFT\\images\\background\\ui-lfg-background-" .. instance.background)
	LFTGroupReadyFrameRoleTexture:SetTexture("Interface\\FrameXML\\LFT\\images\\" .. GetRoleFromCode(role, true) .. "2")
	LFTGroupReadyFrameRoleText:SetText(GetRoleFromCode(role))

	-- show the frame
	LFTGroupReadyFrameTimer:SetMinMaxValues(0, MaxOfferAcceptTime)
	LFTGroupReadyFrameTimer.timeLeft = MaxOfferAcceptTime
	LFTGroupReadyFrame:Show()

	PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\levelup2.ogg")
end

function LFT_GroupReadyClick(confirm)
	if confirm then
		Send("C2S_OFFER_ACCEPT")

		-- display the group status frame
		LFTGroupReadyStatusFrameTankCheck:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-waiting")
		LFTGroupReadyStatusFrameHealerCheck:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-waiting")
		LFTGroupReadyStatusFrameDamage1Check:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-waiting")
		LFTGroupReadyStatusFrameDamage2Check:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-waiting")
		LFTGroupReadyStatusFrameDamage3Check:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-waiting")

		LFTGroupReadyStatusFrame:Show()
	else
		-- player declined the offer, leave queue
		Send("C2S_QUEUE_LEAVE")

		DEFAULT_CHAT_FRAME:AddMessage(Yellow..LFT_CHAT_OFFER_DECLINED_TEXT)
	end

	LFTGroupReadyFrame:Hide()
end

function LFT_GroupReadyStatusUpdate(complete, tank, healer, damage)
	if complete then
		QueueStatus = nil

		LFTGroupReadyStatusFrame:Hide()

		LFT_CheckIfCanQueue()
		LFT_UpdateMinimapTooltip()

		DEFAULT_CHAT_FRAME:AddMessage(Yellow..format(LFT_GROUP_READY_COMPLETE_TEXT, LFTGroupReadyFrameInstanceName:GetText()))

		if ListedGroup then
			Send("C2S_DELETE_GROUP"..LFT_ADDON_FIELD_DELIMITER..ListedGroup.id)
			SelectedGroup = nil
			LFTFrameSendMessageButton:Disable()
			LFTNewGroupFrame:Hide()
		end

		return
	end

	if strfind(tank, "1") then
		LFTGroupReadyStatusFrameTankCheck:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-ready")
	end

	if strfind(healer, "1") then
		LFTGroupReadyStatusFrameHealerCheck:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-ready")
	end

	for i = 1, damage do
		_G["LFTGroupReadyStatusFrameDamage" .. i .. "Check"]:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-ready")
	end

	PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_rolecheck.ogg")
end

function LFT_ToggleRoleButton(frame, role, enable, hideCheckButton)
	if not frame then
		frame = this
	end
	local button = _G[frame:GetName().."Role"..role]
	if not button then
		return
	end
	if enable then
		button:Enable()
		_G[button:GetName().."CheckButton"]:Show()
		_G[button:GetName().."CheckButton"]:Enable()
		_G[button:GetName().."Icon"]:SetDesaturated(false)
		if _G[button:GetName().."Background"] then
			_G[button:GetName().."Background"]:SetDesaturated(false)
		end
	else
		button:Disable()
		_G[button:GetName().."CheckButton"]:Disable()
		_G[button:GetName().."Icon"]:SetDesaturated(true)
		if hideCheckButton then
			_G[button:GetName().."CheckButton"]:Hide()
		else
			_G[button:GetName().."CheckButton"]:Show()
		end
		if _G[button:GetName().."Background"] then
			_G[button:GetName().."Background"]:SetDesaturated(true)
		end
	end
end

function LFT_RoleCheckShow(instances)
	LFTRoleCheckFrame:Hide()

	if not instances or instances == "" then
		LFTRoleCheckFrame.tab = BROWSE_TAB
	else
		LFTRoleCheckFrame.tab = QUEUE_TAB
	end

	if LFTRoleCheckFrame.tab == BROWSE_TAB then
		local leader = GetPartyLeader()
		if leader == UnitName("player") then
			LFTRoleCheckFrameInstancesText:SetText(format(LFT_ROLE_CHECK_MESSAGE_SELF, leader))
		else
			LFTRoleCheckFrameInstancesText:SetText(format(LFT_ROLE_CHECK_MESSAGE, leader))
		end
		LFTRoleCheckFrameInstances.instances = nil
		LFTRoleCheckFrameRole1CheckButton:SetChecked(false)
		LFTRoleCheckFrameRole2CheckButton:SetChecked(false)
		LFTRoleCheckFrameRole3CheckButton:SetChecked(true)

	elseif LFTRoleCheckFrame.tab == QUEUE_TAB then
		if getn(instances) > 1 then
			local text = ""
			for i = 1, getn(instances) do
				text = text .. LFT_Instances[instances[i]].name .. "\n"
			end
			LFTRoleCheckFrameInstances.instances = text
			LFTRoleCheckFrameInstancesText:SetText(LFT_ROLE_CHECK_MULTIPLE_INSTANCES_TEXT)
		else
			LFTRoleCheckFrameInstances.instances = nil
			LFTRoleCheckFrameInstancesText:SetText(LFT_ROLE_CHECK_INSTANCES_TEXT .. White .. LFT_Instances[instances[1]].name)
		end
	end

	LFTRoleCheckFrameTimer:SetMinMaxValues(0, MaxRolecheckTime)
	LFTRoleCheckFrameTimer.timeLeft = MaxRolecheckTime
	LFTRoleCheckFrame:Show()
end

function LFT_RoleCheckConfirm()
	local roles = ""
	for roleID, selected in ipairs(SelectedRoles) do
		local roleName = roleID == 1 and "t" or roleID == 2 and "h" or roleID == 3 and "d" or ""
		if selected then
			roles = roles .. roleName .. LFT_ADDON_ARRAY_DELIMITER
		end
		if LFTRoleCheckFrame.tab == QUEUE_TAB then
			_G["LFTFrameRole" .. roleID .. "CheckButton"]:SetChecked(selected)
		end
	end
	roles = strlower(strsub(roles, 1, -2))
	if LFTRoleCheckFrame.tab == BROWSE_TAB then
		local role = "0"
		if LFTRoleCheckFrameRole1CheckButton:GetChecked() then
			role = "t"
		elseif LFTRoleCheckFrameRole2CheckButton:GetChecked() then
			role = "h"
		elseif LFTRoleCheckFrameRole3CheckButton:GetChecked() then
			role = "d"
		end
		SendRaid("C2C_ROLECHECK_RESPONSE"..LFT_ADDON_FIELD_DELIMITER..role)
	else
		Send("C2S_ROLECHECK_RESPONSE" .. LFT_ADDON_FIELD_DELIMITER .. roles)
	end
	PlaySound("gsTitleOptionOK")
	LFTRoleCheckFrame:Hide()
end

function LFT_RoleCheckDecline()
	if LFTRoleCheckFrame.tab == BROWSE_TAB then
		SendRaid("C2C_ROLECHECK_RESPONSE"..LFT_ADDON_FIELD_DELIMITER.."0")
	else
		Send("C2S_QUEUE_LEAVE")
	end
	PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_denied.ogg")
	LFTRoleCheckFrame:Hide()
end

function LFTRoleCheckFrame_OnShow()
	local _, class = UnitClass("player")
	for role, available in ipairs(LFT_ClassRoles[class]) do
		LFT_ToggleRoleButton(LFTRoleCheckFrame, role, available, true)
	end
	if LFTRoleCheckFrame.tab == BROWSE_TAB then
		LFTRoleCheckFrameRole1CheckButton:SetChecked(false)
		LFTRoleCheckFrameRole2CheckButton:SetChecked(false)
		LFTRoleCheckFrameRole3CheckButton:SetChecked(true)
		LFT_ToggleRoleButton(LFTFrame, 1, false, CurrentTab == BROWSE_TAB)
		LFT_ToggleRoleButton(LFTFrame, 2, false, CurrentTab == BROWSE_TAB)
		LFT_ToggleRoleButton(LFTFrame, 3, false, CurrentTab == BROWSE_TAB)
		-- LFT_ToggleRoleButton(LFTRoleCheckFrame, 1, true, true)
		-- LFT_ToggleRoleButton(LFTRoleCheckFrame, 2, true, true)
		-- LFT_ToggleRoleButton(LFTRoleCheckFrame, 3, true, true)
		LFTRoleCheckFrameConfirmButton:Enable()
		LFTFrameNewGroupButton:Disable()
		LFTNewGroupFrame:Hide()
	else
		for role, selected in ipairs(SelectedRoles) do
			-- enable role check confirm button if at least one role is selected
			if selected then
				LFTRoleCheckFrameConfirmButton:Enable()
			end
			_G["LFTRoleCheckFrameRole" .. role .. "CheckButton"]:SetChecked(selected)
			-- disable ones in main frame
			LFT_ToggleRoleButton(LFTFrame, role, false, CurrentTab == BROWSE_TAB)
		end
	end
	PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_rolecheck.ogg")
end

function LFTRoleCheckFrame_OnHide()
	if not ControlsDisabled then
		LFT_EnableControls()
		if next(SelectedInstances) and (SelectedRoles[1] or SelectedRoles[2] or SelectedRoles[3]) and not next(RolecheckResponses) then
			LFTFrameMainButton:Enable()
		else
			LFTFrameMainButton:Disable()
		end
	end
	LFT_Update()
	LFT_UpdateGroupsList()
end

function LFT_OnQueueEnter()
	QueueStatus = "queued"

	LFT_Update()

	LFTRoleCheckFrame:Hide()
	LFTGroupReadyFrame:Hide()
	LFTGroupReadyStatusFrame:Hide()

	LFTMinimapButton:SetScript("OnUpdate", LFT_MinimapButtonOnUpdate)

	PlaySound("PvpEnterQueue")
end

function LFT_OnQueueLeave(sound)
	QueueStatus = nil

	LFT_Update()

	LFTRoleCheckFrame:Hide()
	LFTGroupReadyFrame:Hide()
	LFTGroupReadyStatusFrame:Hide()

	LFT_UpdateMinimapTooltip()

	if sound then
		PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_denied.ogg")
	end
end

function LFTFrameScrollFrame_OnVerticalScroll()
	if CurrentTab == BROWSE_TAB then
		FauxScrollFrame_OnVerticalScroll(GroupEntryHeight, LFT_UpdateGroupsList)
	elseif CurrentTab == QUEUE_TAB then
		FauxScrollFrame_OnVerticalScroll(InstanceEntryHeight, LFT_UpdateInstances)
	end
end

-- update list of instances available to the player or party
function LFT_UpdateInstances()
	if CurrentTab ~= QUEUE_TAB then
		LFTFrameWarningText:SetText("")
		LFT_ToggleRoleButton(LFTFrame, 1, false, true)
		LFT_ToggleRoleButton(LFTFrame, 2, false, true)
		LFT_ToggleRoleButton(LFTFrame, 3, false, true)
		return
	end

	local roleCheckShown = LFTRoleCheckFrame:IsShown()
	if roleCheckShown then
		LFT_ToggleRoleButton(LFTFrame, 1, false)
		LFT_ToggleRoleButton(LFTFrame, 2, false)
		LFT_ToggleRoleButton(LFTFrame, 3, false)
		LFTFrameMainButton:Disable()
	end

	local level = UnitLevel("player")

	-- hide all instance list entries first
	for _, frame in pairs(InstanceEntryFrames) do
		frame:Hide()
		frame.checkButton:SetChecked(false)
	end
	-- hide all group list entries
	for _, frame in pairs(GroupEntryFrames) do
		frame:Hide()
	end

	LFTFrameWarningText:SetText("")
	-- show low level text if player's level doesn't meet the criteria
	if level and level < LFT_MIN_FINDER_LEVEL then
		LFTFrameWarningText:SetText(LFT_GENERAL_LOW_LEVEL_TEXT)
		-- end here, player level is too low
		return
	end

	if GetNumRaidMembers() > 0 then
		LFTFrameWarningText:SetText(LFT_GENERAL_IN_RAID_TEXT)
		LFT_DisableControls()
		-- end here, player is in a raid
		return
	end

	if GetNumPartyMembers() > 0 then
		-- get the party member with the lowest level
		for i = 1, 4 do
			local unit = "party" .. i
			if UnitIsConnected(unit) then
				level = min(level, UnitLevel(unit))
			end
		end
	end

	local offset = FauxScrollFrame_GetOffset(LFTFrameScrollFrame) or 0
	local data = CustomSort(level)

	-- show instances within a level range based on the lowest party member's level
	for i = 1, DungeonsDisplayed do
		local entry = _G["LFTFrameInstanceEntry" .. i]
		local dungeonIndex = i + offset
		local instance = data[dungeonIndex]
		if instance and instance.code then
			if dungeonIndex <= getn(data) then
				local checkButton = entry.checkButton
				local name = entry.name
				local levels = entry.levels
				local highlight = entry.highlight

				if ControlsDisabled or roleCheckShown then
					checkButton:Disable()
				else
					checkButton:Enable()
				end
				local isSelected = SelectedInstances[instance.code]
				checkButton:SetChecked(isSelected)
				if ControlsDisabled and not isSelected then
					entry:SetAlpha(0.5)
				else
					entry:SetAlpha(1)
				end
				name:SetText(instance.name)
				levels:SetText("(" .. instance.minLevel .. " - " .. instance.maxLevel .. ")")

				local averageLevel = floor((instance.maxLevel - instance.minLevel) / 2) + instance.minLevel
				local levelDiff = averageLevel - level
				local r, g, b
				if levelDiff > 4 then
					-- red
					r, g, b = 1, 0, 0
				elseif levelDiff > 2 then
					-- orange
					r, g, b = 1, 0.5, 0.25
				elseif levelDiff > -3 then
					-- yellow
					r, g, b = 1, 1, 0
				elseif levelDiff > -12 then
					-- green
					r, g, b = 0.25, 0.75, 0.25
				else
					-- gray
					r, g, b = 0.5, 0.5, 0.5
				end
				if instance.minLevel == instance.maxLevel then
					-- max level dungeons
					-- orange
					r, g, b = 1, 0.5, 0.25
				end
				name:SetTextColor(r, g, b)
				levels:SetTextColor(r, g, b)
				highlight:SetVertexColor(r, g, b, 0.7)
				entry.r, entry.g, entry.b = r, g, b
				entry.instance = instance.code
				entry:Show()
			else
				entry:Hide()
			end
		end
	end

	local shown = FauxScrollFrame_Update(LFTFrameScrollFrame, getn(data), DungeonsDisplayed, InstanceEntryHeight)
	if not shown then
		LFTFrameScrollFrame:Show()
		LFTFrameScrollFrameScrollBarScrollDownButton:Disable()
		LFTFrameScrollFrameScrollBarScrollUpButton:Disable()
		LFTFrameScrollFrameScrollBarThumbTexture:Hide()
	else
		LFTFrameScrollFrameScrollBarThumbTexture:Show()
	end
end

function LFT_UpdateMinimapTooltip(instances)
	if instances then
		LFTMinimapButton.instances = instances
	else
		LFTMinimapButton.instances = nil
		LFTMinimapButton:SetScript("OnUpdate", nil)
		LFTMinimapButtonEye:SetTexture("Interface\\FrameXML\\LFT\\images\\eye\\battlenetworking0")
	end
end

function LFTMinimapButton_OnEnter()
	if LFTMinimapButton.instances then
		local instances = LFTMinimapButton.instances
		GameTooltip:SetOwner(this, "ANCHOR_LEFT", 0, -110)
		GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_1, 1, 1, 1)
		GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_2)
		GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_3)
		GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_4)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_QUEUED, 1, 1, 1)
		local instancesLine = ""
		local size = getn(instances)
		for i = 1, size do
			instancesLine = instancesLine..LFT_Instances[instances[i]].name..(i < size and "\n" or "")
		end
		GameTooltip:AddLine(instancesLine)
		if ListedGroup then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(format(LFT_MINIMAP_TOOLTIP_LISTED, ListedGroup.title), 1, 1, 1)
		end
		GameTooltip:Show()
	else
		GameTooltip:SetOwner(this, "ANCHOR_LEFT", 0, -110)
		GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_1, 1, 1, 1)
		GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_2)
		GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_3)
		GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_4)
		-- GameTooltip:AddLine(" ")
		-- GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_NO_QUEUE, 1, 1, 1)
		if ListedGroup then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(format(LFT_MINIMAP_TOOLTIP_LISTED, ListedGroup.title), 1, 1, 1)
		end
		GameTooltip:Show()
	end
end

function LFT_QueueAs(role)
	local checked = this:GetChecked()
	if LFTRoleCheckFrame:IsShown() and LFTRoleCheckFrame.tab == BROWSE_TAB then
		LFTRoleCheckFrameRole1CheckButton:SetChecked(false)
		LFTRoleCheckFrameRole2CheckButton:SetChecked(false)
		LFTRoleCheckFrameRole3CheckButton:SetChecked(false)
		this:SetChecked(checked)
		if checked then
			LFTRoleCheckFrameConfirmButton:Enable()
		else
			LFTRoleCheckFrameConfirmButton:Disable()
		end
		return
	end
	SelectedRoles[role] = checked and true or false
	this:SetChecked(checked)
	-- enable role check confirm button if at least one
	-- role is selected
	LFTRoleCheckFrameConfirmButton:Disable()
	for role in ipairs(SelectedRoles) do
		if SelectedRoles[role] then
			LFTRoleCheckFrameConfirmButton:Enable()
			break
		end
	end

	LFT_CheckIfCanQueue()
end

function LFT_QueueFor(instance)
	-- get the instance code from the parent
	SelectedInstances[instance] = this:GetChecked()
	LFT_CheckIfCanQueue()
end

function LFT_CheckIfCanQueue()
	-- player is in a party but not the leader
	if GetNumPartyMembers() > 0 and not IsPartyLeader() then
		LFT_DisableControls()
		return
	end

	-- if the player has selected a role and at least one instance, enable the main button
	if next(SelectedInstances) and (SelectedRoles[1] or SelectedRoles[2] or SelectedRoles[3]) and not next(RolecheckResponses) then
		LFTFrameMainButton:Enable()
	else
		LFTFrameMainButton:Disable()
	end
end

local function ToggleActionsDropDown(owner, anchor)
	LFTActionsDropDown.owner = owner
	if not LFTActionsDropDown.initialize then
		UIDropDownMenu_Initialize(LFTActionsDropDown, LFTActionsDropDown_Init, "MENU")
	end
	ToggleDropDownMenu(1, nil, LFTActionsDropDown, anchor or owner, 5, -5)
end

function LFT_Toggle()
	if arg1 == "RightButton" then
		ToggleActionsDropDown(LFTMinimapButton)
		return
	end
	if LFTFrame:IsVisible() then
		HideUIPanel(LFTFrame)
	else
		ShowUIPanel(LFTFrame)
		if CurrentTab == QUEUE_TAB then
			LFT_Update()
		elseif CurrentTab == BROWSE_TAB then
			LFT_UpdateGroupsList()
		end
		for role, selected in ipairs(SelectedRoles) do
			_G["LFTFrameRole" .. role .. "CheckButton"]:SetChecked(selected)
		end
	end
end

function LFT_InitDropDown()
	local info = UIDropDownMenu_CreateInfo()
	for i, text in ipairs(DropDownItems) do
		info.text = text
		info.func = LFTFrameDropDownItem_OnClick
		info.checked = UIDropDownMenu_GetSelectedID(LFTFrameDropDown) == i
		UIDropDownMenu_AddButton(info)
	end
end

function LFTFrameDropDown_OnLoad()
	UIDropDownMenu_Initialize(LFTFrameDropDown, LFT_InitDropDown)
	UIDropDownMenu_SetWidth(140, LFTFrameDropDown)
	UIDropDownMenu_SetSelectedID(LFTFrameDropDown, DropDownButtonID)
	UIDropDownMenu_SetText(DropDownText, LFTFrameDropDown)
end

function LFTFrameDropDownItem_OnClick()
	DropDownButtonID = this:GetID()
	DropDownText = DropDownItems[DropDownButtonID]
	UIDropDownMenu_SetSelectedID(LFTFrameDropDown, DropDownButtonID)
	UIDropDownMenu_SetText(UIDropDownMenuButton_GetName(), LFTFrameDropDown)
	LFT_UpdateGroupsList()
	LFTFrameScrollFrame:SetVerticalScroll(0)
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

function LFTFrame_OnLoad()
	LFTFrame:RegisterEvent("CHAT_MSG_ADDON")
	LFTFrame:RegisterEvent("CHAT_MSG_SYSTEM")
	LFTFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	LFTFrame:RegisterEvent("PARTY_LEADER_CHANGED")
	LFTFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	LFTFrame:RegisterEvent("PLAYER_LEVEL_UP")
	LFTFrame:RegisterEvent("UNIT_LEVEL")
	LFTFrame:RegisterEvent("VARIABLES_LOADED")
	LFTFrame:RegisterEvent("PLAYER_LOGIN")
	PanelTemplates_SetNumTabs(LFTFrame, 2)
	PanelTemplates_SetTab(LFTFrame, 1)
	FauxScrollFrame_SetOffset(LFTFrameScrollFrame, 0)
	LFTFrameScrollFrameScrollBar:SetMinMaxValues(0, 0)
	LFTFrameScrollFrameScrollBar:SetValue(0)
	for i = 1, DungeonsDisplayed do
		local instanceListEntry = _G["LFTFrameInstanceEntry" .. i]
		if not instanceListEntry then
			instanceListEntry = CreateFrame("Frame", "LFTFrameInstanceEntry" .. i, LFTFrame, "LFTInstanceEntryTemplate")
			instanceListEntry:SetPoint("TOPLEFT", LFTFrame, "TOPLEFT", 25, -InstanceEntryHeight * (i - 1) - 157 )
			tinsert(InstanceEntryFrames, instanceListEntry)
		end
	end
	for i = 1, GroupsDisplayed do
		local groupEntry = _G["LFTFrameGroupEntry"..i]
		if not groupEntry then
			groupEntry = CreateFrame("Button", "LFTFrameGroupEntry"..i, LFTFrame, "LFTGroupEntryTemplate")
			groupEntry:SetPoint("TOPLEFT", LFTFrame, "TOPLEFT", 30, -GroupEntryHeight * (i - 1) - 157)
			tinsert(GroupEntryFrames, groupEntry)
		end
	end
end

function LFTFrame_OnEvent()
	if event == "VARIABLES_LOADED" then
		LFT_Init()
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == LFT_ADDON_PREFIX or arg1 == "TW_CHAT_MSG_WHISPER" then
			LFT_HandleMessage(arg2, arg4)
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		-- update the UI when player leaves the party
		-- ERR_LEFT_GROUP_YOU is defined in GlobalStrings.lua
		if arg1 == ERR_LEFT_GROUP_YOU then
			QueueStatus = nil
			LFT_Delay(0.5, LFT_Update)
		end
		if ListedGroup then
			local _, _, playerJoined = strfind(arg1, (gsub(ERR_JOINED_GROUP_S, "%%s", "(.+)")))
			if playerJoined and IsGroupUsingRoles(ListedGroup) then
				LFT_GroupRoleCheckStart()
			end
		end
	elseif event == "PLAYER_LOGIN" then
		-- check if can enable Browse tab
		Send("C2S_GET_GROUPS_STATUS")
		-- query the server to get current queue status
		-- after a UI reload and update the UI accordingly
		Send("C2S_GET_QUEUE_STATUS")
	elseif event == "PARTY_LEADER_CHANGED" then
		LFT_Update()
	elseif event == "PARTY_MEMBERS_CHANGED" then
		Send("C2S_GET_GROUPS_LIST")
		LFT_Delay(0.5, LFT_Update)
	else
		-- update the UI in all other cases
		LFT_Delay(0.5, LFT_Update)
	end
end

-- LFT command handler
SLASH_LFT1 = "/lft"
SlashCmdList["LFT"] = function(cmd)
	LFT_Toggle()
end

local SearchResults = {}

function LFT_Search()
	for i = getn(SearchResults), 1, -1 do
		tremove(SearchResults, i)
	end
	local query = LFTFrameSearch:GetText()
	if query ~= "" then
		local words = explode(strlower(query), " ")
		for i = 1, getn(Groups) do
			local titleMatch = true
			local descrMatch = true
			for _, word in pairs(words) do
				if not strfind(strlower(Groups[i].title), word, 1, true) then
					titleMatch = false
				end
				if not strfind(strlower(Groups[i].description), word, 1, true) then
					descrMatch = false
				end
			end
			if titleMatch or descrMatch then
				tinsert(SearchResults, Groups[i])
			end
		end
	end
	LFT_UpdateGroupsList()
end

function LFT_Tab_OnClick(id)
	CloseDropDownMenus()
	CurrentTab = id
	UIDropDownMenu_Initialize(LFTFrameDropDown, LFT_InitDropDown)
	UIDropDownMenu_SetSelectedID(LFTFrameDropDown, DropDownButtonID)
	UIDropDownMenu_SetText(DropDownText, LFTFrameDropDown)
	LFTFrameScrollFrame:SetVerticalScroll(0)
	if CurrentTab == BROWSE_TAB then
		LFTFrameRefreshButton:Show()
		LFTFrameMainButton:Hide()
		LFTFrameNewGroupButton:Show()
		LFTFrameDropDown:Show()
		LFTFrameSendMessageButton:Show()
		LFTFrameSearch:Show()
		LFT_UpdateGroupsList()
	elseif CurrentTab == QUEUE_TAB then
		LFTFrameRefreshButton:Hide()
		LFTFrameMainButton:Show()
		LFTFrameNewGroupButton:Hide()
		LFTNewGroupFrame:Hide()
		LFTFrameSearch:Hide()
		LFTFrameDropDown:Hide()
		LFTFrameSendMessageButton:Hide()
		LFT_Update()
	end
end

function LFT_UpdateGroupsList()
	if CurrentTab ~= BROWSE_TAB then
		return
	end

	LFT_ToggleRoleButton(LFTFrame, 1, false, true)
	LFT_ToggleRoleButton(LFTFrame, 2, false, true)
	LFT_ToggleRoleButton(LFTFrame, 3, false, true)
	LFTFrameWarningText:SetText("")

	if QueueStatus ~= "pending" and not next(RolecheckResponses) then
		LFTFrameNewGroupButton:Enable()
	else
		LFTFrameNewGroupButton:Disable()
	end

	for _, frame in pairs(InstanceEntryFrames) do
		frame:Hide()
	end
	for _, frame in pairs(GroupEntryFrames) do
		frame.selected = false
		frame:UnlockHighlight()
		_G[frame:GetName().."Highlight"]:Hide()
		frame:Hide()
	end

	local offset = FauxScrollFrame_GetOffset(LFTFrameScrollFrame) or 0
	local entries = LFTFrameSearch:GetText() ~= "" and SearchResults or Groups
	local data = CustomSort(entries)

	for i = 1, GroupsDisplayed do
		local entry = data[i + offset]
		local name = "LFTFrameGroupEntry"..i
		local groupButton = _G[name]
		local text = _G[name.."Text"]
		local subText = _G[name.."SubText"]
		local leaderText = _G[name.."LeaderText"]
		if entry then
			text:SetText(entry.title)
			subText:SetText(entry.description)
			leaderText:SetText(entry.creator)
			leaderText:SetTextColor(RAID_CLASS_COLORS[entry.class].r, RAID_CLASS_COLORS[entry.class].g, RAID_CLASS_COLORS[entry.class].b)
			for role = 3, 1, -1 do
				local icon = _G[name.."Role"..role.."Icon"]
				local number = _G[name.."Role"..role.."Number"]
				if entry.limit[role] > 0 then
					icon:SetAlpha(1)
					number:SetText(entry.numConfirmed[role].."/"..entry.limit[role])
				else
					icon:SetAlpha(0)
					number:SetText("")
				end
			end
			if entry.limit[3] <= 0 then
				_G[name.."Role2Number"]:ClearAllPoints()
				_G[name.."Role2Number"]:SetPoint("TOPRIGHT", groupButton, 0, 2)
			else
				_G[name.."Role2Number"]:ClearAllPoints()
				_G[name.."Role2Number"]:SetPoint("RIGHT", name.."Role3Icon", "LEFT", -8, 0)
			end
			if entry.limit[2] <= 0 then
				if entry.limit[3] <= 0 then
					_G[name.."Role1Number"]:ClearAllPoints()
					_G[name.."Role1Number"]:SetPoint("TOPRIGHT", groupButton, 0, 2)
				else
					_G[name.."Role1Number"]:ClearAllPoints()
					_G[name.."Role1Number"]:SetPoint("RIGHT", name.."Role3Icon", "LEFT", -8, 0)
				end
			else
				_G[name.."Role1Number"]:ClearAllPoints()
				_G[name.."Role1Number"]:SetPoint("RIGHT", name.."Role2Icon", "LEFT", -8, 0)
			end
			groupButton:Show()
			groupButton.data = entry
			groupButton.title = entry.title
			groupButton.creator = entry.creator
			groupButton.description = entry.description
			-- update highlight
			if SelectedGroup == entry then
				groupButton.selected = true
				groupButton:LockHighlight()
				_G[name.."Highlight"]:Show()
			end
		end
	end

	local shown = FauxScrollFrame_Update(LFTFrameScrollFrame, getn(data), GroupsDisplayed, GroupEntryHeight)
	if not shown then
		LFTFrameScrollFrame:Show()
		LFTFrameScrollFrameScrollBarScrollUpButton:Disable()
		LFTFrameScrollFrameScrollBarScrollDownButton:Disable()
		LFTFrameScrollFrameScrollBarThumbTexture:Hide()
	else
		LFTFrameScrollFrameScrollBarThumbTexture:Show()
	end
	if ListedGroup then
		LFTFrameNewGroupButton:SetText(LFT_EDIT_GROUP)
	else
		LFTFrameNewGroupButton:SetText(LFT_NEW_GROUP)
	end

	if SelectedGroup and SelectedGroup.category == DropDownButtonID and SelectedGroup.creator ~= UnitName("player") then
		LFTFrameSendMessageButton:Enable()
	else
		LFTFrameSendMessageButton:Disable()
	end
end

function LFT_RefreshButton_OnClick()
	Send("C2S_GET_GROUPS_LIST")
	this:Disable()
end

function LFT_RefreshButton_OnUpdate(elapsed)
	if this:IsEnabled() ~= 0 then
		return
	end
	this.time = (this.time or 0) + elapsed
	if this.time > RefreshButtonTick then
		this.time = 0
		this:Enable()
	end
end

function LFTGroupEntry_OnClick()
	if arg1 == "RightButton" and this.creator == UnitName("player") then
		ToggleActionsDropDown(this, "cursor")
		return
	end
	if this.data and this.data ~= SelectedGroup then
		for _, frame in pairs(GroupEntryFrames) do
			frame.selected = false
			frame:UnlockHighlight()
			_G[frame:GetName().."Highlight"]:Hide()
		end
		SelectedGroup = this.data
		this.selected = true
		this:LockHighlight()
		_G[this:GetName().."Highlight"]:Show()

		Send("C2S_GET_GROUP_DETAILS"..LFT_ADDON_FIELD_DELIMITER..this.data.id)
	else
		SelectedGroup = nil
		this.selected = false
		this:UnlockHighlight()
		_G[this:GetName().."Highlight"]:Show()
	end
	if SelectedGroup and SelectedGroup.creator ~= UnitName("player") then
		LFTFrameSendMessageButton:Enable()
	else
		LFTFrameSendMessageButton:Disable()
	end
	-- if this.data and this.data.creator == UnitName("player") then
	-- 	ToggleActionsDropDown(this, "cursor")
	-- end
end

function LFT_DeleteGroup()
	if ListedGroup then
		StaticPopup_Show("LFT_CONFIRM_DELETE_GROUP", ListedGroup.title)
	end
end

function LFTFrameNewGroupButton_OnClick()
	if LFTNewGroupFrame.mode == "pending" then
		return
	end
	if not ListedGroup then
		-- new group
		LFTNewGroupFrame.mode = "new"
		LFTNewGroupFrame:Show()
		LFTNewGroupFrameDeleteButton:Hide()
		LFTNewGroupFrameRoleCheckButton:Hide()
	else
		-- select my group
		LFTNewGroupFrame.mode = "edit"
		LFTNewGroupFrame:Show()
		LFTNewGroupFrameDeleteButton:Show()
		-- LFTNewGroupFrameRoleCheckButton:Show()

		LFTNewGroupUseRolesButton:SetChecked(IsGroupUsingRoles(ListedGroup))
		LFTNewGroupRole1EditBox:SetNumber(ListedGroup.limit[1])
		LFTNewGroupRole2EditBox:SetNumber(ListedGroup.limit[2])
		LFTNewGroupRole3EditBox:SetNumber(ListedGroup.limit[3])
		LFTNewGroupTitleText:SetText(ListedGroup.title)
		LFTNewGroupDescriptionText:SetText(ListedGroup.description)

		LFTNewGroupUseRolesButton_OnClick()
	end
end

function LFTNewGroupUseRolesButton_OnClick()
	local checked = LFTNewGroupUseRolesButton:GetChecked()
	for i = 1, 3 do
		local editBox = _G["LFTNewGroupRole"..i.."EditBox"]
		local editBoxIcon = _G["LFTNewGroupRole"..i.."EditBoxIcon"]
		editBox:ClearFocus()
		editBox:EnableMouse(checked)
		editBox:SetAlpha(checked and 1 or 0.5)
		editBoxIcon:SetDesaturated(not checked)
	end
	LFTNewGroupTitleText:ClearFocus()
	LFTNewGroupDescriptionText:ClearFocus()
	LFT_UpdatePresetButtons()
end

function LFTNewGroupFramePresetDropDown_OnLoad()
	UIDropDownMenu_Initialize(LFTNewGroupFramePresetDropDown, LFTNewGroupFramePresetDropDown_Init)
	UIDropDownMenu_SetWidth(110, LFTNewGroupFramePresetDropDown)
	UIDropDownMenu_SetText(LFT_PRESETS, LFTNewGroupFramePresetDropDown)
end

function LFTNewGroupFramePresetDropDown_Init()
	local info = UIDropDownMenu_CreateInfo()
	if getn(LFTPresets) < UIDROPDOWNMENU_MAXBUTTONS then
		info.text = GREEN_FONT_COLOR_CODE.."+ New Preset"..FONT_COLOR_CODE_CLOSE
		info.func = LFT_ShowNewPresetDialog
		info.arg1 = nil
		info.checked = nil
		info.value = nil
		UIDropDownMenu_AddButton(info)
	end
	for i, data in ipairs(LFTPresets) do
		info.text = data.presetName
		info.func = LFT_PresetSelect
		info.arg1 = i
		info.checked = CurrentPreset == i
		UIDropDownMenu_AddButton(info)
	end
end

function LFT_PresetSave()
	if not (CurrentPreset and LFTPresets[CurrentPreset]) then
		return
	end
	local preset = LFTPresets[CurrentPreset]
	preset.title = LFTNewGroupTitleText:GetText()
	preset.description = LFTNewGroupDescriptionText:GetText()
	if LFTNewGroupUseRolesButton:GetChecked() then
		preset.roles = preset.roles or {}
		preset.roles[1] = LFTNewGroupRole1EditBox:GetNumber()
		preset.roles[2] = LFTNewGroupRole2EditBox:GetNumber()
		preset.roles[3] = LFTNewGroupRole3EditBox:GetNumber()
	else
		preset.roles = nil
	end
	LFTNewGroupTitleText:ClearFocus()
	LFTNewGroupDescriptionText:ClearFocus()
	LFTNewGroupRole1EditBox:ClearFocus()
	LFTNewGroupRole2EditBox:ClearFocus()
	LFTNewGroupRole3EditBox:ClearFocus()
	LFTNewGroupFrameSavePresetButton:Disable()
end

function LFT_PresetDelete()
	if not CurrentPreset then
		return
	end
	if LFTPresets[CurrentPreset] then
		tremove(LFTPresets, CurrentPreset)
	end
	CurrentPreset = nil
	LFTNewGroupUseRolesButton:SetChecked(true)
	LFTNewGroupRole1EditBox:SetNumber(1)
	LFTNewGroupRole2EditBox:SetNumber(1)
	LFTNewGroupRole3EditBox:SetNumber(3)
	LFTNewGroupUseRolesButton_OnClick()
	LFTNewGroupTitleText:SetText("")
	LFTNewGroupDescriptionText:SetText("")
end

function LFT_ShowPresetDeleteDialog()
	if not (CurrentPreset and LFTPresets[CurrentPreset]) then
		return
	end
	StaticPopup_Show("LFT_CONFIRM_DELETE_PRESET", LFTPresets[CurrentPreset].presetName)
end

function LFT_ShowNewPresetDialog()
	if trim(LFTNewGroupTitleText:GetText()) == "" then
		UIErrorsFrame:AddMessage(LFT_PRESET_ERROR_NOT_VALID_TITLE, 1, 0.1, 0.1)
		return
	end
	StaticPopup_Show("LFT_NEW_PRESET")
end

function LFT_PresetSelect(index)
	if not index then
		return
	end
	CurrentPreset = index
	local data = LFTPresets[index]
	LFTNewGroupTitleText:SetText(data.title)
	LFTNewGroupDescriptionText:SetText(data.description)
	LFTNewGroupUseRolesButton:SetChecked(data.roles ~= nil)
	if data.roles then
		LFTNewGroupRole1EditBox:SetNumber(data.roles[1])
		LFTNewGroupRole2EditBox:SetNumber(data.roles[2])
		LFTNewGroupRole3EditBox:SetNumber(data.roles[3])
	end
	UIDropDownMenu_SetText(data.presetName, LFTNewGroupFramePresetDropDown)
	LFTNewGroupUseRolesButton_OnClick()
end

local function PresetChanged()
	if not (CurrentPreset and LFTPresets[CurrentPreset]) then
		return false
	end
	local data = LFTPresets[CurrentPreset]
	local usingRoles = LFTNewGroupUseRolesButton:GetChecked()
	if trim(LFTNewGroupTitleText:GetText()) == "" then
		return false
	end
	if data.title ~= LFTNewGroupTitleText:GetText() or data.description ~= LFTNewGroupDescriptionText:GetText() then
		return true
	end
	if data.roles and not usingRoles or not data.roles and usingRoles then
		return true
	end
	if data.roles and usingRoles then
		if data.roles[1] ~= LFTNewGroupRole1EditBox:GetNumber()
			or data.roles[2] ~= LFTNewGroupRole2EditBox:GetNumber()
			or data.roles[3] ~= LFTNewGroupRole3EditBox:GetNumber() then
			return true
		end
	end
	return false
end

function LFT_UpdatePresetButtons()
	if CurrentPreset then
		if PresetChanged() then
			LFTNewGroupFrameSavePresetButton:Enable()
		else
			LFTNewGroupFrameSavePresetButton:Disable()
		end
		LFTNewGroupFrameDeletePresetButton:Show()
		UIDropDownMenu_SetText(LFTPresets[CurrentPreset].presetName, LFTNewGroupFramePresetDropDown)
	else
		LFTNewGroupFrameSavePresetButton:Disable()
		LFTNewGroupFrameDeletePresetButton:Hide()
		UIDropDownMenu_SetText(LFT_PRESETS, LFTNewGroupFramePresetDropDown)
	end
end

function LFTNewGroupOkButton_OnClick()
	if InGroupOrRaid() and not IsRaidLeader() then
		UIErrorsFrame:AddMessage(ERR_NOT_LEADER, 1, 0.1, 0.1)
		return
	end
	local title = LFTNewGroupTitleText:GetText()
	if trim(title) == "" then
		LFTNewGroupFrame:Hide()
		return
	end
	local description = LFTNewGroupDescriptionText:GetText()
	local tanks, healers, damage = 0, 0, 0

	if LFTNewGroupUseRolesButton:GetChecked() then
		tanks = LFTNewGroupRole1EditBox:GetNumber()
		healers = LFTNewGroupRole2EditBox:GetNumber()
		damage = LFTNewGroupRole3EditBox:GetNumber()
	end

	if LFTNewGroupFrame.mode == "new" then
		LFTNewGroupFrame.mode = "pending"
		Send("C2S_NEW_GROUP"..LFT_ADDON_FIELD_DELIMITER..title..LFT_ADDON_FIELD_DELIMITER..description..LFT_ADDON_FIELD_DELIMITER..DropDownButtonID..LFT_ADDON_FIELD_DELIMITER..tanks..LFT_ADDON_ARRAY_DELIMITER..healers..LFT_ADDON_ARRAY_DELIMITER..damage..LFT_ADDON_FIELD_DELIMITER.."0")

	elseif LFTNewGroupFrame.mode == "edit" and ListedGroup then
		ToggleDropDownMenu(1, nil, LFTFrameDropDown)
		_G["DropDownList1Button"..ListedGroup.category]:Click()

		local data = ListedGroup
		local newTitle = LFTNewGroupTitleText:GetText()
		local newDescription = LFTNewGroupDescriptionText:GetText()
		local newUsingRoles = LFTNewGroupUseRolesButton:GetChecked()
		local newLimit1 = LFTNewGroupRole1EditBox:GetNumber()
		local newLimit2 = LFTNewGroupRole2EditBox:GetNumber()
		local newLimit3 = LFTNewGroupRole3EditBox:GetNumber()

		if newUsingRoles then
			if newLimit1 ~= data.limit[1] or newLimit2 ~= data.limit[2] or newLimit3 ~= data.limit[3] then
				LFTNewGroupFrame.mode = "pending"
			end
		end

		data.title = newTitle
		data.description = newDescription
		if newUsingRoles then
			data.limit[1] = newLimit1
			data.limit[2] = newLimit2
			data.limit[3] = newLimit3
		else
			data.limit[1] = 0
			data.limit[2] = 0
			data.limit[3] = 0
		end

		if LFTNewGroupFrame.mode == "pending" then
			-- drop all confirmed roles
			Send("C2S_UPDATE_GROUP"..LFT_ADDON_FIELD_DELIMITER..data.id..LFT_ADDON_FIELD_DELIMITER..data.title..LFT_ADDON_FIELD_DELIMITER..data.description..LFT_ADDON_FIELD_DELIMITER..data.limit[1]..LFT_ADDON_ARRAY_DELIMITER..data.limit[2]..LFT_ADDON_ARRAY_DELIMITER..data.limit[3])
		else
			-- keep confirmed roles since limits didnt change on this edit
			local confirmedPlayers = ""
			for roleID = 1, 3 do
				for _, players in pairs(data.signups[roleID]) do
					confirmedPlayers = confirmedPlayers..players.name..LFT_ADDON_ARRAY_DELIMITER..roleID..LFT_ADDON_FIELD_DELIMITER
				end
			end
			Send("C2S_UPDATE_GROUP"..LFT_ADDON_FIELD_DELIMITER..data.id..LFT_ADDON_FIELD_DELIMITER..data.title..LFT_ADDON_FIELD_DELIMITER..data.description..LFT_ADDON_FIELD_DELIMITER..data.limit[1]..LFT_ADDON_ARRAY_DELIMITER..data.limit[2]..LFT_ADDON_ARRAY_DELIMITER..data.limit[3]..LFT_ADDON_FIELD_DELIMITER..confirmedPlayers)
		end
	end
	LFTNewGroupFrame:Hide()
end

function LFT_Timer_OnUpdate(elapsed)
	if (this.timeLeft or 0) > 0 then
		this.timeLeft = this.timeLeft - elapsed
		if this.timeLeft <= 0 then
			this.timeLeft = 0
			if LFTRoleCheckFrame:IsShown() and LFTRoleCheckFrame.tab == BROWSE_TAB then
				LFT_RoleCheckDecline()
			end
		end
		this:SetValue(this.timeLeft)
	end
end

StaticPopupDialogs["LFT_CONFIRM_DELETE_GROUP"] = {
	text = LFT_DELETE_GROUP_CONFIRM_TEXT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		if ListedGroup then
			Send("C2S_DELETE_GROUP"..LFT_ADDON_FIELD_DELIMITER..ListedGroup.id)
			SelectedGroup = nil
			LFTFrameSendMessageButton:Disable()
		end
		LFTNewGroupFrame:Hide()
	end,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["LFT_NEW_PRESET"] = {
	text = LFT_PRESET_NEW_TEXT,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnShow = function()
		local editBox = _G[this:GetName() .. "EditBox"]
		editBox:SetScript("OnEnterPressed", function()
			StaticPopup1Button1:Click()
		end)
		editBox:SetScript("OnEscapePressed", function()
			editBox:SetText("")
			StaticPopup1Button2:Click()
		end)
		editBox:SetFocus()
	end,
	OnAccept = function()
		local text = _G[this:GetParent():GetName() .. "EditBox"]:GetText()
		if trim(text) == "" then
			UIErrorsFrame:AddMessage(LFT_PRESET_ERROR_NOT_VALID_NAME, 1, 0.1, 0.1)
			return
		end
		for k, v in pairs(LFTPresets) do
			if v.presetName == text then
				UIErrorsFrame:AddMessage(LFT_PRESET_ERROR_EXISTS, 1, 0.1, 0.1)
				return
			end
		end
		tinsert(LFTPresets, {
			presetName = text,
			title = LFTNewGroupTitleText:GetText(),
			description = LFTNewGroupDescriptionText:GetText(),
			roles = LFTNewGroupUseRolesButton:GetChecked() and {
				LFTNewGroupRole1EditBox:GetNumber(),
				LFTNewGroupRole2EditBox:GetNumber(),
				LFTNewGroupRole3EditBox:GetNumber()
			},
		})
		UIDropDownMenu_SetText(text, LFTNewGroupFramePresetDropDown)
		CurrentPreset = getn(LFTPresets)
		LFT_UpdatePresetButtons()
		_G[this:GetParent():GetName() .. "EditBox"]:SetText("")
	end,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["LFT_CONFIRM_DELETE_PRESET"] = {
	text = LFT_PRESET_DELETE_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = LFT_PresetDelete,
	whileDead = 1,
	hideOnEscape = 1,
}

function LFTFrameSendMessageButton_OnClick()
	if SelectedGroup and SelectedGroup.creator then
		SetItemRef("player:"..SelectedGroup.creator)
	end
end

local function OpenToGroupEdit()
	if not LFTFrame:IsShown() then
		LFT_Toggle()
		LFTFrameTab1:Click()
	end
	LFTFrameNewGroupButton_OnClick()
end

function LFTActionsDropDown_Init()
	local info = UIDropDownMenu_CreateInfo()
	local notEmpty = false
	if ListedGroup then
		if IsGroupUsingRoles(ListedGroup) then
			info.text = LFT_ROLE_CHECK
			info.func = LFT_GroupRoleCheckStart
			info.arg1 = nil
			info.notCheckable = 1
			info.disabled = QueueStatus == "pending" or next(RolecheckResponses)
			UIDropDownMenu_AddButton(info)
		end

		info.text = LFT_EDIT_GROUP
		info.notCheckable = 1
		info.func = OpenToGroupEdit
		info.disabled = QueueStatus == "pending" or next(RolecheckResponses)
		UIDropDownMenu_AddButton(info)

		info.disabled = nil
		info.text = LFT_DELETE_GROUP
		info.func = StaticPopup_Show
		info.arg1 = "LFT_CONFIRM_DELETE_GROUP"
		info.arg2 = ListedGroup.title
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info)
		notEmpty = true
	end
	if QueueStatus == "queued" and LFTActionsDropDown.owner == LFTMinimapButton and GetPartyLeader() == UnitName("player") then
		info.notCheckable = 1
		info.text = LFT_GENERAL_LEAVE_QUEUE_TEXT
		info.func = Send
		info.arg1 = "C2S_QUEUE_LEAVE"
		UIDropDownMenu_AddButton(info)
		notEmpty = true
	end
	if notEmpty then
		info.notCheckable = 1
		info.text = CANCEL
		info.func = HideDropDownMenu
		info.arg1 = 1
		UIDropDownMenu_AddButton(info)
	end
end

function LFT_GroupRoleCheckStart()
	if not ListedGroup then return end

	RolecheckResponses = wipe(RolecheckResponses)
	-- start role check for everyone
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
			if name and online then
				RolecheckResponses[name] = -1
			end
		end
	else
		RolecheckResponses[UnitName("player")] = -1
		for i = 1, GetNumPartyMembers() do
			if UnitIsConnected("party"..i) then
				RolecheckResponses[UnitName("party"..i)] = -1
			end
		end
	end
	SendRaid("C2C_ROLECHECK_START;"..ListedGroup.id)
end
