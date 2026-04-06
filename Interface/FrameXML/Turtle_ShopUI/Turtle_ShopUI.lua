local MaxEntries = 8
local ClaimID = 0
local Balance = 0
local Sex = UnitSex("player") - 1 -- 1 - male, 2 - female
local CurrentPage = 1

local ShopPrefix = "TW_SHOP"
local _, Race = UnitRace("player")
Race = strlower(Race)

local DebugMode = false
local NeedRefresh = true
local ShowSubcategories = true

local CurrentCategory = nil
local CurrentSubcategory = nil
local ShopEntries = nil

local CategoryFrames = {}

TWS_HIDE_MINIMAP_BUTTON = TWS_HIDE_MINIMAP_BUTTON or 0
TWS_AUTODRESS = TWS_AUTODRESS or 0
RegisterForSave("TWS_HIDE_MINIMAP_BUTTON")
RegisterForSave("TWS_AUTODRESS")

-- Player model positions for previews in fashion category
-- [inventorySlotID] = {
--	 [race] = {
--		 [1] = { z, x, y, facingNormal, facingSpecial }, -- male
--		 [2] = { z, x, y, facingNormal, facingSpecial }, -- female
--	 },
-- },
local Positions = {}
-- Head
Positions[1] = {
	human =     { { 2.1,   0,    -0.8,  0.5 }, { 1.85,  0,    -0.73, 0.5 } },
	dwarf =     { { 1.6,   0,    -0.34, 0.5 }, { 1.5,   0,    -0.43, 0.5 } },
	gnome =     { { 0.8,   0,    -0.3,  0.5 }, { 0.8,   0,    -0.2,  0.5 } },
	nightelf =  { { 3,     0,    -0.95, 0.5 }, { 3,     0,    -0.8,  0.5 } },
	bloodelf =  { { 2.8,   0.03, -0.89, 0.5 }, { 2.15,  0.06, -0.71, 0.5 } },
	orc =       { { 2,    -0.11, -0.71, 0.5 }, { 2.3,  -0.01, -0.63, 0.5 } },
	troll =     { { 2.45, -0.03, -0.53, 0.5 }, { 2.8,   0.01, -0.68, 0.5 } },
	tauren =    { { 2,    -0.23, -0.52, 0.5 }, { 2,    -0.04, -0.41, 0.5 } },
	scourge =   { { 1.8,  -0.01, -0.68, 0.5 }, { 1.9,  -0.03, -0.6,  0.5 } },
	goblin =    { { 1.2,  -0.02, -0.33, 0.5 }, { 1.5,   0.04, -0.28, 0.5 } },
}
-- Shoulders
Positions[3] = {
	human =     { { 1.7,  0.04, -0.6,  0.73 }, { 1.8,  0.04, -0.54, 0.73 } },
	dwarf =     { { 1.2,  0.06, -0.21, 0.73 }, { 1.3,  0.01, -0.27, 0.73 } },
	gnome =     { { 0.8,  0.07, -0.05, 0.73 }, { 0.8,  0.06, -0.11, 0.73 } },
	nightelf =  { { 2.6,  0.04, -0.79, 0.73 }, { 2.6,  0,    -0.65, 0.73 } },
	bloodelf =  { { 2.4,  0.07, -0.69, 0.73 }, { 2.15, 0.08, -0.62, 0.73 } },
	orc =       { { 1.2,  0.03, -0.54, 0.73 }, { 2,    0.09, -0.51, 0.73 } },
	troll =     { { 2,   -0.06, -0.43, 0.73 }, { 2.7,  0.06, -0.48, 0.73 } },
	tauren =    { { 1.6, -0.02, -0.55, 0.73 }, { 2,    0.03, -0.31, 0.73 } },
	scourge =   { { 1.6,  0.01, -0.58, 0.73 }, { 2,   -0.01, -0.47, 0.73 } },
	goblin =    { { 1.2,  0.06, -0.2,  0.73 }, { 1.5,  0.03, -0.15, 0.73 } },
}
-- Back
Positions[15] = {
	human =     { { 1,    0,    0,    3 }, { 0.9, 0,    0,    3 } },
	dwarf =     { { 0.8,  0,    0.2,  3 }, { 0.8, 0,    0.15, 3 } },
	gnome =     { { 0.7,  0,    0.17, 3 }, { 0.7, 0,    0.17, 3 } },
	nightelf =  { { 1,    0,    0,    3 }, { 1.1, 0.1, -0.06, 3 } },
	bloodelf =  { { 1,    0,    0,    3 }, { 1,   0,    0,    3 } },
	orc =       { { 0.9,  0.02, 0.03, 3 }, { 0.9, 0.01, 0.07, 3 } },
	troll =     { { 1,    0,    0,    3 }, { 1,   0,    0.11, 3 } },
	tauren =    { { 1,    0,    0.04, 3 }, { 0.8, 0,    0.14, 3 } },
	scourge =   { { 0.75, 0,    0,    3 }, { 1,   0.01, 0.12, 3 } },
	goblin =    { { 0.8,  0.01, 0.17, 3 }, { 1,   0.01, 0.26, 3 } },
}
-- Chest
Positions[5] = {
	human =     { { 1.6,  0.02, -0.39, 0.3 }, { 1.2,  0.02, -0.33, 0.3 } },
	dwarf =     { { 1.2,  0.02, -0.08, 0.3 }, { 1.2,  0,    -0.14, 0.3 } },
	gnome =     { { 0.8,  0,     0,    0.3 }, { 0.8,  0,     0,    0.3 } },
	nightelf =  { { 2.4,  0.02, -0.56, 0.3 }, { 2.4, -0.04, -0.44, 0.3 } },
	bloodelf =  { { 2,    0,    -0.43, 0.3 }, { 1.6,  0.06, -0.36, 0.3 } },
	orc =       { { 1.6,  0.05, -0.38, 0.3 }, { 2,    0.03, -0.4,  0.3 } },
	troll =     { { 2,   -0.01, -0.28, 0.3 }, { 2,    0.02, -0.25, 0.3 } },
	tauren =    { { 1.6, -0.01, -0.31, 0.3 }, { 1.6,  0,    -0.11, 0.3 } },
	scourge =   { { 1.6, -0.06, -0.41, 0.3 }, { 1.6, -0.01, -0.29, 0.3 } },
	goblin =    { { 1.2,  0,    -0.09, 0.3 }, { 1.2,  0,     0,    0.3 } },
}
-- Tabard
Positions[19] = Positions[5]
-- Shirt
Positions[4] = Positions[5]
-- Wrist
Positions[9] = {
	human =     { { 1.6, 0.03, -0.07, 1.5 }, { 1.6,  0.06, -0.08, 1.5 } },
	dwarf =     { { 1.2, 0.04,  0.23, 1.5 }, { 1.3,  0,     0.15, 1.5 } },
	gnome =     { { 1.2, 0.08,  0.21, 1.5 }, { 1,    0.11,  0.23, 1.5 } },
	nightelf =  { { 2.8, 0.02, -0.13, 1.5 }, { 2.8,  0.09, -0.09, 1.5 } },
	bloodelf =  { { 2.1, 0.05, -0.11, 1.5 }, { 2,    0.04, -0.1,  1.5 } },
	orc =       { { 1.8, 0.04,  0.04, 1.5 }, { 1.9,  0.05, -0.01, 1.5 } },
	troll =     { { 2.1, 0.07,  0.35, 1.5 }, { 2.4,  0.01,  0.14, 1.5 } },
	tauren =    { { 1.6, 0,     0.04, 1.5 }, { 1.6,  0.01,  0.32, 1.5 } },
	scourge =   { { 1.6, 0.06, -0.03, 1.5 }, { 2,   -0.03, -0.09, 1.5 } },
	goblin =    { { 1,   0.06,  0.21, 1.5 }, { 1.4,  0.11,  0.36, 1.5 } },
}
-- Hands
Positions[10] = Positions[9]
-- Waist
Positions[6] = {
	human =     { { 2,    0.02, -0.16, 0 }, { 1.6,  0.01, -0.13, 0 } },
	dwarf =     { { 1.5,  0,     0.18, 0 }, { 1.5,  0,     0.13, 0 } },
	gnome =     { { 1.2,  0,     0.21, 0 }, { 1.2,  0,     0.22, 0 } },
	nightelf =  { { 3.2,  0.01, -0.28, 0 }, { 2.8, -0.03, -0.19, 0 } },
	bloodelf =  { { 2.5,  0,    -0.28, 0 }, { 2,    0.04, -0.16, 0 } },
	orc =       { { 2.4,  0.03, -0.14, 0 }, { 2,   -0.01, -0.07, 0 } },
	troll =     { { 2.8,  0,     0,    0 }, { 2.8,  0,     0,    0 } },
	tauren =    { { 2.4,  0,     0,    0 }, { 2,    0,     0.33, 0 } },
	scourge =   { { 2,   -0.08, -0.23, 0 }, { 2.3, -0.01, -0.13, 0 } },
	goblin =    { { 1.2,  0,     0.22, 0 }, { 1.65, 0.01,  0.26, 0 } },
}
-- Legs
Positions[7] = {
	human =     { { 1.2,  0.01, 0.25, 0 }, { 0.8, -0.01, 0.19, 0 } },
	dwarf =     { { 1.2,  0,    0.4,  0 }, { 1.2,  0,    0.35, 0 } },
	gnome =     { { 1.2,  0.01, 0.29, 0 }, { 1,    0,    0.25, 0 } },
	nightelf =  { { 1.6, -0.03, 0.3,  0 }, { 1.6, -0.01, 0.26, 0 } },
	bloodelf =  { { 1.6, -0.06, 0.16, 0 }, { 1.2,  0.09, 0.19, 0 } },
	orc =       { { 1.6,  0.06, 0.29, 0 }, { 1.2,  0.01, 0.29, 0 } },
	troll =     { { 1.9, -0.02, 0.5,  0 }, { 1.6, -0.01, 0.39, 0 } },
	tauren =    { { 2,    0,    0.38, 0 }, { 1.6,  0,    0.64, 0 } },
	scourge =   { { 1.2, -0.06, 0.15, 0 }, { 1.6,  0.01, 0.26, 0 } },
	goblin =    { { 1.2,  0,    0.31, 0 }, { 1.6,  0,    0.39, 0 } },
}
-- Feet
Positions[8] = {
	human =     { { 1.6,  0.02, 0.43, 0 }, { 1.6, -0.01, 0.53, 0 } },
	dwarf =     { { 1.2,  0,    0.57, 0 }, { 1.5, -0.03, 0.59, 0 } },
	gnome =     { { 1.2,  0.01, 0.31, 0 }, { 1.2,  0,    0.38, 0 } },
	nightelf =  { { 2.4,  0.04, 0.62, 0 }, { 2.4,  0.03, 0.58, 0 } },
	bloodelf =  { { 2,   -0.06, 0.42, 0 }, { 2,    0.14, 0.58, 0 } },
	orc =       { { 1.6,  0.07, 0.52, 0 }, { 1.8,  0.03, 0.65, 0 } },
	troll =     { { 2.4, -0.01, 0.8,  0 }, { 2.4, -0.05, 0.84, 0 } },
	tauren =    { { 2,   -0.04, 0.63, 0 }, { 2,    0,    0.9,  0 } },
	scourge =   { { 1.6, -0.05, 0.43, 0 }, { 1.9,  0,    0.46, 0 } },
	goblin =    { { 1.1,  0,    0.41, 0 }, { 1.6, -0.01, 0.53, 0 } },
}
-- Weapon
Positions[16] = {
	human =     { { 1.2,  0,     0,    1, -0.6  }, { 0.8,  0,     0,    1, -0.9 } },
	dwarf =     { { 0.4,  0,     0.06, 1, -0.6  }, { 0.4,  0,     0.09, 1, -0.6 } },
	gnome =     { { 0.4,  0,     0,    1, -0.6  }, { 0.4, -0.04,  0.07, 1, -0.6 } },
	nightelf =  { { 1.2,  0.11,  0.03, 1, -1.25 }, { 1.6,  0,    -0.16, 1, -1.5 } },
	bloodelf =  { { 1.6, -0.03, -0.1,  1, -0.6  }, { 1.2, -0.01, -0.14, 1, -1.5 } },
	orc =       { { 0.7,  0,     0,    1, -0.6  }, { 0.75, 0,     0,    1, -0.6 } },
	troll =     { { 0.4,  0,     0.1,  1, -1.25 }, { 0.8,  0.01,  0.08, 1, -1.5 } },
	tauren =    { { 0.4,  0,     0,    1, -0.6  }, { 0.4,  0,     0.1,  1, -0.6 } },
	scourge =   { { 0.4,  0,     0,    1, -0.6  }, { 0.8,  0,     0,    1, -0.6 } },
	goblin =    { { 0.4,  0,     0.03, 1, -0.9  }, { 0.7,  0,     0.02, 1, -1.5 } },
}
-- Off-hand
Positions[17] = Positions[16]
-- Ranged
Positions[18] = Positions[16]

local InvTypeToSlot = {
	["INVTYPE_HEAD"] = 1,
	["INVTYPE_SHOULDER"] = 3,
	["INVTYPE_CLOAK"] = 15,
	["INVTYPE_CHEST"] = 5,
	["INVTYPE_ROBE"] = 5,
	["INVTYPE_WAIST"] = 6,
	["INVTYPE_LEGS"] = 7,
	["INVTYPE_FEET"] = 8,
	["INVTYPE_WRIST"] = 9,
	["INVTYPE_HAND"] = 10,
	["INVTYPE_BODY"] = 4,
	["INVTYPE_TABARD"] = 19,
	["INVTYPE_WEAPON"] = 16,
	["INVTYPE_2HWEAPON"] = 16,
	["INVTYPE_WEAPONMAINHAND"] = 16,
	["INVTYPE_SHIELD"] = 17,
	["INVTYPE_WEAPONOFFHAND"] = 17,
	["INVTYPE_HOLDABLE"] = 17,
	["INVTYPE_RANGED"] = 18,
	["INVTYPE_THROWN"] = 18,
	["INVTYPE_RANGEDRIGHT"] = 18,
}

-- utils
local function IsRed(r, g ,b)
	return r > 0.9 and g < 0.2 and b < 0.2
end

local function IsSearching()
	return ShopFrameSearchBox:GetText() ~= ""
end

local function debugprint(...)
	if not DebugMode then return end
	for i = 1, arg.n do arg[i] = tostring(arg[i]) end
	local msg = table.concat(arg, " ") or ""
	DEFAULT_CHAT_FRAME:AddMessage("["..format("%.3f",GetTime()).."|r] "..msg)
end

local function Send(msg)
	SendAddonMessage(ShopPrefix, msg, "GUILD")
end
--

local ShopDelay = CreateFrame("Frame")
ShopDelay.ready = false
ShopDelay:SetScript("OnUpdate", function()
	this.elapsed = this.elapsed or 0
	if this.ready then
		if ShopEntries then
			this:SetScript("OnUpdate", nil)
			this:Hide()
			MinimapShopFrame:Enable()
			if GameMenuButtonShop then
				GameMenuButtonShop:Enable()
			end
		end
	else
		if this.elapsed >= 0.5 then
			Send("Balance")
			Send("Categories")

			this.ready = true
		end
		this.elapsed = this.elapsed + arg1
	end
end)

function ShopFrame_OnLoad()
	tinsert(UISpecialFrames, this:GetName())
	this:RegisterEvent("CHAT_MSG_ADDON")
	this:RegisterEvent("VARIABLES_LOADED")
	this:RegisterEvent("CHAT_MSG_SYSTEM")
	this.selected = nil
	this:RegisterForDrag("LeftButton")
	ShopFrameAutoDressLabel:ClearAllPoints()
	ShopFrameAutoDressLabel:SetPoint("RIGHT", "ShopFrameAutoDress", "LEFT", -2, 0)
end

function ShopFrame_OnShow()
	Send("Balance")
	if NeedRefresh then
		Shop_RefreshEntries()
	end
	PlaySound("igCharacterInfoOpen")
end

local learnedAbility = gsub(ERR_LEARN_ABILITY_S, "%%s", ".+")
local learnedSpell = gsub(ERR_LEARN_SPELL_S, "%%s", ".+")

function ShopFrame_OnEvent()
	if event == "VARIABLES_LOADED" then
		MinimapShopFrame:Disable()
		if GameMenuButtonShop then
			GameMenuButtonShop:Disable()
		end
		if TWS_HIDE_MINIMAP_BUTTON == 0 then
			MinimapShopFrame:Show()
		else
			MinimapShopFrame:Hide()
		end
		if TWS_AUTODRESS == 0 then
			ShopFrameAutoDress:SetChecked(nil)
		else
			ShopFrameAutoDress:SetChecked(1)
		end
		return
	end

	if event == "CHAT_MSG_SYSTEM" then
		local learned = strfind(arg1 or "", learnedAbility) or strfind(arg1 or "", learnedSpell)
		if learned then
			if ShopFrame and ShopFrame:IsShown() then
				Shop_RefreshEntries()
				ShopFrame_Search()
			else
				NeedRefresh = true
			end
		end
		return
	end

	if event == "CHAT_MSG_ADDON" and arg1 == ShopPrefix then
		local message = arg2
		if string.find(message, "Balance:", 1, true) then
			Shop_ProcessBalance(message)
			return
		end

		if string.find(message, "Entries:", 1, true) then
			Shop_ProcessEntries(message)
			return
		end

		if string.find(message, "Categories:", 1, true) then
			Shop_ProcessCategories(message)
			return
		end

		if string.find(message, "BuyResult:", 1, true) then
			Shop_ProcessBuyResult(message)
			return
		end
	end
end

function Shop_ProcessBalance(arg)
	local balance = gsub(arg, "Balance:", "")
	balance = tonumber(balance) or 0
	Balance = balance
	ShopFrameBalance:SetText(DONO_SHOP_BALANCE .. Balance)
end

function Shop_RefreshEntries()
	if not ShopEntries then
		return
	end
	for k in pairs(ShopEntries) do
		ShopEntries[k] = nil
		Send("Entries:" .. k)
	end
	ShopDelay.elapsed = 0
	ShopDelay:Show()
	ShopDelay:SetScript("OnUpdate", function()
		if this.elapsed >= 1.5 then
			this:SetScript("OnUpdate", nil)
			this:Hide()
			Shop_ShowEntries(CurrentCategory, CurrentSubcategory)
		else
			this.elapsed = this.elapsed + arg1
		end
	end)
	NeedRefresh = false
end

function Shop_ProcessCategories(arg)
	arg = string.gsub(arg, ":", ":0=0=" .. DONO_SHOP_ABOUT_TITLE .. "=about;")

	local categories = gsub(arg, "Categories:", "")
	if not categories then
		return
	end
	local cats = explode(categories, ";")
	for _, cat in pairs(cats) do
		local _, _, id, parent, name, icon = strfind(cat, "(%d+)=(%d+)=(.+)=(.+)")
		if id then
			local categoryID = tonumber(id)
			local parentID = tonumber(parent)

			-- fetch category entries
			Send("Entries:" .. categoryID)

			if parentID > 0 then
				-- category has a parentID which means it's a subcategory
				local frame = CreateFrame("Button", "ShopFrameSubcategoryFrame" .. parentID .. categoryID,
					ShopFrameCategoriesScrollFrameChild, "ShopSubcategoryFrameTemplate")

				tinsert(CategoryFrames[parentID].subcategories, frame)

				frame:SetID(parentID)
				frame.subcategoryID = categoryID

				_G[frame:GetName() .. "Name"]:SetText(name)
			else
				local frame = CreateFrame("Button", "ShopFrameCategoryFrame" .. categoryID,
					ShopFrameCategoriesScrollFrameChild, "ShopCategoryFrameTemplate")
				frame:SetID(categoryID)

				_G[frame:GetName() .. "Name"]:SetText(name)
				_G[frame:GetName() .. "IconTexture"]:SetTexture("Interface\\ShopFrame\\" .. icon)

				CategoryFrames[categoryID] = frame
			end
		end
	end

	ShopFrameCategoriesScrollFrame:SetVerticalScroll(0)
	ShopFrameCategoriesScrollFrame:UpdateScrollChildRect()
end

function ShopFrameCategoryButton_OnClick(category, subcategory)
	ShopFrameSearchBox:ClearFocus()

	if category ~= CurrentCategory then
		ShowSubcategories = true
	end

	CurrentCategory = category
	CurrentSubcategory = subcategory
	CurrentPage = 1

	-- update currently selected category highlight
	if ShopFrame.selected then
		ShopFrame.selected:Hide()
	end
	ShopFrame.selected = _G[this:GetName() .. "Selected"]
	ShopFrame.selected:Show()

	if subcategory then
		ShowSubcategories = false
		Shop_ShowEntries(category, subcategory)
		return
	end

	for i, frame in CategoryFrames do
		if frame.subcategories then
			for _, subFrame in frame.subcategories do
				subFrame:Hide()
			end
		end

		frame:SetPoint("TOPLEFT", ShopFrameCategoriesScrollFrameChild, "TOPLEFT", 2, 30 - 36 * (i + 1))
	end

	if category == 0 then
		ShopFramePageText:Hide()
		ShopFramePreviousButton:Hide()
		ShopFramePreviousButton:Disable()
		ShopFrameNextButton:Hide()
		ShopFrameNextButton:Disable()
		ShopFrameClaimButton:Hide()

		ShopFrameAboutFrame:Show()
		ShopFrameAboutFrameLongText:SetText(DONO_SHOP_ABOUT_TEXT)

		ShopFrameCategoriesScrollFrame:UpdateScrollChildRect()
		ShopFrameClaimButton:Disable()
		ShopFrame_HideEntries()
		return
	end

	ShopFrameAboutFrame:Hide()
	ShopFrameClaimButton:Show()

	if this.subcategories and sizeof(this.subcategories) > 0 and ShowSubcategories then
		local emptySubcategories = sizeof(this.subcategories)
		for _, frame in this.subcategories do
			frame.empty = true
			for _, entry in ShopEntries[category] do
				if entry.subcategory == frame.subcategoryID then
					frame.empty = false
					emptySubcategories = emptySubcategories - 1
					break
				end
			end
		end
		for i = category, sizeof(CategoryFrames) do
			if CategoryFrames[i + 1] then
				CategoryFrames[i + 1]:SetPoint("TOPLEFT", ShopFrameCategoriesScrollFrameChild,
					"TOPLEFT", 2, 30 - 36 * (i + 2) - 30 * (sizeof(this.subcategories) - emptySubcategories))
			end
		end
		local subcatIndex = 1
		for i = 1, sizeof(this.subcategories) do
			local frame = this.subcategories[i]
			if not frame.empty then
				subcatIndex = subcatIndex + 1
				frame:SetPoint("TOPLEFT", ShopFrameCategoriesScrollFrameChild, "TOPLEFT", 8, 18 - (36 * category) - (30 * subcatIndex))
				frame:Show()
			end
		end
	end

	ShopFrameCategoriesScrollFrame:UpdateScrollChildRect()
	ShowSubcategories = not ShowSubcategories
	ShopFrameSearchBox:ClearFocus()
	Shop_ShowEntries(category)
end

function Shop_ProcessEntries(arg)
	ShopEntries = ShopEntries or {}

	if strfind(arg, "=start$") or strfind(arg, "=end$") then return end

	arg = gsub(arg, "Entries:", "")
	local info = explode(arg, "=")
	local catId = tonumber(info[1])
	if not catId then return end

	ShopEntries[catId] = ShopEntries[catId] or {}

	local entry = {
		category = catId,
		subcategory = tonumber(info[2]),
		name = info[3],
		price = tonumber(info[4]),
		-- text = info[5],
		id = tonumber(info[6]),
		modelid = tonumber(info[7]),
		itemid = tonumber(info[8]),
		posx = tonumber(info[9]),
		posy = tonumber(info[10]),
		posz = tonumber(info[11]),
		rotation = tonumber(info[12]),
		holiday = tonumber(info[13]),
		-- colors = info[14] or "",
		gender = tonumber(info[15]) or 0,
		restricted = false,
		hidden = false,
	}

	-- force cache item
	local itemLink = "item:" .. entry.id .. ":0:0:0"
	for i = 2, 15 do
		_G["ShopFrameScanTooltipTextLeft"..i]:SetTextColor(0, 0, 0)
		_G["ShopFrameScanTooltipTextRight"..i]:SetTextColor(0, 0, 0)
	end
	ShopFrameScanTooltip:ClearLines()
	ShopFrameScanTooltip:SetOwner(WorldFrame, "BOTTOMRIGHT")
	ShopFrameScanTooltip:SetHyperlink(itemLink)
	ShopFrameScanTooltip:Show()
	for i = 2, 15 do
		local rL, gL, bL = _G["ShopFrameScanTooltipTextLeft"..i]:GetTextColor()
		local rR, gR, bR = _G["ShopFrameScanTooltipTextRight"..i]:GetTextColor()
		if IsRed(rL, gL, bL) or IsRed(rR, gR, bR) then
			entry.restricted = true
			break
		end
	end
	ShopFrameScanTooltip:Hide()

	local recolors = info[14]
	if recolors and recolors ~= "" then
		local s = loadstring("return {"..recolors.."}")
		if s then entry.shared = s() end
		if entry.shared then
			for _, model in pairs(entry.shared) do
				model = tonumber(model)
			end
			if entry.shared[1] ~= entry.modelid then
				entry.hidden = true
			end
		end
	end

	if entry.gender > 0 then
		if entry.gender ~= Sex then
			entry.restricted = true
		end
	end
	local contains = false
	for k, v in pairs(ShopEntries[catId]) do
		if v.id == entry.id then
			contains = true
			break
		end
	end
	if not contains then
		if not entry.restricted or entry.holiday > 0 then
			table.insert(ShopEntries[catId], 1, entry)
		else
			table.insert(ShopEntries[catId], entry)
		end
	end
end

local function RefreshModelPosition()
	this.elapsed = this.elapsed + arg1
	if this.elapsed > 0.03 then
		local entry = this.entryFrame.data
		local scale = UIParent:GetScale() or 1.0
		this:SetScript("OnUpdate", nil)
		this.elapsed = 0
		this:SetPosition(entry.posz / scale, entry.posx / scale, entry.posy / scale)
		this:SetFacing(entry.rotation)
	end
end

local copy = {}
function Shop_ShowEntries(category, subcategory)
	ShopFrame_HideEntries()

	local searching = IsSearching()

	ShopFramePageText:Hide()
	ShopFramePreviousButton:Hide()
	ShopFramePreviousButton:Disable()
	ShopFrameNextButton:Hide()
	ShopFrameNextButton:Disable()
	ShopFrameClaimButton:Disable()

	local entries = ShopEntries[category]
	ShopFrameClaimButton:Show()

	if not entries then
		ShopFrameClaimButton:Hide()
		return
	end

	if subcategory then
		wipe(copy)
		for _, entry in entries do
			if entry.subcategory == subcategory then
				table.insert(copy, entry)
			end
		end
		entries = copy
	end

	local visibleEntries = sizeof(entries)
	for k in pairs(entries) do
		if entries[k].hidden then
			visibleEntries = visibleEntries - 1
		end
	end
	local shopTotalPages = ceil(visibleEntries / MaxEntries)
	if shopTotalPages > 1 then
		ShopFramePageText:SetText(GENERIC_PAGE .. " " .. CurrentPage .. "/" .. shopTotalPages)
		ShopFramePageText:Show()

		ShopFramePreviousButton:Show()
		ShopFrameNextButton:Show()

		if CurrentPage == 1 then
			ShopFramePreviousButton:Disable()
		else
			ShopFramePreviousButton:Enable()
		end

		if CurrentPage == shopTotalPages then
			ShopFrameNextButton:Disable()
		else
			ShopFrameNextButton:Enable()
		end
	end

	local entryIndex = 0
	local normal = "Interface\\ShopFrame\\item_normal"
	local highlight = "Interface\\ShopFrame\\item_highlight"
	local pushed = "Interface\\ShopFrame\\item_normal"
	local lowerLimit = (CurrentPage - 1) * MaxEntries
	local upperLimit = CurrentPage * MaxEntries

	for index, entry in ipairs(entries) do
		if not entry.hidden or searching or subcategory then
			entryIndex = entryIndex + 1
			if entryIndex > lowerLimit and entryIndex <= upperLimit then
				local _, itemLink, _, _, _, _, _, loc, texture = GetItemInfo(entry.id)

				local frameId = mod(entryIndex, MaxEntries)
				if frameId == 0 then
					frameId = MaxEntries
				end

				local entryFrame = _G["ShopFrameEntryFrame" .. frameId]
				entryFrame:SetNormalTexture(normal)
				entryFrame:SetPushedTexture(pushed)
				entryFrame:SetHighlightTexture(highlight)
				entryFrame:GetNormalTexture():SetDesaturated(0)
				entryFrame:GetNormalTexture():SetVertexColor(1, 1, 1)
				entryFrame:GetPushedTexture():SetDesaturated(0)
				entryFrame:GetPushedTexture():SetVertexColor(1, 1, 1)
				entryFrame:Show()
				entryFrame:UnlockHighlight()

				if entry.restricted then
					entryFrame:SetHighlightTexture("")
					entryFrame:GetNormalTexture():SetDesaturated(1)
					entryFrame:GetNormalTexture():SetVertexColor(0, 0, 0)
					entryFrame:GetPushedTexture():SetDesaturated(1)
					entryFrame:GetPushedTexture():SetVertexColor(0, 0, 0)
				end

				if entry.holiday > 0 then
					_G[entryFrame:GetName() .. "FeaturedFrame"]:Show()
				end

				local shared = _G[entryFrame:GetName().."Shared"]
				if entry.shared and not searching and not subcategory then
					entry.modelIndex = entry.modelIndex or 1
					-- Get rid of modelIDs that were not sent
					for _, modelID in pairs(entry.shared) do
						local exists = false
						for _, data in pairs(ShopEntries[category]) do
							if data.modelid == modelID then
								exists = true
								break
							end
						end
						if not exists then
							for _, data in pairs(ShopEntries[category]) do
								if data.shared then
									for k, v in pairs(data.shared) do
										if v == modelID then
											tremove(data.shared, k)
											break
										end
									end
								end
							end
						end
					end
					entry.modelsTotal = getn(entry.shared)
					if entry.modelsTotal > 1 then
						shared:Show()
					else
						shared:Hide()
					end
				else
					shared:Hide()
				end

				_G[entryFrame:GetName() .. "Name"]:SetText(entry.name)

				local priceText = _G[entryFrame:GetName() .. "Price"]
				priceText:SetText(entry.price)
				if Balance < entry.price then
					priceText:SetTextColor(0.9, 0.1, 0.1)
				end

				entryFrame.dress = nil
				entryFrame.model = nil
				entryFrame.data = entry

				if entry.category == 2 then -- skins
					if entry.gender == 0 then
						entryFrame:SetNormalTexture("Interface\\ShopFrame\\entries\\" .. entry.id .. "_" .. Sex)
						entryFrame:SetPushedTexture("Interface\\ShopFrame\\entries\\" .. entry.id .. "_" .. Sex)
					else
						entryFrame:SetNormalTexture("Interface\\ShopFrame\\entries\\" .. entry.id)
						entryFrame:SetPushedTexture("Interface\\ShopFrame\\entries\\" .. entry.id)
					end
					entryFrame:SetHighlightTexture("Interface\\ShopFrame\\item_highlight")
					if entry.restricted then
						entryFrame:SetHighlightTexture("")
						entryFrame:GetNormalTexture():SetDesaturated(1)
						entryFrame:GetPushedTexture():SetDesaturated(1)
					end
				elseif entry.modelid ~= 0 or entry.itemid ~= 0 then
					local model = _G["ShopFrameEntryFrame"..frameId.."Model"]
					if not model then
						model = CreateFrame("DressUpModel", "ShopFrameEntryFrame"..frameId.."Model", entryFrame, "ShopEntryModelTemplate")
						model:SetPoint("TOPLEFT", entryFrame, 10, -10)
						model:SetPoint("BOTTOMRIGHT", entryFrame, -10, 60)
						model:SetLight(1, 0, -0.3, -1, -1,   0.55, 1.0, 1.0, 1.0,   0.8, 1.0, 1.0, 1.0)
						model:SetModelScale(1)
						model:SetParent(ShopFrame)
						model:SetFrameLevel(entryFrame:GetFrameLevel() + 1)
						model.entryFrame = entryFrame
					end
					model:SetAlpha(1)
					model:EnableMouse(DebugMode)
					model:SetID(index)
					model:SetPosition(0, 0, 0)
					model:SetFacing(0)
					if entry.modelid ~= 0 then
						-- creature model
						model:SetUnit(entry.modelid)
						model.elapsed = 0
						model:SetScript("OnUpdate", RefreshModelPosition)
						entryFrame.model = entry.modelid
					elseif loc and loc ~= "" then
						-- something that player can equip
						model:SetUnit("player")
						model:Undress()
						entryFrame.dress = entry.itemid
						local slot = InvTypeToSlot[loc]
						if slot then
							local z, x, y = Positions[slot][Race][Sex][1], Positions[slot][Race][Sex][2], Positions[slot][Race][Sex][3]
							local fNormal, fSpecial = Positions[slot][Race][Sex][4], Positions[slot][Race][Sex][5]
							model:SetPosition(z, x, y)
							if loc == "INVTYPE_RANGED" or loc == "INVTYPE_WEAPONOFFHAND" or loc == "INVTYPE_HOLDABLE" or loc == "INVTYPE_SHIELD" then
								model:SetFacing(fSpecial)
							else
								model:SetFacing(fNormal)
							end
							model:TryOn(entry.itemid)
						end
					end
				else
					local itemBorder = _G[entryFrame:GetName() .. "ItemBorder"]
					local itemTexture = _G[entryFrame:GetName() .. "ItemTexture"]

					itemBorder:Show()
					itemTexture:Show()
					itemTexture:SetTexture(texture)
					SetPortraitToTexture(itemTexture, texture)

					if entry.restricted then
						itemBorder:SetDesaturated(1)
						itemTexture:SetDesaturated(1)
					end
				end

				entryFrame.itemLink = itemLink

				if entry.id == ClaimID and not entry.restricted then
					entryFrame:LockHighlight()
					ShopFrameClaimButton:Enable()
				end
			end
		end
	end
end

function Shop_ProcessBuyResult(arg)
	local result = gsub(arg, "BuyResult:", "")

	if result == "itemnotinshop" then
		UIErrorsFrame:AddMessage(DONO_SHOP_MSG_UNKNOWN_ITEM, 1, 0.1, 0.1)
	elseif result == "bagsfulloralreadyhaveitem" then
		UIErrorsFrame:AddMessage(DONO_SHOP_MSG_FULL_BAGS, 1, 0.1, 0.1)
	elseif result == "unknowndberror" then
		UIErrorsFrame:AddMessage(DONO_SHOP_MSG_UNKNOWN_ERR, 1, 0.1, 0.1)
	elseif result == "dberrorcantprocess" then
		UIErrorsFrame:AddMessage(DONO_SHOP_MSG_CANT_PROCESS, 1, 0.1, 0.1)
	elseif result == "notenoughtokens" then
		UIErrorsFrame:AddMessage(DONO_SHOP_MSG_INSUFFICIENT_TOKENS, 1, 0.1, 0.1)
	end

	Send("Balance")
end

function ShopFrame_HideEntries()
	for i = 1, MaxEntries do
		_G["ShopFrameEntryFrame" .. i]:Hide()
		local model = _G["ShopFrameEntryFrame"..i.."Model"]
		if model then
			model:SetAlpha(0)
			model:EnableMouse(nil)
		end
	end
end

function ShopFrame_CycleModels(entryFrame, dir)
	local scale = UIParent:GetScale() or 1.0
	local model = _G[entryFrame:GetName().."Model"]
	local currentModel = entryFrame.data.modelid
	local newModel
	local newModelIndex = 1
	local max = getn(entryFrame.data.shared)
	for k, v in pairs(entryFrame.data.shared) do
		if v == currentModel then
			newModelIndex = k + dir
			break
		end
	end
	if newModelIndex < 1 then
		newModelIndex = max
	elseif newModelIndex > max then
		newModelIndex = 1
	end
	newModel = entryFrame.data.shared[newModelIndex]
	for _, entry in pairs(ShopEntries[entryFrame.data.category]) do
		if entry.modelid ~= 0 and entry.modelid == newModel then
			model:SetPosition(0, 0, 0)
			model:SetUnit(newModel)
			model:SetPosition(entry.posz / scale, entry.posx / scale, entry.posy / scale)
			_G[entryFrame:GetName() .. "Name"]:SetText(entry.name)
			local priceText = _G[entryFrame:GetName() .. "Price"]
			priceText:SetText(entry.price)
			if Balance < entry.price then
				priceText:SetTextColor(0.9, 0.1, 0.1)
			else
				priceText:SetTextColor(1, 0.82, 0)
			end
			entry.hidden = false
			entryFrame.data.hidden = true
			entryFrame.data = entry
			entryFrame.model = newModel
			entryFrame.itemLink = "item:"..entry.id
			break
		end
	end
	entryFrame.data.modelIndex = newModelIndex
	entryFrame.data.modelsTotal = getn(entryFrame.data.shared)
	if GameTooltip:IsOwned(this) then
		ShopEntryShared_OnEnter()
	end
	if entryFrame.data.id == ClaimID and Balance >= entryFrame.data.price then
		ShopFrameClaimButton.name = entryFrame.data.name
		ShopFrameClaimButton.price = entryFrame.data.price
		ShopFrameClaimButton:Enable()
		entryFrame:LockHighlight()
	else
		StaticPopup_Hide("SHOP_CONFIRMATION")
		ShopFrameClaimButton.name = nil
		ShopFrameClaimButton.price = nil
		ShopFrameClaimButton:Disable()
		entryFrame:UnlockHighlight()
	end
end

function ShopEntryShared_OnEnter()
	local data = this:GetParent().data
	GameTooltip:SetOwner(this, "ANCHOR_LEFT")
	GameTooltip:SetText(DONO_SHOP_CHANGE_COLOR.." "..data.modelIndex.."/"..data.modelsTotal, 1, 1, 1, true)
	GameTooltip:Show()
end

function ShopFrameEntryButton_OnClick()
	if IsControlKeyDown() or TWS_AUTODRESS == 1 then
		ShopDressUpItem(this)
	end

	if this.data.restricted then
		return
	end

	for i = 1, MaxEntries do
		_G["ShopFrameEntryFrame" .. i]:UnlockHighlight()
	end

	if this.data.id ~= ClaimID and Balance >= this.data.price then
		StaticPopup_Hide("SHOP_CONFIRMATION")
		ClaimID = this.data.id
		ShopFrameClaimButton.name = this.data.name
		ShopFrameClaimButton.price = this.data.price
		ShopFrameClaimButton:Enable()
		this:LockHighlight()
	else
		ClaimID = 0
		ShopFrameClaimButton.name = nil
		ShopFrameClaimButton.price = nil
		ShopFrameClaimButton:Disable()
	end

	ShopFrameSearchBox:ClearFocus()
end

function ShopFrame_Claim()
	StaticPopup_Show("SHOP_CONFIRMATION", this.name, this.price)

	ShopFrameSearchBox:ClearFocus()
end

function ShopFrame_ChangePage(dir)
	ShopFrame_HideEntries()

	CurrentPage = CurrentPage + 1 * dir
	if IsSearching() then
		Shop_ShowEntries(-1)
	else
		Shop_ShowEntries(CurrentCategory, CurrentSubcategory)
	end
end

function ShopFrame_Toggle()
	if ShopFrame:IsVisible() then
		ShopFrame:Hide()
	else
		ShopFrame:Show()
		CategoryFrames[0]:Click()
	end
end

function ShopFrameEntryModel_OnEnter()
	local entryFrame = this.entryFrame
	if not entryFrame then return end
	local func = entryFrame:GetScript("OnEnter")
	entryFrame:LockHighlight()
	if func then
		func()
	end
end

function ShopFrameEntryModel_OnLeave()
	local entryFrame = this.entryFrame
	if not entryFrame then return end
	if entryFrame.data.id ~= ClaimID then
		entryFrame:UnlockHighlight()
	end
	GameTooltip:Hide()
end

function ShopFrameEntryModel_OnMouseDown()
	local entryFrame = this.entryFrame
	if not entryFrame then return end
	entryFrame:GetPushedTexture():Show()
	entryFrame:GetHighlightTexture():SetAlpha(0)
	if DebugMode then
		local StartX, StartY = GetCursorPosition()
		local endX, endY, Z, X, Y
		if arg1 == "LeftButton" then
			this:SetScript("OnUpdate", function()
				endX = GetCursorPosition()
				this.rotation = (endX - StartX) / 34 + this:GetFacing()
				this:SetFacing(this.rotation)
				StartX = GetCursorPosition()
			end)
		elseif arg1 == "RightButton" then
			this:SetScript("OnUpdate", function()
				endX, endY = GetCursorPosition()
				Z, X, Y = this:GetPosition()
				X = (endX - StartX) / 100 + X
				Y = (endY - StartY) / 100 + Y
				this:SetPosition(Z, X, Y)
				StartX, StartY = GetCursorPosition()
			end)
		end
	end
end

function ShopFrameEntryModel_OnMouseUp(button)
	local entryFrame = this.entryFrame
	if not entryFrame then return end
	this:SetScript("OnUpdate", nil)
	entryFrame:GetPushedTexture():Hide()
	entryFrame:GetHighlightTexture():SetAlpha(1)
	if MouseIsOver(entryFrame) then
		entryFrame:Click(button)
	end
	if DebugMode then
		local scale = UIParent:GetScale()
		local z, x, y = this:GetPosition()
		debugprint(format("[|cffffd200id|r] %d [|cffffd200x|r] %.3f [|cffffd200y|r] %.3f [|cffffd200z|r] %.3f [|cffffd200facing|r] %.3f",entryFrame.data.id, x * scale, y * scale, z * scale, this:GetFacing()))
	end
end

function ShopDressUpModel_OnLoad()
	ShopDressUpModel:SetUnit("player")
	ShopDressUpModel:SetFacing(0)
	ShopDressUpModel:SetLight(1, 0, -0.3, -1, -1,   0.55, 1.0, 1.0, 1.0,   0.8, 1.0, 1.0, 1.0)
	ShopDressUpModel:EnableMouseWheel(1)

	ShopDressUpModel:SetScript("OnMouseUp", function()
		ShopDressUpModel:SetScript("OnUpdate", nil)
	end)

	ShopDressUpModel:SetScript("OnMouseWheel", function()
		local Z, X, Y = ShopDressUpModel:GetPosition()
		Z = (arg1 > 0 and Z + 0.5 or Z - 0.5)
		ShopDressUpModel:SetPosition(Z, X, Y)
	end)

	ShopDressUpModel:SetScript("OnMouseDown", function()
		local StartX, StartY = GetCursorPosition()
		local EndX, EndY, Z, X, Y

		if arg1 == "LeftButton" then
			ShopDressUpModel:SetScript("OnUpdate", function()
				EndX, EndY = GetCursorPosition()
				ShopDressUpModel:SetFacing((EndX - StartX) / 34 + ShopDressUpModel:GetFacing())
				StartX, StartY = GetCursorPosition()
			end)

		elseif arg1 == "RightButton" then
			ShopDressUpModel:SetScript("OnUpdate", function()
				EndX, EndY = GetCursorPosition()
				Z, X, Y = ShopDressUpModel:GetPosition()
				X = (EndX - StartX) / 90 + X
				Y = (EndY - StartY) / 90 + Y
				ShopDressUpModel:SetPosition(Z, X, Y)
				StartX, StartY = GetCursorPosition()
			end)
		end
	end)
end

function ShopFrameEntryModel_OnMouseWheel()
	if DebugMode then
		local Z, X, Y = this:GetPosition()
		Z = (arg1 > 0 and Z + 1 or Z - 1)
		this:SetPosition(Z, X, Y)
	else
		ShopFrame:GetScript("OnMouseWheel")()
	end
end

function ShopDressUpModel_Reset()
	ShopDressUpModel:SetPosition(ShopDressUpFrameResetButton.z, ShopDressUpFrameResetButton.x, ShopDressUpFrameResetButton.y)
	ShopDressUpModel:Dress()
	local tabardLink = GetInventoryItemLink("player", 19)
	local _, _, itemID = strfind(tabardLink or "", "item:(%d+)")
	if itemID then
		ShopDressUpModel:TryOn(tonumber(itemID))
	end
end

local showPlayer = true

function ShopDressUpItem(entryFrame)
	local dress = entryFrame.dress
	local model = entryFrame.model
	if model then
		local data = entryFrame.data
		if not ShopDressUpFrame:IsShown() then
			ShopDressUpFrame:Show()
		end
		local scale = UIParent:GetScale() or 1.0
		local z, x, y = data.posz/scale, data.posx/scale, data.posy/scale
		ShopDressUpModel:SetPosition(0, 0, 0)
		ShopDressUpModel:SetUnit(model)
		ShopDressUpModel:SetPosition(z, x, y)
		ShopDressUpFrameResetButton.z = z
		ShopDressUpFrameResetButton.x = x
		ShopDressUpFrameResetButton.y = y
		showPlayer = true
		ShopDressUpFrameUndressButton:Hide()
		ShopDressUpFrameResetButton:SetPoint("LEFT", ShopDressUpFrameUndressButton, "RIGHT", -34, 0)
	elseif dress then
		if not ShopDressUpFrame:IsShown() or showPlayer then
			ShopDressUpFrame:Show()
			ShopDressUpModel:SetUnit("player")
			ShopDressUpModel:SetFacing(0)
			ShopDressUpFrameResetButton.z = 0
			ShopDressUpFrameResetButton.x = 0
			ShopDressUpFrameResetButton.y = 0
			local tabardLink = GetInventoryItemLink("player", 19)
			local _, _, itemID = strfind(tabardLink or "", "item:(%d+)")
			if itemID then
				ShopDressUpModel:TryOn(tonumber(itemID))
			end
			showPlayer = false
			ShopDressUpFrameUndressButton:Show()
			ShopDressUpFrameResetButton:SetPoint("LEFT", ShopDressUpFrameUndressButton, "RIGHT", 4, 0)
		end
		ShopDressUpModel:TryOn(tonumber(dress))
	end
end

local function searchsort(a, b)
	return b.restricted and not a.restricted
end

function ShopFrame_Search()
	ShopEntries[-1] = wipe(ShopEntries[-1])
	CurrentPage = 1

	if IsSearching() then
		if ShopFrameAboutFrame:IsShown() then
			ShopFrameAboutFrame:Hide()
		end

		local query = strlower(trim(ShopFrameSearchBox:GetText()))
		for i = 1, getn(ShopEntries) do
			for _, entry in pairs(ShopEntries[i]) do
				if strfind(strlower(entry.name), query, 1, true) then
					tinsert(ShopEntries[-1], entry)
				end
			end
		end
		table.sort(ShopEntries[-1], searchsort)

		Shop_ShowEntries(-1)
	else
		if CurrentCategory == 0 then
			ShopFrameAboutFrame:Show()
			ShopFrameClaimButton:Disable()
		end
		Shop_ShowEntries(CurrentCategory, CurrentSubcategory)
	end
end

SLASH_TWSHOP1 = "/shop"
SlashCmdList["TWSHOP"] = function(cmd)
	if cmd then
		if strfind(cmd, "button", 1, true) then
			TWS_HIDE_MINIMAP_BUTTON = 0
			MinimapShopFrame:Show()
		elseif strfind(cmd, "debug", 1, true) then
			DebugMode = not DebugMode
			if DebugMode then
				print("debug is ON")
			else
				print("debug is OFF")
			end
		else
			ShopFrame_Toggle()
		end
	end
end

StaticPopupDialogs["SHOP_CONFIRMATION"] = {
	text = DONO_SHOP_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		Send("Buy:" .. ClaimID)
	end,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["SHOP_HIDE_CONFIRMATION"] = {
	text = DONO_SHOP_CONFIRM_HIDE,
	button1 = CONFIRM,
	button2 = CANCEL,
	OnAccept = function()
		TWS_HIDE_MINIMAP_BUTTON = 1
		MinimapShopFrame:Hide()
		print(GAME_YELLOW .. DONO_SHOP_CHAT_COMMAND)
	end,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

function ShopDressUpFrame_OnShow()
	ShopFrame:SetWidth(985)
	PlaySound("igCharacterInfoOpen")
end

function ShopDressUpFrame_OnHide()
	ShopFrame:SetWidth(700)
	PlaySound("igCharacterInfoClose")
end
