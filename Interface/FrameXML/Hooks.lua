local strfind = string.find
local gsub = string.gsub

local tooltip = CreateFrame("Frame", nil, GameTooltip)
tooltip:SetScript("OnShow", function()
	if tooltip.hint then
		GameTooltip:AddLine(HELP_SHIFT_CLICK_HINT, 0.25, 0.78, 0.92)
		GameTooltip:Show()
		tooltip.hint = false
		return
	end

	if TOOLTIP_GUILD_NAMES ~= "1" then return end

	local unit = tooltip.unit
	if UnitExists("mouseover") then unit = "mouseover" end

	if not (unit and UnitIsPlayer(unit)) then return end

	local guildName = GetGuildInfo(unit)
	if not guildName then return end

	if not strfind(GameTooltipTextLeft1:GetText() or "", UnitName(unit)) then return end

	GameTooltip:AddLine("<"..guildName..">", 1, 1, 1)
	GameTooltip:Show()
end)

tooltip:SetScript("OnHide", function()
	tooltip.unit = nil
	tooltip.hint = false
end)

local _SetBagItem = GameTooltip.SetBagItem
function GameTooltip.SetBagItem(self, container, slot)
	if TradeFrame:IsShown()
		or (AuctionFrame and AuctionFrame:IsShown() and AuctionFrameAuctions and AuctionFrameAuctions:IsShown())
		or (AuctionFrame and AuctionFrame:IsShown() and AuctionFrameBrowse and AuctionFrameBrowse:IsShown())
		or (MailFrame and MailFrame:IsShown() and SendMailFrame:IsShown())
	then
		tooltip.hint = true
	end
	return _SetBagItem(self, container, slot)
end

local _SetUnit = GameTooltip.SetUnit
function GameTooltip.SetUnit(self, unit)
	tooltip.unit = unit
	return _SetUnit(self, unit)
end

-- HACK FIX for set bonuses not showing if transmogrified
local HooksScanTooltip = CreateFrame("GameTooltip", "HooksScanTooltip", nil, "GameTooltipTemplate")
HooksScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
local sameSetCache = {}
local function SameSet(id, set)
	local _, _, key = strfind(id, "item:(%d+)")
	key = key.."_"..set
	if sameSetCache[key] ~= nil then return sameSetCache[key] end
	local result = false
	HooksScanTooltip:ClearLines()
	HooksScanTooltip:SetHyperlink(id)
	for i = 1, HooksScanTooltip:NumLines() do
		local left = _G["HooksScanTooltipTextLeft" .. i]:GetText()
		if left and strfind(left, "^" .. set) then
			result = true
			break
		end
	end
	sameSetCache[key] = result
	return result
end

-- %((%d+)%) Set: (.+)
local setBonusGraySearch = gsub(ITEM_SET_BONUS_GRAY, "([%(%)])", "%%%1")
setBonusGraySearch = gsub(setBonusGraySearch, "%%s", "(.+)")
setBonusGraySearch = gsub(setBonusGraySearch, "%%d", "(%%d+)")

-- (.+) %((%d+)/(%d+)%)
local setNameSearch = gsub(ITEM_SET_NAME, "([%(%)])", "%%%1")
setNameSearch = gsub(setNameSearch, "%%s", "(.+)")
setNameSearch = gsub(setNameSearch, "%%d", "(%%d+)")

local function FixSetInspect(tooltip, unit)
	local tooltipName = tooltip:GetName()
	local numLines = tooltip:NumLines()
	local setName, numSetItems, originalLine, originalText
	local setItemLine, setItem, link, id, name, bonus, bonusText
	local itemsEquipped = 0
	local index = 1
	for i = 1, numLines do
		originalLine = _G[tooltipName .. "TextLeft" .. i]
		originalText = originalLine:GetText()
		if originalText then
			_, _, setName, _, numSetItems = strfind(originalText, setNameSearch)
			if setName then
				numSetItems = tonumber(numSetItems)
				index = 1
				repeat
					setItemLine = _G[tooltipName .. "TextLeft" .. (i + index)]
					setItem = trim(setItemLine:GetText() or "")
					for slot = 1, 18 do
						link = GetInventoryItemLink(unit, slot)
						_, _, id, name = strfind(link or "", "(item:.+)|h%[(.+)%]")
						if name and name == setItem and SameSet(id, setName) then
							itemsEquipped = itemsEquipped + 1
							setItemLine:SetTextColor(1, 1, 0.6)
						end
					end
					index = index + 1
				until index > numSetItems
				originalLine:SetText(format(ITEM_SET_NAME, setName, itemsEquipped, numSetItems))
				break
			end
		end
	end
	for i = 1, numLines do
		originalLine = _G[tooltipName .. "TextLeft" .. i]
		originalText = originalLine:GetText()
		if originalText then
			_, _, bonus, bonusText = strfind(originalText, setBonusGraySearch)
			if bonus and tonumber(bonus) <= itemsEquipped then
				originalLine:SetText(format(ITEM_SET_BONUS, bonusText))
				originalLine:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
			end
		end
	end
	tooltip:Show()
end

local tooltips = { GameTooltip, ShoppingTooltip1, ShoppingTooltip2 }

for _, object in pairs(tooltips) do
	local SetInventoryItem_Original = object.SetInventoryItem
	local SetBagItem_Original = object.SetBagItem

	function object.SetInventoryItem(self, unit, slot, nameOnly)
		local hasItem, hasCooldown, repairCost = SetInventoryItem_Original(self, unit, slot, nameOnly)
		if hasItem then FixSetInspect(self, unit) end
		return hasItem, hasCooldown, repairCost
	end

	function object.SetBagItem(self, container, slot)
		local hasCooldown, repairCost = SetBagItem_Original(self, container, slot)
		if repairCost then FixSetInspect(self, "player") end
		return hasCooldown, repairCost
	end
end

