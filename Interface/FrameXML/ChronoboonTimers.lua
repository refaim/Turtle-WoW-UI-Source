local BoonBuffs

local boon = CreateFrame("Frame")
boon:RegisterEvent("PLAYER_LOGIN")
boon:RegisterEvent("CHAT_MSG_SYSTEM")
boon:SetScript("OnEvent", function()
	if event == "PLAYER_LOGIN" then
		LoadAddOn("Blizzard_BattlefieldMinimap")

		if not BattlefieldMinimapOptions.chronoboon then
			BattlefieldMinimapOptions.chronoboon = {}
		end

		BoonBuffs = BattlefieldMinimapOptions.chronoboon

		local Original_SetBagItem = GameTooltip.SetBagItem
		function GameTooltip.SetBagItem(self, container, slot)
			local hasCooldown, repairCost = Original_SetBagItem(self, container, slot)
			local itemLink = GetContainerItemLink(container, slot)
			if itemLink then
				local _, _, itemID = strfind(itemLink, "item:(%d+)")
				itemID = tonumber(itemID)
				if itemID == 83001 then -- Supercharged Chronoboon Displacer
					GameTooltip:AddLine("\n")
					GameTooltip:AddLine(CHRONOBOON_LINE_1)
					for i = 1, getn(BoonBuffs) do
						GameTooltip:AddLine(BoonBuffs[i], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
					end
					GameTooltip:AddLine(CHRONOBOON_LINE_2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
					GameTooltip:Show()
				end
			end
			return hasCooldown, repairCost
		end

	elseif event == "CHAT_MSG_SYSTEM" then
		local _, _, wBuff = strfind(arg1, "^Suspended (.+)%.")
		if wBuff then
			tinsert(BoonBuffs, wBuff)
		elseif strfind(arg1, "^Restored (.+)%.") then
			for i = getn(BoonBuffs), 1, -1 do
				tremove(BoonBuffs, i)
			end
		end
	end
end)
