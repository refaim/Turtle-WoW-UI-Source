ADDON_BUTTON_HEIGHT = 16;
MAX_ADDONS_DISPLAYED = 19;

function UpdateAddonButton()
	if ( GetNumAddOns() > 0 ) then
		-- Check to see if any of them are out of date and not disabled
		if ( IsAddonVersionCheckEnabled() and AddonList_HasOutOfDate() and not HasShownAddonOutOfDateDialog ) then
			AddonDialog_Show("ADDONS_OUT_OF_DATE");
			HasShownAddonOutOfDateDialog = true;
		end
		if ( AddonList_HasNewVersion() ) then
			CharacterSelectAddonsButtonGlow:Show();
		else
			CharacterSelectAddonsButtonGlow:Hide();
		end
		CharacterSelectAddonsButton:Show();
	else
		CharacterSelectAddonsButton:Hide();
	end
end

function AddonList_OnLoad()
	this.offset = 0;
end

function AddonList_Update()
	local numEntrys = GetNumAddOns();
	local name, title, notes, url, loadable, reason, security, newVersion;
	local addonIndex;
	local entry, checkbox, string, status, urlButton, securityIcon, versionButton;

	-- Get the character from the current list (nil is all characters)
	local character = GlueDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	if ( character == ALL ) then
		character = nil;
	end
	local enabled, checkboxState;

	for i=1, MAX_ADDONS_DISPLAYED do
		addonIndex = AddonList.offset + i;
		entry = getglobal("AddonListEntry"..i);
		if ( addonIndex > numEntrys ) then
			entry:Hide();
		else
			name, title, notes, url, loadable, reason, security, newVersion = GetAddOnInfo(addonIndex);
			-- GetAddOnEnableState() returns 0, 1, 2 (disabled, enabled for some, enabled for all)
			checkboxState = GetAddOnEnableState(character, addonIndex);
			enabled = (checkboxState > 0);

			checkbox = getglobal("AddonListEntry"..i.."Enabled");
			-- If some are enabled then set the checkbox to be gray
			TriStateCheckbox_SetState(checkboxState, checkbox);
			if ( checkboxState == 1 ) then
				checkbox.tooltip = ENABLED_FOR_SOME;
			else
				checkbox.tooltip = nil;
			end

			string = getglobal("AddonListEntry"..i.."Title");
			if ( loadable ) then
				string:SetTextColor(1.0, 0.78, 0.0);
			elseif ( enabled and reason ~= "DEP_DISABLED" ) then
				string:SetTextColor(1.0, 0.1, 0.1);
			else
				string:SetTextColor(0.5, 0.5, 0.5);
			end
			if ( title ) then
				string:SetText(title);
			else
				string:SetText(name);
			end
			urlButton = getglobal("AddonListEntry"..i.."URL");
			versionButton = getglobal("AddonListEntry"..i.."Update");
			if ( url ) then
				if ( newVersion ) then
					versionButton.tooltip = ADDON_UPDATE_AVAILABLE..CLICK_TO_LAUNCH_ADDON_URL..url;
					versionButton.url = url;
					versionButton:Show();
					urlButton:Hide();
				else
					versionButton:Hide();
					urlButton.tooltip = CLICK_TO_LAUNCH_ADDON_URL..url;
					urlButton.url = url;
					urlButton:Show();
				end
				
			else
				versionButton:Hide();
				urlButton:Hide();
			end
			securityIcon = getglobal("AddonListEntry"..i.."SecurityIcon");
			if ( security == "SECURE" ) then
				AddonList_SetSecurityIcon(securityIcon, 1);
			elseif ( security == "INSECURE" ) then
				AddonList_SetSecurityIcon(securityIcon, 2);
			elseif ( security == "BANNED" ) then
				AddonList_SetSecurityIcon(securityIcon, 3);
			end
			getglobal("AddonListEntry"..i.."Security").tooltip = getglobal("ADDON_"..security);
			string = getglobal("AddonListEntry"..i.."Status");
			if ( reason ) then
				string:SetText(TEXT(getglobal("ADDON_"..reason)));
			else
				string:SetText("");
			end

			entry:SetID(addonIndex);
			entry:Show();
		end
	end

	-- ScrollFrame stuff
	GlueScrollFrame_Update(AddonListScrollFrame, numEntrys, MAX_ADDONS_DISPLAYED, ADDON_BUTTON_HEIGHT);
end

function AddonTooltip_BuildDeps(...)
	local deps = "";
	for i=1, arg.n do
		if ( i == 1 ) then
			deps = TEXT(ADDON_DEPENDENCIES)..arg[i];
		else
			deps = deps..", "..arg[i];
		end
	end
	return deps;
end

function AddonTooltip_Update(owner)
	AddonTooltip.owner = owner;
	local name, title, notes = GetAddOnInfo(owner:GetID());
	if ( title ) then
		AddonTooltipTitle:SetText(title);
	else
		AddonTooltipTitle:SetText(name);
	end
	AddonTooltipNotes:SetText(notes);
	AddonTooltipDeps:SetText(AddonTooltip_BuildDeps(GetAddOnDependencies(owner:GetID())));

	local titleHeight = AddonTooltipTitle:GetHeight();
	local notesHeight = AddonTooltipNotes:GetHeight();
	local depsHeight = AddonTooltipDeps:GetHeight();
	AddonTooltip:SetHeight(10+titleHeight+2+notesHeight+2+depsHeight+10);
end

function AddonList_OnKeyDown()
	if ( arg1 == "ESCAPE" ) then
		AddonList_OnCancel();
	elseif ( arg1 == "ENTER" ) then
		AddonList_OnOk();
	elseif ( arg1 == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function AddonList_Enable(index, enabled)
	local character = GlueDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	if ( character == ALL ) then
		character = nil;
	end
	if ( enabled ) then
		EnableAddOn(character, index);
	else
		DisableAddOn(character, index);
	end
	AddonList_Update();
end

function AddonList_OnOk()
	PlaySound("gsLoginChangeRealmOK");
	SetScriptMemory(ScriptMemory:GetText());
	SaveAddOns();
	AddonList:Hide();
end

function AddonList_OnCancel()
	PlaySound("gsLoginChangeRealmCancel");
	ResetAddOns();
	AddonList:Hide();
end

function AddonListScrollFrame_OnVerticalScroll()
	local scrollbar = getglobal(this:GetName().."ScrollBar");
	scrollbar:SetValue(arg1);
	AddonList.offset = floor((arg1 / ADDON_BUTTON_HEIGHT) + 0.5);
	AddonList_Update();
	if ( AddonTooltip:IsVisible() ) then
		AddonTooltip_Update(AddonTooltip.owner);
	end
end

function AddonList_OnShow()
	ScriptMemory:SetText(GetScriptMemory());
	ScriptMemory:ClearFocus();
	AddonList_Update();
end

function AddonList_HasOutOfDate()
	local hasOutOfDate = false;
	for i=1, GetNumAddOns() do
		local name, title, notes, url, loadable, reason = GetAddOnInfo(i);
		if ( enabled and not loadable and reason == "INTERFACE_VERSION" ) then
			hasOutOfDate = true;
			break;
		end
	end
	return hasOutOfDate;
end

function AddonList_SetSecurityIcon(texture, index)
	local width = 64;
	local height = 16;
	local iconWidth = 16;
	local increment = iconWidth/width;
	local left = (index - 1) * increment;
	local right = index * increment;
	texture:SetTexCoord( left, right, 0, 1.0);
end

function AddonList_DisableOutOfDate()
	for i=1, GetNumAddOns() do
		local name, title, notes, url, loadable, reason = GetAddOnInfo(i);
		if ( enabled and not loadable and reason == "INTERFACE_VERSION" ) then
			DisableAddOn(i);
		end
	end
end

function AddonList_HasNewVersion()
	local hasNewVersion = false;
	for i=1, GetNumAddOns() do
		local name, title, notes, url, loadable, reason, security, newVersion = GetAddOnInfo(i);
		if ( newVersion ) then
			hasNewVersion = true;
			break;
		end
	end
	return hasNewVersion;
end

AddonDialogTypes = { };

AddonDialogTypes["ADDONS_OUT_OF_DATE"] = {
	text = TEXT(ADDONS_OUT_OF_DATE),
	button1 = TEXT(DISABLE_ADDONS),
	button2 = TEXT(LOAD_ADDONS),
	OnAccept = function()
		AddonDialog_Show("CONFIRM_DISABLE_ADDONS");
	end,
	OnCancel = function()
		AddonDialog_Show("CONFIRM_LOAD_ADDONS");
	end,
}

AddonDialogTypes["CONFIRM_LOAD_ADDONS"] = {
	text = TEXT(CONFIRM_LOAD_ADDONS),
	button1 = TEXT(OKAY),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		SetAddonVersionCheck(0);
	end,
	OnCancel = function()
		AddonDialog_Show("ADDONS_OUT_OF_DATE");
	end,
}

AddonDialogTypes["CONFIRM_DISABLE_ADDONS"] = {
	text = TEXT(CONFIRM_DISABLE_ADDONS),
	button1 = TEXT(OKAY),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		AddonList_DisableOutOfDate();
	end,
	OnCancel = function()
		AddonDialog_Show("ADDONS_OUT_OF_DATE");
	end,
}

AddonDialogTypes["CONFIRM_LAUNCH_ADDON_URL"] = {
	text = TEXT(CONFIRM_LAUNCH_ADDON_URL),
	button1 = TEXT(OKAY),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		LaunchAddOnURL(AddonList.selectedID);
	end
}

function AddonDialog_Show(which, arg1)
	-- Set the text of the dialog
	if ( arg1 ) then
		AddonDialogText:SetText(format(AddonDialogTypes[which].text, arg1));
	else
		AddonDialogText:SetText(AddonDialogTypes[which].text);
	end

	-- Set the buttons of the dialog
	if ( AddonDialogTypes[which].button2 ) then
		AddonDialogButton1:ClearAllPoints();
		AddonDialogButton1:SetPoint("BOTTOMRIGHT", "AddonDialogBackground", "BOTTOM", -6, 16);
		AddonDialogButton2:ClearAllPoints();
		AddonDialogButton2:SetPoint("LEFT", "AddonDialogButton1", "RIGHT", 13, 0);
		AddonDialogButton2:SetText(AddonDialogTypes[which].button2);
		AddonDialogButton2:Show();
	else
		AddonDialogButton1:ClearAllPoints();
		AddonDialogButton1:SetPoint("BOTTOM", "AddonDialogBackground", "BOTTOM", 0, 16);
		AddonDialogButton2:Hide();
	end

	AddonDialogButton1:SetText(AddonDialogTypes[which].button1);

	-- Set the miscellaneous variables for the dialog
	AddonDialog.which = which;

	-- Finally size and show the dialog
	AddonDialogBackground:SetHeight(16 + AddonDialogText:GetHeight() + 8 + AddonDialogButton1:GetHeight() + 16);
	AddonDialog:Show();
end

function AddonDialog_OnClick(index)
	AddonDialog:Hide();
	if ( index == 1 ) then
		local OnAccept = AddonDialogTypes[AddonDialog.which].OnAccept;
		if ( OnAccept ) then
			OnAccept();
		end
	else
		local OnCancel = AddonDialogTypes[AddonDialog.which].OnCancel;
		if ( OnCancel ) then
			OnCancel();
		end
	end
end

function AddonDialog_OnKeyDown()
	if ( arg1 == "PRINTSCREEN" ) then
		Screenshot();
		return;
	end

	if ( arg1 == "ESCAPE" ) then
		if ( AddonDialogButton2:IsVisible() ) then
			AddonDialogButton2:Click();
		else
			AddonDialogButton1:Click();
		end
	elseif (arg1 == "ENTER" ) then
		AddonDialogButton1:Click();
	end
end

function AddonListCharacterDropDown_OnClick()
	GlueDropDownMenu_SetSelectedValue(AddonCharacterDropDown, this.value);
	AddonList_Update();
end

function AddonListCharacterDropDown_Initialize()
	local selectedValue = GlueDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	local info;

	info = {};
	info.text = ALL;
	info.value = ALL;
	info.func = AddonListCharacterDropDown_OnClick;
	if ( not selectedValue ) then
		info.checked = 1;
	end
	GlueDropDownMenu_AddButton(info);

	for i=1, GetNumCharacters() do
		info = {};
		info.text = GetCharacterInfo(i);
		info.value = GetCharacterInfo(i);
		info.func = AddonListCharacterDropDown_OnClick;
		if ( selectedValue == info.value ) then
			info.checked = 1;
		end
		GlueDropDownMenu_AddButton(info);
	end
end