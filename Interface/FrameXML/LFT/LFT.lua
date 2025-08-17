local Prefix = "TW_LFG"
local Channel = "GUILD"
local ArrayDelimiter = ":"
local FieldDelimiter = ";"
local Red = "|cffff222a"
local Yellow = "|cffffff00"
local White = "|cffffffff"

local MinFinderLevel = 13
local MaxOfferAcceptTime = 90
local MaxRolecheckTime = 90
local RefreshButtonTick = 5
local SignupButtonTick = 0.5
local DetailsFrameFirstTick = 10
local DetailsFrameTick = 7
local CurrentTab = 1

local ControlsDisabled = false
local InQueue = false
local NoRoleSelected = false
local CanSignup = false
local FirstLoad = false

local SelectedGroupFrame = nil
local MyGroupCategory = nil
local MyGroupTitle = nil

local InstanceEntryFrames = {}
local GroupEntryFrames = {}
local SelectedInstances = {}
local Groups = {}
local OfferedGroup = {}

local SelectedRoles = {
	TANK = false,
	HEALER = false,
	DAMAGE = false
}

local DropDownItems = {
	[1] = {
		[1] = LFT_DROPDOWN_TYPE_1,
		[2] = LFT_DROPDOWN_TYPE_2,
	},
	[2] = {
		[1] = LFT_GROUPS_TYPE1,
		[2] = LFT_GROUPS_TYPE2,
		[3] = LFT_GROUPS_TYPE3,
	}
}

local CurrentDropDownText = { DropDownItems[1][1], DropDownItems[2][1] }
local CurrentDropDownValue = { 1, 1 }

-- utils
local function CustomSort(t)
	local a = {}
	for n, l in pairs(t) do
		tinsert(a, { ["code"] = l.code, ["minLevel"] = l.minLevel, ["name"] = n })
	end

	sort(a, function(a, b)
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

local function GetRoleFromCode(code, ignoreLocale)
	if ignoreLocale then
		return code == "t" and "tank" or code == "h" and "healer" or code == "d" and "damage" or ""
	end
	return code == "t" and LFT_ROLE_1 or code == "h" and LFT_ROLE_2 or code == "d" and LFT_ROLE_3 or ""
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

local function InGroupWith(name)
	if not name then
		return false
	end
	if name == UnitName("player") then
		return true
	end
	if not InGroupOrRaid() then
		return false
	end
	for i = 1, 4 do
		if UnitName("party"..i) == name then
			return true
		end
	end
	for i = 1, 40 do
		if UnitName("raid"..i) == name then
			return true
		end
	end
	return false
end

local function GetPartyLeader()
	if not InGroupOrRaid() then
		return
	end
	for i = 1, 4 do
		if UnitIsPartyLeader("party"..i) then
			return UnitName("party"..i)
		end
	end
	for i = 1, 40 do
		if UnitIsPartyLeader("raid"..i) then
			return UnitName("raid"..i)
		end
	end
end

local function IsIgnored(name)
	if not name then
		return false
	end
	for i = 1, GetNumIgnores() do
		if GetIgnoreName(i) == name then
			return true
		end
	end
	return false
end

local function Send(msg)
	SendAddonMessage(Prefix, msg, Channel)
end

-- handle various messages sent by the server via
-- the guild channel
local function LFT_HandleMessageFromServer(message)
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
		local params = explode(message, FieldDelimiter)

		LFT_GroupReadyShow(params[2], params[3])
	end

	-- sent when a group member confirms their role
	-- during a ready check
	if strfind(message, "S2C_OFFER_UPDATE_COUNT") then
		local params = strsub(message, strlen("S2C_OFFER_UPDATE_COUNT") + 2) -- remove message type
		params = explode(params, ":") -- get confirmed roles

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
		params = explode(params, ":") -- get queued instances

		LFT_RoleCheckStart(params)
	end

	-- sent when a group member confirms their role
	-- during a role check
	if strfind(message, "S2C_ROLECHECK_INFO") then
		if GetNumPartyMembers() > 0 then
			local params = explode(message, FieldDelimiter)
			local member = params[2] -- name of the group member who confirmed their role
			local roles = ""
			params = explode(params[3], ":") -- get confirmed roles
			for i = 1, getn(params) do
				roles = roles .. Yellow .. GetRoleFromCode(params[i]) .. White .. ", "
			end

			roles = strsub(roles, 1, -3)

			DEFAULT_CHAT_FRAME:AddMessage(Yellow .. member .. White .. LFT_CHAT_SELECTED_ROLES_TEXT .. roles)
		end
	end

	-- sent when an error is encountered - has
	-- multiple error definitions
	if strfind(message, "S2C_QUEUE_ERROR") then
		local err = strsub(message, strlen("S2C_QUEUE_ERROR") + 2)
		local msg = _G["LFT_CHAT_ERROR_"..strupper(err or "")] or LFT_CHAT_ERROR_INTERNAL
		UIErrorsFrame:AddMessage(msg, 1, 0.1, 0.1)
	end

	-- sent periodically to keep the client updated
	-- about the queue (not true atm - sent only once)
	if strfind(message, "S2C_UPDATE_QUEUE_STATUS") then
		message = strsub(message, strlen("S2C_UPDATE_QUEUE_STATUS") + 2) -- remove message type
		local params = explode(message, FieldDelimiter)
		if strfind(params[1], "queued") then
			InQueue = true
			local instances = explode(params[2], ArrayDelimiter)
			for k in pairs(SelectedInstances) do
				SelectedInstances[k] = false
			end
			for _, v in ipairs(instances) do
				SelectedInstances[v] = true
			end
			LFT_Update()
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
		end
	end
	-- "C2S_GET_GROUPS_STATUS" -- check if server is ready
	-- "C2S_GET_GROUPS_LIST" -- refresh request for groups list
	-- "C2S_GET_GROUP_DETAILS" -- request details for selected group
	-- "C2S_NEW_GROUP" -- when pressing ok in newgroup frame
	-- "C2S_UPDATE_GROUP" -- when creator clicks save button in group details frame
	-- "C2S_DELETE_GROUP" -- when creator clicks delete button
	-- "C2S_SIGNUP" -- when clicking "sign up" button
	-- "C2S_INVITE_ROLE" -- name, roleIndex
	-- "C2S_REMOVE_SIGNUP" -- kick request

	-- "S2C_GROUPS_STATUS" -- 1 if ready or 0 if not
	-- "S2C_GROUPS_LIST_UPDATE" -- groups list update in response to C2S_GET_GROUPS_LIST (doesnt contain details about individual signups)
	-- "S2C_UPDATE_GROUP" -- contains full information about particular group
	-- "S2C_INVITE_ROLE" -- invite to a group you signed is recieved
	-- "S2C_NEW_SIGNUP" -- notification for the leader

	if strfind(message, "S2C_INVITE_ROLE", 1, true) then
		if InGroupOrRaid() then
			return
		end
		local _, _, leader, groupTitle, roleIndex, id = strfind(message, "S2C_INVITE_ROLE;(.+);(.+);(%d+);(%d+)")
		OfferedGroup.leader = leader
		OfferedGroup.title = groupTitle
		OfferedGroup.role = roleIndex
		OfferedGroup.id = id
		return
	end

	if strfind(message, "S2C_GROUPS_STATUS", 1, true) then
		local _, _, status = strfind(message, "S2C_GROUPS_STATUS;(%d)")
		if tonumber(status) ~= 1 then
			-- PanelTemplates_SetTab(LFTFrame, 1)
			LFTFrameTab1:Click()
			PanelTemplates_DisableTab(LFTFrame, 2)
			LFTNewGroupFrame:Hide()
			LFTGroupDetailsFrame:Hide()
			LFTFrameRefreshButton:Disable()
			LFTFrameNewGroupButton:Disable()
			LFTFrameSignUpButton:Disable()
			LFTFrameDropDownButton:Disable()
		else
			PanelTemplates_EnableTab(LFTFrame, 2)
			LFTFrameRefreshButton:Enable()
			LFTFrameNewGroupButton:Enable()
			-- LFTFrameSignUpButton:Enable()
			LFTFrameDropDownButton:Enable()
		end
		return
	end

	if strfind(message, "S2C_GROUPS_LIST_UPDATE", 1, true) then
		if strfind(message, "S2C_GROUPS_LIST_UPDATE;start", 1, true) then
			for i = getn(Groups), 1, -1 do
				tremove(Groups, i)
			end
			MyGroupCategory = nil
		elseif strfind(message, "S2C_GROUPS_LIST_UPDATE;end", 1, true) then
			LFT_UpdateGroupsList()
			if LFTGroupDetailsFrame:IsShown() then
				if LFTGroupDetailsFrame.data and LFTGroupDetailsFrame.data.id then
					Send("C2S_GET_GROUP_DETAILS;"..LFTGroupDetailsFrame.data.id)
					LFTGroupDetailsFrame.time = 0
					LFTGroupDetailsFrame.refreshTime = DetailsFrameFirstTick
				end
			end
		else
			local _, _, data = strfind(message, "S2C_GROUPS_LIST_UPDATE;(.+)")
			local NewGroup = json.decode(data)
			if type(NewGroup) == "table" then
				for k, v in pairs(Groups) do
					if v.id and v.id == NewGroup.id then
						return
					end
				end
				if NewGroup.creator ~= UnitName("player") then
					tinsert(Groups, NewGroup)
				else
					tinsert(Groups, 1, NewGroup)
					MyGroupCategory = NewGroup.category
					MyGroupTitle = NewGroup.title
					LFTNewGroupFrame:Hide()
				end
			end
		end
		return
	end

	if strfind(message, "S2C_UPDATE_GROUP", 1, true) then
		local _, _, groupID, code, data = strfind(message, "S2C_UPDATE_GROUP;(%d+);([%a%d]+);?(.*)")
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
			if code == "start" then
				-- if its a start, should recieve id, title, description, limits and num confirmed
				local miscInfo = json.decode(data)
				if type(miscInfo) == "table" then
					Groups[groupIndex] = miscInfo
					Groups[groupIndex].signups = {{}, {}, {}}
				end
			elseif code == "end" then
				LFTGroupDetailsFrame.data = Groups[groupIndex]
				if SelectedGroupFrame then
					SelectedGroupFrame.data = Groups[groupIndex]
				end
				LFTGroupDetailsFrame_Update()
			elseif code == "invalid" then
				LFTGroupDetailsFrame:Hide()
				UIErrorsFrame:AddMessage(LFT_CHAT_ERROR_INVALID, 1, 0.1, 0.1)
				Send("C2S_GET_GROUPS_LIST")
			else
				-- idividual signups
				local roleIndex = tonumber(code)
				local signupData = json.decode(data)
				if roleIndex and type(signupData) == "table" then
					if roleIndex == 0 then
						-- if not using roles, insert in a list with least amount of players
						local tanks = getn(Groups[groupIndex].signups[1])
						local healers = getn(Groups[groupIndex].signups[2])
						local damage = getn(Groups[groupIndex].signups[3])
						local m = min(tanks, healers, damage)
						roleIndex = (m == tanks and 1) or (m == healers and 2) or (m == damage and 3) or 1
					end
					tinsert(Groups[groupIndex].signups[roleIndex], signupData)
				end
			end
		end
		return
	end

	if strfind(message, "S2C_NEW_SIGNUP", 1, true) then
		if not MyGroupCategory then
			return
		end
		local _, _, name, roles = strfind(message, "S2C_NEW_SIGNUP;(.+);(.*)")
		if name and name ~= UnitName("player") then
			local rolesStr = ""
			local params = explode(roles or "", ":")

			for i = 1, getn(params) do
				rolesStr = rolesStr .. GetRoleFromCode(params[i]) .. ", "
			end
			rolesStr = strsub(rolesStr, 1, -3)
			local color = ChatTypeInfo["SYSTEM"]
			if rolesStr ~= "" then
				DEFAULT_CHAT_FRAME:AddMessage(format(LFT_CHAT_NEW_SIGNUP_ROLES, name, name, rolesStr), color.r, color.g, color.b)
			else
				DEFAULT_CHAT_FRAME:AddMessage(format(LFT_CHAT_NEW_SIGNUP, name, name), color.r, color.g, color.b)
			end
			if LFTGroupDetailsFrame:IsShown() then
				if LFTGroupDetailsFrame.data and LFTGroupDetailsFrame.data.id then
					Send("C2S_GET_GROUP_DETAILS;"..LFTGroupDetailsFrame.data.id)
					LFTGroupDetailsFrame.time = 0
					LFTGroupDetailsFrame.refreshTime = DetailsFrameFirstTick
				end
			elseif not LFTMinimapButton.isPulsing then
				LFTMinimapButton.isPulsing = true
				PlaySound("TellMessage")
				SetButtonPulse(LFTMinimapButton, 120, 1.2)
			end
		end
		return
	end
end

local function LFT_EnableControls()
	for _, frame in ipairs(InstanceEntryFrames) do
		_G[frame:GetName() .. "CheckButton"]:EnableMouse(1)
	end

	local _, class = UnitClass("player")
	for role, available in pairs(LFT_ClassRoles[strupper(class)]) do
		if available then
			local frame = _G["LFTFrameRole" .. gsub(strlower(role), "^%l", strupper)]

			frame:Enable()
			_G[frame:GetName() .. "CheckButton"]:Enable()
			_G[frame:GetName() .. "Background"]:SetDesaturated(0)
			_G[frame:GetName() .. "Icon"]:SetDesaturated(0)
		end
	end

	LFTFrameDropDownButton:Enable()

	LFTFrameMainButton:Enable()
	ControlsDisabled = false
end

local function LFT_DisableControls()
	if CurrentTab ~= 1 then
		return
	end
	for _, frame in ipairs(InstanceEntryFrames) do
		_G[frame:GetName() .. "CheckButton"]:EnableMouse(0)
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
	ControlsDisabled = true
end

-- initialize LFT
local function LFT_Init()
	SelectedRoles["DAMAGE"] = true

	for code in pairs(LFT_Instances) do
		SelectedInstances[code] = false
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
			local frame = _G["LFTRoleCheckFrameRole" .. gsub(strlower(role), "^%l", strupper)]

			frame:Enable()
			_G[frame:GetName() .. "CheckButton"]:Show()
			_G[frame:GetName() .. "Icon"]:SetDesaturated(0)

			_G["LFTFrameRole" .. gsub(strlower(role), "^%l", strupper) .. "CheckButton"]:Show()
		end
	end

	-- update LFT frame
	LFT_Update()

	-- update minimap button tooltip
	LFT_UpdateMinimapTooltip()
end

function LFT_Update()
	LFT_DisableControls()

	if GetNumPartyMembers() > 0 then
		if IsPartyLeader() then
			if InQueue then
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
		if InQueue then
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

	LFT_UpdateInstances()
end

-- handle button click in instances tab based on the button text
function LFT_MainButtonClick()
	if this:GetID() == 1 then
		local instances = ""
		for instanceName in pairs(SelectedInstances) do
			if SelectedInstances[instanceName] then
				instances = instances .. instanceName .. ArrayDelimiter
			end
		end

		local roles = ""
		for roleName in pairs(SelectedRoles) do
			if SelectedRoles[roleName] == true then
				roles = roles .. strsub(roleName, 1, 1) .. ArrayDelimiter
			end
		end

		-- remove delimiter at the end of the string
		instances = strlower(strsub(instances, 1, -2))
		roles = strlower(strsub(roles, 1, -2))

		Send("C2S_QUEUE_JOIN" .. FieldDelimiter .. instances .. FieldDelimiter .. roles)
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
		InQueue = false

		LFTGroupReadyStatusFrame:Hide()

		LFT_CheckIfCanQueue()
		LFT_UpdateMinimapTooltip()

		DEFAULT_CHAT_FRAME:AddMessage(Yellow..format(LFT_GROUP_READY_COMPLETE_TEXT, LFTGroupReadyFrameInstanceName:GetText()))
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

function LFT_RoleCheckStart(instances)

	for role in SelectedRoles do
		-- enable role check confirm button if
		-- at least one role is selected
		if SelectedRoles[role] then
			LFTRoleCheckFrameConfirmButton:Enable()
		end
		_G["LFTRoleCheckFrameRole" .. gsub(strlower(role), "^%l", strupper) .. "CheckButton"]:SetChecked(SelectedRoles[role])
	end

	if getn(instances) > 1 then
		local text = ""
		for i = 1, getn(instances) do
			text = text .. LFT_Instances[instances[i]].name .. ", "
		end
		text = strsub(text, 1, -3)

		LFTRoleCheckFrameInstances.instances = text
		LFTRoleCheckFrameInstancesText:SetText(LFT_ROLE_CHECK_MULTIPLE_INSTANCES_TEXT)
	else
		LFTRoleCheckFrameInstances.instances = nil
		LFTRoleCheckFrameInstancesText:SetText(LFT_ROLE_CHECK_INSTANCES_TEXT .. White .. LFT_Instances[instances[1]].name)
	end

	LFTRoleCheckFrameTimer:SetMinMaxValues(0, MaxRolecheckTime)
	LFTRoleCheckFrameTimer.timeLeft = MaxRolecheckTime
	LFTRoleCheckFrame:Show()

	PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_rolecheck.ogg")
end

function LFT_RoleCheckClick(confirm)
	if confirm then
		local roles = ""
		for roleName in pairs(SelectedRoles) do
			if SelectedRoles[roleName] then
				roles = roles .. strsub(roleName, 1, 1) .. ArrayDelimiter
			end
		end

		roles = strlower(strsub(roles, 1, -2))

		local message = "C2S_ROLECHECK_RESPONSE" .. FieldDelimiter .. roles
		Send(message)

		PlaySound("gsTitleOptionOK")
	else
		-- player declined the role check
		Send("C2S_QUEUE_LEAVE")

		PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_denied.ogg")
	end

	LFTRoleCheckFrame:Hide()
end

function LFT_OnQueueEnter()
	InQueue = true

	LFT_Update()

	LFTRoleCheckFrame:Hide()
	LFTGroupReadyFrame:Hide()
	LFTGroupReadyStatusFrame:Hide()

	LFTMinimapButton:SetScript("OnUpdate", LFT_MinimapButtonOnUpdate)

	PlaySound("PvpEnterQueue")
end

function LFT_OnQueueLeave(sound)
	InQueue = false

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
	if CurrentTab ~= 1 then
		LFTFrameWarningText:SetText("")
		return
	end

	local level = UnitLevel("player")

	-- hide all instance list entries first
	for _, frame in pairs(InstanceEntryFrames) do
		frame:Hide()
	end
	-- hide all group list entries
	for _, frame in pairs(GroupEntryFrames) do
		frame:Hide()
	end

	LFTFrameWarningText:SetText("")
	-- show low level text if player's level doesn't meet the criteria
	if level and level < MinFinderLevel then
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
				level = min(level, UnitLevel(unit))
			end
		end
	end

	local dropdown = CurrentDropDownValue[1]
	local index = 0
	for instanceCode, instance in CustomSort(LFT_Instances) do
		-- show instances within a level range based on the lowest party
		-- member's level
		if (dropdown == 1 and level >= instance.minLevel and level <= instance.maxLevel) or (dropdown == 2 and level >= instance.minLevel) then
			index = index + 1

			local instanceListEntry = _G["LFTFrameInstancesListEntry" .. index]
			if not instanceListEntry then
				instanceListEntry = CreateFrame("Frame", "LFTFrameInstancesListEntry" .. index, LFTFrameInstancesListContent, "LFTInstanceEntryTemplate")
				tinsert(InstanceEntryFrames, instanceListEntry)
				instanceListEntry:SetPoint("TOPLEFT", LFTFrameInstancesListContent, "TOPLEFT", 5, 20 - 20 * (index))
			end

			instanceListEntry:Show()
			instanceListEntry.instance = instanceCode

			local checkbutton = _G[instanceListEntry:GetName() .. "CheckButton"]
			checkbutton:Enable()
			checkbutton:SetChecked(0)
			if SelectedInstances[instanceCode] then
				checkbutton:SetChecked(1)
			end

			_G[instanceListEntry:GetName() .. "Name"]:SetText(instance.name)
			local averageLevel = floor((instance.maxLevel - instance.minLevel) / 2) + instance.minLevel
			local levelDiff = averageLevel - level
			_G[instanceListEntry:GetName() .. "Levels"]:SetText("(" .. instance.minLevel .. " - " .. instance.maxLevel .. ")")
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
			_G[instanceListEntry:GetName() .. "Name"]:SetTextColor(r, g, b)
			_G[instanceListEntry:GetName() .. "Levels"]:SetTextColor(r, g, b)
			_G[instanceListEntry:GetName() .. "Highlight"]:SetVertexColor(r, g, b, 0.7)
			instanceListEntry.r, instanceListEntry.g, instanceListEntry.b = r, g, b
			if ControlsDisabled and not checkbutton:GetChecked() then
				instanceListEntry:SetAlpha(0.5)
			else
				instanceListEntry:SetAlpha(1)
			end
		end
	end

	LFTFrameInstancesList:UpdateScrollChildRect()
end

function LFT_UpdateMinimapTooltip(instances)
	if instances then
		LFTMinimapButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_LEFT", 0, -110)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_1)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_2, 1, 1, 1)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_3, 1, 1, 1)
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_LINE_4, 1, 1, 1)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(LFT_MINIMAP_TOOLTIP_QUEUED)
			for i = 1, getn(instances) do
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
	NoRoleSelected = true
	SelectedRoles[role] = this:GetChecked() == 1 and true or false

	-- enable role check confirm button if at least one
	-- role is selected
	LFTRoleCheckFrameConfirmButton:Disable()
	for role in pairs(SelectedRoles) do
		if SelectedRoles[role] == true then
			LFTRoleCheckFrameConfirmButton:Enable()
			NoRoleSelected = false
			break
		end
	end

	LFT_CheckIfCanQueue()
	LFT_CheckIfCanSignup()
end

function LFT_QueueFor(instance)
	-- get the instance code from the parent
	SelectedInstances[instance] = this:GetChecked() and true or false

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
	for role in pairs(SelectedRoles) do
		if SelectedRoles[role] == true then
			hasRole = true
			break
		end
	end

	if not hasRole then return end

	-- check if the player has at least one instance selected
	local hasInstance = false
	for instance in pairs(SelectedInstances) do
		if SelectedInstances[instance] == true then
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
		if CurrentTab == 1 then
			LFT_Update()
		end
		for role in pairs(SelectedRoles) do
			if SelectedRoles[role] then
				_G["LFTFrameRole" .. gsub(strlower(role), "^%l", strupper) .. "CheckButton"]:SetChecked(true)
			end
		end
	end
end

function LFT_InitDropDown()
	local info = UIDropDownMenu_CreateInfo()
	for _, text in ipairs(DropDownItems[CurrentTab]) do
		info.text = text
		info.func = LFTFrameDropDownItem_OnClick
		info.checked = UIDropDownMenu_GetText(LFTFrameDropDown) == text
		UIDropDownMenu_AddButton(info)
	end
end

function LFTFrameDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, LFT_InitDropDown)
	UIDropDownMenu_SetWidth(160, LFTFrameDropDown)
	UIDropDownMenu_SetSelectedValue(LFTFrameDropDown, 1)
	UIDropDownMenu_SetText(DropDownItems[1][1], LFTFrameDropDown)
end

function LFTFrameDropDownItem_OnClick()
	local text = _G[this:GetName() .. "NormalText"]:GetText()
	UIDropDownMenu_SetSelectedValue(LFTFrameDropDown, this:GetID())
	UIDropDownMenu_SetText(text, LFTFrameDropDown)
	if CurrentTab == 1 then
		for code in pairs(LFT_Instances) do
			SelectedInstances[code] = false
		end
	elseif CurrentTab == 2 then
		LFTGroupDetailsFrame:Hide()
	end
	CurrentDropDownText[CurrentTab] = DropDownItems[CurrentTab][this:GetID()]
	CurrentDropDownValue[CurrentTab] = this:GetID()
	LFT_Update()
	LFT_UpdateGroupsList()
	LFTFrameInstancesList:SetVerticalScroll(0)
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
	LFTFrame:RegisterEvent("PARTY_INVITE_REQUEST")
	UIPanelWindows["LFTFrame"] = { area = "left", pushable = 3 }
	tinsert(UIChildWindows, "LFTNewGroupFrame")
	tinsert(UIChildWindows, "LFTGroupDetailsFrame")
	PanelTemplates_SetNumTabs(LFTFrame, 2)
	PanelTemplates_SetTab(LFTFrame, 1)
end

function LFTFrame_OnEvent()
	if event == "VARIABLES_LOADED" then
		LFT_Init()
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == Prefix then
			LFT_HandleMessageFromServer(arg2)
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		-- update the UI when player leaves the party
		-- ERR_LEFT_GROUP_YOU is defined in GlobalStrings.lua
		if arg1 == ERR_LEFT_GROUP_YOU then
			InQueue = false
			LFT_Delay(0.5, LFT_Update)
		end
	elseif event == "PLAYER_LOGIN" then
		-- check if can enable Browse tab
		Send("C2S_GET_GROUPS_STATUS")
		FirstLoad = true
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- query the server to get current queue status
		-- after a UI reload and update the UI accordingly
		Send("C2S_GET_QUEUE_STATUS")
	elseif event == "PARTY_INVITE_REQUEST" then
		if OfferedGroup.leader and arg1 == OfferedGroup.leader then
			local dialog = StaticPopup_FindVisible("PARTY_INVITE")
			if dialog then
				local role = _G["LFT_ROLE_"..OfferedGroup.role]
				_G[dialog:GetName().."Text"]:SetText(format(role and LFT_SPECIAL_INVITE_TEXT or LFT_SPECIAL_INVITE_TEXT2, OfferedGroup.leader, OfferedGroup.title, role or ""))
				StaticPopup_Resize(dialog, "PARTY_INVITE")
			end
			for k in pairs(OfferedGroup) do
				OfferedGroup[k] = nil
			end
		end
	elseif event == "PARTY_LEADER_CHANGED" then
		LFT_Delay(1, Send, "C2S_GET_GROUPS_LIST")
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

function LFT_Tab_OnClick()
	if this == LFTFrameTab1 then
		CurrentTab = 1
		LFTFrameRefreshButton:Hide()
		LFTFrameMainButton:Show()
		LFTFrameNewGroupButton:Hide()
		LFTFrameSignUpButton:Hide()
		LFTNewGroupFrame:Hide()
		LFTGroupDetailsFrame:Hide()
		LFTFrameSearch:Hide()
	elseif this == LFTFrameTab2 then
		CurrentTab = 2
		LFTFrameRefreshButton:Show()
		LFTFrameMainButton:Hide()
		LFTFrameNewGroupButton:Show()
		LFTFrameSignUpButton:Show()
		LFTFrameSearch:Show()
		if FirstLoad then
			FirstLoad = false
			Send("C2S_GET_GROUPS_LIST")
		end
	end
	UIDropDownMenu_Initialize(LFTFrameDropDown, LFT_InitDropDown)
	UIDropDownMenu_SetSelectedValue(LFTFrameDropDown, CurrentDropDownValue[CurrentTab])
	UIDropDownMenu_SetText(CurrentDropDownText[CurrentTab], LFTFrameDropDown)
	LFT_Update()
	LFT_UpdateGroupsList()
	LFTFrameInstancesList:SetVerticalScroll(0)
	LFTFrameInstancesList:UpdateScrollChildRect()
end

function LFT_UpdateGroupsList()
	if CurrentTab ~= 2 then
		return
	end
	LFTFrameWarningText:SetText("")
	LFT_EnableControls()
	for _, frame in pairs(InstanceEntryFrames) do
		frame:Hide()
	end
	for _, frame in pairs(GroupEntryFrames) do
		frame.selected = false
		frame:UnlockHighlight()
		_G[frame:GetName().."Highlight"]:Hide()
		frame:Hide()
	end
	local entries = LFTFrameSearch:GetText() ~= "" and SearchResults or Groups
	local index = 1
	for i = 1, getn(entries) do
		local data = entries[i]
		if data and data.category == CurrentDropDownValue[2] and not IsIgnored(data.creator) then
			local groupButton = _G["LFTFrameGroupEntry"..index]
			if not groupButton then
				groupButton = CreateFrame("Button", "LFTFrameGroupEntry"..index, LFTFrameInstancesListContent, "LFTGroupEntryTemplate")
				groupButton:SetPoint("TOPLEFT", LFTFrameInstancesListContent, "TOPLEFT", 8, -31 * (index - 1) - 2)
				tinsert(GroupEntryFrames, groupButton)
			end
			local text = _G["LFTFrameGroupEntry"..index.."Text"]
			local subText = _G["LFTFrameGroupEntry"..index.."SubText"]
			text:SetText(data.title)
			subText:SetText(data.creator)
			subText:SetTextColor(RAID_CLASS_COLORS[data.class].r, RAID_CLASS_COLORS[data.class].g, RAID_CLASS_COLORS[data.class].b)
			groupButton.title = data.title
			groupButton.creator = data.creator
			groupButton.description = data.description
			local tanksLimit = data.limit[1]
			local healersLimit = data.limit[2]
			local damageLimit = data.limit[3]
			local numTanksConfirmed = data.numConfirmed[1] or 0
			local numHealersConfirmed = data.numConfirmed[2] or 0
			local numDamageConfirmed = data.numConfirmed[3] or 0
			local tankIcon = _G[groupButton:GetName().."TankIcon"]
			local healerIcon = _G[groupButton:GetName().."HealerIcon"]
			local damageIcon = _G[groupButton:GetName().."DamageIcon"]
			local tankNumber = _G[groupButton:GetName().."TankNumber"]
			local healerNumber = _G[groupButton:GetName().."HealerNumber"]
			local damageNumber = _G[groupButton:GetName().."DamageNumber"]
			tankIcon:SetAlpha(0)
			healerIcon:SetAlpha(0)
			damageIcon:SetAlpha(0)
			tankNumber:SetAlpha(0)
			healerNumber:SetAlpha(0)
			damageNumber:SetAlpha(0)
			if tanksLimit > 0 then
				tankIcon:SetAlpha(1)
				tankNumber:SetText(numTanksConfirmed.."/"..tanksLimit)
				tankNumber:SetAlpha(1)
			end
			if healersLimit > 0 then
				healerIcon:SetAlpha(1)
				healerNumber:SetText(numHealersConfirmed.."/"..healersLimit)
				healerNumber:SetAlpha(1)
			end
			if damageLimit > 0 then
				damageIcon:SetAlpha(1)
				damageNumber:SetText(numDamageConfirmed.."/"..damageLimit)
				damageNumber:SetAlpha(1)
			end
			index = index + 1
			groupButton:Show()
			groupButton.data = data
			-- update highlight
			if LFTGroupDetailsFrame:IsShown() then
				if LFTGroupDetailsFrame.data and LFTGroupDetailsFrame.data.id == data.id then
					groupButton.selected = true
					groupButton:LockHighlight()
					_G[groupButton:GetName().."Highlight"]:Show()
					SelectedGroupFrame = groupButton
				end
			end
		end
	end
	if MyGroupCategory then
		LFTFrameNewGroupButton:SetText(LFT_MY_GROUP)
	else
		LFTFrameNewGroupButton:SetText(LFT_NEW_GROUP)
	end
	LFTFrameInstancesList:UpdateScrollChildRect()
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

function LFTFrameSignUp_OnClick(skipDialog)
	local data = LFTGroupDetailsFrame.data
	if not data then
		return
	end
	if LFTFrameSignUpButton:GetText() ~= LFT_SIGNUP_CANCEL then
		if MyGroupCategory and not skipDialog and not LFTGroupDetailsFrame.canEdit then
			StaticPopup_Show("LFT_CONFIRM_DELETE_GROUP2", MyGroupTitle)
			return
		end
		local isTank, isHealer, isDamage = SelectedRoles.TANK, SelectedRoles.HEALER, SelectedRoles.DAMAGE
		local needTanks = data.limit[1] > 0 and data.numConfirmed[1] < data.limit[1]
		local needHealers = data.limit[2] > 0 and data.numConfirmed[2] < data.limit[2]
		local needDamage = data.limit[3] > 0 and data.numConfirmed[3] < data.limit[3]
		local myRoles = isTank and needTanks and 1 or 0
		myRoles = isHealer and needHealers and myRoles + 2 or myRoles
		myRoles = isDamage and needDamage and myRoles + 4 or myRoles
		Send("C2S_SIGNUP;true;"..data.id..FieldDelimiter..myRoles)
	else
		-- player wants to cancel sign-up
		Send("C2S_SIGNUP;false;"..data.id)
		Send("C2S_GET_GROUP_DETAILS;"..data.id)
	end
	LFTFrameSignUpButton:Disable()
	LFTFrameSignUpButton.time = 0
end

function LFT_SignupButton_OnUpdate(elapsed)
	this.time = (this.time or 0) + elapsed
	if this.time > SignupButtonTick then
		this.time = 0
		if CanSignup then
			this:Enable()
		else
			this:Disable()
		end
	end
end

function LFT_RemoveGroupSelection()
	for _, frame in pairs(GroupEntryFrames) do
		if frame.selected then
			frame.selected = false
			frame:UnlockHighlight()
			_G[frame:GetName().."Highlight"]:Hide()
			break
		end
	end
	LFTFrameSignUpButton.player = nil
	CanSignup = false
	LFTFrameSignUpButton:Disable()
	SelectedGroupFrame = nil
end

function LFTGroupEntry_OnClick()
	if this ~= SelectedGroupFrame then
		LFT_RemoveGroupSelection()
		SelectedGroupFrame = this
		LFTFrameSignUpButton.player = this.creator
		this.selected = true
		this:LockHighlight()
		_G[this:GetName().."Highlight"]:Show()
		LFTGroupDetailsFrame.data = SelectedGroupFrame.data
		Send("C2S_GET_GROUP_DETAILS;"..SelectedGroupFrame.data.id)
		LFTGroupDetailsFrame.time = 0
		LFTGroupDetailsFrame.refreshTime = DetailsFrameFirstTick
		LFTGroupDetailsFrame:Show()
	else
		LFT_RemoveGroupSelection()
		LFTGroupDetailsFrame:Hide()
		_G[this:GetName().."Highlight"]:Show()
		LFTFrameNewGroupButton:Enable()
	end
end

function LFT_GroupDetailsEnableEdit(enable)
	if enable then
		LFTGroupDetailsFrame.canEdit = true
		LFTGroupDetailsTitleText:SetScript("OnEditFocusGained", function()
			this:HighlightText()
			LFTGroupDetailsFrame.pauseUpdates = true
		end)
		LFTGroupDetailsTitleText:SetScript("OnEditFocusLost", function()
			this:HighlightText(0, 0)
			LFTGroupDetailsFrame.pauseUpdates = false
		end)
		LFTGroupDetailsDescriptionText:SetScript("OnEditFocusGained", function()
			this:HighlightText()
			LFTGroupDetailsFrame.pauseUpdates = true
		end)
		LFTGroupDetailsDescriptionText:SetScript("OnEditFocusLost", function()
			this:HighlightText(0, 0)
			LFTGroupDetailsFrame.pauseUpdates = false
		end)
		LFTGroupDetailsTitleText:EnableMouse(true)
		LFTGroupDetailsTitleBackground:EnableMouse(true)
		LFTGroupDetailsDescriptionText:EnableMouse(true)
		LFTGroupDetailsDeleteButton:Show()
		LFTGroupDetailsSaveChangesButton:Show()
		for i = 1, 3 do
			_G["LFTGroupDetailsSignedPlayersFrameLimit"..i]:EnableMouse(true)
			for j = 1, 10 do
				_G["LFTScroll"..i.."SignedPlayer"..j.."Confirmed"]:EnableMouse(true)
				_G["LFTScroll"..i.."SignedPlayer"..j.."Confirmed"]:GetNormalTexture():Show()
			end
		end
		LFTGroupDetailsTitleBackground:Show()
		-- LFTGroupDetailsDescriptionBackground:Show()
		LFTGroupDetailsDescriptionBackground:EnableMouse(true)
	else
		LFTGroupDetailsFrame.canEdit = false
		LFTGroupDetailsTitleText:SetScript("OnEditFocusGained", function()
			this:ClearFocus()
		end)
		LFTGroupDetailsTitleText:SetScript("OnEditFocusLost", nil)
		LFTGroupDetailsDescriptionText:SetScript("OnEditFocusGained", function()
			this:ClearFocus()
		end)
		LFTGroupDetailsDescriptionText:SetScript("OnEditFocusLost", nil)
		LFTGroupDetailsTitleText:EnableMouse(false)
		LFTGroupDetailsTitleBackground:EnableMouse(false)
		LFTGroupDetailsDescriptionText:EnableMouse(false)
		if not UnitFactionGroup("player") then
			LFTGroupDetailsDeleteButton:Show()
		else
			LFTGroupDetailsDeleteButton:Hide()
		end
		LFTGroupDetailsSaveChangesButton:Hide()
		for i = 1, 3 do
			_G["LFTGroupDetailsSignedPlayersFrameLimit"..i]:EnableMouse(false)
			for j = 1, 10 do
				_G["LFTScroll"..i.."SignedPlayer"..j.."Confirmed"]:EnableMouse(false)
				_G["LFTScroll"..i.."SignedPlayer"..j.."Confirmed"]:GetNormalTexture():Hide()
			end
		end
		LFTGroupDetailsTitleBackground:Hide()
		-- LFTGroupDetailsDescriptionBackground:Hide()
		LFTGroupDetailsDescriptionBackground:EnableMouse(false)
	end
end

function LFT_GroupDetailsSaveChanges_OnClick()
	local data = LFTGroupDetailsFrame.data
	data.title = LFTGroupDetailsTitleText:GetText()
	data.description = LFTGroupDetailsDescriptionText:GetText()
	if LFTGroupDetailsFrame.usingRoles then
		data.limit[1] = LFTGroupDetailsSignedPlayersFrameLimit1:GetNumber()
		data.limit[2] = LFTGroupDetailsSignedPlayersFrameLimit2:GetNumber()
		data.limit[3] = LFTGroupDetailsSignedPlayersFrameLimit3:GetNumber()
		LFT_OnLimitChanged(1, data.limit[1])
		LFT_OnLimitChanged(2, data.limit[2])
		LFT_OnLimitChanged(3, data.limit[3])
	end
	local confirmedPlayers = ""
	local roleIndex
	for k, v in pairs(data.signups) do
		roleIndex = not LFTGroupDetailsFrame.usingRoles and 0 or k
		for k2, v2 in pairs(data.signups[k]) do
			if v2.confirmed then
				confirmedPlayers = confirmedPlayers..v2.name..ArrayDelimiter..roleIndex..FieldDelimiter
			end
		end
	end
	LFTGroupDetailsSaveChangesButton:Disable()
	LFTGroupDetailsFrame.pauseUpdates = false
	Send("C2S_UPDATE_GROUP;"..data.id..FieldDelimiter..data.title..FieldDelimiter..data.description..FieldDelimiter..
		data.limit[1]..ArrayDelimiter..data.limit[2]..ArrayDelimiter..data.limit[3]..FieldDelimiter..confirmedPlayers)
	Send("C2S_GET_GROUP_DETAILS;"..data.id)
	LFTGroupDetailsFrame.time = 0
	LFTGroupDetailsFrame.refreshTime = DetailsFrameFirstTick
end

function LFTGroupDetailsFrame_OnShow()
	LFTNewGroupFrame:Hide()
end

function LFTGroupDetailsFrame_OnHide()
	StaticPopup_Hide("LFT_CONFIRM_DELETE_GROUP")
	StaticPopup_Hide("LFT_CONFIRM_DELETE_GROUP2")
	LFTFrameNewGroupButton:Enable()
	LFT_RemoveGroupSelection()
end

local function UpdateSignupsAlpha(alpha)
	for i = 1, 3 do
		for j = 1, 10 do
			_G["LFTScroll"..i.."SignedPlayer"..j]:GetFontString():SetAlpha(alpha)
			_G["LFTScroll"..i.."SignedPlayer"..j]:GetNormalTexture():SetAlpha(alpha)
			_G["LFTScroll"..i.."SignedPlayer"..j.."Level"]:SetAlpha(alpha)
		end
	end
end

function LFTGroupDetailsFrame_OnUpdate(elapsed)
	if LFTGroupDetailsFrame.pauseUpdates or LFTGroupDetailsSaveChangesButton:IsShown() and LFTGroupDetailsSaveChangesButton:IsEnabled() == 1 then
		this.time = 0
		UpdateSignupsAlpha(0.5)
		if LFTGroupDetailsSaveChangesButton:IsEnabled() ~= 1 then
			ButtonPulse_StopPulse(LFTGroupDetailsSaveChangesButton)
			LFTGroupDetailsSaveChangesButton:UnlockHighlight()
		end
		for _, frame in pairs(PULSEBUTTONS) do
			if frame == LFTGroupDetailsSaveChangesButton then
				return
			end
		end
		SetButtonPulse(LFTGroupDetailsSaveChangesButton, 30, 1.2)
		return
	end
	ButtonPulse_StopPulse(LFTGroupDetailsSaveChangesButton)
	LFTGroupDetailsSaveChangesButton:UnlockHighlight()
	UpdateSignupsAlpha(1)
	this.time = (this.time or 0) + elapsed
	if this.time > (this.refreshTime or DetailsFrameTick) then
		this.time = 0
		this.refreshTime = DetailsFrameTick
		if SelectedGroupFrame then
			Send("C2S_GET_GROUP_DETAILS;"..SelectedGroupFrame.data.id)
		end
	end
end

local function SignupSort(a, b)
	if a.confirmed == b.confirmed then
		return a.name < b.name
	else
		return a.confirmed and not b.confirmed
	end
end

function LFTGroupDetailsFrame_Update()
	if not LFTGroupDetailsFrame:IsShown() or LFTGroupDetailsFrame.pauseUpdates then
		return
	end
	local frame = "LFTGroupDetailsSignedPlayersFrame"
	local limit1 = _G[frame.."Limit1"]
	local limit2 = _G[frame.."Limit2"]
	local limit3 = _G[frame.."Limit3"]
	local label1 = _G[frame.."Label1"]
	local label2 = _G[frame.."Label2"]
	local label3 = _G[frame.."Label3"]
	local tankIcon = _G[frame.."TankIcon"]
	local healerIcon = _G[frame.."HealerIcon"]
	local damageIcon = _G[frame.."DamageIcon"]
	LFTGroupDetailsTitleText:SetText(LFTGroupDetailsFrame.data.title)
	LFTGroupDetailsTitleText:ClearFocus()
	LFTGroupDetailsDescriptionText:SetText(LFTGroupDetailsFrame.data.description)
	LFTGroupDetailsDescriptionText:ClearFocus()
	limit1:ClearFocus()
	limit2:ClearFocus()
	limit3:ClearFocus()
	LFTGroupDetailsFrame.usingRoles = LFTGroupDetailsFrame.data.limit[1] > 0 or
									LFTGroupDetailsFrame.data.limit[2] > 0 or
									LFTGroupDetailsFrame.data.limit[3] > 0

	if LFTGroupDetailsFrame.usingRoles then
		if LFTGroupDetailsFrame.data.limit[1] >= 0 then
			tankIcon:Show()
			limit1:Show()
			limit1:SetNumber(LFTGroupDetailsFrame.data.limit[1])
		end
		if LFTGroupDetailsFrame.data.limit[2] >= 0 then
			healerIcon:Show()
			limit2:Show()
			limit2:SetNumber(LFTGroupDetailsFrame.data.limit[2])
		end
		if LFTGroupDetailsFrame.data.limit[3] >= 0 then
			damageIcon:Show()
			limit3:Show()
			limit3:SetNumber(LFTGroupDetailsFrame.data.limit[3])
		end
	else
		-- if not using roles, hide tanks, healers, damage labels
		tankIcon:Hide()
		healerIcon:Hide()
		damageIcon:Hide()
		limit1:Hide()
		limit2:Hide()
		limit3:Hide()
		label1:SetText("")
		label2:SetText("")
		label3:SetText("")
	end
	if LFTGroupDetailsFrame.data.creator ~= UnitName("player") then
		LFT_GroupDetailsEnableEdit(false)
		LFTFrameNewGroupButton:Enable()
	else
		LFT_GroupDetailsEnableEdit(true)
		LFTFrameNewGroupButton:Disable()
		ButtonPulse_StopPulse(LFTMinimapButton)
		LFTMinimapButton:UnlockHighlight()
		LFTMinimapButton.isPulsing = false
	end
	sort(LFTGroupDetailsFrame.data.signups[1], SignupSort)
	sort(LFTGroupDetailsFrame.data.signups[2], SignupSort)
	sort(LFTGroupDetailsFrame.data.signups[3], SignupSort)
	LFT_SignupsScrollUpdate(_G[frame.."Scroll1"])
	LFT_SignupsScrollUpdate(_G[frame.."Scroll2"])
	LFT_SignupsScrollUpdate(_G[frame.."Scroll3"])
	-- adjust signup button text
	LFTFrameSignUpButton:SetText(LFT_SIGNUP)
	local playerName = UnitName("player")
	for _, roleData in pairs(LFTGroupDetailsFrame.data.signups) do
		for _, signup in pairs(roleData) do
			if signup.name == playerName then
				LFTFrameSignUpButton:SetText(LFT_SIGNUP_CANCEL)
				break
			end
		end
	end
	LFTGroupDetailsSignedPlayersFrameScroll1:SetVerticalScroll(1)
	LFTGroupDetailsSignedPlayersFrameScroll2:SetVerticalScroll(1)
	LFTGroupDetailsSignedPlayersFrameScroll3:SetVerticalScroll(1)
	LFT_CheckIfCanSignup()
	LFT_UpdateGroupsList()
end

function LFTGroupDetailsDeleteButton_OnClick()
	StaticPopup_Show("LFT_CONFIRM_DELETE_GROUP")
	PlaySound("igMainMenuOptionCheckBoxOn")
end

function LFTGroupDetailsSignedPlayersFrame_OnLoad()
	for i = 1, 3 do
		for j = 1, 10 do
			local button = CreateFrame("Button", "LFTScroll"..i.."SignedPlayer"..j, LFTGroupDetailsSignedPlayersFrame, "LFTSignedPlayerButtonTemplate")
			button:SetPoint("TOPLEFT", _G["LFTGroupDetailsSignedPlayersFrameScroll"..i], "TOPLEFT", 14, (j-1) * -15)
			button:Hide()
		end
	end
end

function LFT_SignupsScrollUpdate(scroll)
	local scrollFrame = scroll or this
	local scrollID = scrollFrame:GetID()
	local usingRoles = LFTGroupDetailsFrame.usingRoles
	local data = LFTGroupDetailsFrame.data
	if not data or not data.signups then
		return
	end
	local signups = data.signups[scrollID]
	local limit = data.limit[scrollID] or 0
	local numConfirmed = data.numConfirmed[scrollID] or 0
	local numSigned = getn(signups)
	local offset = FauxScrollFrame_GetOffset(scrollFrame) or 0
	FauxScrollFrame_Update(scrollFrame, numSigned, 10, 16)
	for i = 1, 10 do
		local signupIndex = i + offset
		local button = _G["LFTScroll"..scrollID.."SignedPlayer"..i]
		local levelText = _G["LFTScroll"..scrollID.."SignedPlayer"..i.."Level"]
		local checkButton = _G["LFTScroll"..scrollID.."SignedPlayer"..i.."Confirmed"]
		button:Hide()
		if signupIndex > 0 and signupIndex <= numSigned and signups[signupIndex].name then
			local name = signups[signupIndex].name
			local class = signups[signupIndex].class
			local level = signups[signupIndex].level
			local confirmed = signups[signupIndex].confirmed
			local classColor = RAID_CLASS_COLORS[class]
			local levelColor = GetDifficultyColor(level) or {r=1,g=1,b=1}
			button:SetText(name)
			button:SetTextColor(classColor.r, classColor.g, classColor.b)
			levelText:SetText(level)
			levelText:SetTextColor(levelColor.r, levelColor.g, levelColor.b)
			checkButton:SetChecked(confirmed)
			if LFTGroupDetailsFrame.canEdit then
				if not usingRoles and InGroupWith(name) then
					checkButton:GetNormalTexture():Show()
					checkButton:EnableMouse(true)
				else
					if (not confirmed and numConfirmed >= limit) or not InGroupWith(name) then
						checkButton:GetNormalTexture():Hide()
						checkButton:EnableMouse(false)
					else
						checkButton:GetNormalTexture():Show()
						checkButton:EnableMouse(true)
					end
				end
			else
				checkButton:GetNormalTexture():Hide()
				checkButton:EnableMouse(false)
			end
			button:Show()
		end
	end
	if usingRoles and scroll then
		local label = _G["LFTGroupDetailsSignedPlayersFrameLabel"..scrollID]
		if limit >= 0 then
			label:SetText(numConfirmed.."/")
		end
	end
end

local dropdownPlayer

function LFT_SignedPlayer_OnClick()
	dropdownPlayer = this:GetText()
	UIDropDownMenu_Initialize(LFTGroupDetailsFrameDropDown, LFTGroupDetailsFrameDropDown_Init, "MENU")
	-- set UIDROPDOWNMENU_MENU_VALUE to 1,2 or 3 for invite function
	ToggleDropDownMenu(1, tonumber(strsub(this:GetName(), 10, 10)), LFTGroupDetailsFrameDropDown, this, 0, 0)
	PlaySound("igMainMenuOptionCheckBoxOn")
end

function LFTGroupDetailsFrameDropDown_Init()
	local roleID = 0
	if LFTGroupDetailsFrame.usingRoles and LFTGroupDetailsFrame.canEdit then
		roleID = UIDROPDOWNMENU_MENU_VALUE
	end

	local info = UIDropDownMenu_CreateInfo()
	info.isTitle = 1
	info.notCheckable = 1
	info.text = dropdownPlayer
	info.func = nil
	info.arg1 = nil
	info.arg2 = nil
	UIDropDownMenu_AddButton(info)

	if dropdownPlayer ~= UnitName("player") then
		info.isTitle = nil
		info.disabled = nil
		info.notCheckable = 1
		info.text = WHISPER
		info.func = SetItemRef
		info.arg1 = "player:"..dropdownPlayer
		info.arg2 = nil
		UIDropDownMenu_AddButton(info)
	end

	info.isTitle = nil
	info.disabled = nil
	info.notCheckable = 1
	info.text = TARGET
	info.func = TargetByName
	info.arg1 = dropdownPlayer
	info.arg2 = 1
	UIDropDownMenu_AddButton(info)

	if dropdownPlayer ~= UnitName("player") then
		if LFTGroupDetailsFrame.canEdit then
			if not InGroupWith(dropdownPlayer) and roleID then
				info.isTitle = nil
				info.disabled = nil
				info.notCheckable = 1
				if _G["LFT_ROLE_"..roleID] then
					info.text = PARTY_INVITE.." (".._G["LFT_ROLE_"..roleID]..")"
				else
					info.text = PARTY_INVITE
				end
				info.func = LFT_Invite
				info.arg1 = dropdownPlayer
				info.arg2 = roleID
				UIDropDownMenu_AddButton(info)
			end

			info.isTitle = nil
			info.disabled = nil
			info.text = REMOVE
			info.func = LFT_RemoveSignup
			info.arg1 = dropdownPlayer
			info.arg2 = nil
			UIDropDownMenu_AddButton(info)
		end

		info.isTitle = nil
		info.disabled = nil
		info.text = REPORT
		info.func = ToggleHelpFrame
		info.arg1 = nil
		info.arg2 = nil
		UIDropDownMenu_AddButton(info)

		info.isTitle = nil
		info.disabled = nil
		info.text = IGNORE_PLAYER
		info.func = AddIgnore
		info.arg1 = dropdownPlayer
		info.arg2 = nil
		UIDropDownMenu_AddButton(info)
	end

	info.isTitle = nil
	info.disabled = nil
	info.notCheckable = 1
	info.text = CANCEL
	info.func = HideDropDownMenu
	info.arg1 = 1
	info.arg2 = nil
	UIDropDownMenu_AddButton(info)
end

function LFT_Invite(name, roleID)
	if not LFTGroupDetailsFrame.data or name == UnitName("player") then
		return
	end
	Send("C2S_INVITE_ROLE;"..LFTGroupDetailsFrame.data.id..FieldDelimiter..name..FieldDelimiter..roleID)
end

function LFT_RemoveSignup(name)
	if InGroupWith(name) then
		UninviteByName(name)
	else
		Send("C2S_REMOVE_SIGNUP;"..name)
	end
end

function LFT_SignedPlayerCheckButton_OnClick()
	if not LFTGroupDetailsFrame.canEdit then
		return
	end
	local roleID = tonumber(strsub(this:GetName(), 10, 10))
	local signups = LFTGroupDetailsFrame.data.signups[roleID]
	local limit = LFTGroupDetailsFrame.data.limit[roleID] or 0
	LFT_OnLimitChanged(roleID, limit)
	local numConfirmed = LFTGroupDetailsFrame.data.numConfirmed[roleID] or 0
	local name = this:GetParent():GetText()

	if (not this:GetChecked() and numConfirmed <= limit) or (this:GetChecked() and numConfirmed < limit) or not LFTGroupDetailsFrame.usingRoles then
		for _, signup in pairs(signups) do
			if signup.name == name then
				signup.confirmed = not signup.confirmed
				numConfirmed = (signup.confirmed and numConfirmed + 1) or (not signup.confirmed and numConfirmed - 1) or 0
				if numConfirmed > limit then
					numConfirmed = limit
				end
				if numConfirmed < 0 then
					numConfirmed = 0
				end
				-- remove from other lists if signed to other roles
				for k, v in pairs(LFTGroupDetailsFrame.data.signups) do
					if k ~= roleID then
						for _, v2 in pairs(v) do
							if v2.name == name and v2.confirmed then
								v2.confirmed = false
								LFTGroupDetailsFrame.data.numConfirmed[k] = LFTGroupDetailsFrame.data.numConfirmed[k] - 1
							end
						end
					end
				end
				break
			end
		end
		LFTGroupDetailsFrame.data.numConfirmed[roleID] = numConfirmed
		if this:GetChecked() then
			PlaySound("igMainMenuOptionCheckBoxOn")
		else
			PlaySound("igMainMenuOptionCheckBoxOff")
		end
		LFTGroupDetailsSaveChangesButton:Enable()
	else
		this:SetChecked(false)
		PlaySound("igMainMenuOptionCheckBoxOff")
	end
	LFT_SignupsScrollUpdate(LFTGroupDetailsSignedPlayersFrameScroll1)
	LFT_SignupsScrollUpdate(LFTGroupDetailsSignedPlayersFrameScroll2)
	LFT_SignupsScrollUpdate(LFTGroupDetailsSignedPlayersFrameScroll3)
end

function LFT_OnLimitChanged(roleID, number)
	local roleID = roleID or this:GetID()
	local number = number or this:GetNumber()
	local signups = LFTGroupDetailsFrame.data.signups[roleID]
	local limit = LFTGroupDetailsFrame.data.limit[roleID] or 0
	local numConfirmed = LFTGroupDetailsFrame.data.numConfirmed[roleID] or 0

	if numConfirmed > number then
		for _, signup in pairs(signups) do
			signup.confirmed = false
		end
		numConfirmed = 0
		limit = number
		local label = _G["LFTGroupDetailsSignedPlayersFrameLabel"..roleID]
		if limit >= 0 and LFTGroupDetailsFrame.usingRoles then
			label:SetText("0/")
		end
		for i = 1, 10 do
			_G["LFTScroll"..roleID.."SignedPlayer"..i.."Confirmed"]:SetChecked(false)
		end
	end
end

function LFTDetailsLimitEditBox_OnEditFocusLost()
	this:HighlightText(0, 0)
	LFTGroupDetailsFrame.pauseUpdates = false
	this.inFocus = false
	this:SetTextColor(1, 0.82, 0)
	if LFTGroupDetailsFrame.canEdit then
		LFT_OnLimitChanged(roleID, this:GetNumber())
	end
end

function LFTFrameNewGroupButton_OnClick()
	if not MyGroupCategory then
		-- new group
		LFTNewGroupFrame:Show()
	else
		-- select my group
		ToggleDropDownMenu(1, nil, LFTFrameDropDown)
		_G["DropDownList1Button"..MyGroupCategory]:Click()
		LFTFrameGroupEntry1:Click()
		this:Disable()
	end
end

function LFTNewGroupUseRolesButton_OnClick()
	if not this:GetChecked() then
		LFTNewGroupTanksEditBox:EnableMouse(nil)
		LFTNewGroupTanksEditBox:ClearFocus()
		LFTNewGroupTanksEditBoxIcon:SetDesaturated(1)
		LFTNewGroupTanksEditBox:SetAlpha(0.5)

		LFTNewGroupHealersEditBox:EnableMouse(nil)
		LFTNewGroupHealersEditBox:ClearFocus()
		LFTNewGroupHealersEditBoxIcon:SetDesaturated(1)
		LFTNewGroupHealersEditBox:SetAlpha(0.5)

		LFTNewGroupDamageEditBox:EnableMouse(nil)
		LFTNewGroupDamageEditBox:ClearFocus()
		LFTNewGroupDamageEditBoxIcon:SetDesaturated(1)
		LFTNewGroupDamageEditBox:SetAlpha(0.5)
	else
		LFTNewGroupTanksEditBox:EnableMouse(1)
		LFTNewGroupTanksEditBoxIcon:SetDesaturated(nil)
		LFTNewGroupTanksEditBox:SetAlpha(1)

		LFTNewGroupHealersEditBox:EnableMouse(1)
		LFTNewGroupHealersEditBoxIcon:SetDesaturated(nil)
		LFTNewGroupHealersEditBox:SetAlpha(1)

		LFTNewGroupDamageEditBox:EnableMouse(1)
		LFTNewGroupDamageEditBoxIcon:SetDesaturated(nil)
		LFTNewGroupDamageEditBox:SetAlpha(1)
	end
	LFTNewGroupTitleText:ClearFocus()
	LFTNewGroupDescriptionText:ClearFocus()
	LFTNewGroupTanksEditBox:ClearFocus()
	LFTNewGroupHealersEditBox:ClearFocus()
	LFTNewGroupDamageEditBox:ClearFocus()
	PlaySound("igMainMenuOptionCheckBoxOn")
end

function LFTNewGroupOkButton_OnClick()
	local title = LFTNewGroupTitleText:GetText()
	if InGroupOrRaid() then
		UIErrorsFrame:AddMessage(LFT_CHAT_ERROR_IN_GROUP, 1, 0.1, 0.1)
		return
	end
	if trim(title) ~= "" then
		local isTank, isHealer, isDamage = false, false, false
		local description = LFTNewGroupDescriptionText:GetText()
		local tanks, healers, damage = 0, 0, 0
		if LFTNewGroupUseRolesButton:GetChecked() then
			tanks = LFTNewGroupTanksEditBox:GetNumber()
			healers = LFTNewGroupHealersEditBox:GetNumber()
			damage = LFTNewGroupDamageEditBox:GetNumber()
			isTank, isHealer, isDamage = SelectedRoles.TANK, SelectedRoles.HEALER, SelectedRoles.DAMAGE
		end
		local myRoles = isTank and 1 or 0
		myRoles = isHealer and myRoles + 2 or myRoles
		myRoles = isDamage and myRoles + 4 or myRoles
		-- cancel signups if player have any
		for k, v in pairs(Groups) do
			for i = 3, 1, -1 do
				local v2 = v.signups and v.signups[i]
				if v2 then
					for k3, v3 in pairs(v2) do
						if v3.name == UnitName("player") then
							Send("C2S_SIGNUP;false;"..v.id)
							i = 1
							break
						end
					end
				end
			end
		end
		Send("C2S_NEW_GROUP;"..title..FieldDelimiter..description..FieldDelimiter..CurrentDropDownValue[2]..FieldDelimiter..
			tanks..ArrayDelimiter..healers..ArrayDelimiter..damage..FieldDelimiter..myRoles)
	end
	LFTNewGroupFrame:Hide()
end

function LFT_CheckIfCanSignup()
	if not SelectedGroupFrame then
		LFTFrameSignUpButton:Disable()
		CanSignup = false
		return
	end
	-- should be able to cancel always
	if LFTFrameSignUpButton:GetText() == LFT_SIGNUP_CANCEL then
		LFTFrameSignUpButton:Enable()
		CanSignup = true
		return
	end
	-- this is group with roles but we dont have any selected
	local groupWithRoles = SelectedGroupFrame.data.limit[1] > 0 or SelectedGroupFrame.data.limit[2] > 0 or SelectedGroupFrame.data.limit[3] > 0
	if NoRoleSelected and groupWithRoles then
		LFTFrameSignUpButton:Disable()
		CanSignup = false
		return
	end
	-- all roles are filled
	if groupWithRoles then
		local needTanks = SelectedGroupFrame.data.limit[1] > 0 and SelectedGroupFrame.data.numConfirmed[1] < SelectedGroupFrame.data.limit[1]
		local needHealers = SelectedGroupFrame.data.limit[2] > 0 and SelectedGroupFrame.data.numConfirmed[2] < SelectedGroupFrame.data.limit[2]
		local needDamage = SelectedGroupFrame.data.limit[3] > 0 and SelectedGroupFrame.data.numConfirmed[3] < SelectedGroupFrame.data.limit[3]
		CanSignup = false
		if SelectedRoles.DAMAGE then
			CanSignup = needDamage
		end
		if SelectedRoles.TANK then
			CanSignup = needTanks
		end
		if SelectedRoles.HEALER then
			CanSignup = needHealers
		end
		return
	end

	-- group without roles
	CanSignup = true
end

function LFT_CheckEdit()
	LFTGroupDetailsSaveChangesButton:Disable()
	if not LFTGroupDetailsFrame.data then
		-- no data yet
		return false
	end
	-- empty title is a no-no
	if trim(LFTGroupDetailsTitleText:GetText()) == "" then
		return false
	end
	-- check if title was changed
	if LFTGroupDetailsTitleText:GetText() ~= LFTGroupDetailsFrame.data.title then
		LFTGroupDetailsSaveChangesButton:Enable()
		return true
	end
	-- check if description was changed
	if LFTGroupDetailsDescriptionText:GetText() ~= LFTGroupDetailsFrame.data.description then
		LFTGroupDetailsSaveChangesButton:Enable()
		return true
	end
	-- check if limit was changed
	for i = 1, 3 do
		if LFTGroupDetailsFrame.data.limit[i] and LFTGroupDetailsFrame.data.limit[i] ~= _G["LFTGroupDetailsSignedPlayersFrameLimit"..i]:GetNumber() then
			LFTGroupDetailsSaveChangesButton:Enable()
			return true
		end
	end
end

function LFT_Timer_OnUpdate(elapsed)
	if (this.timeLeft or 0 ) > 0 then
		this.timeLeft = this.timeLeft - elapsed
		if this.timeLeft <= 0 then
			this.timeLeft = 0
		end
		this:SetValue(this.timeLeft)
	end
end

StaticPopupDialogs["LFT_CONFIRM_DELETE_GROUP"] = {
	text = LFT_DELETE_GROUP_CONFIRM_TEXT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		if not UnitFactionGroup("player") then
			SendChatMessage(".lft listing delete "..LFTGroupDetailsFrame.data.id)
		else
			Send("C2S_DELETE_GROUP;"..LFTGroupDetailsFrame.data.id)
		end
		LFTGroupDetailsFrame:Hide()
	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
}

StaticPopupDialogs["LFT_CONFIRM_DELETE_GROUP2"] = {
	text = LFT_DELETE_GROUP_CONFIRM_TEXT2,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		LFTFrameSignUp_OnClick(true)
		Send("C2S_GET_GROUPS_LIST")
	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
}
