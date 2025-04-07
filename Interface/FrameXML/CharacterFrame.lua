CHARACTERFRAME_SUBFRAMES = { "PaperDollFrame", "PetPaperDollFrame", "SkillFrame", "ReputationFrame", "HonorFrame" };

function ToggleCharacter(tab)
	if ( tab == "PetPaperDollFrame" and not HasPetUI() and not PetPaperDollFrame:IsVisible() ) then
		return;
	end
	
	local subFrame = getglobal(tab);
	if ( subFrame ) then
		PanelTemplates_SetTab(CharacterFrame, subFrame:GetID());
		if ( CharacterFrame:IsVisible() ) then
			if ( subFrame:IsVisible() ) then
				HideUIPanel(CharacterFrame);	
			else
				PlaySound("igCharacterInfoTab");
				CharacterFrame_ShowSubFrame(tab);
			end
		else
			ShowUIPanel(CharacterFrame);
			CharacterFrame_ShowSubFrame(tab);
		end
	end
end

function CharacterFrame_ShowSubFrame(frameName)
	for index, value in CHARACTERFRAME_SUBFRAMES do
		if ( value == frameName ) then
			getglobal(value):Show()
		else
			getglobal(value):Hide();	
		end	
	end 
end

function CharacterFrameTab_OnClick()
	if ( this:GetName() == "CharacterFrameTab1" ) then
		ToggleCharacter("PaperDollFrame");
	elseif ( this:GetName() == "CharacterFrameTab2" ) then
		ToggleCharacter("PetPaperDollFrame");
	elseif ( this:GetName() == "CharacterFrameTab3" ) then
		ToggleCharacter("ReputationFrame");	
	elseif ( this:GetName() == "CharacterFrameTab4" ) then
		ToggleCharacter("SkillFrame");	
	elseif ( this:GetName() == "CharacterFrameTab5" ) then
		ToggleCharacter("HonorFrame");	
	end
	PlaySound("igCharacterInfoTab");
end

function CharacterFrame_OnLoad()
	this:RegisterEvent("UNIT_NAME_UPDATE");
	this:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	this:RegisterEvent("PLAYER_PVP_RANK_CHANGED");

	SetTextStatusBarTextPrefix(PlayerFrameHealthBar, TEXT(HEALTH));
	SetTextStatusBarTextPrefix(PlayerFrameManaBar, TEXT(MANA));
	SetTextStatusBarTextPrefix(MainMenuExpBar, TEXT(XP));
	-- Tab Handling code
	PanelTemplates_SetNumTabs(this, 5);
	PanelTemplates_SetTab(this, 1);
end

function CharacterFrame_OnEvent(event)
	if ( not this:IsVisible() ) then
		return;
	end
	if ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( arg1 == "player" ) then
			SetPortraitTexture(CharacterFramePortrait, arg1);
		end
		return;
	elseif ( event == "UNIT_NAME_UPDATE" ) then
		if ( arg1 == "player" ) then
			CharacterNameText:SetText(gsub(UnitPVPName(arg1), "\n.+", ""));
		end
		return;
	elseif ( event == "PLAYER_PVP_RANK_CHANGED" ) then
		CharacterNameText:SetText(gsub(UnitPVPName("player"), "\n.+", ""));
	end
end

function CharacterFrame_OnShow()
	PlaySound("igCharacterInfoOpen");
	SetPortraitTexture(CharacterFramePortrait, "player");
	CharacterNameText:SetText(gsub(UnitPVPName("player"), "\n.+", ""));
	UpdateMicroButtons();
	ShowTextStatusBarText(PlayerFrameHealthBar);
	ShowTextStatusBarText(PlayerFrameManaBar);
	ShowTextStatusBarText(MainMenuExpBar);
	ShowTextStatusBarText(PetFrameHealthBar);
	ShowTextStatusBarText(PetFrameManaBar);
	ShowWatchedReputationBarText();

	SendAddonMessage("TW_TITLES", "Titles:List", "GUILD")
end

function CharacterFrame_OnHide()
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
	HideTextStatusBarText(PlayerFrameHealthBar);
	HideTextStatusBarText(PlayerFrameManaBar);
	HideTextStatusBarText(MainMenuExpBar);
	HideTextStatusBarText(PetFrameHealthBar);
	HideTextStatusBarText(PetFrameManaBar);
	HideWatchedReputationBarText();
end

-- Turtle WoW Title Frame
local availableTitles

function TWTitles_OnEvent()
	if event then
		--DEFAULT_CHAT_FRAME:AddMessage("prefix [" .. arg1 .. "]")
		--DEFAULT_CHAT_FRAME:AddMessage("text [" .. arg2 .. "]")
		--DEFAULT_CHAT_FRAME:AddMessage("chan [" .. arg3 .. "]")
		--DEFAULT_CHAT_FRAME:AddMessage("sender [" .. arg4 .. "]")
		if event == "CHAT_MSG_ADDON" and arg1 == "TWT_TITLES" then
			-- new title message
            local _, _, titleID = string.find(arg2, "newTitle:(%d+)")
			if titleID then
				DEFAULT_CHAT_FRAME:AddMessage("|cff00FF00"..format(TW_TITLES_EARNED, getglobal('PVP_MEDAL' .. titleID)))
			end
			-- available titles
			if string.find(arg2, "TW_AVAILABLE_TITLES:", 1, true) then
				availableTitles = arg2
				UIDropDownMenu_Initialize(TWTitles, TitlesDropDown_Initialize)
			end
		end
	end
end

function TitlesDropDown_OnLoad()
    TWTitles:RegisterEvent("CHAT_MSG_ADDON")
	UIDropDownMenu_Initialize(TWTitles, TitlesDropDown_Initialize);
	UIDropDownMenu_SetWidth(210, TWTitles);
    TWTitles:SetScale(0.9)
end

function TitlesDropDown_Initialize()
    if not availableTitles then
        return
    end
    -- get titles
	local fEx = string.gsub(availableTitles, 'TW_AVAILABLE_TITLES:', "")
	if fEx then
		local aEx = ___explode(fEx, ';')
		for _, titleData in aEx do
			local _, _, id, active = string.find(titleData, '(%d+):(%d+)')
			if id == '0' then
				local info = {}
				info.text = GENERIC_NONE
				info.value = id
				info.arg1 = id
				info.checked = active == '1'
				info.func = TitleChange
				UIDropDownMenu_AddButton(info)
				if active == '1' then
					UIDropDownMenu_SetText(GENERIC_NONE, TWTitles)
				end
			else
				if getglobal('PVP_MEDAL' .. id) then
					local info = {}
					info.text = getglobal('PVP_MEDAL' .. id)
					info.value = id
					info.arg1 = id
					info.checked = active == '1'
					info.func = TitleChange
					UIDropDownMenu_AddButton(info)
					if active == '1' then
						UIDropDownMenu_SetText(getglobal('PVP_MEDAL' .. id), TWTitles)
					end
				end
			end
		end
	end
end

function TitleChange(a)
	SendAddonMessage("TW_TITLES", "ChangeTitle:" .. a, "GUILD")
end

function ___explode(str, delimiter)
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(str, delimiter, from, true)
	while delim_from do
		table.insert(result, string.sub(str, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(str, delimiter, from, true)
	end
	table.insert(result, string.sub(str, from))
	return result
end
