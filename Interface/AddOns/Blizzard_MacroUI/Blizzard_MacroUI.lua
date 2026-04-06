MAX_MACROS = 18;
NUM_ICONS_PER_ROW = 5;
NUM_ICON_ROWS = 4;
NUM_MACRO_ICONS_SHOWN = NUM_ICONS_PER_ROW * NUM_ICON_ROWS;
MACRO_ICON_ROW_HEIGHT = 36;
MACRO_ICON_FILENAMES = {};

UIPanelWindows["MacroFrame"] = { area = "left", pushable = 1, whileDead = 1 };

local SearchResults = {}

function MacroFrame_Show()
	ShowUIPanel(MacroFrame);
end

function MacroFrame_OnLoad()
	MacroFrame_SetAccountMacros();
	PanelTemplates_SetNumTabs(MacroFrame, 2);
	PanelTemplates_SetTab(MacroFrame, 1);
end

function MacroFrame_OnShow()
	MacroFrame_Update();
	PlaySound("igCharacterInfoOpen");
	UpdateMicroButtons();
end

function MacroFrame_OnHide()
	MacroPopupFrame:Hide();
	MacroFrame_SaveMacro();
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
end

function MacroFrame_SetAccountMacros()
	MacroFrame.macroBase = 0;
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	if ( numAccountMacros > 0 ) then
		MacroFrame_SelectMacro(MacroFrame.macroBase + 1);
	else
		MacroFrame_SelectMacro(nil);
	end
end

function MacroFrame_SetCharacterMacros()
	MacroFrame.macroBase = MAX_MACROS;
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	if ( numCharacterMacros > 0 ) then
		MacroFrame_SelectMacro(MacroFrame.macroBase + 1);
	else
		MacroFrame_SelectMacro(nil);
	end
end

function MacroFrame_Update()
	local numMacros;
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	local macroButton, macroIcon, macroName;
	local name, texture, body, isLocal;

	if ( MacroFrame.macroBase == 0 ) then
		numMacros = numAccountMacros;
	else
		numMacros = numCharacterMacros;
	end

	-- Macro List
	for i=1, MAX_MACROS do
		macroButton = _G["MacroButton"..i];
		macroIcon = _G["MacroButton"..i.."Icon"];
		macroName = _G["MacroButton"..i.."Name"];
		if ( i <= numMacros ) then
			name, texture, body, isLocal = GetMacroInfo(MacroFrame.macroBase + i);
			macroIcon:SetTexture(texture);
			macroName:SetText(name);
			macroButton:Enable();
			-- Highlight Selected Macro
			if ( MacroFrame.selectedMacro and (i == (MacroFrame.selectedMacro - MacroFrame.macroBase)) ) then
				macroButton:SetChecked(1);
				MacroFrameSelectedMacroName:SetText(name);
				MacroFrameText:SetText(body);
				MacroFrameSelectedMacroButton:SetID(i);
				MacroFrameSelectedMacroButtonIcon:SetTexture(texture);
				MacroPopupFrame.selectedIconTexture = gsub(strupper(texture), "INTERFACE\\ICONS\\", "");
			else
				macroButton:SetChecked(0);
			end
		else
			macroButton:SetChecked(0);
			macroIcon:SetTexture("");
			macroName:SetText("");
			macroButton:Disable();
		end
	end

	-- Macro Details
	if ( MacroFrame.selectedMacro ~= nil ) then
		MacroFrame_ShowDetails();
		MacroDeleteButton:Enable();
	else
		MacroFrame_HideDetails();
		MacroDeleteButton:Disable();
		MacroPopupFrame.selectedIconTexture = nil;
	end

	-- Update New Button
	if ( numMacros < MAX_MACROS ) then
		MacroNewButton:Enable();
	else
		MacroNewButton:Disable();
	end

	-- Disable Buttons
	if ( MacroPopupFrame:IsVisible() ) then
		MacroEditButton:Disable();
		MacroDeleteButton:Disable();
	else
		MacroEditButton:Enable();
		MacroDeleteButton:Enable();
	end

	if ( not MacroFrame.selectedMacro ) then
		MacroDeleteButton:Disable();
	end
end

function MacroFrame_AddMacroLine(line)
	if ( MacroFrameText:IsVisible() ) then
		MacroFrameText:SetText(MacroFrameText:GetText()..line);
	end
end

function MacroButton_OnClick()
	MacroFrame_SaveMacro();
	MacroFrame_SelectMacro(MacroFrame.macroBase + this:GetID());
	MacroFrame_Update();
	MacroPopupFrame:Hide();
	MacroFrameText:ClearFocus();
end

function MacroFrame_SelectMacro(id)
	MacroFrame.selectedMacro = id;
end

function MacroNewButton_OnClick()
	MacroFrame_SaveMacro();
	MacroPopupFrame.mode = "new";
	MacroPopupFrame:Show();
end

function MacroEditButton_OnClick()
	MacroFrame_SaveMacro();
	MacroPopupFrame.mode = "edit";
	MacroPopupFrame:Show();
end

function MacroDeleteButton_OnClick()
	local selectedMacro = MacroFrame.selectedMacro;
	DeleteMacro(selectedMacro);
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	local numMacros = 0;
	if MacroFrame.macroBase == 0 then
		numMacros = numAccountMacros;
	else
		numMacros = numCharacterMacros;
	end
	if selectedMacro > numMacros + MacroFrame.macroBase then
		selectedMacro = selectedMacro - 1;
	end
	if selectedMacro <= MacroFrame.macroBase then
		MacroFrame.selectedMacro = nil;
	else
		MacroFrame.selectedMacro = selectedMacro;
	end
	MacroFrame_Update();
	MacroFrameText:ClearFocus();
end

function MacroFrame_HideDetails()
	MacroEditButton:Hide();
	MacroFrameCharLimitText:Hide();
	MacroFrameText:Hide();
	MacroFrameSelectedMacroName:Hide();
	MacroFrameSelectedMacroBackground:Hide();
	MacroFrameSelectedMacroButton:Hide();
end

function MacroFrame_ShowDetails()
	MacroEditButton:Show();
	MacroFrameCharLimitText:Show();
	MacroFrameEnterMacroText:Show();
	MacroFrameText:Show();
	MacroFrameSelectedMacroName:Show();
	MacroFrameSelectedMacroBackground:Show();
	MacroFrameSelectedMacroButton:Show();
end

function MacroPopupFrame_OnShow()
	MacroFrameText:ClearFocus();
	MacroPopupEditBox:SetFocus();
	PlaySound("igCharacterInfoOpen");

	UpdateMacroIconFilenames();
	MacroPopupFrame_Update(true);
	MacroPopupOkayButton_Update();

	if ( MacroPopupFrame.mode == "new" ) then
		MacroFrameText:Hide();
		MacroPopupButton_SelectTexture(1);
	end

	-- Disable Buttons
	MacroEditButton:Disable();
	MacroDeleteButton:Disable();
	MacroNewButton:Disable();
	MacroFrameTab1:Disable();
	MacroFrameTab2:Disable();
end

function MacroPopupFrame_OnHide()
	if ( MacroPopupFrame.mode == "new" ) then
		MacroFrameText:Show();
		MacroFrameText:SetFocus();
	end

	-- Enable Buttons
	MacroEditButton:Enable();
	MacroDeleteButton:Enable();
	local numMacros;
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	if ( MacroFrame.macroBase == 0 ) then
		numMacros = numAccountMacros;
	else
		numMacros = numCharacterMacros;
	end
	if ( numMacros < MAX_MACROS ) then
		MacroNewButton:Enable();
	end
	-- Enable tabs
	PanelTemplates_UpdateTabs(MacroFrame);
end

function UpdateMacroIconFilenames()
	wipe(MACRO_ICON_FILENAMES);
	tinsert(MACRO_ICON_FILENAMES, 1, "INV_MISC_QUESTIONMARK");
	local hasPet = HasPetUI();

	for i = 1, GetNumSpellTabs() do
		local _, _, offset, numSpells = GetSpellTabInfo(i);
		offset = offset + 1;
		local tabEnd = offset + numSpells - 1;
		for j = offset, tabEnd do
			local texture = strupper(GetSpellTexture(j, BOOKTYPE_SPELL) or "");
			texture = gsub(texture, "INTERFACE\\ICONS\\", "");
			if texture and texture ~= "" and not strfind(texture, "INTERFACE\\BUTTONS\\") and not tContains(MACRO_ICON_FILENAMES, texture) then
				tinsert(MACRO_ICON_FILENAMES, texture);
			end
			if hasPet then
				texture = strupper(GetSpellTexture(j, BOOKTYPE_PET) or "");
				texture = gsub(texture, "INTERFACE\\ICONS\\", "");
				if texture and texture ~= "" and not strfind(texture, "INTERFACE\\BUTTONS\\") and not tContains(MACRO_ICON_FILENAMES, texture) then
					tinsert(MACRO_ICON_FILENAMES, texture);
				end
			end
		end
	end
	for i = 1, GetNumMacroIcons() do
		local texture = strupper(GetMacroIconInfo(i));
		texture = gsub(texture, "INTERFACE\\ICONS\\", "");
		if not tContains(MACRO_ICON_FILENAMES, texture) then
			tinsert(MACRO_ICON_FILENAMES, texture);
		end
	end
end

function MacroPopupFrame_Update(setName)
	local numMacroIcons = getn(MACRO_ICON_FILENAMES);
	local macroPopupIcon, macroPopupButton;
	local macroPopupOffset = FauxScrollFrame_GetOffset(MacroPopupScrollFrame);
	local index;
	local results = getn(SearchResults);

	-- Determine whether we're creating a new macro or editing an existing one
	if setName then
		if ( MacroPopupFrame.mode == "new" ) then
			MacroPopupEditBox:SetText("");
		elseif ( MacroPopupFrame.mode == "edit" ) then
			local name, texture, body, isLocal = GetMacroInfo(MacroFrame.selectedMacro);
			MacroPopupEditBox:SetText(name);
		end
	end

	-- Icon list
	for i=1, NUM_MACRO_ICONS_SHOWN do
		macroPopupButton = _G["MacroPopupButton"..i];
		if not macroPopupButton then
			macroPopupButton = CreateFrame("CheckButton", "MacroPopupButton"..i, MacroPopupFrame, "MacroPopupButtonTemplate");
			macroPopupButton:SetID(i);
			if i == 1 then
				macroPopupButton:SetPoint("TOPLEFT", "MacroPopupFrame", 24, -85);
			elseif mod(i, NUM_ICONS_PER_ROW) == 1 then
				macroPopupButton:SetPoint("TOPLEFT", "MacroPopupButton"..(i - NUM_ICONS_PER_ROW), "BOTTOMLEFT", 0, -8);
			else
				macroPopupButton:SetPoint("LEFT", "MacroPopupButton"..(i - 1), "RIGHT", 10, 0);
			end
		end
		macroPopupIcon = _G["MacroPopupButton"..i.."Icon"];
		if results > 0 then
			if SearchResults[macroPopupOffset * NUM_ICONS_PER_ROW + i] then
				index = SearchResults[macroPopupOffset * NUM_ICONS_PER_ROW + i];
			else
				index = numMacroIcons + 1;
			end
		else
			index = (macroPopupOffset * NUM_ICONS_PER_ROW) + i;
		end

		local texture = MACRO_ICON_FILENAMES[index];
		if ( index <= numMacroIcons and texture ) then
			macroPopupIcon:SetTexture("INTERFACE\\ICONS\\"..texture);
			macroPopupButton:Show();
			macroPopupButton:SetID(index);
		else
			macroPopupIcon:SetTexture("");
			macroPopupButton:Hide();
		end
		if ( texture and MacroPopupFrame.selectedIconTexture == texture ) then
			macroPopupButton:SetChecked(1);
		else
			macroPopupButton:SetChecked(nil);
		end
	end

	-- Scrollbar stuff
	local numIcons = ceil(numMacroIcons / NUM_ICONS_PER_ROW)
	if results > 0 then
		numIcons = ceil(results / NUM_ICONS_PER_ROW)
	end
	FauxScrollFrame_Update(MacroPopupScrollFrame, numIcons, NUM_ICON_ROWS, MACRO_ICON_ROW_HEIGHT );
end

function MacroPopupFrame_CancelEdit()
	MacroPopupFrame:Hide();
	MacroFrame_Update();
	MacroPopupFrame.selectedIcon = nil;
end

function MacroPopupOkayButton_Update()
	local length = strlen(MacroPopupEditBox:GetText());
	if ( length > 0 and MacroPopupFrame.selectedIcon ) then
		MacroPopupOkayButton:Enable();
	else
		MacroPopupOkayButton:Disable();
	end
	if ( MacroPopupFrame.mode == "edit" and length > 0 ) then
		MacroPopupOkayButton:Enable();
	end
end

function MacroPopupButton_SelectTexture(selectedIcon)
	MacroPopupFrame.selectedIcon = selectedIcon;
	local texture = MACRO_ICON_FILENAMES[selectedIcon];
	MacroPopupFrame.selectedIconTexture = texture;
	MacroFrameSelectedMacroButtonIcon:SetTexture("INTERFACE\\ICONS\\"..texture);
	MacroPopupOkayButton_Update();
	MacroPopupFrame_Update();
end

function MacroPopupButton_OnClick()
	MacroPopupButton_SelectTexture(this:GetID());
end

function MacroPopupOkayButton_OnClick()
	local index = 1;
	local macroIcon = MACRO_ICON_FILENAMES[MacroPopupFrame.selectedIcon];
	local macroName = MacroPopupEditBox:GetText();
	if ( MacroPopupFrame.mode == "new" ) then
		index = CreateMacro(macroName, macroIcon, nil, nil, (MacroFrame.macroBase > 0));
	elseif ( MacroPopupFrame.mode == "edit" ) then
		index = EditMacro(MacroFrame.selectedMacro, macroName, macroIcon);
	end
	MacroPopupFrame:Hide();
	MacroFrame_SelectMacro(index);
	MacroFrame_Update();
end

function MacroFrame_SaveMacro()
	if ( MacroFrame.textChanged and MacroFrame.selectedMacro ) then
		EditMacro(MacroFrame.selectedMacro, nil, nil, MacroFrameText:GetText());
		MacroFrame.textChanged = nil;
	end
end

function MacroPopupFrameSearchBox_OnTextChanged()
	wipe(SearchResults);

	for i = 1, getn(MACRO_ICON_FILENAMES) do
		local texture = MACRO_ICON_FILENAMES[i];
		if strfind(texture, strupper(MacroPopupFrameSearchBox:GetText())) then
			tinsert(SearchResults, i);
		end
	end

	MacroPopupScrollFrame:SetVerticalScroll(1);
	MacroPopupFrame_Update();
end
