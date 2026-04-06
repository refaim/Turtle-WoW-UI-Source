local multisampleFormats = { GetMultisampleFormats() }
local refreshRates = { GetRefreshRates() }
local screenResolutions = { GetScreenResolutions() }

function CameraFollowStyleDropdown_Init()
	local dropdown = _G[UIDROPDOWNMENU_INIT_MENU]
	local value = GetCVar("cameraSmoothStyle")
	local info = UIDropDownMenu_CreateInfo()

	info.func = OptionsFrameDropdown_OnValueChanged

	info.text = CAMERA_NEVER
	info.value = 0
	UIDropDownMenu_AddButton(info)

	info.text = CAMERA_SMART
	info.value = 1
	UIDropDownMenu_AddButton(info)

	info.text = CAMERA_ALWAYS
	info.value = 2
	UIDropDownMenu_AddButton(info)

	UIDropDownMenu_SetSelectedValue(dropdown, tonumber(value))
end

function ClickToMoveDropdown_Init()
	local dropdown = _G[UIDROPDOWNMENU_INIT_MENU]
	local value = GetCVar("cameraSmoothTrackingStyle")
	local info = UIDropDownMenu_CreateInfo()

	info.func = OptionsFrameDropdown_OnValueChanged

	info.text = CAMERA_NEVER
	info.value = 0
	UIDropDownMenu_AddButton(info)

	info.text = CAMERA_SMART
	info.value = 1
	UIDropDownMenu_AddButton(info)

	info.text = CAMERA_LOCKED
	info.value = 2
	UIDropDownMenu_AddButton(info)

	UIDropDownMenu_SetSelectedValue(dropdown, tonumber(value))
end

function CombatTextModeDropdown_Init()
	local dropdown = _G[UIDROPDOWNMENU_INIT_MENU]
	local info = UIDropDownMenu_CreateInfo()
	local value = COMBAT_TEXT_FLOAT_MODE

	info.func = function()
		OptionsFrameDropdown_OnValueChanged()
		Options_UpdateCombatText()
	end

	info.text = COMBAT_TEXT_SCROLL_UP
	info.value = "1"
	UIDropDownMenu_AddButton(info)

	info.text = COMBAT_TEXT_SCROLL_DOWN
	info.value = "2"
	UIDropDownMenu_AddButton(info)

	info.text = COMBAT_TEXT_SCROLL_ARC
	info.value = "3"
	UIDropDownMenu_AddButton(info)

	UIDropDownMenu_SetSelectedValue(dropdown, value)
end

function DisplayMultisamplingDropdown_Init()
	local dropdown = _G[UIDROPDOWNMENU_INIT_MENU]
	local colorBits, depthBits, multiSample, checked
	local value = GetCurrentMultisampleFormat()
	local info = UIDropDownMenu_CreateInfo()
	local index = 1

	info.func = OptionsFrameDropdown_OnValueChanged

	for i = 1, getn(multisampleFormats), 3 do
		colorBits = multisampleFormats[i]
		depthBits = multisampleFormats[i + 1]
		multiSample = multisampleFormats[i + 2]
		info.text = format(MULTISAMPLING_FORMAT_STRING, colorBits, depthBits, multiSample)
		info.value = index
		UIDropDownMenu_AddButton(info)

		index = index + 1
	end

	UIDropDownMenu_SetSelectedValue(dropdown, value)
end

function DisplayRefreshDropdown_Init()
	local dropdown = _G[UIDROPDOWNMENU_INIT_MENU]
	local info = UIDropDownMenu_CreateInfo()
	local value = GetCVar("gxRefresh")

	info.func = OptionsFrameDropdown_OnValueChanged

	for _, rate in refreshRates do
		info.text = rate .. HERTZ
		info.value = rate
		UIDropDownMenu_AddButton(info)
	end

	UIDropDownMenu_SetSelectedValue(dropdown, tonumber(value))
end

function DisplayResolutionDropdown_Init()
	local dropdown = _G[UIDROPDOWNMENU_INIT_MENU]
	local info = UIDropDownMenu_CreateInfo()
	local value = GetCurrentResolution()
	local xIndex, width, height

	info.func = OptionsFrameDropdown_OnValueChanged

	for i, res in screenResolutions do
		xIndex = strfind(res, "x")
		width = strsub(res, 1, xIndex - 1)
		height = strsub(res, xIndex + 1, strlen(res))

		info.text = (width/height > 4/3) and (res .. " " .. WIDESCREEN_TAG) or res
		info.value = i
		UIDropDownMenu_AddButton(info)
	end

	UIDropDownMenu_SetSelectedValue(dropdown, value)
end

function GroupDebuffIndicatorStyleDropdown_Init()
	local dropdown = _G[UIDROPDOWNMENU_INIT_MENU]
	local info = UIDropDownMenu_CreateInfo()
	local value = GROUP_DEBUFF_INDICATOR_STYLE

	info.func = OptionsFrameDropdown_OnValueChanged

	info.text = SYMBOL
	info.value = "1"
	UIDropDownMenu_AddButton(info)

	info.text = SYMBOL .. ' + ' .. EMBLEM_BORDER
	info.value = "2"
	UIDropDownMenu_AddButton(info)

	info.text = EMBLEM_SYMBOL
	info.value = "3"
	UIDropDownMenu_AddButton(info)

	info.text = EMBLEM_SYMBOL .. ' + ' .. EMBLEM_BORDER
	info.value = "4"
	UIDropDownMenu_AddButton(info)

	info.text = EMBLEM_BORDER
	info.value = "5"
	UIDropDownMenu_AddButton(info)

	UIDropDownMenu_SetSelectedValue(dropdown, value)
end

function GroupUnitGrowDirectionDropdown_Init()
	local dropdown = _G[UIDROPDOWNMENU_INIT_MENU]
	local info = UIDropDownMenu_CreateInfo()
	local value = GROUP_UNIT_GROW_DIRECTION

	info.func = OptionsFrameDropdown_OnValueChanged

	info.text = VERTICAL
	info.value = "1"
	UIDropDownMenu_AddButton(info)

	info.text = HORIZONTAL
	info.value = "2"
	UIDropDownMenu_AddButton(info)

	UIDropDownMenu_SetSelectedValue(dropdown, value)
end

function GroupUnitHealthColorDropdown_Init()
	local dropdown = _G[UIDROPDOWNMENU_INIT_MENU]
	local info = UIDropDownMenu_CreateInfo()
	local value = GROUP_UNIT_HEALTH_COLOR

	info.func = OptionsFrameDropdown_OnValueChanged

	info.text = GROUP_UNIT_HEALTH_STATIC
	info.value = "1"
	UIDropDownMenu_AddButton(info)

	info.text = GROUP_UNIT_HEALTH_MISSING_HEALTH
	info.value = "2"
	UIDropDownMenu_AddButton(info)

	info.text = GROUP_UNIT_HEALTH_CLASS
	info.value = "3"
	UIDropDownMenu_AddButton(info)

	UIDropDownMenu_SetSelectedValue(dropdown, value)
end

function TargetOfTargetDropdown_Init()
	local dropdown = _G[UIDROPDOWNMENU_INIT_MENU]
	local info = UIDropDownMenu_CreateInfo()
	local value = SHOW_TARGET_OF_TARGET_STATE

	info.func = OptionsFrameDropdown_OnValueChanged

	info.text = RAID
	info.value = "1"
	UIDropDownMenu_AddButton(info)

	info.text = PARTY
	info.value = "2"
	UIDropDownMenu_AddButton(info)

	info.text = SOLO
	info.value = "3"
	UIDropDownMenu_AddButton(info)

	info.text = RAID_AND_PARTY
	info.value = "4"
	UIDropDownMenu_AddButton(info)

	info.text = ALWAYS
	info.value = "5"
	UIDropDownMenu_AddButton(info)

	UIDropDownMenu_SetSelectedValue(dropdown, value)
end

function WorldAppearanceAnisotropicDropdown_Init()
	local dropdown = _G[UIDROPDOWNMENU_INIT_MENU]
	local info = UIDropDownMenu_CreateInfo()
	local value = GetCVar("anisotropic")

	info.func = OptionsFrameDropdown_OnValueChanged

	info.text = "1x"
	info.value = 1
	UIDropDownMenu_AddButton(info)

	info.text = "2x"
	info.value = 2
	UIDropDownMenu_AddButton(info)

	info.text = "4x"
	info.value = 4
	UIDropDownMenu_AddButton(info)

	info.text = "8x"
	info.value = 8
	UIDropDownMenu_AddButton(info)

	info.text = "16x"
	info.value = 16
	UIDropDownMenu_AddButton(info)

	UIDropDownMenu_SetSelectedValue(dropdown, tonumber(value))
end

function Options_UpdateCombatText()
	if SHOW_COMBAT_TEXT == "1" then
		UIParentLoadAddOn("Blizzard_CombatText")
	end
	if IsAddOnLoaded("Blizzard_CombatText") then
		CombatText_UpdateDisplayedMessages()
	end
end

function Options_SetSimpleChat()
	if SIMPLE_CHAT == "1" then
		FCF_Set_SimpleChat()
	else
		FCF_Set_NormalChat()
	end
end

function Options_UpdateTutorials(value)
	if value == 1  then
		ResetTutorials()
		TutorialFrameCheckButton:SetChecked(1)
	else
		ClearTutorials()
	end
	TutorialFrame_HideAllAlerts()
end

function Options_ResetTutorials()
	if TutorialsEnabled() == 1 then
		TutorialFrame_HideAllAlerts()
		ResetTutorials()
	end
end

function UpdateNameplates()
	if NAMEPLATES_ON then
		ShowNameplates()
	else
		HideNameplates()
	end
	if ( FRIENDNAMEPLATES_ON ) then
		ShowFriendNameplates()
	else
		HideFriendNameplates()
	end
end

function Options_ToggleMusic()
	if GetCVar("EnableMusic") == "1" then
		SetCVar("EnableMusic", 0)
	else
		SetCVar("EnableMusic", 1)
	end
end

function Options_ToggleSound()
	if GetCVar("MasterSoundEffects") == "0" then
		SetCVar("MasterSoundEffects", 1)
	else
		SetCVar("MasterSoundEffects", 0)
	end
end

function Options_MasterVolumeUp()
	local masterVolume = GetCVar("MasterVolume") + 0
	if masterVolume < 1.0 then
		masterVolume = masterVolume + 0.1
		SetCVar("MasterVolume", masterVolume)
	end
end

function Options_MasterVolumeDown()
	local masterVolume = GetCVar("MasterVolume") + 0
	if masterVolume > 0.0 then
		masterVolume = masterVolume - 0.1
		SetCVar("MasterVolume", masterVolume)
	end
end