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
			CharacterNameText:SetText(UnitPVPName(arg1));
		end
		return;
	elseif ( event == "PLAYER_PVP_RANK_CHANGED" ) then
		CharacterNameText:SetText(UnitPVPName("player"));
	end
end

function CharacterFrame_OnShow()
	PlaySound("igCharacterInfoOpen");
	SetPortraitTexture(CharacterFramePortrait, "player");
	CharacterNameText:SetText(UnitPVPName("player"));
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

local TW_Titles = CreateFrame("Frame")

TW_Titles:RegisterEvent("CHAT_MSG_ADDON")

local availableTitles

TW_Titles:SetScript("OnEvent", function()
	if event then

		--DEFAULT_CHAT_FRAME:AddMessage("prefix [" .. arg1 .. "]")
		--DEFAULT_CHAT_FRAME:AddMessage("text [" .. arg2 .. "]")
		--DEFAULT_CHAT_FRAME:AddMessage("chan [" .. arg3 .. "]")
		--DEFAULT_CHAT_FRAME:AddMessage("sender [" .. arg4 .. "]")

		if event == "CHAT_MSG_ADDON" and arg1 == "TWT_TITLES" then

			-- new title message
			if string.find(arg2, "newTitle:", 1, true) then
				local ntEx = ___explode(arg2, ":")
				DEFAULT_CHAT_FRAME:AddMessage("|cff00FF00You have earned \"" .. getglobal('PVP_MEDAL' .. ntEx[2]) .. "\" title.")
			end
			-- available titles
			if string.find(arg2, "TW_AVAILABLE_TITLES:", 1, true) then
				availableTitles = arg2
				TitlesDropDown_OnLoad()
			end

		end
	end
end)

function TitlesDropDown_OnLoad()
	UIDropDownMenu_Initialize(getglobal('TWTitles'), TitlesDropDown_Initialize);
	UIDropDownMenu_SetWidth(210, getglobal('TWTitles'));
end

function TitlesDropDown_Initialize()
	--get titles
	local fEx = ___explode(availableTitles, 'TW_AVAILABLE_TITLES:')
	if fEx[2] then
		local aEx = ___explode(fEx[2], ';')
		for _, titleData in aEx do

			local titleDataEx = ___explode(titleData, ':')

			local id = titleDataEx[1]
			local active = titleDataEx[2]

			if id == '0' then

				local info = {}
				info.text = "None"
				info.value = id
				info.arg1 = id
				info.checked = active == '1'
				info.func = TitleChange
				UIDropDownMenu_AddButton(info)

				if active == '1' then
					UIDropDownMenu_SetText("None", getglobal('TWTitles'))
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
						UIDropDownMenu_SetText(getglobal('PVP_MEDAL' .. id), getglobal('TWTitles'))
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
	local delim_from, delim_to = string.find(str, delimiter, from, 1, true)
	while delim_from do
		table.insert(result, string.sub(str, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(str, delimiter, from, true)
	end
	table.insert(result, string.sub(str, from))
	return result
end
