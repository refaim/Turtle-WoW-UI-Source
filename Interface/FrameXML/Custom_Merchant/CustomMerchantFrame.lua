local ITEMS_PER_PAGE = 10
local COSTTYPE_ITEM = 1
local COSTTYPE_HONOR = 2
local COSTTYPE_ARENA = 3
local MAX_ITEM_COSTS = 3
local TRIGGER = "CUSTOM_MERCHANT_TRIGGER"
local MerchantItems = {}

UIPanelWindows["CustomMerchantFrame"] = { area = "left", pushable = 0 }

function CustomMerchantFrame_OnLoad()
	this:RegisterEvent("GOSSIP_SHOW")
	this:RegisterEvent("GOSSIP_CLOSED")
	this:RegisterEvent("UNIT_INVENTORY_CHANGED")
	this:RegisterEvent("CHAT_MSG_ADDON")
	this:RegisterForDrag("LeftButton")
	this.page = 1
end

do
	local data = {}
	function CustomMerchantFrame_Show()
		wipe(data)
		data.command = "show"
		SendAddonMessage("TW_Merchant", json.encode(data), "GUILD")
	end

	function CustomMerchantFrame_GetCurrency()
		wipe(data)
		data.command = "update"
		SendAddonMessage("TW_Merchant", json.encode(data), "GUILD")
	end

	function CustomMerchantFrame_Buy(id)
		wipe(data)
		data.command = "buy"
		data.idx = id
		SendAddonMessage("TW_Merchant", json.encode(data), "GUILD")
	end
end

function CustomMerchantFrame_OnEvent()
	if event == "CHAT_MSG_ADDON" and arg1 == "TW_Merchant" then
		local info = json.decode(arg2)
		if type(info) ~= "table" then return end

		if info.command == "update" then
			CustomMerchantFrame.honorAmount = info.totalHonor
			CustomMerchantFrame.arenaAmount = info.totalArena
			CustomMerchantFrame_UpdateCurrency()
			PlaySound("LOOTWINDOWCOINSOUND")
		elseif info.command == "show" then
			CustomMerchantFrame.honorAmount = info.totalHonor
			CustomMerchantFrame.arenaAmount = info.totalArena
			CustomMerchantFrame.page = 1
			CustomMerchantFrame_Update()
			ShowUIPanel(CustomMerchantFrame)
		elseif info.command == "itemBatch" then
			for _, v in ipairs(info.items) do
					MerchantItems[table.getn(MerchantItems) + 1] = v
			end
		end

	elseif event == "GOSSIP_SHOW" then
		if not (GetGossipText() == TRIGGER and UnitExists("npc")) then return end
		GossipFrame:SetAlpha(0)
		GossipFrame:EnableMouse(false)
		GossipFrame.pushable = UIPanelWindows.GossipFrame.pushable
		UIPanelWindows.GossipFrame.pushable = 99
		CloseWindows(nil, GossipFrame)
		MerchantItems = {}
		CustomMerchantFrame_Show()

	elseif event == "GOSSIP_CLOSED" then
		if not CustomMerchantFrame:IsShown() then return end
		GossipFrame:SetAlpha(1)
		GossipFrame:EnableMouse(true)
		UIPanelWindows.GossipFrame.pushable = GossipFrame.pushable or 0
		GossipFrame.pushable = nil
		HideUIPanel(CustomMerchantFrame)
		wipe(MerchantItems)
	end
end


function CustomMerchantFrame_OnShow()
	OpenBackpack()
end

function CustomMerchantFrame_OnHide()
	CloseBackpack()
	HideUIPanel(GossipFrame)
	PlaySound("igCharacterInfoClose")
	ResetCursor()
end

function CustomMerchantFrame_Update()
	CustomMerchantFrame_UpdateMerchantInfo()
	CustomMerchantFrame_UpdateCurrency()
end

function CustomMerchantFrame_UpdateCurrency()
	local factionGroup = UnitFactionGroup("player")
	local honorTexture = "Interface\\TargetingFrame\\UI-PVP-Horde"
	if factionGroup then
		honorTexture = "Interface\\TargetingFrame\\UI-PVP-"..factionGroup
	end

	local honorAmount = CustomMerchantFrame.honorAmount or 0
	local arenaAmount = CustomMerchantFrame.arenaAmount or 0

	MoneyFrame_UpdateAlternateCurrency(CustomMerchantFrameHonorAmount, honorTexture, honorAmount, true)
	MoneyFrame_UpdateAlternateCurrency(CustomMerchantFrameArenaAmount, "Interface\\TargetingFrame\\PVP-ArenaPoints-Icon", arenaAmount)

	CustomMerchantFrameHonorAmount:Show()
	CustomMerchantFrameArenaAmount:Show()
end

function GetCustomMerchantNumItems()
	return table.getn(MerchantItems)
end

function GetCustomMerchantItemInfo(index)
	if not MerchantItems[index] then return nil end
	return MerchantItems[index].id, MerchantItems[index].item_id, MerchantItems[index].cost, MerchantItems[index].count, MerchantItems[index].ext_cost, MerchantItems[index].ext_cost_count, MerchantItems[index].can_use
end

function CustomMerchantFrame_UpdateMerchantInfo()
	CustomMerchantNameText:SetText(UnitName("npc"))
	SetPortraitTexture(CustomMerchantFramePortrait, "npc")

	local numMerchantItems = GetCustomMerchantNumItems()

	for i = 1, ITEMS_PER_PAGE do
		local index = (((CustomMerchantFrame.page - 1) * ITEMS_PER_PAGE) + i)
		local itemButton = _G["CustomMerchantItem"..i.."ItemButton"]
		local merchantButton = _G["CustomMerchantItem"..i]
		local merchantAltCurrency = _G["CustomMerchantItem"..i.."AltCurrencyFrame"]

		if index <= numMerchantItems then
			local idx, itemId, price, count, costs, costsCount, canUse = GetCustomMerchantItemInfo(index)
			local name, _, _, _, _, _, _, _, texture = GetItemInfo(itemId)

			_G["CustomMerchantItem"..i.."AltCurrencyFrame"]:Show()
			CustomMerchantFrame_UpdateAltCurrency(index, i)
			merchantAltCurrency:ClearAllPoints()
			merchantAltCurrency:SetPoint("BOTTOMLEFT", "CustomMerchantItem"..i.."NameFrame", "BOTTOMLEFT", 0, 31)
			merchantAltCurrency:SetID(index)
			merchantAltCurrency:Show()

			_G["CustomMerchantItem"..i.."Name"]:SetText(name)
			SetItemButtonCount(itemButton, count)
			SetItemButtonTexture(itemButton, texture)
			itemButton:SetID(index)
			itemButton:Show()

			if not canUse then
				SetItemButtonNameFrameVertexColor(merchantButton, 1.0, 0, 0)
				SetItemButtonSlotVertexColor(merchantButton, 1.0, 0, 0)
				SetItemButtonTextureVertexColor(itemButton, 0.9, 0, 0)
				SetItemButtonNormalTextureVertexColor(itemButton, 0.9, 0, 0)
			else
				SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5)
				SetItemButtonSlotVertexColor(merchantButton, 1.0, 1.0, 1.0)
				SetItemButtonTextureVertexColor(itemButton, 1.0, 1.0, 1.0)
				SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 1.0, 1.0)
			end
		else
			itemButton:Hide()
			merchantAltCurrency:Hide()
			SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5)
			SetItemButtonSlotVertexColor(merchantButton, 0.4, 0.4, 0.4)
			_G["CustomMerchantItem"..i.."Name"]:SetText("")
		end
	end

	-- Handle paging buttons
	if numMerchantItems > ITEMS_PER_PAGE then
		CustomMerchantPageText:SetText(format(MERCHANT_PAGE_NUMBER, CustomMerchantFrame.page, ceil(numMerchantItems / ITEMS_PER_PAGE)))
		if CustomMerchantFrame.page <= 1 then
			CustomMerchantPrevPageButton:Disable()
		else
			CustomMerchantPrevPageButton:Enable()
		end
		if numMerchantItems <= ITEMS_PER_PAGE or CustomMerchantFrame.page >= ceil(numMerchantItems / ITEMS_PER_PAGE) then
			CustomMerchantNextPageButton:Disable()
		else
			CustomMerchantNextPageButton:Enable()
		end
		CustomMerchantPageText:Show()
		CustomMerchantPrevPageButton:Show()
		CustomMerchantNextPageButton:Show()
	else
		CustomMerchantPageText:Hide()
		CustomMerchantPrevPageButton:Hide()
		CustomMerchantNextPageButton:Hide()
	end
end

function CustomMerchantFrame_UpdateAltCurrency(itemIndex, buttonIndex)
	local previousButtonName
	local idx, itemId, price, count, costs, costsCount = GetCustomMerchantItemInfo(itemIndex)
	local frameName = "CustomMerchantItem"..buttonIndex.."AltCurrencyFrame"

	local hadHonor = false
	local hadArena = false
	-- Hide all cost buttons first so stale ones don't linger
	_G[frameName.."Honor"]:Hide()
	_G[frameName.."Arena"]:Hide()
	for i = 1, MAX_ITEM_COSTS do
		_G[frameName.."Item"..i]:Hide()
	end

	if not costs then return end
	costsCount = costsCount or 0

	-- update Alt Currency Frame with itemValues
	for i = 1, costsCount do
		local costInfo = costs[i]
		local currentButtonName
		local button = _G[frameName.."Item"..i]
		button.link = nil

		if costInfo.type == COSTTYPE_ITEM then
			local name, link, _, _, _, _, _, _, itemTexture = GetItemInfo(costInfo.value)
			MoneyFrame_UpdateAlternateCurrency(button, itemTexture, costInfo.amount)
			button.link = link

			if itemTexture then
				button:Show()
			else
				button:Hide()
			end
			currentButtonName = frameName.."Item"..i
		elseif costInfo.type == COSTTYPE_HONOR then
			local factionGroup = UnitFactionGroup("player")
			local honorTexture = "Interface\\TargetingFrame\\UI-PVP-Horde"
			if factionGroup then
				honorTexture = "Interface\\TargetingFrame\\UI-PVP-"..factionGroup
			end
			button = _G[frameName.."Honor"]
			MoneyFrame_UpdateAlternateCurrency(button, honorTexture, costInfo.value, true)
			button:Show()
			currentButtonName = frameName.."Honor"
			hadHonor = true
		elseif costInfo.type == COSTTYPE_ARENA then
			button = _G[frameName.."Arena"]
			MoneyFrame_UpdateAlternateCurrency(button, "Interface\\TargetingFrame\\PVP-ArenaPoints-Icon", costInfo.value)
			button:Show()
			currentButtonName = frameName.."Arena"
			hadArena = true
		end

		button:ClearAllPoints()
		if previousButtonName then
			button:SetPoint("LEFT", previousButtonName, "RIGHT", 3, 0)
		else
			local offsetX = -11
			if not hadArena and not hadHonor then
				offsetX = -15
			end
			button:SetPoint("BOTTOM", "CustomMerchantItem"..buttonIndex, "BOTTOM", offsetX, -1)
		end
		previousButtonName = currentButtonName
	end

	if costsCount >= 3 then
		_G[frameName]:SetScale(0.85)
	else
		_G[frameName]:SetScale(1)
	end
end

function CustomMerchantItem_OnEnter()
	local idx, itemId = GetCustomMerchantItemInfo(this:GetID())
	if not itemId then return end
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("item:"..itemId)
	GameTooltip:Show()
	SetCursor("BUY_CURSOR")
	CustomMerchantFrame.itemHover = this:GetID()
end

function CustomMerchantPrevPageButton_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn")
	CustomMerchantFrame.page = CustomMerchantFrame.page - 1
	CustomMerchantFrame_Update()
end

function CustomMerchantNextPageButton_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn")
	CustomMerchantFrame.page = CustomMerchantFrame.page + 1
	CustomMerchantFrame_Update()
end

function CustomMerchantItemButton_OnClick(button, ignoreModifiers)
	local idx, itemId = GetCustomMerchantItemInfo(this:GetID())
	if not itemId then return end

	local name, link, quality = GetItemInfo(itemId)
	if not name then return end

	if button == "LeftButton" then
		if IsControlKeyDown() and not ignoreModifiers then
			DressUpItemLink(itemId)
		elseif IsShiftKeyDown() and not ignoreModifiers then
			if ChatFrameEditBox:IsVisible() then
				local r, g, b, color = GetItemQualityColor(quality or 1)
				ChatFrameEditBox:Insert(format("%s|H%s|h[%s]|h|r", color, link, name))
			end
		end
	else
		if IsControlKeyDown() and not ignoreModifiers then
			return
		else
			CustomMerchantFrame_Buy(idx)
			-- PlaySound("LOOTWINDOWCOINSOUND")
		end
	end
end
