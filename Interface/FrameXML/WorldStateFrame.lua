NUM_ALWAYS_UP_UI_FRAMES = 0;
NUM_EXTENDED_UI_FRAMES = 0;
MAX_WORLDSTATE_SCORE_BUTTONS = 22;
MAX_NUM_STAT_COLUMNS = 7;
WORLDSTATESCOREFRAME_BASE_WIDTH = 530;
WORLDSTATESCOREFRAME_COLUMN_SPACING = 77;
WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET = -32;

ExtendedUI = {};

local inArena = false

-- Always up stuff (i.e. capture the flag indicators)
function WorldStateAlwaysUpFrame_OnLoad()
	this:RegisterEvent("UPDATE_WORLD_STATES");
	SHOW_BATTLEFIELD_MINIMAP = "0";
	RegisterForSave("SHOW_BATTLEFIELD_MINIMAP");
	WorldStateAlwaysUpFrame_Update();
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function WorldStateAlwaysUpFrame_OnEvent()
	if ( event == "UPDATE_WORLD_STATES" ) then
		WorldStateAlwaysUpFrame_Update();
		WorldStateFrame_ToggleMinimap();	
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		WorldStateFrame_ToggleMinimap();
	end
end

function WorldStateAlwaysUpFrame_Update()
	local numUI = GetNumWorldStateUI();
	local name, frame, frameText, frameDynamicIcon, frameIcon, frameFlash, flashTexture, frameDynamicButton, relative;
	local extendedUI, extendedUIState1, extendedUIState2, extendedUIState3, uiInfo; 
	local text, icon, state, dynamicIcon, tooltip, dynamicTooltip, flash;
	local inInstance, instanceType = IsInInstance();
	local alwaysUpShown = 1;
	local extendedUIShown = 1;
	if ( HIDE_OUTDOOR_WORLD_STATE == "0" or instanceType == "pvp" ) then
		for i=1, numUI do
			state, text, icon, dynamicIcon, tooltip, dynamicTooltip, extendedUI, extendedUIState1, extendedUIState2, extendedUIState3 = GetWorldStateUIInfo(i);
			if ( state > 0 ) then
				-- Handle always up frames and extended ui's completely differently
				if ( extendedUI ~= "" ) then
					-- extendedUI
					uiInfo = ExtendedUI[extendedUI]
					name = uiInfo.name..extendedUIShown;
					if ( extendedUIShown > NUM_EXTENDED_UI_FRAMES ) then
						frame = uiInfo.create(extendedUIShown);
						NUM_EXTENDED_UI_FRAMES = extendedUIShown;
					else
						frame = getglobal(name);
					end
					uiInfo.update(extendedUIShown, extendedUIState1, extendedUIState2, extendedUIState3);
					frame:Show();
					extendedUIShown = extendedUIShown + 1;
				else
					-- Always Up
					name = "AlwaysUpFrame"..alwaysUpShown;
					if ( alwaysUpShown > NUM_ALWAYS_UP_UI_FRAMES ) then
						frame = CreateFrame("Frame", name, WorldStateAlwaysUpFrame, "WorldStateAlwaysUpTemplate");
						NUM_ALWAYS_UP_UI_FRAMES = alwaysUpShown;
					else
						frame = getglobal(name);
					end
					if ( alwaysUpShown == 1 ) then
						frame:SetPoint("TOP", WorldStateAlwaysUpFrame, -23 , -20);
					else
						relative = getglobal("AlwaysUpFrame"..(alwaysUpShown - 1));
						frame:SetPoint("TOP", relative, "BOTTOM");
					end
					frameText = getglobal(name.."Text");
					frameIcon = getglobal(name.."Icon");
					frameDynamicIcon = getglobal(name.."DynamicIconButtonIcon");
					frameFlash = getglobal(name.."Flash");
					flashTexture = getglobal(name.."FlashTexture");
					frameDynamicButton = getglobal(name.."DynamicIconButton");

					frameText:SetText(text);
					frameIcon:SetTexture(icon);
					frameDynamicIcon:SetTexture(dynamicIcon);
					flash = nil;
					if ( dynamicIcon ~= "" ) then
						flash = dynamicIcon.."Flash"
					end
					flashTexture:SetTexture(flash);
					frameDynamicButton.tooltip = dynamicTooltip;
					if ( state == 2 ) then
						UIFrameFlash(frameFlash, 0.5, 0.5, -1);
						frameDynamicButton:Show();
					else
						UIFrameFlashStop(frameFlash);
						frameDynamicButton:Hide();
					end
					alwaysUpShown = alwaysUpShown + 1;
				end	
				frame.tooltip = tooltip;
				frame:Show();
			end
		end
	end
	for i=alwaysUpShown, NUM_ALWAYS_UP_UI_FRAMES do
		frame = getglobal("AlwaysUpFrame"..i);
		frame:Hide();
	end
	for i=extendedUIShown, NUM_EXTENDED_UI_FRAMES do
		frame = getglobal("WorldStateCaptureBar"..i);
		if ( frame ) then
			frame:Hide();
		end
	end
	UIParent_ManageFramePositions();
end

function WorldStateFrame_ToggleMinimap()
	local numUI = GetNumWorldStateUI();
	if ( SHOW_BATTLEFIELD_MINIMAP == "1" ) then
		if ( numUI == 0 ) then
			if ( not MiniMapBattlefieldFrame.status == "active" ) then
				if ( BattlefieldMinimap ) then
					BattlefieldMinimap:Hide();
				end
			end
		else
			if ( not BattlefieldMinimap ) then
				BattlefieldMinimap_LoadUI();
				BattlefieldMinimap:Show();
			else
				BattlefieldMinimap:Show();				
			end
		end
	end
end

-- UI Specific functions
function CaptureBar_Create(id)
	local frame = CreateFrame("Frame", "WorldStateCaptureBar"..id, UIParent, "WorldStateCaptureBarTemplate");
	return frame;
end

function CaptureBar_Update(id, value)
	local position = 25 + 124*(1 - value/100);
	local bar = getglobal("WorldStateCaptureBar"..id);
	if ( not bar.oldValue ) then
		bar.oldValue = position;
	end
	if ( position < bar.oldValue ) then
		getglobal("WorldStateCaptureBar"..id.."IndicatorLeft"):Show();
		getglobal("WorldStateCaptureBar"..id.."IndicatorRight"):Hide();
	elseif ( position > bar.oldValue ) then
		getglobal("WorldStateCaptureBar"..id.."IndicatorLeft"):Hide();
		getglobal("WorldStateCaptureBar"..id.."IndicatorRight"):Show();
	else
		getglobal("WorldStateCaptureBar"..id.."IndicatorLeft"):Hide();
		getglobal("WorldStateCaptureBar"..id.."IndicatorRight"):Hide();
	end
	-- Magic numbers the bar is 40 - 20 - 40
	if ( value > 60  ) then
		getglobal("WorldStateCaptureBar"..id.."LeftIconHighlight"):Show();
		getglobal("WorldStateCaptureBar"..id.."RightIconHighlight"):Hide();
	elseif ( value < 40 ) then
		getglobal("WorldStateCaptureBar"..id.."LeftIconHighlight"):Hide();
		getglobal("WorldStateCaptureBar"..id.."RightIconHighlight"):Show();
	else
		getglobal("WorldStateCaptureBar"..id.."LeftIconHighlight"):Hide();
		getglobal("WorldStateCaptureBar"..id.."RightIconHighlight"):Hide();
	end
	bar.oldValue = position;
	getglobal("WorldStateCaptureBar"..id.."Indicator"):SetPoint("CENTER", "WorldStateCaptureBar"..id, "LEFT", position, 0);
end


-- This has to be after all the functions are loaded
ExtendedUI["CAPTUREPOINT"] = {
	name = "WorldStateCaptureBar",
	create = CaptureBar_Create,
	update = CaptureBar_Update,
	onHide = CaptureBar_Hide,
}

-------------- FINAL SCORE FUNCTIONS ---------------

function WorldStateScoreFrame_OnLoad()
	this:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");
	this:RegisterEvent("UPDATE_WORLD_STATES");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");

	-- Tab Handling code
	PanelTemplates_SetNumTabs(this, 3);
end

function WorldStateScoreFrame_Update()
    local inArena = this.arenaData and true or false
    local arenaData, firstTeam
    local arenaPlayerData = {}
    if inArena then
        arenaData = explode(this.arenaData, ADDON_MSG_FIELD_DELIMITER)
        local players = explode(arenaData[4], ADDON_MSG_ARRAY_DELIMITER)
        local playerData
        for i, player in players do
            playerData = explode(player, ADDON_MSG_SUBFIELD_DELIMITER)
            arenaPlayerData[playerData[1]] = { playerData[2], playerData[3] }

            firstTeam = firstTeam or playerData[2]
        end

        WorldStateScoreFrameTab1:Hide()
        WorldStateScoreFrameTab2:Hide()
        WorldStateScoreFrameTab3:Hide()
    else
        WorldStateScoreFrameTab1:Show()
        WorldStateScoreFrameTab2:Show()
        WorldStateScoreFrameTab3:Show()
    end

	--Show the frame if its hidden and there is a victor
	if ( GetBattlefieldWinner() ) then
		-- Show the final score frame, set textures etc.
		ShowUIPanel(WorldStateScoreFrame);
		WorldStateScoreFrameLeaveButton:Show();
		WorldStateScoreFrameTimerLabel:Show();
		WorldStateScoreFrameTimer:Show();

		-- Show winner
        if inArena then
            print(arenaData[2], firstTeam)
            if arenaData[2] == firstTeam then
		        WorldStateScoreWinnerFrameText:SetText(getglobal(ARENA_TEAM_GOLD_WIN));
                WorldStateScoreWinnerFrameText:SetVertexColor(0.1, 1.0, 0.1);
                WorldStateScoreWinnerFrameLeft:SetVertexColor(0.19, 0.57, 0.11);
                WorldStateScoreWinnerFrameRight:SetVertexColor(0.19, 0.57, 0.11);
            else
		        WorldStateScoreWinnerFrameText:SetText(getglobal(ARENA_TEAM_GREEN_WIN));
                WorldStateScoreWinnerFrameText:SetVertexColor(1, 0.82, 0);
                WorldStateScoreWinnerFrameLeft:SetVertexColor(0.85, 0.71, 0.26);
                WorldStateScoreWinnerFrameRight:SetVertexColor(0.85, 0.71, 0.26);
            end
        else
            local battlefieldWinner = GetBattlefieldWinner();
            WorldStateScoreWinnerFrameText:SetText(getglobal("VICTORY_TEXT"..battlefieldWinner));
            if ( battlefieldWinner == 0 ) then
                -- Horde won
                WorldStateScoreWinnerFrameText:SetVertexColor(1.0, 0.1, 0.1);
                WorldStateScoreWinnerFrameLeft:SetVertexColor(0.52, 0.075, 0.18);
                WorldStateScoreWinnerFrameRight:SetVertexColor(0.52, 0.075, 0.18);
            else
                -- Alliance won
                WorldStateScoreWinnerFrameText:SetVertexColor(0, 0.68, 0.94);
                WorldStateScoreWinnerFrameLeft:SetVertexColor(0.11, 0.26, 0.51);
                WorldStateScoreWinnerFrameRight:SetVertexColor(0.11, 0.26, 0.51);
            end
        end
		WorldStateScoreWinnerFrame:Show();

	else
		WorldStateScoreWinnerFrame:Hide();
		WorldStateScoreFrameLeaveButton:Hide();
		WorldStateScoreFrameTimerLabel:Hide();
		WorldStateScoreFrameTimer:Hide();
	end

	-- Update buttons
	local numScores = GetNumBattlefieldScores();

	local scoreButton, buttonIcon, buttonName, nameButton, buttonKills, buttonDeaths, buttonHonorGained, buttonFaction, columnButtonText, columnButtonIcon, buttonFactionLeft, buttonFactionRight;
	local name, kills, killingBlows, deaths, honorGained, faction, rank, race, class;
	local index, buttonKillingBlows, honorableKills, rankName, rankNumber;
	local columnData;

        -- ScrollFrame update
	local hasScrollBar;
	if ( numScores > MAX_WORLDSTATE_SCORE_BUTTONS ) then
		hasScrollBar = 1;
		WorldStateScoreScrollFrame:Show();
	else
		WorldStateScoreScrollFrame:Hide();
        end
	FauxScrollFrame_Update(WorldStateScoreScrollFrame, numScores, MAX_WORLDSTATE_SCORE_BUTTONS, 16 );

	-- Setup Columns
	local text, icon, tooltip, columnButton;
	local numStatColumns = GetNumBattlefieldStats();
	local columnButton, columnButtonText, columnTextButton, columnIcon;
	local honorGainedAnchorFrame = "WorldStateScoreFrameHK";
	for i=1, MAX_NUM_STAT_COLUMNS do
		if ( i <= numStatColumns ) then
			text, icon, tooltip = GetBattlefieldStatInfo(i);
			columnButton = getglobal("WorldStateScoreColumn"..i);
			columnButtonText = getglobal("WorldStateScoreColumn"..i.."Text");
			columnButtonText:SetText(text);
			columnButton.icon = icon;
			columnButton.tooltip = tooltip;

			columnTextButton = getglobal("WorldStateScoreButton1Column"..i.."Text");

			if ( icon ~= "" ) then
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", 6, -33);
			else
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", -1, -33);
			end

			if ( i == numStatColumns ) then
				honorGainedAnchorFrame = "WorldStateScoreColumn"..i;
			end

			getglobal("WorldStateScoreColumn"..i):Show();
		else
			getglobal("WorldStateScoreColumn"..i):Hide();
		end
	end

	-- Anchor the bonus honor gained to the last column shown
	WorldStateScoreFrameHonorGained:SetPoint("CENTER", honorGainedAnchorFrame, "CENTER", 58, 0);

	-- Last button shown is what the player count anchors to
	local lastButtonShown = "WorldStateScoreButton1";

	for i=1, MAX_WORLDSTATE_SCORE_BUTTONS do
		-- Need to create an index adjusted by the scrollframe offset
		index = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame) + i;
		scoreButton = getglobal("WorldStateScoreButton"..i);
		if ( hasScrollBar ) then
			scoreButton:SetWidth(WorldStateScoreFrame.scrollBarButtonWidth);
		else
			scoreButton:SetWidth(WorldStateScoreFrame.buttonWidth);
		end
		if ( index <= numScores ) then
			buttonIcon = getglobal("WorldStateScoreButton"..i.."RankButtonIcon");
			buttonName = getglobal("WorldStateScoreButton"..i.."NameButtonName");
			nameButton = getglobal("WorldStateScoreButton"..i.."NameButton");
			buttonKills = getglobal("WorldStateScoreButton"..i.."HonorableKills");
			buttonKillingBlows = getglobal("WorldStateScoreButton"..i.."KillingBlows");
			buttonDeaths = getglobal("WorldStateScoreButton"..i.."Deaths");
			buttonHonorGained = getglobal("WorldStateScoreButton"..i.."HonorGained");
			buttonFactionLeft = getglobal("WorldStateScoreButton"..i.."FactionLeft");
			buttonFactionRight = getglobal("WorldStateScoreButton"..i.."FactionRight");

			name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class = GetBattlefieldScore(index);
			rankName, rankNumber = GetPVPRankInfo(rank, faction);
			if ( rankNumber > 0 ) then
				buttonIcon:SetTexture(format("%s%02d","Interface\\PvPRankBadges\\PvPRank", rankNumber));
				buttonIcon:Show();
			else
				buttonIcon:Hide();
			end

			if ( not race ) then
				race = "";
			end
			if ( not class ) then
				class = "";
			end
			local classToken = TW_CLASS_TOKEN[GetLocale()][class]
			local classColor = ""
			if classToken and RAID_CLASS_COLORS[classToken] then
				classColor = RAID_CLASS_COLORS[classToken].hex or ""
			end
			buttonName:SetText(classColor..name);
			nameButton:SetWidth(buttonName:GetWidth());
			nameButton.name = name;
			nameButton.tooltip = race.." "..class;
			getglobal("WorldStateScoreButton"..i.."RankButton").tooltip = rankName;
			buttonKills:SetText(honorableKills);
			buttonKillingBlows:SetText(killingBlows);
			buttonDeaths:SetText(deaths);
			buttonHonorGained:SetText(honorGained);
			for j=1, MAX_NUM_STAT_COLUMNS do
				columnButtonText = getglobal("WorldStateScoreButton"..i.."Column"..j.."Text");
				columnButtonIcon = getglobal("WorldStateScoreButton"..i.."Column"..j.."Icon");
				if ( j <= numStatColumns ) then
					-- If there's an icon then move the icon left and format the text with an "x" in front
					columnData = GetBattlefieldStatData(index, j);
					if ( getglobal("WorldStateScoreColumn"..j).icon ~= "" ) then
						if ( columnData > 0 ) then
							columnButtonText:SetText(format(FLAG_COUNT_TEMPLATE, columnData));
							columnButtonIcon:SetTexture(getglobal("WorldStateScoreColumn"..j).icon..faction);
							columnButtonIcon:Show();
						else
							columnButtonText:SetText("");
							columnButtonIcon:Hide();
						end
					else
						columnButtonText:SetText(columnData);
						columnButtonIcon:Hide();
					end
					columnButtonText:Show();
				else
					columnButtonText:Hide();
					columnButtonIcon:Hide();
				end
			end

            if inArena then
                if arenaPlayerData[name] and arenaPlayerData[name][1] == firstTeam then
                    buttonName:SetVertexColor(0.1, 1.0, 0.1);
                    buttonFactionLeft:SetVertexColor(0.19, 0.57, 0.11);
                    buttonFactionRight:SetVertexColor(0.19, 0.57, 0.11);
                else
                    buttonName:SetVertexColor(1, 0.82, 0);
                    buttonFactionLeft:SetVertexColor(0.85, 0.71, 0.26);
                    buttonFactionRight:SetVertexColor(0.85, 0.71, 0.26);
                end
			elseif ( faction ) then
				if ( faction ) == 0 then
                    buttonName:SetVertexColor(1.0, 0.1, 0.1);
                    buttonFactionLeft:SetVertexColor(0.52, 0.075, 0.18);
                    buttonFactionRight:SetVertexColor(0.5, 0.075, 0.18);
                else
                    buttonName:SetVertexColor(0, 0.68, 0.94);
                    buttonFactionLeft:SetVertexColor(0.11, 0.26, 0.51);
                    buttonFactionRight:SetVertexColor(0.11, 0.26, 0.51);
                end
				if ( name == UnitName("player") ) then
					buttonName:SetVertexColor(1.0, 0.82, 0);
				end
				buttonFactionLeft:Show();
				buttonFactionRight:Show();
			else
				buttonFactionLeft:Hide();
				buttonFactionRight:Hide();
			end
			lastButtonShown = scoreButton:GetName();
			scoreButton:Show();
		else
			scoreButton:Hide();
		end
	end

	-- Set count text and anchor team count to last button shown
    WorldStateScorePlayerCount:Show();
    if inArena then
        WorldStateScorePlayerCount:SetText(arenaData[3] .. " " .. PLAYERS_COUNT)
    else
        -- Count number of players on each side
        local numHorde = 0;
        local numAlliance = 0;
        for i=1, numScores do
            name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class = GetBattlefieldScore(i);
            if ( faction ) then
                if ( faction == 0 ) then
                    numHorde = numHorde + 1;
                else
                    numAlliance = numAlliance + 1;
                end
            end
        end
        if ( numHorde > 0 and numAlliance > 0 ) then
            WorldStateScorePlayerCount:SetText(format(GetText("PLAYER_COUNT_ALLIANCE", nil, numAlliance), numAlliance).." / "..format(GetText("PLAYER_COUNT_HORDE", nil, numHorde), numHorde));
        elseif ( numAlliance > 0 ) then
            WorldStateScorePlayerCount:SetText(format(GetText("PLAYER_COUNT_ALLIANCE", nil, numAlliance), numAlliance));
        elseif ( numHorde > 0 ) then
            WorldStateScorePlayerCount:SetText(format(GetText("PLAYER_COUNT_HORDE", nil, numHorde), numHorde));
        else
            WorldStateScorePlayerCount:Hide();
        end
    end
	WorldStateScorePlayerCount:SetPoint("TOPLEFT", lastButtonShown, "BOTTOMLEFT", 15, -6);
	WorldStateScoreBattlegroundRunTime:SetText(TIME_ELAPSED.." "..SecondsToTime(GetBattlefieldInstanceRunTime()/1000, 1));
	WorldStateScoreBattlegroundRunTime:SetPoint("TOPRIGHT", lastButtonShown, "BOTTOMRIGHT", -20, -7);
end

function WorldStateScoreFrame_Resize(width)
	if ( not width ) then
		if ( WorldStateScoreScrollFrame:IsShown() ) then
			width = WORLDSTATESCOREFRAME_BASE_WIDTH + 37 + GetNumBattlefieldStats()*WORLDSTATESCOREFRAME_COLUMN_SPACING;
		else
			width = WORLDSTATESCOREFRAME_BASE_WIDTH + GetNumBattlefieldStats()*WORLDSTATESCOREFRAME_COLUMN_SPACING;
		end
	end
	WorldStateScoreFrame:SetWidth(width);
	
	WorldStateScoreFrameTopBackground:SetWidth(WorldStateScoreFrame:GetWidth()-129);
	WorldStateScoreFrameTopBackground:SetTexCoord(0, WorldStateScoreFrameTopBackground:GetWidth()/256, 0, 1.0);
	WorldStateScoreFrame.scrollBarButtonWidth = WorldStateScoreFrame:GetWidth() - 165;
	WorldStateScoreFrame.buttonWidth = WorldStateScoreFrame:GetWidth() - 137;
	WorldStateScoreScrollFrame:SetWidth(WorldStateScoreFrame.scrollBarButtonWidth);

	-- Position Column data horizontally
	local buttonKills, buttonDeaths, buttonHonorGained, buttonReturnedIcon, buttonCapturedIcon, buttonKillingBlows;
	for i=1, MAX_WORLDSTATE_SCORE_BUTTONS do
		buttonKills = getglobal("WorldStateScoreButton"..i.."HonorableKills");
		buttonKillingBlows = getglobal("WorldStateScoreButton"..i.."KillingBlows");
		buttonDeaths = getglobal("WorldStateScoreButton"..i.."Deaths");
		buttonHonorGained = getglobal("WorldStateScoreButton"..i.."HonorGained");
		if ( i == 1 ) then
			buttonKills:SetPoint("CENTER", "WorldStateScoreFrameHK", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			buttonKillingBlows:SetPoint("CENTER", "WorldStateScoreFrameKB", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			buttonDeaths:SetPoint("CENTER", "WorldStateScoreFrameDeaths", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			buttonHonorGained:SetPoint("CENTER", "WorldStateScoreFrameHonorGained", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
		else
			buttonKills:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."HonorableKills", "CENTER", 0, -15);
			buttonKillingBlows:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."KillingBlows", "CENTER", 0, -15);
			buttonDeaths:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Deaths", "CENTER", 0, -15);
			buttonHonorGained:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."HonorGained", "CENTER", 0, -15);
			for j=1, MAX_NUM_STAT_COLUMNS do
				getglobal("WorldStateScoreButton"..i.."Column"..j.."Text"):SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Column"..j.."Text", "CENTER", 0, -15);
			end
		end
	end
end

function WorldStateScoreFrameTab_OnClick(tab)
	if ( not tab ) then
		tab = this;
	end
	local faction = tab:GetID();
	PanelTemplates_SetTab(WorldStateScoreFrame, faction);
	if ( faction == 2 ) then
		faction = 1;
	elseif ( faction == 3 ) then
		faction = 0;
	else
		faction = nil;
	end
	WorldStateScoreFrameLabel:SetText(format(STAT_TEMPLATE, tab:GetText()));
	SetBattlefieldScoreFaction(faction);
	PlaySound("igCharacterInfoTab");
end

function ToggleWorldStateScoreFrame()
	if ( WorldStateScoreFrame:IsVisible() ) then
		HideUIPanel(WorldStateScoreFrame);
	else
		if ( MiniMapBattlefieldFrame.status == "active" ) then
			ShowUIPanel(WorldStateScoreFrame);
		end
	end
end
