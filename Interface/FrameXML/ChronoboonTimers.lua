local boon = CreateFrame("Frame")
boon:RegisterEvent("PLAYER_LOGIN")
boon:RegisterEvent("CHAT_MSG_SYSTEM")
boon:SetScript("OnEvent", function()
	if event == "PLAYER_LOGIN" then
		local Original_SetBagItem = GameTooltip.SetBagItem
		function GameTooltip.SetBagItem(self, container, slot)
			local hasCooldown, repairCost = Original_SetBagItem(self, container, slot)
			local itemLink = GetContainerItemLink(container, slot)
			if itemLink and ChronoboonBuffs then
				local _, _, itemID = strfind(itemLink, "item:(%d+)")
				if itemID == "83001" then -- Supercharged Chronoboon Displacer
					GameTooltip:AddLine("\n")
					GameTooltip:AddLine(CHRONOBOON_LINE_1)
					for i = 1, getn(ChronoboonBuffs) do
						GameTooltip:AddLine(ChronoboonBuffs[i], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
					end
					GameTooltip:AddLine(CHRONOBOON_LINE_2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
					GameTooltip:Show()
				end
			end
			return hasCooldown, repairCost
		end

	elseif event == "CHAT_MSG_SYSTEM" then
		if not ChronoboonBuffs then return end
		local _, _, wBuff = strfind(arg1, "^Suspended (.+)%.")
		if wBuff then
			tinsert(ChronoboonBuffs, wBuff)
		elseif strfind(arg1, "^Restored (.+)%.") then
			for i = getn(ChronoboonBuffs), 1, -1 do
				tremove(ChronoboonBuffs, i)
			end
		end
	end
end)
