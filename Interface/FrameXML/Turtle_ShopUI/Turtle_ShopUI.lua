local DONATION_SHOP_MAX_ENTRIES = 8
local DONATION_SHOP_PREFIX = "TW_SHOP"

StaticPopupDialogs["SHOP_CONFIRMATION"] = {
    text = TEXT(DONO_SHOP_CONFIRM),
    button1 = TEXT(YES),
    button2 = TEXT(NO),
    OnAccept = function(id)
        SendAddonMessage(DONATION_SHOP_PREFIX, "Buy:" .. ShopFrame:GetID(), "GUILD")
    end,
    timeout = 6,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local shopBalance = 0
local shopCategoryFrames = {}
local shopCurrentCategory = nil
local shopCurrentSubcategory = nil
local shopCurrentPage = 1
local shopEntries = nil

if not TWS_HIDE_MINIMAP_BUTTON then
    TWS_HIDE_MINIMAP_BUTTON = 0
end

RegisterForSave("TWS_HIDE_MINIMAP_BUTTON")

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
        if event == "VARIABLES_LOADED" then
            MinimapShopFrame:Disable()
            if TWS_HIDE_MINIMAP_BUTTON == 0 then
                MinimapShopFrame:Show()
            else
                MinimapShopFrame:Hide()
            end
        end

        if event == "CHAT_MSG_ADDON" and arg1 == DONATION_SHOP_PREFIX then
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
        DEFAULT_CHAT_FRAME:AddMessage("err:" .. time() .. "|cffffffff attempt to print a nil value.")
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
        ShopFrameBalance:SetText(TEXT(DONO_SHOP_BALANCE) .. shopBalance)
    end
end

function Shop_GetCategories()
    SendAddonMessage(DONATION_SHOP_PREFIX, "Categories", "GUILD")
end

function Shop_ProcessCategories(arg)
    arg = string.gsub(arg, ":", ":0=0=" .. DONO_SHOP_ABOUT_TITLE .. "=about;")

    local ex = explode(arg, "Categories:")
    if ex[2] then
        local cats = explode(ex[2], ";")
        for _, cat in next, cats do
            if cat then
                local catEx = explode(cat, "=")
                if catEx[2] then
                    local categoryID = tonumber(catEx[1])
                    local parentID = tonumber(catEx[2])
                    local name = catEx[3]
                    local icon = catEx[4]

                    -- fetch category entries
                    SendAddonMessage(DONATION_SHOP_PREFIX, "Entries:" .. categoryID, "GUILD")

                    if parentID > 0 then
                        -- category has a parentID which means it's a subcategory
                        local frame = CreateFrame("Button", "ShopFrameSubcategoryFrame" .. parentID .. categoryID, ShopFrameCategoriesScrollFrameChild, "ShopSubcategoryFrameTemplate")

                        shopCategoryFrames[parentID].subcategories[categoryID] = frame

                        frame:SetID(parentID)
                        frame:SetPoint("TOPLEFT", ShopFrameCategoriesScrollFrameChild, "TOPLEFT", 8, 24 - 36 * (parentID + 1) - 30 * sizeof(shopCategoryFrames[parentID].subcategories))
                        frame.subcategoryID = categoryID

                        getglobal(frame:GetName() .. "Name"):SetText(name)
                    else
                        local frame = CreateFrame("Button", "ShopFrameCategoryFrame" .. categoryID, ShopFrameCategoriesScrollFrameChild, "ShopCategoryFrameTemplate")
                        frame:SetID(categoryID)
                        frame:SetPoint("TOPLEFT", ShopFrameCategoriesScrollFrameChild, "TOPLEFT", 2, 30 - 36 * (categoryID + 1))

                        getglobal(frame:GetName() .. "Name"):SetText(name)
                        getglobal(frame:GetName() .. "IconTexture"):SetTexture("Interface\\ShopFrame\\" .. icon)

                        shopCategoryFrames[categoryID] = frame
                    end
                end
            end
        end

        ShopFrameCategoriesScrollFrame:SetVerticalScroll(0)
        ShopFrameCategoriesScrollFrame:UpdateScrollChildRect()
    end
end

function ShopFrameCategoryButton_OnClick(category, subcategory)
    shopCurrentCategory = category
    shopCurrentSubcategory = subcategory
    shopCurrentPage = 1

    -- hide entries
    ShopFrame_HideEntries()

    -- update currently selected category highlight
    if ShopFrame.selected then
        ShopFrame.selected:Hide()
    end
    ShopFrame.selected = getglobal(this:GetName() .. "Selected")
    ShopFrame.selected:Show()

    if subcategory then
        Shop_ShowEntries(category, subcategory)
        return
    end

    for i, frame in shopCategoryFrames do
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

        ShopFrameAboutFrame:Show()
		ShopFrameAboutFrameLongText:SetText(DONO_SHOP_ABOUT_TEXT)

        ShopFrameCategoriesScrollFrame:UpdateScrollChildRect()
		return
	end
    ShopFrameAboutFrame:Hide()

    if this.subcategories and sizeof(this.subcategories) > 0 then
        for i = category, sizeof(shopCategoryFrames) do
            if shopCategoryFrames[i + 1] then
                shopCategoryFrames[i + 1]:SetPoint("TOPLEFT", ShopFrameCategoriesScrollFrameChild, "TOPLEFT", 2, 28 - 36 * (i + 2) - 30 * (sizeof(this.subcategories)))
            end
        end

        for _, frame in this.subcategories do
            frame:Show()
        end
    end

    ShopFrameCategoriesScrollFrame:UpdateScrollChildRect()

    Shop_ShowEntries(category)
end

function Shop_ProcessEntries(arg)
    shopEntries = shopEntries or {}

    local ex = explode(arg, "=")
    local catEx = explode(arg, "Entries:")

    if ex[2] ~= "start" and ex[2] ~= "end" then
        if catEx[2] then
            local catEx2 = explode(catEx[2], "=")
            if catEx2[1] and tonumber(catEx2[1]) then
                local entry = {
                    ["id"] = tonumber(catEx2[6]),
                    ["subcategory"] = tonumber(catEx2[2]),
                    ["name"] = catEx2[3],
                    ["price"] = tonumber(catEx2[4]),
                    ["text"] = catEx2[5],
                    ["modelid"] = tonumber(catEx2[7]),
                    ["itemid"] = tonumber(catEx2[8]),
                    ["posx"] = tonumber(catEx2[9]),
                    ["posy"] = tonumber(catEx2[10]),
                    ["posz"] = tonumber(catEx2[11]),
                    ["rotation"] = tonumber(catEx2[12]),
                    ["holiday"] = tonumber(catEx2[13]),
                    ["restricted"] = nil,
                }

                local catId = tonumber(catEx2[1])
                shopEntries[catId] = shopEntries[catId] or {}

                local itemLink = "item:" .. entry["id"] .. ":0:0:0"

                -- force cache item
                ShopFrameScanTooltip:ClearLines()
                ShopFrameScanTooltip:SetOwner(WorldFrame, "BOTTOMRIGHT")
                ShopFrameScanTooltip:SetHyperlink(itemLink)
                ShopFrameScanTooltip:Show()
                ShopFrameScanTooltip:Hide()

                if entry["holiday"] > 0 then
                    table.insert(shopEntries[catId], 1, entry)
                else
                    table.insert(shopEntries[catId], entry)
                end
            end
        end
    end
end

function Shop_ShowEntries(category, subcategory)
    ShopFrame_HideEntries()

    ShopFramePageText:Hide()
    ShopFramePreviousButton:Hide()
    ShopFramePreviousButton:Disable()
    ShopFrameNextButton:Hide()
    ShopFrameNextButton:Disable()

    local entries = shopEntries[category]

    if subcategory then
        local t = {}
        for _, entry in entries do
            if entry["subcategory"] == subcategory then
                table.insert(t, entry)
            end
        end

        entries = t
    end

    if category == 7 then
        DONATION_SHOP_MAX_ENTRIES = 2
    else
        DONATION_SHOP_MAX_ENTRIES = 8
    end

    local shopTotalPages = ceil(sizeof(entries) / DONATION_SHOP_MAX_ENTRIES)
    if shopTotalPages > 1 then
        ShopFramePageText:SetText(GENERIC_PAGE .. " " .. shopCurrentPage .. "/" .. shopTotalPages)
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

    for index, entry in entries do
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

            entryFrame.data = entry
            entryFrame:SetNormalTexture("Interface\\ShopFrame\\item_normal")
            entryFrame:Show()

            if entry["restricted"] then
                entryFrame:GetNormalTexture():SetDesaturated(1)
                entryFrame:EnableMouse(0)
            end

            if entry["holiday"] > 0 then
                getglobal(entryFrame:GetName() .. "FeaturedFrame"):Show()
            end

            getglobal(entryFrame:GetName() .. "Name"):SetText(entry.name)

            local priceText = getglobal(entryFrame:GetName() .. "Price")
            priceText:SetText(entry.price)
            if shopBalance < entry.price then
                priceText:SetTextColor(0.9, 0.1, 0.1)
            end

            entryFrame.dress = nil
            entryFrame.model = nil

            if category == 2 then
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

                local model = getglobal("ShopEntryModel"..frameId)
                if not model then
                    model = CreateFrame("PlayerModel", "ShopEntryModel"..frameId, entryFrame, "ShopEntryModelTemplate")
                    model:SetPoint("TOPLEFT", entryFrame, 10, -10)
                    model:SetPoint("BOTTOMRIGHT", entryFrame, -10, 50)
                end
                model:Show()
                model:SetID(index)
                model:SetModelScale(1)
                model:SetPosition(0, 0, 0)
                model:SetFacing(0)
                model:SetUnit(entry.modelid)
                model:SetScript("OnUpdate", function()
                    if this.elapsed >= 0.05 then
                        local data = entries[this:GetID()]
                        local scale = UIParent:GetScale() or 1.0

                        this.elapsed = 0

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
                    model:Show()
                    model:Undress()
                    model:TryOn(entry.itemid)
                end

                entryFrame.dress = entry.itemid
            else
                local itemBorder = getglobal(entryFrame:GetName() .. "ItemBorder")
                local itemTexture = getglobal(entryFrame:GetName() .. "ItemTexture")
                local link = "item:" .. entries[index].id .. ":0:0:0"
                local _, _, _, _, _, _, _, _, texture = GetItemInfo(link)

                itemBorder:Show()

                itemTexture:Show()
                itemTexture:SetTexture(texture)
                SetPortraitToTexture(itemTexture, texture)

                if entries[index].restricted then
                    itemBorder:SetDesaturated(1)

                    itemTexture:SetDesaturated(1)
                end
            end

            ShopFrame_AddButtonOnEnterTooltipShopFrame(entryFrame, itemLink)
        end
    end
end

function Shop_ProcessBuyResult(arg)
    local rEx = explode(arg, ":")
    if rEx[2] then
        if rEx[2] == "itemnotinshop" then
            print(DONO_SHOP_MSG_UNKNOWN_ITEM)
        end
        if rEx[2] == "bagsfulloralreadyhaveitem" then
            print(DONO_SHOP_MSG_FULL_BAGS)
        end
        if rEx[2] == "unknowndberror" then
            print(DONO_SHOP_MSG_UNKNOWN_ERR)
        end
        if rEx[2] == "dberrorcantprocess" then
            print(DONO_SHOP_MSG_CANT_PROCESS)
        end
        if rEx[2] == "notenoughtokens" then
            print(DONO_SHOP_MSG_INSUFFICIENT_TOKENS)
        end
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
    ShopFrame:SetID(this.data["id"])
    if shopBalance < this.data["price"] then
        print(DONO_SHOP_MSG_INSUFFICIENT_TOKENS)
        return
    end
    StaticPopup_Show("SHOP_CONFIRMATION", this.data["name"], this.data["price"])
end

function ShopFrame_ChangePage(dir)
    ShopFrame_HideEntries()

    shopCurrentPage = shopCurrentPage + 1 * dir
    Shop_ShowEntries(shopCurrentCategory, shopCurrentSubcategory)
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

        shopCategoryFrames[0]:Click()
        --ShopFrameCategoryButton_OnClick(0)
    end
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

function ShopFrameEntryModel_OnMouseDown()
    this.clickedAt = GetTime()

    local startX = GetCursorPosition()
    local endX

    this:SetScript("OnUpdate", function()
        endX = GetCursorPosition()

        this.rotation = (endX - startX) / 34 + this:GetFacing()

        this:SetFacing(this.rotation)

        startX = GetCursorPosition()
    end)
end

function ShopFrameEntryModel_OnMouseUp(button)
    this:SetScript("OnUpdate", nil)

    if this:GetParent():IsMouseEnabled() and GetTime() - this.clickedAt < 0.1 then
        this:GetParent():Click()
    end
end

SLASH_TWSHOP1 = "/shop"
SlashCmdList["TWSHOP"] = function(cmd)
    if cmd then
		if string.find(cmd, "button", 1, true) then
			TWS_HIDE_MINIMAP_BUTTON = 0

			MinimapShopFrame:Show()
		else
			ShopFrame_Toggle()
		end
	end
end