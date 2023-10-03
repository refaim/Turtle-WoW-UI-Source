local _G, _ = _G or getfenv()
local EBC_Frame = CreateFrame("Frame")
EBC_Frame:RegisterEvent("VARIABLES_LOADED")

EBC_Frame:SetScript("OnEvent", function()
	if event == "VARIABLES_LOADED" then
		StopMusic()
		EBC_CreateFrame()
	end
end)

function ShowEBCMinimapDropdown()
    if EBCMinimapDropdown:IsVisible() then
		EBCMinimapDropdown:Hide()
	else
		EBCMinimapDropdown:Show()
	end
end

function EBC_TuneIn(station)
	local s1 = EBCMinimapDropdown.CheckButton1:GetChecked() or false
	local s2 = EBCMinimapDropdown.CheckButton2:GetChecked() or false
	
	if not s1 and not s2 then 
		EBC_Alert(EBC_STOPPED..EBC_TITLE..EBC_FORNOW)
		StopMusic()
		return
	end
	
	EBCMinimapDropdown.MuteButton:SetBackdrop({bgFile = "Interface\\Buttons\\UI-GuildButton-MOTD-Up",})
	SetCVar("EnableMusic", 1)
	SendChatMessage(".radio "..station,"SAY" ,nil)
	EBC_Alert(EBC_TUNEDINTO.._G["EBC_STATION"..station].."!")
end

function EBC_Alert(txt)
	UIErrorsFrame:AddMessage(txt,1, 1, 1, 1,4);
	DEFAULT_CHAT_FRAME:AddMessage(txt);
end

function EBC_CreateFrame()

	local uiScale = GetCVar("uiScale")
	local res = GetCVar("gxResolution")

	-- Create the Drowndown Frame
	local EBCMinimapDropdown = CreateFrame("Frame", "EBCMinimapDropdown", UIParent)
	EBCMinimapDropdown:SetFrameStrata("DIALOG")
	EBCMinimapDropdown:SetPoint("TOPRIGHT", EBC_Minimap, "BOTTOMLEFT", 10, 10)
	EBCMinimapDropdown:SetWidth(215-math.floor(uiScale*10))
	EBCMinimapDropdown:SetHeight(105)
	EBCMinimapDropdown:SetBackdrop({
	  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	  tile = true, tileSize = 16, edgeSize = 16,
	  insets = { left = 4, right = 4, top = 4, bottom = 3 }
	})
	EBCMinimapDropdown:SetClampedToScreen()
	EBCMinimapDropdown:Hide()

	-- Title
	EBCMinimapDropdown.title = CreateFrame("Frame", "EBCMinimapDropdownTitle", EBCMinimapDropdown)
	EBCMinimapDropdown.title:SetPoint("TOPLEFT", EBCMinimapDropdown, "TOPLEFT")
	EBCMinimapDropdown.title:SetWidth(205-math.floor(uiScale*10))
	EBCMinimapDropdown.title:SetHeight(69)

	-- Title Text
	EBCMinimapDropdown.title.text = EBCMinimapDropdown.title:CreateFontString(nil, "HIGH", "GameFontNormal")
	EBCMinimapDropdown.title.text:SetText(EBC_TITLE)
	if res == "1280x720" then
		EBCMinimapDropdown.title.text:SetFont("Fonts\\FRIZQT__.TTF", 14)
	elseif res == "1024x768" or res == "1280x600" or "800x600" then
		EBCMinimapDropdown.title.text:SetFont("Fonts\\FRIZQT__.TTF", 13)
	else
		EBCMinimapDropdown.title.text:SetFont("Fonts\\FRIZQT__.TTF", 15)
	end
	EBCMinimapDropdown.title.text:SetPoint("TOPLEFT", 13, -10)

	-- Volume Slider
	EBCMinimapDropdown.slider = CreateFrame("Slider", "EBCMinimapDropdownSlider", EBCMinimapDropdown, "OptionsSliderTemplate")
	EBCMinimapDropdown.slider:SetPoint("BOTTOMLEFT", EBCMinimapDropdown, "BOTTOMLEFT", 10, 7)
	EBCMinimapDropdown.slider:SetWidth(125)
	EBCMinimapDropdown.slider:SetHeight(20)
	EBCMinimapDropdown.slider:SetOrientation('HORIZONTAL')
	EBCMinimapDropdown.slider:SetMinMaxValues(0, 100)
	EBCMinimapDropdown.slider:SetValue(math.floor(GetCVar("MusicVolume")*100))
	EBCMinimapDropdown.slider:SetValueStep(1)
	getglobal(EBCMinimapDropdown.slider:GetName() .. 'Low'):SetText('')
	getglobal(EBCMinimapDropdown.slider:GetName() .. 'High'):SetText('')
	getglobal(EBCMinimapDropdown.slider:GetName() .. 'Text'):SetText('')
	EBCMinimapDropdown.slider:EnableMouseWheel(true)
	EBCMinimapDropdown.slider:SetScript("OnValueChanged",function()
		SetCVar("MusicVolume",EBCMinimapDropdown.slider:GetValue()/100)
		EBCMinimapDropdown.VolText.text:SetText(EBCMinimapDropdown.slider:GetValue())
		PlaySound("igMiniMapZoomIn","SFX")
	end)
	EBCMinimapDropdown.slider:SetScript("OnMouseWheel", function()
		local val = EBCMinimapDropdown.slider:GetValue()
		if arg1 == 1 then
			val=val+10
		else
			val=val-10
		end
		SetCVar("MusicVolume",val/100)
		EBCMinimapDropdown.slider:SetValue(val)
	 end)

	-- Volume Text
	EBCMinimapDropdown.VolText = CreateFrame("Frame", "EBCMinimapDropdownVolText", EBCMinimapDropdown)
	EBCMinimapDropdown.VolText:SetPoint("BOTTOMLEFT", EBCMinimapDropdown, "BOTTOMLEFT", 2,2)
	EBCMinimapDropdown.VolText:SetWidth(8)
	EBCMinimapDropdown.VolText:SetHeight(8)

	EBCMinimapDropdown.VolText.text = EBCMinimapDropdown.VolText:CreateFontString(nil, "HIGH", "GameFontNormal")
	EBCMinimapDropdown.VolText.text:SetText(EBCMinimapDropdown.slider:GetValue())
	EBCMinimapDropdown.VolText.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
	EBCMinimapDropdown.VolText.text:SetPoint("BOTTOMLEFT", 135, 10)

	-- Mute Button
	EBCMinimapDropdown.MuteButton = CreateFrame("Frame", "EBCMinimapDropdownMuteButton", EBCMinimapDropdown)
	EBCMinimapDropdown.MuteButton:SetWidth(18)
	EBCMinimapDropdown.MuteButton:SetHeight(18)
		if GetCVar("EnableMusic") == "1" then
			EBCMinimapDropdown.MuteButton:SetBackdrop({bgFile = "Interface\\Buttons\\UI-GuildButton-MOTD-Up",})
		else
			EBCMinimapDropdown.MuteButton:SetBackdrop({bgFile = "Interface\\Buttons\\UI-GuildButton-MOTD-Disabled",})
		end
	EBCMinimapDropdown.MuteButton:SetPoint("BOTTOMRIGHT", EBCMinimapDropdown, "BOTTOMRIGHT", -15, 7)

	EBCMinimapDropdown.MuteButton:EnableMouse(true)
	EBCMinimapDropdown.MuteButton:SetScript("OnMouseDown", function()
		if GetCVar("EnableMusic") == "1" then
			EBCMinimapDropdown.MuteButton:SetBackdrop({bgFile = "Interface\\Buttons\\UI-GuildButton-MOTD-Disabled",})
			SetCVar("EnableMusic", 0)
			EBCMinimapDropdown.CheckButton1:SetChecked(0)
			EBCMinimapDropdown.CheckButton2:SetChecked(0)
			StopMusic()
			GameTooltip:SetText("|cffffd000 Enable",1,1,1,1)
		else
			EBCMinimapDropdown.MuteButton:SetBackdrop({bgFile = "Interface\\Buttons\\UI-GuildButton-MOTD-Up",})
			GameTooltip:SetText("|cffffd000 "..EBC_MUTE,1,1,1,1)
			SetCVar("EnableMusic", 1)
		end
	end)
	EBCMinimapDropdown.MuteButton:SetScript("OnEnter", function()
		local state = EBC_UNMUTE
		if GetCVar("EnableMusic") == "1" then state = EBC_MUTE end
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText("|cffffd000"..state,1,1,1,1)
	end)
	EBCMinimapDropdown.MuteButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- Station Checkbox
	EBCMinimapDropdown.CheckButton1 = CreateFrame("CheckButton", "EBCMinimapDropdownCheckButton", EBCMinimapDropdown.title, "UICheckButtonTemplate")
	EBCMinimapDropdown.CheckButton1:SetPoint("LEFT", 8, -8)
	EBCMinimapDropdown.CheckButton1:SetWidth(30)
	EBCMinimapDropdown.CheckButton1:SetHeight(30)
	
	EBCMinimapDropdown.CheckButton1:SetScript("OnEnter", function()
		local state = EBC_TUNEIN
		if this:GetChecked() == 1 then state = EBC_TUNEOUT end
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:SetText("|cffffd000"..state,1,1,1,1)
	end)
	EBCMinimapDropdown.CheckButton1:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	EBCMinimapDropdown.CheckButton1:SetScript("OnClick", function()
		local state = EBC_TUNEIN
		if this:GetChecked() == 1 then state = EBC_TUNEOUT end
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:SetText("|cffffd000"..state,1,1,1,1)
		EBCMinimapDropdown.CheckButton2:SetChecked(0)
		EBC_TuneIn(1)
	end)
	
	-- Station Text
	EBCMinimapDropdown.RaidoText = CreateFrame("Frame", "EBCMinimapDropdownRadio", EBCMinimapDropdown.CheckButton1)
	EBCMinimapDropdown.RaidoText:SetPoint("TOP", EBCMinimapDropdown.CheckButton1, "TOP", 0, 0)
	EBCMinimapDropdown.RaidoText:SetWidth(10)
	EBCMinimapDropdown.RaidoText:SetHeight(10)

	EBCMinimapDropdown.RaidoText.text = EBCMinimapDropdown.RaidoText:CreateFontString(nil, "HIGH", "GameFontNormal")
	EBCMinimapDropdown.RaidoText.text:SetText("|cffffffff"..EBC_STATION1)
	if res == "1280x720" or res == "1024x768" or res == "1280x600" then
		EBCMinimapDropdown.RaidoText.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
	elseif "800x600" then
		EBCMinimapDropdown.RaidoText.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
	else
		EBCMinimapDropdown.RaidoText.text:SetFont("Fonts\\FRIZQT__.TTF", 13)
	end
	EBCMinimapDropdown.RaidoText.text:SetPoint("LEFT", 23, -9)

	-- Station 2 Checkbox
	EBCMinimapDropdown.CheckButton2 = CreateFrame("CheckButton", "EBCMinimapDropdownCheckButton2", EBCMinimapDropdown.CheckButton1, "UICheckButtonTemplate")
	EBCMinimapDropdown.CheckButton2:SetPoint("LEFT", 0, -22)
	EBCMinimapDropdown.CheckButton2:SetWidth(30)
	EBCMinimapDropdown.CheckButton2:SetHeight(30)
	
	EBCMinimapDropdown.CheckButton2:SetScript("OnEnter", function()
		local state = EBC_TUNEIN
		if this:GetChecked() == 1 then state = EBC_TUNEOUT end
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:SetText("|cffffd000"..state,1,1,1,1)
	end)
	EBCMinimapDropdown.CheckButton2:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	EBCMinimapDropdown.CheckButton2:SetScript("OnClick", function()
		local state = EBC_TUNEIN
		if this:GetChecked() == 1 then state = EBC_TUNEOUT end
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:SetText("|cffffd000"..state,1,1,1,1)
		EBCMinimapDropdown.CheckButton1:SetChecked(0)
		EBC_TuneIn(2)
	end)
	
	-- Station 2 Text
	EBCMinimapDropdown.RaidoText2 = CreateFrame("Frame", "EBCMinimapDropdownRadio2", EBCMinimapDropdown.CheckButton2)
	EBCMinimapDropdown.RaidoText2:SetPoint("TOP", EBCMinimapDropdown.CheckButton2, "TOP", 0, 0)
	EBCMinimapDropdown.RaidoText2:SetWidth(10)
	EBCMinimapDropdown.RaidoText2:SetHeight(10)

	EBCMinimapDropdown.RaidoText2.text = EBCMinimapDropdown.RaidoText2:CreateFontString(nil, "HIGH", "GameFontNormal")
	EBCMinimapDropdown.RaidoText2.text:SetText("|cffffffff"..EBC_STATION2)
	if res == "1280x720" or res == "1024x768" or res == "1280x600" then
		EBCMinimapDropdown.RaidoText2.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
	elseif "800x600" then
		EBCMinimapDropdown.RaidoText2.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
	else
		EBCMinimapDropdown.RaidoText2.text:SetFont("Fonts\\FRIZQT__.TTF", 13)
	end
	EBCMinimapDropdown.RaidoText2.text:SetPoint("LEFT", 23, -9)

end
