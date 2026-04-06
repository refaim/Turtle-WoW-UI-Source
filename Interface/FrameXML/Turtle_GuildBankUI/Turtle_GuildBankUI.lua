------------------------------------------------------------
------------------------------------------- Constants
------------------------------------------------------------
local ACTION_WITHDRAW = 0
local ACTION_DEPOSIT = 1
local ACTION_UNLOCK_GUILD_BANK = 2
local ACTION_UNLOCK_GUILD_TAB_GUILD_MONEY = 6
local ACTION_UNLOCK_GUILD_TAB_PERSONAL_MONEY = 3
local ACTION_WITHDRAW_MONEY = 4
local ACTION_DEPOSIT_MONEY = 5
local ACTION_DESTROY = 7
local MAX_TABS = 5
local MAX_SLOTS = 98
local MAX_WITHDRAWALS = 5

local COLOR_GOLD = "|cffd7b845"
local COLOR_SILVER = "|cff979697"
local COLOR_COPPER = "|cffa05a39"
local STAMP_FORMAT = "%A %d %b %Y %H:%M"
local TRIGGER = "GUILD_BANK_TRIGGER"

GuildBank = {}

GuildBank.tabIcons = {
	"Ability_Creature_Cursed_01",
	"Ability_Creature_Cursed_05",
	"INV_Bijou_Green",
	"INV_Enchant_ShardNexusLarge",
	"INV_Misc_Ammo_Gunpowder_01",
	"INV_Misc_Bag_EnchantedMageweave",
	"INV_Misc_Bag_EnchantedRunecloth",
	"INV_Misc_Bag_SatchelofCenarius",
	"INV_Misc_Coin_08",
	"INV_Misc_Coin_15",
	"INV_Misc_WartornScrap_Chain",
	"INV_Misc_WartornScrap_Cloth",
	"INV_Misc_WartornScrap_Leather",
	"INV_Misc_WartornScrap_Plate",
	"INV_Qiraj_JewelBlessed",
	"INV_Qiraj_JewelEncased",
	"INV_QirajIdol_Azure",
	"INV_QirajIdol_Night",
	"INV_Scarab_Crystal",
	"Spell_ChargeNegative",
	"Spell_ChargePositive",
	"INV_Ammo_Arrow_02",
	"INV_Ammo_Bullet_03",
	"INV_Ammo_Snowball",
	"INV_Crate_03",
	"INV_Drink_04",
	"INV_Drink_16",
	"INV_Enchant_DustIllusion",
	"INV_Enchant_EssenceEternalLarge",
	"INV_Enchant_ShardBrilliantLarge",
	"INV_Enchant_ShardRadientSmall",
	"INV_Fabric_FelRag",
	"INV_Fabric_MoonRag_01",
	"INV_Fabric_PurpleFire_01",
	"INV_Fabric_PurpleFire_02",
	"INV_Gizmo_08",
	"INV_Ingot_07",
	"INV_Misc_Bag_02",
	"INV_Misc_Bag_06",
	"INV_Misc_Bag_07_Black",
	"INV_Misc_Bag_07_Blue",
	"INV_Misc_Bag_08",
	"INV_Misc_Bag_09_Green",
	"INV_Misc_Bag_09_Red",
	"INV_Misc_Bag_10_Blue",
	"INV_Misc_Bag_10_Green",
	"INV_Misc_Bag_11",
	"INV_Misc_Bag_12",
	"INV_Misc_Bag_13",
	"INV_Misc_Bag_14",
	"INV_Misc_Bag_16",
	"INV_Misc_Bag_18",
	"INV_Misc_Bag_21",
	"INV_Misc_Bag_22",
	"INV_Misc_Bandage_12",
	"INV_Misc_Bomb_02",
	"INV_Misc_Bomb_04",
	"INV_Misc_Book_01",
	"INV_Misc_Coin_01",
	"INV_Misc_Coin_03",
	"INV_Misc_Coin_05",
	"INV_Misc_Dust_01",
	"INV_Misc_Fish_11",
	"INV_Misc_Food_15",
	"INV_Misc_Gem_01",
	"INV_Misc_Gem_Pearl_04",
	"INV_Misc_Gem_Topaz_01",
	"INV_Misc_Herb_09",
	"INV_Misc_Herb_16",
	"INV_Misc_Herb_17",
	"INV_Misc_Herb_19",
	"INV_Misc_Herb_BlackLotus",
	"INV_Misc_Herb_DreamFoil",
	"INV_Misc_Herb_IceCap",
	"INV_Misc_Herb_MountainSilverSage",
	"INV_Misc_Herb_PlagueBloom",
	"INV_Misc_Idol_02",
	"INV_Misc_LeatherScrap_02",
	"INV_Misc_StoneTablet_05",
	"INV_Ore_Mithril_02",
	"INV_Ore_Thorium_02",
	"INV_Potion_21",
	"INV_Potion_22",
	"INV_Potion_23",
	"INV_Potion_24",
	"INV_Potion_25",
	"INV_Potion_26",
	"INV_Potion_30",
	"INV_Potion_32",
	"INV_Potion_40",
	"INV_Potion_41",
	"INV_Potion_47",
	"INV_Potion_48",
	"INV_Potion_54",
	"INV_Potion_55",
	"INV_Potion_61",
	"INV_Potion_62",
	"INV_Potion_69",
	"INV_Potion_75",
	"INV_Potion_76",
	"INV_Potion_82",
	"INV_Potion_83",
	"INV_Potion_89",
	"INV_Potion_90",
	"INV_Potion_96",
	"INV_Potion_97",
	"INV_Scroll_01",
	"INV_Scroll_02",
	"INV_Stone_14",
	"INV_Stone_15",
	"INV_Stone_GrindingStone_05",
	"INV_Stone_SharpeningStone_01",
	"INV_Stone_SharpeningStone_03",
	"INV_Stone_SharpeningStone_05",
	"Trade_Engineering",
	"Trade_Engraving",
	"Trade_Fishing",
	"Trade_Herbalism",
	"Trade_LeatherWorking",
	"Trade_Mining",
	"Trade_Tailoring",
	"Trade_Alchemy",
	"Trade_BlackSmithing",
	"Trade_BrewPoison",
}

GuildBank.debug = false
GuildBank.ready = false

GuildBank.prefix = "TW_GUILDBANK"

GuildBank.money = 0
GuildBank.currentTab = 1
GuildBank.BottomTab = 1

GuildBank.itemFrames = {}
GuildBank.guildInfo = {}
GuildBank.log = {}
GuildBank.moneyLog = {}
GuildBank.guildRanks = {}
GuildBank.cursorItem = {}
GuildBank.tabs = {}
GuildBank.tabs.info = {}
GuildBank.items = {}
GuildBank.withdrawalsLeft = {}

for i = 1, MAX_TABS do
	GuildBank.items[i] = {}
	GuildBank.withdrawalsLeft[i] = ""
end

GuildBank.oldTabSettings = {}
GuildBank.newTabSettings = {}

GuildBank.cost = {
	feature = 0,
	tab = 0,
	tabCost = 0,
}

------------------------------------------------------------
------------------------------------------- Utils
------------------------------------------------------------

local function gdebug(str)
	if not GuildBank.debug then return end
	DEFAULT_CHAT_FRAME:AddMessage("["..format("%.3f", GetTime()).."] " .. tostring(str))
end

function GuildBank:Send(data)
	if self.debug then gdebug("|cff11ff00->" .. data) end
	SendAddonMessage(self.prefix, data, "GUILD")
end

function GuildBank:CacheItem(linkOrID)
	if not linkOrID or linkOrID == 0 then return end

	if tonumber(linkOrID) then
		if GetItemInfo(linkOrID) then
			-- item ok, break
			return true
		else
			local item = "item:" .. linkOrID .. ":0:0:0"
			local _, _, itemLink = strfind(item, "(item:%d+:%d+:%d+:%d+)")
			linkOrID = itemLink
		end
	else
		if strfind(linkOrID, "|", 1, true) then
			local _, _, itemLink = strfind(linkOrID, "(item:%d+:%d+:%d+:%d+)")
			linkOrID = itemLink
			if GetItemInfo(self:IDFromLink(linkOrID)) then
				-- item ok, break
				return true
			end
		end
	end

	GameTooltip:SetHyperlink(linkOrID)
end

function GuildBank:IDFromLink(link)
	local _, _, itemID = strfind(link or "", "item:(%d+)")
	return tonumber(itemID)
end

function GuildBank:GetFreeSlot()
	-- if not GuildBankFrame:IsShown() then return 0 end
	-- local index = 1
	-- local col = 1
	-- local row = 1
	-- while col < 15 do
	-- 	if not self.itemFrames[index].occupied then return index end
	-- 	index = index + 14
	-- 	row = row + 1
	-- 	if row > 7 then
	-- 		row = 1
	-- 		col = col + 1
	-- 		index = col
	-- 	end
	-- end
	return 0
end

------------------------------------------------------------
------------------------------------------- OnLoad
------------------------------------------------------------

function GuildBankFrame_OnLoad()
	GuildBankFrame:SetUserPlaced(true)
	GuildBankFrame:RegisterEvent("CHAT_MSG_ADDON")
	GuildBankFrame:RegisterEvent("GOSSIP_SHOW")
	GuildBankFrame:RegisterEvent("GOSSIP_CLOSED")
	GuildBankFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
	GuildBankFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
	GuildBankFrame:RegisterEvent("PLAYER_LOGIN")
	GuildBank:HookFunctions()
	GuildBank:CreateFrames()
	PanelTemplates_SetNumTabs(GuildBankFrame, 3)
	PanelTemplates_SetTab(GuildBankFrame, 1)
end

------------------------------------------------------------
------------------------------------------- Cursor
------------------------------------------------------------

function GuildBank:ResetCursorItem()
	self.cursorItem.tab = nil
	self.cursorItem.slot = nil
	self.cursorItem.from = nil
	self.cursorItem.count = 0
end

function GuildBank:CursorHasItem()
	return self:CursorHasBagItem() or self:CursorHasBankItem() or self:CursorHasSplitItem()
end

function GuildBank:CursorHasBagItem()
	return self.cursorItem.from == "bag" and self.cursorItem.tab ~= nil and self.cursorItem.slot ~= nil
end

function GuildBank:CursorHasBankItem()
	return self.cursorItem.from == "bank" and self.cursorItem.tab ~= nil and self.cursorItem.slot ~= nil
end

function GuildBank:CursorHasSplitItem()
	return self.cursorItem.from == "split" and self.cursorItem.tab ~= nil and self.cursorItem.slot ~= nil and self.cursorItem.count > 0
end

-- Cursor Frame
GuildBank.cursorFrame = CreateFrame("Frame")
GuildBank.cursorFrame:Hide()

GuildBank.cursorFrame:SetScript("OnShow", function()
	GuildBankFrameCursorItemFrame:Show()
	GuildBankFrameDestroyItemCatcherFrame:Show()
	if GuildBank.cursorItem.slot and GuildBank.cursorItem.slot ~= 0 then
		SetDesaturation(_G["GuildBankFrameItem" .. GuildBank.cursorItem.slot .. "IconTexture"], 1)
	end
end)

GuildBank.cursorFrame:SetScript("OnHide", function()
	GuildBankFrameCursorItemFrame:Hide()
	GuildBankFrameDestroyItemCatcherFrame:Hide()
	if GuildBank.cursorItem.slot and GuildBank.cursorItem.slot ~= 0 then
		SetDesaturation(_G["GuildBankFrameItem" .. GuildBank.cursorItem.slot .. "IconTexture"], 0)
	end
	GuildBank:ResetCursorItem()
end)

GuildBank.cursorFrame:SetScript("OnUpdate", function()
	local cursorX, cursorY = GetCursorPosition()
	cursorX = cursorX / UIParent:GetScale()
	cursorY = cursorY / UIParent:GetScale()
	GuildBankFrameCursorItemFrameTexture:ClearAllPoints()
	GuildBankFrameCursorItemFrameTexture:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", cursorX - 5, cursorY - 32)
end)


------------------------------------------------------------
------------------------------------------- Tooltip
------------------------------------------------------------

GuildBank.TooltipFrame = CreateFrame("Frame", "GuildBankTooltipFrame", GameTooltip)

local original_SetBagItem = GameTooltip.SetBagItem

function GameTooltip.SetBagItem(self, container, slot)
	local _, count = GetContainerItemInfo(container, slot)
	if count and count < 0 then count = 1 end
	GameTooltip.itemCount = count
	GameTooltip.itemLink = GetContainerItemLink(container, slot)
	return original_SetBagItem(self, container, slot)
end

GuildBank.TooltipFrame:SetScript("OnShow", function()
	if not GameTooltip.itemLink then return end
	local count = 0
	for i = 1, MAX_TABS do
		for _, item in pairs(GuildBank.items[i]) do
			local id = GuildBank:IDFromLink(GameTooltip.itemLink)
			if id and id == item.itemID then
				count = count + item.count
			end
		end
	end
	if count > 0 then
		GameTooltip:AddLine(count .. " " .. GUILD_BANK_QUANTITY, 1, 1, 1, 1)
		GameTooltip:Show()
	end
end)

GuildBank.TooltipFrame:SetScript("OnHide", function()
	GameTooltip.itemLink = nil
end)

------------------------------------------------------------
------------------------------------------- Events
------------------------------------------------------------

function GuildBankFrame_OnEvent()
	if event == "PLAYER_LOGIN" then
		if IsInGuild() then
			GuildRoster()
		end
		return
	end

	if (event == "PLAYER_GUILD_UPDATE" and arg1 == "player") or (event == "GUILD_ROSTER_UPDATE" and GuildBankFrame:IsShown()) then
		GuildBank.playerGuildUpdateTimer:Show()
		return
	end

	if event == "GOSSIP_SHOW" then
		if GetGossipText() == TRIGGER and UnitExists("npc") then
			UIPanelWindows.GossipFrame.pushable = 99
			CloseWindows(nil, GossipFrame)
			GuildBank.gossipOpen = true
			GossipFrame:SetAlpha(0)
			GossipFrame:EnableMouse(nil)
			if not GuildBank.ready then
				GuildBank:GetBankInfo()
			else
				gdebug("guild bank live, can show")
				GuildBankFrameTab_OnClick(1, true)
				GuildBankFrameBottomTab_OnClick(1)
				GuildBankFrame:Show()
			end
		end
		return
	end

	if event == "GOSSIP_CLOSED" then
		if GuildBank.gossipOpen then
			GuildBank.gossipOpen = false
			GossipFrame:SetAlpha(1)
			GossipFrame:EnableMouse(1)
			UIPanelWindows.GossipFrame.pushable = 0
			GuildBankFrameCloseButton_OnClick()
			StaticPopup_Hide("GUILDBANK_UNLOCK")
			StaticPopup_Hide("GUILDBANK_UNLOCK_TAB")
			StaticPopup_Hide("GUILDBANK_WITHDRAW_MONEY")
			StaticPopup_Hide("GUILDBANK_DEPOSIT_MONEY")
		end
		return
	end

	if event == "CHAT_MSG_ADDON" and arg1 == GuildBank.prefix then
		local message = arg2

		if strfind(message, "^Access:Error:HC") then
			return
		end

		-- bank management messages
		if strfind(message, "^Player:Unguilded") then
			GuildBank:Reset()
			return
		end

		if strfind(message, "^UnlockGuildBank:Cost:") then
			if GuildBank.gossipOpen then
				local _, _, cost = strfind(message, "UnlockGuildBank:Cost:(%d+)")
				StaticPopup_Show("GUILDBANK_UNLOCK", cost)
			end
			return
		end

		if strfind(message, "^Unlock:Tab:%d+:Cost:%d+") then
			local _, _, tab, cost = strfind(message, "^Unlock:Tab:(%d+):Cost:(%d+)")
			if tab and cost then
				GuildBank.cost.tab = tab
				GuildBank.cost.tabCost = cost
				StaticPopup_Show("GUILDBANK_UNLOCK_TAB", GuildBank.cost.tab, GuildBank.cost.tabCost)
				return
			end
			return
		end

		-- public messages

		-- non gm members need bank info after unlock
		if strfind(message, "^GUnlock:GuildBank:Ok") then
			if not GuildBank:IsGm() then
				GuildBank:GetBankInfo()
			end
			return
		end

		if strfind(message, "^GDeposit:") then
			local ex = explode(message, ":")

			local item = {
				tab = tonumber(ex[2]),
				slot = tonumber(ex[3]),
				guid = tonumber(ex[4]),
				itemID = tonumber(ex[5]),
				count = tonumber(ex[6]),
				nameIfSuffix = ex[7],
				randomProperty = ex[8],
				enchant = ex[9],
			}

			GuildBank:CacheItem(item.itemID)

			GuildBank.items[item.tab][item.slot] = item

			GuildBank:UpdateSlot(item.tab, item.slot, GuildBank.items[item.tab][item.slot])

			return
		end

		if strfind(message, "^GMoveItem:") or
			strfind(message, "^GSwapItem:") or
			strfind(message, "^GSplitItem:") then

			local ex = explode(message, ":")

			if ex[3] and tonumber(ex[3]) and ex[13] and tonumber(ex[13]) then

				local fromTab = tonumber(ex[3])
				local fromSlot = tonumber(ex[4])

				GuildBank.items[fromTab][fromSlot] = {
					tab = fromTab,
					slot = fromSlot,
					guid = tonumber(ex[5]),
					itemID = tonumber(ex[6]),
					count = tonumber(ex[7]),
					nameIfSuffix = ex[8],
					randomProperty = ex[9],
					enchant = ex[10],
				}

				GuildBank:CacheItem(GuildBank.items[fromTab][fromSlot].itemID)

				GuildBank:UpdateSlot(fromTab, fromSlot, GuildBank.items[fromTab][fromSlot])

				local toTab = tonumber(ex[12])
				local toSlot = tonumber(ex[13])

				GuildBank.items[toTab][toSlot] = {
					tab = toTab,
					slot = toSlot,
					guid = tonumber(ex[14]),
					itemID = tonumber(ex[15]),
					count = tonumber(ex[16]),
					nameIfSuffix = ex[17],
					randomProperty = ex[18],
					enchant = ex[19],
				}

				GuildBank:CacheItem(GuildBank.items[toTab][toSlot].itemID)

				GuildBank:UpdateSlot(toTab, toSlot, GuildBank.items[toTab][toSlot])

			end

			return
		end

		if strfind(message, "^GWithdraw:") then
			local ex = explode(message, ":")

			if ex[2] and tonumber(ex[2]) and ex[3] and tonumber(ex[3]) then

				local tab = tonumber(ex[2])
				local slot = tonumber(ex[3])

				GuildBank.items[tab][slot] = {
					tab = tab,
					slot = slot,
					guid = 0,
					itemID = 0,
					count = 0,
					nameIfSuffix = "0",
					randomProperty = 0,
					enchant = 0,
				}

				GuildBank:CacheItem(GuildBank.items[tab][slot].itemID)

				GuildBank:UpdateSlot(tab, slot, GuildBank.items[tab][slot])

				GuildBank:ResetAction()

			end
			return
		end

		if strfind(message, "^GPartialWithdraw:") then
			local ex = explode(message, ":")

			if ex[2] and tonumber(ex[2]) and ex[6] and tonumber(ex[6]) then

				local tab = tonumber(ex[2])
				local slot = tonumber(ex[3])

				GuildBank.items[tab][slot] = {
					tab = tab,
					slot = slot,
					guid = tonumber(ex[4]),
					itemID = tonumber(ex[5]),
					count = tonumber(ex[6]),
					nameIfSuffix = "0",
					randomProperty = 0,
					enchant = 0
				}

				GuildBank:CacheItem(GuildBank.items[tab][slot].itemID)

				GuildBank:UpdateSlot(tab, slot, GuildBank.items[tab][slot])

			end

			return
		end

		if strfind(message, "^GDestroy:") then
			local ex = explode(message, ":")

			if ex[2] and tonumber(ex[2]) and ex[3] and tonumber(ex[3]) then

				local tab = tonumber(ex[2])
				local slot = tonumber(ex[3])

				GuildBank.items[tab][slot] = {
					tab = tab,
					slot = slot,
					guid = 0,
					itemID = 0,
					count = 0,
					nameIfSuffix = "0",
					randomProperty = 0,
					enchant = 0
				}

				GuildBank:CacheItem(GuildBank.items[tab][slot].itemID)

				GuildBank:UpdateSlot(tab, slot, GuildBank.items[tab][slot])

			end
			return
		end

		if strfind(message, "^GPartialDestroy:") then
			local ex = explode(message, ":")

			if ex[2] and tonumber(ex[2]) and ex[6] and tonumber(ex[6]) then

				local tab = tonumber(ex[2])
				local slot = tonumber(ex[3])

				GuildBank.items[tab][slot] = {
					tab = tab,
					slot = slot,
					guid = tonumber(ex[4]),
					itemID = tonumber(ex[5]),
					count = tonumber(ex[6]),
					nameIfSuffix = "0",
					randomProperty = 0,
					enchant = 0,
				}

				GuildBank:CacheItem(GuildBank.items[tab][slot].itemID)

				GuildBank:UpdateSlot(tab, slot, GuildBank.items[tab][slot])

			end

			return
		end

		if strfind(message, "^GTabLog:") then
			local _, _, tab = strfind(message, "GTabLog:(%d):")
			tab = tonumber(tab)
			local logLine = gsub(message, "GTabLog:%d:", "")

			if not logLine then
				return
			end

			GuildBank:AppendLog(tab, logLine)

			if GuildBank.BottomTab == 2 then
				GuildBank:ShowLog(tab)
			end

			return
		end

		if strfind(message, "^GMoneyLog:") then
			local logLine = gsub(message, "GMoneyLog:%d+:", "")
			GuildBank:AppendMoneyLog(logLine)
			if GuildBank.BottomTab == 3 then
				GuildBank:ShowMoneyLog()
			end
			return
		end

		if strfind(message, "^GUpdateTab:") then
			local info = explode(message, ":")
			if tonumber(info[2]) and info[3] and info[4] then

				local tab = tonumber(info[2])

				if not GuildBank.tabs.info then GuildBank.tabs.info = {} end
				if not GuildBank.tabs.info[tab] then GuildBank.tabs.info[tab] = {} end

				GuildBank.tabs.info[tab].name = info[3]
				GuildBank.tabs.info[tab].icon = info[4]
				GuildBank.tabs.info[tab].withdrawals = tonumber(info[5])
				GuildBank.tabs.info[tab].minrank = tonumber(info[6])

				GuildBank:Update()

			end
			return
		end

		if strfind(message, "^GMoney:") then
			local _, _, amount = strfind(message, "GMoney:(%d+)")
			if tonumber(amount) then
				GuildBank.money = tonumber(amount)
				GuildBank:UpdateMoney()
			end
			return
		end

		-- GUnlock:Tab:2:Ok
		if strfind(message, "^GUnlock:Tab:%d+:Ok") then
			local _, _, numTabs = strfind(message, "GUnlock:Tab:(%d+):Ok")
			if tonumber(numTabs) then
				GuildBank.tabs.numTabs = tonumber(numTabs)
				GuildBank:UpdateTabs()
				if GuildBank:IsGm() then
					GuildBankFrameTab_OnClick(GuildBank.tabs.numTabs)
				end
			end
			return
		end

		-- private messages

		if strfind(message, "^BankInfo:") then
			-- BankInfo:NoGuildBank
			-- BankInfo:tabs:%d: .....
			-- BankInfo:money:%d+
			if gsub(message, "BankInfo:", "") == "NoGuildBank" and GuildBank.gossipOpen then
				if GuildBank:IsGm() then
					GuildBank:Send("UnlockGuildBank:Cost")
				else
					UIErrorsFrame:AddMessage(GUILD_BANK_NOT_UNLOCKED, 1, 0.1, 0.1, 1)
					CloseGossip()
				end
				return
			end

			if strfind(message, "^BankInfo:money:") then
				local _, _, amount = strfind(message, "^BankInfo:money:(%d+)")
				GuildBank.money = tonumber(amount or 0)
				GuildBank:UpdateMoney()
				return
			end

			local ex = explode(message, ":")

			if ex[2] and ex[3] and tonumber(ex[3]) then

				GuildBank.tabs = {
					numTabs = tonumber(ex[3]),
					info = {}
				}

				for i = 1, MAX_TABS do
					GuildBank.tabs.info[i] = {
						name = ex[3 + i],
						icon = ex[3 + 5 + i],
						withdrawals = tonumber(ex[3 + 5 + 5 + i]),
						minrank = tonumber(ex[3 + 5 + 5 + 5 + i]),
					}
					GuildBank.log[i] = {}
				end

				GuildBank:UpdateTabs()
				GuildBank.items = {}
				for i = 1, MAX_TABS do
					GuildBank.items[i] = {}
				end

				GuildBank:GetTabItems(1)
			end
			return
		end

		if strfind(message, "^TabItems:") then
			local _, _, tab, info = strfind(message, "^TabItems:(%d+):(.+)")
			tab = tonumber(tab)
			if tab and info then
				if info == "end" then
					if tab < MAX_TABS then
						GuildBank:GetTabItems(tab + 1)
					else
						gdebug("got all bank items")
						GuildBank:GetTabLog(1)
					end
				else
					local tabItems = explode(info, ";")
					for _, itemString in pairs(tabItems) do
						local item = explode(itemString, ":")
						GuildBank.items[tab][tonumber(item[2])] = {
							tab = tonumber(item[1]),
							slot = tonumber(item[2]),
							guid = tonumber(item[3]),
							itemID = tonumber(item[4]),
							count = tonumber(item[5]),
							nameIfSuffix = item[6],
							randomProperty = item[7],
							enchant = item[8]
						}
						GuildBank:CacheItem(GuildBank.items[tab][tonumber(item[2])].itemID)
					end
				end
			end
			return
		end

		if strfind(message, "^TabLog:") then
			local _, _, tab, info = strfind(message, "^TabLog:(%d+):(.+)")
			tab = tonumber(tab)
			if tab and info then
				if info == "end" then
					if tab < MAX_TABS then
						GuildBank:GetTabLog(tab + 1)
					else
						gdebug("got all bank tab logs")
						GuildBank:GetMoneyLog()
					end
				else
					local logLines = explode(info, "=")
					for _, line in pairs(logLines) do
						GuildBank:AppendLog(tab, line)
					end
				end
			end
			return
		end

		if strfind(message, "^MoneyLog:") then
			message = gsub(message, "MoneyLog:", "")
			if message == "end" then
				gdebug("|cFF33FF00 >>>>>>>>>> Got everything needed from the server")
				GuildBank.ready = true
				if GuildBank.gossipOpen then
					GuildBankFrameTab_OnClick(1, true)
					GuildBankFrameBottomTab_OnClick(1)
					GuildBankFrame:Show()
				end
			else
				local logLines = explode(message, "=")
				for _, line in pairs(logLines) do
					GuildBank:AppendMoneyLog(line)
				end
			end
			return
		end

		if strfind(message, "^TabWithdrawalsLeft:") then
			local _, _, tab, amount = strfind(message, "^TabWithdrawalsLeft:(%d+):(%w+)")
			if tab and amount then
				tab = tonumber(tab)
				GuildBank.withdrawalsLeft[tab] = amount
				if GuildBankFrame:IsVisible() then
					GuildBank:UpdateWithdrawalsLeft()
				end
			end
			return
		end
	end
end

function GuildBankFrame_OnShow()
	PlaySoundFile("Interface\\GuildBankFrame\\GuildBankOpen.wav")
end

function GuildBankFrame_OnHide()
	StaticPopup_Hide("GUILDBANK_UNLOCK")
	StaticPopup_Hide("GUILDBANK_UNLOCK_TAB")
	StaticPopup_Hide("GUILDBANK_WITHDRAW_MONEY")
	StaticPopup_Hide("GUILDBANK_DEPOSIT_MONEY")
	StaticPopup_Hide("GUILDBANK_DELETE_GOOD_ITEM")
	StaticPopup_Hide("GUILDBANK_DELETE_ITEM")
	GuildBank:ResetAction()
	GuildBank.gossipOpen = false
	PlaySoundFile("Interface\\GuildBankFrame\\GuildBankClose.wav")
end

function GuildBankFrameCloseButton_OnClick()
	HideUIPanel(GossipFrame)
	GossipFrame:SetAlpha(1)
	GuildBankFrame:Hide()
end

function GuildBank:PlayerGuildUpdate()
	self.playerGuildUpdateTimer:Hide()

	if not IsInGuild() then
		self:Reset()
		GuildBankFrame:Hide()
		return
	end

	local guildName = GetGuildInfo("player")
	if not guildName then return end

	if self.guildInfo.name then
		if self.guildInfo.name == guildName then
			self:Update("PlayerGuildUpdate")
		else
			self:Reset()
			self.startDelay:Show()
		end
	else
		self:UpdateGuildInfo()
		self.playerGuildUpdateTimer:Show()
	end
end

GuildBank.playerGuildUpdateTimer = CreateFrame("Frame")
GuildBank.playerGuildUpdateTimer:Hide()

GuildBank.playerGuildUpdateTimer:SetScript("OnShow", function()
	gdebug("|cff00ff00 playerGuildUpdateTimer show")
	this.startTime = GetTime()
end)

GuildBank.playerGuildUpdateTimer:SetScript("OnUpdate", function()
	local plus = 1
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then
		GuildBank:PlayerGuildUpdate()
		gdebug("|cffff0000 playerGuildUpdateTimer hide")
		GuildBank.playerGuildUpdateTimer:Hide()
		this.startTime = GetTime()
	end
end)

function GuildBank:GetBankInfo()
	GuildBank:Send("GetBankInfo:")
end

function GuildBank:GetTabItems(tab)
	GuildBank:Send("GetTabItems:" .. tab)
end

GuildBank.startDelay = CreateFrame("Frame")
GuildBank.startDelay:Hide()

GuildBank.startDelay:SetScript("OnShow", function()
	this.startTime = GetTime()
end)
GuildBank.startDelay:SetScript("OnHide", function()
end)

GuildBank.startDelay:SetScript("OnUpdate", function()
	local plus = 3
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then

		if IsInGuild() then
			gdebug("startDelay in guild")
			GuildBank:UpdateGuildInfo()

			if GuildBank.guildInfo.name then
				-- init ?
				gdebug("got guild name = " .. GuildBank.guildInfo.name .. ", can init")
				gdebug("got guildRankIndex = " .. GuildBank.guildInfo.rankIndex .. ", can init")
				GuildBank.startDelay:Hide()
				GuildBank.currentTab = 1
				GuildBank.BottomTab = 1
				GuildBank:ResetCursorItem()
				GuildRoster()
			else
				this.startTime = GetTime()
			end

		else
			gdebug("startDelay not in guild")
			gdebug("startDelay stopped")
			GuildBank.guildInfo = {}
			GuildBank.startDelay:Hide()
		end
	end
end)

function GuildBank_UnlockGuildBank_Accept()
	GuildBank:Send("UnlockGuildBank:Ok")
end

local function SplitStack(button, split)
	GuildBank.cursorItem.tab = button.tab
	GuildBank.cursorItem.slot = button:GetID()
	GuildBank.cursorItem.from = "split"
	GuildBank.cursorItem.count = split
	local texture = _G["GuildBankFrameItem" .. GuildBank.cursorItem.slot .. "IconTexture"]:GetTexture()
	GuildBankFrameCursorItemFrameTexture:SetTexture(texture)
	GuildBank.cursorFrame:Show()
end

function GuildBank:CreateFrames()
	local row = 0
	local col = 0
	local separator = 0
	local separators = 0

	for i = 1, MAX_SLOTS do
		if not self.itemFrames[i] then
			self.itemFrames[i] = CreateFrame("Button", "GuildBankFrameItem" .. i, GuildBankFrameSlots, "GuildBankFrameItemButtonTemplate")
		end

		if col - math.floor(col / 2) * 2 == 0 then
			separator = 12
			separators = separators + separator
		else
			separator = 11
			separators = separators + separator
		end

		self.itemFrames[i]:SetPoint("TOPLEFT", GuildBankFrameSlots, "TOPLEFT", col * 40 + separator + separators - 24, -10 - row * 44)
		self.itemFrames[i]:SetID(i)
		self.itemFrames[i].tab = 1
		self.itemFrames[i].slot = i
		self.itemFrames[i].occupied = false
		self.itemFrames[i].maxStack = 0
		self.itemFrames[i].guid = 0
		self.itemFrames[i].itemID = 0
		self.itemFrames[i].SplitStack = SplitStack
		self.itemFrames[i]:Show()

		col = col + 1

		if col == 14 then
			col = 0
			row = row + 1
			separators = 0
			separator = 0
		end
	end
end

function GuildBank:Reset()
	self:ResetAction()
	self.ready = false
	self.money = 0
	self.itemFrames = {}
	self.currentTab = 1
	self.guildInfo = {}
	self.log = {}
	self.moneyLog = {}
	self.guildRanks = {}
	self.tabs = {}
	self.withdrawalsLeft = {}
	self.items = {}

	for i = 1, MAX_TABS do
		self.withdrawalsLeft[i] = ""
		self.items[i] = {}
	end

	self.cost = {
		feature = 0,
		tab = 0,
		tabCost = 0,
	}
end

function GuildBankFrame_ShowDeleteDialog()
	GuildBank:ShowDeleteDialog(true)
end

function GuildBank:ShowDeleteDialog(skipButtonCheck)
	if arg1 == "RightButton" then
		self:ResetAction()
		return
	end
	if (arg1 == "LeftButton" or skipButtonCheck) and (self:CursorHasBankItem() or self:CursorHasSplitItem()) then

		local name, _, quality = GetItemInfo(self.items[self.cursorItem.tab][self.cursorItem.slot].itemID)

		if self.items[self.cursorItem.tab][self.cursorItem.slot].nameIfSuffix ~= "0" then
			name = self.items[self.cursorItem.tab][self.cursorItem.slot].nameIfSuffix
		end

		if name and quality then
			GuildBankFrameCursorItemFrame:Hide()
			GuildBankFrameDestroyItemCatcherFrame:Hide()

			name = ITEM_QUALITY_COLORS[quality].hex .. name .. FONT_COLOR_CODE_CLOSE

			local count = ""
			if self.cursorItem.count > 1 then
				count = " x " .. self.cursorItem.count
			end

			if quality >= 3 then
				StaticPopup_Show("GUILDBANK_DELETE_GOOD_ITEM", name .. count)
			else
				StaticPopup_Show("GUILDBANK_DELETE_ITEM", name .. count)
			end
			return
		end
	end
	self:ResetAction()
end

function GuildBank:Update(w)
	gdebug(" ------------------------------ |cff88ff88 GUILDBANK Update()")
	if w then gdebug(w) end
	self:UpdateTabs()
	self:UpdateTabTitle()
	self:UpdateMoney()
	self:GetTabWithdrawalsLeft()
	self:UpdateGuildInfo()
	self:UpdateSlotRights()
end

function GuildBank:UpdateGuildInfo()
	gdebug("UpdateGuildInfo trigger")

	if not IsInGuild() then
		self.guildInfo = { name = nil, rankName = nil, rankIndex = nil }
		return
	end

	gdebug("UpdateGuildInfo in guild")
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
	if guildName then
		self.guildInfo.name = guildName
		self.guildInfo.rankName = guildRankName
		self.guildInfo.rankIndex = guildRankIndex
		GuildBankFrameHeader:SetText(self.guildInfo.name .. " " .. GUILD_BANK_TITLE)
		gdebug("UpdateGuildInfo got guildName = [" .. self.guildInfo.name .. "]")
	else
		gdebug("UpdateGuildInfo player guilded, couldnt get info")
	end
end

function GuildBank:UpdateSlotRights()
	local locked = self:TabIsLocked(self.currentTab)
	for slot = 1, MAX_SLOTS do
		SetDesaturation(_G["GuildBankFrameItem" .. slot .. "IconTexture"], locked and 1 or 0)
	end
end

function GuildBank:IsGm()
	return self.guildInfo.rankIndex == 0
end

------------------------------------------------------------
------------------------------------------- Hooks
------------------------------------------------------------

function GuildBank:HookFunctions()
	local original_ContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick
	ContainerFrameItemButton_OnClick = function(button, ignoreModifiers)
		if GuildBank.BottomTab == 1 and GuildBankFrame:IsVisible() then
			-- bank
			if button == "LeftButton" then
				-- withdraw to specific bag slot
				if GuildBank:CursorHasBankItem() then
					local bag = this:GetParent():GetID()
					local slot = this:GetID()

					GuildBank:Send("WithdrawItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot ..
					":" .. bag .. ":" .. slot .. ":" .. GuildBank.cursorItem.count)

					GuildBank:ResetAction()
					return
				end

				-- withdraw partial from split from bank
				if GuildBank:CursorHasSplitItem() then
					local bag = this:GetParent():GetID()
					local slot = this:GetID()

					GuildBank:Send("WithdrawItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot ..
					":" .. bag .. ":" .. slot .. ":" .. GuildBank.cursorItem.count)

					GuildBank:ResetAction()
					return
				end
			end

			-- deposit into free guild bank slot
			if button == "RightButton" then
				local bag = this:GetParent():GetID()
				local slot = this:GetID()

				local texture, count, locked, quality, readable = GetContainerItemInfo(bag, slot)
				if count then
					if count < 0 then count = 1 end
					GuildBank:Send("DepositItem:" .. bag .. ":" .. slot .. ":" .. GuildBank.currentTab .. ":"..GuildBank:GetFreeSlot()..":" .. count)
				end

				GuildBank:ResetAction()
				return
			end
		end

		-- execute original onclick
		original_ContainerFrameItemButton_OnClick(button, ignoreModifiers)

		-- original executed
		if button == "LeftButton" then
			-- item picked up ?
			if CursorHasItem() then
				local texture, count, locked, quality, readable = GetContainerItemInfo(this:GetParent():GetID(), this:GetID())
				if count and count < 0 then count = 1 end
				GuildBank.cursorItem.tab = this:GetParent():GetID()
				GuildBank.cursorItem.slot = this:GetID()
				GuildBank.cursorItem.from = "bag"
				GuildBank.cursorItem.count = count
				return
			elseif not this.hasStackSplit == 1 then
				GuildBank:ResetAction()
			end
		end
	end

	local original_OpenStackSplitFrame = OpenStackSplitFrame
	OpenStackSplitFrame = function(maxStack, parent, anchor, anchorTo, minSplit)
		original_OpenStackSplitFrame(maxStack, parent, anchor, anchorTo, minSplit)
		if parent:GetParent() ~= GuildBankFrameSlots then
			-- we started splitting item in our bags
			GuildBank.cursorItem.tab = parent:GetParent():GetID()
			GuildBank.cursorItem.slot = parent:GetID()
			GuildBank.cursorItem.from = "bag"
			GuildBank.cursorItem.count = 0
		end
	end

	local original_StackSplitFrameOkay_Click = StackSplitFrameOkay_Click
	StackSplitFrameOkay_Click = function()
		if GuildBank.cursorItem.from == "bag" then
			-- splitting item in our bag is finished
			-- set how many to be deposited into guild bank
			GuildBank.cursorItem.count = StackSplitFrame.split
		end
		original_StackSplitFrameOkay_Click()
	end
end

------------------------------------------------------------
------------------------------------------- Slots
------------------------------------------------------------

function GuildBankSlot_OnClick(button)
	if GuildBank:TabIsLocked(GuildBank.currentTab) then return end

	local frame = _G["GuildBankFrameItem" .. this:GetID()]
	if not frame then return end

	if button == "LeftButton" then
		if IsShiftKeyDown() then
			if frame.occupied then
				if ChatFrameEditBox:IsVisible() then
					local name, linkString, quality = GetItemInfo(frame.linkString)
					local itemLink = ITEM_QUALITY_COLORS[quality].hex .. "|H" .. linkString .. "|h[" .. name .. "]|h|r"
					ChatFrameEditBox:Insert(itemLink)
				else
					OpenStackSplitFrame(frame.count, frame, "BOTTOMRIGHT", "TOPRIGHT")
				end
			end
			return
		end

		if CursorHasItem() then
			if GuildBank:CursorHasBagItem() then
				-- deposit to specific slot from player bag
				-- TODO: fix pickup from keyring, click on bank, cursor ddoesnt have item here!
				GuildBank:Send("DepositItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot
				.. ":" .. GuildBank.currentTab .. ":" .. this:GetID() .. ":" .. GuildBank.cursorItem.count)
				ClearCursor()
				GuildBank:ResetAction()
			else
				-- cursor has invalid item, from keyring for example
				ClearCursor()
			end

		elseif GuildBank:CursorHasBankItem() then
			-- move item
			if GuildBank.cursorItem.slot == frame.slot then
				-- same source dest
				GuildBank:ResetAction()
				return
			end
			GuildBank:Send("MoveItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":" .. frame.slot)
			GuildBank:ResetAction()

		elseif GuildBank:CursorHasSplitItem() then
			-- split item
			if GuildBank.cursorItem.slot == frame.slot then
				-- same source dest
				GuildBank:ResetAction()
				return
			end
			if _G["GuildBankFrameItem"..GuildBank.cursorItem.slot].count == GuildBank.cursorItem.count then
				GuildBank:Send("MoveItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":" .. frame.slot)
			else
				GuildBank:Send("SplitItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":" .. frame.slot .. ":" .. GuildBank.cursorItem.count)
			end
			GuildBank:ResetAction()

		elseif frame.occupied then
			-- pick up bank item
			local texture = _G[frame:GetName() .. "IconTexture"]:GetTexture()
			GuildBankFrameCursorItemFrameTexture:SetTexture(texture)

			GuildBank.cursorItem.tab = frame.tab
			GuildBank.cursorItem.slot = frame.slot
			GuildBank.cursorItem.from = "bank"
			GuildBank.cursorItem.count = frame.count

			-- show frame
			GuildBank.cursorFrame:Show()
		end
	elseif button == "RightButton" then
		if GuildBank:CursorHasItem() then
			GuildBank:ResetAction()
		elseif frame.occupied then
			-- auto withdraw from bank
			GuildBank:Send("WithdrawItem:" .. frame.tab .. ":" .. frame.slot .. ":0:0:" .. frame.count)
		end
	end
end

function GuildBankSlot_OnDragStart()
	if GuildBank:TabIsLocked(GuildBank.currentTab) then return end

	local frame = _G["GuildBankFrameItem" .. this:GetID()]
	if not frame then return end

	if not frame.occupied then return end

	-- pick up bank item
	local texture = _G[frame:GetName() .. "IconTexture"]:GetTexture()
	GuildBankFrameCursorItemFrameTexture:SetTexture(texture)

	GuildBank.cursorItem.tab = frame.tab
	GuildBank.cursorItem.slot = frame.slot
	GuildBank.cursorItem.from = "bank"
	GuildBank.cursorItem.count = frame.count

	-- show frame
	GuildBank.cursorFrame:Show()
end

function GuildBankSlot_OnReceiveDrag()
	if GuildBank:TabIsLocked(GuildBank.currentTab) then	return end

	local frame = _G["GuildBankFrameItem" .. this:GetID()]
	if not frame then return end

	if GuildBank:CursorHasBankItem() then
		if GuildBank.cursorItem.slot == frame.slot then
			-- same source dest
			GuildBank:ResetAction()
			return
		end

		GuildBank:Send("MoveItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":" .. frame.slot)
		GuildBank:ResetAction()
		return
	end

	if GuildBank:CursorHasBagItem() then
		local texture, count, locked, quality, readable = GetContainerItemInfo(GuildBank.cursorItem.tab, GuildBank.cursorItem.slot)
		if count and count < 0 then count = 1 end
		GuildBank:Send("DepositItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":" .. frame.tab .. ":" .. frame.slot .. ":" .. count)
		ClearCursor()
		GuildBank:ResetAction()
		return
	end
end

function GuildBankSlot_OnEnter()
	if not this.linkString then return end

	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -(this:GetWidth() / 4) + 10, -(this:GetHeight() / 4))
	GameTooltip:SetHyperlink(this.linkString)

	local count = 0

	for i = 1, MAX_TABS do
		for _, item in pairs(GuildBank.items[i]) do
			if this.itemID == item.itemID then
				if this.name == item.nameIfSuffix then
					count = count + item.count
				end
			end
		end
	end

	if count > 1 then
		GameTooltip:AddLine(count .. " " .. GUILD_BANK_QUANTITY, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end

function GuildBank:UpdateSlot(tab, slot, item, noAnimation)
	local frame = _G["GuildBankFrameItem" .. slot]

	if not frame then return end

	if self:CursorHasItem() and self.currentTab == tab then
		if self.cursorItem.tab == tab and self.cursorItem.slot == slot then
			self:ResetAction()
		end
	end

	if tab ~= self.currentTab then return end

	if not item or item.guid == 0 then
		frame.occupied = false
		frame.tab = tab
		frame.itemID = 0
		frame.guid = 0
		frame.name = "0"
		SetItemButtonTexture(frame, nil)
		_G[frame:GetName() .. "Count"]:Hide()
		frame.linkString = nil
		return
	end

	if item.guid == 0 then return end

	frame.occupied = true
	frame.tab = item.tab
	frame.itemID = item.itemID
	frame.count = item.count
	frame.guid = item.guid
	frame.name = item.nameIfSuffix

	local name, linkString, _, _, _, _, maxStack, _, texture = GetItemInfo(item.itemID)

	if not name then
		self:CacheItem(item.itemID)
		return
	end

	linkString = gsub(linkString, ":0:0:0", ":" .. item.enchant .. ":" .. item.randomProperty .. ":0")
	frame.linkString = linkString
	frame.maxStack = maxStack

	SetItemButtonTexture(frame, texture)
	SetDesaturation(_G["GuildBankFrameItem" .. slot .. "IconTexture"], self:TabIsLocked(tab) and 1 or 0)

	_G["GuildBankFrameItem" .. item.slot .. "Count"]:Hide()

	if item.count > 1 then
		_G["GuildBankFrameItem" .. item.slot .. "Count"]:SetText(item.count)
		_G["GuildBankFrameItem" .. item.slot .. "Count"]:Show()
	end

	if self.currentTab == frame.tab and not noAnimation then
		ComboPointShineFadeIn(_G["GuildBankFrameItem" .. frame.slot .. "Shine"])
	end
end

function GuildBank:UpdateTabTitle()

	if not self.tabs.info then return end

	local accessText = GREEN_FONT_COLOR_CODE .. "(" .. GUILD_BANK_FULL_ACCESS .. ")|r"

	if self:TabIsLocked(self.currentTab) then
		accessText = RED_FONT_COLOR_CODE .. "(" .. GUILD_BANK_LOCKED .. ")|r"
	end

	GuildBankFrameWithdrawalsTitle:Hide()
	GuildBankFrameWithdrawalsTitleBackground:Hide()
	GuildBankFrameWithdrawalsTitleBackgroundLeft:Hide()
	GuildBankFrameWithdrawalsTitleBackgroundRight:Hide()

	if self.BottomTab == 1 then
		GuildBankFrameWithdrawalsTitle:Show()
		GuildBankFrameWithdrawalsTitleBackground:Show()
		GuildBankFrameWithdrawalsTitleBackgroundLeft:Show()
		GuildBankFrameWithdrawalsTitleBackgroundRight:Show()

		if not self.tabs.info[self.currentTab] then return end
		if not self.tabs.info[self.currentTab].name then return end

		GuildBankFrameTabTitle:SetText(self.tabs.info[self.currentTab].name .. " " .. accessText)
	elseif self.BottomTab == 2 then
		GuildBankFrameTabTitle:SetText(self.tabs.info[self.currentTab].name .. " " .. GUILD_BANK_LOG .. " ")
	elseif self.BottomTab == 3 then
		GuildBankFrameTabTitle:SetText(GUILD_BANK_MONEY_LOG)
	end

end

function GuildBank:ResetAction()
	self.cursorFrame:Hide()
	self:ResetCursorItem()
end

------------------------------------------------------------
------------------------------------------- Tabs
------------------------------------------------------------

function GuildBank_UnlockTab_Accept(moneySource)
	GuildBank:Send("UnlockTab:" .. GuildBank.cost.tab .. ":" .. moneySource)
end

function GuildBankFrameBottomTab_OnClick(id)
	PlaySound("igCharacterInfoTab")

	GuildBank.BottomTab = id
	GuildBank:ResetAction()
	GuildBankFrameSlots:Hide()
	GuildBankFrameLog:Hide()
	GuildBankFrameMoneyLog:Hide()

	-- enable tab buttons
	for i = 1, GuildBank.tabs.numTabs do
		_G["GuildBankFrameGuildTab" .. i]:Enable()
		SetDesaturation(_G["GuildBankFrameGuildTab" .. i]:GetNormalTexture(), 0)
	end

	if GuildBank.BottomTab == 1 then
		GuildBank:UpdateTabs()
		GuildBankFrameSlots:Show()
	elseif GuildBank.BottomTab == 2 then
		GuildBank:ShowLog(GuildBank.currentTab)
	elseif GuildBank.BottomTab == 3 then
		-- disable tab buttons
		for i = 1, GuildBank.tabs.numTabs do
			_G["GuildBankFrameGuildTab" .. i]:Disable()
			SetDesaturation(_G["GuildBankFrameGuildTab" .. i]:GetNormalTexture(), 1)
		end
		GuildBank:ShowMoneyLog()
	end

	GuildBank:UpdateTabTitle()
end

function GuildBankFrameTab_OnClick(id, initial)
	for i = 1, MAX_TABS do
		_G["GuildBankFrameGuildTab"..i]:SetChecked(GuildBank.currentTab == i)
	end

	if arg1 == "RightButton" then
		if GuildBank:IsGm() and id <= GuildBank.tabs.numTabs then
			GuildBank:OpenTabSettings(id)
		end
		return
	end

	GuildBank:ResetAction()

	if _G["GuildBankFrameGuildTab" .. id].unlocked then
		GuildBank.currentTab = id
		-- reset all slots
		for i = 1, MAX_SLOTS do
			GuildBank:UpdateSlot(GuildBank.currentTab, i, nil, true)
		end
		-- fill
		for _, item in GuildBank.items[GuildBank.currentTab] do
			GuildBank:UpdateSlot(item.tab, item.slot, item, true)
		end
		if not initial then
			PlaySoundFile("Interface\\GuildBankFrame\\GuildBankOpenTab" .. math.random(1, 4) .. ".wav")
		end
		GuildBank:Update()
		-- log
		if GuildBank.BottomTab == 2 then
			GuildBank:ShowLog(id)
		end
	else
		_G["GuildBankFrameGuildTab" .. id]:SetChecked(false)
		GuildBank.cost.tab = id
		GuildBank:Send("UnlockTabCost:" .. id)
	end
end

function GuildBankFrameSaveTabSettings()
	if GuildBankFrameTabSettingsSaveButton:IsEnabled() == 0 then
		return
	end

	GuildBank:Send("UpdateTab:" .. GuildBank.newTabSettings.tab .. ":" ..
	GuildBank.newTabSettings.name .. ":" ..
	GuildBank.newTabSettings.icon .. ":" ..
	GuildBank.newTabSettings.withdrawals .. ":" ..
	GuildBank.newTabSettings.minrank)

	GuildBankFrameTabSettings:Hide()
end

function GuildBankFrameWithdrawalsDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo()
	for i = 0, MAX_WITHDRAWALS do
		info.text = i == 0 and GUILD_BANK_WITHDRAWAL_UNLIMITED or i
		info.value = i
		info.arg1 = i
		info.func = GuildBankFrameWithdrawalsDropDown_Set
		info.checked = i == GuildBank.newTabSettings.withdrawals
		UIDropDownMenu_AddButton(info)
	end
end

function GuildBankFrameAccessDropdown_Initialize()
	local info = UIDropDownMenu_CreateInfo()
	for i = 1, GuildControlGetNumRanks(), 1 do
		info.text = GuildControlGetRankName(i)
		info.value = i - 1
		info.arg1 = i - 1
		info.func = GuildBankFrameMinRankDropDown_Set
		info.checked = i - 1 == GuildBank.newTabSettings.minrank
		UIDropDownMenu_AddButton(info)
	end
end

function GuildBankFrameWithdrawalsDropDown_Set(value)
	if value == 0 then
		UIDropDownMenu_SetText(GUILD_BANK_WITHDRAWAL_UNLIMITED, GuildBankFrameTabSettingsWithdrawalsDropdown)
	else
		UIDropDownMenu_SetText(value, GuildBankFrameTabSettingsWithdrawalsDropdown)
	end
	GuildBank.newTabSettings.withdrawals = value
	GuildBankFrameTabSettings_Changed()
end

function GuildBankFrameMinRankDropDown_Set(value)
	UIDropDownMenu_SetText(GuildBank.guildRanks[value], GuildBankFrameTabSettingsAccessDropdown)
	GuildBank.newTabSettings.minrank = value
	GuildBankFrameTabSettings_Changed()
end

function GuildBankFrameWithdrawalsIcon_OnClick()
	local id = this:GetID()
	for i = 1, getn(GuildBank.iconFrames) do
		GuildBank.iconFrames[i]:SetChecked(false)
	end
	this:SetChecked(true)
	GuildBank.newTabSettings.icon = GuildBank.tabIcons[id]
	GuildBankFrameTabSettings_Changed()
end

function GuildBankFrameTabSettings_Changed()
	local name = trim(GuildBankFrameTabSettingsTabNameEditBox:GetText())

	if strlen(name) < 2 or strfind(name, ":", 1, true) then
		GuildBankFrameTabSettingsSaveButton:Disable()
		return
	end

	GuildBank.newTabSettings.name = name

	local enableSave
	for k in pairs(GuildBank.newTabSettings) do
		if GuildBank.newTabSettings[k] ~= GuildBank.oldTabSettings[k] then
			enableSave = true
			break
		end
	end

	if enableSave then
		GuildBankFrameTabSettingsSaveButton:Enable()
	else
		GuildBankFrameTabSettingsSaveButton:Disable()
	end
end

function GuildBank:UpdateTabs()
	if not self.gossipOpen then return end

	if not self.tabs.numTabs then return end

	for i = 1, MAX_TABS do
		_G["GuildBankFrameGuildTab" .. i]:Hide()
	end

	for i = 1, self.tabs.numTabs do
		_G["GuildBankFrameGuildTab" .. i]:SetNormalTexture("Interface\\Icons\\" .. self.tabs.info[i].icon)
		_G["GuildBankFrameGuildTab" .. i]:SetPushedTexture("Interface\\Icons\\" .. self.tabs.info[i].icon)
		_G["GuildBankFrameGuildTab" .. i].tooltip = self.tabs.info[i].name
		_G["GuildBankFrameGuildTab" .. i].tooltip2 = self:IsGm() and GUILD_BANK_MANAGE or nil
		_G["GuildBankFrameGuildTab" .. i].unlocked = true
		_G["GuildBankFrameGuildTab" .. i]:Show()
	end

	-- guild master
	if self.tabs.numTabs < MAX_TABS and self:IsGm() then
		_G["GuildBankFrameGuildTab" .. self.tabs.numTabs + 1]:Show()
		_G["GuildBankFrameGuildTab" .. self.tabs.numTabs + 1].tooltip = GUILD_BANK_BUY_TAB .. " " .. self.tabs.numTabs + 1
		_G["GuildBankFrameGuildTab" .. self.tabs.numTabs + 1].unlocked = false
		_G["GuildBankFrameGuildTab" .. self.tabs.numTabs + 1].tooltip2 = nil
		_G["GuildBankFrameGuildTab" .. self.tabs.numTabs + 1]:SetNormalTexture("Interface\\GuildBankFrame\\UI-GuildBankFrame-NewTab")
		_G["GuildBankFrameGuildTab" .. self.tabs.numTabs + 1]:SetPushedTexture("Interface\\GuildBankFrame\\UI-GuildBankFrame-NewTab")
	end

	for i = 1, MAX_TABS do
		_G["GuildBankFrameGuildTab" .. i]:SetChecked(i == self.currentTab)
	end
end

function GuildBank:OpenTabSettings(tab)
	self.oldTabSettings.tab = tab
	self.oldTabSettings.name = self.tabs.info[tab].name
	self.oldTabSettings.icon = self.tabs.info[tab].icon
	self.oldTabSettings.minrank = self.tabs.info[tab].minrank
	self.oldTabSettings.withdrawals = self.tabs.info[tab].withdrawals

	self.newTabSettings.tab = tab
	self.newTabSettings.name = self.oldTabSettings.name
	self.newTabSettings.icon = self.oldTabSettings.icon
	self.newTabSettings.minrank = self.oldTabSettings.minrank
	self.newTabSettings.withdrawals = self.oldTabSettings.withdrawals

	-- ranks
	self.guildRanks = {}
	for i = 1, GuildControlGetNumRanks() do
		self.guildRanks[i - 1] = GuildControlGetRankName(i)
	end

	-- name
	GuildBankFrameTabSettingsTabNameEditBox:SetText(self.oldTabSettings.name)

	-- withdrawals
	local withdrawalsText = self.oldTabSettings.withdrawals
	if withdrawalsText == 0 then
		withdrawalsText = GUILD_BANK_WITHDRAWAL_UNLIMITED
	end

	UIDropDownMenu_Initialize(GuildBankFrameTabSettingsWithdrawalsDropdown, GuildBankFrameWithdrawalsDropDown_Initialize)
	UIDropDownMenu_SetWidth(80, GuildBankFrameTabSettingsWithdrawalsDropdown)
	UIDropDownMenu_SetText(withdrawalsText, GuildBankFrameTabSettingsWithdrawalsDropdown)

	-- access
	UIDropDownMenu_Initialize(GuildBankFrameTabSettingsAccessDropdown, GuildBankFrameAccessDropdown_Initialize)
	UIDropDownMenu_SetWidth(80, GuildBankFrameTabSettingsAccessDropdown)
	UIDropDownMenu_SetText(self.guildRanks[self.oldTabSettings.minrank], GuildBankFrameTabSettingsAccessDropdown)

	-- icons
	self.iconFrames = self.iconFrames or {}

	local maxCol = 5
	local maxRow = 6
	local index = 1
	if not self.iconFrames[1] then
		for row = 1, maxRow do
			for col = 1, maxCol do
				local frame = CreateFrame("CheckButton", "GuildBankFrameIcon" .. index, GuildBankFrameTabSettings, "GuildBankFrameTabIconButtonTemplate")
				frame:SetPoint("TOPLEFT", GuildBankFrameTabSettings, "TOPLEFT", (col - 1) * 36 + 8, -(row - 1) * 36 - 111)
				frame:Show()
				self.iconFrames[index] = frame
				index = index + 1
			end
		end
	end

	GuildBankFrameTabSettingsSaveButton:Disable()
	GuildBankFrameTabSettingsWithdrawalsDropdown:Enable()
	GuildBankFrameTabSettingsWithdrawalsDropdownButton:Enable()
	GuildBankFrameTabSettings:Show()
	GuildBankFrameTabSettingsScrollFrame_Update()
end

function GuildBankFrameTabSettingsScrollFrame_Update()
	local offset = FauxScrollFrame_GetOffset(GuildBankFrameTabSettingsScrollFrame) or 0
	for i = 1, 30 do
		local frame = GuildBank.iconFrames[i]
		if frame then
			local iconIndex = i + (offset * 5)
			local texture = GuildBank.tabIcons[iconIndex]
			if texture then
				SetItemButtonTexture(frame, "Interface\\Icons\\" .. texture)
				frame:SetID(iconIndex)
				frame:SetChecked(strlower(texture) == strlower(GuildBank.newTabSettings.icon))
				frame:Show()
			else
				frame:Hide()
			end
		end
	end
	FauxScrollFrame_Update(GuildBankFrameTabSettingsScrollFrame, ceil(getn(GuildBank.tabIcons) / 5), 6, 36)
end

function GuildBank:GetTabWithdrawalsLeft()
	self:Send("GetTabWithdrawalsLeft:" .. self.currentTab)
end

function GuildBank:TabIsLocked(tab)
	if not self.guildInfo or not self.guildInfo.rankIndex then return true end

	if not self.tabs or not self.tabs.info or not self.tabs.info[tab] then return true end

	if self:IsGm() then return false end

	if self.guildInfo.rankIndex > self.tabs.info[tab].minrank then return true end

	if self.tabs.info[tab].withdrawals > 0 then
		if tonumber(self.withdrawalsLeft[tab]) == 0 then return true end
	end

	return false
end

function GuildBank:UpdateWithdrawalsLeft()

	local text = "|cffFFFFFF"..GUILD_BANK_WITHDRAWAL_UNLIMITED

	if self.withdrawalsLeft[self.currentTab] ~= "Unlimited" then
		if self.withdrawalsLeft[self.currentTab] == "0" then
			text = "|cffFFFFFF" .. GENERIC_NONE
		elseif self.withdrawalsLeft[self.currentTab] == "1" then
			text = "|cffFFFFFF" .. self.withdrawalsLeft[self.currentTab] .. " " .. GENERIC_STACK
		else
			text = "|cffFFFFFF" .. self.withdrawalsLeft[self.currentTab] .. " " .. GENERIC_STACKS
		end
	end

	if self:TabIsLocked(self.currentTab) then
		text = "|cffFFFFFF"..GENERIC_NONE
	end

	GuildBankFrameWithdrawalsTitle:SetText(GUILD_BANK_REMAINING_WITHDRAWALS .. ": " ..text)

	self:UpdateTabTitle()
	self:UpdateSlotRights()

end

------------------------------------------------------------
------------------------------------------- Money
------------------------------------------------------------

function GuildBankFrameMoneyFrame_OnLoad()
	GuildBankFrameMoneyFrameGoldButton:EnableMouse(false)
	GuildBankFrameMoneyFrameSilverButton:EnableMouse(false)
	GuildBankFrameMoneyFrameCopperButton:EnableMouse(false)
end

function GuildBank:UpdateMoney()
	local gold = floor(self.money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
	local silver = floor((self.money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = mod(self.money, COPPER_PER_SILVER)
	local goldButton = GuildBankFrameMoneyFrameGoldButton
	local silverButton = GuildBankFrameMoneyFrameSilverButton
	local copperButton = GuildBankFrameMoneyFrameCopperButton

	goldButton:SetText(gold)
	goldButton:SetWidth(goldButton:GetTextWidth() + MONEY_ICON_WIDTH_SMALL)
	goldButton:Show()
	silverButton:SetText(silver)
	silverButton:SetWidth(silverButton:GetTextWidth() + MONEY_ICON_WIDTH_SMALL)
	silverButton:Show()
	copperButton:SetText(copper)
	copperButton:SetWidth(copperButton:GetTextWidth() + MONEY_ICON_WIDTH_SMALL)
	copperButton:Show()
	GuildBankFrameMoneyFrameAvailableMoneyText:ClearAllPoints()
	GuildBankFrameMoneyFrameAvailableMoneyText:SetPoint("RIGHT", GuildBankFrameMoneyFrameGoldButtonText, "LEFT", -4, 0)
end

function GuildBankFrameMoneyFrameDepositMoney(money)
	if money and tonumber(money) > 0 then
		GuildBank:Send("DepositMoney:" .. money)
	end
end

function GuildBankFrameMoneyFrameWithdrawMoney(money)
	if money and tonumber(money) > 0 then
		GuildBank:Send("WithdrawMoney:" .. money)
	end
end

------------------------------------------------------------
------------------------------------------- Log
------------------------------------------------------------
function GuildBank:GetTabLog(tab)
	self:Send("GetTabLog:" .. tab)
end

function GuildBank:GetMoneyLog()
	self:Send("GetMoneyLog:")
end

function GuildBank:ShowLog(tab)
	GuildBankFrameLog:Show()
	GuildBankFrameLog:Clear()

	if sizeof(self.log[tab]) == 0 then
		GuildBankFrameLog:AddMessage(GUILD_BANK_NO_LOG)
		return
	end

	for _, line in ipairs(self.log[tab]) do
		if line.item then
			local name, _, quality = GetItemInfo(line.item)
			line.name = name or UNKNOWN
			line.quality = quality or 1
			local count = ""
			local fmt = ""
			local playerName = line.player
			local itemLink = ""

			if line.count > 1 then
				count = " x" .. line.count
			end

			itemLink = "|Hitem:" .. line.item .. ":" .. line.enchant .. ":" .. line.randomProperty .. ":0:0:0:0:0:0|h" .. ITEM_QUALITY_COLORS[line.quality].hex .. "[" .. line.name .. "]|h|r" .. count

			if line.action == ACTION_WITHDRAW then
				fmt = GUILD_BANK_WITHDREW
			elseif line.action == ACTION_DEPOSIT then
				fmt = GUILD_BANK_DEPOSITED
			elseif line.action == ACTION_DESTROY then
				fmt = GUILD_BANK_DESTROYED
			end

			local stamp = date(STAMP_FORMAT, line.stamp)

			GuildBankFrameLog:AddMessage(format(fmt, stamp, playerName, itemLink))
		end
	end
end

function GuildBank:ShowMoneyLog()
	GuildBankFrameMoneyLog:Show()
	GuildBankFrameMoneyLog:Clear()

	if sizeof(self.moneyLog) == 0 then
		GuildBankFrameMoneyLog:AddMessage(GUILD_BANK_NO_LOG)
		return
	end

	for _, line in ipairs(self.moneyLog) do
		local playerName = line.player
		local fmt = ""
		local money = ""

		if line.action == ACTION_UNLOCK_GUILD_BANK then
			fmt = GUILD_BANK_LOG_UNLOCK_BANK
		elseif line.action == ACTION_UNLOCK_GUILD_TAB_GUILD_MONEY then
			fmt = GUILD_BANK_LOG_UNLOCK_TAB1
		elseif line.action == ACTION_UNLOCK_GUILD_TAB_PERSONAL_MONEY then
			fmt = GUILD_BANK_LOG_UNLOCK_TAB2
		elseif line.action == ACTION_WITHDRAW_MONEY then
			fmt = GUILD_BANK_WITHDREW
		elseif line.action == ACTION_DEPOSIT_MONEY then
			fmt = GUILD_BANK_DEPOSITED
		else
			return
		end

		local gold = floor(line.money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
		local silver = floor((line.money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
		local copper = mod(line.money, COPPER_PER_SILVER)

		if gold > 0 then
			money = gold..COLOR_GOLD.." "..strlower(GOLD).."|r"
		end
		if silver > 0 then
			money = money.." "..silver..COLOR_SILVER.." "..strlower(SILVER).."|r"
		end
		if copper > 0 then
			money = money.." "..copper..COLOR_COPPER.." "..strlower(COPPER).."|r"
		end

		local stamp = date(STAMP_FORMAT, line.stamp)

		GuildBankFrameMoneyLog:AddMessage(format(fmt, stamp, playerName, money))
	end
end

function GuildBank:AppendLog(tab, line)

	local log = explode(line, ";")

	self:CacheItem(log[4])

	local stamp = tonumber(log[1])
	local player = log[2]
	local action = tonumber(log[3])
	local item = log[4] -- itemID
	local name = log[5]
	local quality = tonumber(log[6])
	local count = tonumber(log[7])
	local randomProperty = tonumber(log[8])
	local enchant = tonumber(log[9])

	if not self.log[tab] then self.log[tab] = {} end

	tinsert(self.log[tab], {
		stamp = stamp,
		player = player,
		action = action,
		item = item,
		name = name,
		quality = quality,
		count = count,
		randomProperty = randomProperty,
		enchant = enchant
	})

end

function GuildBank:AppendMoneyLog(line)

	local log = explode(line, ";")

	local stamp = tonumber(log[1])
	local player = log[2]
	local action = tonumber(log[3])
	local money = tonumber(log[4])

	tinsert(self.moneyLog, {
		stamp = stamp,
		player = player,
		action = action,
		money = money
	})

end

------------------------------------------------------------
------------------------------------------- Popups
------------------------------------------------------------

StaticPopupDialogs["GUILDBANK_UNLOCK"] = {
	text = GUILD_BANK_POPUP_UNLOCK,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		GuildBank_UnlockGuildBank_Accept()
	end,
	OnCancel = function()
		CloseGossip()
	end,
	hideOnEscape = 1,
}

StaticPopupDialogs["GUILDBANK_UNLOCK_TAB"] = {
	text = GUILD_BANK_POPUP_UNLOCK_TAB,
	button1 = GUILD_BANK_POPUP_UNLOCK_TAB_BUTTON1,
	button3 = GUILD_BANK_POPUP_UNLOCK_TAB_BUTTON2,
	button2 = CANCEL,
	OnAccept = function()
		GuildBank_UnlockTab_Accept(0) -- bank gold
	end,
	OnAlt = function()
		GuildBank_UnlockTab_Accept(1) -- personal gold
	end,
	OnCancel = function()
		GuildBank.cost = {
			feature = 0,
			tab = 0,
			tabCost = 0,
		}
	end,
	OnHide = function()
		GuildBank.cost = {
			feature = 0,
			tab = 0,
			tabCost = 0,
		}
	end,
	hideOnEscape = 1
}

StaticPopupDialogs["GUILDBANK_WITHDRAW_MONEY"] = {
	text = GUILD_BANK_POPUP_WITHDRAW,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		local moneyInputFrame = _G[this:GetParent():GetName() .. "MoneyInputFrame"]
		GuildBankFrameMoneyFrameWithdrawMoney(MoneyInputFrame_GetCopper(moneyInputFrame))
	end,
	OnHide = function()
		MoneyInputFrame_ResetMoney(_G[this:GetName() .. "MoneyInputFrame"])
	end,
	EditBoxOnEnterPressed = function()
		GuildBankFrameMoneyFrameWithdrawMoney(MoneyInputFrame_GetCopper(this:GetParent()))
		this:GetParent():GetParent():Hide()
	end,
	hasMoneyInputFrame = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["GUILDBANK_DEPOSIT_MONEY"] = {
	text = GUILD_BANK_POPUP_DEPOSIT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		local moneyInputFrame = _G[this:GetParent():GetName() .. "MoneyInputFrame"]
		GuildBankFrameMoneyFrameDepositMoney(MoneyInputFrame_GetCopper(moneyInputFrame))
	end,
	OnHide = function()
		MoneyInputFrame_ResetMoney(_G[this:GetName() .. "MoneyInputFrame"])
	end,
	EditBoxOnEnterPressed = function()
		GuildBankFrameMoneyFrameDepositMoney(MoneyInputFrame_GetCopper(this:GetParent()))
		this:GetParent():GetParent():Hide()
	end,
	hasMoneyInputFrame = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["GUILDBANK_DELETE_ITEM"] = {
	text = DELETE_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		local count = 0
		if GuildBank:CursorHasSplitItem() then
			count = GuildBank.cursorItem.count
		end
		GuildBank:Send("DestroyItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":" .. count)
		GuildBank:ResetAction()
	end,
	OnCancel = function()
		GuildBank:ResetAction()
	end,
	OnUpdate = function()
		if not GuildBank:CursorHasItem() then
			GuildBank:ResetAction()
		end
	end,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["GUILDBANK_DELETE_GOOD_ITEM"] = {
	text = DELETE_GOOD_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		local count = 0
		if GuildBank:CursorHasSplitItem() then
			count = GuildBank.cursorItem.count
		end
		GuildBank:Send("DestroyItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":" .. count)
		GuildBank:ResetAction()
	end,
	OnCancel = function()
		GuildBank:ResetAction()
	end,
	OnUpdate = function()
		if not GuildBank:CursorHasItem() then
			GuildBank:ResetAction()
		end
	end,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function()
		_G[this:GetName() .. "Button1"]:Disable()
		_G[this:GetName() .. "EditBox"]:SetFocus()
	end,
	OnHide = function()
		if (ChatFrameEditBox:IsShown()) then
			ChatFrameEditBox:SetFocus()
		end
		_G[this:GetName() .. "EditBox"]:SetText("")
	end,
	EditBoxOnEnterPressed = function()
		if (_G[this:GetParent():GetName() .. "Button1"]:IsEnabled() == 1) then
			GuildBank:Send("DestroyItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":0")
			GuildBank:ResetAction()
			this:GetParent():Hide()
		end
	end,
	EditBoxOnTextChanged = function()
		local editBox = _G[this:GetParent():GetName() .. "EditBox"]
		if (strupper(editBox:GetText()) == DELETE_ITEM_CONFIRM_STRING) then
			_G[this:GetParent():GetName() .. "Button1"]:Enable()
		else
			_G[this:GetParent():GetName() .. "Button1"]:Disable()
		end
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide()
		GuildBank:ResetAction()
	end
}
