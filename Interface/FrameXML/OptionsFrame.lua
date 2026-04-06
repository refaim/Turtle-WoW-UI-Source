NUM_CATEGORIES_TO_DISPLAY = 18
NUM_OPTIONS_TO_DISPLAY = 11
NUM_SEARCH_RESULTS_TO_DISPLAY = 20
OPTIONS_OPTION_OFFSET = 34

local categoryButtons, dependencyMap, resultFrames, searchResults = {}, {}, {}, {}
local currentCategory

local function CheckDependency(var, requiredValue)
	local value = _G[var]

	if strfind(var, "%(%)") then
		var = strsub(var, 1, strlen(var) - 2)

		value = _G[var]()
	elseif value == nil then
		value = GetCVar(var)
	end

	return value == requiredValue
end

local function DisableOptionFrame(frame)
	local type = frame.control and frame.control:GetFrameType() or frame:GetFrameType()

	frame.enabled = false

	if type == "Button" then
		frame:Disable()
		return
	elseif type == "CheckButton" then
		frame.control:Disable()
	elseif type == "Frame" then
		frame.control:EnableMouse(0)
		frame.button:Disable()
		frame.text:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	elseif type == "Slider" then
		frame.control:EnableMouse(0)
		frame.minval:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		frame.maxval:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		frame.thumb:Hide()
	end

	frame.label:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
end

local function EnableOptionFrame(frame)
	local type = frame.control and frame.control:GetFrameType() or frame:GetFrameType()

	frame.enabled = true

	if type == "Button" then
		frame:Enable()
		return
	elseif type == "CheckButton" then
		frame.control:Enable()
	elseif type == "Frame" then
		frame.control:EnableMouse(1)
		frame.button:Enable()
		frame.text:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	elseif type == "Slider" then
		frame.control:EnableMouse(1)
		frame.minval:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		frame.maxval:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		frame.thumb:Show()
	end

	frame.label:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end

local function UpdateOptionDependency(frame)
	local dependency = frame.option.dependency
	if not dependency then
		EnableOptionFrame(frame)
		return
	end

	DisableOptionFrame(frame)
	for i = 2, getn(dependency) do
		if CheckDependency(dependency[1], dependency[i]) then
			EnableOptionFrame(frame)
			return
		end
	end
end

local function CheckDependentOptions(var)
	local frames = dependencyMap[var]
	if not frames then return end

	for _, frame in next, frames do
		UpdateOptionDependency(frame)
	end
end

local function OnControlValueChanged(option, value)
	local var

	if option.cvar then
		var = option.cvar
		SetCVar(var, value, option.name)
	elseif option.uvar then
		var = option.uvar
		_G[var] = value
	else
		var = option.getter
		_G[option.setter](tonumber(value))
	end

	if option.func then
		_G[option.func](value)
	end

	if option.restartGx then
		RestartGx()
	end

	option.changedValue = value

	CheckDependentOptions(var)
end

local function UpdateOptions(category, focusOption)
	category = GameOptions[category]

	local buttonWidth = 0
	local indices = { 1, 1, 1 }
	local initialized = category.initialized
	local control, offsetX, offsetY, optionDependency, optionFrame, optionName, optionType, value, variable

	wipe(dependencyMap)

	for _, frame in { OptionsFrameContentScrollFrameChild:GetChildren() } do
		frame:Hide()
	end

	for index, option in ipairs(category.options) do
		offsetX = 30
		offsetY = -14 - ((index - 1) * OPTIONS_OPTION_OFFSET)

		optionDependency = option.dependency
		optionName = _G[option.name]
		optionType = option.type

		if option.cvar then
			value = GetCVar(option.cvar)
		elseif option.uvar then
			value = _G[option.uvar]
		elseif option.getter then
			value = _G[option.getter]()
		end

		if optionType == "button" then
			optionFrame = _G["OptionsFrameButton" .. indices[1]] or CreateFrame("Button", "OptionsFrameButton" .. indices[1], OptionsFrameContentScrollFrameChild, "OptionsButtonTemplateEx")
			optionFrame:SetText(optionName)

			buttonWidth = max(optionFrame:GetTextWidth(), buttonWidth)
			optionFrame:SetWidth(buttonWidth + 32)
			optionFrame:SetScript("OnClick", _G[option.func])

			offsetX = optionDependency and 36 or 28
			offsetY = -8 - ((index - 1) * OPTIONS_OPTION_OFFSET)

			indices[1] = indices[1] + 1
		elseif optionType == "checkbutton" then
			optionFrame = _G["OptionsFrameCheckButton" .. indices[2]] or CreateFrame("Frame", "OptionsFrameCheckButton" .. indices[2], OptionsFrameContentScrollFrameChild, "OptionsCheckButtonTemplateEx")

			control = optionFrame.control
			control:SetChecked(option.inverted and (1 - tonumber(value)) or tonumber(value))

			indices[2] = indices[2] + 1
		elseif optionType == "dropdown" then
			optionFrame = _G["OptionsFrame" .. option.identifier .. "DropDown"] or CreateFrame("Frame", "OptionsFrame" .. option.identifier .. "DropDown", OptionsFrameContentScrollFrameChild, "OptionsDropDownTemplateEx")

			control = optionFrame.control
			UIDropDownMenu_Initialize(control, _G[option.identifier .. "Dropdown_Init"])
		elseif optionType == "slider" then
			optionFrame = _G["OptionsFrameSlider" .. indices[3]] or CreateFrame("Frame", "OptionsFrameSlider" .. indices[3], OptionsFrameContentScrollFrameChild, "OptionsSliderTemplateEx")

			control = optionFrame.control
			control:SetMinMaxValues(option.minval, option.maxval)
			control:SetValueStep(option.step)
			control:SetValue(tonumber(option.inverted and (option.maxval - value + option.minval) or value))

			if option.numberLabels then
				optionFrame.minval:SetText(option.minval)
				optionFrame.maxval:SetText(option.maxval)
			else
				optionFrame.minval:SetText(LOW)
				optionFrame.maxval:SetText(HIGH)
			end

			indices[3] = indices[3] + 1
		end

		optionFrame:SetPoint("TOPLEFT", OptionsFrameContentScrollFrameChild, offsetX, offsetY)
		optionFrame:Show()
		optionFrame.label:SetText(optionName)
		optionFrame.option = option

		if not initialized then
			option.initialValue = value
			option.changedValue = false
		end

		if optionDependency then
			variable = optionDependency[1]
			if strfind(variable, "%(%)") then
				variable = strsub(variable, 1, strlen(variable) - 2)
			end

			dependencyMap[variable] = dependencyMap[variable] or {}
			tinsert(dependencyMap[variable], optionFrame)

			UpdateOptionDependency(optionFrame)

			optionFrame.label:SetPoint("LEFT", optionFrame, option.ignoreOffset and 0 or 10, 0)
		else
			EnableOptionFrame(optionFrame)

			optionFrame.label:SetPoint("LEFT", optionFrame)
		end
	end

	category.initialized = true

	OptionsFrameContentScrollFrame:UpdateScrollChildRect()

	if focusOption and focusOption > NUM_OPTIONS_TO_DISPLAY then
		OptionsFrameContentScrollFrame:SetVerticalScroll((focusOption - NUM_OPTIONS_TO_DISPLAY) * OPTIONS_OPTION_OFFSET)
	end
end

function OptionsFrame_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")

	for i = 1, NUM_CATEGORIES_TO_DISPLAY do
		tinsert(categoryButtons, _G["OptionsFrameCategoryListCategory" .. i])
	end

	for i = 1, NUM_SEARCH_RESULTS_TO_DISPLAY do
		tinsert(resultFrames, _G["OptionsFrameSearchResultsResult" .. i])
	end

	Options_RegisterUVars()

	OptionsFrame_UpdateCategories()
end

function OptionsFrame_OnEvent()
	if ALWAYS_SHOW_MULTIBARS == "1" then
		MultiActionBar_ShowAllGrids()
	end

	BuffButtons_UpdatePositions()
	Options_UpdateCombatText()
end

function OptionsFrame_OnShow()
	if not currentCategory then
		OptionsFrameCategoryListCategory2:Click()
	else
		UpdateOptions(currentCategory)
	end

	OptionsFrameSearchBox:ClearFocus()
	OptionsFrameSearchResults:Hide()

	Disable_BagButtons()
	UpdateMicroButtons()

	FauxScrollFrame_Update(OptionsFrameCategoryListScrollFrame, getn(GameOptions), NUM_CATEGORIES_TO_DISPLAY, 18, nil, nil, nil, OptionsFrameCategoryListHighlight, 180, 180)
end

function OptionsFrame_OnHide()
	for _, category in GameOptions do
		category.initialized = false
	end

	ShowUIPanel(GameMenuFrame)

	UpdateMicroButtons()
end

function OptionsFrame_RevertOptions()
	local value
	for _, category in GameOptions do
		if category.initialized then
			for k, option in category.options do
				if option.changedValue ~= false and option.changedValue ~= option.initialValue then
					value = option.initialValue

					if option.cvar then
						SetCVar(option.cvar, value, option.name)
					elseif option.uvar then
						_G[option.uvar] = value
					elseif option.setter then
						_G[option.setter](value)
					end

					if option.func then
						_G[option.func](value)
					end
				end
			end
		end

		category.initialized = false
	end
end

function OptionsFrame_Search(keepResults)
	if keepResults and sizeof(searchResults) > 0 then
		OptionsFrameSearchResults:Show()
		return
	end

	OptionsFrameSearchResults:Hide()

	wipe(searchResults)

	local query = strlower(trim(this:GetText()))
	if query ~= "" and strlen(query) > 2 then
		for i, category in GameOptions do
			if category.options then
				for k = 1, getn(category.options) do
					local option = category.options[k]
					if option.type ~= "button" and strfind(strlower(_G[option.name]), query, 1, true) then
						option.index = k
						option.category = i
						tinsert(searchResults, option)
					end
				end
			end
		end

		local count = getn(searchResults)
		if count > 0 then
			for _, frame in { OptionsFrameSearchResults:GetChildren() } do
				frame:Hide()
			end
			local button
			for i, option in next, searchResults do
				if i > NUM_SEARCH_RESULTS_TO_DISPLAY then break end

				button = resultFrames[i]
				button.categoryIndex = option.category
				button.optionIndex = option.index
				button.text:SetText("|cffffffff" .. GameOptions[option.category].name .. "|cffcecece > |cffffd100" .. _G[option.name])
				button:Show()
			end

			local height = (count < NUM_SEARCH_RESULTS_TO_DISPLAY and count + 1 or NUM_SEARCH_RESULTS_TO_DISPLAY) * 19 -- result frame height + 1 for offset between frames
			OptionsFrameSearchResults:SetHeight(height)
			OptionsFrameSearchResults:SetPoint("TOPLEFT", OptionsFrameSearchBox, "TOPLEFT", -10, height)
			OptionsFrameSearchResults:Show()
		end
	end
end

function OptionsFrame_SetDefaults(popup)
	if not currentCategory then return end

	if popup then
		StaticPopup_Show("OPTIONS_CONFIRM_DEFAULTS", GameOptions[currentCategory].name)
		return
	end

	local category = GameOptions[currentCategory]
	local value
	for _, option in category.options do
		if option.cvar then
			value = GetCVarDefault(option.cvar)
			SetCVar(option.cvar, value, option.name)
		elseif option.defaultValue then
			value = option.defaultValue
			if option.uvar then
				_G[option.uvar] = value
			elseif option.setter then
				_G[option.setter](value)
			end
		end

		if option.func then
			_G[option.func](value)
		end
	end

	category.initialized = false

	UpdateOptions(currentCategory)
	Options_UpdateCombatText()
end

function OptionsFrame_UpdateCategories()
	local numCategories = getn(GameOptions)
	local overflow = numCategories > NUM_CATEGORIES_TO_DISPLAY
	local scrollOffset = FauxScrollFrame_GetOffset(OptionsFrameCategoryListScrollFrame)

	FauxScrollFrame_Update(OptionsFrameCategoryListScrollFrame, numCategories, NUM_CATEGORIES_TO_DISPLAY, 18, nil, nil, nil, OptionsFrameCategoryListHighlight, 164, 180)

	OptionsFrameCategoryListHighlight:Hide()

	local button, category, offset
	for i = 1, NUM_CATEGORIES_TO_DISPLAY do
		offset = i + scrollOffset
		button = categoryButtons[i]

		if offset > numCategories then
			button:Hide()
		else
			category = GameOptions[offset]
			if category.options then
				button:SetTextFontObject(GameFontHighlight)
				button:EnableMouse(1)
				button:SetID(offset)
				button.text:SetPoint("LEFT", button, 24, 0)

				button.bar:Hide()
			else
				button:SetTextFontObject(GameFontNormal)
				button:EnableMouse(0)
				button:SetID(0)
				button.text:SetPoint("LEFT", button, 12, 0)

				button.bar:Show()
			end

			if overflow then
				button.text:SetWidth(142)
				button.bar:SetWidth(278)
			else
				button.text:SetWidth(158)
				button.bar:SetWidth(314)
			end

			button.text:SetText(category.name)
			button:Show()
		end
	end
end

function OptionsFrameCheckButton_OnClick()
	local option = this:GetParent().option
	local value = this:GetChecked() and (option.inverted and "0" or "1") or (option.inverted and "1" or "0")

	OnControlValueChanged(option, value)

	PlaySound("igMainMenuOptionCheckBoxOn")
end

function OptionsFrameDropdown_OnValueChanged()
	local dropdown = _G[UIDROPDOWNMENU_OPEN_MENU]
	local option = dropdown:GetParent().option
	local value

	value = this.value
	UIDropDownMenu_SetSelectedValue(dropdown, value)

	OnControlValueChanged(option, value)
end

function OptionsFrameSlider_OnValueChanged()
	local option = this:GetParent().option
	local value = option.inverted and (option.maxval - this:GetValue() + option.minval) or this:GetValue()

	OnControlValueChanged(option, value)
end

function OptionsListButton_OnClick(category, focusOption)
	local button = this

	if currentCategory and currentCategory ~= category then
		OptionsFrameContentScrollFrame:SetVerticalScroll(0)
	end

	local id
	for _, frame in categoryButtons do
		id = frame:GetID()
		if id ~= 0 then
			frame:EnableMouse(1)
			if category and id == category then
				button = frame
			end
		end
	end

	button:EnableMouse(0)

	category = button:GetID()

	OptionsFrameCategoryListHighlight:ClearAllPoints()
	OptionsFrameCategoryListHighlight:SetPoint("TOPLEFT", button, -4, 0)
	OptionsFrameCategoryListHighlight:Show()

	if GameOptions[category].options then
		UpdateOptions(category, focusOption)

		currentCategory = category
	end

	OptionsFrameSearchBox:ClearFocus()
	OptionsFrameSearchResults:Hide()

	PlaySound("igMainMenuOptionCheckBoxOff")
end

function OptionsFrameControl_OnEnter(parent)
	local frame = parent and this:GetParent() or this
	local tooltip = frame.option.desc
	local requirement = frame.option.requirement
	local warning = frame.option.warning

	if tooltip then
		GameTooltip:SetOwner(parent and this:GetParent() or this, "ANCHOR_RIGHT", 4, 0)
		GameTooltip:SetText(tooltip, nil, nil, nil, nil, 1)

		if requirement then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(requirement)
		end

		if warning then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(warning, 1.0, 0, 0, true)
		end

		GameTooltip:Show()
	end

	if frame.enabled then
		frame.label:SetTextColor(1, 1, 1)
	end
end

function OptionsFrameControl_OnLeave(parent)
	local frame = parent and this:GetParent() or this

	GameTooltip:Hide()

	if frame.enabled then
		frame.label:SetTextColor(1, .82, 0)
	end
end