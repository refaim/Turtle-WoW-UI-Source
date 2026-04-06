MINIMAPPING_TIMER = 5;
MINIMAPPING_FADE_TIMER = 0.5;
CURSOR_OFFSET_X = -7;
CURSOR_OFFSET_Y = -9;

function Minimap_OnLoad()
	MiniMapPing.fadeOut = nil;
	this:SetSequence(0);
	this:RegisterEvent("MINIMAP_PING");
	this:RegisterEvent("MINIMAP_UPDATE_ZOOM");
end

function ToggleMinimap()
	if ( Minimap:IsVisible() ) then
		PlaySound("igMiniMapClose");
		Minimap:Hide();
	else
		PlaySound("igMiniMapOpen");
		Minimap:Show();
	end
end

function Minimap_Update()
	MinimapZoneText:SetText(GetMinimapZoneText());
	local pvpType, factionName, isArena = GetZonePVPInfo();
	if ( isArena ) then
		MinimapZoneText:SetTextColor(1.0, 0.1, 0.1);
	elseif ( pvpType == "friendly" ) then
		MinimapZoneText:SetTextColor(0.1, 1.0, 0.1);
	elseif ( pvpType == "hostile" ) then
		MinimapZoneText:SetTextColor(1.0, 0.1, 0.1);
	elseif ( pvpType == "contested" ) then
		MinimapZoneText:SetTextColor(1.0, 0.7, 0);
	else
		MinimapZoneText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	if ( GameTooltip:IsOwned(MinimapZoneTextButton) ) then
		GameTooltip:SetOwner(MinimapZoneTextButton, "ANCHOR_LEFT");
		GameTooltip:AddLine(GetMinimapZoneText());
		if ( (pvpType == "friendly") or (pvpType == "hostile") ) then
			GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName));
		elseif ( pvpType == "contested" ) then
			GameTooltip:AddLine(CONTESTED_TERRITORY);
		elseif ( pvpType == "arena" ) then
			GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY);
		end
		GameTooltip:Show();
	end
end

function Minimap_OnEvent()
	if ( event == "MINIMAP_PING" ) then
		Minimap_SetPing(arg2, arg3, 1);
		Minimap.timer = MINIMAPPING_TIMER;
	elseif ( event == "MINIMAP_UPDATE_ZOOM" ) then
		MinimapZoomIn:Enable();
		MinimapZoomOut:Enable();
		local zoom = Minimap:GetZoom();
		if ( zoom == (Minimap:GetZoomLevels() - 1) ) then
			MinimapZoomIn:Disable();
		elseif ( zoom == 0 ) then
			MinimapZoomOut:Disable();
		end
	end
end

function Minimap_OnUpdate(elapsed)
	if ( Minimap.timer > 0 ) then
		Minimap.timer = Minimap.timer - elapsed;
		if ( Minimap.timer <= 0 ) then
			MiniMapPing_FadeOut();
		else
			Minimap_SetPing(Minimap:GetPingPosition());
		end
	elseif ( MiniMapPing.fadeOut ) then
		MiniMapPing.fadeOutTimer = MiniMapPing.fadeOutTimer - elapsed;
		if ( MiniMapPing.fadeOutTimer > 0 ) then
			MiniMapPing:SetAlpha(MiniMapPing.fadeOutTimer / MINIMAPPING_FADE_TIMER);
		else
			MiniMapPing.fadeOut = nil;
			MiniMapPing:Hide();
		end
	end
end

function Minimap_SetPing(x, y, playSound)
	x = x * Minimap:GetWidth();
	y = y * Minimap:GetHeight();

	if ( sqrt(x * x + y * y) < (Minimap:GetWidth() / 2) ) then
		MiniMapPing:SetPoint("CENTER", "Minimap", "CENTER", x, y);
		MiniMapPing:SetAlpha(1);
		MiniMapPing:Show();
		if ( playSound ) then
			PlaySound("MapPing");
		end
	else
		MiniMapPing:Hide();
	end

end

function MiniMapPing_FadeOut()
	MiniMapPing.fadeOut = 1;
	MiniMapPing.fadeOutTimer = MINIMAPPING_FADE_TIMER;
end

function Minimap_ZoomInClick()
	MinimapZoomOut:Enable();
	PlaySound("igMiniMapZoomIn");
	Minimap:SetZoom(Minimap:GetZoom() + 1);
	if(Minimap:GetZoom() == (Minimap:GetZoomLevels() - 1)) then
		MinimapZoomIn:Disable();
	end
end

function Minimap_ZoomOutClick()
	MinimapZoomIn:Enable();
	PlaySound("igMiniMapZoomOut");
	Minimap:SetZoom(Minimap:GetZoom() - 1);
	if ( Minimap:GetZoom() == 0 ) then
		MinimapZoomOut:Disable();
	end
end

function Minimap_OnClick()
	local x, y = GetCursorPosition();
	x = x / this:GetEffectiveScale();
	y = y / this:GetEffectiveScale();

	local cx, cy = this:GetCenter();
	x = x + CURSOR_OFFSET_X - cx;
	y = y + CURSOR_OFFSET_Y - cy;
	if ( sqrt(x * x + y * y) < (this:GetWidth() / 2) ) then
		Minimap:PingLocation(x, y);
	end
end

function Minimap_ZoomIn()
	MinimapZoomIn:Click();
end

function Minimap_ZoomOut()
	MinimapZoomOut:Click();
end

local TWBGQueueMinimapMenuFrame = CreateFrame("Frame", "TWBGQueueMinimapMenuFrame", UIParent, "UIDropDownMenuTemplate")

function ShowTWBGQueueMenu()
	UIDropDownMenu_Initialize(TWBGQueueMinimapMenuFrame, BuildTWBGQueueMenu, "MENU")
	ToggleDropDownMenu(1, nil, TWBGQueueMinimapMenuFrame, this, 2, 2)
end

function JoinBattlegroundQueue(bgType)
	SendAddonMessage("TW_BGQueue", bgType, "GUILD")
end

function BuildTWBGQueueMenu()
	local info

	if UIDROPDOWNMENU_MENU_LEVEL == 2 then
		info = UIDropDownMenu_CreateInfo()
		info.text = ARENA_QUEUE_RATED.." (2v2)"
		info.func = JoinArenaQueue
		info.arg1 = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

		info = UIDropDownMenu_CreateInfo()
		info.text = ARENA_QUEUE_RATED.." (3v3)"
		info.func = JoinArenaQueue
		info.arg1 = 2
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

		info = UIDropDownMenu_CreateInfo()
		info.text = ARENA_QUEUE_RATED.." (5v5)"
		info.func = JoinArenaQueue
		info.arg1 = 3
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

		info = UIDropDownMenu_CreateInfo()
		info.text = ""
		info.disabled = true
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

		info = UIDropDownMenu_CreateInfo()
		info.text = ARENA_QUEUE_SKIRMISH
		info.func = JoinArenaQueue
		info.arg1 = 0
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
		return
	end

	info = UIDropDownMenu_CreateInfo()
	info.text = BATTLEFIELDS
	info.isTitle = true
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = ""
	info.disabled = true
	UIDropDownMenu_AddButton(info)

	local arenaQueued = false
	local warsongQueued = false
	local arathiQueued = false
	local thornGorgeQueued = false
	local alteracQueued = false

	for i = 1, MAX_BATTLEFIELD_QUEUES do
		local a, b = GetBattlefieldStatus(i)
		if a == "queued" then
			if b == ARENA then
				arenaQueued = true
			elseif b == MINIMAP_BATTLEGROUND_WARSONG then
				warsongQueued = true
			elseif b == MINIMAP_BATTLEGROUND_ARATHI then
				arathiQueued = true
			elseif b == MINIMAP_BATTLEGROUND_THORNGORGE then
				thornGorgeQueued = true
			elseif b == MINIMAP_BATTLEGROUND_ALTERAC then
				alteracQueued = true
			end
		end
	end

	info = UIDropDownMenu_CreateInfo()
	info.text = ARENA
	info.disabled = arenaQueued
	info.checked = arenaQueued
	info.hasArrow = not arenaQueued
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = MINIMAP_BATTLEGROUND_WARSONG
	info.tooltipTitle = MINIMAP_BATTLEGROUND_WARSONG
	info.tooltipText = MINIMAP_BATTLEGROUND_WARSONG_TOOLTIP
	info.disabled = warsongQueued
	info.checked = warsongQueued
	info.func = JoinBattlegroundQueue
	info.arg1 = "Warsong"
	UIDropDownMenu_AddButton(info)

	if UnitLevel("player") >= 20 then
		info = UIDropDownMenu_CreateInfo()
		info.text = MINIMAP_BATTLEGROUND_ARATHI
		info.tooltipTitle = MINIMAP_BATTLEGROUND_ARATHI
		info.tooltipText = MINIMAP_BATTLEGROUND_ARATHI_TOOLTIP
		info.disabled = arathiQueued
		info.checked = arathiQueued
		info.func = JoinBattlegroundQueue
		info.arg1 = "Arathi"
		UIDropDownMenu_AddButton(info)
	end

	if UnitLevel("player") >= 51 then
		info = UIDropDownMenu_CreateInfo()
		info.text = MINIMAP_BATTLEGROUND_ALTERAC
		info.tooltipTitle = MINIMAP_BATTLEGROUND_ALTERAC
		info.tooltipText = MINIMAP_BATTLEGROUND_ALTERAC_TOOLTIP
		info.disabled = alteracQueued
		info.checked = alteracQueued
		info.func = JoinBattlegroundQueue
		info.arg1 = "Alterac"
		UIDropDownMenu_AddButton(info)
	end

	if UnitLevel("player") >= 60 then
		info = UIDropDownMenu_CreateInfo()
		info.text = MINIMAP_BATTLEGROUND_THORNGORGE
		info.tooltipTitle = MINIMAP_BATTLEGROUND_THORNGORGE
		info.tooltipText = MINIMAP_BATTLEGROUND_THORNGORGE_TOOLTIP
		info.disabled = thornGorgeQueued
		info.checked = thornGorgeQueued
		info.func = JoinBattlegroundQueue
		info.arg1 = "ThornGorge"
		UIDropDownMenu_AddButton(info)
	end
end
