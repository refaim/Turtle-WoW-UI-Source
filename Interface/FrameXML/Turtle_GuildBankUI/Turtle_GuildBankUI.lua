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

local TEXT_WITHDREW = "|cffff0000" .. GUILD_BANK_WITHDREW .. " "
local TEXT_DEPOSITT = "|cffffffff" .. GUILD_BANK_DEPOSITED .. " "
local TEXT_DESTROY = "|cffff8888" .. GUILD_BANK_DESTROYED .. " "
local COLOR_PLAYER = "|cffffd200"
local COLOR_GOLD = "|cffd7b845"
local COLOR_SILVER = "|cff979697"
local COLOR_COPPER = "|cffa05a39"
local STAMP_FORMAT = "%A %d %b %Y %H:%M"
local GAME_YELLOW = "|cffffff00"
local TRIGGER = "GUILD_BANK_TRIGGER"

local GuildBank = CreateFrame("Frame")

GuildBank:RegisterEvent("CHAT_MSG_ADDON")
GuildBank:RegisterEvent("GOSSIP_SHOW")
GuildBank:RegisterEvent("GOSSIP_CLOSED")
GuildBank:RegisterEvent("PLAYER_GUILD_UPDATE")
GuildBank:RegisterEvent("GUILD_ROSTER_UPDATE")

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

GuildBank.newTabSettings = {
	tab = nil,
	info = nil,
	ghettoTrigger = 0
}

GuildBank.cost = {
	feature = 0,
	tab = 0,
	tabCost = 0,
}

------------------------------------------------------------
------------------------------------------- Utils
------------------------------------------------------------

local function gprint(str)
	DEFAULT_CHAT_FRAME:AddMessage(GAME_YELLOW .. str)
end

local function gdebug(str)
	if GuildBank.debug then
		gprint("[g] " .. tostring(str))
	end
end

function GuildBank:Send(data)
	if self.debug then
		gdebug("|cff11ff00->" .. data)
	end
	SendAddonMessage(self.prefix, data, "GUILD")
end

function GuildBank:CacheItem(linkOrID)

	if not linkOrID then
		gdebug("cache item call with null " .. type(linkOrID))
	end

	if not linkOrID or linkOrID == 0 then
		return
	end

	if tonumber(linkOrID) then
		if GetItemInfo(linkOrID) then
			-- item ok, break
			return true
		else
			local item = "item:" .. linkOrID .. ":0:0:0"
			local _, _, itemLink = strfind(item, "(item:%d+:%d+:%d+:%d+)");
			linkOrID = itemLink
		end
	else
		if strfind(linkOrID, "|", 1, true) then
			local _, _, itemLink = strfind(linkOrID, "(item:%d+:%d+:%d+:%d+)");
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

------------------------------------------------------------
------------------------------------------- OnLoad
------------------------------------------------------------

function GuildBankFrame_OnLoad()
	GuildBank:HookFunctions()
	GuildBank:CreateFrames()
	GuildBank.startDelay:Show()
end

------------------------------------------------------------
------------------------------------------- Cursor
------------------------------------------------------------

function GuildBankFrame_CursorItem_OnClick()
end

function GuildBankFrame_CursorItem_OnKeyDown()
	if arg1 == "ESCAPE" then
		GuildBank:ResetAction()
	end
end

function GuildBank:ResetCursorItem()
	self.cursorItem = {
		tab = nil,
		slot = nil,
		from = nil,
		count = 0
	}
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
	GuildBank:ResetAction()
end)

GuildBank.cursorFrame:SetScript("OnUpdate", function()

	local cursorX, cursorY = GetCursorPosition();

	cursorX = cursorX / UIParent:GetScale()
	cursorY = cursorY / UIParent:GetScale()

	GuildBankFrameCursorItemFrameTexture:ClearAllPoints();
	GuildBankFrameCursorItemFrameTexture:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", cursorX - 5, cursorY - 32);

end)


------------------------------------------------------------
------------------------------------------- Tooltip
------------------------------------------------------------

function GuildBank:AddButtonOnEnterTooltip(frame, itemLink)
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -(this:GetWidth() / 4) + 10, -(this:GetHeight() / 4))
		GameTooltip:SetHyperlink(itemLink)
		local count = 0
		for i = 1, MAX_TABS do
			for _, item in GuildBank.items[i] do
				if frame.itemID == item.itemID then
					if frame.name == item.nameIfSuffix then
						count = count + item.count
					end
					if item.nameIfSuffix ~= "0" and frame.guid == item.guid then
						if strfind(item.nameIfSuffix, GameTooltipTextLeft1:GetText(), 1, true) then
							GameTooltipTextLeft1:SetText(item.nameIfSuffix)
						end
					end
				end
			end
		end
		if count > 1 then
			GameTooltip:AddLine(count .. " " .. GUILD_BANK_QUANTITY, 1, 1, 1, 1)
		end
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function GuildBank:RemoveButtonOnEnterTooltip(frame)
	frame:SetScript("OnEnter", nil)
end

GuildBank.TooltipFrame = CreateFrame("Frame", "GuildBankTooltipFrame", GameTooltip)

local TWGBHookSetBagItem = GameTooltip.SetBagItem
function GameTooltip.SetBagItem(self, container, slot)
	GameTooltip.itemLink = GetContainerItemLink(container, slot)
	local _, count = GetContainerItemInfo(container, slot)
	if count and count < 0 then
		count = 1
	end
	GameTooltip.itemCount = count
	return TWGBHookSetBagItem(self, container, slot)
end
GuildBank.TooltipFrame:SetScript("OnShow", function()
	if GameTooltip.itemLink then
		local count = 0
		for i = 1, MAX_TABS do
			for _, item in GuildBank.items[i] do
				local _, _, id = strfind(GameTooltip.itemLink, "item:(%d+)")
				id = tonumber(id)
				if id and id == item.itemID then
					count = count + item.count
				end
			end
		end
		if count > 0 then
			GameTooltip:AddLine(count .. " " .. TEXT(GUILD_BANK_QUANTITY), 1, 1, 1, 1)
			GameTooltip:Show()
		end
	end
end)

GuildBank.TooltipFrame:SetScript("OnHide", function()
	GameTooltip.itemLink = nil
end)

------------------------------------------------------------
------------------------------------------- Events
------------------------------------------------------------

GuildBank:SetScript("OnEvent", function()
	if (event == "PLAYER_GUILD_UPDATE" and arg1 == "player") or (event == "GUILD_ROSTER_UPDATE" and GuildBankFrame:IsShown()) then
		GuildBank.playerGuildUpdateTimer:Show()
		return
	end

	if event == "GOSSIP_SHOW" then
		if GetGossipText() == TRIGGER then
			UIPanelWindows.GossipFrame.pushable = 99
			local centerFrame = (GetCenterFrame())
			HideUIPanel(centerFrame)
			ShowUIPanel(centerFrame)
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
			StaticPopup_Hide("RENAME_TAB_BAD")
			StaticPopup_Hide("UNLOCK_GUILD_BANK")
			StaticPopup2_Hide("UNLOCK_GUILD_BANK_TAB")
			StaticPopup2_Hide("GUILDBANK_WITHDRAW_MONEY")
			StaticPopup2_Hide("GUILDBANK_DEPOSIT_MONEY")
		end
		return
	end

	if event == "CHAT_MSG_ADDON" and arg1 == GuildBank.prefix then
		local message = arg2

		if strfind(message, "^Access:Error:HC") then
			-- UIErrorsFrame:AddMessage(GUILD_BANK_ERR_HARDCORE, 1, 0.1, 0.1, 1)
			-- CloseGossip()
			return
		end

		-- bank management messages
		if strfind(message, "^Player:Unguilded") then
			GuildBank:Reset()
			-- UIErrorsFrame:AddMessage(ERR_GUILD_PLAYER_NOT_IN_GUILD, 1, 0.1, 0.1, 1)
			-- CloseGossip()
			return
		end

		if strfind(message, "^UnlockGuildBank:Cost:") then
			if GuildBank.gossipOpen then
				local _, _, cost = strfind(message, "UnlockGuildBank:Cost:(%d+)")
				StaticPopup_Show("UNLOCK_GUILD_BANK", cost)
			end
			return
		end

		if strfind(message, "^Unlock:Tab:%d+:Cost:%d+") then
			local _, _, tab, cost = strfind(message, "^Unlock:Tab:(%d+):Cost:(%d+)")
			if tab and cost then
				GuildBank.cost.tab = tab
				GuildBank.cost.tabCost = cost
				StaticPopup2_Show("UNLOCK_GUILD_BANK_TAB", GuildBank.cost.tab, GuildBank.cost.tabCost)
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
			local tabEx = explode(message, ":")
			local tab = tonumber(tabEx[2])

			local logLine = explode(message, "GTabLog:" .. tab .. ":")
			if logLine[2] then

				GuildBank:AppendLog(tab, logLine[2])

				if GuildBank.BottomTab == 2 then
					GuildBank:ShowLog(tab)
				end
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
end)

function GuildBankFrame_OnShow()
	PlaySoundFile("Interface\\GuildBankFrame\\GuildBankOpen.wav", "Dialog");
end

function GuildBankFrame_OnHide()

	GuildBank.gossipOpen = false

	StaticPopup_Hide("RENAME_TAB_BAD")
	StaticPopup_Hide("UNLOCK_GUILD_BANK")
	StaticPopup2_Hide("UNLOCK_GUILD_BANK_TAB")
	StaticPopup2_Hide("GUILDBANK_WITHDRAW_MONEY")
	StaticPopup2_Hide("GUILDBANK_DEPOSIT_MONEY")
	StaticPopup2_Hide("DELETE_GOOD_ITEM")
	StaticPopup2_Hide("DELETE_ITEM")

	GuildBank:ResetAction()

	PlaySoundFile("Interface\\GuildBankFrame\\GuildBankClose.wav", "Dialog");
end

function GuildBankFrameCloseButton_OnClick()
	HideUIPanel(GossipFrame)
	GossipFrame:SetAlpha(1)
	GuildBankFrame:Hide()
end

function GuildBank:PlayerGuildUpdate()
	self.playerGuildUpdateTimer:Hide()
	if IsInGuild() then

		local guildName = GetGuildInfo("player");
		if not guildName then
			return
		end

		if self.guildInfo.name then

			if self.guildInfo.name == guildName then
				self:Update("PlayerGuildUpdate")
			else
				self:Reset()
				self.startDelay:Show()
			end
			return
		else
			self:UpdateGuildInfo()
			self.playerGuildUpdateTimer:Show()
		end

	else
		self:Reset()
		GuildBankFrame:Hide()
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

				GuildBank:Init()
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

GuildBank.initDelay = CreateFrame("Frame")
GuildBank.initDelay:Hide()

GuildBank.initDelay:SetScript("OnShow", function()
	this.startTime = GetTime()
end)
GuildBank.initDelay:SetScript("OnHide", function()
end)

GuildBank.initDelay:SetScript("OnUpdate", function()
	local plus = 0.5
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then

		GuildBank:Init()
		GuildBank.initDelay:Hide()
	end
end)

function GuildBank_UnlockGuildBank_Accept()
	GuildBank:Send("UnlockGuildBank:Ok")
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

		_G["GuildBankFrameItem" .. i .. "Slot"]:SetText(i);

		self.itemFrames[i]:SetPoint("TOPLEFT", GuildBankFrameSlots, "TOPLEFT", col * 40 + separator + separators - 24, -10 - row * 44)
		self.itemFrames[i]:SetID(i)
		self.itemFrames[i].tab = 1
		self.itemFrames[i].slot = i
		self.itemFrames[i].occupied = false
		self.itemFrames[i].maxStack = 0
		self.itemFrames[i].guid = 0
		self.itemFrames[i].itemID = 0

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

function GuildBank:Init()

	gdebug("|cFF33FF00 GuildBank Init !")

	if not self.guildInfo.name then
		gdebug("init not guildinfo name")
		return
	end

	self.currentTab = 1
	self.BottomTab = 1

	GuildBankFrameBottomTab_Enable(GuildBankFrameBottomTab1)
	GuildBankFrameBottomTab_Disable(GuildBankFrameBottomTab2)
	GuildBankFrameBottomTab_Disable(GuildBankFrameBottomTab3)

	GuildBankFrameTab1:SetChecked(true)

	GuildRoster() --Requests updated guild roster information from the server

	self:GetBankInfo()

	self:ResetCursorItem()

	GuildBankFrameDestroyItemCatcherFrame:SetScript("OnMouseUp", function()
		GuildBank:ShowDeleteDialog()
	end)
end

function GuildBank:Reset()
	self:ResetAction()
	self.ready = false;
	self.money = 0;
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
	self.newTabSettings = {
		tab = nil,
		info = nil,
		ghettoTrigger = 0
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
				StaticPopup2_Show("DELETE_GOOD_ITEM", name .. count);
			else
				StaticPopup2_Show("DELETE_ITEM", name .. count);
			end
			return
		end
	end
	self:ResetAction()
end

function GuildBank:Update(w)
	gdebug(" ------------------------------ |cff88ff88 GUILDBANK Update()")
	if w then
		gdebug(w)
	end
	self:UpdateTabs()
	self:UpdateTabTitle()
	self:UpdateMoney()
	self:GetTabWithdrawalsLeft()
	self:UpdateGuildInfo()
	self:UpdateSlotRights()
end

function GuildBank:UpdateGuildInfo()

	gdebug("UpdateGuildInfo trigger")

	if IsInGuild() then

		gdebug("UpdateGuildInfo in guild")

		local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")

		if guildName then

			self.guildInfo.name = guildName;
			self.guildInfo.rankName = guildRankName;
			self.guildInfo.rankIndex = guildRankIndex;

			GuildBankFrameHeader:SetText(self.guildInfo.name .. " " .. GUILD_BANK_TITLE)

			gdebug("UpdateGuildInfo got guildName = [" .. self.guildInfo.name .. "]")
		else
			gdebug("UpdateGuildInfo player guilded, couldnt get info")
		end
	else
		self.guildInfo = {
			name = nil,
			rankName = nil,
			rankIndex = nil
		}
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

	local GuildBank_BagSlot_OnClick = ContainerFrameItemButton_OnClick
	if GuildBank_BagSlot_OnClick then
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

				if button == "RightButton" and GuildBankFrame:IsVisible() then
					local bag = this:GetParent():GetID()
					local slot = this:GetID()

					if GetContainerItemInfo(bag, slot) then
						local texture, count, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot);
						if count < 0 then
							count = 1
						end
						GuildBank:Send("DepositItem:" .. bag .. ":" .. slot .. ":" .. GuildBank.currentTab .. ":0:" .. count)
					end

					GuildBank:ResetAction()
					return
				end

			end

			-- execute original onclick
			GuildBank_BagSlot_OnClick(button, ignoreModifiers)

			-- original executed
			if button == "LeftButton" then

				-- item picked up ?
				if CursorHasItem() then

					-- todo
					--local texture, itemCount, locked = GetContainerItemInfo(BANK_CONTAINER, this:GetID());
					--if ( not locked ) then
					--
					--end

					local texture, count, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(this:GetParent():GetID(), this:GetID());
					if count < 0 then
						count = 1
					end
					GuildBank.cursorItem = {
						tab = this:GetParent():GetID(), --bag
						slot = this:GetID(),
						from = "bag",
						count = count
					}

					return
				else
					GuildBank:ResetAction()
				end

			end

		end
	end

	local GuildBank_StackSplitFrameOkay_Click = StackSplitFrameOkay_Click
	if GuildBank_StackSplitFrameOkay_Click then
		StackSplitFrameOkay_Click = function()
			GuildBank_StackSplitFrameOkay_Click()
			if StackSplitFrame.owner then
				GuildBank.cursorItem.tab = StackSplitFrame.owner:GetParent():GetID()
				GuildBank.cursorItem.slot = StackSplitFrame.owner:GetID()
				GuildBank.cursorItem.count = StackSplitFrame.split
			else
				gdebug("|cffff0000 StackSplitFrame doesnt have owner")
			end
		end
	end

end

------------------------------------------------------------
------------------------------------------- Slots
------------------------------------------------------------

function BankSlot_OnClick(button)

	if GuildBank:TabIsLocked(GuildBank.currentTab) then
		return
	end

	local frame = _G["GuildBankFrameItem" .. this:GetID()]

	if not button then
		return false
	end

	if button == "LeftButton" then

		if IsShiftKeyDown() then

			if frame.occupied then

				if ChatFrameEditBox:IsVisible() then
					local name, linkString, quality = GetItemInfo(frame.itemID)
					local itemLink = ITEM_QUALITY_COLORS[quality].hex .. "\124H" .. linkString .. "\124h[" .. name .. "]\124h\124r"
					ChatFrameEditBox:Insert(itemLink)
				else
					GuildBankFrame_OpenStackSplitFrame(frame.maxStack, frame, "BOTTOMRIGHT", "TOPRIGHT")
				end

			end

			return
		end

		if CursorHasItem() then
			if GuildBank:CursorHasBagItem() then
				-- from player bag
				-- todo fix pickup from keyring, click on bank, cursor ddoesnt have item here!

				GuildBank:Send("DepositItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot
				.. ":" .. GuildBank.currentTab .. ":" .. this:GetID() .. ":" .. GuildBank.cursorItem.count)
				ClearCursor()
				GuildBank:ResetAction()
				return
			else
				-- cursor has invalid item, from keyring for example
				ClearCursor()
				return
			end
		end

		if GuildBank:CursorHasBankItem() then

			-- move item
			if GuildBank.cursorItem.slot == frame.slot then
				-- same source dest
				GuildBank:ResetAction()
				return
			end
			GuildBank:Send("MoveItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":" .. frame.slot)
			GuildBank:ResetAction()
			return

		elseif GuildBank:CursorHasSplitItem() then

			-- split item
			if GuildBank.cursorItem.slot == frame.slot then
				-- same source dest
				GuildBank:ResetAction()
				return
			end
			GuildBank:Send("SplitItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":" .. frame.slot .. ":" .. GuildBank.cursorItem.count)
			GuildBank:ResetAction()
			return

		else
			if frame.occupied then
				-- pick up bank item
				local texture = _G[frame:GetName() .. "IconTexture"]:GetTexture()
				GuildBankFrameCursorItemFrameTexture:SetTexture(texture)

				GuildBank.cursorItem = {
					tab = frame.tab,
					slot = frame.slot,
					from = "bank",
					count = frame.count
				}
				-- show frame
				GuildBank.cursorFrame:Show()
				return
			else
				-- click on empty spot without cursoritem, do nothing
			end
		end

	end
	if button == "RightButton" then

		if GuildBank:CursorHasItem() then

			if GuildBank:CursorHasBagItem() then
				gdebug("has bag item")
			end
			if GuildBank:CursorHasBankItem() then
				gdebug("has bank item")
			end
			if GuildBank:CursorHasSplitItem() then
				gdebug("has split item")
			end
			GuildBank:ResetAction()
			return
		end

		-- auto withdraw from bank
		if frame.occupied then
			GuildBank:Send("WithdrawItem:" .. frame.tab .. ":" .. frame.slot .. ":0:0:" .. frame.count)
		end

	end
end

function BankSlot_OnDragStart()

	if GuildBank:TabIsLocked(GuildBank.currentTab) then
		return
	end

	local frame = _G["GuildBankFrameItem" .. this:GetID()]

	if frame.occupied then
		-- pick up bank item
		local texture = _G[frame:GetName() .. "IconTexture"]:GetTexture()
		GuildBankFrameCursorItemFrameTexture:SetTexture(texture)

		GuildBank.cursorItem = {
			tab = frame.tab,
			slot = frame.slot,
			from = "bank",
			count = frame.count
		}

		-- show frame
		GuildBank.cursorFrame:Show()
		return
	else
		-- start drag from empty slot
	end


end

function BankSlot_OnReceiveDrag()

	if GuildBank:TabIsLocked(GuildBank.currentTab) then
		return
	end

	local frame = _G["GuildBankFrameItem" .. this:GetID()]

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

		local texture, count, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(GuildBank.cursorItem.tab, GuildBank.cursorItem.slot);
		if count < 0 then
			count = 1
		end
		GuildBank:Send("DepositItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":" .. frame.tab .. ":" .. frame.slot .. ":" .. count)
		ClearCursor();
		GuildBank:ResetAction()
		return

	end

end

function GuildBankFrame_StackSplitFrameRight_Click()
	if GuildBankFrameStackSplitFrame.split == GuildBankFrameStackSplitFrame.maxStack then
		return
	end

	GuildBankFrameStackSplitFrame.split = GuildBankFrameStackSplitFrame.split + 1
	GuildBankFrameStackSplitFrameSplitText:SetText(GuildBankFrameStackSplitFrame.split)

	if GuildBankFrameStackSplitFrame.split == GuildBankFrameStackSplitFrame.maxStack then
		GuildBankFrameStackSplitFrameRightButton:Disable()
	end
	GuildBankFrameStackSplitFrameLeftButton:Enable()
end

function GuildBankFrame_StackSplitFrameLeft_Click()
	if GuildBankFrameStackSplitFrame.split == 1 then
		return
	end

	GuildBankFrameStackSplitFrame.split = GuildBankFrameStackSplitFrame.split - 1;
	GuildBankFrameStackSplitFrameSplitText:SetText(GuildBankFrameStackSplitFrame.split);

	if GuildBankFrameStackSplitFrame.split == 1 then
		GuildBankFrameStackSplitFrameLeftButton:Disable()
	end
	GuildBankFrameStackSplitFrameRightButton:Enable()
end

function GuildBankFrame_StackSplitFrameOkay_Click()
	if GuildBankFrameStackSplitFrame.owner then

		local texture = _G["GuildBankFrameItem" .. GuildBank.cursorItem.slot .. "IconTexture"]:GetTexture()
		GuildBankFrameCursorItemFrameTexture:SetTexture(texture)

		GuildBank.cursorItem.count = GuildBankFrameStackSplitFrame.split

		GuildBank.cursorFrame:Show()

	end
	GuildBankFrameStackSplitFrame:Hide();
end

function GuildBankFrame_StackSplitFrameCancel_Click()
	GuildBankFrameStackSplitFrame:Hide();
end

function GuildBankFrame_OpenStackSplitFrame(maxStack, parent, anchor, anchorTo)
	if GuildBankFrameStackSplitFrame.owner then
		GuildBankFrameStackSplitFrame.owner.hasStackSplit = 0
	end

	GuildBankFrameStackSplitFrame.maxStack = maxStack
	if GuildBankFrameStackSplitFrame.maxStack < 2 then
		GuildBankFrameStackSplitFrame:Hide()
		return
	end

	GuildBankFrameStackSplitFrame.owner = parent
	parent.hasStackSplit = 1
	GuildBankFrameStackSplitFrame.split = 1
	GuildBankFrameStackSplitFrame.typing = 0
	GuildBankFrameStackSplitFrameSplitText:SetText(GuildBankFrameStackSplitFrame.split)
	GuildBankFrameStackSplitFrameLeftButton:Disable()
	GuildBankFrameStackSplitFrameRightButton:Enable()

	GuildBank.cursorItem.tab = GuildBank.currentTab
	GuildBank.cursorItem.slot = parent:GetID()
	GuildBank.cursorItem.from = "split"
	GuildBank.cursorItem.count = 0

	GuildBankFrameStackSplitFrame:ClearAllPoints()
	GuildBankFrameStackSplitFrame:SetPoint(anchor, parent, anchorTo, 0, 0)
	GuildBankFrameStackSplitFrame:Show()
end

function GuildBankFrame_StackSplitFrame_OnKeyDown()
	if arg1 == "BACKSPACE" or arg1 == "DELETE" then
		if this.typing == 0 or this.split == 1 then
			return
		end

		this.split = floor(this.split / 10)
		if this.split <= 1 then
			this.split = 1
			this.typing = 0
			GuildBankFrameStackSplitFrameLeftButton:Disable()
		else
			GuildBankFrameStackSplitFrameLeftButton:Enable()
		end
		GuildBankFrameStackSplitFrameSplitText:SetText(this.split)
		if (this.money == this.maxStack) then
			GuildBankFrameStackSplitFrameRightButton:Disable()
		else
			GuildBankFrameStackSplitFrameRightButton:Enable()
		end
	elseif arg1 == "ENTER" then
		GuildBankFrame_StackSplitFrameOkay_Click()
	elseif arg1 == "ESCAPE" then
		GuildBankFrame_StackSplitFrameCancel_Click()
	elseif arg1 == "LEFT" or arg1 == "DOWN" then
		GuildBankFrame_StackSplitFrameLeft_Click()
	elseif arg1 == "RIGHT" or arg1 == "UP" then
		GuildBankFrame_StackSplitFrameRight_Click()
	end
end

function GuildBankFrame_StackSplitFrame_OnChar()
	if arg1 < "0" or arg1 > "9" then
		return
	end

	if this.typing == 0 then
		this.typing = 1
		this.split = 0
	end

	local split = (this.split * 10) + arg1
	if split == this.split then
		if this.split == 0 then
			this.split = 1
		end
		return
	end

	if split <= this.maxStack then
		this.split = split
		GuildBankFrameStackSplitFrameSplitText:SetText(split)
		if split == this.maxStack then
			GuildBankFrameStackSplitFrameRightButton:Disable()
		else
			GuildBankFrameStackSplitFrameRightButton:Enable()
		end
		if split == 1 then
			GuildBankFrameStackSplitFrameLeftButton:Disable()
		else
			GuildBankFrameStackSplitFrameLeftButton:Enable()
		end
	elseif split == 0 then
		this.split = 1
	end
end

function GuildBank:UpdateSlot(tab, slot, item, noAnimation)

	local frame = _G["GuildBankFrameItem" .. slot]

	if not frame then
		gdebug("update slot error, no frame")
		return
	end

	if self:CursorHasItem() and self.currentTab == tab then
		if self.cursorItem.tab == tab and self.cursorItem.slot == slot then
			self:ResetAction()
		end
	end

	if tab ~= self.currentTab then
		return
	end

	if not item or item.guid == 0 then
		frame.occupied = false
		frame.tab = tab
		frame.itemID = 0
		frame.guid = 0
		frame.name = "0"
		SetItemButtonTexture(frame, nil);
		_G[frame:GetName() .. "Count"]:Hide()
		self:RemoveButtonOnEnterTooltip(frame)
		return
	end

	if item.guid ~= 0 then

		frame.occupied = true
		frame.tab = item.tab
		frame.itemID = item.itemID
		frame.count = item.count
		frame.guid = item.guid
		frame.name = item.nameIfSuffix

		local name, linkString, _, _, _, _, maxStack, _, texture = GetItemInfo(item.itemID)

		if not name then
			-- cache
			self:CacheItem(item.itemID)
			return
		end

		linkString = gsub(linkString, ":0:0:0", ":" .. item.enchant .. ":" .. item.randomProperty .. ":0")

		frame.maxStack = maxStack

		SetItemButtonTexture(frame, texture);

		_G["GuildBankFrameItem" .. item.slot .. "Count"]:Hide()

		if item.count > 1 then
			_G["GuildBankFrameItem" .. item.slot .. "Count"]:SetText(item.count)
			_G["GuildBankFrameItem" .. item.slot .. "Count"]:Show()
		end

		if self.currentTab == frame.tab and not noAnimation then
			ComboPointShineFadeIn(_G["GuildBankFrameItem" .. frame.slot .. "Shine"])
		end

		self:AddButtonOnEnterTooltip(frame, linkString)
	end
end

function GuildBank:UpdateTabTitle()

	if not self.tabs.info then return end

	local accessText = ITEM_QUALITY_COLORS[2].hex .. "(" .. GUILD_BANK_FULL_ACCESS .. ")"

	if self:TabIsLocked(self.currentTab) then
		accessText = "|cffff1111(" .. GUILD_BANK_LOCKED .. ")"
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

function GuildBankFrameBottomTab_Disable(tab)
	local name = tab:GetName();
	_G[name .. "Left"]:Show()
	_G[name .. "Middle"]:Show()
	_G[name .. "Right"]:Show()
	tab:Enable();
	_G[name .. "LeftDisabled"]:Hide()
	_G[name .. "MiddleDisabled"]:Hide()
	_G[name .. "RightDisabled"]:Hide()
end

function GuildBankFrameBottomTab_Enable(tab)
	local name = tab:GetName();
	_G[name .. "Left"]:Hide()
	_G[name .. "Middle"]:Hide()
	_G[name .. "Right"]:Hide()
	tab:Disable();
	_G[name .. "LeftDisabled"]:Show()
	_G[name .. "MiddleDisabled"]:Show()
	_G[name .. "RightDisabled"]:Show()
end

function GuildBankFrameBottomTab_OnClick(id)

	PlaySound("igCharacterInfoTab");

	GuildBank.BottomTab = id
	GuildBank:ResetAction()

	GuildBankFrameBottomTab_Disable(GuildBankFrameBottomTab1)
	GuildBankFrameBottomTab_Disable(GuildBankFrameBottomTab2)
	GuildBankFrameBottomTab_Disable(GuildBankFrameBottomTab3)

	GuildBankFrameBottomTab_Enable(_G["GuildBankFrameBottomTab" .. id])

	GuildBankFrameSlots:Hide()
	GuildBankFrameLog:Hide()
	GuildBankFrameMoneyLog:Hide()

	-- enable tab buttons
	for i = 1, GuildBank.tabs.numTabs do
		_G["GuildBankFrameTab" .. i]:Enable()
		SetDesaturation(_G["GuildBankFrameTab" .. i]:GetNormalTexture(), 0)
	end

	if GuildBank.BottomTab == 1 then
		GuildBank:UpdateTabs()
		GuildBankFrameSlots:Show()
	elseif GuildBank.BottomTab == 2 then
		GuildBank:ShowLog(GuildBank.currentTab)
	elseif GuildBank.BottomTab == 3 then
		-- disable tab buttons
		for i = 1, GuildBank.tabs.numTabs do
			_G["GuildBankFrameTab" .. i]:Disable()
			SetDesaturation(_G["GuildBankFrameTab" .. i]:GetNormalTexture(), 1)
		end
		GuildBank:ShowMoneyLog()
	end

	GuildBank:UpdateTabTitle()
end

function GuildBankFrameTab_OnClick(id, initial)

	if arg1 == "RightButton" then
		if GuildBank:IsGm() and id <= GuildBank.tabs.numTabs then
			GuildBank:OpenTabSettings(id)
		end
		return
	end

	GuildBank:ResetAction()

	if GuildBank.currentTab == id and not initial then
		_G["GuildBankFrameTab" .. id]:SetChecked(true)
		return
	end

	if _G["GuildBankFrameTab" .. id].unlocked then

		GuildBank.currentTab = id

		for i = 1, MAX_TABS do
			_G["GuildBankFrameTab"..i]:SetChecked(false)
		end

		_G["GuildBankFrameTab" .. id]:SetChecked(true)

		-- reset all slots
		for i = 1, MAX_SLOTS do
			GuildBank:UpdateSlot(GuildBank.currentTab, i, nil, true)
		end

		-- fill
		for _, item in GuildBank.items[GuildBank.currentTab] do
			GuildBank:UpdateSlot(item.tab, item.slot, item, true)
		end

		if not initial then
			PlaySoundFile("Interface\\GuildBankFrame\\GuildBankOpenTab" .. math.random(1, 4) .. ".wav", "Dialog");
		end

		GuildBank:Update()

		-- log
		if GuildBank.BottomTab == 2 then
			GuildBank:ShowLog(id)
		end

	else
		_G["GuildBankFrameTab" .. id]:SetChecked(false)
		GuildBank.cost.tab = id
		GuildBank:Send("UnlockTabCost:" .. id)
	end

end

function GuildBankFrameSaveTabSettings()
	if GuildBank.newTabSettings.info.name == "" then
		StaticPopup_Show("RENAME_TAB_BAD")
		return
	end

	local start, finish = 1, 1
	for i = 1, string.len(GuildBank.newTabSettings.info.name) do
		if string.sub(GuildBank.newTabSettings.info.name, i, i) ~= " " then
			start = i
			break
		end
	end
	for i = string.len(GuildBank.newTabSettings.info.name), 1, -1 do
		if string.sub(GuildBank.newTabSettings.info.name, i, i) ~= " " then
			finish = i
			break
		end
	end

	if start == finish or string.len(string.sub(GuildBank.newTabSettings.info.name, start, finish)) < 2 then
		StaticPopup_Show("RENAME_TAB_BAD")
		return
	end

	GuildBank.newTabSettings.info.name = string.sub(GuildBank.newTabSettings.info.name, start, finish)

	GuildBank:Send("UpdateTab:" .. GuildBank.newTabSettings.tab .. ":" ..
	GuildBank.newTabSettings.info.name .. ":" ..
	GuildBank.newTabSettings.info.icon .. ":" ..
	GuildBank.newTabSettings.info.withdrawals .. ":" ..
	GuildBank.newTabSettings.info.minrank)

	GuildBankFrameCloseTabSettings()
end

function GuildBankFrameCloseTabSettings()
	GuildBank.newTabSettings = {
		tab = nil,
		info = nil,
		ghettoTrigger = 0
	}
	GuildBankFrameTabSettings:Hide()
end

function GuildBankFrameWithdrawalsDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo()
	for i = 0, MAX_WITHDRAWALS do
		info.text = i == 0 and GUILD_BANK_WITHDRAWAL_UNLIMITED or i
		info.value = i
		info.arg1 = i
		info.func = GuildBankFrameWithdrawalsDropDown_Set
		info.checked = i == GuildBank.newTabSettings.info.withdrawals
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
		info.checked = i - 1 == GuildBank.newTabSettings.info.minrank
		UIDropDownMenu_AddButton(info);
	end
end

function GuildBankFrameWithdrawalsDropDown_Set(value)
	if value == 0 then
		UIDropDownMenu_SetText(GUILD_BANK_WITHDRAWAL_UNLIMITED, GuildBankFrameTabSettingsWithdrawalsDropdown)
	else
		UIDropDownMenu_SetText(value, GuildBankFrameTabSettingsWithdrawalsDropdown)
	end
	GuildBank.newTabSettings.info.withdrawals = value
	GuildBankFrameTabSettings_Changed(true)
end

function GuildBankFrameMinRankDropDown_Set(value)
	UIDropDownMenu_SetText(GuildBank.guildRanks[value], GuildBankFrameTabSettingsAccessDropdown)
	GuildBank.newTabSettings.info.minrank = value
	GuildBankFrameTabSettings_Changed(true)
end

function GuildBankFrameWithdrawalsIcon_OnClick()
	for i in GuildBank.tabIcons do
		_G["GuildBankFrameIcon" .. i .. "Selected"]:Hide()
	end

	_G["GuildBankFrameIcon" .. this:GetID() .. "Selected"]:Show()

	GuildBank.newTabSettings.info.icon = GuildBank.tabIcons[this:GetID()]

	GuildBankFrameTabSettings_Changed(true)
end

function GuildBankFrameTabSettings_Changed(force)
	if GuildBank.newTabSettings.ghettoTrigger == 0 and not force then
		GuildBank.newTabSettings.ghettoTrigger = GuildBank.newTabSettings.ghettoTrigger + 1
		return
	end
	GuildBank.newTabSettings.info.name = GuildBankFrameTabSettingsTabNameEditBox:GetText()
	if string.len(GuildBank.newTabSettings.info.name) < 2 or GuildBank.newTabSettings.info.name == "" then
		GuildBankFrameTabSettingsSaveButton:Disable()
	else
		GuildBankFrameTabSettingsSaveButton:Enable()
	end
end

function GuildBank:UpdateTabs()
	if not self.gossipOpen then
		return
	end

	if not self.tabs.numTabs then
		return
	end

	for i = 1, MAX_TABS do
		_G["GuildBankFrameTab" .. i]:Hide()
	end

	for i = 1, self.tabs.numTabs do
		_G["GuildBankFrameTab" .. i]:SetNormalTexture("Interface\\Icons\\" .. self.tabs.info[i].icon)
		_G["GuildBankFrameTab" .. i]:SetPushedTexture("Interface\\Icons\\" .. self.tabs.info[i].icon)
		_G["GuildBankFrameTab" .. i].tooltip = self.tabs.info[i].name
		_G["GuildBankFrameTab" .. i].tooltip2 = self:IsGm() and GUILD_BANK_MANAGE or nil
		_G["GuildBankFrameTab" .. i].unlocked = true
		_G["GuildBankFrameTab" .. i]:Show()
	end

	-- guild master
	if self.tabs.numTabs < MAX_TABS and self:IsGm() then
		_G["GuildBankFrameTab" .. self.tabs.numTabs + 1]:Show()
		_G["GuildBankFrameTab" .. self.tabs.numTabs + 1].tooltip = GUILD_BANK_BUY_TAB .. " " .. self.tabs.numTabs + 1
		_G["GuildBankFrameTab" .. self.tabs.numTabs + 1].unlocked = false
		_G["GuildBankFrameTab" .. self.tabs.numTabs + 1].tooltip2 = nil
		_G["GuildBankFrameTab" .. self.tabs.numTabs + 1]:SetNormalTexture("Interface\\GuildBankFrame\\UI-GuildBankFrame-NewTab")
		_G["GuildBankFrameTab" .. self.tabs.numTabs + 1]:SetPushedTexture("Interface\\GuildBankFrame\\UI-GuildBankFrame-NewTab")
	end

	for i = 1, MAX_TABS do
		_G["GuildBankFrameTab" .. i]:SetChecked(false)
	end
	_G["GuildBankFrameTab" .. self.currentTab]:SetChecked(true)

end

function GuildBank:OpenTabSettings(tab)

	self.newTabSettings = {
		tab = tab,
		info = self.tabs.info[tab],
		ghettoTrigger = 0 -- yeah...
	}

	-- ranks
	self.guildRanks = {}
	for i = 1, GuildControlGetNumRanks() do
		self.guildRanks[i - 1] = GuildControlGetRankName(i);
	end

	-- name
	GuildBankFrameTabSettingsTabNameEditBox:SetText(self.tabs.info[tab].name)

	-- withdrawals
	local withdrawalsText = self.tabs.info[tab].withdrawals
	if withdrawalsText == 0 then
		withdrawalsText = GUILD_BANK_WITHDRAWAL_UNLIMITED
	end

	UIDropDownMenu_Initialize(GuildBankFrameTabSettingsWithdrawalsDropdown, GuildBankFrameWithdrawalsDropDown_Initialize);
	UIDropDownMenu_SetWidth(80, GuildBankFrameTabSettingsWithdrawalsDropdown);
	UIDropDownMenu_SetText(withdrawalsText, GuildBankFrameTabSettingsWithdrawalsDropdown)

	-- access
	UIDropDownMenu_Initialize(GuildBankFrameTabSettingsAccessDropdown, GuildBankFrameAccessDropdown_Initialize);
	UIDropDownMenu_SetWidth(80, GuildBankFrameTabSettingsAccessDropdown);
	UIDropDownMenu_SetText(self.guildRanks[self.tabs.info[tab].minrank], GuildBankFrameTabSettingsAccessDropdown)

	-- icons
	self.iconFrames = {}

	local col = 0
	local row = 0

	for i, icon in self.tabIcons do

		if not self.iconFrames[i] then
			self.iconFrames[i] = CreateFrame("Button", "GuildBankFrameIcon" .. i, GuildBankFrameTabSettingsScrollFrameChildren, "GuildBankFrameTabIconButtonTemplate")
		end

		SetItemButtonTexture(_G["GuildBankFrameIcon" .. i], "Interface\\Icons\\" .. icon);

		self.iconFrames[i]:SetPoint("TOPLEFT", GuildBankFrameTabSettingsScrollFrameChildren, "TOPLEFT", col * 36 + 3, -row * 36)
		self.iconFrames[i]:Show()
		self.iconFrames[i]:SetID(i)

		_G["GuildBankFrameIcon" .. i .. "Selected"]:Hide()
		if icon == self.tabs.info[tab].icon then
			_G["GuildBankFrameIcon" .. i .. "Selected"]:Show()
		end

		col = col + 1

		if col == 5 then
			col = 0
			row = row + 1
		end

	end

	GuildBankFrameTabSettingsSaveButton:Disable()

	GuildBankFrameTabSettingsWithdrawalsDropdown:Enable()
	GuildBankFrameTabSettingsWithdrawalsDropdownButton:Enable()

	GuildBankFrameTabSettings:Show()
end

function GuildBank:GetTabWithdrawalsLeft()
	self:Send("GetTabWithdrawalsLeft:" .. self.currentTab)
end

function GuildBank:TabIsLocked(tab)
	if not self.guildInfo or not self.guildInfo.rankIndex then
		return true
	end
	if not self.tabs or
		not self.tabs.info or
		not self.tabs.info[tab] then
		return true
	end

	if self:IsGm() then
		return false
	end

	if self.guildInfo.rankIndex > self.tabs.info[tab].minrank then
		return true
	end

	if self.tabs.info[tab].withdrawals > 0 then

		if tonumber(self.withdrawalsLeft[tab]) == 0 then
			return true
		end

		--if self.withdrawalsLeft[tab] == "Unlimited" then
		--	 return false
		--else
		--	 if tonumber(self.withdrawalsLeft[tab]) == 0 then
		--		  return true
		--	 end
		--end

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
	GuildBankFrameMoneyFrameGoldButton:EnableMouse(false);
	GuildBankFrameMoneyFrameSilverButton:EnableMouse(false);
	GuildBankFrameMoneyFrameCopperButton:EnableMouse(false);
end

function GuildBank:UpdateMoney()
	local gold = floor(self.money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
	local silver = floor((self.money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = mod(self.money, COPPER_PER_SILVER)
	local goldButton = GuildBankFrameMoneyFrameGoldButton
	local silverButton = GuildBankFrameMoneyFrameSilverButton
	local copperButton = GuildBankFrameMoneyFrameCopperButton

	goldButton:SetText(gold);
	goldButton:SetWidth(goldButton:GetTextWidth() + MONEY_ICON_WIDTH_SMALL);
	goldButton:Show();
	silverButton:SetText(silver);
	silverButton:SetWidth(silverButton:GetTextWidth() + MONEY_ICON_WIDTH_SMALL);
	silverButton:Show();
	copperButton:SetText(copper);
	copperButton:SetWidth(copperButton:GetTextWidth() + MONEY_ICON_WIDTH_SMALL);
	copperButton:Show();
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

function TWGuildLogHyperlinkClick()
	ChatFrame_OnHyperlinkShow(arg1, arg2, arg3)
end

function TWGuildLog_OnScroll()
	if arg1 > 0 then
		this:ScrollUp()
	else
		if IsShiftKeyDown() then
			this:ScrollToBottom();
		else
			this:ScrollDown()
		end
	end
end

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
	end

	for _, line in self.log[tab] do
		if line.item then
			local name, _, quality = GetItemInfo(line.item)
			line.name = name or UNKNOWN
			line.quality = quality or 1
			local count = ""
			local actionText = ""
			local playerName = COLOR_PLAYER .. line.player .. " "
			local itemLink = ""

			if line.count > 1 then
				count = " x " .. line.count
			end

			itemLink = "|Hitem:" .. line.item .. ":" .. line.enchant .. ":" .. line.randomProperty .. ":0:0:0:0:0:0|h" .. ITEM_QUALITY_COLORS[line.quality].hex .. "[" .. line.name .. "]|h|r" .. count

			if line.action == ACTION_WITHDRAW then
				actionText = TEXT_WITHDREW
			elseif line.action == ACTION_DEPOSIT then
				actionText = TEXT_DEPOSITT
			elseif line.action == ACTION_DESTROY then
				actionText = TEXT_DESTROY
			end

			local stamp = date(STAMP_FORMAT, line.stamp)
			stamp = " |cffafafaf(" .. stamp .. ")"

			GuildBankFrameLog:AddMessage(playerName .. actionText .. itemLink .. stamp);
		end
	end

end

function GuildBank:ShowMoneyLog()

	GuildBankFrameMoneyLog:Show()
	GuildBankFrameMoneyLog:Clear()
	if sizeof(self.moneyLog) == 0 then
		GuildBankFrameLog:AddMessage(GUILD_BANK_NO_LOG)
	end

	for _, line in self.moneyLog do

		local playerName = COLOR_PLAYER .. line.player .. " "
		local actionText = ""
		local money = ""

		if line.action == ACTION_UNLOCK_GUILD_BANK then
			actionText = "|cff0abb34" .. GUILD_BANK_LOG_UNLOCK_BANK .. " "
		elseif line.action == ACTION_UNLOCK_GUILD_TAB_GUILD_MONEY then
			actionText = "|cff0abb34" .. GUILD_BANK_LOG_UNLOCK_TAB1 .. " "
		elseif line.action == ACTION_UNLOCK_GUILD_TAB_PERSONAL_MONEY then
			actionText = "|cff0abb34" .. GUILD_BANK_LOG_UNLOCK_TAB2 .. " "
		elseif line.action == ACTION_WITHDRAW_MONEY then
			actionText = TEXT_WITHDREW
		elseif line.action == ACTION_DEPOSIT_MONEY then
			actionText = TEXT_DEPOSITT
		else
			return
		end

		local gold = floor(line.money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
		local silver = floor((line.money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
		local copper = mod(line.money, COPPER_PER_SILVER)

		if gold > 0 then
			money = "|r" .. gold .. COLOR_GOLD .. "g"
		end
		if silver > 0 then
			money = money .. "|r" .. silver .. COLOR_SILVER .. "s"
		end
		if copper > 0 then
			money = money .. "|r" .. copper .. COLOR_COPPER .. "c"
		end

		local stamp = date(STAMP_FORMAT, line.stamp)
		stamp = " |cffafafaf(" .. stamp .. ")"

		GuildBankFrameMoneyLog:AddMessage(playerName .. actionText .. money .. stamp);

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

	if not self.log[tab] then
		self.log[tab] = {}
	end

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

StaticPopupDialogs["UNLOCK_GUILD_BANK"] = {
	text = TEXT(GUILD_BANK_POPUP_UNLOCK),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		GuildBank_UnlockGuildBank_Accept()
	end,
    OnCancel = function()
        CloseGossip()
    end,
	timeout = 0,
	whileDead = 0,
	hideOnEscape = 1,
};

StaticPopup2Dialogs["UNLOCK_GUILD_BANK_TAB"] = {
	text = TEXT(GUILD_BANK_POPUP_UNLOCK_TAB),
	button1 = TEXT(GUILD_BANK_POPUP_UNLOCK_TAB_BUTTON1),
	button3 = TEXT(GUILD_BANK_POPUP_UNLOCK_TAB_BUTTON2),
	button2 = TEXT(CANCEL),
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
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["RENAME_TAB_BAD"] = {
	text = TEXT(GUILD_BANK_POPUP_INVALID_NAME),
	button1 = TEXT(OKAY),
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopup2Dialogs["GUILDBANK_WITHDRAW_MONEY"] = {
	text = TEXT(GUILD_BANK_POPUP_WITHDRAW),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		local moneyInputFrame = _G[this:GetParent():GetName() .. "MoneyInputFrame"]
		GuildBankFrameMoneyFrameWithdrawMoney(MoneyInputFrame_GetCopper(moneyInputFrame));
	end,
	OnHide = function()
		MoneyInputFrame_ResetMoney(_G[this:GetName() .. "MoneyInputFrame"])
	end,
	EditBoxOnEnterPressed = function()
		GuildBankFrameMoneyFrameWithdrawMoney(MoneyInputFrame_GetCopper(this:GetParent()));
		this:GetParent():GetParent():Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopup2Dialogs["GUILDBANK_DEPOSIT_MONEY"] = {
	text = TEXT(GUILD_BANK_POPUP_DEPOSIT),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		local moneyInputFrame = _G[this:GetParent():GetName() .. "MoneyInputFrame"]
		GuildBankFrameMoneyFrameDepositMoney(MoneyInputFrame_GetCopper(moneyInputFrame));
	end,
	OnHide = function()
		MoneyInputFrame_ResetMoney(_G[this:GetName() .. "MoneyInputFrame"])
	end,
	EditBoxOnEnterPressed = function()
		GuildBankFrameMoneyFrameDepositMoney(MoneyInputFrame_GetCopper(this:GetParent()));
		this:GetParent():GetParent():Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopup2Dialogs["DELETE_ITEM"] = {
	text = TEXT(DELETE_ITEM),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
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
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopup2Dialogs["DELETE_GOOD_ITEM"] = {
	text = TEXT(DELETE_GOOD_ITEM),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
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
	timeout = 0,
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
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName() .. "EditBox"]:SetText("")
	end,
	EditBoxOnEnterPressed = function()
		if (_G[this:GetParent():GetName() .. "Button1"]:IsEnabled() == 1) then
			GuildBank:Send("DestroyItem:" .. GuildBank.cursorItem.tab .. ":" .. GuildBank.cursorItem.slot .. ":0")
			GuildBank:ResetAction()
			this:GetParent():Hide();
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
		this:GetParent():Hide();
		GuildBank:ResetAction()
	end
};
