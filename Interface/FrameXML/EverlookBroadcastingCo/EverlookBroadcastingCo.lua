function ShowEBCMinimapDropdown()
	if EBCMinimapDropdown:IsShown() then
		EBCMinimapDropdown:Hide()
	else
		EBCMinimapDropdown:Show()
	end
end

function EBC_TuneIn(station)
	station = station or this:GetID()
	local s1 = EBCMinimapDropdownCheckButton1:GetChecked()
	local s2 = EBCMinimapDropdownCheckButton2:GetChecked()

	if not s1 and not s2 then
		EBC_SELECTED_STATION = nil
		UIErrorsFrame:AddMessage(format(EBC_STOPPED, EBC_TITLE), 1, 1, 0)
		StopMusic()
		return
	end
	EBC_SELECTED_STATION = station
	EBCMinimapDropdownMuteButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up")
	SetCVar("EnableMusic", 1)
	SendChatMessage(".radio "..station)
	UIErrorsFrame:AddMessage(format(EBC_TUNEDINTO, _G["EBC_STATION"..station]), 1, 1, 0)
end

function EBCMinimapDropdown_OnUpdate(elapsed)
	if not this.timer then
		return
	end
	if MouseIsOver(this) then
		this.timer = UIDROPDOWNMENU_SHOW_TIME
	else
		this.timer = this.timer - elapsed
	end
	if this.timer <= 0 then
		this.timer = nil
		this:Hide()
	end
end
