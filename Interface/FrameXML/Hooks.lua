local strfind = string.find
local gsub = string.gsub
local strsub = string.sub

ChatFrame_OnEvent_Original = ChatFrame_OnEvent

function ChatFrame_OnEvent(event)
	if event == "CHAT_MSG_HARDCORE" then
		-- Remove GM's coloured text from the message
		local output, c = gsub(arg1, "^|c", "")
		if c then
			_, _, output = strfind(arg1, "(ª.*ª)")
		end
		if not output then
			output = arg1
		end

		-- Some checks to see if the message is the spoofed AddonMessage
		local _, c = gsub(output, "ª", "")
		if strsub(output, 1, 2) == "ª" and strsub(output, -2) == "ª" and c == 3 then
			--[[
			-- This is an example of how you could convert this CHAT_MSG into a similar format to a regular CHAT_MSG_ADDON event.
			-- I recommend using copying this entire function as is and expanding this commented section for your addons.

			local tbl = {}
			for v in string.gfind(output, "[^ª]+") do
				tinsert(tbl, v)
			end

			local prefix = tbl[1]
			local text = tbl[2]
			local sender = arg2
			local msgType = "HARDCORE"

			]]           --
			return false --Hides the "AddonMessage" from the Hardcore chat client side.
		end
	end
	ChatFrame_OnEvent_Original(event)
end

-- Extends SendAddonMessage() to support a "HARDCORE" type.
SendAddonMessage_Original = SendAddonMessage

function SendAddonMessage(prefix, text, msgType, target)
	if msgType == "HARDCORE" then
		SendChatMessage("ª" .. prefix .. "ª" .. text .. "ª", "HARDCORE")
		return false
	else
		SendAddonMessage_Original(prefix, text, msgType)
	end
end

-- HACK FIX for set bonuses not showing if transmogrified
local HooksScanTooltip = CreateFrame("GameTooltip", "HooksScanTooltip", nil, "GameTooltipTemplate")
HooksScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local function SameSet(id, set)
	HooksScanTooltip:ClearLines()
	HooksScanTooltip:SetHyperlink(id)
	for i = 1, HooksScanTooltip:NumLines() do
		local left = _G["HooksScanTooltipTextLeft" .. i]:GetText()
		if left and strfind(left, "^" .. set) then
			return true
		end
	end
	return false
end

local setColon = gsub(ITEM_SET_BONUS, "%%s", "")

local function FixSetInspect(tooltip, unit)
	local tooltipName = tooltip:GetName()
	local numLines = tooltip:NumLines()
	local setName, numSetItems
	local itemsEquipped = 0
	for i = 1, numLines do
		local originalLine = _G[tooltipName .. "TextLeft" .. i]
		local originalText = originalLine:GetText()
		if originalText then
			_, _, setName, numSetItems = strfind(originalText, "(.+) %(%d/(%d)%)")
			if setName then
				numSetItems = tonumber(numSetItems)
				local index = 1
				repeat
					local setItemLine = _G[tooltipName .. "TextLeft" .. (i + index)]
					local setItem = trim(setItemLine:GetText() or "")
					for slot = 1, 18 do
						local link = GetInventoryItemLink(unit, slot)
						local _, _, id, name = strfind(link or "", "(item:%d+).+%[(.+)%]")
						if name and name == setItem and SameSet(id, setName) then
							itemsEquipped = itemsEquipped + 1
							setItemLine:SetTextColor(1, 1, 0.6)
						end
					end
					index = index + 1
				until index > numSetItems
				originalLine:SetText(format(setName .. " (%d/" .. numSetItems .. ")", itemsEquipped))
				break
			end
		end
	end
	for i = 1, numLines do
		local originalLine = _G[tooltipName .. "TextLeft" .. i]
		local originalText = originalLine:GetText()
		if originalText then
			local _, _, bonus = strfind(originalText, "%((%d+)%) " .. setColon)
			if bonus and tonumber(bonus) <= itemsEquipped then
				originalLine:SetText(gsub(originalText, "%(%d+%) " .. setColon, setColon))
				originalLine:SetTextColor(0, 1, 0)
			end
		end
	end
	tooltip:Show()
end

local tooltips = { GameTooltip, ShoppingTooltip1, ShoppingTooltip2 }

for _, object in pairs(tooltips) do
	local SetInventoryItem_Original = object.SetInventoryItem
	local SetBagItem_Original = object.SetBagItem

	function object.SetInventoryItem(self, unit, slot)
		local hasItem, hasCooldown, repairCost = SetInventoryItem_Original(self, unit, slot)
		if GetInventoryItemLink(unit, slot) then
			FixSetInspect(self, unit)
		end
		return hasItem, hasCooldown, repairCost
	end

	function object.SetBagItem(self, container, slot)
		local hasCooldown, repairCost = SetBagItem_Original(self, container, slot)
		if GetContainerItemLink(container, slot) then
			FixSetInspect(self, "player")
		end
		return hasCooldown, repairCost
	end
end
