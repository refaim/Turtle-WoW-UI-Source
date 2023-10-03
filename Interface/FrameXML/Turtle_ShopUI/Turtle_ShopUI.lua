local tws = CreateFrame('frame')

if not TWS_HIDE_MINIMAP_BUTTON then
    TWS_HIDE_MINIMAP_BUTTON = 0
end

RegisterForSave("TWS_HIDE_MINIMAP_BUTTON");

function twsprint(a)
    if a == nil then
        DEFAULT_CHAT_FRAME:AddMessage('err:' .. time() .. '|cffffffff attempt to print a nil value.')
        return false
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd200" .. a)
end

tws:RegisterEvent("CHAT_MSG_ADDON")
tws:RegisterEvent("VARIABLES_LOADED")

tws.prefix = "TW_SHOP"
tws.balance = 0

tws.startDelayer = CreateFrame("Frame")
tws.startDelayer:Hide()

tws.startDelayer:SetScript("OnShow", function()
    this.startTime = GetTime()
end)

tws.startDelayer:SetScript("OnUpdate", function()
    local plus = 3
    local gt = GetTime() * 1000
    local st = (this.startTime + plus) * 1000
    if gt >= st then

        tws.getBalance()
        tws.getCategories()

        tws.startDelayer:Hide()

        this.startTime = GetTime()
    end
end)

function ShopFrame_OnLoad()
    tws.startDelayer:Show()
end

tws:SetScript("OnEvent", function()

    if event then
        if event == 'VARIABLES_LOADED' then
            if TWS_HIDE_MINIMAP_BUTTON == 0 then
                TWMinimapShopFrame:Show()
            else
                TWMinimapShopFrame:Hide()
            end
        end
        if event == 'CHAT_MSG_ADDON' and arg1 == tws.prefix then

            local message = arg2

            if string.find(message, "Balance:", 1, true) then
                tws.processBalance(message)
                return
            end

            if string.find(message, "Entries:", 1, true) then
                tws.processEntries(message)
                return
            end

            if string.find(message, "Categories:", 1, true) then
                tws.processCategories(message)
                return
            end

            if string.find(message, "BuyResult:", 1, true) then
                tws.processBuyResult(message)
                return
            end

        end

    end

end)

function tws.getBalance()
    SendAddonMessage(tws.prefix, "Balance", "GUILD")
    ShopFrameEntryFrameBuyButton:Enable()
end

function tw_getBalance()
    tws.getBalance()
end

function tws.processBalance(arg)
    local ex = __explode(arg, "Balance:")
    if ex[2] and tonumber(ex[2]) then
        tws.balance = tonumber(ex[2])
        ShopFrameBalance:SetText("Balance: " .. tws.balance)
    end
end

tws.categories = {}
tws.categoryFrames = {}

function tws.getCategories()
    SendAddonMessage(tws.prefix, "Categories", "GUILD")
end

function tws.processCategories(arg)

	arg = string.gsub(arg,"8","9")
	arg = string.gsub(arg,"7","8")
	arg = string.gsub(arg,"6","7")
	arg = string.gsub(arg,"5","6")
	arg = string.gsub(arg,"4","5")
	arg = string.gsub(arg,"3","4")
	arg = string.gsub(arg,"2","3")
	arg = string.gsub(arg,"1","2")
	arg = string.gsub(arg, ":", ":1=About=about;")

    for index in tws.categoryFrames do
        tws.categoryFrames[index]:Hide()
    end

    local ex = __explode(arg, "Categories:")
    if ex[2] then

        local cats = __explode(ex[2], ";")
        for _, cat in next, cats do
            if cat then
                local catEx = __explode(cat, "=")
                if catEx[2] then
                    local catId = tonumber(catEx[1])
                    tws.categories[catId] = {
                        name = catEx[2],
                        icon = catEx[3],
                    }

                    local index = tonumber(catEx[1])

                    if not tws.categoryFrames[index] then
                        tws.categoryFrames[index] = CreateFrame('Frame', 'TWSCategoryFrame' .. catId, ShopFrameCategoriesScrollFrameChild, 'TWSCategoryFrameTemplate')
                    end

                    tws.categoryFrames[index]:SetPoint("TOPLEFT", ShopFrameCategoriesScrollFrameChild, "TOPLEFT", 2, 30 - 36 * index)
                    tws.categoryFrames[index].id = catId

                    getglobal('TWSCategoryFrame' .. index .. 'ButtonName'):SetText(catEx[2])
                    getglobal('TWSCategoryFrame' .. index .. 'Button'):SetID(catId)
                    getglobal('TWSCategoryFrame' .. index .. 'IconIcon'):SetTexture("Interface\\ShopFrame\\" .. catEx[3])

                end
            end
        end

        ShopFrameCategoriesScrollFrame:SetVerticalScroll(0)
        ShopFrameCategoriesScrollFrame:UpdateScrollChildRect()
    end

    if tws.tableSize(tws.categories) > 0 then
        ShopFrameCategoryButton_OnClick(1)
    end

end

function ShopFrameCategoryButton_OnClick(id)

	ShopFrameEntryFrame:Hide()

    for _, data in tws.categoryFrames do
        getglobal('TWSCategoryFrame' .. data.id .. 'ButtonSelected'):Hide()
    end
    getglobal('TWSCategoryFrame' .. id .. 'ButtonSelected'):Show()
	
	if id == 1 then
		for index in tws.entryFrames do
			tws.entryFrames[index]:Hide()
		end
		ShopFrameFramePageText:Hide()
		ShopFrameLeftArrow:Hide()
		ShopFrameLeftArrow:Disable()
		ShopFrameRightArrow:Hide()
		ShopFrameRightArrow:Disable()

		ShopFrameAboutFrameLongText:SetText([[
Please be aware of the following: 

• All donation rewards are soulbound, not account-bound. 

• Non-hardcore characters have a 48-hour grace period to request refunds on donation rewards. 

• Tokens will automatically be returned upon Hardcore death. Please create a Hardcore character to preview donation rewards. 

• Deleting a non-hardcore character will not refund tokens.

For any issues, open a GM ticket using /gm.
]])
		ShopFrameAboutFrame:Show()
		return
	end
	ShopFrameAboutFrame:Hide()

	id = id - 1
    SendAddonMessage(tws.prefix, "Entries:" .. id, "GUILD")

    tws.currentCategory = id
    tws.entryPage = 1

end

tws.entries = {}
tws.entryFrames = {}
tws.entryPage = 1
tws.currentCategory = nil
tws.totalPages = 0

function tws.processEntries(arg)

    local ex = __explode(arg, "=")
    local catId = 0

    local catEx = __explode(arg, "Entries:")
    if catEx[2] then
        local catEx2 = __explode(catEx[2], "=")
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
            tws.entries = {}
        end
        if ex[2] == "end" then


            ShopFrameFramePageText:Hide()
            ShopFrameLeftArrow:Hide()
            ShopFrameLeftArrow:Disable()
            ShopFrameRightArrow:Hide()
            ShopFrameRightArrow:Disable()

            tws.totalPages = tws.ceil(tws.tableSize(tws.entries) / 8)

            if tws.totalPages > 1 then
                ShopFrameFramePageText:SetText("Page " .. tws.entryPage .. "/" .. tws.totalPages)
                ShopFrameFramePageText:Show()

                ShopFrameLeftArrow:Show()
                ShopFrameRightArrow:Show()

                if tws.entryPage == 1 then
                    ShopFrameLeftArrow:Disable()
                else
                    ShopFrameLeftArrow:Enable()
                end

                if tws.entryPage == tws.totalPages then
                    ShopFrameRightArrow:Disable()
                else
                    ShopFrameRightArrow:Enable()
                end

            end

            for index in tws.entryFrames do
                tws.entryFrames[index]:Hide()
            end

            local x = 0
            local y = 0
            local entryIndex = 0

            for id, entry in tws.entries do

                entryIndex = entryIndex + 1

                if entryIndex > (tws.entryPage - 1) * 8 and entryIndex <= 8 * tws.entryPage then

                    x = x + 1

                    if x == 5 then
                        y = 160
                        x = 1
                    end

                    if not tws.entryFrames[id] then
                        tws.entryFrames[id] = CreateFrame('Frame', 'TWSEntryFrame' .. id, ShopFrame, 'TWSEntryFrameTemplate')
                    end

                    tws.entryFrames[id]:SetPoint("TOPLEFT", ShopFrame, "TOPLEFT", 120 + 112 * x, -74 - y)

                    getglobal('TWSEntryFrame' .. id .. 'Button'):SetNormalTexture("Interface\\ShopFrame\\item_normal")
                    getglobal('TWSEntryFrame' .. id .. 'Button'):SetNormalTexture("Interface\\ShopFrame\\entries\\" .. id)
                    getglobal('TWSEntryFrame' .. id .. 'Button'):SetPushedTexture("Interface\\ShopFrame\\item_normal")
                    getglobal('TWSEntryFrame' .. id .. 'Button'):SetPushedTexture("Interface\\ShopFrame\\entries\\" .. id)
                    getglobal('TWSEntryFrame' .. id .. 'ButtonName'):SetText(entry.name)
                    getglobal('TWSEntryFrame' .. id .. 'ButtonPrice'):SetText(entry.price)
                    getglobal('TWSEntryFrame' .. id .. 'Button'):SetID(id)

                    local item = "item:" .. id .. ":0:0:0"
                    local _, _, itemLink = string.find(item, "(item:%d+:%d+:%d+:%d+)");

                    local infoText = ''

                    if string.find(string.lower(entry.name), "tabard", 1, true) then
                        infoText = 'CTRL-Left Click to display this\ntabard on your character.'
                        getglobal('TWSEntryFrame' .. id .. 'Button'):SetScript("OnClick", function(self)
                            if IsControlKeyDown() then
                                DressUpItemLink(itemLink)
                            else
                                ShopFrameEntryButton_OnClick(this:GetID())
                            end
                        end)
                    end

                    tws.AddButtonOnEnterTooltipShopFrame(getglobal('TWSEntryFrame' .. id .. 'Button'), itemLink, infoText)

                    tws.entryFrames[id]:Show()

                end
            end
        end
        if ex[2] ~= "start" and ex[2] ~= "end" then

            if catEx[2] then
                local catEx2 = __explode(catEx[2], "=")
                if catEx2[1] and tonumber(catEx2[1]) then
                    catId = tonumber(catEx2[1])

                    tws.entries[tonumber(catEx2[5])] = {
                        ['name'] = catEx2[2],
                        ['price'] = tonumber(catEx2[3]),
                        ['text'] = catEx2[4],
                        ['id'] = tonumber(catEx2[5]),
                    }

                else
                    return
                end
            else
                return
            end
        end
    end
end

function tws.processBuyResult(arg)
    local rEx = __explode(arg, ":")
    if rEx[2] then
        if rEx[2] == 'itemnotinshop' then
            twsprint("Item is not available right now.")
        end
        if rEx[2] == 'bagsfulloralreadyhaveitem' then
            twsprint("You cannot receive this item. Your inventory may be full.")
        end
        if rEx[2] == 'unknowndberror' then
            twsprint("Can't process payment.")
        end
        if rEx[2] == 'dberrorcantprocess' then
            twsprint("Can't process payment.")
        end
        if rEx[2] == 'notenoughtokens' then
            twsprint("You don't have enough tokens to buy this!")
        end
        --if rEx[2] == 'ok' then
        --    twsprint("Purchase was successful. Check your bags.")
        --end
    end
    tws.getBalance()
end

function ShopFrameEntryButton_OnClick(id)

    for index in tws.entryFrames do
        tws.entryFrames[index]:Hide()
    end

    ShopFrameFramePageText:Hide()
    ShopFrameLeftArrow:Hide()
    ShopFrameLeftArrow:Disable()
    ShopFrameRightArrow:Hide()
    ShopFrameRightArrow:Disable()

    ShopFrameEntryFrameImage:SetTexture("Interface\\ShopFrame\\entries\\" .. id)
    ShopFrameEntryFrameName:SetText(tws.entries[id].name)
    ShopFrameEntryFrameLongText:SetText(tws.entries[id].text)
    ShopFrameEntryFramePrice:SetText(tws.entries[id].price)
    ShopFrameEntryFrameBuyButton:SetID(tws.entries[id].id)

    if tws.balance < tws.entries[id].price then
        tws.AddButtonOnEnterTextTooltip(ShopFrameEntryFrameBuyButton, "You don't have enough tokens to buy this!", "You can buy tokens our website.")
    end

    ShopFrameEntryFrameBuyButton:Enable()
    ShopFrameEntryFrame:Show()
end

function ShopFrameBuyButton_OnClick(id)
    ShopFrameEntryFrameBuyButton:Disable()
    SendAddonMessage(tws.prefix, "Buy:" .. id, "GUILD")
end

function ShopFrame_ChangePage(dir)
    tws.entryPage = tws.entryPage + 1 * dir
    tws.processEntries("TW_SHOP Entries:" .. tws.currentCategory .. "=end")
end

function __explode(str, delimiter)
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

function tws.AddButtonOnEnterTextTooltip(frame, text, ext)
    frame:SetScript("OnEnter", function(self)

        ShopFrameTooltip:SetOwner(this, "ANCHOR_RIGHT", -(this:GetWidth() / 4) + 20, -(this:GetHeight() / 4) + 10)

        ShopFrameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE .. text)
        if ext then
            ShopFrameTooltip:AddLine(FONT_COLOR_CODE_CLOSE .. ext)
        end
        ShopFrameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function(self)
        ShopFrameTooltip:Hide()
    end)
end

function tws.AddButtonOnEnterTooltipShopFrame(frame, itemLink, infoText)

    if string.find(itemLink, "|", 1, true) then
        local ex = __explode(itemLink, "|")

        if not ex[2] or not ex[3] then
            return false
        end

        frame:SetScript("OnEnter", function(self)
            ShopFrameTooltip:SetOwner(this, "ANCHOR_RIGHT", -(this:GetWidth() / 4) + 25, -(this:GetHeight() / 4));
            ShopFrameTooltip:SetHyperlink(string.sub(ex[3], 2, string.len(ex[3])));

            if infoText then
                ShopFrameTooltip:AddLine(infoText)
            end

            ShopFrameTooltip:Show();

        end)
    else
        frame:SetScript("OnEnter", function(self)
            ShopFrameTooltip:SetOwner(this, "ANCHOR_RIGHT", -(this:GetWidth() / 4) + 25, -(this:GetHeight() / 4));
            ShopFrameTooltip:SetHyperlink(itemLink);

            if infoText then
                ShopFrameTooltip:AddLine(infoText)
            end

            ShopFrameTooltip:Show();
        end)
    end
    frame:SetScript("OnLeave", function(self)
        ShopFrameTooltip:Hide();
    end)
end

function tws.tableSize(t)
    local s = 0
    for i in t do
        s = s + 1
    end
    return s
end

function tws.ceil(num)
    if num > math.floor(num) then
        return math.floor(num + 1)
    end
    return math.floor(num + 0.5)
end

function tws_toggle()
    if ShopFrame:IsVisible() then
        ShopFrame:Hide()
    else
        ShopFrame:Show()
    end
end

function tws_minimap_hide()
    local tws_minimap_menu = CreateFrame('Frame', 'tws_minimap_menu', UIParent, 'UIDropDownMenuTemplate')
    UIDropDownMenu_Initialize(tws_minimap_menu, tws_build_minimap_menu, "MENU");
    ToggleDropDownMenu(1, nil, tws_minimap_menu, "cursor", 2, 3);
end


function tws_build_minimap_menu()
    local title = {};
    title.text = "Donation Rewards"
    title.disabled = false
    title.isTitle = true
    title.func = function()
        --
    end
    UIDropDownMenu_AddButton(title);

    local menu_enabled = {};
    menu_enabled.text = "Hide Button"
    menu_enabled.disabled = false
    menu_enabled.isTitle = false
    menu_enabled.tooltipTitle = 'Hide Button'
    menu_enabled.tooltipText = 'Hide this minimap button.'
    menu_enabled.justifyH = 'LEFT'
    menu_enabled.func = function()
        TWS_HIDE_MINIMAP_BUTTON = 1
        TWMinimapShopFrame:Hide()
        DEFAULT_CHAT_FRAME:AddMessage("Donation rewards minimap button hidden. Type '/twshop showbutton' to show it.")
    end
    UIDropDownMenu_AddButton(menu_enabled);

    local close = {};
    close.text = "Close"
    close.disabled = false
    close.isTitle = false
    close.func = function()
        --
    end
    UIDropDownMenu_AddButton(close);
end


SLASH_TWSHOP1, SLASH_TWSHOP2 = "/twshop", "/shop"
SlashCmdList["TWSHOP"] = function(cmd)
    if cmd then
		if string.find(cmd, 'showbutton', 1, true) or string.find(cmd, 'button', 1, true) or string.find(cmd, 'show', 1, true) then
			TWS_HIDE_MINIMAP_BUTTON = 0
			TWMinimapShopFrame:Show()
		else
			tws_toggle()
		end
	end
end