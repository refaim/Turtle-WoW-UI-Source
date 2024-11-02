local boon = CreateFrame("Frame")
local boonTip = CreateFrame("Frame", "boonTip", GameTooltip)

boonTip:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

boon:RegisterEvent("ADDON_LOADED")
boon:RegisterEvent("CHAT_MSG_SYSTEM")

boon:SetScript("OnEvent", function()

    if event then

        if event == "ADDON_LOADED" then

            local bmLoaded, bmReason = LoadAddOn("Blizzard_BattlefieldMinimap")

            if not BattlefieldMinimapOptions.chronoboon then
                BattlefieldMinimapOptions.chronoboon = {}
            end
        
            BOON_BUFFS = BattlefieldMinimapOptions.chronoboon

            local TWLC2cChronoboonHookSetBagItem = GameTooltip.SetBagItem
            function GameTooltip.SetBagItem(self, container, slot)
                GameTooltip.itemLink = GetContainerItemLink(container, slot)
                _, GameTooltip.itemCount = GetContainerItemInfo(container, slot)
                return TWLC2cChronoboonHookSetBagItem(self, container, slot)
            end

        elseif event == "CHAT_MSG_SYSTEM" then

            if string.find(arg1, "Suspended ", 1, true)
                    and string.find(arg1, "m).", 1, true) then

                        BOON_BUFFS[table.getn(BOON_BUFFS) + 1] = string.sub(arg1, string.find(arg1, "Suspended ", 1, true) + 10, string.len(arg1) -1 )

            elseif string.find(arg1, "Restored ", 1, true)
                    and string.find(arg1, "m).", 1, true) then

                if table.getn(BOON_BUFFS) > 0 then
                    BOON_BUFFS = {}
                end

            end
        end
    end

end)

boonTip:SetScript("OnShow", function()
    if GameTooltip.itemLink then

        local _, _, itemLink = string.find(GameTooltip.itemLink, "(item:%d+:%d+:%d+:%d+)");

        if not itemLink then
            return false
        end

        local itemName = GetItemInfo(itemLink)

        if itemName == "Supercharged Chronoboon Displacer" then
            GameTooltip:AddLine("\n")
            GameTooltip:AddLine("World effects suspended:")

            for _, buff in BOON_BUFFS do
                GameTooltip:AddLine(buff, 1, 1, 1)
            end

            GameTooltip:AddLine("\n")
            GameTooltip:AddLine("While a world effect is suspended, you")
            GameTooltip:AddLine("cannot benefit from it.")

            GameTooltip:Show()
        end

    end
end)

boonTip:SetScript("OnHide", function()
    GameTooltip.itemLink = nil
end)
