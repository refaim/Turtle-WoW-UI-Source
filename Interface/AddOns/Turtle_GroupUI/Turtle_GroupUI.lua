local clusterFrames = {}
local memberFrames = {}
local memberPets = {}
local petFrames = {}
local roster = {}

local clusterBackdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
}

local clusterBackdropBorderless = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
}

local healthColor = { r = 0.0, g = 1.0, b = 0.0 }
local manaColor = { r = 0.0, g = 0.4, b = 1.0 }
local nameColor = { r = 1.0, g = 1.0, b = 1.0 }

local function UpdateMemberAuras(f)
	local frame = f or this
	local unit = frame.unit
	if not unit then return end

	frame.debuffHighlight:Hide()
	frame.debuffIndicator:Hide()

	for _, button in frame.auraButtons do
		button:SetID(0)
		button:Hide()
	end

	for i = 1, 40 do
		local debuff, _, type = UnitDebuff(unit, i, 1)
		if type then
			local color = DebuffTypeColor[type]

			if GROUP_DEBUFF_INDICATOR_STYLE == "1" then
				frame.debuffIndicatorTexture:SetTexture("Interface\\GroupFrame\\UI-Group-Debuff" .. type)
			elseif GROUP_DEBUFF_INDICATOR_STYLE == "2" then
				frame.debuffHighlight:Show()
				frame.debuffHighlight:SetVertexColor(color.r, color.g, color.b, 1)

				frame.debuffIndicatorTexture:SetTexture("Interface\\GroupFrame\\UI-Group-Debuff" .. type)
			elseif GROUP_DEBUFF_INDICATOR_STYLE == "3" then
				frame.debuffIndicatorTexture:SetTexture(debuff)
			elseif GROUP_DEBUFF_INDICATOR_STYLE == "4" then
				frame.debuffHighlight:Show()
				frame.debuffHighlight:SetVertexColor(color.r, color.g, color.b, 1)

				frame.debuffIndicatorTexture:SetTexture(debuff)
			else
				frame.debuffHighlight:Show()
				frame.debuffHighlight:SetVertexColor(color.r, color.g, color.b, 1)
			end

			frame.debuffIndicator.type = "debuff"
			frame.debuffIndicator:SetID(i)
			frame.debuffIndicator:Show()
			break
		end
	end

	local button
	local maxBuffs = math.floor(GROUP_UNIT_WIDTH / 14)
	local shown = 0
	for i = 1, 16 do
		local buff = UnitBuff(unit, i, 1)
		if buff then
			shown = shown + 1

			button = frame.auraButtons[shown]
			if shown > maxBuffs or not button then break end

			button.texture:SetTexture(buff)
			button.type = "buff"
			button:SetID(i)
			button:Show()
		end
	end
end

local function UpdateMemberDisplayPower(f)
	local frame = f or this
	local unit = frame.unit
	if unit then
		local power = UnitPowerType(frame.unit)
		local color = power == 0 and manaColor or ManaBarColor[power]

		frame.powerbar:SetStatusBarColor(color.r, color.g, color.b)
		frame.powerbar:SetBackdropColor(color.r - 0.6, color.g - 0.6, color.b - 0.6, 0.8)
	end
end

local function UpdateMemberHealth(f)
	local frame = f or this
	local unit = frame.unit
	if not unit then return end

	if not UnitIsConnected(unit) and UnitIsPlayer(unit) then
		frame.statusText:SetText(PLAYER_OFFLINE)
		frame.statusText:SetTextColor(0.7, 0.7, 0.7)

		frame.healthbar:SetStatusBarColor(0.6, 0.6, 0.6)
		frame.healthbar:SetMinMaxValues(0, 1)
		frame.healthbar:SetValue(1)

		frame:SetScript("OnUpdate", nil)
		return
	elseif UnitIsDeadOrGhost(unit) then
		frame.healthbar:SetMinMaxValues(0, 1)
		frame.healthbar:SetValue(0)

		if UnitIsGhost(unit) then
			frame.statusText:SetText(GHOST)
			frame.statusText:SetTextColor(0.7, 0.7, 0.7)
		else
			frame.statusText:SetText(DEAD)
			frame.statusText:SetTextColor(0.7, 0, 0)
		end
		return
	else
		frame.statusText:SetText("")
	end

	local health = UnitHealth(unit)
	local healthMax = UnitHealthMax(unit)

	frame.healthbar:SetMinMaxValues(0, healthMax)
	frame.healthbar:SetValue(health)

	if GROUP_UNIT_HEALTH_COLOR == "2" then
		local percentage = ceil((health / healthMax) * 100)

		if percentage == 100 then
			frame.healthbar:SetStatusBarColor(0, 1, 0)
		elseif percentage < 100 and percentage >= 75 then
			frame.healthbar:SetStatusBarColor(0.6, 0.8, 0)
		elseif percentage < 75 and percentage >= 50 then
			frame.healthbar:SetStatusBarColor(1, 1, 0)
		elseif percentage < 50 and percentage >= 25 then
			frame.healthbar:SetStatusBarColor(0.8, 0.6, 0)
		elseif percentage < 25 then
			frame.healthbar:SetStatusBarColor(1, 0, 0)
		end
	end
end

local function UpdateMemberPower(f)
	local frame = f or this
	local unit = frame.unit
	if unit then
		frame.powerbar:SetMinMaxValues(0, UnitManaMax(unit))
		frame.powerbar:SetValue(UnitMana(unit))
	end
end

local function UpdateMemberFrame(frame)
	if not frame or not frame.unit then return end

	local unit = frame.unit
	local name = UnitName(unit)
	local _, class = UnitClass(unit)
	local barColor = (GROUP_UNIT_HEALTH_COLOR == "3" and class) and RAID_CLASS_COLORS[class] or healthColor
	local nameTextColor = (GROUP_CLASS_COLORED_NAMES == "1" and class) and RAID_CLASS_COLORS[class] or nameColor

	if strfind(unit, "pet") then
		barColor = healthColor
		nameTextColor = nameColor
	end

	frame.nameText:SetText(name)
	frame.nameText:SetTextColor(nameTextColor.r, nameTextColor.g, nameTextColor.b)
	frame.nameText:SetWidth(GROUP_UNIT_WIDTH - 18)

	if UnitIsUnit(unit, "player") then
		frame:SetScript("OnUpdate", nil)
	elseif UnitIsPlayer(unit) then
		frame:SetScript("OnUpdate", GroupMemberFrame_OnUpdate)
	end

	frame.healthbar:SetStatusBarColor(barColor.r, barColor.g, barColor.b)

	UpdateMemberAuras(frame)
	UpdateMemberDisplayPower(frame)
	UpdateMemberHealth(frame)
	UpdateMemberPower(frame)
end

local function FinishReadyCheck()
	GroupFrame.elapsed = 0
	GroupFrame:SetScript("OnUpdate", function()
		if this.elapsed >= 5 then
			for _, frame in ipairs(memberFrames) do
				frame.readyIcon:Hide()
			end
			this:SetScript("OnUpdate", nil)
		end
		this.elapsed = this.elapsed + arg1
	end)

	for _, frame in ipairs(memberFrames) do
		if frame.isReady == -1 or frame.isReady == 0 then
			frame.readyIcon:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-notready")
		end
	end
end

local function UpdateHighlight()
	local highlight = GroupFrame.currentHighlight
	if highlight then
		highlight:Hide()
	end

	if UnitInParty("target") or UnitInRaid("target") then
		for _, frame in ipairs(memberFrames) do
			if frame.unit and UnitIsUnit(frame.unit, "target") then
				frame.highlight:Show()

				GroupFrame.currentHighlight = frame.highlight
				break
			end
		end
	end
end

local function UpdateReadyStatus(member, status)
	local finishEarly = true

	for _, frame in ipairs(memberFrames) do
		if frame.unit then
			if UnitName(frame.unit) == member then
				if status == "Ready" then
					frame.readyIcon:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-ready")

					frame.isReady = 1
				else
					frame.readyIcon:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-notready")

					frame.isReady = 0
				end
			end

			if frame.isReady == -1 then
				finishEarly = false
			end
		end
	end

	if finishEarly then
		FinishReadyCheck()
	end
end

function GroupFrame_InitiateReadyCheck()
	local finishEarly = true
	local status
	for _, frame in ipairs(memberFrames) do
		frame.isReady = -1

		if frame.unit then
			status = frame.readyIcon
			status:Show()

			if not UnitIsConnected(frame.unit) then
				frame.isReady = 0

				status:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-notready")
			elseif UnitIsUnit(frame.unit, "player") then
				frame.isReady = 1

				status:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-ready")
			else
				status:SetTexture("Interface\\FrameXML\\LFT\\images\\readycheck-waiting")

				finishEarly = false
			end
		end
	end

	DoReadyCheck()

	if finishEarly then
		FinishReadyCheck()
	else
		GroupFrame.elapsed = 0
		GroupFrame:SetScript("OnUpdate", function()
			if this.elapsed >= 30 then
				FinishReadyCheck()
			end
			this.elapsed = this.elapsed + arg1
		end)
	end
end

function GroupFrame_OnEvent()
	if event == "PLAYER_ENTERING_WORLD" then
		local cluster

		this.growDirection = GROUP_UNIT_GROW_DIRECTION

		for i = 1, 8 do
			cluster = _G["GroupClusterFrame" .. i]

			table.insert(clusterFrames, cluster)

			for _, member in ipairs({ cluster:GetChildren() }) do
				table.insert(memberFrames, member)
			end

			cluster.header:SetText(GROUP .. " " .. i)

			if not cluster:IsUserPlaced() then
				cluster:ClearAllPoints()
				cluster:SetPoint("TOPLEFT", UIParent, 136 + ((i - 1) * GROUP_UNIT_WIDTH + ((i - 1) * 12)), -134)
			end
		end

		if not GroupPetsClusterFrame:IsUserPlaced() then
			GroupPetsClusterFrame:ClearAllPoints()
			GroupPetsClusterFrame:SetPoint("TOPLEFT", UIParent, 136, -192 - 5 * GROUP_UNIT_HEIGHT)
		end

		GroupFrame_Toggle()
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == "TW_RF" then
			local args = explode(arg2, ADDON_MSG_FIELD_DELIMITER)
			UpdateReadyStatus(args[1], args[2])
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		UpdateHighlight()
	elseif event == "RAID_TARGET_UPDATE" then
		GroupMemberFrame_UpdateRaidIcons()
	elseif event == "UNIT_NAME_UPDATE" then
		local frame = roster[arg1]

		UpdateMemberFrame(frame)
	elseif event == "PARTY_MEMBERS_CHANGED" then
		if GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0 and GROUP_REPLACE_PARTY == "1" then
			GroupFrame_Update()
		end
	else
		GroupFrame_UpdateLayout()
		GroupFrame_Update()
		GroupMemberFrame_UpdateRaidIcons()
	end
end

function GroupFrame_ResetPosition()
	for i, cluster in ipairs(clusterFrames) do
		cluster:ClearAllPoints()

		if GROUP_UNIT_GROW_DIRECTION == "1" then
			cluster:SetPoint("TOPLEFT", UIParent, 136 + ((i - 1) * GROUP_UNIT_WIDTH + ((i - 1))), -134)
		else
			if i < 5 then
				cluster:SetPoint("TOPLEFT", UIParent, 136, -134 - ((i - 1) * GROUP_UNIT_HEIGHT + ((i - 1) * 24)))
			else
				cluster:SetPoint("TOPLEFT", UIParent, 160 + 5 * GROUP_UNIT_WIDTH, -134 - ((i - 5) * GROUP_UNIT_HEIGHT + ((i - 5) * 24)))
			end
		end
	end

	GroupPetsClusterFrame:ClearAllPoints()
	if GROUP_UNIT_GROW_DIRECTION == "1" then
		GroupPetsClusterFrame:SetPoint("TOPLEFT", UIParent, 136, -180 - 5 * GROUP_UNIT_HEIGHT)
	else
		GroupPetsClusterFrame:SetPoint("TOPLEFT", UIParent, 136, -220 - 5 * GROUP_UNIT_HEIGHT)
	end
end

function GroupFrame_Toggle()
	if GROUP_ENABLED == "1" then
		GroupFrame:RegisterEvent("CHAT_MSG_ADDON")
		GroupFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		GroupFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		GroupFrame:RegisterEvent("RAID_ROSTER_UPDATE")
		GroupFrame:RegisterEvent("RAID_TARGET_UPDATE")
		GroupFrame:RegisterEvent("UNIT_NAME_UPDATE")
		GroupFrame:RegisterEvent("UNIT_PET")
		GroupFrame:Show()

		GroupFrame_Update()
		GroupMemberFrame_UpdateRaidIcons()

		RaidOptionsFrame_UpdatePartyFrames()
	else
		GroupFrame:UnregisterAllEvents()
		GroupFrame:Hide()

		for _, frame in ipairs(clusterFrames) do
			frame:Hide()
		end
		GroupPetsClusterFrame:Hide()

		RaidOptionsFrame_UpdatePartyFrames()
	end
end

function GroupFrame_ToggleMovement(state)
	state = state or (GroupFrame:IsMouseEnabled() and 0 or 1)

	GroupFrame:EnableMouse(state)

	for _, frame in ipairs(memberFrames) do
		frame:EnableMouse(1 - state)
	end

	table.insert(clusterFrames, GroupPetsClusterFrame)

	local width = GROUP_UNIT_GROW_DIRECTION == "1" and (GROUP_UNIT_WIDTH + 10) or (5 * GROUP_UNIT_WIDTH + 10)
	local height = GROUP_UNIT_GROW_DIRECTION == "1" and (5 * GROUP_UNIT_HEIGHT + 10) or (GROUP_UNIT_HEIGHT + 10)

	for _, frame in ipairs(clusterFrames) do
		if state == 1 then
			frame:SetUserPlaced(true)
			frame:SetBackdrop(GROUP_BORDER == "1" and clusterBackdrop or clusterBackdropBorderless)
			frame:SetBackdropColor(1, 1, 1, 0.3)
			frame:SetWidth(width)
			frame:SetHeight(height)
			frame:Show()
			frame:SetScript("OnUpdate", function()
				SnapMoveFrame(this)
			end)
		else
			frame:SetBackdropColor(1, 1, 1, 0)
			frame:SetScript("OnUpdate", nil)
		end
	end

	table.remove(clusterFrames, getn(clusterFrames))

	if state == 0 then
		GroupFrame_Update()
	end
end

function GroupFrame_Update()
	wipe(memberPets)

	GroupPetsClusterFrame:Hide()

	for _, frame in ipairs(clusterFrames) do
		frame:Hide()
	end

	for _, frame in ipairs(memberFrames) do
		frame:Hide()
		frame.unit = nil
	end

	for _, frame in ipairs(petFrames) do
		frame:Hide()
		frame.unit = nil
	end

	if GetNumRaidMembers() > 0 then
		local cluster

		GroupClusterFrame1Header:SetText(GROUP .. " 1")

		for i = 1, 8 do
			if RAID_SUBGROUP_LISTS and RAID_SUBGROUP_LISTS[i] then
				cluster = clusterFrames[i]

				for frameNumber, raidNumber in pairs(RAID_SUBGROUP_LISTS[i]) do
					cluster:Show()

					local frame = _G[cluster:GetName() .. "MemberFrame" .. frameNumber]

					frame.unit = "raid" .. raidNumber
					frame:Show()

					UpdateMemberFrame(frame)

					if UnitExists("raidpet" .. raidNumber) then
						tinsert(memberPets, "raidpet" .. raidNumber)
					end
				end
			end
		end
	elseif GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0 and  GROUP_REPLACE_PARTY == "1" then
		GroupClusterFrame1Header:SetText(PARTY)

		GroupClusterFrame1:Show()

		local members = GetNumPartyMembers()

		for i = 0, members do
			local frame = _G["GroupClusterFrame1MemberFrame" .. i + 1]
			frame:Show()

			if i == 0 then
				frame.unit = "player"

				if UnitExists("pet") then
					tinsert(memberPets, "pet")
				end
			else
				frame.unit = "party" .. i
			end

			UpdateMemberFrame(frame)

			if UnitExists("partypet" .. i) then
				tinsert(memberPets, "partypet" .. i)
			end
		end
	end

	if SHOW_PARTY_PETS == "1" then
		GroupFrame_UpdateMemberPets()
	end

	GroupFrame_UpdateLayout()
end

function GroupFrame_UpdateMemberPets()
	if sizeof(memberPets) > 0 then
		GroupPetsClusterFrame:Show()

		for i, pet in ipairs(memberPets) do
			local frame = _G["GroupPetsClusterFramePet" .. i]
			if not frame then
				frame = CreateFrame("Button", "GroupPetsClusterFramePet" .. i, GroupPetsClusterFrame, "GroupMemberFrameTemplate")
				frame:UnregisterAllEvents()
				frame:RegisterEvent("UNIT_HEALTH")
				frame:RegisterForClicks("LeftButtonUp")
				frame:SetScript("OnUpdate", nil)

				frame.powerbar:Hide()

				frame.healthbar:SetPoint("TOPLEFT", frame)
				frame.healthbar:SetPoint("BOTTOMRIGHT", frame)

				tinsert(petFrames, frame)
			end

			if i == 1 then
				frame:SetPoint("TOPLEFT", GroupPetsClusterFrame, 5, -5)
			else
				frame:SetPoint("TOPLEFT", _G["GroupPetsClusterFramePet" .. i - 1], "BOTTOMLEFT", 0, -1)
			end

			frame.unit = pet
			frame:Show()

			roster[pet] = frame

			UpdateMemberFrame(frame)
		end
	end
end

function GroupFrame_UpdateLayout()
	local backdrop = GROUP_BORDER == "1" and clusterBackdrop or nil
	local clusterWidth = GROUP_BORDER == "1" and GROUP_UNIT_WIDTH + 10 or GROUP_UNIT_WIDTH
	local clusterHeight = GROUP_BORDER == "1" and GROUP_UNIT_HEIGHT + 10 or GROUP_UNIT_WIDTH
	local headerOffset = GROUP_BORDER == "1" and 0 or 5
	local previous

	for i, cluster in ipairs(clusterFrames) do
		for k, member in ipairs({ cluster:GetChildren() }) do
			if previous then
				member:ClearAllPoints()
				if GROUP_UNIT_GROW_DIRECTION == "1" then
					member:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -1)
				else
					member:SetPoint("TOPLEFT", previous, "TOPRIGHT", 1, 0)
				end
			end

			member:SetWidth(GROUP_UNIT_WIDTH)
			member:SetHeight(GROUP_UNIT_HEIGHT)
			member.nameText:SetWidth(GROUP_UNIT_WIDTH - 18)

			if member:IsShown() then
				if GROUP_UNIT_GROW_DIRECTION == "1" then
					cluster:SetHeight(k * GROUP_UNIT_HEIGHT + 10 + k - 1)
					cluster:SetWidth(clusterWidth)
				else
					cluster:SetHeight(clusterHeight)
					cluster:SetWidth(k * GROUP_UNIT_WIDTH + 10 + k - 1)
				end
			end

			previous = member
		end

		cluster:SetBackdrop(backdrop)
		cluster:SetBackdropColor(1, 1, 1, 0)
		cluster:SetHitRectInsets(5, 5, -20, 5)
		cluster.header:ClearAllPoints()
		if GROUP_UNIT_GROW_DIRECTION == "1" then
			cluster.header:SetPoint("TOP", cluster, headerOffset, 14)
		else
			cluster.header:SetPoint("TOPLEFT", cluster, 10, 14)
		end

		if GROUP_HEADERS == "1" then
			cluster.header:Show()
		else
			cluster.header:Hide()
		end

		previous = nil
	end

	-- Pets cluster
	local activeFrames = 0
	for i, frame in ipairs(petFrames) do
		frame:SetWidth(GROUP_UNIT_WIDTH)
		frame:SetHeight(GROUP_UNIT_HEIGHT - 20)

		if frame:IsVisible() then
			activeFrames = activeFrames + 1
		end
	end

	GroupPetsClusterFrame:SetBackdrop(backdrop)
	GroupPetsClusterFrame:SetBackdropColor(1, 1, 1, 0)
	GroupPetsClusterFrame:SetWidth(clusterWidth)
	GroupPetsClusterFrame:SetHeight(activeFrames * (GROUP_UNIT_HEIGHT - 20) + activeFrames - 1 + 10)

	if GROUP_HEADERS == "1" then
		GroupPetsClusterFrameHeader:Show()
	else
		GroupPetsClusterFrameHeader:Hide()
	end

	GroupPetsClusterFrameHeader:ClearAllPoints()
	if GROUP_UNIT_GROW_DIRECTION == "1" then
		GroupPetsClusterFrameHeader:SetPoint("TOP", GroupPetsClusterFrame, headerOffset, 14)
	else
		GroupPetsClusterFrameHeader:SetPoint("TOPLEFT", GroupPetsClusterFrame, 10, 14)
	end

	if GROUP_UNIT_GROW_DIRECTION ~= GroupFrame.growDirection then
		GroupFrame.growDirection = GROUP_UNIT_GROW_DIRECTION

		GroupFrame_ResetPosition()
	end

	if GroupFrame:IsMouseEnabled() then
		GroupFrame_ToggleMovement(1)
	end
end

function GroupMemberFrame_UpdateRaidIcons()
	local index, icon
	for _, frame in ipairs(memberFrames) do
		icon = frame.raidIcon

		icon:Hide()
		if frame:IsShown() and frame.unit and UnitExists(frame.unit) then
			index = GetRaidTargetIndex(frame.unit)
			if index then
				icon:Show()

				SetRaidTargetIconTexture(icon, index)
			end
		end
	end
end

function GroupMemberFrame_OnLoad()
	this:RegisterEvent("UNIT_AURA")
	this:RegisterEvent("UNIT_HEALTH")
	this:RegisterEvent("UNIT_DISPLAYPOWER")
	this:RegisterEvent("UNIT_ENERGY")
	this:RegisterEvent("UNIT_MAXENERGY")
	this:RegisterEvent("UNIT_MANA")
	this:RegisterEvent("UNIT_MAXMANA")
	this:RegisterEvent("UNIT_RAGE")
	this:RegisterEvent("UNIT_MAXRAGE")

	this:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	this.auraButtons = {}
	for i = 1, 8 do
		this.auraButtons[i] = _G[this:GetName() .. "AuraButton" .. i]
	end

	this.debuffHighlight = _G[this:GetName() .. "DebuffHighlight"]
	this.debuffIndicator = _G[this:GetName() .. "DebuffIndicator"]
	this.debuffIndicatorTexture = _G[this:GetName() .. "DebuffIndicatorTexture"]
	this.highlight = _G[this:GetName() .. "Highlight"]
	this.healthbar = _G[this:GetName() .. "HealthBar"]
	this.powerbar = _G[this:GetName() .. "PowerBar"]
	this.nameText = _G[this:GetName() .. "Name"]
	this.statusText = _G[this:GetName() .. "Status"]
	this.raidIcon = _G[this:GetName() .. "RaidIcon"]
	this.readyIcon = _G[this:GetName() .. "ReadyCheckStatus"]

	this.isReady = -1
end

function GroupMemberFrame_OnEvent()
	if this.unit and arg1 == this.unit then
		if event == "UNIT_AURA" then
			UpdateMemberAuras(this)
		elseif event == "UNIT_HEALTH" then
			UpdateMemberHealth(this)
		elseif event == "UNIT_DISPLAYPOWER" then
			UpdateMemberDisplayPower(this)
		else
			UpdateMemberPower(this)
		end
	end
end

function GroupMemberFrame_OnClick()
	local unit = this.unit
	if arg1 == "LeftButton" then
		if SpellIsTargeting() then
			SpellTargetUnit(unit)
		elseif CursorHasItem() then
			DropItemOnUnit(unit)
		else
			TargetUnit(unit)
		end
	elseif arg1 == "RightButton" and not UnitIsUnit(unit, "player") then
		FriendsDropDown.displayMode = "MENU"
		FriendsDropDown.initialize = function()
			UnitPopup_ShowMenu(_G[UIDROPDOWNMENU_OPEN_MENU], "PARTY", unit, UnitName(unit))
		end
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
	end
end

function GroupMemberFrame_OnEnter()
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:SetUnit(this.unit)
	GameTooltip:Show()
end

function GroupMemberFrame_OnUpdate()
	local unit = this.unit
	if not unit then return end

	local r1, g1, b1 = this.healthbar:GetStatusBarColor()
	local r2, g2, b2 = this.powerbar:GetStatusBarColor()
	if CheckInteractDistance(unit, 5) then
		this.healthbar:SetStatusBarColor(r1, g1, b1, 1)
		this.powerbar:SetStatusBarColor(r2, g2, b2, 1)
	else
		this.healthbar:SetStatusBarColor(r1, g1, b1, 0.4)
		this.powerbar:SetStatusBarColor(r2, g2, b2, 0.4)
	end
end

function GroupMemberFrameAuraButton_OnLoad()
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	this.texture = _G[this:GetName() .. "Texture"]
end

function GroupMemberFrameAuraButton_OnClick()
	this:GetParent():Click(arg1)
end

function GroupMemberFrameAuraButton_OnEnter()
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)

	if this.type == "buff" then
		GameTooltip:SetUnitBuff(this:GetParent().unit, this:GetID(), 1)
	else
		GameTooltip:SetUnitDebuff(this:GetParent().unit, this:GetID(), 1)
	end
	GameTooltip:Show()
end

function GroupClusterDropDown_Init()
	local info = UIDropDownMenu_CreateInfo()

	info.text = GROUP
	info.isTitle = 1
	info.notCheckable = true
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = true
	info.text = TOGGLE_MOVEMENT
	info.func = GroupFrame_ToggleMovement
	info.arg1 = GroupFrame:IsMouseEnabled() and 0 or 1
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = true
	info.text = UNIT_POPUP_MOVE_RESET
	info.func = GroupFrame_ResetPosition
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = true
	info.text = READY_CHECK
	info.func = GroupFrame_InitiateReadyCheck
	if not UnitInRaid("player") or not IsRaidLeader() then
		info.disabled = true
	end
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = true
	info.text = CANCEL
	info.func = CloseDropDownMenus
	UIDropDownMenu_AddButton(info)
end