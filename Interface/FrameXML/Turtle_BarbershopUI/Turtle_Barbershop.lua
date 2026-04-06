BARBERSHOP_PREFIX = "TW_BARBERSHOP"

UIPanelWindows["BarbershopFrame"] = { area = "center", pushable = 0 }

local Barbershop = {}
local _, race = UnitRace("player")
local gender = UnitSex("player") - 1
local isInSession = false
local purchaseCost = 0
local savedCameraYaw = false
local restoreHelm = false
local sequence = 104 -- Sit on high chair

local Customizations = {
	-- Hair Style
	[1] = {
		old = 1,
		selected = 1,
		available = {
			Human = { 17, 26 },
			Dwarf = { 17, 19 },
			Gnome = { 12, 12 },
			NightElf = { 12, 12 },
			BloodElf = { 16, 20 },
			Orc = { 13, 14 },
			Troll = { 10, 10 },
			Tauren = { 13, 12 },
			Scourge = { 16, 17 },
			Goblin = { 14, 17 },
		},
	},
	-- Hair Color
	[2] = {
		old = 1,
		selected = 1,
		available = {
			Human = { 10, 10 },
			Dwarf = { 10, 10 },
			Gnome = { 10, 10 },
			NightElf = { 10, 10 },
			BloodElf = { 16, 16 },
			Orc = { 8, 8 },
			Troll = { 10, 10 },
			Tauren = { 9, 9 },
			Scourge = { 11, 11 },
			Goblin = { 5, 5 },
		},
	},
	-- Facial Hair
	[3] = {
		old = 1,
		selected = 1,
		available = {
			Human = { 9, 7 },
			Dwarf = { 21, 6 },
			Gnome = { 12, 7 },
			NightElf = { 14, 10 },
			BloodElf = { 11, 11 },
			Orc = { 11, 7 },
			Troll = { 14, 10 },
			Tauren = { 9, 7 },
			Scourge = { 17, 8 },
			Goblin = { 10, 5 },
		},
	},
}

local DelayFrame = CreateFrame("Frame")
DelayFrame:Hide()
DelayFrame.elapsed = 0
DelayFrame:SetScript("OnUpdate", function()
	if not DelayFrame.func then return end
	if DelayFrame.elapsed >= DelayFrame.time then
		DelayFrame.elapsed = 0
		DelayFrame.func()
		DelayFrame:Hide()
		DelayFrame.func = nil
		return
	end
	DelayFrame.elapsed = DelayFrame.elapsed + arg1
end)

local function Delay(time, func)
	DelayFrame.func = func
	DelayFrame.time = time
	DelayFrame.elapsed = 0
	DelayFrame:Show()
end

function BarbershopModel_OnLoad()
	BarbershopModel:SetRotation(0)
	BarbershopModel:SetLight(1, 0, -0.3, 1, -1, 1, 0.7, 0.7, 0.7, 1, 0.8, 0.8, 0.64)
	BarbershopModel:RegisterEvent("UNIT_MODEL_CHANGED")
end

local function Refresh()
	BarbershopModel:SetPosition(0, 0, 0)
	BarbershopModel:RefreshUnit()
	BarbershopModel:SetPosition(0, 0, -0.5)
end

function BarbershopModel_OnEvent()
	if arg1 == "player" and isInSession then
		Delay(0.6, Refresh)
		SetPortraitTexture(MicroButtonPortrait, "")
	end
end

function BarbershopModel_OnKeyDown()
	local screenshotKey = GetBindingKey("SCREENSHOT")
	if arg1 == "ESCAPE" then
		HideUIPanel(BarbershopFrame)
	elseif screenshotKey and (arg1 == screenshotKey) then
		RunBinding("SCREENSHOT")
	end
end

function BarbershopModel_OnShow()
	BarbershopModel:SetWidth(GetScreenWidth() + 10)
	BarbershopModel:SetHeight(GetScreenHeight() + 10)
	BarbershopModel:SetPosition(0, 0, 0)
	BarbershopModel:SetUnit("player")
	BarbershopModel:SetFacing(0)
	BarbershopModel:SetPosition(0, 0, -0.5)
	BarbershopModel:SetScript("OnKeyDown", BarbershopModel_OnKeyDown)
	BarbershopModel.start = GetTime()
	BarbershopModel:SetSequence(sequence)
	PlayerFrame:Hide()
	TargetFrame:Hide()
	SetPortraitTexture(MicroButtonPortrait, "")
	BarbershopBackground:SetWidth(BarbershopModel:GetWidth())
	BarbershopBackground:SetHeight(BarbershopModel:GetHeight())
	BarbershopBackground:Show()
end

function BarbershopModel_OnHide()
	BarbershopModel:SetPosition(0, 0, 0)
	PlayerFrame:Show()
	if UnitExists("target") then
		TargetFrame:Show()
	end
	SetPortraitTexture(MicroButtonPortrait, "player")
	BarbershopBackground:Hide()
end

function BarbershopModel_OnUpdateModel()
	local time = (GetTime() - (BarbershopModel.start or GetTime())) * 1000
	BarbershopModel:SetSequenceTime(sequence, time)
end

function BarbershopModel_OnUpdate()
	if BarbershopModel.mousedown then
		local endX, endY = GetCursorPosition()
		BarbershopModel:SetFacing((endX - BarbershopModel.startX) / 120 + BarbershopModel:GetFacing())
		BarbershopModel.startX, BarbershopModel.startY = GetCursorPosition()
	end
	if not BarbershopModel.fadeTime then return end
	if (GetTime() - BarbershopModel.fadeTime) > 0.3 then
		BarbershopModel.fadeTime = nil
		BarbershopModel:Hide()
	end
end

function BarbershopModel_OnMouseDown()
	BarbershopModel.mousedown = true
	BarbershopModel.startX, BarbershopModel.startY = GetCursorPosition()
end

function BarbershopModel_OnMouseUp()
	BarbershopModel.mousedown = false
end

function Barbershop:GetCustomizationLabel(customization)
	local token = race == "Tauren" and "HORNS" or "NORMAL"

	if customization == 1 then
		return _G["HAIR_"..token.."_STYLE"]
	elseif customization == 2 then
		return _G["HAIR_"..token.."_COLOR"]
	end

	token = "NORMAL"
	-- Female-specific labels
	if gender == 2 then
		if race == "NightElf" then
			token = "MARKINGS"
		elseif race == "Gnome" or race == "BloodElf" then
			token = "EARRINGS"
		elseif race == "Tauren" then
			token = "HAIR"
		else
			token = "PIERCINGS"
		end
	end

	if race == "Scourge" or race == "Goblin" then
		token = "FEATURES"
	end

	if race == "Troll" then
		token = "TUSKS"
	end

	return _G["FACIAL_HAIR_"..token]
end

function Barbershop:SetupCamera()
	-- Save current view and flip camera to face the player
	SetView(1)
	FlipCameraYaw(180)
	CameraZoomOut(2)
	savedCameraYaw = true
	if ShowingHelm() then
		restoreHelm = true
	end
	ShowHelm(false)
end

function Barbershop:RestoreCamera()
	if not savedCameraYaw then return end
	FlipCameraYaw(180)  -- Flip back
	SetView(2)
	savedCameraYaw = false
	if restoreHelm then
		restoreHelm = false
		ShowHelm(true)
	end
end

function Barbershop:Send(message)
	SendAddonMessage(BARBERSHOP_PREFIX, message, "GUILD")
end

function Barbershop:PreviewCustomization(customization, index)
	local msgType = ""
	if customization == 1 then
		msgType = "C2S_PREVIEW_STYLE"
	elseif customization == 2 then
		msgType = "C2S_PREVIEW_COLOR"
	elseif customization == 3 then
		msgType = "C2S_PREVIEW_FACIAL_HAIR"
	end
	self:Send(msgType .. ADDON_MSG_FIELD_DELIMITER .. (index - 1))
end

function Barbershop:Purchase()
	self:Send("C2S_PURCHASE")
end

function Barbershop:Reset()
	self:Send("C2S_RESET")
end

function Barbershop:Close()
	self:Send("C2S_CLOSE")
end

function Barbershop:Update()
	-- Update selectors
	for i = 1, 3 do
		local total = Customizations[i].available[race][gender]
		local selected = Customizations[i].selected
		_G["BarbershopFrameSelector"..i.."Category"]:SetText(self:GetCustomizationLabel(i).." "..selected.."/"..total)
	end

	-- Update buttons
	-- Enable if style, color, or facial hair changed
	if Customizations[1].selected ~= Customizations[1].old
		or Customizations[2].selected ~= Customizations[2].old
		or Customizations[3].selected ~= Customizations[3].old then
		BarbershopFrameOkayButton:Enable()
		BarbershopFrameResetButton:Enable()
	else
		BarbershopFrameOkayButton:Disable()
		BarbershopFrameResetButton:Disable()
	end

	-- Update money frame
	MoneyFrame_Update("BarbershopFrameMoneyFrame", purchaseCost)
end

function Barbershop:HandleOpenBarber(args)
	if isInSession then return end
	-- Args: cost|current_style|available_styles|current_color|available_colors|current_facial_hair|available_facial_hairs (colon-separated)
	purchaseCost = tonumber(args[1]) or 0

	for i = 1, 3 do
		Customizations[i].old = (tonumber(args[i * 2]) or 0) + 1
		Customizations[i].selected = Customizations[i].old
		-- local available = args[i * 2 + 1]
		-- if available and available ~= "" then
		--     Customizations[i].available = explode(available, SUBFIELD_DELIMITER, Customizations[i].available)
		--     for j = 1, getn(Customizations[i].available) do
		--         Customizations[i].available[j] = tonumber(Customizations[i].available[j])
		--     end
		-- end
	end

	-- Update session state
	isInSession = true

	-- Setup camera to face player
	self:SetupCamera()

	-- Show the frame
	ShowUIPanel(BarbershopFrame)

	BarbershopFrame:ClearAllPoints()
	BarbershopFrame:SetPoint("RIGHT", min(-50, -CONTAINER_OFFSET_X), -50)

	self:Update()
end

function Barbershop:HandleUpdatePreview(args)
	-- Fields received (0-indexed):
	-- fields[1] = cost (dynamic, calculated based on changes)
	-- fields[2] = currentStyle
	-- fields[3] = currentColor
	-- fields[4] = currentFacialHair
	if getn(args) < 4 then return end

	purchaseCost = tonumber(args[1]) or 0
	Customizations[1].selected = (tonumber(args[2]) or 0) + 1
	Customizations[2].selected = (tonumber(args[3]) or 0) + 1
	Customizations[3].selected = (tonumber(args[4]) or 0) + 1

	self:Update()
end

function Barbershop:HandlePurchaseResult(args)
	-- Args: success|style|color|facial_hair
	if getn(args) < 4 then return end

	if args[1] == "1" then
		purchaseCost = 0
		Customizations[1].old = Customizations[1].selected
		Customizations[2].old = Customizations[2].selected
		Customizations[3].old = Customizations[3].selected
		self:Update()
		PlaySound("MONEYFRAMEOPEN")
	end
end

function Barbershop:HandleError(args)
	-- Args: error_message
	if getn(args) < 1 then return end
	local text = _G["BARBERSHOP_ERROR"..args[1]]
	if text then
		UIErrorsFrame:AddMessage(text, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	end
end

function Barbershop:HandleCloseBarber()
	isInSession = false
	purchaseCost = 0

	-- Restore camera before hiding frame
	self:RestoreCamera()
	HideUIPanel(BarbershopFrame)
end

function BarbershopFrame_OnLoad()
	this:RegisterEvent("CHAT_MSG_ADDON")
	this:RegisterEvent("PLAYER_MONEY")
	this:RegisterEvent("PLAYER_LOGIN")
end

local args = {}

function BarbershopFrame_OnEvent()
	if event == "CHAT_MSG_ADDON" and arg1 == BARBERSHOP_PREFIX then
		args = explode(arg2, ADDON_MSG_FIELD_DELIMITER, args)

		if getn(args) == 0 then return end

		local msgType = args[1]

		-- Extract args (everything after the message type)
		tremove(args, 1)

		-- Handle message types
		if msgType == "S2C_OPEN_BARBER" then
			Barbershop:HandleOpenBarber(args)
		elseif msgType == "S2C_UPDATE_PREVIEW" then
			Barbershop:HandleUpdatePreview(args)
		elseif msgType == "S2C_PURCHASE_RESULT" then
			Barbershop:HandlePurchaseResult(args)
		elseif msgType == "S2C_ERROR" then
			Barbershop:HandleError(args)
		elseif msgType == "S2C_CLOSE_BARBER" then
			Barbershop:HandleCloseBarber()
		end

	elseif event == "PLAYER_MONEY" then
		if isInSession then
			Barbershop:Update()
		end

	elseif event == "PLAYER_LOGIN" then
		Barbershop:Close()
	end
end

function BarbershopFrame_OnShow()
	UIFrameFadeIn(BarbershopModel, 0.3, 0, 1)
	UIFrameFadeIn(BarbershopBackground, 0.3, 0, 1)
	Disable_BagButtons()
	PlaySound("igCharacterInfoOpen")
end

function BarbershopFrame_OnHide()
	PlaySound("igCharacterInfoClose")
	Barbershop:RestoreCamera()
	-- If still in session when frame is hidden (e.g., Escape pressed), send close message
	if isInSession then
		Barbershop:Close()
	end
	BarbershopModel:SetScript("OnKeyDown", nil)
	BarbershopModel.fadeTime = GetTime()
	UIFrameFadeOut(BarbershopModel, 0.3, 1, 0)
	UIFrameFadeOut(BarbershopBackground, 0.3, 1, 0)
	Enable_BagButtons()
end

function BarbershopFrameOkayButton_OnClick()
	if not isInSession then return end
	Barbershop:Purchase()
end

function BarbershopFrameCancelButton_OnClick()
	if isInSession then
		Barbershop:Close()
	else
		HideUIPanel(BarbershopFrame)
	end
end

function BarbershopFrameResetButton_OnClick()
	if not isInSession then return end
	Barbershop:Reset()
	-- Reset local state to original
	Customizations[1].selected = Customizations[1].old
	Customizations[2].selected = Customizations[2].old
	Customizations[3].selected = Customizations[3].old
	Barbershop:Update()
	PlaySound("igMainMenuOptionCheckBoxOn")
end

function BarbershopSelector_OnClick(dir)
	local id = this:GetParent():GetID()
	local newIndex = Customizations[id].selected + dir
	local total = Customizations[id].available[race][gender]
	if newIndex < 1 then
		newIndex = total
	elseif newIndex > total then
		newIndex = 1
	end
	Barbershop:PreviewCustomization(id, newIndex)
	PlaySound("igMainMenuOptionCheckBoxOn")
end
