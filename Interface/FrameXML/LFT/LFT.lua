BINDING_HEADER_LFT = "Group Finder"
BINDING_NAME_LFT = "Toggle Group Finder"

local LFT_CONFIG = {}
local _G, _ = _G or getfenv()

LFT = CreateFrame("Frame")
local me = UnitName('player')
local addonVer = '0.0.4.0'
local LFT_ADDON_CHANNEL = 'LFT'
local groupsFormedThisSession = 0
local LFT_isHC = false
local StillAlive

-- check: while in group, window closes at 0 and 30
-- check: rare case when goingWith is sent but i join a manual group and someone with lft
--   will invite me (maybe add a not inGroup check before sending goingWith)

-- todo : stats like "x players is looking for groups at the moment" available at all times

--- [5:09 PM] Dogenovi: LFM Idea: Group forming for elite quests.
--- Group forms when 3 players accumulate
--- Doesn't respect class roles (They are not too important for outdoor content as you don't engage a lot of mobs at once)
--- Keeps looking for players after a party of 3 is formed.

ROLE_TANK_TOOLTIP = 'Indicates that you are willing to\nprotect allies from harm by\nensuring that enemies are\nattacking you instead of them.'
ROLE_HEALER_TOOLTIP = 'Indicates that you are willing to\nheal your allies when they take\ndamage.'
ROLE_DAMAGE_TOOLTIP = 'Indicates that you are willing to\ntake on the role of dealing\ndamage to enemies.'
ROLE_BAD_TOOLTIP = 'Your class may not perform this role.'

LFT.tab = 1
LFT.dungeonsSpam = {}
LFT.dungeonsSpamDisplay = {}
LFT.dungeonsSpamDisplayLFM = {}
LFT.browseFrames = {}
LFT.showedUpdateNotification = false
LFT.maxDungeonsInQueue = 5
LFT.groupSizeMax = 5
LFT.class = ''
LFT.channel = LFT_ADDON_CHANNEL
LFT.channelIndex = 0
LFT.level = UnitLevel('player')
LFT.findingGroup = false
LFT.findingMore = false
LFT:RegisterEvent("VARIABLES_LOADED")
LFT:RegisterEvent("PLAYER_ENTERING_WORLD")
LFT:RegisterEvent("PARTY_MEMBERS_CHANGED")
LFT:RegisterEvent("PARTY_LEADER_CHANGED")
LFT:RegisterEvent("PLAYER_LEVEL_UP")
LFT:RegisterEvent("PLAYER_TARGET_CHANGED")
LFT.availableDungeons = {}
LFT.group = {}
LFT.oneGroupFull = false
LFT.groupFullCode = ''
LFT.acceptNextInvite = false
LFT.onlyAcceptFrom = ''
LFT.queueStartTime = 0
LFT.averageWaitTime = 0
LFT.types = {
	[1] = 'Suggested Dungeons',
	--	[2] = 'Random Dungeon',
	[3] = 'All Available Dungeons',
	--[4] = 'Elite Quests'
}
local TYPE_ELITE_QUESTS = 4
LFT.quests = {}
LFT.maxDungeonsList = 11
LFT.minimapFrames = {}
LFT.myRandomTime = 0
LFT.random_min = 0
LFT.random_max = 5

LFT.RESET_TIME = 0
LFT.TANK_TIME = 2
LFT.HEALER_TIME = 10
LFT.DAMAGE_TIME = 18
LFT.FULLCHECK_TIME = 26 --time when checkGroupFull is called, has to wait for goingWith messages
LFT.TIME_MARGIN = 30

LFT.ROLE_CHECK_TIME = 50

LFT.foundGroup = false
LFT.inGroup = false
LFT.isLeader = false
LFT.LFMGroup = {}
LFT.LFMDungeonCode = ''
LFT.currentGroupSize = 1

LFT.objectivesFrames = {}
LFT.peopleLookingForGroups = 0
LFT.peopleLookingForGroupsDisplay = 0

LFT.gotOnline = false
LFT.gotUptime = false
LFT.gotTimeFromServer = false
LFT.sentServerInfoRequest = false

LFT.hookExecutions = 0

LFT.currentGroupRoles = {}

LFT.supress = {}

LFT.classColors = {
	["warrior"] = { r = 0.78, g = 0.61, b = 0.43, c = "|cffc79c6e" },
	["mage"] = { r = 0.41, g = 0.8, b = 0.94, c = "|cff69ccf0" },
	["rogue"] = { r = 1, g = 0.96, b = 0.41, c = "|cfffff569" },
	["druid"] = { r = 1, g = 0.49, b = 0.04, c = "|cffff7d0a" },
	["hunter"] = { r = 0.67, g = 0.83, b = 0.45, c = "|cffabd473" },
	["shaman"] = { r = 0.14, g = 0.35, b = 1.0, c = "|cff0070de" },
	["priest"] = { r = 1, g = 1, b = 1, c = "|cffffffff" },
	["warlock"] = { r = 0.58, g = 0.51, b = 0.79, c = "|cff9482c9" },
	["paladin"] = { r = 0.96, g = 0.55, b = 0.73, c = "|cfff58cba" }
}

local LFT_Titles = CreateFrame("Frame")
LFT_Titles:RegisterEvent("CHAT_MSG_ADDON")
LFT_Titles:RegisterEvent("VARIABLES_LOADED")

LFT_Titles:SetScript("OnEvent", function()
	if event then
		if event == "CHAT_MSG_ADDON" and arg1 == "TWT_TITLES" then
			local availableTitles = ___explode(arg2, ";")
			for n=2, table.getn(availableTitles), 1 do
				local title = ___explode(availableTitles[n], ":")[1]
				if title == StillAlive then
					LFT_isHC = true
				end
			end
		end
		if event == "VARIABLES_LOADED" then
			for id=1,100 do
				if getglobal('PVP_MEDAL' .. id) == "Still Alive" then
					StillAlive = tostring(id)
					SendAddonMessage("TW_TITLES", "Titles:List", "GUILD")
				end
			end
		end
	end
end)

function LFTisHC() 
	return LFT_isHC
end

--quest watcher
local LFTQuestWatcher = CreateFrame("Frame")
--LFTQuestWatcher:RegisterEvent("QUEST_ACCEPTED")
--LFTQuestWatcher:RegisterEvent("QUEST_REMOVED")
--LFTQuestWatcher:RegisterEvent("QUEST_TURNED_IN")
LFTQuestWatcher:RegisterEvent("QUEST_LOG_UPDATE")
LFTQuestWatcher:Show()

LFTQuestWatcher:SetScript("OnEvent", function()
	if event then
		if event == "QUEST_LOG_UPDATE" then
			if LFT_CONFIG['type'] == TYPE_ELITE_QUESTS then
				lfdebug(event)
				LFT.getEliteQuests()
				DungeonListFrame_Update()
			end
		end

	end
end)

-- delay leave queue, to check if im really ungrouped
local LFTDelayLeaveQueue = CreateFrame("Frame")
LFTDelayLeaveQueue:Hide()
LFTDelayLeaveQueue.reason = ''
LFTDelayLeaveQueue:SetScript("OnShow", function()
	this.startTime = GetTime()
end)
LFTDelayLeaveQueue:SetScript("OnUpdate", function()
	local plus = 2 --seconds
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then
		LFT.inGroup = GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0
		if not LFT.inGroup then
			leaveQueue(LFTDelayLeaveQueue.reason)
			LFTDelayLeaveQueue.reason = ''
			LFT.hidePartyRoleIcons()
		end
		LFTDelayLeaveQueue:Hide()
	end
end)

local LFTMinimapAnimation = CreateFrame("Frame")
LFTMinimapAnimation:Hide()

LFTMinimapAnimation:SetScript("OnShow", function()
	this.startTime = GetTime()
	this.frameIndex = 0
end)
LFTMinimapAnimation:SetScript("OnHide", function()
	_G['LFT_MinimapEye']:SetTexture('Interface\\FrameXML\\LFT\\images\\eye\\battlenetworking0')
end)

LFTMinimapAnimation:SetScript("OnUpdate", function()
	local plus = 0.10 --seconds
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then

		if this.frameIndex < 28 then
			this.frameIndex = this.frameIndex + 1
		else
			this.frameIndex = 0
		end

		_G['LFT_MinimapEye']:SetTexture('Interface\\FrameXML\\LFT\\images\\eye\\battlenetworking' .. this.frameIndex)

		this.startTime = GetTime()

	end
end)

local LFTTime = CreateFrame("Frame")
LFTTime:Hide()
LFTTime.second = -1
LFTTime.diff = 0

LFTTime:SetScript("OnShow", function()
	lfdebug('lfttime SHOW call LFTTime.second = ' .. LFTTime.second .. ' my:' .. tonumber(date("%S", time())))
	lfdebug('diff = ' .. LFTTime.diff)
	this.startTime = GetTime()
	this.execAt = {}
	this.resetAt = {}
end)

LFTTime:SetScript("OnUpdate", function()
	local plus = 0.5 --seconds
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then

		this.startTime = GetTime()

		--LFT.currentGroupSize = GetNumPartyMembers() + 1

		LFTTime.second = tonumber(date("%S", time())) + LFTTime.diff
		if LFTTime.second < 0 then
			LFTTime.second = LFTTime.second + 60
		end
		if LFTTime.second >= 60 then
			LFTTime.second = LFTTime.second - 60
		end

		if LFTTime.second == LFT.RESET_TIME or LFTTime.second == LFT.TIME_MARGIN then

			if not this.resetAt[LFTTime.second] then

				this.resetAt[LFTTime.second] = true

				if LFT.peopleLookingForGroupsDisplay < LFT.peopleLookingForGroups or LFT.peopleLookingForGroups == 0 then
					LFT.peopleLookingForGroupsDisplay = LFT.peopleLookingForGroups
				end

				LFT.peopleLookingForGroups = 0

				LFT.browseNames = {}

				lfdebug("RESET --- TIME IS 0 OR 30")

				for dungeon, data in next, LFT.dungeons do
					--reset dungeon spam
					LFT.dungeonsSpam[data.code] = { tank = 0, healer = 0, damage = 0 }
					--reset myRole
					if LFT.groupFullCode == '' and not LFT.inGroup then
						LFT.dungeons[dungeon].myRole = ''
					end
				end
				this.execAt = {}

			end
		end

		if (LFTTime.second > 2 and LFTTime.second < 27) or
				(LFTTime.second > 32 and LFTTime.second < 57) then

			this.resetAt = {}

			if not this.execAt[LFTTime.second] then
				BrowseDungeonListFrame_Update()
				this.execAt[LFTTime.second] = true
			end

		end

		if LFTTime.second == 28 or LFTTime.second == 58 then
			--check for 0 at 28 and 58
			for dungeon, data in next, LFT.dungeons do
				if LFT.dungeonsSpam[data.code].tank == 0 then
					LFT.dungeonsSpamDisplay[data.code].tank = LFT.dungeonsSpam[data.code].tank
				end
				if LFT.dungeonsSpam[data.code].healer == 0 then
					LFT.dungeonsSpamDisplay[data.code].healer = LFT.dungeonsSpam[data.code].healer
				end
				if LFT.dungeonsSpam[data.code].damage == 0 then
					LFT.dungeonsSpamDisplay[data.code].damage = LFT.dungeonsSpam[data.code].damage
				end
				LFT.dungeonsSpamDisplayLFM[data.code] = 0
			end
		end


	end
end)

local LFTGoingWithPicker = CreateFrame("Frame")
LFTGoingWithPicker:Hide()
LFTGoingWithPicker.candidate = ''
LFTGoingWithPicker.priority = 0
LFTGoingWithPicker.dungeon = ''
LFTGoingWithPicker.myRole = ''

LFTGoingWithPicker:SetScript("OnShow", function()
	this.startTime = GetTime()
end)

LFTGoingWithPicker:SetScript("OnHide", function()
end)

LFTGoingWithPicker:SetScript("OnUpdate", function()
	local plus = 1 --seconds
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then

		LFT.dungeons[LFT.dungeonNameFromCode(LFTGoingWithPicker.dungeon)].myRole = LFTGoingWithPicker.myRole

		SendChatMessage('goingWith:' .. LFTGoingWithPicker.candidate .. ':' .. LFTGoingWithPicker.dungeon
				.. ':' .. LFTGoingWithPicker.myRole, "CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))

		LFT.foundGroup = true

		LFTGoingWithPicker.candidate = ''
		LFTGoingWithPicker.myRole = ''
		LFTGoingWithPicker.priority = 0
		LFTGoingWithPicker.dungeon = ''
		LFTGoingWithPicker:Hide()
	end
end)

local COLOR_RED = '|cffff222a'
local COLOR_ORANGE = '|cffff8000'
local COLOR_GREEN = '|cff1fba1f'
local COLOR_HUNTER = '|cffabd473'
local COLOR_YELLOW = '|cffffff00'
local COLOR_WHITE = '|cffffffff'
local COLOR_DISABLED = '|cffaaaaaa'
local COLOR_DISABLED2 = '|cff666666'
local COLOR_TANK = '|cff0070de'
local COLOR_HEALER = COLOR_GREEN
local COLOR_DAMAGE = COLOR_RED

-- dungeon complete animation
local LFTDungeonComplete = CreateFrame("Frame")
LFTDungeonComplete:Hide()
LFTDungeonComplete.frameIndex = 0
LFTDungeonComplete.dungeonInProgress = false

LFTDungeonComplete:SetScript("OnShow", function()
	this.startTime = GetTime()
	LFTDungeonComplete.frameIndex = 0
	_G['LFTDungeonComplete']:SetAlpha(0)
	_G['LFTDungeonComplete']:Show()
end)

LFTDungeonComplete:SetScript("OnHide", function()
	--	this.startTime = GetTime()
end)

LFTDungeonComplete:SetScript("OnUpdate", function()
	local plus = 0.03 --seconds
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then
		this.startTime = GetTime()
		local frame = ''
		if LFTDungeonComplete.frameIndex < 10 then
			frame = frame .. '0' .. LFTDungeonComplete.frameIndex
		else
			frame = frame .. LFTDungeonComplete.frameIndex
		end
		_G['LFTDungeonCompleteFrame']:SetTexture('Interface\\FrameXML\\LFT\\images\\dungeon_complete\\dungeon_complete_' .. frame)
		if LFTDungeonComplete.frameIndex < 35 then
			_G['LFTDungeonComplete']:SetAlpha(_G['LFTDungeonComplete']:GetAlpha() + 0.03)
		end
		if LFTDungeonComplete.frameIndex > 119 then
			_G['LFTDungeonComplete']:SetAlpha(_G['LFTDungeonComplete']:GetAlpha() - 0.03)
		end
		if LFTDungeonComplete.frameIndex >= 150 then
			_G['LFTDungeonComplete']:Hide()
			_G['LFTDungeonStatus']:Hide()
			_G['LFTDungeonCompleteFrame']:SetTexture('Interface\\FrameXML\\LFT\\images\\dungeon_complete\\dungeon_complete_00')
			LFTDungeonComplete:Hide()

			local index = 0
			for _, boss in next, LFT.bosses[LFT.groupFullCode] do
				index = index + 1
				LFT.objectivesFrames[index]:Hide()
				LFT.objectivesFrames[index].completed = false
				_G["LFTObjective" .. index .. 'ObjectiveComplete']:Hide()
				_G["LFTObjective" .. index .. 'ObjectivePending']:Hide()
				_G["LFTObjective" .. index .. 'Objective']:SetText('')
			end
			--LFT.objectivesFrames = {}
		end
		LFTDungeonComplete.frameIndex = LFTDungeonComplete.frameIndex + 1
	end
end)

-- objectives
local LFTObjectives = CreateFrame("Frame")
LFTObjectives:Hide()
--LFTObjectives:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
LFTObjectives.collapsed = false
LFTObjectives.closedByUser = false
LFTObjectives.lastObjective = 0
LFTObjectives.leftOffset = -80
LFTObjectives.frameIndex = 0
LFTObjectives.objectivesComplete = 0

function close_lft_objectives()
	LFTObjectives.closedByUser = true
	_G['LFTDungeonStatus']:Hide()
end

-- swoooooooosh

LFTObjectives:SetScript("OnShow", function()
	LFTObjectives.leftOffset = -80
	LFTObjectives.frameIndex = 0
	this.startTime = GetTime()
end)

LFTObjectives:SetScript("OnHide", function()
	--	this.startTime = GetTime()
end)

LFTObjectives:SetScript("OnUpdate", function()
	local plus = 0.001 --seconds
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then
		this.startTime = GetTime()
		LFTObjectives.frameIndex = LFTObjectives.frameIndex + 1
		LFTObjectives.leftOffset = LFTObjectives.leftOffset + 5
		_G["LFTObjective" .. LFTObjectives.lastObjective .. 'Swoosh']:SetPoint("TOPLEFT", _G["LFTObjective" .. LFTObjectives.lastObjective], "TOPLEFT", LFTObjectives.leftOffset, 5)
		if LFTObjectives.frameIndex <= 10 then
			_G["LFTObjective" .. LFTObjectives.lastObjective .. 'Swoosh']:SetAlpha(LFTObjectives.frameIndex / 10)
		end
		if LFTObjectives.frameIndex >= 30 then
			_G["LFTObjective" .. LFTObjectives.lastObjective .. 'Swoosh']:SetAlpha(1 - LFTObjectives.frameIndex / 40)
		end
		if LFTObjectives.leftOffset >= 120 then
			LFTObjectives:Hide()
			_G["LFTObjective" .. LFTObjectives.lastObjective .. 'Swoosh']:SetAlpha(0)
		end
	end
end)

LFTObjectives:SetScript("OnEvent", function()
	if event then
		if event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then
			local creatureDied = arg1
			--lfdebug(creatureDied)
			if LFT.bosses[LFT.groupFullCode] then
				for _, boss in next, LFT.bosses[LFT.groupFullCode] do
					--creatureDied == 'You have slain ' .. boss .. '!'
					if creatureDied == boss .. ' dies.' then
						LFTObjectives.objectiveComplete(boss)
						return true
					end
				end
			end
		end
	end
end)

-- fill available dungeons delayer because UnitLevel(member who just joined) returns 0
local LFTFillAvailableDungeonsDelay = CreateFrame("Frame")
LFTFillAvailableDungeonsDelay.triggers = 0
LFTFillAvailableDungeonsDelay.queueAfterIfPossible = false
LFTFillAvailableDungeonsDelay:Hide()
LFTFillAvailableDungeonsDelay:SetScript("OnShow", function()
	this.startTime = GetTime()
end)

LFTFillAvailableDungeonsDelay:SetScript("OnHide", function()
	if LFTFillAvailableDungeonsDelay.triggers < 10 then
		LFT.fillAvailableDungeons(LFTFillAvailableDungeonsDelay.queueAfterIfPossible)
		LFTFillAvailableDungeonsDelay.triggers = LFTFillAvailableDungeonsDelay.triggers + 1
	else
		--lferror('Error occurred at LFTFillAvailableDungeonsDelay triggers = 10. Please report this to Xerron/Er.')
	end
end)
LFTFillAvailableDungeonsDelay:SetScript("OnUpdate", function()
	local plus = 0.1 --seconds
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then
		LFTFillAvailableDungeonsDelay:Hide()
	end
end)

-- channel join delayer

local LFTChannelJoinDelay = CreateFrame("Frame")
LFTChannelJoinDelay:Hide()

LFTChannelJoinDelay:SetScript("OnShow", function()
	this.startTime = GetTime()
end)

LFTChannelJoinDelay:SetScript("OnHide", function()
	LFT.checkLFTChannel()
end)

LFTChannelJoinDelay:SetScript("OnUpdate", function()
	local plus = 15 --seconds
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then
		LFTChannelJoinDelay:Hide()
		
	end
end)

local LFTQueue = CreateFrame("Frame")
LFTQueue:Hide()

-- group invite timer

local LFTInvite = CreateFrame("Frame")
LFTInvite:Hide()
LFTInvite.inviteIndex = 1
LFTInvite:SetScript("OnShow", function()
	this.startTime = GetTime()
	LFTInvite.inviteIndex = 1
	local awesomeButton = _G['LFTGroupReadyAwesome']
	awesomeButton:SetText('Waiting Players (' .. LFT.groupSizeMax - GetNumPartyMembers() - 1 .. ')')
	awesomeButton:Disable()
end)

LFTInvite:SetScript("OnUpdate", function()
	local plus = 0.5 --seconds
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then
		this.startTime = GetTime()

		LFTInvite.inviteIndex = this.inviteIndex + 1

		if LFTInvite.inviteIndex == 2 then
			if LFT.group[LFT.groupFullCode].healer ~= '' then
				InviteByName(LFT.group[LFT.groupFullCode].healer)
			end
		end
		if LFTInvite.inviteIndex == 3 then
			if LFT.group[LFT.groupFullCode].damage1 ~= '' then
				InviteByName(LFT.group[LFT.groupFullCode].damage1)
			end
		end
		if LFTInvite.inviteIndex == 4 and LFTInvite.inviteIndex <= LFT.groupSizeMax then
			if LFT.group[LFT.groupFullCode].damage2 ~= '' then
				InviteByName(LFT.group[LFT.groupFullCode].damage2)
			end
		end
		if LFTInvite.inviteIndex == 5 and LFTInvite.inviteIndex <= LFT.groupSizeMax then
			if LFT.group[LFT.groupFullCode].damage3 ~= '' then
				InviteByName(LFT.group[LFT.groupFullCode].damage3)
				LFTInvite:Hide()
				LFTInvite.inviteIndex = 1
			end
		end
	end
end)

-- role check timer

local LFTRoleCheck = CreateFrame("Frame")
LFTRoleCheck:Hide()

LFTRoleCheck:SetScript("OnShow", function()
	this.startTime = GetTime()
end)

LFTRoleCheck:SetScript("OnHide", function()
	if LFT.isLeader then
		if LFT.findingMore then
		else
			lfprint('A member of your group has not confirmed his role.')
			PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_denied.ogg")
			_G['findMoreButton']:Enable()
		end
	end
	_G['LFTRoleCheck']:Hide()
end)

LFTRoleCheck:SetScript("OnUpdate", function()
	local plus = LFT.ROLE_CHECK_TIME --seconds
	if LFT.isLeader then
		plus = plus + 2 --leader waits 2 more second to hide
	end
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then
		LFTRoleCheck:Hide()

		if LFT.isLeader then
			_G['findMoreButton']:Disable()

		else
			declineRole()
		end
	end
end)

-- who counter timer

local LFTWhoCounter = CreateFrame("Frame")
LFTWhoCounter:Hide()
LFTWhoCounter.people = 0
LFTWhoCounter.total = 0
LFTWhoCounter.listening = false
LFTWhoCounter:SetScript("OnShow", function()
	this.startTime = GetTime()
	LFTWhoCounter.people = 0
	LFTWhoCounter.listening = true
	lfprint('Checking people online with the addon (5secs)...')
end)

LFTWhoCounter:SetScript("OnHide", function()
	LFTWhoCounter.people = LFTWhoCounter.people + 1 -- + me
	lfprint('Found ' .. COLOR_GREEN .. LFTWhoCounter.people .. COLOR_WHITE .. '/' .. LFTWhoCounter.total .. ' online using LFT addon.')
	LFTWhoCounter.listening = false
end)

LFTWhoCounter:SetScript("OnUpdate", function()
	local plus = 5 --seconds
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then
		LFTWhoCounter:Hide()
	end
end)

--closes the group ready frame when someone leaves queue from the button
local LFTGroupReadyFrameCloser = CreateFrame("Frame")
LFTGroupReadyFrameCloser:Hide()
LFTGroupReadyFrameCloser.response = ''
LFTGroupReadyFrameCloser:SetScript("OnShow", function()
	this.startTime = GetTime()
end)

LFTGroupReadyFrameCloser:SetScript("OnHide", function()
end)
LFTGroupReadyFrameCloser:SetScript("OnUpdate", function()
	local plus = LFT.ROLE_CHECK_TIME --time after i click leave queue, afk
	local plus2 = LFT.ROLE_CHECK_TIME + 5 --time after i close the window
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	local st2 = (this.startTime + plus2) * 1000
	if gt >= st then
		if LFTGroupReadyFrameCloser.response == '' then
			sayNotReady()
		end
	end
	if gt >= st2 then
		_G['LFTReadyStatus']:Hide()
		if GetNumPartyMembers() ~= 4 then --No point in displaying all this if the group is full?
			lfprint('A member of your group has not accepted the invitation. You are rejoining the queue.')
			if LFT.isLeader then
				leaveQueue('LFTGroupReadyFrameCloser isleader = true')
				LFT.fillAvailableDungeons('queueAgain' == 'queueAgain')
			end
			if LFTGroupReadyFrameCloser.response == 'notReady' then
				--doesnt trigger for leader, cause it leaves queue
				--which resets response to ''
				--LeaveParty()
				LFTGroupReadyFrameCloser.response = ''
			end
		end
		LFTGroupReadyFrameCloser:Hide()
	end
end)

-- communication

local LFTComms = CreateFrame("Frame")
LFTComms:Hide()
LFTComms:RegisterEvent("CHAT_MSG_CHANNEL")
LFTComms:RegisterEvent("CHAT_MSG_WHISPER")
LFTComms:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")
LFTComms:RegisterEvent("PARTY_INVITE_REQUEST")
LFTComms:RegisterEvent("CHAT_MSG_ADDON")
LFTComms:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
LFTComms:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE_USER")
LFTComms:RegisterEvent("CHAT_MSG_SYSTEM")
--"CHAT_MSG_CHANNEL_NOTICE_USER"
--Category: Communication
--
--Fired when something changes in the channel like moderation enabled, user is kicked, announcements changed and so on. CHAT_*_NOTICE in GlobalStrings.lua has a full list of available types.
--
--arg1
--type ("ANNOUNCEMENTS_OFF", "ANNOUNCEMENTS_ON", "BANNED", "OWNER_CHANGED", "INVALID_NAME", "INVITE", "MODERATION_OFF", "MODERATION_ON", "MUTED", "NOT_MEMBER", "NOT_MODERATED", "SET_MODERATOR", "UNSET_MODERATOR" )
--arg2
--If arg5 has a value then this is the user affected ( eg: "Player Foo has been kicked by Bar" ), if arg5 has no value then it's the person who caused the event ( eg: "Channel Moderation has been enabled by Bar" )
--arg4
--Channel name with number
--arg5
--Player that caused the event (eg "Player Foo has been kicked by Bar" )

LFTComms:SetScript("OnEvent", function()
	if event then
		if event == 'CHAT_MSG_SYSTEM' then
			if string.find(arg1, 'Server uptime:', 1, true) and
					not LFT.gotUptime and
					(string.find(arg1, 'Days', 1, true) or
							string.find(arg1, 'Hours', 1, true) or
							string.find(arg1, 'Minutes', 1, true) or
							string.find(arg1, 'Seconds', 1, true)) then

				if string.find(arg1, 'Seconds', 1, true) then
					local mSplit = string.split(arg1, ' ')
					if not tonumber(mSplit[LFT.tableSize(mSplit) - 1]) then
						return false
					end
					LFTTime.second = tonumber(mSplit[LFT.tableSize(mSplit) - 1])
					LFTTime:Hide()
					LFTTime.diff = LFTTime.second - tonumber(date("%S", time()))
					LFTTime:Show()
				else
					LFTTime.second = 0
					LFTTime:Hide()
					LFTTime.diff = LFTTime.second - tonumber(date("%S", time()))
					LFTTime:Show() --default 0
				end

				return true
			end
		end
		if event == 'CHAT_MSG_CHANNEL_NOTICE_USER' then

			if arg1 == 'PLAYER_ALREADY_MEMBER' then
				-- probably only used when reloadui
				LFT.checkLFTChannel()
			end
			--lfdebug('CHAT_MSG_CHANNEL_NOTICE_USER')
			--lfdebug(arg1) --event,
			--lfdebug(arg2) -- somename
			--lfdebug(arg3) -- blank
			--lfdebug(arg4) -- 6.Lft
			--lfdebug(arg5) -- blank
			--lfdebug('channel index = ' .. LFT.channelIndex) -- blank
		end
		if event == 'CHAT_MSG_CHANNEL_NOTICE' then
			if arg9 == LFT.channel and arg1 == 'YOU_JOINED' then
				LFT.channelIndex = arg8
			end
		end

		if event == 'CHAT_MSG_ADDON' and arg1 == LFT_ADDON_CHANNEL then
			lfdebug(arg4 .. ' says : ' .. arg2)
			if string.sub(arg2, 1, 11) == 'objectives:' and arg4 ~= me then
				local objEx = string.split(arg2, ':')
				if LFT.groupFullCode ~= objEx[2] then
					LFT.groupFullCode = objEx[2]
				end

				local objectivesString = string.split(objEx[3], '-')

				local complete = 0

				for stringIndex, s in next, objectivesString do
					if s then
						if s == '1' then
							complete = complete + 1
							local index = 0
							for _, boss in next, LFT.bosses[LFT.groupFullCode] do
								index = index + 1
								if index == stringIndex then
									LFTObjectives.objectiveComplete(boss, true)
								end
							end
						end
					end
				end

				if not LFTObjectives.closedByUser and not _G["LFTDungeonStatus"]:IsVisible() then
					LFT.showDungeonObjectives('code_for_debug_only', complete)
				end
			end
			if string.sub(arg2, 1, 11) == 'notReadyAs:' then

				PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_denied.ogg")

				local readyEx = string.split(arg2, ':')
				local role = readyEx[2]
				if role == 'tank' then
					_G['LFTReadyStatusReadyTank']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-notready')
				end
				if role == 'healer' then
					_G['LFTReadyStatusReadyHealer']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-notready')
				end
				if role == 'damage' then
					if _G['LFTReadyStatusReadyDamage1']:GetTexture() == 'Interface\\FrameXML\\LFT\\images\\readycheck-waiting' then
						_G['LFTReadyStatusReadyDamage1']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-notready')
					elseif _G['LFTReadyStatusReadyDamage2']:GetTexture() == 'Interface\\FrameXML\\LFT\\images\\readycheck-waiting' then
						_G['LFTReadyStatusReadyDamage2']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-notready')
					elseif _G['LFTReadyStatusReadyDamage3']:GetTexture() == 'Interface\\FrameXML\\LFT\\images\\readycheck-waiting' then
						_G['LFTReadyStatusReadyDamage3']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-notready')
					end
				end
			end
			if string.sub(arg2, 1, 8) == 'readyAs:' then
				local readyEx = string.split(arg2, ':')
				local role = readyEx[2]

				LFT.showPartyRoleIcons(role, arg4)

				if role == 'tank' then
					_G['LFTReadyStatusReadyTank']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-ready')
				end
				if role == 'healer' then
					_G['LFTReadyStatusReadyHealer']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-ready')
				end
				if role == 'damage' then
					if _G['LFTReadyStatusReadyDamage1']:GetTexture() == 'Interface\\FrameXML\\LFT\\images\\readycheck-waiting' then
						_G['LFTReadyStatusReadyDamage1']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-ready')
					elseif _G['LFTReadyStatusReadyDamage2']:GetTexture() == 'Interface\\FrameXML\\LFT\\images\\readycheck-waiting' then
						_G['LFTReadyStatusReadyDamage2']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-ready')
					elseif _G['LFTReadyStatusReadyDamage3']:GetTexture() == 'Interface\\FrameXML\\LFT\\images\\readycheck-waiting' then
						_G['LFTReadyStatusReadyDamage3']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-ready')
					end
				end
				if _G['LFTReadyStatusReadyTank']:GetTexture() == 'Interface\\FrameXML\\LFT\\images\\readycheck-ready' and
						_G['LFTReadyStatusReadyHealer']:GetTexture() == 'Interface\\FrameXML\\LFT\\images\\readycheck-ready' and
						_G['LFTReadyStatusReadyDamage1']:GetTexture() == 'Interface\\FrameXML\\LFT\\images\\readycheck-ready' and
						_G['LFTReadyStatusReadyDamage2']:GetTexture() == 'Interface\\FrameXML\\LFT\\images\\readycheck-ready' and
						_G['LFTReadyStatusReadyDamage3']:GetTexture() == 'Interface\\FrameXML\\LFT\\images\\readycheck-ready' then
					_G['LFTReadyStatus']:Hide()
					LFTGroupReadyFrameCloser:Hide()
					local _, numCompletedObjectives = LFT.getDungeonCompletion()
					LFT.showDungeonObjectives('dummy', numCompletedObjectives)
					--promote the tank to leader
				end
				if LFT.isLeader and role == 'tank' and arg4 ~= me then
					PromoteByName(arg4)
				end
			end

			if string.sub(arg2, 1, 11) == 'leaveQueue:' and arg4 ~= me then
				leaveQueue('leaveQueue: addon party')
			end

			if string.sub(arg2, 1, 8) == 'minimap:' then
				if not LFT.isLeader then
					local miniEx = string.split(arg2, ':')
					local code = miniEx[2]
					local tank = tonumber(miniEx[3])
					local healer = tonumber(miniEx[4])
					local damage = tonumber(miniEx[5])

					LFT.LFMDungeonCode = code

					LFT.group = {} --reset old entries
					LFT.group[code] = {
						tank = '',
						healer = '',
						damage1 = '',
						damage2 = '',
						damage3 = ''
					}
					if tank == 1 then
						LFT.group[code].tank = 'DummyTank'
					end
					if healer == 1 then
						LFT.group[code].healer = 'DummyHealer'
					end
					if damage > 0 then
						LFT.group[code].damage1 = 'DummyDamage1'
					end
					if damage > 1 then
						LFT.group[code].damage2 = 'DummyDamage2'
					end
					if damage > 2 then
						LFT.group[code].damage3 = 'DummyDamage3'
					end
				end
			end
			if string.sub(arg2, 1, 14) == 'LFMPartyReady:' then

				local queueEx = string.split(arg2, ':')
				local mCode = queueEx[2]
				local objectivesCompleted = queueEx[3]
				local objectivesTotal = queueEx[4]

				LFT.groupFullCode = mCode
				LFT.LFMDungeonCode = mCode

				--uncheck everything
				_G['Dungeon_' .. LFT.groupFullCode .. '_CheckButton']:SetChecked(false)
				LFT.findingGroup = false
				LFT.findingMore = false
				local background = ''
				local dungeonName = 'unknown'
				for d, data in next, LFT.dungeons do
					if data.code == mCode then
						background = data.background
						dungeonName = d
					end
				end

				local myRole = LFT.dungeons[LFT.dungeonNameFromCode(mCode)].myRole

				LFT.SetSingleRole(myRole)

				_G['LFTGroupReadyBackground']:SetTexture('Interface\\FrameXML\\LFT\\images\\background\\ui-lfg-background-' .. background)
				_G['LFTGroupReadyRole']:SetTexture('Interface\\FrameXML\\LFT\\images\\' .. myRole .. '2')
				_G['LFTGroupReadyMyRole']:SetText(LFT.ucFirst(myRole))
				_G['LFTGroupReadyDungeonName']:SetText(dungeonName)
				_G['LFTGroupReadyObjectivesCompleted']:SetText(objectivesCompleted .. '/' .. objectivesTotal .. ' Bosses Defeated')

				LFT.readyStatusReset()
				_G['LFTGroupReady']:Show()
				LFTGroupReadyFrameCloser:Show()

				LFT.fixMainButton()
				_G['LFTlft']:Hide()

				PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\levelup2.ogg")
				LFTQueue:Hide()

				if LFT.isLeader then
					SendChatMessage("[LFT]:lft_group_formed:" .. mCode .. ":" .. time() - LFT.queueStartTime, "CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))
				end
			end
			if string.sub(arg2, 1, 10) == 'weInQueue:' then
				local queueEx = string.split(arg2, ':')
				LFT.weInQueue(queueEx[2])
			end
			if string.sub(arg2, 1, 10) == 'roleCheck:' then
				if arg4 ~= me then
					PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_rolecheck.ogg")
				end
				lfprint('A role check has been initiated. Your group will be queued when all members have selected a role.')
				UIErrorsFrame:AddMessage("|cff69ccf0[Group Finder] |cffffff00A role check has been initiated. Your group will be queued when all members have selected a role.")

				local argEx = string.split(arg2, ':')
				local mCode = argEx[2]
				LFT.LFMDungeonCode = mCode
				LFT.resetGroup()

				lfdebug('my role is : ' .. LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole)

				--if we dont know my prev role
				if LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole == '' then

					if _G['RoleTank']:GetChecked() then
						LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole = 'tank'
					elseif _G['RoleHealer']:GetChecked() then
						LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole = 'healer'
					elseif _G['RoleDamage']:GetChecked() then
						LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole = 'damage'
					else
						LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole = LFT.GetPossibleRoles()
					end
				end

				_G['roleCheckTank']:SetChecked(LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole == 'tank')
				_G['roleCheckHealer']:SetChecked(LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole == 'healer')
				_G['roleCheckDamage']:SetChecked(LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole == 'damage')

				lfdebug(' my  role after checks : ' .. LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole)

				_G['LFTRoleCheckAcceptRole']:Enable()

				--commented this to show my rolecheck window
				--if LFT.isLeader then
				--	lfdebug('is leader')
				--	if LFT_CONFIG['role'] == 'tank' then
				--		LFT.LFMGroup.tank = me
				--		SendAddonMessage(LFT_ADDON_CHANNEL, "acceptRole:" .. LFT_CONFIG['role'], "PARTY")
				--	end
				--	if LFT_CONFIG['role'] == 'healer' then
				--		LFT.LFMGroup.healer = me
				--		SendAddonMessage(LFT_ADDON_CHANNEL, "acceptRole:" .. LFT_CONFIG['role'], "PARTY")
				--	end
				--	if LFT_CONFIG['role'] == 'damage' then
				--		LFT.LFMGroup.damage1 = me
				--		SendAddonMessage(LFT_ADDON_CHANNEL, "acceptRole:" .. LFT_CONFIG['role'], "PARTY")
				--	end
				--else
				_G['LFTRoleCheckQForText']:SetText(COLOR_WHITE .. "Queued for " .. COLOR_YELLOW .. LFT.dungeonNameFromCode(mCode))
				_G['LFTRoleCheck']:Show()
				_G['LFTGroupReady']:Hide()
				--end
				LFTRoleCheck:Show()
			end

			if string.sub(arg2, 1, 11) == 'acceptRole:' then
				local roleEx = string.split(arg2, ':')
				local roleColor = ''

				if arg4 == me and not LFT.isLeader then
					LFTRoleCheck:Hide()
				end

				LFT.showPartyRoleIcons(roleEx[2], arg4)

				if roleEx[2] == 'tank' then
					roleColor = COLOR_TANK
				end
				if roleEx[2] == 'healer' then
					roleColor = COLOR_HEALER
				end
				if roleEx[2] == 'damage' then
					roleColor = COLOR_DAMAGE
				end
				if arg4 == me then
					lfprint('You have chosen: ' .. roleColor .. LFT.ucFirst(roleEx[2]))
				end

				if roleEx[2] == 'tank' then

					_G['roleCheckTank']:SetChecked(false)
					_G['roleCheckTank']:Disable()
					_G['LFTRoleCheckRoleTank']:SetDesaturated(1)

					if _G['LFTRoleCheck']:IsVisible() and LFT_CONFIG['role'] == 'tank' then
						_G['LFTRoleCheckAcceptRole']:Disable()
					end

					if LFT_CONFIG['role'] == 'tank' then
						if _G['LFTRoleCheck']:IsVisible() then
							_G['LFTRoleCheckAcceptRole']:Disable()
							_G['roleCheckTank']:SetChecked(false)
							_G['roleCheckTank']:Disable()
						else
							--not visible means confirmed by me
							--for me
							--should not get here i think, button will be disabled
							if LFT.isLeader then
								if arg4 ~= me then
									lfprint(LFT.classColors[LFT.playerClass(arg4)].c .. arg4 .. COLOR_WHITE .. ' has chosen '
											.. COLOR_TANK .. 'Tank' .. COLOR_WHITE .. ' but you already confirmed this role.')
									lfprint('Queueing aborted.')
									leaveQueue(' two tanks')
									return false
								end
							else
								--for other tank
								if LFT.LFMGroup.tank ~= '' and LFT.LFMGroup.tank ~= me then
									lfprint(COLOR_TANK .. 'Tank ' .. COLOR_WHITE .. 'role has already been filled by ' .. LFT.classColors[LFT.playerClass(LFT.LFMGroup.tank)].c .. LFT.LFMGroup.tank
											.. COLOR_WHITE .. '. Please select a different role to rejoin the queue.')
									return false
								end
							end
						end
					end
					LFT.LFMGroup.tank = arg4
				end

				if roleEx[2] == 'healer' then

					_G['roleCheckHealer']:SetChecked(false)
					_G['roleCheckHealer']:Disable()
					_G['LFTRoleCheckRoleHealer']:SetDesaturated(1)

					if _G['LFTRoleCheck']:IsVisible() and LFT_CONFIG['role'] == 'healer' then
						_G['LFTRoleCheckAcceptRole']:Disable()
					end

					if LFT_CONFIG['role'] == 'healer' then
						if _G['LFTRoleCheck']:IsVisible() then
							_G['LFTRoleCheckAcceptRole']:Disable()
							_G['roleCheckHealer']:SetChecked(false)
							_G['roleCheckHealer']:Disable()
						else
							--not visible means confirmed by me
							--for me
							--should not get here i think, button will be disabled
							if LFT.isLeader then
								if arg4 ~= me then
									lfprint(LFT.classColors[LFT.playerClass(arg4)].c .. arg4 .. COLOR_WHITE .. ' has chosen '
											.. COLOR_HEALER .. 'Healer' .. COLOR_WHITE .. ' but you already confirmed this role.')
									lfprint('Queueing aborted.')
									leaveQueue('two healers')
									return false
								end
							else
								--for other healer
								if LFT.LFMGroup.healer ~= '' then
									lfprint(COLOR_HEALER .. 'Healer ' .. COLOR_WHITE .. 'role has already been filled by ' .. LFT.classColors[LFT.playerClass(LFT.LFMGroup.healer)].c .. LFT.LFMGroup.healer
											.. COLOR_WHITE .. '. Please select a different role to rejoin the queue.')
									return false
								end
							end
						end
					end
					LFT.LFMGroup.healer = arg4
				end

				if roleEx[2] == 'damage' then

					local dpsFilled = false

					if LFT.LFMGroup.damage1 == '' then
						LFT.LFMGroup.damage1 = arg4
					elseif LFT.LFMGroup.damage2 == '' then
						LFT.LFMGroup.damage2 = arg4
					elseif LFT.LFMGroup.damage3 == '' then
						LFT.LFMGroup.damage3 = arg4

						dpsFilled = true
						_G['roleCheckDamage']:SetChecked(false)
						_G['roleCheckDamage']:Disable()
						_G['LFTRoleCheckRoleDamage']:SetDesaturated(1)

						if _G['LFTRoleCheck']:IsVisible() and LFT_CONFIG['role'] == 'damage' then
							_G['LFTRoleCheckAcceptRole']:Disable()
						end

					end

					if LFT_CONFIG['role'] == 'damage' or dpsFilled then

						if _G['LFTRoleCheck']:IsVisible() then

							-- lock accept buttons if we have 3 dps already
							if LFT.LFMGroup.damage1 ~= '' and
									LFT.LFMGroup.damage2 ~= '' and
									LFT.LFMGroup.damage3 ~= '' then
								--_G['LFTRoleCheckAcceptRole']:Disable()
								_G['roleCheckDamage']:SetChecked(false)
								_G['roleCheckDamage']:Disable()
								_G['LFTRoleCheckRoleDamage']:SetDesaturated(1)
							end

						else
							if dpsFilled then
								if LFT.isLeader then
									if arg4 ~= me and arg4 ~= LFT.LFMGroup.damage3 then
										if LFT.LFMGroup.damage1 ~= '' and LFT.LFMGroup.damage2 ~= '' and LFT.LFMGroup.damage3 ~= '' then
											lfprint(LFT.classColors[LFT.playerClass(arg4)].c .. arg4 .. COLOR_WHITE .. ' has chosen ' .. COLOR_DAMAGE .. 'Damage' .. COLOR_WHITE
													.. ' but the group already has ' .. COLOR_DAMAGE .. '3' .. COLOR_WHITE .. ' confirmed ' .. COLOR_DAMAGE .. 'Damage' .. COLOR_WHITE .. ' members.')
											lfprint('Queueing aborted.')
											leaveQueue('4 dps')
											return false
										end
									end
								else
									if LFT.LFMGroup.damage1 ~= '' and LFT.LFMGroup.damage2 ~= '' and LFT.LFMGroup.damage3 ~= '' then
										lfprint(COLOR_DAMAGE .. 'Damage ' .. COLOR_WHITE .. 'role has already been filled by ' .. COLOR_DAMAGE .. '3' .. COLOR_WHITE .. ' members. Please select a different role to rejoin the queue.')
										return false
									end
								end
							end
						end
					end

				end

				if arg4 ~= me then
					lfprint(LFT.classColors[LFT.playerClass(arg4)].c .. arg4 .. COLOR_WHITE .. ' has chosen: ' .. roleColor .. LFT.ucFirst(roleEx[2]))
				end
				LFT.checkLFMgroup()
			end
			if string.sub(arg2, 1, 12) == 'declineRole:' then
				PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\lfg_denied.ogg")
				LFT.checkLFMgroup(arg4)
			end
		end
		if event == 'PARTY_INVITE_REQUEST' then
			if LFT.acceptNextInvite then
				if arg1 == LFT.onlyAcceptFrom then
					LFT.AcceptGroupInvite()
					LFT.acceptNextInvite = false
				else
					LFT.DeclineGroupInvite()
				end
			end
			if not LFT.foundGroup then
				leaveQueue('PARTY_INVITE_REQUEST')
			end
		end
		if event == 'CHAT_MSG_CHANNEL_LEAVE' then
			LFT.removePlayerFromVirtualParty(arg2, false) --unknown role
		end
		if event == 'CHAT_MSG_CHANNEL' and string.find(arg1, '[LFT]', 1, true) and arg8 == LFT.channelIndex and arg2 ~= me and --for lfm
				string.find(arg1, '(LFM)', 1, true) then
			--[LFT]:stratlive:(LFM):name
			local mEx = string.split(arg1, ':')
			if mEx[4] == me then
				LFT.onlyAcceptFrom = arg2
				LFT.acceptNextInvite = true
			end
		end
		if event == 'CHAT_MSG_CHANNEL' and arg8 == LFT.channelIndex and string.find(arg1, 'lft_group_formed', 1, true) then
			local gfEx = string.split(arg1, ':')
			local code = gfEx[3]
			local time = tonumber(gfEx[4])
			groupsFormedThisSession = groupsFormedThisSession + 1
			if not time then
				return false
			end
			if LFT.averageWaitTime == 0 then
				LFT.averageWaitTime = time
			else
				LFT.averageWaitTime = math.floor((LFT.averageWaitTime + time) / 2)
			end
		end
		if event == 'CHAT_MSG_CHANNEL' and string.find(arg1, '[LFT]', 1, true) and arg8 == LFT.channelIndex and arg2 ~= me and --for lfg
				string.find(arg1, 'party:ready', 1, true) then
			local mEx = string.split(arg1, ':')
			LFT.groupFullCode = mEx[2] --code

			local healer = mEx[5]
			local damage1 = mEx[6]
			local damage2 = mEx[7]
			local damage3 = mEx[8]

			--check if party ready message is for me
			if me ~= healer and me ~= damage1 and me ~= damage2 and me ~= damage3 then
				return
			end

			if me == healer then
				LFT.dungeons[LFT.dungeonNameFromCode(LFT.groupFullCode)].myRole = 'healer'
				LFT.SetSingleRole(LFT.dungeons[LFT.dungeonNameFromCode(LFT.groupFullCode)].myRole)
			end
			if me == damage1 or me == damage2 or me == damage3 then
				LFT.dungeons[LFT.dungeonNameFromCode(LFT.groupFullCode)].myRole = 'damage'
				LFT.SetSingleRole(LFT.dungeons[LFT.dungeonNameFromCode(LFT.groupFullCode)].myRole)
			end

			LFT.onlyAcceptFrom = arg2
			LFT.acceptNextInvite = true

			local background = ''
			local dungeonName = 'unknown'
			for d, data in next, LFT.dungeons do
				if data.code == mEx[2] then
					background = data.background
					dungeonName = d
				end
			end

			local myRole = LFT.dungeons[LFT.dungeonNameFromCode(LFT.groupFullCode)].myRole

			_G['LFTGroupReadyBackground']:SetTexture('Interface\\FrameXML\\LFT\\images\\background\\ui-lfg-background-' .. background)
			_G['LFTGroupReadyRole']:SetTexture('Interface\\FrameXML\\LFT\\images\\' .. myRole .. '2')
			_G['LFTGroupReadyMyRole']:SetText(LFT.ucFirst(myRole))
			_G['LFTGroupReadyDungeonName']:SetText(dungeonName)

			LFT.readyStatusReset()
			_G['LFTGroupReadyObjectivesCompleted']:SetText('0/' .. LFT.tableSize(LFT.bosses[LFT.groupFullCode]) .. ' Bosses Defeated')
			_G['LFTGroupReady']:Show()
			LFTGroupReadyFrameCloser:Show()
			_G['LFTRoleCheck']:Hide()

			PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\levelup2.ogg")
			LFTQueue:Hide()

			LFT.findingGroup = false
			LFT.findingMore = false
			_G['LFTlft']:Hide()

			LFT.fixMainButton()
		end

		if event == 'CHAT_MSG_CHANNEL' and arg8 == LFT.channelIndex then
			if string.sub(arg1, 1, 4) == 'LFG:' then
				LFT.peopleLookingForGroups = LFT.peopleLookingForGroups + 1
				if LFT.peopleLookingForGroupsDisplay < LFT.peopleLookingForGroups then
					LFT.peopleLookingForGroupsDisplay = LFT.peopleLookingForGroups
				end

				local lfgEx = string.split(arg1, ' ')

				for _, lfg in lfgEx do
					local spamSplit = string.split(lfg, ':')
					local mDungeonCode = spamSplit[2]
					local mRole = spamSplit[3] --other's role
					local mLvl = tonumber(spamSplit[4]) --other's lvl
					if not mLvl then mLvl = 0 end
					
					if mDungeonCode and mRole and mLvl then
						
						if (LFTisHC() and mLvl ~= 0) or (not LFTisHC() and mLvl == 0) then
							local HC = ''
							if mLvl ~= 0 then HC = "[HC] " end

							if not LFT.browseNames[mDungeonCode] then
								LFT.browseNames[mDungeonCode] = {}
							end
							if not LFT.browseNames[mDungeonCode][mRole] then
								LFT.browseNames[mDungeonCode][mRole] = ''
							end

							if LFT.browseNames[mDungeonCode][mRole] == '' then
								LFT.browseNames[mDungeonCode][mRole] = HC..arg2
							else
								LFT.browseNames[mDungeonCode][mRole] = LFT.browseNames[mDungeonCode][mRole] .. "\n" .. HC..arg2
							end

							LFT.incDungeonssSpamRole(mDungeonCode, mRole)
							LFT.updateDungeonsSpamDisplay(mDungeonCode)
						end
					end
				end
			end
		end
		if event == 'CHAT_MSG_CHANNEL' and arg8 == LFT.channelIndex then
			if string.sub(arg1, 1, 4) == 'LFM:' then

				local lfmEx = string.split(arg1, ':')
				local mDungeonCode = lfmEx[2] or false
				local lfmTank = tonumber(lfmEx[3]) or 0
				local lfmHealer = tonumber(lfmEx[4]) or 0
				local lfmDamage = tonumber(lfmEx[5]) or 0
				local ishc = lfmEx[6] or false

				if mDungeonCode then
				
					if (LFTisHC() and ishc) or (not LFTisHC() and not ishc) then
					
						LFT.peopleLookingForGroups = LFT.peopleLookingForGroups + lfmTank + lfmHealer + lfmDamage
						if LFT.peopleLookingForGroupsDisplay < LFT.peopleLookingForGroups then
							LFT.peopleLookingForGroupsDisplay = LFT.peopleLookingForGroups
						end

						LFT.incDungeonssSpamRole(mDungeonCode, 'tank', lfmTank)
						LFT.incDungeonssSpamRole(mDungeonCode, 'healer', lfmHealer)
						LFT.incDungeonssSpamRole(mDungeonCode, 'damage', lfmDamage)
						LFT.updateDungeonsSpamDisplay(mDungeonCode, true, lfmTank + lfmHealer + lfmDamage)
					end
				end
			end
		end

		if event == 'CHAT_MSG_CHANNEL' and arg8 == LFT.channelIndex and not LFT.oneGroupFull and (LFT.findingGroup or LFT.findingMore) and arg2 ~= me then

			if string.sub(arg1, 1, 6) == 'found:' then

				local foundLongEx = string.split(arg1, ' ')

				for _, found in foundLongEx do
					if string.len(found) > 0 then
						local foundEx = string.split(found, ':')
						local mRole = foundEx[2]
						local mDungeon = foundEx[3]
						local name = foundEx[4]
						local prio = nil
						if foundEx[5] then
							if tonumber(foundEx[5]) then
								prio = tonumber(foundEx[5])
							end
						end
						
						if string.find(LFT_CONFIG['role'], mRole, 1, true) and not LFT.foundGroup and name == me then
							--if prio then
							--	if LFTGoingWithPicker.candidate == '' then
							--		LFTGoingWithPicker.candidate = arg2
							--		LFTGoingWithPicker.priority = prio
							--		LFTGoingWithPicker.dungeon = mDungeon
							--		LFTGoingWithPicker.myRole = mRole
							--		LFTGoingWithPicker:Show()
							--	else
							--		if prio > LFTGoingWithPicker.priority then
							--			LFTGoingWithPicker.candidate = arg2
							--			LFTGoingWithPicker.priority = prio
							--			LFTGoingWithPicker.dungeon = mDungeon
							--			LFTGoingWithPicker.myRole = mRole
							--		end
							--	end
							--else
							--should not get here in latest versions
							LFT.dungeons[LFT.dungeonNameFromCode(mDungeon)].myRole = mRole
							lfdebug('myRole for ' .. mDungeon .. ' set to ' .. mRole)
								SendChatMessage('goingWith:' .. arg2 .. ':' .. mDungeon .. ':' .. mRole, "CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))
							LFT.foundGroup = true
							--end
						end
					end
				end
			end

			if string.sub(arg1, 1, 10) == 'leftQueue:' then
				local leftEx = string.split(arg1, ':')
				local mRole = leftEx[2]
				LFT.removePlayerFromVirtualParty(arg2, mRole)
			end

			if string.sub(arg1, 1, 10) == 'goingWith:' and
					(string.find(LFT_CONFIG['role'], 'tank', 1, true) or LFT.isLeader) then

				local withEx = string.split(arg1, ':')
				local leader = withEx[2]
				local mDungeon = withEx[3]
				local mRole = withEx[4]

				--check if im queued for mDungeon
				for dungeon, _ in next, LFT.group do
					if dungeon == mDungeon then
						if leader ~= me then
							-- only healers and damages respond with goingwith
							LFT.remHealerOrDamage(mDungeon, arg2)
						end
					end
					-- otherwise, dont care
				end

				-- lfm, leader should invite this guy now
				if LFT.isLeader then
					lfdebug('im leader')
				else
					lfdebug('im not leader')
				end
				if LFT.isLeader and leader == me then
					if LFT.isNeededInLFMGroup(mRole, arg2, mDungeon) then
						if mRole == 'tank' then
							LFT.addTank(mDungeon, arg2, true, true)
						end
						if mRole == 'healer' then
							LFT.addHealer(mDungeon, arg2, true, true)
						end
						if mRole == 'damage' then
							LFT.addDamage(mDungeon, arg2, true, true)
						end
						LFT.inviteInLFMGroup(arg2)
					end
				end
			end

			-- LFG
			if string.sub(arg1, 1, 4) == 'LFG:' then

				local lfgEx = string.split(arg1, ' ')
				local foundMessage = ''
				local prioMembers = GetNumPartyMembers() + 1
				local prioObjectives = LFT.getDungeonCompletion()

				for _, lfg in lfgEx do
					local spamSplit = string.split(lfg, ':')
					local mDungeonCode = spamSplit[2]
					local mRole = spamSplit[3] --other's role
					local mLvl = tonumber(spamSplit[4]) --other's lvl
					if not mLvl then mLvl = 0 end
					
					if mDungeonCode and mRole and mLvl then
						
						if (LFTisHC() and mLvl ~= 0 and (UnitLevel("player")+5 >= mLvl and UnitLevel("player")-5 <= mLvl)) or (not LFTisHC() and mLvl == 0) then

							for _, data in next, LFT.dungeons do
								if data.queued and data.code == mDungeonCode then

									--LFM forming
									if LFT.isLeader then
										if mRole == 'tank' then
											if LFT.addTank(mDungeonCode, arg2) then
												foundMessage = foundMessage .. 'found:tank:' .. mDungeonCode .. ':' .. arg2 .. ':' .. prioMembers .. ':' .. prioObjectives .. ' '
											end
										end
										if mRole == 'healer' then
											if LFT.addHealer(mDungeonCode, arg2) then
												foundMessage = foundMessage .. 'found:healer:' .. mDungeonCode .. ':' .. arg2 .. ':' .. prioMembers .. ':' .. prioObjectives .. ' '
											end
										end
										if mRole == 'damage' then
											if LFT.addDamage(mDungeonCode, arg2) then
												foundMessage = foundMessage .. 'found:damage:' .. mDungeonCode .. ':' .. arg2 .. ':' .. prioMembers .. ':' .. prioObjectives .. ' '
											end
										end
										if foundMessage ~= '' then
											SendChatMessage(foundMessage, "CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))
										end
										return false
									end

									-- LFG forming
									if not LFT.inGroup then
										if string.find(LFT_CONFIG['role'], 'tank', 1, true) then
											LFT.group[mDungeonCode].tank = me

											-- if im tank looking for x and i see a different tank looking for x first
											-- then supress my next lfg:x:tank
											if mRole == 'tank' then
												LFT.supress[mDungeonCode] = 'tank'
											end

											if mRole == 'healer' then
												if LFT.addHealer(mDungeonCode, arg2, false, true) then
													foundMessage = foundMessage .. 'found:healer:' .. mDungeonCode .. ':' .. arg2 .. ':0:0 '
												end
											end
											if mRole == 'damage' then
												if LFT.addDamage(mDungeonCode, arg2, false, true) then
													foundMessage = foundMessage .. 'found:damage:' .. mDungeonCode .. ':' .. arg2 .. ':0:0 '
												end
											end
											--end

											--pseudo fill group for tooltip display
										elseif string.find(LFT_CONFIG['role'], 'healer', 1, true) then
											LFT.addHealer(mDungeonCode, me, true, true) --faux, me

											if mRole == 'tank' then
												LFT.addTank(mDungeonCode, arg2, true, true) --faux, tank
											end
											if mRole == 'damage' then
												LFT.addDamage(mDungeonCode, arg2, true, true) --faux, dps
											end
											--end

										elseif string.find(LFT_CONFIG['role'], 'damage', 1, true) then
											LFT.addDamage(mDungeonCode, me, true, true) --faux

											if mRole == 'tank' and LFT.group[mDungeonCode].tank == '' then
												LFT.addTank(mDungeonCode, arg2, true, true) --faux, tank
											end
											if mRole == 'healer' and LFT.group[mDungeonCode].healer == '' then
												LFT.addHealer(mDungeonCode, arg2, true, true) -- fause healer
											end
											if mRole == 'damage' then
												LFT.addDamage(mDungeonCode, arg2, true, true) --faux, dps
											end
										end
									end
								end
							end
						end
					end
				end
				if foundMessage ~= '' then
					SendChatMessage(foundMessage, "CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))
				end
			end
		end
	end
end)

-- debug and print functions

function lfprint(a)
	if a == nil then
		DEFAULT_CHAT_FRAME:AddMessage(COLOR_HUNTER .. '[Group Finder]|cff0070de:' .. time() .. '|cffffffff attempt to print a nil value.')
		return false
	end
	DEFAULT_CHAT_FRAME:AddMessage(COLOR_HUNTER .. "[Group Finder] |cffffffff" .. a)
end

function lfnotice(a)
	DEFAULT_CHAT_FRAME:AddMessage(COLOR_HUNTER .. "[Group Finder] " .. COLOR_ORANGE .. a)
end

function lferror(a)
	DEFAULT_CHAT_FRAME:AddMessage('|cff69ccf0[Group Finder]|cff0070de:' .. time() .. '|cffffffff[' .. a .. ']')
end

function lfdebug(a)
	if not LFT_CONFIG['debug'] then
		return false
	end
	if type(a) == 'boolean' then
		if a then
			lfprint('|cff0070de[LFTDEBUG:' .. time() .. ']|cffffffff[true]')
		else
			lfprint('|cff0070de[LFTDEBUG:' .. time() .. ']|cffffffff[false]')
		end
		return true
	end
	lfprint('|cff0070de[LFTDEBUG:' .. time() .. ']|cffffffff[' .. a .. ']')
end

local hookChatFrame = function(frame)
	lfdebug('hooking chat frame call')
	if not frame then
		lfdebug(' not frame ')
		return
	end

	LFT.gotTimeFromServer = false
	LFT.gotOnline = false
	LFT.gotUptime = false

	local original = frame.AddMessage

	if original then
		local skiphook = nil
		frame.AddMessage = function(t, message, ...)
			if skiphook then
				return original(t, message, unpack(arg))
			end

			LFT.hookExecutions = LFT.hookExecutions + 1

			if string.find(message, 'Players online:', 1, true) and
					string.find(message, 'Max online:', 1, true) and
					not LFT.gotOnline then
				local onlineNr = string.split(message, ' ')
				if tonumber(onlineNr[3]) then
					LFTWhoCounter.total = tonumber(onlineNr[3])
				end
				LFT.gotOnline = true
				return false --hide this message
			end
			if string.find(message, 'Server uptime:', 1, true) and
					not LFT.gotUptime and
					(string.find(message, 'Days', 1, true) or
							string.find(message, 'Hours', 1, true) or
							string.find(message, 'Minutes', 1, true) or
							string.find(message, 'Seconds', 1, true)) then
				LFT.gotUptime = true
				return false --hide this message
			end

			original(t, message, unpack(arg))

			if not LFT.gotTimeFromServer then
				if LFT.gotOnline and LFT.gotUptime then
					LFT.gotTimeFromServer = true
					skiphook = true
				end
			end

		end
	else
		lferror("Tried to hook non-chat frame.")
	end
	SendChatMessage('.server info')
	ToggleCharacter("PaperDollFrame")
	ToggleCharacter("PaperDollFrame")
end

LFT:SetScript("OnEvent", function()
	if event then
		if event == "VARIABLES_LOADED" then
			LFT.init()
		end
		if event == "PLAYER_TARGET_CHANGED" and LFT.inGroup then
			if _G['TargetFrame']:IsVisible() then
				if LFT.currentGroupRoles[UnitName('target')] then
					_G['LFTPartyRoleIconsTarget']:SetTexture('Interface\\FrameXML\\LFT\\images\\' .. LFT.currentGroupRoles[UnitName('target')] .. '_small')
					_G['LFTPartyRoleIconsTarget']:Show()
				end
			else
				_G['LFTPartyRoleIconsTarget']:Hide()
			end
		end
		if event == "PLAYER_ENTERING_WORLD" then
			LFT.level = UnitLevel('player')
			lfdebug('PLAYER_ENTERING_WORLD')
			hookChatFrame(ChatFrame1);
			--lfdebug(arg1)
			--lfdebug(arg2)
		end
		if event == "PARTY_LEADER_CHANGED" then

			BrowseDungeonListFrame_Update()

			if LFT.isLeader and IsPartyLeader() then
				lfdebug('end PARTY_LEADER_CHANGED - missfire ?')
				return false
			end

			LFT.isLeader = IsPartyLeader()
			if GetNumPartyMembers() + 1 == LFT.groupSizeMax then
			else
				-- only leave queue if im in queue
				if LFT.isLeader and (LFT.findingGroup or LFT.findingMore) then
					leaveQueue('party leader changed group < 5 ')
				end
			end
		end
		if event == "PARTY_MEMBERS_CHANGED" then
			--lfdebug('PARTY_MEMBERS_CHANGED') --check -- triggers in raids too
			DungeonListFrame_Update()

			if not LFT.inGroup then
				LFT.currentGroupSize = 1
			end
			lfdebug('joineed' .. GetNumPartyMembers() + 1 .. ' > ' .. LFT.currentGroupSize)
			lfdebug('left' .. GetNumPartyMembers() + 1 .. ' < ' .. LFT.currentGroupSize)

			local someoneJoined = GetNumPartyMembers() + 1 > LFT.currentGroupSize
			local someoneLeft = GetNumPartyMembers() + 1 < LFT.currentGroupSize

			LFT.currentGroupSize = GetNumPartyMembers() + 1
			LFT.inGroup = GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0

			BrowseDungeonListFrame_Update()

			if not someoneLeft and not someoneJoined then
				lfdebug('end PARTY_MEMBERS_CHANGED - missfire ?')

				if not LFT.inGroup then
					LFTDelayLeaveQueue.reason = 'i left grou --- i think'
					LFTDelayLeaveQueue:Show()
				end

				return false
			end

			if LFT.inGroup then
				if LFT.isLeader then
				else
					_G['LFTlft']:Hide()
				end
			else
				-- i left the group OR everybody left
				lfdebug('LFTInvite.inviteIndex = ' .. LFTInvite.inviteIndex)
				LFT.GetPossibleRoles()
				LFT.hidePartyRoleIcons()

				_G['LFTDungeonStatus']:Hide()
				_G['LFTRoleCheck']:Hide()

				-- i left when there was a dungeon in progress
				if LFTDungeonComplete.dungeonInProgress then
					-- todo: ban player for 5 minutes
					LFTDungeonComplete.dungeonInProgress = false
				end

				if LFTInvite.inviteIndex == 1 then
					return false
				end
				if LFT.findingGroup or LFT.findingMore then
					leaveQueue('not group and finding group/more')
				end

				return false
			end

			if someoneJoined then

				if LFT.findingMore then
					-- send him objectives
					local objectivesString = ''
					for index, _ in next, LFT.objectivesFrames do
						if LFT.objectivesFrames[index].completed then
							objectivesString = objectivesString .. '1-'
						else
							objectivesString = objectivesString .. '0-'
						end
					end
					SendAddonMessage(LFT_ADDON_CHANNEL, "objectives:" .. LFT.LFMDungeonCode .. ":" .. objectivesString, "PARTY")
					-- end send objectives
					if LFT.isLeader then

						local newName = ''
						local joinedManually = false
						for i = 1, GetNumPartyMembers() do
							local name = UnitName('party' .. i)
							local fromQueue = name == LFT.group[LFT.LFMDungeonCode].tank or
									name == LFT.group[LFT.LFMDungeonCode].healer or
									name == LFT.group[LFT.LFMDungeonCode].damage1 or
									name == LFT.group[LFT.LFMDungeonCode].damage2 or
									name == LFT.group[LFT.LFMDungeonCode].damage3

							if not fromQueue then
								newName = name
								joinedManually = true
							end
						end
						if joinedManually then
							--joined manually, dont know his role

							LFTFillAvailableDungeonsDelay.queueAfterIfPossible = GetNumPartyMembers() < (LFT.groupSizeMax - 1)

							if not LFTFillAvailableDungeonsDelay.queueAfterIfPossible then
								--group full
								SendAddonMessage(LFT_ADDON_CHANNEL, "LFMPartyReady:" .. LFT.LFMDungeonCode .. ":" .. LFTObjectives.objectivesComplete .. ":" .. LFT.tableSize(LFT.bosses[LFT.LFMDungeonCode]), "PARTY")
								return false -- so it goes into check full in timer
							end
							leaveQueue(' someone joined manually')
							findMore()
						else
							--joined from the queue, we know his role, check if group is full
							--  lfdebug('player ' .. newName .. ' joined from queue')
							if LFT.checkLFMGroupReady(LFT.LFMDungeonCode) then
								SendAddonMessage(LFT_ADDON_CHANNEL, "LFMPartyReady:" .. LFT.LFMDungeonCode .. ":" .. LFTObjectives.objectivesComplete .. ":" .. LFT.tableSize(LFT.bosses[LFT.LFMDungeonCode]), "PARTY")
							else
								SendAddonMessage(LFT_ADDON_CHANNEL, "weInQueue:" .. LFT.LFMDungeonCode, "PARTY")
							end
						end
					end

				else
					-- disable dungeon checks if i have more than one and i join a party
					for _, data in next, LFT.dungeons do
						data.queue = false
						if _G["Dungeon_" .. data.code .. '_CheckButton'] then
							_G["Dungeon_" .. data.code .. '_CheckButton']:SetChecked(false)
						end
					end
					DungeonListFrame_Update()
				end

			end
			if someoneLeft then
				LFT.showPartyRoleIcons()
				_G['LFTReadyStatus']:Hide()
				_G['LFTGroupReady']:Hide()
				-- find who left and update virtual group
				if LFT.findingMore --then
						and LFT.isLeader then

					--inc some getto code
					lfdebug('someone left')
					local leftName = ''
					local stillInParty = false
					if LFT.group[LFT.LFMDungeonCode].tank ~= '' and LFT.group[LFT.LFMDungeonCode].tank ~= me then
						leftName = LFT.group[LFT.LFMDungeonCode].tank
						stillInParty = false
						for i = 1, GetNumPartyMembers() do
							local name = UnitName('party' .. i)
							if leftName == name then
								stillInParty = true
								break
							end
						end
						if not stillInParty then
							LFT.group[LFT.LFMDungeonCode].tank = ''
							LFT.LFMGroup.tank = ''
							lfprint(leftName .. ' (' .. COLOR_TANK .. 'Tank' .. COLOR_WHITE .. ') has been removed from the queue group.')
						end
					end
					--
					if LFT.group[LFT.LFMDungeonCode].healer ~= '' and LFT.group[LFT.LFMDungeonCode].healer ~= me then
						leftName = LFT.group[LFT.LFMDungeonCode].healer
						stillInParty = false
						for i = 1, GetNumPartyMembers() do
							local name = UnitName('party' .. i)
							if leftName == name then
								stillInParty = true
								break
							end
						end
						if not stillInParty then
							LFT.group[LFT.LFMDungeonCode].healer = ''
							LFT.LFMGroup.healer = ''
							lfprint(leftName .. ' (' .. COLOR_HEALER .. 'Healer' .. COLOR_WHITE .. ') has been removed from the queue group.')
						end
					end
					--
					if LFT.group[LFT.LFMDungeonCode].damage1 ~= '' and LFT.group[LFT.LFMDungeonCode].damage1 ~= me then
						leftName = LFT.group[LFT.LFMDungeonCode].damage1
						stillInParty = false
						for i = 1, GetNumPartyMembers() do
							local name = UnitName('party' .. i)
							if leftName == name then
								stillInParty = true
								break
							end
						end
						if not stillInParty then
							LFT.group[LFT.LFMDungeonCode].damage1 = ''
							LFT.LFMGroup.damage1 = ''
							lfprint(leftName .. ' (' .. COLOR_DAMAGE .. 'Damage' .. COLOR_WHITE .. ') has been removed from the queue group.')
						end
					end
					--
					if LFT.group[LFT.LFMDungeonCode].damage2 ~= '' and LFT.group[LFT.LFMDungeonCode].damage2 ~= me then
						leftName = LFT.group[LFT.LFMDungeonCode].damage2
						stillInParty = false
						for i = 1, GetNumPartyMembers() do
							local name = UnitName('party' .. i)
							if leftName == name then
								stillInParty = true
								break
							end
						end
						if not stillInParty then
							LFT.group[LFT.LFMDungeonCode].damage2 = ''
							LFT.LFMGroup.damage2 = ''
							lfprint(leftName .. ' (' .. COLOR_DAMAGE .. 'Damage' .. COLOR_WHITE .. ') has been removed from the queue group.')
						end
					end
					--
					if LFT.group[LFT.LFMDungeonCode].damage3 ~= '' and LFT.group[LFT.LFMDungeonCode].damage3 ~= me then
						leftName = LFT.group[LFT.LFMDungeonCode].damage3
						stillInParty = false
						for i = 1, GetNumPartyMembers() do
							local name = UnitName('party' .. i)
							if leftName == name then
								stillInParty = true
								break
							end
						end
						if not stillInParty then
							LFT.group[LFT.LFMDungeonCode].damage3 = ''
							LFT.LFMGroup.damage3 = ''
							lfprint(leftName .. ' (' .. COLOR_DAMAGE .. 'Damage' .. COLOR_WHITE .. ') has been remove from the queue group.')
						end
					end
				end
			end
			--lfdebug('ajunge aici ??')
			if LFT.isLeader then
				LFT.sendMinimapDataToParty(LFT.LFMDungeonCode)
			end
			-- update awesome button enabled if 5/5 disabled + text if not
			local awesomeButton = _G['LFTGroupReadyAwesome']
			awesomeButton:SetText('Waiting Players (' .. LFT.groupSizeMax - GetNumPartyMembers() - 1 .. ')')
			awesomeButton:Disable()

			if GetNumPartyMembers() == LFT.groupSizeMax - 1 then
				awesomeButton:SetText('Let\'s do this!')
				awesomeButton:Enable()
			end
			--lfdebug(' end PARTY_MEMBERS_CHANGED')
		end
		if event == 'PLAYER_LEVEL_UP' then
			LFT.level = arg1
			LFT.fillAvailableDungeons()
		end
	end
end)

function LFT.init()

	local bmLoaded, bmReason = LoadAddOn("Blizzard_BattlefieldMinimap")

	if not BattlefieldMinimapOptions.LFT then
		BattlefieldMinimapOptions.LFT = {}
	end

	LFT_CONFIG = BattlefieldMinimapOptions.LFT

	if not LFT_CONFIG then
		LFT_CONFIG = {}
		LFT_CONFIG['debug'] = false
		LFT_CONFIG['role'] = 'damage'
		LFT_CONFIG['type'] = 1
	end

	if LFT_CONFIG['debug'] then
		_G['LFTTitleTime']:Show()
	else
		_G['LFTTitleTime']:Hide()
	end
	local _, uClass = UnitClass('player')
	LFT.class = string.lower(uClass)

	if not LFT_CONFIG['type'] then
		LFT_CONFIG['type'] = 1
	end
	-- disabled type 2, needs to reset to 1
	if LFT_CONFIG['type'] == 2 then
		LFT_CONFIG['type'] = 1
	end

	UIDropDownMenu_SetText(LFT.types[LFT_CONFIG['type']], _G['LFTTypeSelect']);

	if LFT_CONFIG['type'] == TYPE_ELITE_QUESTS then
		_G['LFTMainDungeonsText']:SetText('Elite Quests')
		_G['LFTBrowseDungeonsText']:SetText('Elite Quests')
	else
		_G['LFTMainDungeonsText']:SetText('Dungeons')
		_G['LFTBrowseDungeonsText']:SetText('Dungeons')
	end

	_G['LFTDungeonsText']:SetText(LFT.types[LFT_CONFIG['type']])
	if not LFT_CONFIG['role'] then
		LFT.SetSingleRole('tank')
		LFT.SetSingleRole(LFT.GetPossibleRoles())
	else
		LFT.GetPossibleRoles()
		LFTsetRole(LFT_CONFIG['role'])
	end

	LFT.channelIndex = 0
	LFT.level = UnitLevel('player')
	LFT.findingGroup = false
	LFT.findingMore = false
	LFT.availableDungeons = {}
	LFT.group = {}
	LFT.oneGroupFull = false
	LFT.groupFullCode = ''
	LFT.acceptNextInvite = false
	LFT.currentGroupSize = GetNumPartyMembers() + 1

	LFT.isLeader = IsPartyLeader() or false

	LFT.inGroup = GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0
	LFT.fixMainButton()

	LFT.fillAvailableDungeons()

	LFTChannelJoinDelay:Show()

	LFT.objectivesFrames = {}
	LFTDungeonComplete.dungeonInProgress = false

	_G['LFTGroupReadyAwesome']:Disable()

	--lfprint(COLOR_HUNTER .. 'Looking For Turtles v' .. addonVer .. COLOR_WHITE .. ' - LFG Addon for Turtle WoW loaded.')

	local dungeonsButton = _G['LFTBrowseButton']

	dungeonsButton:SetScript("OnEnter", function()
		_G['LFTBrowseButtonHighlight']:Show()
	end)
	dungeonsButton:SetScript("OnLeave", function()
		_G['LFTBrowseButtonHighlight']:Hide()
	end)

	local dungeonsButton = _G['LFTDungeonsButton']

	dungeonsButton:SetScript("OnEnter", function()
		_G['LFTDungeonsButtonHighlight']:Show()
	end)
	dungeonsButton:SetScript("OnLeave", function()
		_G['LFTDungeonsButtonHighlight']:Hide()
	end)

	for dungeon, data in next, LFT.dungeons do
		if not LFT.dungeonsSpam[data.code] then
			LFT.dungeonsSpam[data.code] = {
				tank = 0,
				healer = 0,
				damage = 0
			}
		end
		if not LFT.dungeonsSpamDisplay[data.code] then
			LFT.dungeonsSpamDisplay[data.code] = {
				tank = 0,
				healer = 0,
				damage = 0
			}
			LFT.dungeonsSpamDisplayLFM[data.code] = 0
		end

	end

	-- get quests
	LFT.getEliteQuests()

end

function LFT.getEliteQuests()
	local numEntries, numQuests = GetNumQuestLogEntries();

	local quests = {}
	local header = ''
	for i = 1, 20 do
		--replace with numEntries
		local title, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i)
		if isHeader then
			header = title
		else
			if isComplete and isComplete > 0 then
				-- quest is complete, hide it ?
			else
				-- quest not complete show ?
				if questTag then
					-- elite, at least, i think
					if questTag == 'Elite' then
						--lfdebug(header .. ': ' .. title .. ' ' .. questTag)
						local color = GetDifficultyColor(level) --rgb
						local code = 0
						for j = 1, string.len(title) do
							code = code + string.byte(string.sub(title, j, j))
						end
						local queued = false
						if LFT.quests[title] then
							queued = LFT.quests[title].queued
						end
						quests[title] = {
							minLevel = level, maxLevel = 60,
							code = code, queued = queued, canQueue = true,
							background = header, myRole = ''
						}

					end

				end
			end
		end
	end
	if table.getn(LFT.quests) ~= table.getn(quests) or table.getn(LFT.quests) == 0 then
		LFT.quests = quests
	end

	for quest, data in next, LFT.quests do

		if not LFT.dungeonsSpam[data.code] then
			LFT.dungeonsSpam[data.code] = {
				tank = 0,
				healer = 0,
				damage = 0
			}
		end
		if not LFT.dungeonsSpamDisplay[data.code] then
			LFT.dungeonsSpamDisplay[data.code] = {
				tank = 0,
				healer = 0,
				damage = 0
			}
			LFT.dungeonsSpamDisplayLFM[data.code] = 0
		end

	end

	--DungeonListFrame_Update()
	return LFT.quests
end

LFTQueue:SetScript("OnShow", function()
	this.startTime = GetTime()
	this.spammed = {
		tank = false,
		damage = false,
		heal = false,
		reset = false,
		lfm = false,
		checkGroupFull = false
	}
end)

LFTQueue:SetScript("OnHide", function()
	LFTMinimapAnimation:Hide()
end)

LFTQueue:SetScript("OnUpdate", function()
	local plus = 1 --seconds
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st and LFT.findingGroup then
		this.startTime = GetTime()

		if LFTTime.second == -1 then
			return false
		end

		_G['LFTTitleTime']:SetText(LFTTime.second)
		_G['LFTGroupStatusTimeInQueue']:SetText('Time in queue: ' .. SecondsToTime(time() - LFT.queueStartTime))
		if LFT.averageWaitTime == 0 then
			_G['LFTGroupStatusAverageWaitTime']:SetText('Average wait time: Unavailable')
		else
			_G['LFTGroupStatusAverageWaitTime']:SetText('Average wait time: ' .. SecondsToTimeAbbrev(LFT.averageWaitTime))
		end

		if (LFTTime.second == LFT.RESET_TIME or LFTTime.second == LFT.RESET_TIME + LFT.TIME_MARGIN) and not this.spammed.reset then
			lfdebug('reset -- call -- spam')
			this.spammed = {
				tank = false,
				damage = false,
				heal = false,
				reset = false,
				lfm = false,
				checkGroupFull = false
			}
			if not LFT.inGroup then
				LFT.resetGroup()
			end
		end

		if (LFTTime.second == LFT.RESET_TIME + 2 or LFTTime.second == LFT.RESET_TIME + 2 + LFT.TIME_MARGIN) and not this.spammed.lfm then
			if LFT.isLeader then
				LFT.sendLFMStats(LFT.LFMDungeonCode)
				this.spammed.lfm = true
			end
		end

		if (LFTTime.second == LFT.TANK_TIME + LFT.myRandomTime or LFTTime.second == LFT.TANK_TIME + LFT.TIME_MARGIN + LFT.myRandomTime) and
				string.find(LFT_CONFIG['role'], 'tank', 1, true) and not this.spammed.tank then
			this.spammed.tank = true
			if not LFT.inGroup then
				-- only start forming group if im not already grouped
				for _, data in next, LFT.dungeons do
					if data.queued then
						LFT.group[data.code].tank = me
					end
				end
				--new: but do send lfg message if im a tank, to be picked up by LFM party leader
				LFT.sendLFGMessage('tank')
			end
		end

		if (LFTTime.second == LFT.HEALER_TIME + LFT.myRandomTime or LFTTime.second == LFT.HEALER_TIME + LFT.TIME_MARGIN + LFT.myRandomTime) and
				string.find(LFT_CONFIG['role'], 'healer', 1, true) and not this.spammed.heal then
			this.spammed.heal = true
			if not LFT.inGroup then
				-- dont spam lfm if im already in a group, because leader will pick up new players
				LFT.sendLFGMessage('healer')
			end
		end

		if (LFTTime.second == LFT.DAMAGE_TIME + LFT.myRandomTime or LFTTime.second == LFT.DAMAGE_TIME + LFT.TIME_MARGIN + LFT.myRandomTime) and
				string.find(LFT_CONFIG['role'], 'damage', 1, true) and not this.spammed.damage then
			this.spammed.damage = true
			if not LFT.inGroup then
				-- dont spam lfm if im already in a group, because leader will pick up new players
				LFT.sendLFGMessage('damage')
			end
		end

		if (LFTTime.second == LFT.FULLCHECK_TIME or LFTTime.second == LFT.FULLCHECK_TIME + LFT.TIME_MARGIN) and
				string.find(LFT_CONFIG['role'], 'tank', 1, true) and not this.spammed.checkGroupFull then
			this.spammed.checkGroupFull = true
			if not LFT.inGroup then

				local groupFull, code, healer, damage1, damage2, damage3 = LFT.checkGroupFull()

				if groupFull then
					LFT.groupFullCode = code

					LFT.dungeons[LFT.dungeonNameFromCode(LFT.groupFullCode)].myRole = 'tank'

					LFT.SetSingleRole('tank')

					SendChatMessage("[LFT]:" .. code .. ":party:ready:" .. healer .. ":" ..
							damage1 .. ":" .. damage2 .. ":" .. damage3,
							"CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))

					SendChatMessage("[LFT]:lft_group_formed:" .. code .. ":" .. time() - LFT.queueStartTime,
							"CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))

					--untick everything
					for dungeon, data in next, LFT.dungeons do
						if _G["Dungeon_" .. data.code .. '_CheckButton'] then
							_G["Dungeon_" .. data.code .. '_CheckButton']:SetChecked(false)
						end
						LFT.dungeons[dungeon].queued = false
					end

					LFT.findingGroup = false
					LFT.findingMore = false

					local background = ''
					local dungeonName = 'unknown'
					for d, data in next, LFT.dungeons do
						if data.code == code then
							background = data.background
							dungeonName = d
						end
					end

					_G['LFTGroupReadyBackground']:SetTexture('Interface\\FrameXML\\LFT\\images\\background\\ui-lfg-background-' .. background)
					_G['LFTGroupReadyRole']:SetTexture('Interface\\FrameXML\\LFT\\images\\' .. LFT_CONFIG['role'] .. '2')
					_G['LFTGroupReadyMyRole']:SetText(LFT.ucFirst(LFT_CONFIG['role']))
					_G['LFTGroupReadyDungeonName']:SetText(dungeonName)
					LFT.readyStatusReset()
					_G['LFTGroupReady']:Show()
					LFTGroupReadyFrameCloser:Show()

					_G['LFTRoleCheck']:Hide()

					PlaySoundFile("Interface\\FrameXML\\LFT\\sound\\levelup2.ogg")
					LFTQueue:Hide()

					LFT.fixMainButton()
					_G['LFTlft']:Hide()
					LFTInvite:Show()
				end
			end

		end

	end
end)

function LFT.checkLFTChannel()
	--lfdebug('check LFT channel call - after 15s')
	local lastVal = 0
	local chanList = { GetChannelList() }

	for _, value in next, chanList do
		if value == LFT.channel then
			LFT.channelIndex = lastVal
			break
		end
		lastVal = value
	end

	if LFT.channelIndex == 0 then
		--lfdebug('not in chan, joining')
		JoinChannelByName(LFT.channel)
	else
		--lfdebug('in chan, chilling LFT.channelIndex = ' .. LFT.channelIndex)
	end

end

function LFT.GetPossibleRoles()

	local tankCheck = _G['RoleTank']
	local healerCheck = _G['RoleHealer']
	local damageCheck = _G['RoleDamage']

	--ready check window
	local readyCheckTank = _G['roleCheckTank']
	local readyCheckHealer = _G['roleCheckHealer']
	local readyCheckDamage = _G['roleCheckDamage']

	tankCheck:Disable()
	tankCheck:Hide()
	tankCheck:SetChecked(false)
	healerCheck:Disable()
	healerCheck:Hide()
	healerCheck:SetChecked(false)
	damageCheck:Disable()
	damageCheck:Hide()
	damageCheck:SetChecked(false)

	readyCheckTank:Disable()
	readyCheckTank:Hide()
	readyCheckTank:SetChecked(false)
	readyCheckHealer:Disable()
	readyCheckHealer:Hide()
	readyCheckHealer:SetChecked(false)
	readyCheckDamage:Disable()
	readyCheckDamage:Hide()
	readyCheckDamage:SetChecked(false)

	_G['LFTTankBackground2']:SetDesaturated(1)
	_G['LFTHealerBackground2']:SetDesaturated(1)
	_G['LFTDamageBackground2']:SetDesaturated(1)

	_G['LFTRoleCheckRoleTank']:SetDesaturated(1)
	_G['LFTRoleCheckRoleHealer']:SetDesaturated(1)
	_G['LFTRoleCheckRoleDamage']:SetDesaturated(1)

	if LFT.class == 'warrior' then

		tankCheck:Enable()
		tankCheck:Show()

		readyCheckTank:Enable()
		readyCheckTank:Show()
		readyCheckTank:SetChecked(true)

		damageCheck:Enable()
		damageCheck:Show()

		readyCheckDamage:Enable()
		readyCheckDamage:Show()
		readyCheckDamage:SetChecked(false)

		tankCheck:SetChecked(string.find(LFT_CONFIG['role'], 'tank', 1, true))
		healerCheck:SetChecked(false)
		damageCheck:SetChecked(string.find(LFT_CONFIG['role'], 'damage', 1, true))

		_G['LFTTankBackground2']:SetDesaturated(0)
		_G['LFTDamageBackground2']:SetDesaturated(0)

		_G['LFTRoleCheckRoleTank']:SetDesaturated(0)
		_G['LFTRoleCheckRoleDamage']:SetDesaturated(0)

		return 'tank'
	end
	if LFT.class == 'paladin' or LFT.class == 'druid' or LFT.class == 'shaman' then

		tankCheck:Enable()
		tankCheck:Show()

		readyCheckTank:Enable()
		readyCheckTank:Show()
		readyCheckTank:SetChecked(false)

		healerCheck:Enable()
		healerCheck:Show()

		readyCheckHealer:Enable()
		readyCheckHealer:Show()
		readyCheckHealer:SetChecked(true)

		damageCheck:Enable()
		damageCheck:Show()

		readyCheckDamage:Enable()
		readyCheckDamage:Show()
		readyCheckDamage:SetChecked(false)

		tankCheck:SetChecked(string.find(LFT_CONFIG['role'], 'tank', 1, true))
		healerCheck:SetChecked(string.find(LFT_CONFIG['role'], 'healer', 1, true))
		damageCheck:SetChecked(string.find(LFT_CONFIG['role'], 'damage', 1, true))

		_G['LFTTankBackground2']:SetDesaturated(0)
		_G['LFTHealerBackground2']:SetDesaturated(0)
		_G['LFTDamageBackground2']:SetDesaturated(0)

		_G['LFTRoleCheckRoleTank']:SetDesaturated(0)
		_G['LFTRoleCheckRoleHealer']:SetDesaturated(0)
		_G['LFTRoleCheckRoleDamage']:SetDesaturated(0)

		return 'healer'
	end
	if LFT.class == 'priest' then

		healerCheck:Enable()
		healerCheck:Show()
		readyCheckHealer:Enable()
		readyCheckHealer:Show()
		readyCheckHealer:SetChecked(true)

		damageCheck:Enable()
		damageCheck:Show()
		readyCheckDamage:Enable()
		readyCheckDamage:Show()
		readyCheckDamage:SetChecked(false)

		tankCheck:SetChecked(false)
		healerCheck:SetChecked(string.find(LFT_CONFIG['role'], 'healer', 1, true))
		damageCheck:SetChecked(string.find(LFT_CONFIG['role'], 'damage', 1, true))

		_G['LFTHealerBackground2']:SetDesaturated(0)
		_G['LFTDamageBackground2']:SetDesaturated(0)

		_G['LFTRoleCheckRoleHealer']:SetDesaturated(0)
		_G['LFTRoleCheckRoleDamage']:SetDesaturated(0)

		return 'healer'
	end
	if LFT.class == 'warlock' or LFT.class == 'hunter' or LFT.class == 'mage' or LFT.class == 'rogue' then

		damageCheck:Enable()
		damageCheck:Show()

		readyCheckDamage:Enable()
		readyCheckDamage:Show()
		readyCheckDamage:SetChecked(true)

		tankCheck:SetChecked(false)
		healerCheck:SetChecked(false)
		damageCheck:SetChecked(string.find(LFT_CONFIG['role'], 'damage', 1, true))

		_G['LFTDamageBackground2']:SetDesaturated(0)
		_G['LFTRoleCheckRoleDamage']:SetDesaturated(0)

		return 'damage'
	end

	tankCheck:SetChecked(string.find(LFT_CONFIG['role'], 'tank', 1, true))
	healerCheck:SetChecked(string.find(LFT_CONFIG['role'], 'healer', 1, true))
	damageCheck:SetChecked(string.find(LFT_CONFIG['role'], 'damage', 1, true))

	return 'damage'
end

function LFT.getAvailableDungeons(level, type, mine, partyIndex)
	if level == 0 then
		return {}
	end
	local dungeons = {}

	for _, data in next, LFT.dungeons do

		if type == TYPE_ELITE_QUESTS then
			-- elite quests
			if mine then
				dungeons[data.code] = true
			else
				-- todo fix questIndex
				--dungeons[data.code] = IsUnitOnQuest(questIndex, "party" .. partyIndex)
			end
		else

			if level >= data.minLevel and (level <= data.maxLevel or (not mine)) and type ~= 3 then
				dungeons[data.code] = true
			end
			if level >= data.minLevel and type == 3 then
				--all available
				dungeons[data.code] = true
			end

		end
	end
	return dungeons
end

function LFT.fillAvailableDungeons(queueAfter, dont_scroll)

	if LFT_CONFIG['type'] == TYPE_ELITE_QUESTS then
		LFT.dungeons = LFT.getEliteQuests()
	else
		LFT.dungeons = LFT.allDungeons
	end
	
	if LFT.level == 0 then
		LFT.level = UnitLevel('player')
	end
	
	if LFT.level >= 13 or LFT.level == 0 or LFT.level == nil then
		_G['LFTLowLevel']:Hide()
	else
		_G['LFTLowLevel']:Show()
	end

	--unqueue queued
	for dungeon, data in next, LFT.dungeons do
		LFT.dungeons[dungeon].canQueue = true
		if data.queued and LFT.level < data.minLevel then
			LFT.dungeons[dungeon].queued = false
		end
	end

	--hide all
	for _, frame in next, LFT.availableDungeons do
		_G["Dungeon_" .. frame.code]:Hide()
	end

	-- if grouped fill only dungeons that can be joined by EVERYONE
	if LFT.inGroup then

		local party = {
			[0] = {
				level = LFT.level,
				name = UnitName('player'),
				dungeons = LFT.getAvailableDungeons(LFT.level, LFT_CONFIG['type'], true)
			}
		}
		for i = 1, GetNumPartyMembers() do
			party[i] = {
				level = UnitLevel('party' .. i),
				name = UnitName('party' .. i),
				dungeons = LFT.getAvailableDungeons(UnitLevel('party' .. i), LFT_CONFIG['type'], false, i)
			}

			if party[i].level == 0 and UnitIsConnected('party' .. i) then
				LFTFillAvailableDungeonsDelay:Show()
				return false
			end
		end

		LFTFillAvailableDungeonsDelay.triggers = 0

		for dungeonCode in next, LFT.getAvailableDungeons(LFT.level, LFT_CONFIG['type'], true) do
			local canAdd = {
				[1] = UnitLevel('party1') == 0,
				[2] = UnitLevel('party2') == 0,
				[3] = UnitLevel('party3') == 0,
				[4] = UnitLevel('party4') == 0
			}

			for i = 1, GetNumPartyMembers() do
				for code in next, party[i].dungeons do
					if dungeonCode == code then
						canAdd[i] = true
					end
				end
			end
			if canAdd[1] and canAdd[2] and canAdd[3] and canAdd[4] then
			else
				LFT.dungeons[LFT.dungeonNameFromCode(dungeonCode)].canQueue = false
			end
		end
	end

	local dungeonIndex = 0
	for dungeon, data in LFT.fuckingSortAlready(LFT.dungeons) do
		--	for dungeon, data in next, LFT.dungeons do
		if LFT.level >= data.minLevel and LFT.level <= data.maxLevel and LFT_CONFIG['type'] ~= 3 then

			dungeonIndex = dungeonIndex + 1

			if not LFT.availableDungeons[data.code] then
				LFT.availableDungeons[data.code] = CreateFrame("Frame", "Dungeon_" .. data.code, _G["DungeonListScrollFrameChildren"], "LFT_DungeonItemTemplate")
			end

			LFT.availableDungeons[data.code]:Show()

			local color = COLOR_GREEN
			if LFT.level == data.minLevel or LFT.level == data.minLevel + 1 then
				color = COLOR_RED
			end
			if LFT.level == data.minLevel + 2 or LFT.level == data.minLevel + 3 then
				color = COLOR_ORANGE
			end
			if LFT.level == data.minLevel + 4 or LFT.level == data.maxLevel + 5 then
				color = COLOR_GREEN
			end

			if LFT.level > data.maxLevel then
				color = COLOR_GREEN
			end

			_G['Dungeon_' .. data.code .. '_CheckButton']:Enable()

			if data.canQueue then
				LFT.removeOnEnterTooltip(_G['Dungeon_' .. data.code .. '_Button'])
			else
				color = COLOR_DISABLED
				data.queued = false
				LFT.addOnEnterTooltip(_G['Dungeon_' .. data.code .. '_Button'], dungeon .. ' is unavailable',
						'A member of your group does not meet', 'the suggested minimum level requirement (' .. data.minLevel .. ').')
				_G['Dungeon_' .. data.code .. '_CheckButton']:Disable()
			end

			_G['Dungeon_' .. data.code .. 'Text']:SetText(color .. dungeon)
			if LFT_CONFIG['type'] == TYPE_ELITE_QUESTS then
				_G['Dungeon_' .. data.code .. 'Levels']:SetText(color .. data.background)
			else
				_G['Dungeon_' .. data.code .. 'Levels']:SetText(color .. '(' .. data.minLevel .. ' - ' .. data.maxLevel .. ')')
			end

			_G['Dungeon_' .. data.code .. '_Button']:SetID(dungeonIndex)

			LFT.availableDungeons[data.code]:SetPoint("TOPLEFT", _G["DungeonListScrollFrameChildren"], "TOPLEFT", 5, 20 - 20 * (dungeonIndex))
			LFT.availableDungeons[data.code].code = data.code
			LFT.availableDungeons[data.code].background = data.background
			LFT.availableDungeons[data.code].questIndex = data.questIndex
			LFT.availableDungeons[data.code].minLevel = data.minLevel
			LFT.availableDungeons[data.code].maxLevel = data.maxLevel

			LFT.dungeons[dungeon].queued = data.queued
			_G['Dungeon_' .. data.code .. '_CheckButton']:SetChecked(data.queued)

			if LFT_CONFIG['type'] == 2 and not LFT.inGroup then
				LFT.dungeons[dungeon].queued = true
				_G['Dungeon_' .. data.code .. '_CheckButton']:SetChecked(true)
			end

		end

		if LFT.level >= data.minLevel and LFT_CONFIG['type'] == 3 then
			--all available

			dungeonIndex = dungeonIndex + 1

			if not LFT.availableDungeons[data.code] then
				LFT.availableDungeons[data.code] = CreateFrame("Frame", "Dungeon_" .. data.code, _G["DungeonListScrollFrameChildren"], "LFT_DungeonItemTemplate")
			end

			LFT.availableDungeons[data.code]:Show()

			local color = COLOR_GREEN
			if LFT.level == data.minLevel or LFT.level == data.minLevel + 1 then
				color = COLOR_RED
			end
			if LFT.level == data.minLevel + 2 or LFT.level == data.minLevel + 3 then
				color = COLOR_ORANGE
			end
			if LFT.level == data.minLevel + 4 or LFT.level == data.maxLevel + 5 then
				color = COLOR_GREEN
			end

			if LFT.level > data.maxLevel then
				color = COLOR_GREEN
			end

			_G['Dungeon_' .. data.code .. '_CheckButton']:Enable()

			if data.canQueue then
				LFT.removeOnEnterTooltip(_G['Dungeon_' .. data.code .. '_Button'])
			else
				color = COLOR_DISABLED
				data.queued = false
				LFT.addOnEnterTooltip(_G['Dungeon_' .. data.code .. '_Button'], dungeon .. ' is unavailable',
						'A member of your group does not meet', 'the suggested minimum level requirement (' .. data.minLevel .. ').')
				_G['Dungeon_' .. data.code .. '_CheckButton']:Disable()
			end

			_G['Dungeon_' .. data.code .. 'Text']:SetText(color .. dungeon)
			_G['Dungeon_' .. data.code .. 'Levels']:SetText(color .. '(' .. data.minLevel .. ' - ' .. data.maxLevel .. ')')
			_G['Dungeon_' .. data.code .. '_Button']:SetID(dungeonIndex)

			LFT.availableDungeons[data.code]:SetPoint("TOPLEFT", _G["DungeonListScrollFrameChildren"], "TOPLEFT", 5, 20 - 20 * (dungeonIndex))
			LFT.availableDungeons[data.code].code = data.code
			LFT.availableDungeons[data.code].background = data.background
			LFT.availableDungeons[data.code].questIndex = data.questIndex
			LFT.availableDungeons[data.code].minLevel = data.minLevel
			LFT.availableDungeons[data.code].maxLevel = data.maxLevel

		end

		if LFT.findingGroup then
			if _G['Dungeon_' .. data.code .. '_CheckButton'] then
				_G['Dungeon_' .. data.code .. '_CheckButton']:Disable()
			end
		end

		if LFT.findingMore then
			if _G['Dungeon_' .. data.code .. '_CheckButton'] then
				_G['Dungeon_' .. data.code .. '_CheckButton']:Disable()
				_G['Dungeon_' .. data.code .. '_CheckButton']:SetChecked(false)
			end
			if data.code == LFT.LFMDungeonCode then
				if _G['Dungeon_' .. data.code .. '_CheckButton'] then
					_G['Dungeon_' .. data.code .. '_CheckButton']:SetChecked(true)
				end
				LFT.dungeons[dungeon].queued = true
			end
		end
		if _G['Dungeon_' .. data.code .. '_CheckButton'] then
			if _G['Dungeon_' .. data.code .. '_CheckButton']:GetChecked() then
				LFT.dungeons[dungeon].queued = true
			end
		end
	end

	-- gray out the rest if there are 5 already checked
	local queues = 0
	for _, d in next, LFT.dungeons do
		if d.queued then
			queues = queues + 1
		end
	end
	if queues >= LFT.maxDungeonsInQueue then

		for _, frame in next, LFT.availableDungeons do
			local dungeonName = LFT.dungeonNameFromCode(frame.code)
			if not LFT.dungeons[dungeonName].queued then
				_G["Dungeon_" .. frame.code .. '_CheckButton']:Disable()
				_G['Dungeon_' .. frame.code .. 'Text']:SetText(COLOR_DISABLED .. dungeonName)
				_G['Dungeon_' .. frame.code .. 'Levels']:SetText(COLOR_DISABLED .. '(' .. frame.minLevel .. ' - ' .. frame.maxLevel .. ')')

				local q = 'dungeons'
				if LFT_CONFIG['type'] == TYPE_ELITE_QUESTS then
					q = 'elite quests'
					_G['Dungeon_' .. frame.code .. 'Levels']:SetText(COLOR_DISABLED .. frame.background)
				end
				LFT.addOnEnterTooltip(_G['Dungeon_' .. frame.code .. '_Button'], 'Queueing for ' .. dungeonName .. ' is unavailable',
						'Maximum allowed queued ' .. q .. ' at a time is ' .. LFT.maxDungeonsInQueue .. '.')
			end
		end
	end
	-- end gray

	LFT.fixMainButton()

	if queueAfter then
		LFTFillAvailableDungeonsDelay.queueAfterIfPossible = false

		--find checked dungeon
		local qDungeon = ''
		local dungeonName = ''
		for _, frame in next, LFT.availableDungeons do
			if _G["Dungeon_" .. frame.code .. '_CheckButton']:GetChecked() then
				qDungeon = frame.code
			end
		end
		if qDungeon == '' then
			return false --do nothing
		end

		dungeonName = LFT.dungeonNameFromCode(qDungeon)

		if LFT.dungeons[dungeonName].canQueue then
			findMore()
		else
			lfprint('A member of your group does not meet the suggested minimum level requirement for |cff69ccf0' .. dungeonName)
		end
	end

	if dont_scroll then
		return
	end
	_G['DungeonListScrollFrame']:SetVerticalScroll(0)
	_G['DungeonListScrollFrame']:UpdateScrollChildRect()
end

function LFT.enableDungeonCheckButtons()
	for _, frame in next, LFT.availableDungeons do
		_G["Dungeon_" .. frame.code .. '_CheckButton']:Enable()
	end
	DungeonListFrame_Update()
end

function LFT.disableDungeonCheckButtons(except)
	for _, frame in next, LFT.availableDungeons do
		if except and except == frame.code then
			--dont disable
		else
			_G["Dungeon_" .. frame.code .. '_CheckButton']:Disable()
		end
	end
end

function LFT.resetGroup()
	LFT.group = {};
	if not LFT.oneGroupFull then
		LFT.groupFullCode = ''
	end
	LFT.acceptNextInvite = false
	LFT.onlyAcceptFrom = ''
	LFT.foundGroup = false

	LFT.currentGroupRoles = {}

	LFT.isLeader = IsPartyLeader()
	LFT.inGroup = GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0

	LFTGroupReadyFrameCloser.response = ''

	for dungeon, data in next, LFT.dungeons do

		LFT.dungeons[dungeon].myRole = ''

		if data.queued then
			local tank = ''
			if string.find(LFT_CONFIG['role'], 'tank', 1, true) then
				tank = me
			end
			LFT.group[data.code] = {
				tank = tank,
				healer = '',
				damage1 = '',
				damage2 = '',
				damage3 = '',
			}
		end
	end
	LFT.myRandomTime = math.random(LFT.random_min, LFT.random_max)
	LFT.LFMGroup = {
		tank = '',
		healer = '',
		damage1 = '',
		damage2 = '',
		damage3 = '',
	}
end

function LFT.addTank(dungeon, name, faux, add)

	if LFT.group[dungeon].tank == '' then
		if add then
			LFT.group[dungeon].tank = name
		end
		if not faux then
			--SendChatMessage('found:tank:' .. dungeon .. ':' .. name, "CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))
		end
		return true
	end
	return false
end

function LFT.addHealer(dungeon, name, faux, add)
	--prevent adding same person twice, added damage too, multiple roles
	if LFT.group[dungeon].healer == name or
			LFT.group[dungeon].damage1 == name or
			LFT.group[dungeon].damage2 == name or
			LFT.group[dungeon].damage3 == name then

		return false
	end

	if LFT.group[dungeon].healer == '' then
		if add then
			LFT.group[dungeon].healer = name
		end
		if not faux then
			--SendChatMessage('found:healer:' .. dungeon .. ':' .. name, "CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))
		end
		return true
	end
	return false
end

function LFT.remHealerOrDamage(dungeon, name)
	if LFT.group[dungeon].healer == name then
		LFT.group[dungeon].healer = ''
	end
	if LFT.group[dungeon].damage1 == name then
		LFT.group[dungeon].damage1 = ''
	end
	if LFT.group[dungeon].damage2 == name then
		LFT.group[dungeon].damage2 = ''
	end
	if LFT.group[dungeon].damage3 == name then
		LFT.group[dungeon].damage3 = ''
	end
end

function LFT.addDamage(dungeon, name, faux, add)

	if not LFT.group[dungeon] then
		LFT.group[dungeon] = {
			tank = '',
			healer = '',
			damage1 = '',
			damage2 = '',
			damage3 = ''
		}
	end

	--prevent adding same person twice, added tank and healer too, for 2.5+ multipleroles
	if LFT.group[dungeon].tank == name or
			LFT.group[dungeon].healer == name or
			LFT.group[dungeon].damage1 == name or
			LFT.group[dungeon].damage2 == name or
			LFT.group[dungeon].damage3 == name then
		return false
	end

	if LFT.group[dungeon].damage1 == '' then
		if add then
			LFT.group[dungeon].damage1 = name
		end
		if not faux then
			--			SendChatMessage('found:damage:' .. dungeon .. ':' .. name, "CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))
		end
		return true
	elseif LFT.group[dungeon].damage2 == '' then
		if add then
			LFT.group[dungeon].damage2 = name
		end
		if not faux then
			--			SendChatMessage('found:damage:' .. dungeon .. ':' .. name, "CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))
		end
		return true
	elseif LFT.group[dungeon].damage3 == '' then
		if add then
			LFT.group[dungeon].damage3 = name
		end
		if not faux then
			--			SendChatMessage('found:damage:' .. dungeon .. ':' .. name, "CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))
		end
		return true
	end
	return false --group full on damage
end

function LFT.checkGroupFull()

	for _, data in next, LFT.dungeons do
		if data.queued then
			local members = 0
			if LFT.group[data.code].tank ~= '' then
				members = members + 1
			end
			if LFT.group[data.code].healer ~= '' then
				members = members + 1
			end
			if LFT.group[data.code].damage1 ~= '' then
				members = members + 1
			end
			if LFT.group[data.code].damage2 ~= '' then
				members = members + 1
			end
			if LFT.group[data.code].damage3 ~= '' then
				members = members + 1
			end
			lfdebug('members = ' .. members .. ' (' .. LFT.group[data.code].tank ..
					',' .. LFT.group[data.code].healer .. ',' .. LFT.group[data.code].damage1 ..
					',' .. LFT.group[data.code].damage2 .. ',' .. LFT.group[data.code].damage3 .. ')')
			if members == LFT.groupSizeMax then
				LFT.oneGroupFull = true
				LFT.group[data.code].full = true

				return true, data.code, LFT.group[data.code].healer, LFT.group[data.code].damage1, LFT.group[data.code].damage2, LFT.group[data.code].damage3
			else
				LFT.group[data.code].full = false
				LFT.oneGroupFull = false
			end
		end
	end

	return false, false, nil, nil, nil, nil
end

function LFT.showMyRoleIcon(myRole)
	if _G['PlayerPortrait']:IsVisible() then
		_G['LFTPartyRoleIconsPlayer']:SetTexture('Interface\\FrameXML\\LFT\\images\\' .. myRole .. '_small')
		_G['LFTPartyRoleIconsPlayer']:Show()
	else
		_G['LFTPartyRoleIconsPlayer']:Hide()
	end
end

function LFT.showPartyRoleIcons(role, name)
	if not role and not name then
		for i = 1, 4 do
			if _G['PartyMemberFrame' .. i .. 'Portrait']:IsVisible() then
				if LFT.currentGroupRoles[UnitName('party' .. i)] then
					_G['LFTPartyRoleIconsParty' .. i]:SetTexture('Interface\\FrameXML\\LFT\\images\\' .. LFT.currentGroupRoles[UnitName('party' .. i)] .. '_small')
					_G['LFTPartyRoleIconsParty' .. i]:Show()
				end
			else
				_G['LFTPartyRoleIconsParty' .. i]:Hide()
			end
		end
		return true
	end
	LFT.currentGroupRoles[name] = role
	for i = 1, GetNumPartyMembers() do
		if UnitName('party' .. i) == name then
			if _G['PartyMemberFrame' .. i .. 'Portrait']:IsVisible() then
				_G['LFTPartyRoleIconsParty' .. i]:SetTexture('Interface\\FrameXML\\LFT\\images\\' .. role .. '_small')
				_G['LFTPartyRoleIconsParty' .. i]:Show()
			else
				_G['LFTPartyRoleIconsParty' .. i]:Hide()
			end
		end
	end
end

function LFT.hideMyRoleIcon()
	_G['LFTPartyRoleIconsPlayer']:Hide()
end

function LFT.hidePartyRoleIcons()
	LFT.hideMyRoleIcon()
	_G['LFTPartyRoleIconsParty1']:Hide()
	_G['LFTPartyRoleIconsParty2']:Hide()
	_G['LFTPartyRoleIconsParty3']:Hide()
	_G['LFTPartyRoleIconsParty4']:Hide()
end

function LFT.dungeonNameFromCode(code)
	for name, data in next, LFT.dungeons do
		if data.code == code then
			return name, data.background
		end
	end
	return 'Unknown', 'UnknownBackground'
end

function LFT.dungeonFromCode(code)
	for _, data in next, LFT.dungeons do
		if data.code == code then
			return data
		end
	end
	return false
end

function LFT.AcceptGroupInvite()
	AcceptGroup()
	StaticPopup_Hide("PARTY_INVITE")
	PlaySoundFile("Sound\\Doodad\\BellTollNightElf.wav")
	UIErrorsFrame:AddMessage("[Group Finder] Group Auto Accept")
end

function LFT.DeclineGroupInvite()
	DeclineGroup()
	StaticPopup_Hide("PARTY_INVITE")
end

function LFT.fuckingSortAlready(t, reverse)
	local a = {}
	for n, l in pairs(t) do
		table.insert(a, { ['code'] = l.code, ['minLevel'] = l.minLevel, ['name'] = n })
	end
	if reverse then
		table.sort(a, function(a, b)
			return a['minLevel'] > b['minLevel']
		end)
	else
		table.sort(a, function(a, b)
			return a['minLevel'] < b['minLevel']
		end)
	end

	local i = 0 -- iterator variable
	local iter = function()
		-- iterator function
		i = i + 1
		if a[i] == nil then
			return nil
			--		else return a[i]['code'], t[a[i]['name']]
		else
			return a[i]['name'], t[a[i]['name']]
		end
	end
	return iter
end

function LFT.tableSize(t)
	local size = 0
	for _, _ in next, t do
		size = size + 1
	end
	return size
end

function LFT.checkLFMgroup(someoneDeclined)

	if someoneDeclined then
		if someoneDeclined ~= me then
			lfprint(LFT.classColors[LFT.playerClass(someoneDeclined)].c .. someoneDeclined .. COLOR_WHITE .. ' declined role check.')
			lfdebug('LFTRoleCheck:Hide() in checkLFMgroup someone declined')
			LFTRoleCheck:Hide()
		end
		return false
	end

	if not LFT.isLeader then
		return
	end

	local currentGroupSize = GetNumPartyMembers() + 1
	local readyNumber = 0
	if LFT.LFMGroup.tank ~= '' then
		readyNumber = readyNumber + 1
	end
	if LFT.LFMGroup.healer ~= '' then
		readyNumber = readyNumber + 1
	end
	if LFT.LFMGroup.damage1 ~= '' then
		readyNumber = readyNumber + 1
	end
	if LFT.LFMGroup.damage2 ~= '' then
		readyNumber = readyNumber + 1
	end
	if LFT.LFMGroup.damage3 ~= '' then
		readyNumber = readyNumber + 1
	end

	if currentGroupSize == readyNumber then
		LFT.findingMore = true
		lfdebug('group ready ? ' .. currentGroupSize .. ' = ' .. readyNumber)
		--lfdebug(LFT.LFMGroup.tank)
		--lfdebug(LFT.LFMGroup.healer)
		--lfdebug(LFT.LFMGroup.damage1)
		--lfdebug(LFT.LFMGroup.damage2)
		--lfdebug(LFT.LFMGroup.damage3)
		--everyone is ready / confirmed roles

		LFT.group[LFT.LFMDungeonCode] = {
			tank = LFT.LFMGroup.tank,
			healer = LFT.LFMGroup.healer,
			damage1 = LFT.LFMGroup.damage1,
			damage2 = LFT.LFMGroup.damage2,
			damage3 = LFT.LFMGroup.damage3,
		}
		SendAddonMessage(LFT_ADDON_CHANNEL, "weInQueue:" .. LFT.LFMDungeonCode, "PARTY")
		lfdebug('LFTRoleCheck:Hide() in checkLFMGROUP we ready')
		LFTRoleCheck:Hide()
	end
end

function LFT.weInQueue(code)

	local dungeonName = LFT.dungeonNameFromCode(code)
	LFT.dungeons[dungeonName].queued = true

	lfprint('Your group is in the queue for |cff69ccf0' .. dungeonName)

	LFT.findingGroup = true
	LFT.findingMore = true
	LFT.disableDungeonCheckButtons()

	_G['RoleTank']:Disable()
	_G['RoleHealer']:Disable()
	_G['RoleDamage']:Disable()

	PlaySound('PvpEnterQueue')

	if LFT.isLeader then
		LFT.sendMinimapDataToParty(code)
	else
		LFT.group[code] = {
			tank = '',
			healer = '',
			damage1 = '',
			damage2 = '',
			damage3 = ''
		}
	end

	LFT.oneGroupFull = false
	LFT.queueStartTime = time()
	LFTQueue:Show()
	LFTMinimapAnimation:Show()
	_G['LFTlft']:Hide()
	LFT.fixMainButton()
end

function LFT.fixMainButton()

	local lfgButton = _G['findGroupButton']
	local lfmButton = _G['findMoreButton']
	local leaveQueueButton = _G['leaveQueueButton']

	lfgButton:Hide()
	lfmButton:Hide()
	leaveQueueButton:Hide()

	lfgButton:Disable()
	lfmButton:Disable()
	leaveQueueButton:Disable()

	LFT.inGroup = GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0

	local queues = 0
	for _, data in next, LFT.dungeons do
		if data.queued then
			queues = queues + 1
		end
	end

	if queues > 0 then
		lfgButton:Enable()
	end

	if LFT.inGroup then
		lfmButton:Show()
		--GetNumPartyMembers() returns party size-1, doesnt count myself
		if GetNumPartyMembers() < (LFT.groupSizeMax - 1) and LFT.isLeader and queues > 0 then
			lfmButton:Enable()
			if LFT.LFMDungeonCode ~= '' then
				LFT.disableDungeonCheckButtons(LFT.LFMDungeonCode)
			end
		end
		if GetNumPartyMembers() == (LFT.groupSizeMax - 1) and LFT.isLeader then
			--group full
			lfmButton:Disable()
			LFT.disableDungeonCheckButtons()
		end
		if not LFT.isLeader then
			lfmButton:Disable()
			LFT.disableDungeonCheckButtons()
		end
	else
		lfgButton:Show()
	end

	if LFT.findingGroup then
		leaveQueueButton:Show()
		leaveQueueButton:Enable()
		if LFT.inGroup then
			if not LFT.isLeader then
				leaveQueueButton:Disable()
			end
		end
		lfgButton:Hide()
		lfmButton:Hide()
	end

	if GetNumRaidMembers() > 0 then
		lfgButton:Disable()
		lfmButton:Disable()
		leaveQueueButton:Disable()
	end

	-- todo replace this with LFT_CONFIG['role'] == ''
	local tankCheck = _G['RoleTank']
	local healerCheck = _G['RoleHealer']
	local damageCheck = _G['RoleDamage']
	local newRole = ''
	if tankCheck:GetChecked() then
		newRole = newRole .. 'tank'
	end
	if healerCheck:GetChecked() then
		newRole = newRole .. 'healer'
	end
	if damageCheck:GetChecked() then
		newRole = newRole .. 'damage'
	end

	if newRole == '' then
		lfgButton:Disable()
		lfmButton:Disable()
	end
end

function LFT.sendCancelMeMessage()
	if string.find(LFT_CONFIG['role'], 'tank', 1, true) then
		SendChatMessage('leftQueue:tank', "CHANNEL",
				DEFAULT_CHAT_FRAME.editBox.languageID,
				GetChannelName(LFT.channel))

	end
	if string.find(LFT_CONFIG['role'], 'healer', 1, true) then
		SendChatMessage('leftQueue:healer', "CHANNEL",
				DEFAULT_CHAT_FRAME.editBox.languageID,
				GetChannelName(LFT.channel))

	end
	if string.find(LFT_CONFIG['role'], 'damage', 1, true) then
		SendChatMessage('leftQueue:damage', "CHANNEL",
				DEFAULT_CHAT_FRAME.editBox.languageID,
				GetChannelName(LFT.channel))

	end
end

function LFT.sendLFGMessage(role)

	local lfg_text = ''
	local lfg_level
	if LFTisHC() then lfg_level = UnitLevel("player") else lfg_level = 0 end
	for code, _ in pairs(LFT.group) do
		if LFT.supress[code] == role then
			LFT.supress[code] = ''
		else
			lfg_text = 'LFG:' .. code .. ':' .. role .. ':' .. lfg_level .. ' ' .. lfg_text
		end
	end
	lfg_text = string.sub(lfg_text, 1, string.len(lfg_text) - 1)

	SendChatMessage(lfg_text, "CHANNEL",
			DEFAULT_CHAT_FRAME.editBox.languageID,
			GetChannelName(LFT.channel))
end

function LFT.sendLFMStats(code)

	if code == '' then
		lfdebug('cant send lfm stats, code = blank')
		return false
	end
	if not LFT.group[code] then
		return false
	end
	local tank, healer, damage = 0, 0, 0
	if LFT.group[code].tank ~= '' then
		tank = tank + 1
	end
	if LFT.group[code].healer ~= '' then
		healer = healer + 1
	end
	if LFT.group[code].damage1 ~= '' then
		damage = damage + 1
	end
	if LFT.group[code].damage2 ~= '' then
		damage = damage + 1
	end
	if LFT.group[code].damage3 ~= '' then
		damage = damage + 1
	end
	
	SendChatMessage("LFM:" .. code .. ":" .. tank .. ":" .. healer .. ":" .. damage.. ":" ..tostring(LFTisHC()), "CHANNEL",
			DEFAULT_CHAT_FRAME.editBox.languageID,
			GetChannelName(LFT.channel))
end

function LFT.isNeededInLFMGroup(role, name, code)

	if role == 'tank' and LFT.group[code].tank == '' then
		--		LFT.group[code].tank = name
		return true
	end
	if role == 'healer' and LFT.group[code].healer == '' then
		--		LFT.group[code].healer = name
		return true
	end
	if role == 'damage' then
		if LFT.group[code].damage1 == '' then
			--			LFT.group[code].damage1 = name
			return true
		end
		if LFT.group[code].damage2 == '' then
			--			LFT.group[code].damage2 = name
			return true
		end
		if LFT.group[code].damage3 == '' then
			--			LFT.group[code].damage3 = name
			return true
		end
	end
	return false
end

function LFT.inviteInLFMGroup(name)
	SendChatMessage("[LFT]:" .. LFT.LFMDungeonCode .. ":(LFM):" .. name, "CHANNEL", DEFAULT_CHAT_FRAME.editBox.languageID, GetChannelName(LFT.channel))
	InviteByName(name)
end

function LFT.checkLFMGroupReady(code)
	if not LFT.isLeader then
		return
	end

	local members = 0

	if LFT.group[code].tank ~= '' then
		members = members + 1
	end
	if LFT.group[code].healer ~= '' then
		members = members + 1
	end
	if LFT.group[code].damage1 ~= '' then
		members = members + 1
	end
	if LFT.group[code].damage2 ~= '' then
		members = members + 1
	end
	if LFT.group[code].damage3 ~= '' then
		members = members + 1
	end

	return members == LFT.groupSizeMax
end

function LFT.sendMinimapDataToParty(code)
	lfdebug('send minimap data to party code = ' .. code)
	if code == '' then
		return false
	end
	if not LFT.group[code] then
		return false
	end
	local tank, healer, damage = 0, 0, 0
	if LFT.group[code].tank ~= '' then
		tank = tank + 1
	end
	if LFT.group[code].healer ~= '' then
		healer = healer + 1
	end
	if LFT.group[code].damage1 ~= '' then
		damage = damage + 1
	end
	if LFT.group[code].damage2 ~= '' then
		damage = damage + 1
	end
	if LFT.group[code].damage3 ~= '' then
		damage = damage + 1
	end
	SendAddonMessage(LFT_ADDON_CHANNEL, "minimap:" .. code .. ":" .. tank .. ":" .. healer .. ":" .. damage, "PARTY")
end

function LFT.addOnEnterTooltip(frame, title, text1, text2, x, y)
	frame:SetScript("OnEnter", function()
		if x and y then
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT", x, y)
		else
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -200, -5)
		end
		GameTooltip:AddLine(title)
		if text1 then
			GameTooltip:AddLine(text1, 1, 1, 1)
		end
		if text2 then
			GameTooltip:AddLine(text2, 1, 1, 1)
		end
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function LFT.removeOnEnterTooltip(frame)
	frame:SetScript("OnEnter", function()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function LFT.removePlayerFromVirtualParty(name, mRole)
	if not mRole then
		mRole = 'unknown'
	end
	for dungeonCode, data in next, LFT.group do
		if data.tank == name and (mRole == 'tank' or mRole == 'unknown') then
			LFT.group[dungeonCode].tank = ''
		end
		if data.healer == name and (mRole == 'healer' or mRole == 'unknown') then
			LFT.group[dungeonCode].healer = ''
		end
		if data.damage1 == name and (mRole == 'damage' or mRole == 'unknown') then
			LFT.group[dungeonCode].damage1 = ''
		end
		if data.damage2 == name and (mRole == 'damage' or mRole == 'unknown') then
			LFT.group[dungeonCode].damage2 = ''
		end
		if data.damage3 == name and (mRole == 'damage' or mRole == 'unknown') then
			LFT.group[dungeonCode].damage3 = ''
		end
	end
end

function LFT.deQueueAll()
	for _, data in next, LFT.dungeons do
		if data.queued then
			LFT.dungeons[data.code].queued = false
		end
	end
end

function LFT.readyStatusReset()
	_G['LFTReadyStatusReadyTank']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-waiting')
	_G['LFTReadyStatusReadyHealer']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-waiting')
	_G['LFTReadyStatusReadyDamage1']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-waiting')
	_G['LFTReadyStatusReadyDamage2']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-waiting')
	_G['LFTReadyStatusReadyDamage3']:SetTexture('Interface\\FrameXML\\LFT\\images\\readycheck-waiting')
end

function test_dung_ob(code)
	LFT.showDungeonObjectives(code)
end

function LFT.showDungeonObjectives(code, numObjectivesComplete)

	local dungeonName = LFT.dungeonNameFromCode(LFT.groupFullCode)
	if numObjectivesComplete then
		lfdebug('showdungeons obj call with numObjectivesComplete = ' .. numObjectivesComplete)
		LFTObjectives.objectivesComplete = numObjectivesComplete
	else
		lfdebug('showdungeons obj call without numObjectivesComplete')
		LFTObjectives.objectivesComplete = 0
	end

	lfdebug('LFTObjectives.objectivesComplete = ' .. LFTObjectives.objectivesComplete)

	--hideall
	for index, _ in next, LFT.objectivesFrames do
		if _G["LFTObjective" .. index] then
			_G["LFTObjective" .. index]:Hide()
		end
	end

	if LFT.dungeons[dungeonName] then
		if LFT.bosses[LFT.groupFullCode] then
			_G['LFTDungeonStatusDungeonName']:SetText(dungeonName)

			local index = 0
			for _, boss in next, LFT.bosses[LFT.groupFullCode] do
				index = index + 1
				if not LFT.objectivesFrames[index] then
					LFT.objectivesFrames[index] = CreateFrame("Frame", "LFTObjective" .. index, _G['LFTDungeonStatus'], "LFTObjectiveBossTemplate")
				end
				LFT.objectivesFrames[index]:Show()
				LFT.objectivesFrames[index].name = boss
				LFT.objectivesFrames[index].code = LFT.groupFullCode

				if LFT.objectivesFrames[index].completed == nil then
					LFT.objectivesFrames[index].completed = false
				end

				_G["LFTObjective" .. index .. 'Swoosh']:SetAlpha(0)
				_G["LFTObjective" .. index .. 'ObjectiveComplete']:Hide()
				_G["LFTObjective" .. index .. 'ObjectivePending']:Show()

				if LFT.objectivesFrames[index].completed then
					_G["LFTObjective" .. index .. 'ObjectiveComplete']:Show()
					_G["LFTObjective" .. index .. 'ObjectivePending']:Hide()
				else
					_G["LFTObjective" .. index .. 'Objective']:SetText(COLOR_DISABLED .. '0/1 ' .. boss .. ' defeated')
				end

				LFT.objectivesFrames[index]:SetPoint("TOPLEFT", _G["LFTDungeonStatus"], "TOPLEFT", 10, -110 - 20 * (index))
			end

			_G["LFTDungeonStatusCollapseButton"]:Show()
			_G["LFTDungeonStatusExpandButton"]:Hide()
			_G["LFTDungeonStatus"]:Show()
		else
			_G["LFTDungeonStatus"]:Hide()
		end
	else
		_G["LFTDungeonStatus"]:Hide()
	end
end

function LFT.getDungeonCompletion()
	local completed = 0
	local total = 0
	for index, _ in next, LFT.objectivesFrames do
		if LFT.objectivesFrames[index].completed then
			completed = completed + 1
		end
		total = total + 1
	end
	if completed == 0 then
		return 0, 0
	end
	return math.floor((completed * 100) / total), completed
end

LFT.browseNames = {}

function LFT.LFTBrowse_Update()
	--lfdebug('LFTBrowse_Update time is ' .. LFTTime.second)

	--hide all
	for _, frame in next, LFT.browseFrames do
		_G["BrowseFrame_" .. frame.code]:Hide()
	end

	local dungeonIndex = 0
	for dungeon, data in LFT.fuckingSortAlready(LFT.dungeons, true) do

		if LFT.dungeonsSpam[data.code] and LFT.level >= data.minLevel then

			if LFT.dungeonsSpamDisplay[data.code].tank > 0 or LFT.dungeonsSpamDisplay[data.code].healer > 0 or LFT.dungeonsSpamDisplay[data.code].damage > 0 then

				dungeonIndex = dungeonIndex + 1

				if not LFT.browseFrames[data.code] then
					LFT.browseFrames[data.code] = CreateFrame("Frame", "BrowseFrame_" .. data.code, _G["BrowseScrollFrameChildren"], "LFTBrowseDungeonTemplate")
				end

				_G['BrowseFrame_' .. data.code .. 'Background']:SetTexture('Interface\\FrameXML\\LFT\\images\\background\\ui-lfg-background-' .. data.background)
				_G['BrowseFrame_' .. data.code .. 'Background']:SetAlpha(0.7)

				LFT.browseFrames[data.code]:Show()

				local color = COLOR_GREEN
				if LFT.level == data.minLevel or LFT.level == data.minLevel + 1 then
					color = COLOR_RED
				end
				if LFT.level == data.minLevel + 2 or LFT.level == data.minLevel + 3 then
					color = COLOR_ORANGE
				end
				if LFT.level == data.minLevel + 4 or LFT.level == data.maxLevel + 5 then
					color = COLOR_GREEN
				end

				if LFT.level > data.maxLevel then
					color = COLOR_GREEN
				end

				_G["BrowseFrame_" .. data.code .. "DungeonName"]:SetText(color .. dungeon)
				_G["BrowseFrame_" .. data.code .. "IconLeader"]:Hide()

				if LFT.dungeonsSpamDisplayLFM[data.code] > 0 then
					_G["BrowseFrame_" .. data.code .. "DungeonName"]:SetText(color .. dungeon .. " (" .. LFT.dungeonsSpamDisplayLFM[data.code] .. "/5)")
					_G["BrowseFrame_" .. data.code .. "IconLeader"]:Show()
				end

				local tank_color = ''
				local healer_color = ''
				local damage_color = ''









				--_G["BrowseFrame_" .. data.code .. "IconTank"]:SetDesaturated(0)
				_G["BrowseFrame_" .. data.code .. "TankButtonTexture"]:SetDesaturated(0)
				if LFT.dungeonsSpamDisplay[data.code].tank == 0 then
					tank_color = COLOR_DISABLED2
					--_G["BrowseFrame_" .. data.code .. "IconTank"]:SetDesaturated(1)
					_G["BrowseFrame_" .. data.code .. "TankButtonTexture"]:SetDesaturated(1)
					LFT.removeOnEnterTooltip(_G["BrowseFrame_" .. data.code .. "TankButton"])
				else
					if LFT.browseNames[data.code] and LFT.browseNames[data.code]['tank'] then
						LFT.addOnEnterTooltip(_G["BrowseFrame_" .. data.code .. "TankButton"], COLOR_TANK .. "Tank\n" .. COLOR_WHITE .. LFT.browseNames[data.code]['tank'], nil, nil, 15, 0)
					end
				end

				--_G["BrowseFrame_" .. data.code .. "IconHealer"]:SetDesaturated(0)
				_G["BrowseFrame_" .. data.code .. "HealerButtonTexture"]:SetDesaturated(0)
				if LFT.dungeonsSpamDisplay[data.code].healer == 0 then
					healer_color = COLOR_DISABLED2
					--_G["BrowseFrame_" .. data.code .. "IconHealer"]:SetDesaturated(1)
					_G["BrowseFrame_" .. data.code .. "HealerButtonTexture"]:SetDesaturated(1)
					LFT.removeOnEnterTooltip(_G["BrowseFrame_" .. data.code .. "HealerButton"])
				else
					if LFT.browseNames[data.code] and LFT.browseNames[data.code]['healer'] then
						LFT.addOnEnterTooltip(_G["BrowseFrame_" .. data.code .. "HealerButton"], COLOR_HEALER .. "Healer\n" .. COLOR_WHITE .. LFT.browseNames[data.code]['healer'], nil, nil, 15, 0)
					end
				end

				--_G["BrowseFrame_" .. data.code .. "IconDamage"]:SetDesaturated(0)
				_G["BrowseFrame_" .. data.code .. "DamageButtonTexture"]:SetDesaturated(0)
				if LFT.dungeonsSpamDisplay[data.code].damage == 0 then
					damage_color = COLOR_DISABLED2
					--_G["BrowseFrame_" .. data.code .. "IconDamage"]:SetDesaturated(1)
					_G["BrowseFrame_" .. data.code .. "DamageButtonTexture"]:SetDesaturated(1)
					LFT.removeOnEnterTooltip(_G["BrowseFrame_" .. data.code .. "DamageButton"])
				else
					if LFT.browseNames[data.code] and LFT.browseNames[data.code]['damage'] then
						LFT.addOnEnterTooltip(_G["BrowseFrame_" .. data.code .. "DamageButton"], COLOR_DAMAGE .. "Damage\n" .. COLOR_WHITE .. LFT.browseNames[data.code]['damage'], nil, nil, 15, 0)
					end
				end

				_G["BrowseFrame_" .. data.code .. "NrTank"]:SetText(tank_color .. LFT.dungeonsSpamDisplay[data.code].tank)
				_G["BrowseFrame_" .. data.code .. "NrHealer"]:SetText(healer_color .. LFT.dungeonsSpamDisplay[data.code].healer)
				_G["BrowseFrame_" .. data.code .. "NrDamage"]:SetText(damage_color .. LFT.dungeonsSpamDisplay[data.code].damage)

				_G["BrowseFrame_" .. data.code .. "_JoinAs"]:Hide()

				if data.queued and (LFT.findingMore or LFT.findingGroup) then
					_G["BrowseFrame_" .. data.code .. "InQueue"]:Show()
				else
					_G["BrowseFrame_" .. data.code .. "InQueue"]:Hide()

					local queues = 0
					for dungeon, data in LFT.dungeons do
						if data.queued then
							queues = queues + 1
						end
					end

					if not LFT.inGroup and queues < 5 then

						if LFT.dungeonsSpamDisplay[data.code].tank == 0 and string.find(LFT_CONFIG['role'], 'tank', 1, true) then
							_G["BrowseFrame_" .. data.code .. "_JoinAs"]:SetID(1)
							_G["BrowseFrame_" .. data.code .. "_JoinAs"]:SetText('Join as Tank')
							_G["BrowseFrame_" .. data.code .. "_JoinAs"]:Show()
						elseif LFT.dungeonsSpamDisplay[data.code].healer == 0 and string.find(LFT_CONFIG['role'], 'healer', 1, true) then
							_G["BrowseFrame_" .. data.code .. "_JoinAs"]:SetID(2)
							_G["BrowseFrame_" .. data.code .. "_JoinAs"]:SetText('Join as Healer')
							_G["BrowseFrame_" .. data.code .. "_JoinAs"]:Show()
						elseif LFT.dungeonsSpamDisplay[data.code].damage < 3 and string.find(LFT_CONFIG['role'], 'damage', 1, true) then
							_G["BrowseFrame_" .. data.code .. "_JoinAs"]:SetID(3)
							_G["BrowseFrame_" .. data.code .. "_JoinAs"]:SetText('Join as Damage')
							_G["BrowseFrame_" .. data.code .. "_JoinAs"]:Show()
						end
					end
				end

				LFT.browseFrames[data.code]:SetPoint("TOPLEFT", _G["BrowseScrollFrameChildren"], "TOPLEFT", 0, 41 - 41 * (dungeonIndex))
				LFT.browseFrames[data.code].code = data.code


			end
		end
	end

	if dungeonIndex > 0 then
		_G['LFTBrowseNoPeople']:Hide()
		_G['LFTBrowseBrowseText']:SetText('Browse (' .. dungeonIndex .. ')')
		_G['LFTMainBrowseText']:SetText('Browse (' .. dungeonIndex .. ')')
	else
		_G['LFTBrowseNoPeople']:Show()
		_G['LFTBrowseBrowseText']:SetText('Browse')
		_G['LFTMainBrowseText']:SetText('Browse')
	end

	_G['BrowseDungeonListScrollFrame']:UpdateScrollChildRect()

end

-- XML called methods and public functions

function checkRoleCompatibility(role)
	if role == 'tank' and (LFT.class == 'priest' or LFT.class == 'mage' or LFT.class == 'warlock' or LFT.class == 'hunter' or LFT.class == 'rogue') then
		GameTooltip:AddLine(ROLE_BAD_TOOLTIP, 1, 0, 0);
	end
	if role == 'healer' and (LFT.class == 'warrior' or LFT.class == 'mage' or LFT.class == 'warlock' or LFT.class == 'hunter' or LFT.class == 'rogue') then
		GameTooltip:AddLine(ROLE_BAD_TOOLTIP, 1, 0, 0);
	end
end

function lft_replace(s, c, cc)
	return (string.gsub(s, c, cc))
end

function acceptRole()

	local myRole = ''
	if _G['roleCheckTank']:GetChecked() then
		myRole = 'tank'
	end
	if _G['roleCheckHealer']:GetChecked() then
		myRole = 'healer'
	end
	if _G['roleCheckDamage']:GetChecked() then
		myRole = 'damage'
	end
	LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole = myRole

	LFT.SetSingleRole(myRole)

	SendAddonMessage(LFT_ADDON_CHANNEL, "acceptRole:" .. myRole, "PARTY")
	LFT.showMyRoleIcon(myRole)
	--LFTRoleCheck:Hide()
	_G['LFTRoleCheck']:Hide()
end

function declineRole()
	local myRole = ''
	if _G['roleCheckTank']:GetChecked() then
		myRole = 'tank'
	end
	if _G['roleCheckHealer']:GetChecked() then
		myRole = 'healer'
	end
	if _G['roleCheckDamage']:GetChecked() then
		myRole = 'damage'
	end
	LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole = myRole
	local myRole = LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].myRole
	SendAddonMessage(LFT_ADDON_CHANNEL, "declineRole:" .. myRole, "PARTY")

	--LFTRoleCheck:Hide()
	_G['LFTRoleCheck']:Hide()
end

function LFT_Toggle()

	-- remove channel from every chat frame
	LFT.removeChannelFromWindows()

	if LFT.level == 0 then
		LFT.level = UnitLevel('player')
	end
	
	if LFT.level >= 13 or LFT.level == 0 or LFT.level == nil then
		_G['LFTLowLevel']:Hide()
	else
		_G['LFTLowLevel']:Show()
	end

	for dungeon, data in next, LFT.dungeons do
		if not LFT.dungeonsSpam[data.code] then
			LFT.dungeonsSpam[data.code] = { tank = 0, healer = 0, damage = 0 }
		end
		if not LFT.dungeonsSpamDisplay[data.code] then
			LFT.dungeonsSpamDisplay[data.code] = { tank = 0, healer = 0, damage = 0 }
		end
		if not LFT.dungeonsSpamDisplayLFM[data.code] then
			LFT.dungeonsSpamDisplayLFM[data.code] = 0
		end
		if not LFT.supress[data.code] then
			LFT.supress[data.code] = ''
		end
	end

	if _G['LFTlft']:IsVisible() then
		PlaySound("igCharacterInfoClose")
		_G['LFTlft']:Hide()
	else
		PlaySound("igCharacterInfoOpen")
		_G['LFTlft']:Show()

		if LFT.tab == 1 then

			LFT.checkLFTChannel()
			if not LFT.findingGroup then
				LFT.fillAvailableDungeons()
			end

			if not LFT.sentServerInfoRequest then
				hookChatFrame(ChatFrame1)
				LFT.sentServerInfoRequest = true
			end

			DungeonListFrame_Update()

		elseif LFT.tab == 2 then
			BrowseDungeonListFrame_Update()
		end
	end

end

function sayReady()
	if LFT.inGroup and GetNumPartyMembers() + 1 == LFT.groupSizeMax then
		_G['LFTGroupReady']:Hide()

		if not LFT.groupFullCode then 
			--There was an error with sayReady(), attempting to exit.
			return
		end
		
		local myRole = LFT.dungeons[LFT.dungeonNameFromCode(LFT.groupFullCode)].myRole
		SendAddonMessage(LFT_ADDON_CHANNEL, "readyAs:" .. myRole, "PARTY")
		LFT.SetSingleRole(myRole)
		LFT.GetPossibleRoles()
		LFT.showMyRoleIcon(myRole)
		LFTMinimapAnimation:Hide()
		_G['LFTReadyStatus']:Show()
		LFTGroupReadyFrameCloser.response = 'ready'
		_G['LFTGroupReadyAwesome']:Disable()
	end
end

function sayNotReady()
	if LFT.inGroup and GetNumPartyMembers() + 1 == LFT.groupSizeMax then
		_G['LFTGroupReady']:Hide()

		if not LFT.groupFullCode then 
			--There was an error with sayReady(), attempting to exit.
			return
		end
		
		local myRole = LFT.dungeons[LFT.dungeonNameFromCode(LFT.groupFullCode)].myRole
		SendAddonMessage(LFT_ADDON_CHANNEL, "notReadyAs:" .. myRole, "PARTY")
		LFT.SetSingleRole(myRole)
		LFT.GetPossibleRoles()
		LFTMinimapAnimation:Hide()
		_G['LFTReadyStatus']:Show()
		LFTGroupReadyFrameCloser.response = 'notReady'
		_G['LFTGroupReadyAwesome']:Disable()
	end
end

function LFT.SetSingleRole(role)

	_G['RoleTank']:SetChecked(role == 'tank')
	_G['roleCheckTank']:SetChecked(role == 'tank')

	_G['RoleHealer']:SetChecked(role == 'healer')
	_G['roleCheckHealer']:SetChecked(role == 'healer')

	_G['RoleDamage']:SetChecked(role == 'danage')
	_G['roleCheckDamage']:SetChecked(role == 'damage')

	LFT_CONFIG['role'] = role

end

function LFTsetRole(role, status, readyCheck)

	local tankCheck = _G['RoleTank']
	local healerCheck = _G['RoleHealer']
	local damageCheck = _G['RoleDamage']

	--ready check window
	local readyCheckTank = _G['roleCheckTank']
	local readyCheckHealer = _G['roleCheckHealer']
	local readyCheckDamage = _G['roleCheckDamage']

	if readyCheck then
		_G['LFTRoleCheckAcceptRole']:Enable()

		if not readyCheckTank:GetChecked() and
				not readyCheckHealer:GetChecked() and
				not readyCheckDamage:GetChecked() then
			_G['LFTRoleCheckAcceptRole']:Disable()
		end

		readyCheckHealer:SetChecked(role == 'healer')
		readyCheckDamage:SetChecked(role == 'damage')
		readyCheckTank:SetChecked(role == 'tank')

		LFT_CONFIG['role'] = role
		return true
	end

	local newRole = ''

	if LFT.inGroup then
		tankCheck:SetChecked(role == 'tank')
		healerCheck:SetChecked(role == 'healer')
		damageCheck:SetChecked(role == 'damage')
		newRole = role
	else
		if tankCheck:GetChecked() then
			newRole = newRole .. 'tank'
		end
		if healerCheck:GetChecked() then
			newRole = newRole .. 'healer'
		end
		if damageCheck:GetChecked() then
			newRole = newRole .. 'damage'
		end
	end

	LFT_CONFIG['role'] = newRole

	LFT.fixMainButton()
	lfdebug('newRole = ' .. newRole)
	--LFT_CONFIG['role'] = newRole
	BrowseDungeonListFrame_Update()

	---

	--if role == 'tank' then
	--	readyCheckHealer:SetChecked(false)
	--	healerCheck:SetChecked(false)
	--
	--	readyCheckDamage:SetChecked(false)
	--	damageCheck:SetChecked(false)
	--	if not status and not readyCheck then
	--		tankCheck:SetChecked(true)
	--	end
	--end
	--if role == 'healer' then
	--	readyCheckTank:SetChecked(false)
	--	tankCheck:SetChecked(false)
	--
	--	readyCheckDamage:SetChecked(false)
	--	damageCheck:SetChecked(false)
	--	if not status and not readyCheck then
	--		healerCheck:SetChecked(true)
	--	end
	--end
	--if role == 'damage' then
	--	readyCheckTank:SetChecked(false)
	--	tankCheck:SetChecked(false)
	--
	--	readyCheckHealer:SetChecked(false)
	--	healerCheck:SetChecked(false)
	--	if not status and not readyCheck then
	--		damageCheck:SetChecked(true)
	--	end
	--end
	--
	--if readyCheck then
	--	tankCheck:SetChecked(readyCheckTank:GetChecked())
	--	healerCheck:SetChecked(readyCheckHealer:GetChecked())
	--	damageCheck:SetChecked(readyCheckDamage:GetChecked())
	--else
	--	readyCheckTank:SetChecked(tankCheck:GetChecked())
	--	readyCheckHealer:SetChecked(healerCheck:GetChecked())
	--	readyCheckDamage:SetChecked(damageCheck:GetChecked())
	--end
	--LFT_CONFIG['role'] = role
	--BrowseDungeonListFrame_Update()
end

function DungeonListFrame_Update(dont_scroll)
	LFT.fillAvailableDungeons(false, dont_scroll)
end

function BrowseDungeonListFrame_Update()
	LFT.LFTBrowse_Update()
end

function DungeonType_OnLoad()
	UIDropDownMenu_Initialize(this, DungeonType_Initialize);
	UIDropDownMenu_SetWidth(160, LFTTypeSelect);
end

function DungeonType_OnClick(a)
	LFT_CONFIG['type'] = a
	UIDropDownMenu_SetText(LFT.types[LFT_CONFIG['type']], _G['LFTTypeSelect'])

	if LFT_CONFIG['type'] == TYPE_ELITE_QUESTS then
		_G['LFTMainDungeonsText']:SetText('Elite Quests')
		_G['LFTBrowseDungeonsText']:SetText('Elite Quests')
	else
		_G['LFTMainDungeonsText']:SetText('Dungeons')
		_G['LFTBrowseDungeonsText']:SetText('Dungeons')
	end

	_G['LFTDungeonsText']:SetText(LFT.types[LFT_CONFIG['type']])

	-- dequeue everything from before
	for dungeon, data in next, LFT.dungeons do
		if _G["Dungeon_" .. data.code .. '_CheckButton'] then
			_G["Dungeon_" .. data.code .. '_CheckButton']:SetChecked(false)
		end
		LFT.dungeons[dungeon].queued = false
	end

	if LFT_CONFIG['type'] == TYPE_ELITE_QUESTS then
		LFT.dungeons = LFT.getEliteQuests()
	else
		LFT.dungeons = LFT.allDungeons
	end

	-- dequeue everything after too
	for dungeon, data in next, LFT.dungeons do
		if data.queued then
			if _G["Dungeon_" .. data.code .. '_CheckButton'] then
				_G["Dungeon_" .. data.code .. '_CheckButton']:SetChecked(false)
			end
			LFT.dungeons[dungeon].queued = false
		end
	end

	for dungeon, data in next, LFT.dungeons do
		if not LFT.dungeonsSpam[data.code] then
			LFT.dungeonsSpam[data.code] = {
				tank = 0,
				healer = 0,
				damage = 0
			}
		end
		if not LFT.dungeonsSpamDisplay[data.code] then
			LFT.dungeonsSpamDisplay[data.code] = {
				tank = 0,
				healer = 0,
				damage = 0
			}
			LFT.dungeonsSpamDisplayLFM[data.code] = 0
		end

	end

	LFT.fillAvailableDungeons()
end

function DungeonType_Initialize()
	for id, type in pairs(LFT.types) do
		local info = {}
		info.text = type
		info.value = id
		info.arg1 = id
		info.checked = LFT_CONFIG['type'] == id
		info.func = DungeonType_OnClick
		if not LFT.findingGroup then
			UIDropDownMenu_AddButton(info)
		end
	end
end

function LFT_HideMinimap()
	for i, _ in LFT.minimapFrames do
		LFT.minimapFrames[i]:Hide()
	end
	_G['LFTGroupStatus']:Hide()
end

function LFT_ShowMinimap()

	if LFT.findingGroup or LFT.findingMore then
		local dungeonIndex = 0
		for dungeonCode, _ in next, LFT.group do
			local tank = 0
			local healer = 0
			local damage = 0

			if LFT.group[dungeonCode].tank ~= '' or (not LFT.inGroup and string.find(LFT_CONFIG['role'], 'tank', 1, true)) then
				tank = tank + 1
			end
			if LFT.group[dungeonCode].healer ~= '' or (not LFT.inGroup and string.find(LFT_CONFIG['role'], 'healer', 1, true)) then
				healer = healer + 1
			end
			if LFT.group[dungeonCode].damage1 ~= '' or (not LFT.inGroup and string.find(LFT_CONFIG['role'], 'damage', 1, true)) then
				damage = damage + 1
			end
			if LFT.group[dungeonCode].damage2 ~= '' then
				damage = damage + 1
			end
			if LFT.group[dungeonCode].damage3 ~= '' then
				damage = damage + 1
			end

			if not LFT.minimapFrames[dungeonCode] then
				LFT.minimapFrames[dungeonCode] = CreateFrame('Frame', "LFTMinimap_" .. dungeonCode, UIParent, "LFTMinimapDungeonTemplate")
			end

			local background = ''
			local dungeonName = 'unknown'
			for d, data2 in next, LFT.dungeons do
				if data2.code == dungeonCode then
					background = data2.background
					dungeonName = d
				end
			end

			LFT.minimapFrames[dungeonCode]:Show()
			LFT.minimapFrames[dungeonCode]:SetPoint("TOP", _G["LFTGroupStatus"], "TOP", 0, -25 - 46 * (dungeonIndex))
			_G['LFTMinimap_' .. dungeonCode .. 'Background']:SetTexture('Interface\\FrameXML\\LFT\\images\\background\\ui-lfg-background-' .. background)
			_G['LFTMinimap_' .. dungeonCode .. 'DungeonName']:SetText(dungeonName)

			--_G['LFTMinimap_' .. dungeonCode .. 'MyRole']:SetTexture('Interface\\FrameXML\\LFT\\images\\ready_' .. LFT_CONFIG['role'])
			_G['LFTMinimap_' .. dungeonCode .. 'MyRole']:Hide() -- hide for now  - dev

			if tank == 0 then
				_G['LFTMinimap_' .. dungeonCode .. 'ReadyIconTank']:SetDesaturated(1)
			end
			if healer == 0 then
				_G['LFTMinimap_' .. dungeonCode .. 'ReadyIconHealer']:SetDesaturated(1)
			end
			if damage == 0 then
				_G['LFTMinimap_' .. dungeonCode .. 'ReadyIconDamage']:SetDesaturated(1)
			end
			_G['LFTMinimap_' .. dungeonCode .. 'NrTank']:SetText(tank .. '/1')
			_G['LFTMinimap_' .. dungeonCode .. 'NrHealer']:SetText(healer .. '/1')
			_G['LFTMinimap_' .. dungeonCode .. 'NrDamage']:SetText(damage .. '/3')

			dungeonIndex = dungeonIndex + 1
		end

		_G['LFTGroupStatus']:SetHeight(dungeonIndex * 46 + 95)
		_G['LFTGroupStatusTimeInQueue']:SetText('Time in queue: ' .. SecondsToTime(time() - LFT.queueStartTime))
		if LFT.averageWaitTime == 0 then
			_G['LFTGroupStatusAverageWaitTime']:SetText('Average wait Time: Unavailable')
		else
			_G['LFTGroupStatusAverageWaitTime']:SetText('Average wait time: ' .. SecondsToTimeAbbrev(LFT.averageWaitTime))
		end

		local x, y = GetCursorPosition()

		if x < 800 and y > 300 then
			_G['LFTGroupStatus']:SetPoint("TOPLEFT", _G["LFT_Minimap"], "BOTTOMRIGHT", 0, 0)
		elseif x < 800 and y < 300 then
			_G['LFTGroupStatus']:SetPoint("TOPLEFT", _G["LFT_Minimap"], "TOPRIGHT", 0, _G['LFTGroupStatus']:GetHeight())
		elseif x > 800 and y > 300 then
			_G['LFTGroupStatus']:SetPoint("TOPLEFT", _G["LFT_Minimap"], "TOPRIGHT", -_G['LFTGroupStatus']:GetWidth() - 40, -20)
		else
			_G['LFTGroupStatus']:SetPoint("TOPLEFT", _G["LFT_Minimap"], "TOPRIGHT", -_G['LFTGroupStatus']:GetWidth() - 40, _G['LFTGroupStatus']:GetHeight())
		end

		_G['LFTGroupStatus']:Show()
	else
		GameTooltip:SetOwner(this, "ANCHOR_LEFT", 0, -110)
		GameTooltip:AddLine('Group Finder')
		GameTooltip:AddLine('Left-click to open.', 1, 1, 1)
		GameTooltip:AddLine('Hold control and drag to move.', 1, 1, 1)
		GameTooltip:AddLine('Hold control and right-click to reset position.', 1, 1, 1)
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine('You are not queued for any dungeons.', 1, 1, 1)
		if LFT.peopleLookingForGroupsDisplay == 0 then
			GameTooltip:AddLine('No players are looking for groups at the moment.', 1, 1, 1)
		elseif LFT.peopleLookingForGroupsDisplay == 1 then
			GameTooltip:AddLine(LFT.peopleLookingForGroupsDisplay .. ' player is looking for groups at the moment.', 1, 1, 1)
		else
			GameTooltip:AddLine(LFT.peopleLookingForGroupsDisplay .. ' players are looking for groups at the moment.', 1, 1, 1)
		end
		GameTooltip:Show()
	end
end

function queueForFromButton(bCode)

	local codeEx = string.split(bCode, '_')
	local qCode = codeEx[2]

	if _G['Dungeon_' .. qCode .. '_CheckButton']:IsEnabled() == 0 then
		return false
	end

	for code, data in next, LFT.availableDungeons do
		if code == qCode and not LFT.findingGroup then
			_G['Dungeon_' .. data.code .. '_CheckButton']:SetChecked(not _G['Dungeon_' .. data.code .. '_CheckButton']:GetChecked())
			queueFor(bCode, _G['Dungeon_' .. data.code .. '_CheckButton']:GetChecked())
		end
	end
end

function queueFor(name, status)

	lfdebug('queue for call ' .. name)

	local dungeonCode = ''
	local dung = string.split(name, '_')
	dungeonCode = dung[2]
	for dungeon, data in next, LFT.dungeons do
		if tonumber(dungeonCode) then
			--quests
			dungeonCode = tonumber(dungeonCode)
		end
		if dungeonCode == data.code then
			if status then
				LFT.dungeons[dungeon].queued = true
			else
				LFT.dungeons[dungeon].queued = false
			end
		end
	end

	local queues = 0
	for _, data in next, LFT.dungeons do
		if data.queued then
			queues = queues + 1
		end
	end

	lfdebug(queues .. ' queues in queuefor')

	LFT.inGroup = GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0

	lfdebug('queues: ' .. queues)
	lfdebug(LFT.inGroup)

	if LFT.inGroup then
		if queues == 1 then
			LFT.LFMDungeonCode = dungeonCode
			LFT.disableDungeonCheckButtons(dungeonCode)
		end
	else
		if queues < LFT.maxDungeonsInQueue then
			--LFT.enableDungeonCheckButtons()
		else
			for _, frame in next, LFT.availableDungeons do
				local dungeonName = LFT.dungeonNameFromCode(frame.code)
				lfdebug('dungeonName in queuefor = ' .. dungeonName)
				lfdebug('frame.code in queuefor = ' .. frame.code)
				lfdebug('frame.background in queuefor = ' .. frame.background)
				if not LFT.dungeons[dungeonName].queued then
					_G["Dungeon_" .. frame.code .. '_CheckButton']:Disable()
					_G['Dungeon_' .. frame.code .. 'Text']:SetText(COLOR_DISABLED .. dungeonName)
					_G['Dungeon_' .. frame.code .. 'Levels']:SetText(COLOR_DISABLED .. '(' .. frame.minLevel .. ' - ' .. frame.maxLevel .. ')')

					local q = 'dungeons'
					if LFT_CONFIG['type'] == TYPE_ELITE_QUESTS then
						q = 'elite quests'
						_G['Dungeon_' .. frame.code .. 'Levels']:SetText(COLOR_DISABLED .. frame.background)
					end

					LFT.addOnEnterTooltip(_G['Dungeon_' .. frame.code .. '_Button'], 'Queueing for ' .. dungeonName .. ' is unavailable',
							'Maximum allowed queued ' .. q .. ' at a time is ' .. LFT.maxDungeonsInQueue .. '.')
				end
			end
		end
	end
	DungeonListFrame_Update(true)
	LFT.fixMainButton()
end

function findMore()

	--LFTsetRole('tank', true, true)

	-- find queueing dungeon
	local qDungeon = ''
	for _, frame in next, LFT.availableDungeons do
		if _G["Dungeon_" .. frame.code .. '_CheckButton']:GetChecked() then
			qDungeon = frame.code
		end
	end

	LFT.LFMDungeonCode = qDungeon

	local tankCheck = _G['RoleTank']
	local healerCheck = _G['RoleHealer']
	local damageCheck = _G['RoleDamage']

	if tankCheck:GetChecked() then
		LFTsetRole('tank', true, true)
	elseif healerCheck:GetChecked() then
		LFTsetRole('healer', true, true)
	elseif damageCheck:GetChecked() then
		LFTsetRole('damage', true, true)
	end

	SendAddonMessage(LFT_ADDON_CHANNEL, "roleCheck:" .. qDungeon, "PARTY")

	LFT.fixMainButton()

	-- disable the button disable spam clicking it
	_G['findMoreButton']:Disable()

	BrowseDungeonListFrame_Update()
end

function joinQueue(roleID, name)

	lfdebug('join queue call ' .. name)
	lfdebug('join queue call role ' .. roleID)

	local nameEx = string.split(name, '_')
	local mCode = nameEx[2]

	--leaveQueue('from join queue')

	if _G['Dungeon_' .. mCode .. '_CheckButton'] ~= nil then
		_G['Dungeon_' .. mCode .. '_CheckButton']:SetChecked(true)
	end

	queueFor(name, true)

	findGroup()
end

function findGroup()

	LFT.resetGroup()

	_G['RoleTank']:Disable()
	_G['RoleHealer']:Disable()
	_G['RoleDamage']:Disable()

	PlaySound('PvpEnterQueue')

	local roleText = ''
	if string.find(LFT_CONFIG['role'], 'tank', 1, true) then
		roleText = roleText .. COLOR_TANK .. 'Tank'
	end
	if string.find(LFT_CONFIG['role'], 'healer', 1, true) then
		local orText = ''
		if roleText ~= '' then
			orText = COLOR_WHITE .. ', '
		end
		roleText = roleText .. orText .. COLOR_HEALER .. 'Healer'
	end
	if string.find(LFT_CONFIG['role'], 'damage', 1, true) then
		local orText = ''
		if roleText ~= '' then
			orText = COLOR_WHITE .. ', '
		end
		roleText = roleText .. orText .. COLOR_DAMAGE .. 'Damage'
	end

	--disable on click advertise for now
	--local lfg_text = ''
	local dungeonsText = ''
	for dungeon, data in next, LFT.dungeons do
		if data.queued then
			lfdebug('in find group queued for : ' .. dungeon)
			dungeonsText = dungeonsText .. dungeon .. ', '
			--lfg_text = 'LFG:' .. data.code .. ':' .. LFT_CONFIG['role'] .. ' ' .. lfg_text
		end
	end
	--lfg_text = string.sub(lfg_text, 1, string.len(lfg_text) - 1)
	--
	--if not dontAdvertise then
	--	SendChatMessage(lfg_text, "CHANNEL",
	--			DEFAULT_CHAT_FRAME.editBox.languageID,
	--			GetChannelName(LFT.channel))
	--end

	dungeonsText = string.sub(dungeonsText, 1, string.len(dungeonsText) - 2)
	lfprint('You are in the queue for |cff69ccf0' .. dungeonsText ..
			COLOR_WHITE .. ' as: ' .. roleText)

	LFT.findingGroup = true
	LFTQueue:Show()
	LFTMinimapAnimation:Show()

	LFT.disableDungeonCheckButtons()
	LFT.oneGroupFull = false
	LFT.queueStartTime = time()

	LFT.fixMainButton()

	BrowseDungeonListFrame_Update()
end

function leaveQueue(callData)

	if callData then
		lfdebug('-------- leaveQueue(' .. callData .. ')')
	else
		lfdebug('-------- leaveQueue(no-callData)')
	end
	lfdebug('_G[LFTGroupReady]:Hide()')
	_G['LFTGroupReady']:Hide()
	_G["LFTDungeonStatus"]:Hide()
	_G['LFTRoleCheck']:Hide()

	LFTGroupReadyFrameCloser:Hide()
	LFTGroupReadyFrameCloser.response = ''

	LFTQueue:Hide()
	LFTRoleCheck:Hide()
	lfdebug('LFTRoleCheck:Hide() in leaveQueue')

	LFT.hidePartyRoleIcons()
	LFT.hideMyRoleIcon()

	local dungeonsText = ''

	for dungeon, data in next, LFT.dungeons do
		if data.queued then
			--			if LFT_CONFIG['type'] == 2 then --random dungeon, dont uncheck if it comes here from the button

			-- substract 1
			--if LFT_CONFIG['role'] == 'tank' then
			--	LFT.dungeonsSpam[code].tank = LFT.dungeonsSpam[code].tank - 1
			--end
			--if LFT_CONFIG['role'] == 'healer' then
			--	LFT.dungeonsSpam[code].healer = LFT.dungeonsSpam[code].healer - 1
			--end
			--if LFT_CONFIG['role'] == 'damage' then
			--	LFT.dungeonsSpam[code].damage = LFT.dungeonsSpam[code].damage - 1
			--end

			if callData ~= 'from join queue' then
				if _G["Dungeon_" .. data.code .. '_CheckButton'] then
					_G["Dungeon_" .. data.code .. '_CheckButton']:SetChecked(false)
				end
				LFT.dungeons[dungeon].queued = false
			end
			dungeonsText = dungeonsText .. dungeon .. ', '
		end
	end

	dungeonsText = string.sub(dungeonsText, 1, string.len(dungeonsText) - 2)
	if dungeonsText == '' then
		dungeonsText = LFT.dungeonNameFromCode(LFT.LFMDungeonCode)
	end
	if LFT.findingGroup or LFT.findingMore then
		if LFT.inGroup then
			if LFT.isLeader then
				SendAddonMessage(LFT_ADDON_CHANNEL, "leaveQueue:now", "PARTY")
			end
			lfprint('Your group has left the queue for |cff69ccf0' .. dungeonsText .. COLOR_WHITE .. '.')
		else
			if callData ~= 'from join queue' then
				lfprint('You have left the queue for |cff69ccf0' .. dungeonsText .. COLOR_WHITE .. '.')
			end
		end

		LFT.sendCancelMeMessage()
		LFT.findingGroup = false
		LFT.findingMore = false
	end

	LFT.enableDungeonCheckButtons()

	LFT.GetPossibleRoles()
	--LFTsetRole(LFT_CONFIG['role'])

	if LFT.LFMDungeonCode ~= '' then
		if _G["Dungeon_" .. LFT.LFMDungeonCode .. '_CheckButton'] then
			_G["Dungeon_" .. LFT.LFMDungeonCode .. '_CheckButton']:SetChecked(true)
			LFT.dungeons[LFT.dungeonNameFromCode(LFT.LFMDungeonCode)].queued = true
		end
	end

	local tankCheck = _G['RoleTank']
	local healerCheck = _G['RoleHealer']
	local damageCheck = _G['RoleDamage']

	DungeonListFrame_Update()
	BrowseDungeonListFrame_Update()
end

function LFTObjectives.objectiveComplete(bossName, dontSendToAll)
	local code = ''
	local objectivesString = ''
	for index, _ in next, LFT.objectivesFrames do
		if LFT.objectivesFrames[index].name == bossName then
			if not LFT.objectivesFrames[index].completed then
				LFT.objectivesFrames[index].completed = true

				LFTObjectives.objectivesComplete = LFTObjectives.objectivesComplete + 1

				_G["LFTObjective" .. index .. 'ObjectiveComplete']:Show()
				_G["LFTObjective" .. index .. 'ObjectivePending']:Hide()
				_G["LFTObjective" .. index .. 'Objective']:SetText(COLOR_WHITE .. '1/1 ' .. bossName .. ' defeated')

				LFTObjectives.lastObjective = index
				LFTObjectives:Show()
				code = LFT.objectivesFrames[index].code

			else
			end
		end
		if LFT.objectivesFrames[index].completed then
			objectivesString = objectivesString .. '1-'
		else
			objectivesString = objectivesString .. '0-'
		end
	end

	if code ~= '' then
		if not dontSendToAll then
			--lfdebug("send " .. "objectives:" .. code .. ":" .. objectivesString)
			SendAddonMessage(LFT_ADDON_CHANNEL, "objectives:" .. code .. ":" .. objectivesString, "PARTY")
		end

		--dungeon complete ?
		local dungeonName, iconCode = LFT.dungeonNameFromCode(code)
		if LFTObjectives.objectivesComplete == LFT.tableSize(LFT.objectivesFrames) or
				(code == 'brdarena' and LFTObjectives.objectivesComplete == 1) then
			_G['LFTDungeonCompleteIcon']:SetTexture('Interface\\FrameXML\\LFT\\images\\icon\\lfgicon-' .. iconCode)
			_G['LFTDungeonCompleteDungeonName']:SetText(dungeonName)
			LFTDungeonComplete.dungeonInProgress = false
			LFTDungeonComplete:Show()
			LFTObjectives.closedByUser = false
		else
			LFTDungeonComplete.dungeonInProgress = true
		end
	end
end

function toggleDungeonStatus_OnClick()
	LFTObjectives.collapsed = not LFTObjectives.collapsed
	if LFTObjectives.collapsed then
		_G["LFTDungeonStatusCollapseButton"]:Hide()
		_G["LFTDungeonStatusExpandButton"]:Show()
	else
		_G["LFTDungeonStatusCollapseButton"]:Show()
		_G["LFTDungeonStatusExpandButton"]:Hide()
	end
	for index, _ in next, LFT.objectivesFrames do
		if LFTObjectives.collapsed then
			_G["LFTObjective" .. index]:Hide()
		else
			_G["LFTObjective" .. index]:Show()
		end
	end
end

function lft_switch_tab(t)
	LFT.tab = t
	PlaySound("igCharacterInfoTab");
	if t == 1 then
		_G['LFTBrowse']:Hide()
		_G['LFTMain']:Show()
	elseif t == 2 then
		_G['LFTMain']:Hide()
		_G['LFTBrowse']:Show()
	end
end

-- slash commands

SLASH_LFTDEBUG1 = "/lftdebug"
SlashCmdList["LFTDEBUG"] = function(cmd)
	if cmd then
		LFT_CONFIG['debug'] = not LFT_CONFIG['debug']
		if LFT_CONFIG['debug'] then
			lfprint('debug enabled')
			_G['LFTTitleTime']:Show()
		else
			lfprint('debug disabled')
			_G['LFTTitleTime']:Hide()
		end
	end
end
SLASH_LFG1 = "/lfg"
SlashCmdList["LFG"] = function(cmd)
	LFT_Toggle()
end

function LFT.removeChannelFromWindows()
	if LFT_CONFIG['debug'] then
		return false
	end

	for windowIndex = 1, 9 do
		local DefaultChannels = { GetChatWindowChannels(windowIndex) };
		for i, d in DefaultChannels do
			if d == LFT.channel then
				if getglobal("ChatFrame" .. windowIndex) then
					ChatFrame_RemoveChannel(getglobal("ChatFrame" .. windowIndex), LFT.channel); -- DEFAULT_CHAT_FRAME works well, too
					lfprint('LFT channel removed from window ' .. windowIndex .. ' LFT')
					lfnotice('Please do not type in the LFT channel or add it to your chat frames.')
				end
			end
		end
	end
end

function LFT.incDungeonssSpamRole(dungeon, role, nrInc)

	if not nrInc then
		nrInc = 1
	end

	if not role then
		role = LFT_CONFIG['role']
	end

	if not LFT.dungeonsSpam[dungeon] then
		--lfdebug('error in incDugeon, ' .. dungeon .. ' not init')
		return false
	end

	if role == 'tank' then
		LFT.dungeonsSpam[dungeon].tank = LFT.dungeonsSpam[dungeon].tank + nrInc
	end
	if role == 'healer' then
		LFT.dungeonsSpam[dungeon].healer = LFT.dungeonsSpam[dungeon].healer + nrInc
	end
	if role == 'damage' then
		LFT.dungeonsSpam[dungeon].damage = LFT.dungeonsSpam[dungeon].damage + nrInc
	end
end

function LFT.updateDungeonsSpamDisplay(code, lfm, numLFM)

	if not LFT.dungeonsSpam[code] then
		--lfdebug('error in updateDungeons, ' .. code .. ' not init')
		return false
	end

	if not LFT.dungeonsSpamDisplay[code] then
		lfdebug('error in updateDungeons, ' .. code .. ' not init, display')
		return false
	end

	if LFT.dungeonsSpam[code].tank ~= 0 then
		LFT.dungeonsSpamDisplay[code].tank = LFT.dungeonsSpam[code].tank
	end

	if LFT.dungeonsSpam[code].healer ~= 0 then
		LFT.dungeonsSpamDisplay[code].healer = LFT.dungeonsSpam[code].healer
	end

	if LFT.dungeonsSpam[code].damage ~= 0 then
		LFT.dungeonsSpamDisplay[code].damage = LFT.dungeonsSpam[code].damage
	end

	if lfm then
		if LFT.dungeonsSpamDisplayLFM[code] == 0 then
			LFT.dungeonsSpamDisplayLFM[code] = numLFM
		else
			if numLFM > LFT.dungeonsSpamDisplayLFM[code] then
				LFT.dungeonsSpamDisplayLFM[code] = numLFM
			end
		end
	end

end

-- dungeons

LFT.dungeons = {}

LFT.allDungeons = {
	['Ragefire Chasm'] = { minLevel = 13, maxLevel = 18, code = 'rfc', queued = false, canQueue = true, background = 'ragefirechasm', myRole = '' },
	['Wailing Caverns'] = { minLevel = 17, maxLevel = 24, code = 'wc', queued = false, canQueue = true, background = 'wailingcaverns', myRole = '' },
	['The Deadmines'] = { minLevel = 17, maxLevel = 24, code = 'dm', queued = false, canQueue = true, background = 'deadmines', myRole = '' },
	['Shadowfang Keep'] = { minLevel = 22, maxLevel = 30, code = 'sfk', queued = false, canQueue = true, background = 'shadowfangkeep', myRole = '' },
	['The Stockade'] = { minLevel = 22, maxLevel = 30, code = 'stocks', queued = false, canQueue = true, background = 'stormwindstockades', myRole = '' },
	['Blackfathom Deeps'] = { minLevel = 23, maxLevel = 32, code = 'bfd', queued = false, canQueue = true, background = 'blackfathomdeeps', myRole = '' },
	['Scarlet Monastery Graveyard'] = { minLevel = 27, maxLevel = 36, code = 'smgy', queued = false, canQueue = true, background = 'scarletmonastery', myRole = '' },
	['Scarlet Monastery Library'] = { minLevel = 28, maxLevel = 39, code = 'smlib', queued = false, canQueue = true, background = 'scarletmonastery', myRole = '' },
	['Gnomeregan'] = { minLevel = 29, maxLevel = 38, code = 'gnomer', queued = false, canQueue = true, background = 'gnomeregan', myRole = '' },
	['Razorfen Kraul'] = { minLevel = 29, maxLevel = 38, code = 'rfk', queued = false, canQueue = true, background = 'razorfenkraul', myRole = '' },

	['The Crescent Grove'] = { minLevel = 32, maxLevel = 38, code = 'tcg', queued = false, canQueue = true, background = 'tcg', myRole = '' },

	['Scarlet Monastery Armory'] = { minLevel = 32, maxLevel = 41, code = 'smarmory', queued = false, canQueue = true, background = 'scarletmonastery', myRole = '' },
	['Scarlet Monastery Cathedral'] = { minLevel = 35, maxLevel = 45, code = 'smcath', queued = false, canQueue = true, background = 'scarletmonastery', myRole = '' },
	['Razorfen Downs'] = { minLevel = 36, maxLevel = 46, code = 'rfd', queued = false, canQueue = true, background = 'razorfendowns', myRole = '' },
	['Uldaman'] = { minLevel = 40, maxLevel = 51, code = 'ulda', queued = false, canQueue = true, background = 'uldaman', myRole = '' },
	['Gilneas City'] = { minLevel = 42, maxLevel = 50, code = 'gilneas', queued = false, canQueue = true, background = 'gilneas', myRole = '' },
	['Zul\'Farrak'] = { minLevel = 44, maxLevel = 54, code = 'zf', queued = false, canQueue = true, background = 'zulfarak', myRole = '' },
	['Maraudon Orange'] = { minLevel = 47, maxLevel = 55, code = 'maraorange', queued = false, canQueue = true, background = 'maraudon', myRole = '' },
	['Maraudon Purple'] = { minLevel = 45, maxLevel = 55, code = 'marapurple', queued = false, canQueue = true, background = 'maraudon', myRole = '' },
	['Maraudon Princess'] = { minLevel = 47, maxLevel = 55, code = 'maraprincess', queued = false, canQueue = true, background = 'maraudon', myRole = '' },
	['Temple of Atal\'Hakkar'] = { minLevel = 50, maxLevel = 60, code = 'st', queued = false, canQueue = true, background = 'sunkentemple', myRole = '' },
	['Hateforge Quarry'] = { minLevel = 50, maxLevel = 60, code = 'hfq', queued = false, canQueue = true, background = 'hfq', myRole = '' },
	['Blackrock Depths'] = { minLevel = 52, maxLevel = 60, code = 'brd', queued = false, canQueue = true, background = 'blackrockdepths', myRole = '' },
	['Blackrock Depths Arena'] = { minLevel = 52, maxLevel = 60, code = 'brdarena', queued = false, canQueue = true, background = 'blackrockdepths', myRole = '' },
	['Blackrock Depths Emperor'] = { minLevel = 54, maxLevel = 60, code = 'brdemp', queued = false, canQueue = true, background = 'blackrockdepths', myRole = '' },
	['Lower Blackrock Spire'] = { minLevel = 55, maxLevel = 60, code = 'lbrs', queued = false, canQueue = true, background = 'blackrockspire', myRole = '' },
	['Dire Maul East'] = { minLevel = 55, maxLevel = 60, code = 'dme', queued = false, canQueue = true, background = 'diremaul', myRole = '' },
	['Dire Maul North'] = { minLevel = 57, maxLevel = 60, code = 'dmn', queued = false, canQueue = true, background = 'diremaul', myRole = '' },
	['Dire Maul Tribute'] = { minLevel = 57, maxLevel = 60, code = 'dmt', queued = false, canQueue = true, background = 'diremaul', myRole = '' },
	['Dire Maul West'] = { minLevel = 57, maxLevel = 60, code = 'dmw', queued = false, canQueue = true, background = 'diremaul', myRole = '' },
	['Scholomance'] = { minLevel = 58, maxLevel = 60, code = 'scholo', queued = false, canQueue = true, background = 'scholomance', myRole = '' },
	['Stratholme: Undead District'] = { minLevel = 58, maxLevel = 60, code = 'stratud', queued = false, canQueue = true, background = 'stratholme', myRole = '' },
	['Stratholme: Scarlet Bastion'] = { minLevel = 58, maxLevel = 60, code = 'stratlive', queued = false, canQueue = true, background = 'stratholme', myRole = '' },
	['Karazhan Crypt'] = { minLevel = 58, maxLevel = 60, code = 'kc', queued = false, canQueue = true, background = 'kc', myRole = '' },
	['Caverns of Time: Black Morass'] = { minLevel = 60, maxLevel = 60, code = 'cotbm', queued = false, canQueue = true, background = 'cotbm', myRole = '' },
	['Stormwind Vault'] = { minLevel = 60, maxLevel = 60, code = 'swv', queued = false, canQueue = true, background = 'swv', myRole = '' },


	--['GM Test'] = { minLevel = 1, maxLevel = 60, code = 'gmtest', queued = false, canQueue = true, background = 'stratholme', myRole = '' },
}

LFT.bosses = {
	['gmtest'] = { --dev only
		'Duros',
		'Draka',
	},
	['rfc'] = {
		'Oggleflint',
		'Taragaman the Hungerer',
		'Jergosh the Invoker',
		'Bazzalan'
	},
	['wc'] = {
		'Lord Cobrahn',
		'Lady Anacondra',
		'Kresh',
		'Lord Pythas',
		'Skum',
		'Lord Serpentis',
		'Verdan the Everliving',
		'Mutanus the Devourer',
	},
	['dm'] = {
		'Rhahk\'zor',
		'Sneed',
		'Gilnid',
		'Mr. Smite',
		'Cookie',
		'Captain Greenskin',
		'Edwin VanCleef',
	},
	['sfk'] = {
		'Rethilgore',
		'Razorclaw the Butcher',
		'Baron Silverlaine',
		'Commander Springvale',
		'Odo the Blindwatcher',
		'Fenrus the Devourer',
		'Wolf Master Nandos',
		'Archmage Arugal',
	},
	['bfd'] = {
		'Ghamoo-ra',
		'Lady Sarevess',
		'Gelihast',
		'Lorgus Jett',
		'Baron Aquanis',
		'Twilight Lord Kelris',
		'Old Serra\'kis',
		'Aku\'mai',
	},
	['stocks'] = {
		'Targorr the Dread',
		'Kam Deepfury',
		'Hamhock',
		'Bazil Thredd',
		'Dextren Ward',
	},
	['gnomer'] = {
		'Grubbis',
		'Viscous Fallout',
		'Electrocutioner 6000',
		'Crowd Pummeler 9-60',
		'Mekgineer Thermaplugg',
	},
	['rfk'] = {
		'Roogug',
		'Aggem Thorncurse',
		'Death Speaker Jargba',
		'Overlord Ramtusk',
		'Agathelos the Raging',
		'Charlga Razorflank',
	},
	['smgy'] = {
		'Interrogator Vishas',
		'Bloodmage Thalnos',
	},
	['smarmory'] = {
		'Herod'
	},
	['smcath'] = {
		'High Inquisitor Fairbanks',
		'Scarlet Commander Mograine',
		'High Inquisitor Whitemane'
	},
	['smlib'] = {
		'Houndmaster Loksey',
		'Arcanist Doan'
	},
	['rfd'] = {
		'Tuten\'kash',
		'Mordresh Fire Eye',
		'Glutton',
		'Ragglesnout',
		'Amnennar the Coldbringer',
	},
	['ulda'] = {
		'Revelosh',
		'Ironaya',
		'Obsidian Sentinel',
		'Ancient Stone Keeper',
		'Galgann Firehammer',
		'Grimlok',
		'Archaedas',
	},
	['gilneas'] = {
		'Matthias Holtz',
		'Judge Sutherland',
		'Dustivan Blackcowl',
		'Marshal Magnus Greystone',
		'Celia Harlow',
		'Mortimer Harlow',
		'Genn Greymane',
	},
	['zf'] = {
		'Antu\'sul',
		'Theka the Martyr',
		'Witch Doctor Zum\'rah',
		'Sandfury Executioner',
		'Nekrum Gutchewer',
		'Shadowpriest Sezz\'ziz',
		'Sergeant Bly',
		'Hydromancer Velratha',
		'Ruuzlu',
		'Chief Ukorz Sandscalp',
	},
	['maraorange'] = {
		'Noxxion',
		'Razorlash',
	},
	['marapurple'] = {
		'Lord Vyletongue',
		'Celebras the Cursed',
	},
	['maraprincess'] = {
		'Tinkerer Gizlock',
		'Landslide',
		'Rotgrip',
		'Princess Theradras',
	},
	['st'] = {
		'Jammal\'an the Prophet',
		'Ogom the Wretched',
		'Dreamscythe',
		'Weaver',
		'Morphaz',
		'Hazzas',
		'Shade of Eranikus',
		'Atal\'alarion',
	},
	['brd'] = {
		'Lord Roccor',
		'Bael\'Gar',
		'High Interrogator Gerstahn',
		'Houndmaster Grebmar',

		'Pyromancer Loregrain',
		'Fineous Darkvire',

		'General Angerforge',
		'Golem Lord Argelmach',

		'Lord Incendius',

		'Hurley Blackbreath',
		'Plugger Spazzring',
		'Ribbly Screwspigot',
		'Phalanx',

		'Warder Stilgiss',

		'Watchman Doomgrip',
		'Verek',

		'Ambassador Flamelash',
		'Magmus',
		'Emperor Dagran Thaurissan',
	},
	['brdemp'] = {
		'General Angerforge',
		'Golem Lord Argelmach',
		'Emperor Dagran Thaurissan',
		'Magmus',
		'Ambassador Flamelash',
	},
	['brdarena'] = {
		'Anub\'shiah-s', --summoned
		'Eviscerator-s', --summoned
		'Gorosh the Dervish-s', --summoned
		'Grizzle-s', --summoned
		'Hedrum the Creeper-s', --summoned
		'Ok\'thor the Breaker-s', --summoned
	},
	['lbrs'] = {
		'Highlord Omokk',
		'Shadow Hunter Vosh\'gajin',
		'War Master Voone',
		'Mother Smolderweb',
		'Quartermaster Zigris',
		'Halycon',
		'Gizrul the Slavener',
		'Overlord Wyrmthalak',
	},
	['ubrs'] = {
		'Pyroguard Emberseer',
		'Warchief Rend Blackhand',
		'The Beast',
		'General Drakkisath',
	},
	['dme'] = {
		'Pusilin',
		'Zevrim Thornhoof',
		'Hydrospawn',
		'Lethtendris',
		'Alzzin the Wildshaper',
	},
	['dmn'] = {
		'Guard Mol\'dar',
		'Stomper Kreeg',
		'Guard Fengus',
		'Guard Slip\'kik',
		'Captain Kromcrush',
		'King Gordok',
	},
	['dmt'] = {
		'King Gordok',
	},
	['dmw'] = {
		'Tendris Warpwood',
		'Illyanna Ravenoak',
		'Magister Kalendris',
		'Immol\'thar',
		'Prince Tortheldrin',
	},
	['scholo'] = {
		'Jandice Barov',
		'Rattlegore',
		'Ras Frostwhisper',
		'Instructor Malicia',
		'Doctor Theolen Krastinov',
		'Lorekeeper Polkelt',
		'The Ravenian',
		'Lord Alexei Barov',
		'Lady Illucia Barov',
		'Darkmaster Gandling',
	},
	['stratlive'] = {
		'The Unforgiven',
		'Timmy the Cruel',
		'Malor the Zealous',
		'Cannon Master Willey',
		'Archivist Galford',
		'Balnazzar',
	},
	['stratud'] = {
		'Nerub\'enkan',
		'Baroness Anastari',
		'Maleki the Pallid',
		'Magistrate Barthilas',
		'Ramstein the Gorger',
		'Baron Rivendare',
	},
	['cotbm'] = {
		'Chronar',
		'Time-Lord Epochronos',
		'Antnormi'
	},
	['kc'] = {
		'Marrowspike',
		'Hivaxxis',
		'Corpsemuncher',
		'Archlich Enkhraz',
		'Alarus'
	},
	['swv'] = {
		'Aszosh Grimflame',
		'Tham\'Grarr',
		'Black Bride',
		'Damian',
		'Volkan Cruelblade',
		'Arc\'tiras'
	},
	['tcg'] = {
		'Grovetender Engryss',
		'Keeper Ranathos',
		'High Priestess A\'lathea',
		'Fenektis the Deceiver',
		'Master Raxxieth'
	},
	['hfq'] = {
		'High Foreman Bargul Blackhammer',
		'Engineer Figgles',
		'Corrosis',
		'Hatereaver Annihilator',
		'Har\'gesh Doomcaller'
	},
};

-- utils

function LFT.playerClass(name)
	if name == me then
		local _, unitClass = UnitClass('player')
		return string.lower(unitClass)
	end
	for i = 1, GetNumPartyMembers() do
		if UnitName('party' .. i) then
			if name == UnitName('party' .. i) then
				local _, unitClass = UnitClass('party' .. i)
				return string.lower(unitClass)
			end
		end
	end
	return 'priest'
end

function LFT.ver(ver)
	return tonumber(string.sub(ver, 1, 1)) * 1000 +
			tonumber(string.sub(ver, 3, 3)) * 100 +
			tonumber(string.sub(ver, 5, 5)) * 10 +
			tonumber(string.sub(ver, 7, 7)) * 1
end

function LFT.ucFirst(a)
	return string.upper(string.sub(a, 1, 1)) .. string.lower(string.sub(a, 2, string.len(a)))
end

function string:split(delimiter)
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(self, delimiter, from)
	while delim_from do
		table.insert(result, string.sub(self, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(self, delimiter, from)
	end
	table.insert(result, string.sub(self, from))
	return result
end