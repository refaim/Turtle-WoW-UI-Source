local spellCom = CreateFrame("Frame")
spellCom:RegisterEvent("CHAT_MSG_ADDON")
spellCom:RegisterEvent("VARIABLES_LOADED")
spellCom:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

function spellCom.replace(text, search, replace)
    if search == replace then
        return text
    end
    local searchedtext = ""
    local textleft = text
    while string.find(textleft, search, 1, true) do
        searchedtext = searchedtext .. string.sub(textleft, 1, string.find(textleft, search, 1, true) - 1) .. replace
        textleft = string.sub(textleft, string.find(textleft, search, 1, true) + string.len(search))
    end
    if string.len(textleft) > 0 then
        searchedtext = searchedtext .. textleft
    end
    return searchedtext
end

function spellCom.explode(str, delimiter)
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

spellCom:SetScript("OnEvent", function()
    if event then
        if event == "VARIABLES_LOADED" then
            spellCom.hookFunctions()
        end

        if event == "CHAT_MSG_ADDON" and arg1 == "TW_CHAT_MSG_WHISPER" then

            local message = arg2
            local from = arg4

            if string.find(message, "SpellInfoAnswer_", 1, true) then
                showSpellTooltip(message)
            end
            if string.find(message, "TalentInfoAnswer_", 1, true) then
                showSpellTooltip(message)
            end
            if string.find(message, "TalentInfoRequest_", 1, true) then
                local spellData = spellCom.explode(message, "_")
                local tab = spellData[2]
                local id = spellData[3]
                if tab and id then
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");

                    if GameTooltip:SetTalent(tonumber(tab), tonumber(id)) then
                    end

                    GameTooltip:Show()

                    local tip = ''
                    for i = 1, 30 do
                        if getglobal('GameTooltipTextLeft' .. i) and getglobal('GameTooltipTextLeft' .. i):IsVisible() and getglobal('GameTooltipTextLeft' .. i):GetText() then
                            tip = tip .. "L" .. i .. ";" .. getglobal('GameTooltipTextLeft' .. i):GetText() .. "@"
                        end
                        if getglobal('GameTooltipTextRight' .. i) and getglobal('GameTooltipTextRight' .. i):IsVisible() and getglobal('GameTooltipTextRight' .. i):GetText() then
                            tip = tip .. "R" .. i .. ";" .. getglobal('GameTooltipTextRight' .. i):GetText() .. "@"
                        end
                    end
                    GameTooltip:Hide()

                    if tip ~= '' then
                        tip = spellCom.replace(tip, ':', '*dd*')
                        tip = spellCom.replace(tip, 'Click to learn', '')
                        SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. from .. ">", ":TalentInfoAnswer_" .. tip, "GUILD")
                    end

                end
            end
            if string.find(message, "SpellInfoRequest_", 1, true) then
                local spellData = spellCom.explode(message, "_")
                local id = spellData[2]
                if id then
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");

                    if GameTooltip:SetSpell(id, SpellBookFrame.bookType) then
                    end

                    GameTooltip:Show()

                    local tip = ''
                    for i = 1, 30 do
                        if getglobal('GameTooltipTextLeft' .. i) and getglobal('GameTooltipTextLeft' .. i):IsVisible() and getglobal('GameTooltipTextLeft' .. i):GetText() then
                            tip = tip .. "L" .. i .. ";" .. getglobal('GameTooltipTextLeft' .. i):GetText() .. "@"
                        end
                        if getglobal('GameTooltipTextRight' .. i) and getglobal('GameTooltipTextRight' .. i):IsVisible() and getglobal('GameTooltipTextRight' .. i):GetText() then
                            tip = tip .. "R" .. i .. ";" .. getglobal('GameTooltipTextRight' .. i):GetText() .. "@"
                        end
                    end
                    GameTooltip:Hide()

                    if tip ~= '' then
                        tip = spellCom.replace(tip, ':', '*dd*')
                        SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. from .. ">", ":SpellInfoAnswer_" .. tip, "GUILD")
                    end

                end

            end
        end
    end
end)

function SpellButton_OnClick(drag)

    local id = SpellBook_GetSpellID(this:GetID());
    if (id > MAX_SPELLS) then
        return ;
    end
    this:SetChecked("false");
    if (drag) then
        PickupSpell(id, SpellBookFrame.bookType);
    elseif (IsShiftKeyDown()) then
        local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType);
        if (MacroFrame and MacroFrame:IsVisible()) then
            if (spellName and not IsSpellPassive(id, SpellBookFrame.bookType)) then
                if (subSpellName and (string.len(subSpellName) > 0)) then
                    MacroFrame_AddMacroLine(TEXT(SLASH_CAST1) .. " " .. spellName .. "(" .. subSpellName .. ")");
                else
                    MacroFrame_AddMacroLine(TEXT(SLASH_CAST1) .. " " .. spellName);
                end
            end
        elseif ChatFrameEditBox:IsVisible() and spellName then
            local spell = "|cFF71D5FF|Hspell:" .. id .. ":0:" .. UnitName("player") .. ":|h[" .. spellName .. "]|h|r"
            ChatFrameEditBox:Insert(spell)
        else
            PickupSpell(id, SpellBookFrame.bookType);
        end
    elseif (arg1 ~= "LeftButton" and SpellBookFrame.bookType == BOOKTYPE_PET) then
        ToggleSpellAutocast(id, SpellBookFrame.bookType);
    else
        CastSpell(id, SpellBookFrame.bookType);
        SpellButton_UpdateSelection();
    end
end

function spellCom.hookFunctions()
    local talent_click = TalentFrameTalent_OnClick

    if talent_click then
        TalentFrameTalent_OnClick = function(...)
            if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
                local name = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), this:GetID());
                local talent = "|cFF71D5FF|Htalent:" .. PanelTemplates_GetSelectedTab(TalentFrame) .. ":" .. this:GetID() .. ":" .. UnitName("player") .. ":|h[" .. name .. "]|h|r"
                ChatFrameEditBox:Insert(talent)
                return
            end
            talent_click(unpack(arg))
        end
    end

    local hyperlink_show = ChatFrame_OnHyperlinkShow

    if hyperlink_show then
        ChatFrame_OnHyperlinkShow = function(link, text, button, ...)
            if string.find(link, 'spell:', 1, true) then

                if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
                    ChatFrameEditBox:Insert(text);
                    return
                end

                local textEx = spellCom.explode(link, ":")
                if textEx[2] and textEx[4] then
                    SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. textEx[4] .. ">", ":SpellInfoRequest_" .. textEx[2], "GUILD")
                end

                return
            elseif string.find(link, 'talent', 1, true) then
                if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
                    ChatFrameEditBox:Insert(text);
                    return
                end

                local textEx = spellCom.explode(link, ":")
                if textEx[2] and textEx[3] and textEx[4] then
                    SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. textEx[4] .. ">", ":TalentInfoRequest_" .. textEx[2] .. "_" .. textEx[3], "GUILD")
                end

                return
            end

            hyperlink_show(link, text, button, unpack(arg))
        end
    end
end

function showSpellTooltip(arg)

    local spellInfo = spellCom.explode(arg, "_")

    if spellInfo[2] then

        local blankSpellId = nil
        for id = 1, 100 do
            local name = GetSpellName(id, BOOKTYPE_SPELL);
            if name and name == "Attack" then
                blankSpellId = id
                break
            end
        end

        if not blankSpellId then
            return false
        end

        ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
        ItemRefTooltip:SetSpell(blankSpellId, SpellBookFrame.bookType)
        ItemRefTooltip:ClearLines()

        for i = 1, 30 do
            getglobal('ItemRefTooltipTextLeft' .. i):Hide()
            getglobal('ItemRefTooltipTextRight' .. i):Hide()
        end

        local sDet = spellCom.explode(spellInfo[2], "@")
        for _, s in sDet do
            local data = spellCom.explode(s, ";")

            if string.find(data[1], "L", 1, true) then

                data[2] = spellCom.replace(data[2], '*dd*', ':')

                if string.find(data[2], ".", 1, true) then
                    getglobal('ItemRefTooltip'):AddLine("|cffffd200" .. data[2], 1, 1, 1, 1)
                else
                    getglobal('ItemRefTooltip'):AddLine(data[2], 1, 1, 1)
                end
                getglobal('ItemRefTooltipTextLeft' .. string.sub(data[1], 2)):Show()

            end
            if string.find(data[1], "R", 1, true) then

                data[2] = spellCom.replace(data[2], '*dd*', ':')

                getglobal('ItemRefTooltipTextRight' .. string.sub(data[1], 2)):SetText(data[2])
                getglobal('ItemRefTooltipTextRight' .. string.sub(data[1], 2)):Show()
            end
        end
        ItemRefTooltip:Show()
    end
end
