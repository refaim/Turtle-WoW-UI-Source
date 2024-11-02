DONATION_SHOP_MAX_ENTRIES = 8
DONATION_SHOP_PREFIX = "TW_SHOP"

StaticPopupDialogs["SHOP_CONFIRMATION"] = {
    text = "Claim [%s] for %d tokens?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(id)
        SendAddonMessage(DONATION_SHOP_PREFIX, "Buy:" .. ShopFrame:GetID(), "GUILD")
    end,
    timeout = 6,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local shopBalance = 0
local shopCategories = {}
local shopCategoryFrames = {}
local shopCurrentCategory = nil
local shopCurrentPage = 1
local shopEntries = nil
local shopTotalPages = 0

local races = {
    ["Human"] = "Human",
    ["NightElf"] = "Night Elf",
    ["Dwarf"] = "Dwarf",
    ["Gnome"] = "Gnome",
    ["BloodElf"] = "High Elf",
    ["Orc"] = "Orc",
    ["Troll"] = "Troll",
    ["Scourge"] = "Undead",
    ["Tauren"] = "Tauren",
    ["Goblin"] = "Goblin",
}

local slots = {
    ["INVTYPE_HEAD"] = "Head",
    ["INVTYPE_SHOULDER"] = "Shoulders",
    ["INVTYPE_CLOAK"] = "Back",
    ["INVTYPE_CHEST"] = "Chest",
    ["INVTYPE_ROBE"] = "Chest",
    ["INVTYPE_BODY"] = "Shirt",
    ["INVTYPE_TABARD"] = "Tabard",
    ["INVTYPE_WRIST"] = "Wrist",
    ["INVTYPE_HAND"] = "Hands",
    ["INVTYPE_WAIST"] = "Waist",
    ["INVTYPE_LEGS"] = "Legs",
    ["INVTYPE_FEET"] = "Feet",
}

if not TWS_HIDE_MINIMAP_BUTTON then
    TWS_HIDE_MINIMAP_BUTTON = 0
end

RegisterForSave("TWS_HIDE_MINIMAP_BUTTON");

local ShopDelay = CreateFrame("Frame")
ShopDelay.ready = false
ShopDelay:SetScript("OnUpdate", function()
    this.elapsed = this.elapsed or 0
    if this.ready then
        if shopEntries then
            this:Hide()

            MinimapShopFrame:Enable()
        end
    else
        if this.elapsed >= 0.5 then
            Shop_GetBalance()
            Shop_GetCategories()

            this.ready = true
        end
        this.elapsed = this.elapsed + arg1
    end
end)

function ShopFrame_OnEvent()
    if event then
        if event == 'VARIABLES_LOADED' then
            MinimapShopFrame:Disable()
            if TWS_HIDE_MINIMAP_BUTTON == 0 then
                MinimapShopFrame:Show()
            else
                MinimapShopFrame:Hide()
            end
        end

        if event == 'CHAT_MSG_ADDON' and arg1 == DONATION_SHOP_PREFIX then
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
end

-- utils
local function ceil(num)
    if num > math.floor(num) then
        return math.floor(num + 1)
    end
    return math.floor(num + 0.5)
end

local function explode(str, delimiter)
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

local function print(a)
    if a == nil then
        DEFAULT_CHAT_FRAME:AddMessage('err:' .. time() .. '|cffffffff attempt to print a nil value.')
        return false
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd200" .. a)
end

local function sizeof(t)
    local s = 0
    for i in t do
        s = s + 1
    end
    return s
end
--

function Shop_GetBalance()
    SendAddonMessage(DONATION_SHOP_PREFIX, "Balance", "GUILD")
end

function Shop_ProcessBalance(arg)
    local ex = explode(arg, "Balance:")
    if ex[2] and tonumber(ex[2]) then
        shopBalance = tonumber(ex[2])
        ShopFrameBalance:SetText("Balance: " .. shopBalance)
    end
end

function Shop_GetCategories()
    SendAddonMessage(DONATION_SHOP_PREFIX, "Categories", "GUILD")
end

function Shop_ProcessCategories(arg)
	arg = string.gsub(arg, "8", "9")
	arg = string.gsub(arg, "7", "8")
	arg = string.gsub(arg, "6", "7")
	arg = string.gsub(arg, "5", "6")
	arg = string.gsub(arg, "4", "5")
	arg = string.gsub(arg, "3", "4")
	arg = string.gsub(arg, "2", "3")
	arg = string.gsub(arg, "1", "2")
	arg = string.gsub(arg, ":", ":1=About=about;")

    for index in shopCategoryFrames do
        shopCategoryFrames[index]:Hide()
    end

    local ex = explode(arg, "Categories:")
    if ex[2] then
        local cats = explode(ex[2], ";")
        for _, cat in next, cats do
            if cat then
                local catEx = explode(cat, "=")
                if catEx[2] then
                    local categoryID = tonumber(catEx[1])
                    shopCategories[categoryID] = {
                        name = catEx[2],
                        icon = catEx[3],
                    }

                    SendAddonMessage(DONATION_SHOP_PREFIX, "Entries:" .. categoryID - 1, "GUILD")

                    if not shopCategoryFrames[categoryID] then
                        shopCategoryFrames[categoryID] = CreateFrame("Button", "ShopFrameCategoryFrame" .. categoryID, ShopFrameCategoriesScrollFrameChild, "ShopCategoryFrameTemplate")
                    end

                    local frame = shopCategoryFrames[categoryID]

                    frame:SetPoint("TOPLEFT", ShopFrameCategoriesScrollFrameChild, "TOPLEFT", 2, 30 - 36 * categoryID)
                    frame:SetID(categoryID)

                    getglobal(frame:GetName() .. "Name"):SetText(catEx[2])
                    getglobal(frame:GetName() .. "IconTexture"):SetTexture("Interface\\ShopFrame\\" .. catEx[3])
                end
            end
        end

        ShopFrameCategoriesScrollFrame:SetVerticalScroll(0)
        ShopFrameCategoriesScrollFrame:UpdateScrollChildRect()
    end
end

function ShopFrameCategoryButton_OnClick(id)
    ShopFrameFashionDropDown:Hide()
    ShopFrame_HideEntries()

    for _, frame in shopCategoryFrames do
        getglobal(frame:GetName() .. 'Selected'):Hide()
    end

    getglobal('ShopFrameCategoryFrame' .. id .. 'Selected'):Show()

	if id == 1 then
		ShopFramePageText:Hide()
		ShopFramePreviousButton:Hide()
		ShopFramePreviousButton:Disable()
		ShopFrameNextButton:Hide()
		ShopFrameNextButton:Disable()

        ShopFrameAboutFrame:Show()
		ShopFrameAboutFrameLongText:SetText([[
Please be aware of the following:

• All donation rewards are soulbound, not account-bound.

• Non-hardcore characters have a 48-hour grace period to request refunds on donation rewards.

• Tokens will automatically be returned upon Hardcore death. Please create a Hardcore character to preview donation rewards.

• Deleting a non-hardcore character will not refund tokens.

• Greyed out entries are not usable by your race, class or gender.

• To claim a shop item, left-click on the entry and confirm your decision. You can use the mouse-wheel to rotate entry models.

For any issues, open a GM ticket using /gm.
]])

		return
    elseif id == 8 then
        ShopFrameFashionDropDown:Show()
	end
	ShopFrameAboutFrame:Hide()

	id = id - 1
    SendAddonMessage(DONATION_SHOP_PREFIX, "Entries:" .. id, "GUILD")

    shopCurrentCategory = id
    shopCurrentPage = 1
end

function Shop_ProcessEntries(arg)
    local ex = explode(arg, "=")
    local catId = 0

    local catEx = explode(arg, "Entries:")
    if catEx[2] then
        local catEx2 = explode(catEx[2], "=")
        if catEx2[1] and tonumber(catEx2[1]) then
            catId = tonumber(catEx2[1])
        else
            return
        end
    else
        return
    end

    if ex[2] then
        if ex[2] == "start" then
            shopEntries = {}
        end

        if ex[2] == "end" then
            if shopCurrentCategory == 7 then
                DONATION_SHOP_MAX_ENTRIES = 2
            else
                DONATION_SHOP_MAX_ENTRIES = 8
            end

            ShopFrame_HideEntries()

            ShopFramePageText:Hide()
            ShopFramePreviousButton:Hide()
            ShopFramePreviousButton:Disable()
            ShopFrameNextButton:Hide()
            ShopFrameNextButton:Disable()

            shopTotalPages = ceil(sizeof(shopEntries) / DONATION_SHOP_MAX_ENTRIES)

            if shopTotalPages > 1 then
                ShopFramePageText:SetText("Page " .. shopCurrentPage .. "/" .. shopTotalPages)
                ShopFramePageText:Show()

                ShopFramePreviousButton:Show()
                ShopFrameNextButton:Show()

                if shopCurrentPage == 1 then
                    ShopFramePreviousButton:Disable()
                else
                    ShopFramePreviousButton:Enable()
                end

                if shopCurrentPage == shopTotalPages then
                    ShopFrameNextButton:Disable()
                else
                    ShopFrameNextButton:Enable()
                end
            end

            local entryIndex = 0

            for index, entry in shopEntries do
                entryIndex = entryIndex + 1
                if entryIndex > (shopCurrentPage - 1) * DONATION_SHOP_MAX_ENTRIES and entryIndex <= DONATION_SHOP_MAX_ENTRIES * shopCurrentPage then
                    local itemLink = "item:" .. entry.id .. ":0:0:0"
                    local frameId = mod(entryIndex, DONATION_SHOP_MAX_ENTRIES)
                    if frameId == 0 then
                        frameId = DONATION_SHOP_MAX_ENTRIES
                    end

                    local entryFrame = nil
                    if shopCurrentCategory == 7 then
                        entryFrame = getglobal("ShopFrameLargeEntry" .. frameId)
                    else
                        entryFrame = getglobal("ShopFrameEntry" .. frameId)
                    end

                    entryFrame:SetNormalTexture("Interface\\ShopFrame\\item_normal")
                    entryFrame:SetID(index)
                    entryFrame:Show()

                    if entry.restricted then
                        entryFrame:GetNormalTexture():SetDesaturated(1)
                        entryFrame:EnableMouse(0)
                    end

					getglobal(entryFrame:GetName() .. "Name"):SetText(entry.name)

					local priceText = getglobal(entryFrame:GetName() .. "Price")
                    priceText:SetText(entry.price)
                    if shopBalance < entry.price then
                        priceText:SetTextColor(0.9, 0.1, 0.1)
                    end

                    entryFrame.dress = nil
                    entryFrame.model = nil

                    if entry.category == 2 then
                        entryFrame:SetNormalTexture("Interface\\ShopFrame\\entries\\" .. entry.id)

                        if entry.restricted then
                            entryFrame:GetNormalTexture():SetDesaturated(1)
                        end
                    elseif entry.modelid ~= 0 then
                        local children = { entryFrame:GetChildren() }
                        for _, child in ipairs(children) do
                            if child:GetFrameType() == "PlayerModel" then
                                child:Hide()
                            end
                        end

                        -- a new model frame is required each time because simply showing/hiding
                        -- an existing model will mess up the geometry of that model
                        local model = CreateFrame("PlayerModel", nil, entryFrame, "ShopEntryModelTemplate")

                        model:Show()
                        model:SetID(index)
                        model:SetPoint("TOPLEFT", entryFrame, 10, -10)
                        model:SetPoint("BOTTOMRIGHT", entryFrame, -10, 50)
                        model:SetUnit(entry.modelid)
                        model:SetScript("OnUpdate", function()
                            if this.elapsed >= 0.05 then
                                local data = shopEntries[this:GetID()]
                                local scale = UIParent:GetScale() or 1.0

                                this.elapsed = 0

                                this:SetModelScale(data.scale / scale)
                                this:SetPosition(data.posz / scale, data.posx / scale, data.posy / scale)
                                this:SetFacing(data.rotation)
                                this:SetScript("OnUpdate", nil)
                            else
                                this.elapsed = this.elapsed + arg1
                            end
                        end)
					elseif entry.itemid ~= 0 then
                        entryFrame:SetNormalTexture("Interface\\ShopFrame\\ShopFrame-ItemLarge")

                        local model = getglobal(entryFrame:GetName() .. "DressUpModel")

                        if model then
                            model:SetID(entry.itemid)
                            model:Hide()
                            model:Show()
                        end

                        entryFrame.dress = entry.itemid
					else
                        local itemBorder = getglobal(entryFrame:GetName() .. "ItemBorder")
                        local itemTexture = getglobal(entryFrame:GetName() .. "ItemTexture")
                        local link = "item:" .. shopEntries[index].id .. ":0:0:0"
                        local _, _, _, _, _, _, _, _, texture = GetItemInfo(link)

                        itemBorder:Show()

                        itemTexture:Show()
                        itemTexture:SetTexture(texture)
                        SetPortraitToTexture(itemTexture, texture)

                        if shopEntries[index].restricted then
                            itemBorder:SetDesaturated(1)

                            itemTexture:SetDesaturated(1)
                        end
					end

                    ShopFrame_AddButtonOnEnterTooltipShopFrame(entryFrame, itemLink)
                end
            end
        end

        if ex[2] ~= "start" and ex[2] ~= "end" then
            if catEx[2] then
                local catEx2 = explode(catEx[2], "=")
                if catEx2[1] and tonumber(catEx2[1]) then
                    local catId = tonumber(catEx2[1])
                    local entryId = tonumber(catEx2[5])
                    local entry = {
                        ['id'] = entryId,
                        ['category'] = catId,
                        ['name'] = catEx2[2],
                        ['price'] = tonumber(catEx2[3]),
                        ['text'] = catEx2[4],
                        ['modelid'] = tonumber(catEx2[6]),
                        ['itemid'] = tonumber(catEx2[7]),
                        ['posx'] = tonumber(catEx2[8]),
                        ['posy'] = tonumber(catEx2[9]),
                        ['posz'] = tonumber(catEx2[10]),
                        ['rotation'] = tonumber(catEx2[11]),
                        ['scale'] = tonumber(catEx2[12]),
                        ['restricted'] = nil,
                    }

                    local itemLink = "item:" .. entryId .. ":0:0:0"

                    ShopFrameScanTooltip:ClearLines()
                    ShopFrameScanTooltip:SetOwner(WorldFrame, "BOTTOMRIGHT")
                    ShopFrameScanTooltip:SetHyperlink(itemLink)
                    ShopFrameScanTooltip:Show()

                    if catId == 2 then -- Skins
                        local _, race = UnitRace("player")
                        local gender = "female"
                        if UnitSex("player") == 2 then
                            gender = "male"
                        end

                        local name = string.lower(entry.name)
                        if string.find(name, string.lower(races[race])) then
                            if string.find(name, "male") then
                                if string.find(name, "%A(" .. gender .. ")%A") then
                                    table.insert(shopEntries, 1, entry)
                                else
                                    entry.restricted = true

                                    table.insert(shopEntries, entry)
                                end
                            else
                                table.insert(shopEntries, 1, entry)
                            end
                        else
                            entry.restricted = true

                            table.insert(shopEntries, entry)
                        end
                    elseif catId == 4 then -- Glyphs
                        local found = false
                        local _, class = UnitClass("player")
                        local pattern = "classes: " .. strlower(class)
                        for i = 1, ShopFrameScanTooltip:NumLines() do
                            local text = getglobal("ShopFrameScanTooltipTextLeft" ..i):GetText()
                            if strfind(strlower(text), pattern) then
                                found = true
                                break
                            end
                        end

                        if found then
                            table.insert(shopEntries, 1, entry)
                        else
                            entry.restricted = true

                            table.insert(shopEntries, entry)
                        end
                    elseif catId == 7 and UIDropDownMenu_GetSelectedName(ShopFrameFashionDropDown) ~= "All" then -- Fashion
                        local slot = UIDropDownMenu_GetSelectedName(ShopFrameFashionDropDown)
                        local _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(entry.itemid)
                        if slots[itemEquipLoc] == slot then
                            table.insert(shopEntries, entry)
                        end
                    else
                        table.insert(shopEntries, entry)
                    end

                    ShopFrameScanTooltip:Hide()
                else
                    return
                end
            else
                return
            end
        end
    end
end

function Shop_ProcessBuyResult(arg)
    local rEx = explode(arg, ":")
    if rEx[2] then
        if rEx[2] == 'itemnotinshop' then
            print("Item is not available right now.")
        end
        if rEx[2] == 'bagsfulloralreadyhaveitem' then
            print("You cannot receive this item. Your inventory may be full.")
        end
        if rEx[2] == 'unknowndberror' then
            print("Can't process payment.")
        end
        if rEx[2] == 'dberrorcantprocess' then
            print("Can't process payment.")
        end
        if rEx[2] == 'notenoughtokens' then
            print("You don't have enough tokens to claim this!")
        end
        --if rEx[2] == 'ok' then
        --    print("Purchase was successful. Check your bags.")
        --end
    end
    Shop_GetBalance()
end

function ShopFrame_HideEntries()
    for i = 1, DONATION_SHOP_MAX_ENTRIES do
        getglobal("ShopFrameEntry" .. i):Hide()
    end

    for i = 1, 2 do
        getglobal("ShopFrameLargeEntry" .. i):Hide()
    end
end

function ShopFrameEntryButton_OnClick()
    local id = this:GetID()
    ShopFrame:SetID(shopEntries[id].id)
    StaticPopup_Show("SHOP_CONFIRMATION", shopEntries[id].name, shopEntries[id].price)
end

function ShopFrame_ChangePage(dir)
    ShopFrame_HideEntries()

    shopCurrentPage = shopCurrentPage + 1 * dir
    Shop_ProcessEntries("TW_SHOP Entries:" .. shopCurrentCategory .. "=end")
end

function ShopFrame_AddButtonOnEnterTextTooltip(frame, text, ext)
    frame:SetScript("OnEnter", function(self)

        GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -(this:GetWidth() / 4) + 20, -(this:GetHeight() / 4) + 10)

        GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE .. text)
        if ext then
            GameTooltip:AddLine(FONT_COLOR_CODE_CLOSE .. ext)
        end
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

function ShopFrame_AddButtonOnEnterTooltipShopFrame(frame, itemLink, infoText)
    if string.find(itemLink, "|", 1, true) then
        local ex = explode(itemLink, "|")

        if not ex[2] or not ex[3] then
            return false
        end

        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(frame, "ANCHOR_RIGHT", 10, 0);
            GameTooltip:SetHyperlink(string.sub(ex[3], 2, string.len(ex[3])));

            if infoText then
                GameTooltip:AddLine(infoText)
            end

            GameTooltip:Show();

        end)
    else
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(frame, "ANCHOR_RIGHT", 10, 0);
            GameTooltip:SetHyperlink(itemLink);

            if infoText then
                GameTooltip:AddLine(infoText)
            end

            GameTooltip:Show();
        end)
    end

    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide();
    end)
end

function ShopFrame_Toggle()
    if ShopFrame:IsVisible() then
        ShopFrame:Hide()
    else
        ShopFrame:Show()

        ShopFrameCategoryButton_OnClick(1)
    end
end

function ShopFrameFashionDropDown_OnLoad()
    local items = { "All", "Head", "Shoulders", "Back", "Chest", "Shirt", "Tabard", "Wrist", "Hands", "Waist", "Legs", "Feet", }

    for index in items do
        UIDropDownMenu_AddButton({
            text = items[index],
            func = ShopFrameFashionDropDown_OnSelect,
            arg1 = items[index],
        });
    end

    UIDropDownMenu_SetSelectedName(ShopFrameFashionDropDown, "All")
end

function ShopFrameFashionDropDown_OnSelect(value)
    UIDropDownMenu_SetSelectedName(ShopFrameFashionDropDown, value)

    ShopFrameCategoryButton_OnClick(8)
end

function ShopFrameEntryModel_OnEnter()
    local entry = this:GetParent()

    if entry:IsMouseEnabled() then
        entry:GetHighlightTexture():SetDrawLayer("OVERLAY")
    end

    local func = entry:GetScript("OnEnter")
    if func then
        func()
    end
end

function ShopFrameEntryModel_OnLeave()
    this:GetParent():GetHighlightTexture():SetDrawLayer("HIGHLIGHT")

    GameTooltip:Hide()
end

function ShopFrameEntryModel_OnMouseUp(button)
    if this:GetParent():IsMouseEnabled() then
        this:GetParent():Click()
    end
end

function ShopFrameEntryModel_OnMouseWheel(delta)
    this:SetFacing(this:GetFacing() + (delta * 0.1))
end

SLASH_TWSHOP1 = "/shop"
SlashCmdList["TWSHOP"] = function(cmd)
    if cmd then
		if string.find(cmd, 'button', 1, true) then
			TWS_HIDE_MINIMAP_BUTTON = 0

			MinimapShopFrame:Show()
		else
			ShopFrame_Toggle()
		end
	end
end