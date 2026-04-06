local ADDON_PREFIX = "TW_ARENA"
local ADDON_CHANNEL = "GUILD"

local triggerQueue = "ARENA_BATTLE_REGISTRATION"
local triggerRegistrar = "ARENA_TEAM_REGISTRATION"

local arenas = {
	[1] = { type = "2v2", captain = false, },
	[2] = { type = "3v3", captain = false, },
	[3] = { type = "5v5", captain = false, },
}

local pendingInvite = {
	arenaType = "",
	invitee = "",
	teamID = 0,
}

local function Send(message)
	SendAddonMessage(ADDON_PREFIX, message, ADDON_CHANNEL)
end

local function InitArenaTypeDropdown()
	local info = UIDropDownMenu_CreateInfo()
	for _, item in ipairs(arenas) do
		info.text = item.type
		info.checked = UIDropDownMenu_GetText(ArenaRegistrarFrameDropDown) == item.type
		info.func = ArenaRegistrarFrameDropDown_OnClick
		UIDropDownMenu_AddButton(info)
	end
end

local function HandleInvite(accepted)
	Send(accepted and "C2S_ACCEPT_INVITE" or "C2S_DECLINE_INVITE" .. ADDON_MSG_FIELD_DELIMITER .. pendingInvite.teamID .. ADDON_MSG_FIELD_DELIMITER .. pendingInvite.arenaType)
end

local function DisbandTeam()
	Send("S2C_DISBAND" .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type)
end

local function InvitePlayer(player)
	Send("S2C_INVITE" .. ADDON_MSG_FIELD_DELIMITER .. player .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type)
end

local function KickPlayer()
	Send("S2C_KICK" .. ADDON_MSG_FIELD_DELIMITER .. ArenaFrame.currentMember .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type)
end

local function LeaveTeam()
	Send("S2C_LEAVE_TEAM" .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type)
end

local function UpdateArenaPoints(points)
	ArenaFramePointsText:SetText(points or 0)
end

local function UpdateArenaTeams(data)
	local details = {}
	local teams
	if not strfind(data, "No teams found") then
		teams = explode(data, ADDON_MSG_SUBFIELD_DELIMITER)
	end

	for i = 1, getn(arenas) do
		local teamFrame = _G["ArenaFrameTeam" .. i]
		local teamFrameName = teamFrame:GetName()

		teamFrame:SetAlpha(0.4)
		teamFrame.active = false

		_G[teamFrameName .. "Text"]:Show()
		_G[teamFrameName .. "Details"]:Hide()

		if teams then
			explode(teams[i], ADDON_MSG_ARRAY_DELIMITER, details)
			if details[2] ~= "None" and details[3] ~= "None" then
				arenas[i].captain = details[3] == "Captain" and true or false

				teamFrame:SetAlpha(1)
				teamFrame.active = true

				_G[teamFrameName .. "Text"]:Hide()

				local detailsFrame = _G[teamFrameName .. "Details"]
				local detailsFrameName = detailsFrame:GetName()
				local detailsDisbandButton = _G[detailsFrameName .. "DisbandButton"]
				local detailsTeamName = _G[detailsFrameName .. "Name"]

				local rating = tonumber(details[4]) or 0
				local seasonRank = tonumber(details[5]) or 0
				local seasonWins = tonumber(details[6]) or 0
				local seasonGames = tonumber(details[7]) or 0
				local weekRank = 0
				local weekWins = tonumber(details[8]) or 0
				local weekGames = tonumber(details[9]) or 0

				detailsFrame:Show()
				detailsTeamName:SetText(details[2])

				_G[detailsFrameName .. "Rating"]:SetText(rating)
				_G[detailsFrameName .. "WeekRank"]:SetText(weekRank)
				_G[detailsFrameName .. "WeekGames"]:SetText(weekGames)
				_G[detailsFrameName .. "WeekWins"]:SetText(weekWins)
				_G[detailsFrameName .. "WeekLoss"]:SetText(weekGames - weekWins)
				_G[detailsFrameName .. "SeasonRank"]:SetText(seasonRank)
				_G[detailsFrameName .. "SeasonGames"]:SetText(seasonGames)
				_G[detailsFrameName .. "SeasonWins"]:SetText(seasonWins)
				_G[detailsFrameName .. "SeasonLoss"]:SetText(seasonGames - seasonWins)

				if arenas[i].captain then
					detailsDisbandButton:Show()
					detailsTeamName:SetPoint("TOPLEFT", detailsFrame, 38, -16)
				else
					detailsDisbandButton:Hide()
					detailsTeamName:SetPoint("TOPLEFT", detailsFrame, 18, -16)
				end
			end
		end
	end
end

local function UpdateArenaTeamRoster(data)
	for _, child in pairs({ ArenaFrameDetailsFrame:GetChildren() }) do
		if child:GetFrameType() == "Frame" then
			child:Hide()
		end
	end

	local details = {}
	local isCaptain = arenas[ArenaFrame.currentTeam].captain
	local members = explode(data, ADDON_MSG_SUBFIELD_DELIMITER)
	for i, member in pairs(members) do
		local frame = _G["ArenaFrameDetailsFrameMember" .. i]
		local frameName = frame:GetName()
		frame:Show()

		local kickButton = _G[frameName .. "KickButton"]
		local captainIcon = _G[frameName .. "CaptainIcon"]

		explode(member, ADDON_MSG_ARRAY_DELIMITER, details)
		local name = details[1]
		local isCaptainRole = details[2] == "Captain"

		_G[frameName .. "Name"]:SetText(name)

		if isCaptain and not isCaptainRole then
			kickButton.member = name
			kickButton:Show()
		else
			kickButton:Hide()
		end

		if isCaptainRole then
			captainIcon:Show()
		else
			captainIcon:Hide()
		end
	end

	if isCaptain then
		ArenaFrameDetailsFrameButton:SetID(1)
		ArenaFrameDetailsFrameButton:SetText(ARENA_TEAM_INVITE)
	else
		ArenaFrameDetailsFrameButton:SetID(0)
		ArenaFrameDetailsFrameButton:SetText(ARENA_TEAM_LEAVE)
	end
end

function ArenaFrame_OnLoad()
	UpdateArenaPoints(0)
	this:RegisterEvent("CHAT_MSG_ADDON")
	this:RegisterEvent("GOSSIP_SHOW")
	this:RegisterEvent("GOSSIP_CLOSED")
end

function ArenaFrame_OnEvent()
	if event == "CHAT_MSG_ADDON" then
		if arg1 ~= ADDON_PREFIX then
			return
		end

		local args = explode(arg2, ADDON_MSG_FIELD_DELIMITER)

		if args[1] == "S2C_ERROR" and args[2] then
			UIErrorsFrame:AddMessage(args[2], 1.0, 0.1, 0.1, 1.0)

		elseif args[1] == "S2C_CREATE_SUCCESS" then
			ArenaRegistrarFrame:Hide()

			if ArenaFrame:IsShown() then
				ArenaFrame_OnShow()
			end

			print(GAME_YELLOW .. ARENA_TEAM_CREATED)

		elseif args[1] == "S2C_DISBAND_SUCCESS" then
			if ArenaFrame:IsShown() then
				Send("S2C_INFO")
				ArenaFrameDetailsFrame:Hide()
			end

			print(GAME_YELLOW .. ARENA_TEAM_DISBANDED)

		elseif args[1] == "S2C_INFO" and args[2] ~= UnitName("target") then
			UpdateArenaTeams(args[2])

		elseif args[1] == "S2C_INVITE_ACCEPTED" then
			if ArenaFrame:IsShown() then
				Send("S2C_INFO")
			end

			if ArenaFrameDetailsFrame:IsShown() then
				Send("S2C_ROSTER" .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type)
			end

			if args[4] == pendingInvite.invitee then
				print(format(GAME_YELLOW .. ARENA_TEAM_JOINED, args[2]))
			else
				print(format(GAME_YELLOW .. ARENA_TEAM_MEMBER_JOINED, args[2]))
			end

		elseif args[1] == "S2C_INVITE_DECLINED" then
			if args[4] ~= pendingInvite.invitee then
				print(format(GAME_YELLOW .. ARENA_TEAM_INVITE_DECLINED, args[2]))
			end

		elseif args[1] == "S2C_INVITED" then
			pendingInvite.arenaType = args[3]
			pendingInvite.invitee = args[4]
			pendingInvite.teamID = args[5]

			StaticPopupDialogs["ARENA_POPUP_INVITE_OFFER"].text = format(ARENA_TEAM_INVITED, args[4], args[3], args[2])
			StaticPopup_Show("ARENA_POPUP_INVITE_OFFER")

		elseif args[1] == "S2C_INVITE_SUCCESS" then
			print(format(GAME_YELLOW .. ARENA_TEAM_INVITE_SENT, gsub(strlower(args[2]), "^%l", strupper)))

		elseif args[1] == "S2C_KICKED" then
			if ArenaFrame:IsShown() then
				Send("S2C_INFO")

				ArenaFrameDetailsFrame:Hide()
			end

			print(format(GAME_YELLOW .. ARENA_TEAM_KICKED, args[2]))

		elseif args[1] == "S2C_KICK_SUCCESS" then
			if ArenaFrameDetailsFrame:IsShown() then
				Send("S2C_ROSTER" .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type)
			end

			print(format(GAME_YELLOW .. ARENA_TEAM_MEMBER_KICKED, args[2]))

		elseif args[1] == "S2C_LEAVE_TEAM_SUCCESS" then
			if ArenaFrame:IsShown() then
				Send("S2C_INFO")
			end

			ArenaFrameDetailsFrame:Hide()

			print(format(GAME_YELLOW .. ARENA_TEAM_LEFT, args[3]))

		elseif args[1] == "S2C_MEMBER_LEFT" then
			if ArenaFrameDetailsFrame:IsShown() then
				Send("S2C_ROSTER" .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type)
			end

			print(format(GAME_YELLOW .. ARENA_TEAM_MEMBER_LEFT, args[2], args[4]))

		elseif args[1] == "S2C_ARENAPOINTS" then
			UpdateArenaPoints(args[2])

		elseif args[1] == "S2C_QUEUE_SUCCESS" then
			UIErrorsFrame:AddMessage(format(GAME_YELLOW .. ARENA_QUEUE_JOINED, args[2]))

		elseif args[1] == "S2C_ROSTER" then
			UpdateArenaTeamRoster(args[4])

		elseif args[1] == "S2C_SCOREBOARD" then
			WorldStateScoreFrame.arenaData = arg2
		end

	elseif event == "GOSSIP_SHOW" then
		local gossip = GetGossipText()
		if not ((gossip == triggerQueue or gossip == triggerRegistrar) and UnitName("npc")) then
			return
		end

		GossipFrame:SetAlpha(0)
		GossipFrame:EnableMouse(nil)

		if gossip == triggerQueue then
			ArenaQueueFrame:Show()
		else
			ArenaRegistrarFrame:Show()
		end

	elseif event == "GOSSIP_CLOSED" then
		GossipFrame:SetAlpha(1)
		GossipFrame:EnableMouse(1)
		ArenaQueueFrame:Hide()
		ArenaRegistrarFrame:Hide()
	end
end

function ArenaFrame_OnShow()
	Send("C2S_ARENAPOINTS")
	Send("S2C_INFO")

	PlaySound("igCharacterInfoOpen")
end

function ArenaTeam_OnClick()
	local id = this:GetID()
	if this.active then
		if ArenaFrame.currentTeam ~= id then
			ArenaFrame.currentTeam = id
			ArenaFrameDetailsFrame:Show()
			Send("S2C_ROSTER" .. ADDON_MSG_FIELD_DELIMITER .. arenas[id].type)
			PlaySound("igCharacterInfoTab")
		else
			ArenaFrame.currentTeam = nil
			ArenaFrameDetailsFrame:Hide()
		end
	end
end

function ArenaFrameDetailsDisbandButton_OnClick()
	ArenaFrame.currentTeam = this:GetParent():GetParent():GetID()

	StaticPopup_Show("ARENA_POPUP_DISBAND")
end

function ArenaMemberFrameKickButton_OnClick()
	ArenaFrame.currentMember = this.member

	StaticPopup_Show("ARENA_POPUP_KICK_CONFIRM", this.member)
end

function ArenaQueueButton_OnClick()
	local id = this:GetID()
	if id == 0 then
		ArenaQueueFrameJoinButton:Enable()
	else
		ArenaQueueFrameJoinButton:Disable()
	end

	ArenaQueueFrame.selection = id

	for i in pairs(arenas) do
		_G["ArenaQueueFrameButton" .. i]:UnlockHighlight()
	end
	ArenaQueueFrameSkirmishButton:UnlockHighlight()

	this:LockHighlight()
end

function ArenaQueueFrame_OnLoad()
	for i, arena in pairs(arenas) do
		_G["ArenaQueueFrameButton" .. i]:SetText(ARENA_QUEUE_RATED .. " " .. arena.type)
	end

	ArenaQueueFrameButton1:Click()
end

function ArenaRegistrarFrameDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, InitArenaTypeDropdown)
	UIDropDownMenu_SetSelectedValue(ArenaRegistrarFrameDropDown, 1)
	UIDropDownMenu_SetText("2v2", ArenaRegistrarFrameDropDown)
end

function ArenaRegistrarFrameDropDown_OnClick()
	local text = _G[this:GetName() .. "NormalText"]:GetText()
	UIDropDownMenu_SetSelectedValue(ArenaRegistrarFrameDropDown, this:GetID())
	UIDropDownMenu_SetText(text, ArenaRegistrarFrameDropDown)
end

function ArenaRegistrarFrameConfirmButton_OnClick()
	local name = ArenaRegistrarFrameEditBox:GetText()
	local selectedValue = UIDropDownMenu_GetSelectedValue(ArenaRegistrarFrameDropDown)
	if name ~= "" and selectedValue then
		Send("S2C_CREATE" .. ADDON_MSG_FIELD_DELIMITER .. arenas[selectedValue].type .. ADDON_MSG_FIELD_DELIMITER .. name)
	end
end

function JoinArenaQueue(selection)
	local selection = tonumber(selection) or ArenaQueueFrame.selection
	if not selection then
		return
	end
	if selection == 0 then
		SendAddonMessage("TW_BGQueue", "Arena", ADDON_CHANNEL)
	elseif arenas[selection] and arenas[selection].type then
		Send("S2C_QUEUE" .. ADDON_MSG_FIELD_DELIMITER .. arenas[selection].type)
	end
	CloseDropDownMenus()
end

function LeaveArenaQueue()
	Send("S2C_LEAVE_QUEUE")
end

function RequestArenaScoreInfo()
	Send("C2S_SCOREBOARD")
end

StaticPopupDialogs["ARENA_POPUP_DISBAND"] = {
	text = ARENA_TEAM_DISBAND_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		DisbandTeam()
	end,
	hideOnEscape = true,
}

StaticPopupDialogs["ARENA_POPUP_INVITE_PLAYER"] = {
	text = ARENA_TEAM_INVITE_INFO,
	button1 = CONFIRM,
	button2 = CANCEL,
	OnAccept = function()
		local editbox = _G[this:GetParent():GetName() .. "EditBox"]
		InvitePlayer(editbox:GetText())
		editbox:SetText("")
	end,
	EditBoxOnEnterPressed = function()
		InvitePlayer(this:GetText())
		this:SetText("")
		this:GetParent():Hide()
	end,
	hideOnEscape = true,
	hasEditBox = true,
}

StaticPopupDialogs["ARENA_POPUP_INVITE_OFFER"] = {
	text = "",
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "LEVELUPSOUND",
	OnAccept = function()
		HandleInvite(true)
	end,
	OnCancel = function()
		HandleInvite(false)
	end,
}

StaticPopupDialogs["ARENA_POPUP_KICK_CONFIRM"] = {
	text = ARENA_TEAM_KICK_CONFIRM,
	button1 = CONFIRM,
	button2 = CANCEL,
	OnAccept = function()
		KickPlayer()
	end,
	hideOnEscape = true,
}

StaticPopupDialogs["ARENA_POPUP_LEAVE_CONFIRM"] = {
	text = ARENA_TEAM_LEAVE_CONFIRM,
	button1 = CONFIRM,
	button2 = CANCEL,
	OnAccept = function()
		LeaveTeam()
	end,
	hideOnEscape = true,
}