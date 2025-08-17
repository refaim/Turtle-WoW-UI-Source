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
    local messageType = accepted and "C2S_ACCEPT_INVITE" or "C2S_DECLINE_INVITE"

    SendAddonMessage(ADDON_PREFIX, messageType .. ADDON_MSG_FIELD_DELIMITER .. pendingInvite.teamID .. ADDON_MSG_FIELD_DELIMITER .. pendingInvite.arenaType, ADDON_CHANNEL)
end

local function DisbandTeam()
    SendAddonMessage(ADDON_PREFIX, "S2C_DISBAND" .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type, ADDON_CHANNEL)
end

local function InvitePlayer(player)
    SendAddonMessage(ADDON_PREFIX, "S2C_INVITE" .. ADDON_MSG_FIELD_DELIMITER .. player .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type, ADDON_CHANNEL)
end

local function KickPlayer()
    SendAddonMessage(ADDON_PREFIX, "S2C_KICK" .. ADDON_MSG_FIELD_DELIMITER .. ArenaFrame.currentMember .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type, ADDON_CHANNEL)
end

local function LeaveTeam()
    SendAddonMessage(ADDON_PREFIX, "S2C_LEAVE_TEAM" .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type, ADDON_CHANNEL)
end

local function UpdateArenaPoints(data)
    local points = data or 0

    ArenaFrameArenaPoints:SetText(format(ARENA_ARENA_POINTS, points))
end

local function UpdateArenaTeams(data)
    local details = {}
    local teams
    if data ~= "No teams found" then
        teams = explode(data, ADDON_MSG_SUBFIELD_DELIMITER)
    end

    for i = 1, table.getn(arenas) do
        local teamFrame = getglobal("ArenaFrameTeam" .. i)
        local teamFrameName = teamFrame:GetName()

        teamFrame:SetAlpha(0.4)
        teamFrame.active = false

        getglobal(teamFrameName .. "Text"):Show()
        getglobal(teamFrameName .. "Details"):Hide()

        if teams then
            explode(teams[i], ADDON_MSG_ARRAY_DELIMITER, details)
            if details[2] ~= "None" and details[3] ~= "None" then
                arenas[i].captain = details[3] == "Captain" and true or false

                teamFrame:SetAlpha(1)
                teamFrame.active = true

                getglobal(teamFrameName .. "Text"):Hide()

                local detailsFrame = getglobal(teamFrameName .. "Details")
                local detailsFrameName = detailsFrame:GetName()
                local detailsDisbandButton = getglobal(detailsFrameName .. "DisbandButton")
                local detailsTeamName = getglobal(detailsFrameName .. "Name")

                local rating = tonumber(details[4]) or 0
                local seasonRank = tonumber(details[5]) or 0
                local seasonWins = tonumber(details[6]) or 0
                local seasonGames = tonumber(details[7]) or 0
                local weekRank = 0
                local weekWins = tonumber(details[8]) or 0
                local weekGames = tonumber(details[9]) or 0

                detailsFrame:Show()
                detailsTeamName:SetText(details[2])

                getglobal(detailsFrameName .. "Rating"):SetText(rating)
                getglobal(detailsFrameName .. "WeekRank"):SetText(weekRank)
                getglobal(detailsFrameName .. "WeekGames"):SetText(weekGames)
                getglobal(detailsFrameName .. "WeekWins"):SetText(weekWins)
                getglobal(detailsFrameName .. "WeekLoss"):SetText(weekGames - weekWins)
                getglobal(detailsFrameName .. "SeasonRank"):SetText(seasonRank)
                getglobal(detailsFrameName .. "SeasonGames"):SetText(seasonGames)
                getglobal(detailsFrameName .. "SeasonWins"):SetText(seasonWins)
                getglobal(detailsFrameName .. "SeasonLoss"):SetText(seasonGames - seasonWins)

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
    for _, child in { ArenaFrameDetailsFrame:GetChildren() } do
        if child:GetFrameType() == "Frame" then
            child:Hide()
        end
    end

    local details = {}
    local isCaptain = arenas[ArenaFrame.currentTeam].captain
    local members = explode(data, ADDON_MSG_SUBFIELD_DELIMITER)
    for i, member in members do
        local frame = getglobal("ArenaFrameDetailsFrameMember" .. i)
        local frameName = frame:GetName()
        frame:Show()

        local kickButton = getglobal(frameName .. "KickButton")
        local captainIcon = getglobal(frameName .. "CaptainIcon")

        explode(member, ADDON_MSG_ARRAY_DELIMITER, details)
        local name = details[1]
        local isCaptainRole = details[2] == "Captain"

        getglobal(frameName .. "Name"):SetText(name)

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

local listener = CreateFrame("Frame")
listener:RegisterEvent("CHAT_MSG_ADDON")
listener:RegisterEvent("GOSSIP_SHOW")
listener:RegisterEvent("GOSSIP_CLOSED")
listener:SetScript("OnEvent", function()
    if event == "CHAT_MSG_ADDON" then
        if arg1 == ADDON_PREFIX then
            local args = explode(arg2, ADDON_MSG_FIELD_DELIMITER)

            if args[1] == "S2C_ERROR" and args[2] then
                print(GAME_YELLOW .. args[2])
            elseif args[1] == "S2C_CREATE_SUCCESS" then
                ArenaRegistrarFrame:Hide()

                if ArenaFrame:IsShown() then
                    ArenaFrame_OnShow()
                end

                print(GAME_YELLOW .. ARENA_TEAM_CREATED)
            elseif args[1] == "S2C_DISBAND_SUCCESS" then
                if ArenaFrame:IsShown() then
                    SendAddonMessage(ADDON_PREFIX, "S2C_INFO", ADDON_CHANNEL)

                    ArenaFrameDetailsFrame:Hide()
                end

                print(GAME_YELLOW .. ARENA_TEAM_DISBANDED)
            elseif args[1] == "S2C_INFO" then
                UpdateArenaTeams(args[2])
            elseif args[1] == "S2C_INVITE_ACCEPTED" then
                if ArenaFrame:IsShown() then
                    SendAddonMessage(ADDON_PREFIX, "S2C_INFO", ADDON_CHANNEL)
                end

                if ArenaFrameDetailsFrame:IsShown() then
                    SendAddonMessage(ADDON_PREFIX, "S2C_ROSTER" .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type, ADDON_CHANNEL)
                end

                if args[4] == pendingInvite.invitee then
                    print(string.format(GAME_YELLOW .. ARENA_TEAM_JOINED, args[2]))
                else
                    print(string.format(GAME_YELLOW .. ARENA_TEAM_MEMBER_JOINED, args[2]))
                end
            elseif args[1] == "S2C_INVITE_DECLINED" then
                if args[4] ~= pendingInvite.invitee then
                    print(string.format(GAME_YELLOW .. ARENA_TEAM_INVITE_DECLINED, args[2]))
                end
            elseif args[1] == "S2C_INVITED" then
                pendingInvite.arenaType = args[3]
                pendingInvite.invitee = args[4]
                pendingInvite.teamID = args[5]

                StaticPopupDialogs["ARENA_POPUP_INVITE_OFFER"].text = string.format(TEXT(ARENA_TEAM_INVITED), args[4], args[3], args[2])
                StaticPopup_Show("ARENA_POPUP_INVITE_OFFER")
            elseif args[1] == "S2C_INVITE_SUCCESS" then
                print(format(GAME_YELLOW .. ARENA_TEAM_INVITE_SENT, gsub(string.lower(args[2]), "^%l", string.upper)))
            elseif args[1] == "S2C_KICKED" then
                if ArenaFrame:IsShown() then
                    SendAddonMessage(ADDON_PREFIX, "S2C_INFO", ADDON_CHANNEL)

                    ArenaFrameDetailsFrame:Hide()
                end

                print(string.format(GAME_YELLOW .. ARENA_TEAM_KICKED, args[2]))
            elseif args[1] == "S2C_KICK_SUCCESS" then
                if ArenaFrameDetailsFrame:IsShown() then
                    SendAddonMessage(ADDON_PREFIX, "S2C_ROSTER" .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type, ADDON_CHANNEL)
                end

                print(string.format(GAME_YELLOW .. ARENA_TEAM_MEMBER_KICKED, args[2]))
            elseif args[1] == "S2C_LEAVE_TEAM_SUCCESS" then
                if ArenaFrame:IsShown() then
                    SendAddonMessage(ADDON_PREFIX, "S2C_INFO", ADDON_CHANNEL)
                end

                ArenaFrameDetailsFrame:Hide()

                print(string.format(GAME_YELLOW .. ARENA_TEAM_LEFT, args[3]))
            elseif args[1] == "S2C_MEMBER_LEFT" then
                if ArenaFrameDetailsFrame:IsShown() then
                    SendAddonMessage(ADDON_PREFIX, "S2C_ROSTER" .. ADDON_MSG_FIELD_DELIMITER .. arenas[ArenaFrame.currentTeam].type, ADDON_CHANNEL)
                end

                print(string.format(GAME_YELLOW .. ARENA_TEAM_MEMBER_LEFT, args[2], args[4]))
            elseif args[1] == "S2C_ARENAPOINTS" then
                UpdateArenaPoints(args[2])
            elseif args[1] == "S2C_QUEUE_SUCCESS" then
                print(string.format(GAME_YELLOW .. ARENA_QUEUE_JOINED, args[2]))
            elseif args[1] == "S2C_ROSTER" then
                UpdateArenaTeamRoster(args[4])
            elseif args[1] == "S2C_SCOREBOARD" then
                WorldStateScoreFrame.arenaData = arg2
            end
        end
    elseif event == "GOSSIP_SHOW" then
        local gossip = GetGossipText()
        if gossip == triggerQueue or gossip == triggerRegistrar then
            GossipFrame:SetAlpha(0)
            GossipFrame:EnableMouse(nil)
            local centerFrame = (GetCenterFrame())
            HideUIPanel(centerFrame)
            ShowUIPanel(centerFrame)

            if gossip == triggerQueue then
                ArenaQueueFrame:Show()
            else
                ArenaRegistrarFrame:Show()
            end
		end
    elseif event == "GOSSIP_CLOSED" then
		GossipFrame:SetAlpha(1)
		GossipFrame:EnableMouse(1)
        ArenaQueueFrame:Hide()
		ArenaRegistrarFrame:Hide()
    end
end)

function ArenaFrame_OnLoad()
    UpdateArenaPoints(0)
end

function ArenaFrame_OnShow()
    SendAddonMessage(ADDON_PREFIX, "C2S_ARENAPOINTS", ADDON_CHANNEL)
    SendAddonMessage(ADDON_PREFIX, "S2C_INFO", ADDON_CHANNEL)

    PlaySound("igCharacterInfoOpen")
end

function ArenaTeam_OnClick()
    if this.active and ArenaFrame.currentTeam ~= this:GetID() then
        ArenaFrame.currentTeam = this:GetID()

        ArenaFrameDetailsFrame:Show()

        SendAddonMessage(ADDON_PREFIX, "S2C_ROSTER" .. ADDON_MSG_FIELD_DELIMITER .. arenas[this:GetID()].type, ADDON_CHANNEL)

        PlaySound("igCharacterInfoTab")
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

    for i in arenas do
        getglobal("ArenaQueueFrameButton" .. i):UnlockHighlight()
    end
    ArenaQueueFrameSkirmishButton:UnlockHighlight()

    this:LockHighlight()
end

function ArenaQueueFrame_OnLoad()
    for i, arena in arenas do
        getglobal("ArenaQueueFrameButton" .. i):SetText(ARENA_QUEUE_RATED .. " " .. arena.type)
    end

    ArenaQueueFrameButton1:Click()
end

function ArenaRegistrarFrameDropDown_OnLoad()
    UIDropDownMenu_Initialize(this, InitArenaTypeDropdown)
    UIDropDownMenu_SetSelectedValue(ArenaRegistrarFrameDropDown, 1)
    UIDropDownMenu_SetText("2v2", ArenaRegistrarFrameDropDown)
end

function ArenaRegistrarFrameDropDown_OnClick()
    local text = getglobal(this:GetName() .. "NormalText"):GetText()
    UIDropDownMenu_SetSelectedValue(ArenaRegistrarFrameDropDown, this:GetID())
    UIDropDownMenu_SetText(text, ArenaRegistrarFrameDropDown)
end

function ArenaRegistrarFrameConfirmButton_OnClick()
    local name = ArenaRegistrarFrameEditBox:GetText()
    local selectedValue = UIDropDownMenu_GetSelectedValue(ArenaRegistrarFrameDropDown)
    if name ~= "" and selectedValue then
        SendAddonMessage(ADDON_PREFIX, "S2C_CREATE" .. ADDON_MSG_FIELD_DELIMITER .. arenas[selectedValue].type .. ADDON_MSG_FIELD_DELIMITER .. name, ADDON_CHANNEL)
    end
end

function JoinArenaQueue(asGroup)
    local selection = ArenaQueueFrame.selection
    if selection then
        if selection == 0 then
            SendAddonMessage("TW_BGQueue", "Arena", ADDON_CHANNEL)
        else
            SendAddonMessage(ADDON_PREFIX, "S2C_QUEUE" .. ADDON_MSG_FIELD_DELIMITER .. arenas[selection].type, ADDON_CHANNEL)
        end
    end
end

function LeaveArenaQueue()
    SendAddonMessage(ADDON_PREFIX, "S2C_LEAVE_QUEUE", ADDON_CHANNEL)
end

function RequestArenaScoreInfo()
    SendAddonMessage(ADDON_PREFIX, "C2S_SCOREBOARD", ADDON_CHANNEL)
end

StaticPopupDialogs["ARENA_POPUP_DISBAND"] = {
    text = TEXT(ARENA_TEAM_DISBAND_CONFIRM),
    button1 = TEXT(YES),
    button2 = TEXT(NO),
    OnAccept = function()
        DisbandTeam()
    end,
    timeout = 0,
    hideOnEscape = true,
}

StaticPopupDialogs["ARENA_POPUP_INVITE_PLAYER"] = {
    text = TEXT(ARENA_TEAM_INVITE_INFO),
    button1 = TEXT(CONFIRM),
    button2 = TEXT(CANCEL),
    OnAccept = function()
        local editbox = getglobal(this:GetParent():GetName() .. "EditBox")
        InvitePlayer(editbox:GetText())
        editbox:SetText("")
    end,
    EditBoxOnEnterPressed = function()
        InvitePlayer(this:GetText())
        this:SetText("")
        this:GetParent():Hide()
    end,
    timeout = 0,
    hideOnEscape = true,
    hasEditBox = true,
}

StaticPopupDialogs["ARENA_POPUP_INVITE_OFFER"] = {
    text = "",
    button1 = TEXT(ACCEPT),
    button2 = TEXT(DECLINE),
    OnAccept = function()
        HandleInvite(true)
    end,
    OnCancel = function()
        HandleInvite(false)
    end,
    timeout = 0,
}

StaticPopupDialogs["ARENA_POPUP_KICK_CONFIRM"] = {
    text = TEXT(ARENA_TEAM_KICK_CONFIRM),
    button1 = TEXT(CONFIRM),
    button2 = TEXT(CANCEL),
    OnAccept = function()
        KickPlayer()
    end,
    timeout = 0,
    hideOnEscape = true,
}

StaticPopupDialogs["ARENA_POPUP_LEAVE_CONFIRM"] = {
    text = TEXT(ARENA_TEAM_LEAVE_CONFIRM),
    button1 = TEXT(CONFIRM),
    button2 = TEXT(CANCEL),
    OnAccept = function()
        LeaveTeam()
    end,
    timeout = 0,
    hideOnEscape = true,
}