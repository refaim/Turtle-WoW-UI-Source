local EquipTransmogTooltip = CreateFrame("Frame", "EquipTransmogTooltip", GameTooltip)
local Transmog = {}

local transmogDebug = false

local TransmogConfig = {} -- hax

local strfind = string.find
local tonumber = tonumber
local gsub = string.gsub
local GetItemInfo = GetItemInfo

local function twferror(a)
	DEFAULT_CHAT_FRAME:AddMessage(RED_FONT_COLOR_CODE .. "ERROR: " .. tostring(a) .. ".")
end

local function twfprint(a)
	DEFAULT_CHAT_FRAME:AddMessage(NORMAL_FONT_COLOR_CODE .. tostring(a) .. FONT_COLOR_CODE_CLOSE)
end

local function twfdebug(a)
	if not transmogDebug then
		return
	end
	twfprint("|cff0070de[DEBUG:" .. format("%.3f", GetTime()) .. "]|cffffffff[" .. tostring(a) .. "]")
end

local function wipe(t)
	if type(t) ~= "table" then
		return
	end
	for i = getn(t), 1, -1 do
		table.remove(t, i)
	end
end

local player = UnitName("player")
local _, class = UnitClass("player")
class = string.lower(class)

local _, race = UnitRace("player")
race = string.lower(race)
if race == "scourge" then
	race = "undead"
end

local sex = UnitSex("player") - 1
local prefix = "TW_TRANSMOG"
local fashionCoins = 0
local currentSlot = nil
local currentSlotName = nil
local currentPage = 1
local totalPages = 1
local itemsPerPage = 15
local currentTab = "items"
local currentOutfit = nil
local AvailableTransmogItems = {}
local ItemButtons = {}
-- local NumTransmogs = {}
local TransmogDataFromServer = {}
local TransmogStatusFromServer = {}
local TransmogStatusToServer = {}
local EquippedItems = {}
local EquippedTransmogs = {}
-- local CurrentTransmogsData = {}
-- local AvailableSets = {}
local Selection = {}
local Pages = {}
local changePage = false
local trigger = "TRANSMOG_TRIGGER"

local InventorySlots = {
	["HeadSlot"] = 1,
	["ShoulderSlot"] = 3,
	["ShirtSlot"] = 4,
	["ChestSlot"] = 5,
	["WaistSlot"] = 6,
	["LegsSlot"] = 7,
	["FeetSlot"] = 8,
	["WristSlot"] = 9,
	["HandsSlot"] = 10,
	["BackSlot"] = 15,
	["MainHandSlot"] = 16,
	["SecondaryHandSlot"] = 17,
	["RangedSlot"] = 18,
	["TabardSlot"] = 19,
}

local InventorySlotNames = {
	[1] = HEADSLOT,
	[2] = "",
	[3] = SHOULDERSLOT,
	[4] = SHIRTSLOT,
	[5] = CHESTSLOT,
	[6] = WRISTSLOT,
	[7] = LEGSSLOT,
	[8] = FEETSLOT,
	[9] = WRISTSLOT,
	[10] = HANDSSLOT,
	[11] = "",
	[12] = "",
	[13] = "",
	[14] = "",
	[15] = BACKSLOT,
	[16] = MAINHANDSLOT,
	[17] = SECONDARYHANDSLOT,
	[18] = RANGEDSLOT,
	[19] = TABARDSLOT,
}

local InvTypes = {
	["INVTYPE_HEAD"] = 1,
	["INVTYPE_SHOULDER"] = 3,
	["INVTYPE_CLOAK"] = 16,
	["INVTYPE_BODY"] = 4,
	["INVTYPE_TABARD"] = 19,
	["INVTYPE_CHEST"] = 5,
	["INVTYPE_ROBE"] = 20,
	["INVTYPE_WAIST"] = 6,
	["INVTYPE_LEGS"] = 7,
	["INVTYPE_FEET"] = 8,
	["INVTYPE_WRIST"] = 9,
	["INVTYPE_HAND"] = 10,
	["INVTYPE_WEAPON"] = 13,
	["INVTYPE_WEAPONMAINHAND"] = 21,
	["INVTYPE_2HWEAPON"] = 17,
	["INVTYPE_SHIELD"] = 14,
	["INVTYPE_WEAPONOFFHAND"] = 22,
	["INVTYPE_HOLDABLE"] = 23,
	["INVTYPE_THROWN"] = 25,
	["INVTYPE_RANGED"] = 15,
	["INVTYPE_RANGEDRIGHT"] = 26,
}

local TransmogErrors = {
	["0"] = "no error",
	["1"] = "no dest item",
	["2"] = "bad slot",
	["3"] = "transmog not learned",
	["4"] = "no source item proto",
	["5"] = "source not valid for destination",
	["10"] = "stoi failed",
	["11"] = "no coin"
}

-- server side
local SERVER_SLOT_HEAD = 0
local SERVER_SLOT_SHOULDERS = 2
local SERVER_SLOT_BODY = 3
local SERVER_SLOT_CHEST = 4
local SERVER_SLOT_WAIST = 5
local SERVER_SLOT_LEGS = 6
local SERVER_SLOT_FEET = 7
local SERVER_SLOT_WRISTS = 8
local SERVER_SLOT_HANDS = 9
local SERVER_SLOT_BACK = 14
local SERVER_SLOT_MAINHAND = 15
local SERVER_SLOT_OFFHAND = 16
local SERVER_SLOT_RANGED = 17
local SERVER_SLOT_TABARD = 18

local InvTypeToServerSlot = {
	["INVTYPE_HEAD"] = { SERVER_SLOT_HEAD, "HeadSlot" },
	["INVTYPE_SHOULDER"] = { SERVER_SLOT_SHOULDERS, "ShoulderSlot" },
	["INVTYPE_CLOAK"] = { SERVER_SLOT_BACK, "BackSlot" },
	["INVTYPE_CHEST"] = { SERVER_SLOT_CHEST, "ChestSlot" },
	["INVTYPE_ROBE"] = { SERVER_SLOT_CHEST, "ChestSlot" },
	["INVTYPE_WAIST"] = { SERVER_SLOT_WAIST, "WaistSlot" },
	["INVTYPE_LEGS"] = { SERVER_SLOT_LEGS, "LegsSlot" },
	["INVTYPE_FEET"] = { SERVER_SLOT_FEET, "FeetSlot" },
	["INVTYPE_WRIST"] = { SERVER_SLOT_WRISTS, "WristSlot" },
	["INVTYPE_HAND"] = { SERVER_SLOT_HANDS, "HandsSlot" },
	["INVTYPE_BODY"] = { SERVER_SLOT_BODY, "ShirtSlot" },
	["INVTYPE_TABARD"] = { SERVER_SLOT_TABARD, "TabardSlot" },
	["INVTYPE_WEAPON"] = { SERVER_SLOT_MAINHAND, "MainHandSlot" },
	["INVTYPE_2HWEAPON"] = { SERVER_SLOT_MAINHAND, "MainHandSlot" },
	["INVTYPE_WEAPONMAINHAND"] = { SERVER_SLOT_MAINHAND, "MainHandSlot" },
	["INVTYPE_SHIELD"] = { SERVER_SLOT_OFFHAND, "SecondaryHandSlot" },
	["INVTYPE_WEAPONOFFHAND"] = { SERVER_SLOT_OFFHAND, "SecondaryHandSlot" },
	["INVTYPE_HOLDABLE"] = { SERVER_SLOT_OFFHAND, "SecondaryHandSlot" },
	["INVTYPE_RANGED"] = { SERVER_SLOT_RANGED, "RangedSlot" },
	["INVTYPE_THROWN"] = { SERVER_SLOT_RANGED, "RangedSlot" },
	["INVTYPE_RANGEDRIGHT"] = { SERVER_SLOT_RANGED, "RangedSlot" },
}

function Transmog:SlotIdToServerSlot(slotId)
	local link = GetInventoryItemLink("player", slotId)
	local itemName, _, _, _, _, _, _, invType = GetItemInfo(Transmog:IDFromLink(link) or 0)
	if invType then
		-- offhandslot exception
		if slotId == 17 and invType == "INVTYPE_WEAPON" then
			return SERVER_SLOT_OFFHAND
		end
		return InvTypeToServerSlot[invType][1] or 99
	end
end

function Transmog:FrameFromInvType(invType, clientSlot)
	if clientSlot then
		if clientSlot == 17 and invType == "INVTYPE_WEAPON" then
			return SecondaryHandSlot
		end
	end
	return _G[InvTypeToServerSlot[invType][2]]
end

local Positions = {
    [1] = {
        bloodelf =  { { 10.8,  0,   -3.4, 0.61, }, { 8.8,  0.2, -2.7, 0.61, }, },
        undead =    { { 6.8,   0,   -2.2, 0.61, }, { 7.8, -0.5, -2.7, 0.61, }, },
        orc =       { { 8.8,   0,   -2.7, 0.2,  }, { 9.1,  0,   -2.7, 0.61, }, },
        gnome =     { { 3.8,   0,   -1,   0.61, }, { 3.8,  0,   -1,   0.61, }, },
        dwarf =     { { 6.3,   0,   -1.2, 0.61, }, { 6.3,  0,   -1.7, 0.61, }, },
        tauren =    { { 8.8,  -0.5, -2.2, 0.3,  }, { 8.8, -0.5, -1.7, 0.61, }, },
        nightelf =  { { 11.8,  0,   -3.7, 0.61, }, { 11.8, 0,   -3.2, 0.61, }, },
        human =     { { 8.8,   0,   -3.2, 0.61, }, { 7.5,  0,   -2.7, 0.61, }, },
        troll =     { { 10.8, -0.5, -2.2, 0.3,  }, { 11.1, 0,   -3,   0.61, }, },
        goblin =    { { 5.3,   0,   -1.3, 0.61, }, { 6.3,  0,   -1.0, 0.61, }, },
    },
    [3] = {
        bloodelf =  { { 7.8, 0.5, -2.7, 0.61, }, { 7.8, 0.5, -2.2, 0.61, }, },
        undead =    { { 5.8, 0.5, -1.7, 0.61, }, { 6.8, 0,   -1.7, 0.61, }, },
        orc =       { { 5.3, 0.5, -1.7, 0.61, }, { 6.3, 0.5, -1.7, 0.61, }, },
        gnome =     { { 2.8, 0.5, -0.2, 0.61, }, { 2.8, 0.5, -0.2, 0.61, }, },
        dwarf =     { { 4.8, 0.5, -0.9, 0.61, }, { 4.8, 0.2, -0.9, 0.61, }, },
        tauren =    { { 5.3, 0.5, -2.2, 0.61, }, { 5.8, 0.5, -1.7, 0.61, }, },
        nightelf =  { { 8.8, 0.5, -2.2, 0.61, }, { 8.8, 0.5, -1.7, 0.61, }, },
        human =     { { 5.8, 0.5, -1.7, 0.61, }, { 5.8, 0.5, -1.7, 0.61, }, },
        troll =     { { 7.8, 0.5, -1.7, 0.61, }, { 9.1, 0.5, -1.7, 0.61, }, },
        goblin =    { { 4.3, 0.5, -0.2, 0.61, }, { 4.8, 0.5, -0.2, 0.61, }, },
    },
    [5] = {
        bloodelf =  { { 7.8,  0.1, -1.2, 0.3, }, { 6.8,  0.3, -1.2, 0.3, }, },
        undead =    { { 5.8,  0.1, -1.2, 0.3, }, { 5.8,  0.1, -1.2, 0.3, }, },
        orc =       { { 5.8,  0.1, -1.2, 0.3, }, { 6.8,  0.1, -0.7, 0.3, }, },
        gnome =     { { 3.8,  0.1,  0.6, 0.3, }, { 3.8,  0.1,  0.6, 0.3, }, },
        dwarf =     { { 4.5,  0.1,  0.3, 0.3, }, { 4.5,  0.1,  0.3, 0.3, }, },
        tauren =    { { 5.8, -0.1, -0.2, 0.3, }, { 5.8, -0.1, -0.2, 0.3, }, },
        nightelf =  { { 8.8,  0.1, -1.2, 0.3, }, { 8.8,  0.1, -1.2, 0.3, }, },
        human =     { { 5.8,  0.1, -1.2, 0.3, }, { 5.8,  0.1, -1.2, 0.3, }, },
        troll =     { { 7.8, -0.1, -0.2, 0.3, }, { 7.8, -0.1, -0.2, 0.3, }, },
        goblin =    { { 4.3,  0.1,  0.3, 0.3, }, { 4.8,  0.1,  0.3, 0.3, }, },
    },
    [6] = {
        bloodelf =  { { 10, 0, -0.6, 0.31, }, { 8.3, 0.3, -0.4, 0.31, }, },
        undead =    { { 8,  0, -0.4, 0.31, }, { 8,   0,   -0.4, 0.31, }, },
        orc =       { { 8,  0, -0.4, 0.31, }, { 8,   0,   -0.4, 0.31, }, },
        gnome =     { { 4,  0,  1.1, 0.31, }, { 4,   0,    1.1, 0.31, }, },
        dwarf =     { { 5,  0,  0.6, 0.31, }, { 5,   0,    0.6, 0.31, }, },
        tauren =    { { 9,  0, -0.1, 0.31, }, { 8,   0,    1.6, 0.31, }, },
        nightelf =  { { 10, 0, -0.4, 0.31, }, { 10,  0,   -0.4, 0.31, }, },
        human =     { { 7,  0, -0.4, 0.31, }, { 7,   0,   -0.9, 0.31, }, },
        troll =     { { 10, 0, -0.4, 0.31, }, { 10,  0,   -0.4, 0.31, }, },
        goblin =    { { 6,  0,  1.1, 0.31, }, { 7,   0,    1.1, 0.31, }, },
    },
    [7] = {
        bloodelf =  { { 7.8, 0, 0.6, 0.31, }, { 5.8, 0.3, 0.9, 0.31, }, },
        undead =    { { 5.8, 0, 0.9, 0.31, }, { 7.1, 0,   0.9, 0.31, }, },
        orc =       { { 5.8, 0, 0.9, 0.31, }, { 5.8, 0,   0.9, 0.31, }, },
        gnome =     { { 3.8, 0, 1.1, 0.31, }, { 3.8, 0,   1.1, 0.31, }, },
        dwarf =     { { 4.8, 0, 1.4, 0.31, }, { 4.8, 0,   1.4, 0.31, }, },
        tauren =    { { 6.8, 0, 0.9, 0.31, }, { 5.8, 0,   1.9, 0.31, }, },
        nightelf =  { { 8.8, 0, 0.9, 0.31, }, { 8.8, 0,   0.9, 0.31, }, },
        human =     { { 5.8, 0, 0.9, 0.31, }, { 5.8, 0,   0.9, 0.31, }, },
        troll =     { { 7.8, 0, 0.9, 0.31, }, { 7.8, 0,   1.9, 0.31, }, },
        goblin =    { { 4.9, 0, 1.2, 0.31, }, { 5.3, 0,   0.9, 0.31, }, },
    },
    [8] = {
        bloodelf =  { { 8.8, -0.3,  1.5, 0.3, }, { 6.3,  0.4, 1.7, 0.3, }, },
        undead =    { { 5.8,  0,    1.5, 0.3, }, { 7.1,  0,   1.5, 0.3, }, },
        orc =       { { 5.8,  0,    1.5, 0.3, }, { 5.8,  0,   1.5, 0.3, }, },
        gnome =     { { 4.8,  0,    1.4, 0.3, }, { 4.3,  0.1, 1.4, 0.3, }, },
        dwarf =     { { 4.8,  0,    2.1, 0.3, }, { 5.3, -0.2, 1.9, 0.3, }, },
        tauren =    { { 6.8,  0,    1.5, 0.3, }, { 6.8,  0,   2.5, 0.3, }, },
        nightelf =  { { 8.8,  0,    1.8, 0.3, }, { 8.8,  0,   1.8, 0.3, }, },
        human =     { { 6.8,  0,    1.5, 0.3, }, { 5.8,  0,   1.5, 0.3, }, },
        troll =     { { 7.8,  0,    1.5, 0.3, }, { 8.8,  0,   2.5, 0.3, }, },
        goblin =    { { 4.8, -0.15, 1.8, 1.3, }, { 5.8,  0,   1.7, 0.3, }, },
    },
    [9] = {
        bloodelf =  { { 8.8,  0.4, -0.3, 1.5, }, { 7.3,  0.4, -0.3, 1.5, }, },
        undead =    { { 5.8,  0.4, -0.3, 1.5, }, { 7.1, -0.1, -0.3, 1.5, }, },
        orc =       { { 5.8,  0.4, -0.3, 1.5, }, { 6.3,  0.4, -0.3, 1.5, }, },
        gnome =     { { 4.3,  0.4,  0.7, 1.5, }, { 4.3,  0.4,  0.7, 1.5, }, },
        dwarf =     { { 4.6,  0.1,  0.8, 1.5, }, { 5.2,  0.1,  0.6, 1.5, }, },
        tauren =    { { 5.8,  0.2, -0.3, 1.5, }, { 7.1,  0.2,  1,   1.5, }, },
        nightelf =  { { 10.8, 0.4, -0.3, 1.5, }, { 10.8, 0.4, -0.3, 1.5, }, },
        human =     { { 6.8,  0.4, -0.3, 1.5, }, { 5.8,  0.4, -0.3, 1.5, }, },
        troll =     { { 7.8,  0.4,  0.6, 1.5, }, { 9.8,  0.4,  0.6, 1.5, }, },
        goblin =    { { 4.8,  0.4,  1.0, 1.5, }, { 5.4,  0.4,  1.2, 1.5, }, },
    },
    [15] = {
        bloodelf =  { { 7.8, -0.3, -1,   3.2, }, { 4.8, 0, -0.7, 3.2, }, },
        undead =    { { 4.8, 0,    -1,   3.2, }, { 5.8, 0,  0,   3.2, }, },
        orc =       { { 4.8, 0,    -1,   3.2, }, { 4.8, 0, -0.2, 3.2, }, },
        gnome =     { { 2.8, 0,     0.7, 3.2, }, { 2.8, 0,  0.7, 3.2, }, },
        dwarf =     { { 3.8, 0,     0.5, 3.2, }, { 3.8, 0,  0.5, 3.2, }, },
        tauren =    { { 5.6, 0,     0.2, 3.2, }, { 5.6, 0,  0.2, 3.2, }, },
        nightelf =  { { 7.8, 0,    -1,   3.2, }, { 7.8, 0, -1,   3.2, }, },
        human =     { { 4.8, 0,    -0.5, 3.2, }, { 4.8, 0, -1,   3.2, }, },
        troll =     { { 6.8, 0,    -1,   3.2, }, { 7.8, 0,  0,   3.2, }, },
        goblin =    { { 3.8, 0,     0.5, 3.2, }, { 4.3, 0,  0.5, 3.2, }, },
    },
    [16] = {
        bloodelf =  { { 6.8, 0, 0.4, 0.61, }, { 6.3, 0.2, 0.4, 0.61, }, },
        undead =    { { 3.8, 0, 0.4, 0.61, }, { 3.8, 0, 0.4,   0.61, }, },
        orc =       { { 3.8, 0, 0.4, 0.61, }, { 4.8, 0, 0.4,   0.61, }, },
        gnome =     { { 1.8, 0, 0.4, 0.61, }, { 1.8, 0, 0.4,   0.61, }, },
        dwarf =     { { 2.8, 0, 0.4, 0.61, }, { 2.8, 0, 0.4,   0.61, }, },
        tauren =    { { 3.8, 0, 0.4, 0.61, }, { 3.8, 0, 0.4,   0.61, }, },
        nightelf =  { { 6.8, 0, 0.4, 0.61, }, { 6.8, 0, 0.4,   0.61, }, },
        human =     { { 3.8, 0, 0.4, 0.61, }, { 3.8, 0, 0.4,   0.61, }, },
        troll =     { { 5.8, 0, 1.4, 0.61, }, { 5.8, 0, 0.4,   0.61, }, },
        goblin =    { { 3.3, 0, 0.9, 0.9,  }, { 3.3, 0, 0.4,   0.61, }, },
    },
    [18] = {
        bloodelf =  { { 6.8, 0, 0.4, -0.61, }, { 6.3, 0.2, 0.4, -1,    }, },
        undead =    { { 3.8, 0, 0.4, -0.61, }, { 3.8, 0,   0.4, -0.61, }, },
        orc =       { { 3.8, 0, 0.4, -0.61, }, { 4.8, 0,   0.4, -0.61, }, },
        gnome =     { { 1.8, 0, 0.4, -0.61, }, { 1.8, 0,   0.4, -0.61, }, },
        dwarf =     { { 2.8, 0, 0.4, -0.61, }, { 2.8, 0,   0.4, -0.61, }, },
        tauren =    { { 3.8, 0, 0.4, -0.61, }, { 3.8, 0,   0.4, -0.61, }, },
        nightelf =  { { 6.8, 0, 0.4, -0.61, }, { 6.8, 0,   0.4, -0.61, }, },
        human =     { { 3.8, 0, 0.4, -0.61, }, { 3.8, 0,   0.4, -0.61, }, },
        troll =     { { 5.8, 0, 1.4, -0.61, }, { 5.8, 0,   0.4, -0.61, }, },
        goblin =    { { 3.3, 0, 0.9, -0.61, }, { 3.3, 0,   0.4, -0.61, }, },
    },
}
Positions[4] = Positions[5]
Positions[19] = Positions[5]
Positions[10] = Positions[9]
Positions[17] = Positions[16]

for _, slot in pairs(InventorySlots) do
	AvailableTransmogItems[slot] = {}
	TransmogDataFromServer[slot] = {}
	-- CurrentTransmogsData[slot] = {}
	TransmogStatusFromServer[slot] = 0
	TransmogStatusToServer[slot] = 0
	EquippedItems[slot] = 0
	Selection[slot] = 0
	Pages[slot] = 1
end

function TransmogFrame_OnEvent()
	if event == "GOSSIP_SHOW" then
		if GetGossipText() == trigger then
			if Transmog.delayedLoad:IsVisible() then
				twfdebug("Transmog addon loading retry in 5s.")
			else
				GossipFrame:SetAlpha(0)
				GossipFrame:EnableMouse(nil)
				TransmogFrame:Show()
				UIPanelWindows.GossipFrame.pushable = 99
				local centerFrame = (GetCenterFrame())
				HideUIPanel(centerFrame)
				ShowUIPanel(centerFrame)
			end
		end

	elseif event == "GOSSIP_CLOSED" then
		GossipFrame:SetAlpha(1)
		GossipFrame:EnableMouse(1)
		TransmogFrame:Hide()
		UIPanelWindows.GossipFrame.pushable = 0

	elseif event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then

		twfdebug(event)

		if Transmog:EquippedItemsChanged() then

			twfdebug("equipped items changed")

			if TransmogFrame:IsVisible() then
				twfdebug("visible")
				Transmog.gearChangedDelay.delay = 1
			else
				twfdebug("not visible")
				Transmog.gearChangedDelay.delay = 2
			end
			Transmog:LockPlayerItems()
			Transmog.gearChangedDelay:Show()

		else
			twfdebug("equipped items not changed")
		end

	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == "TW_CHAT_MSG_WHISPER" then
			local message = arg2
			local from = arg4
			if strfind(message, "INSShowTransmogs", 1, true) then
				twfdebug(arg1)
				twfdebug(arg2)
				twfdebug(arg3)
				twfdebug(arg4)
				SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. from .. ">", "INSTransmogs:start", "GUILD")
				for InventorySlotId, itemID in TransmogStatusFromServer do
					if itemID ~= 0 then

						local TransmogItemName = GetItemInfo(itemID)

						if TransmogItemName then
							-- check if we actually have an item equipped
							if GetInventoryItemLink("player", InventorySlotId) then
								local _, _, eqItemLink = strfind(GetInventoryItemLink("player", InventorySlotId), "(item:%d+:%d+:%d+:%d+)")
								local eName = GetItemInfo(eqItemLink)
								SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. from .. ">", "INSTransmogs:" .. eName .. ":" .. TransmogItemName, "GUILD")
							end
						end
					end
				end
				SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. from .. ">", "INSTransmogs:end", "GUILD")
			end

		elseif arg1 == prefix then
			twfdebug(arg1)
			twfdebug(arg2)
			twfdebug(arg3)
			twfdebug(arg4)
			local message = arg2

			if strfind(message, "AvailableTransmogs", 1, true) then
				--AvailableTransmogs:slot:num:id1:id2:id3
				--AvailableTransmogs:slot:num:0
				--AvailableTransmogs:slot:num:end
				local ex = explode(message, ":")

				twfdebug("ex4: [" .. ex[4] .."]")

				local InventorySlotId = tonumber(ex[2])

				if strfind(ex[4], "start", 1, true) then
					wipe(TransmogDataFromServer[InventorySlotId])
				elseif strfind(ex[4], "end", 1, true) then
					Transmog:ShowAvailableTransmogs(InventorySlotId, true)
				else
					for i, itemID in ex do
						if i > 3 then
							itemID = tonumber(itemID)
							if itemID ~= 0 then
								Transmog:CacheItem(itemID)
								table.insert(TransmogDataFromServer[InventorySlotId], itemID)
							end
						end
					end
				end

			elseif strfind(message, "TransmogStatus", 1, true) then

				local data = gsub(message, "TransmogStatus:", "")
				if data then
					local TransmogStatus = explode(data, ",")

					for _, InventorySlotId in InventorySlots do
						TransmogStatusFromServer[InventorySlotId] = 0
						TransmogStatusToServer[InventorySlotId] = 0
					end
					for _, d in TransmogStatus do
						local _, _, InventorySlotId, itemID = strfind(d, "(%d+):(%d+)")
						InventorySlotId = tonumber(InventorySlotId)
						itemID = tonumber(itemID)
						TransmogStatusFromServer[InventorySlotId] = itemID
						TransmogStatusToServer[InventorySlotId] = itemID

						if itemID ~= 0 then
							Transmog:CacheItem(itemID)
						end
					end

					Transmog:TransmogStatus()
				end

			elseif strfind(message, "ResetResult:", 1, true) or strfind(message, "TransmogResult:", 1, true) then
				local _, _, action, serverSlot, InventorySlotId, result = strfind(message, "(%w+)Result:(%d+):(%d+):(%d+)")
				if action and serverSlot and InventorySlotId and result then
					InventorySlotId = tonumber(InventorySlotId)
					action = "Reset" and true or false

					if result == "0" then
						Transmog:AddAnimation(InventorySlotId, action)
					else
						twferror("Error: " .. result .. " (" .. TransmogErrors[result] .. ")")
						Transmog:Reset()
					end
				end

			elseif strfind(message, "NewTransmog", 1, true) then
				local _, _, id = strfind(message, "NewTransmog:(%d+)")
				if strfind(message, "|r") then
					twfdebug("1message: [" .. message .. "] contains r")
				end
				if strfind(message, "|r", 1, true) then
					twfdebug("2message: [" .. message .. "] contains r")
				end
				if id and tonumber(id) then
					twfdebug("new transmog " .. id)
					Transmog:AddWonItem(tonumber(id))
				else
					twfdebug("new transmog not number :[" .. id .. "]")
				end
			end
		end

	elseif event == "VARIABLES_LOADED" then
		if not BattlefieldMinimapOptions.transmog then
			BattlefieldMinimapOptions.transmog = {}
		end
		
		TransmogConfig = BattlefieldMinimapOptions.transmog -- hax
		
		if not TransmogConfig then
			TransmogConfig = {}
		end
		
		if not TransmogConfig[player] then
			TransmogConfig[player] = {}
		end
		
		if not TransmogConfig[player]["Outfits"] then
			TransmogConfig[player]["Outfits"] = {}
		end
		-- cache outfit items
		for _, data in pairs(TransmogConfig[player]["Outfits"]) do
			for _, itemID in pairs(data) do
				Transmog:CacheItem(itemID)
			end
		end
		UIDropDownMenu_Initialize(TransmogFrameOutfits, OutfitsDropDown_Initialize)
	end
end

function Transmog:EquippedItemsChanged()
	for _, InventorySlotId in InventorySlots do
		if GetInventoryItemLink("player", InventorySlotId) then
			local _, _, eqItemLink = strfind(GetInventoryItemLink("player", InventorySlotId), "(item:%d+:%d+:%d+:%d+)")
			if EquippedItems[InventorySlotId] ~= Transmog:IDFromLink(eqItemLink) then
				return true
			end
		elseif EquippedItems[InventorySlotId] ~= 0 then
			return true
		end
	end
	return false
end

function Transmog:CacheEquippedGear()
	for _, InventorySlotId in InventorySlots do
		if GetInventoryItemLink("player", InventorySlotId) then
			Transmog:CacheItem(GetInventoryItemLink("player", InventorySlotId))
		end
	end
end

function Transmog_OnLoad()
	this:RegisterForDrag("LeftButton")
	this:SetMovable(1)
	this:SetUserPlaced(true)
	this:RegisterEvent("GOSSIP_SHOW")
	this:RegisterEvent("GOSSIP_CLOSED")
	this:RegisterEvent("UNIT_INVENTORY_CHANGED")
	this:RegisterEvent("CHAT_MSG_ADDON")
	this:RegisterEvent("VARIABLES_LOADED")

	LoadAddOn("Blizzard_BattlefieldMinimap")

	Transmog:CacheItem(51217) -- Fashion Coin

	TransmogFrameInstructions:SetText(TRANSMOG_INSTRUCTIONS)
	TransmogFrameSetBonus:SetText("")
	TransmogFrameNoTransmogs:SetText(TRANSMOG_NO_MOGS)

	TransmogFrameSaveOutfit:Disable()
	TransmogFrameDeleteOutfit:Hide()
	UIDropDownMenu_SetWidth(123, TransmogFrameOutfits)
	UIDropDownMenu_SetText(TEXT(TRANSMOG_OUTFITS), TransmogFrameOutfits)

	-- pre cache equipped items
	Transmog:CacheEquippedGear()

	Transmog.newTransmogAlert:HideAnchor()

	Transmog.delayedLoad:Show()

	if class == "druid" or class == "shaman" or class == "paladin" then
		RangedSlot:Hide()
		local point, relativeTo, relativePoint, offsetX, offsetY = MainHandSlot:GetPoint()
		MainHandSlot:SetPoint(point, relativeTo, relativePoint, offsetX + 16, offsetY)
	end

	local original_SetInventoryItem = GameTooltip.SetInventoryItem
	function GameTooltip.SetInventoryItem(self, unit, slot)
		GameTooltip.itemLink = GetInventoryItemLink(unit, slot)
		return original_SetInventoryItem(self, unit, slot)
	end

	local original_SetBagItem = GameTooltip.SetBagItem
	function GameTooltip.SetBagItem(self, container, slot)
		GameTooltip.itemLink = GetContainerItemLink(container, slot)
		return original_SetBagItem(self, container, slot)
	end
end

function Transmog:LoadOnce()
	Transmog:Send("GetTransmogStatus")
	-- Transmog:Send("GetSetsStatus:")
end

function TransmogFrame_OnShow()

	Transmog_SwitchTab("items")
	SetPortraitTexture(TransmogFramePortrait, "target")

	Transmog:GetFashionCoins()
	Transmog:Reset()
end

function Transmog_OnHide()
	HideUIPanel(GossipFrame)

	PlaySound("igCharacterInfoClose")
	currentSlotName = nil
	currentSlot = nil
	currentOutfit = nil
	TransmogFrameSaveOutfit:Disable()
	TransmogFrameDeleteOutfit:Hide()
	UIDropDownMenu_SetText(TRANSMOG_OUTFITS, TransmogFrameOutfits)
end

function Transmog:Reset(once)

	if not once then
		Transmog:Send("GetTransmogStatus")
	end

	TransmogFrameRaceBackground:SetTexture("Interface\\TransmogFrame\\transmogbackground" .. race)
	TransmogFrameSplash:Show()
	TransmogFrameInstructions:Show()
	TransmogFrameSetBonus:Show()
	TransmogFrameApplyButton:Disable()

	currentPage = 1

	Transmog:GetFashionCoins()
	TransmogFramePlayerModel:SetPosition(0, 0, 0)
	TransmogFramePlayerModel:SetFacing(0.61)
	TransmogFramePlayerModel:SetUnit("player")
	TransmogFramePlayerModel:SetLight(1, 0, -0.3, -1, -1,   0.55, 1.0, 1.0, 1.0,   0.8, 1.0, 1.0, 1.0)
	local tabardLink = GetInventoryItemLink("player", 19)
	if tabardLink then
		local _, _, tabard = strfind(tabardLink, "item:(%d+)")
		TransmogFramePlayerModel:TryOn(tonumber(tabard))
	end
	Transmog_SwitchTab(currentTab)
	AddButtonOnEnterTextTooltip(TransmogFrameRevert, RESET)

	currentOutfit = nil
	TransmogFrameSaveOutfit:Disable()
	TransmogFrameDeleteOutfit:Hide()
	UIDropDownMenu_SetText(TRANSMOG_OUTFITS, TransmogFrameOutfits)
	Transmog:HidePlayerItemsAnimation()
end

function Transmog:Send(data)
	SendAddonMessage(prefix, data, "GUILD")
	twfdebug("|cff69ccf0send -> " .. data)
end

function Transmog:SetProgressBar(collected, possible)
	if collected > possible then
		collected = possible
	end

	TransmogFrameCollectedBarText:SetText(collected .. "/" .. possible)

	local fillBarWidth = (collected / possible) * TransmogFrameCollected:GetWidth()
	TransmogFrameCollectedBarFillBar:SetPoint("TOPRIGHT", TransmogFrameCollected, "TOPLEFT", fillBarWidth, 0)
	TransmogFrameCollectedBarFillBar:Show()

	TransmogFrameCollectedBar:SetStatusBarColor(0.0, 0.0, 0.0, 0.5)
	TransmogFrameCollectedBarBackground:SetVertexColor(0.0, 0.0, 0.0, 0.5)
	TransmogFrameCollectedBarFillBar:SetVertexColor(0.0, 1.0, 0.0, 0.5)

	TransmogFrameCollectedBar:Show()
end

function Transmog_Search()
	if currentSlot then
		currentPage = 1
		for k in pairs(Pages) do
			Pages[k] = 1
		end
		Transmog:ShowAvailableTransmogs(currentSlot, true)
	end
end

Transmog.availableTransmogsCacheDelay = CreateFrame("Frame")
Transmog.availableTransmogsCacheDelay:Hide()

Transmog.availableTransmogsCacheDelay.InventorySlotId = 0

Transmog.availableTransmogsCacheDelay:SetScript("OnShow", function()
	this.startTime = GetTime()
end)

Transmog.availableTransmogsCacheDelay:SetScript("OnUpdate", function()
	local plus = 0.1
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then

		twfdebug("delay cache: " .. Transmog.availableTransmogsCacheDelay.InventorySlotId)
		Transmog:ShowAvailableTransmogs(Transmog.availableTransmogsCacheDelay.InventorySlotId, true)
		Transmog.availableTransmogsCacheDelay:Hide()
	end
end)

local function CustomSort(a, b)
	-- sort by subType
	if a.itemSubType == b.itemSubType then
		-- equal subType - sort by quality
		if a.quality == b.quality then
			-- equal quality - sort by name
			return a.name < b.name
		else
			return a.quality > b.quality
		end
	else
		return a.itemSubType > b.itemSubType
	end
end

function Transmog:ShowAvailableTransmogs(InventorySlotId, refresh)
	if refresh then
		-- don't do this block if we are simply changing page
		local searchText = trim(TransmogFrameSearch:GetText())
		searchText = searchText ~= SEARCH and searchText or ""

		wipe(AvailableTransmogItems[InventorySlotId])

		for i, itemID in TransmogDataFromServer[InventorySlotId] do
			itemID = tonumber(itemID)

			local name, link, quality, _, itemType, itemSubType, _, equipSlot, texture = GetItemInfo(itemID)
			local _, _, eqItemLink = strfind(GetInventoryItemLink("player", InventorySlotId), "(item:%d+:%d+:%d+:%d+)")

			if not name then
				Transmog:CacheItem(itemID)
				twfdebug("caching item " .. itemID)
				if not Transmog.availableTransmogsCacheDelay:IsShown() then
					Transmog.availableTransmogsCacheDelay.InventorySlotId = InventorySlotId
					Transmog.availableTransmogsCacheDelay:Show()
					return
				end
			end

			if name and strfind(strlower(name), strlower(searchText)) then
				table.insert(AvailableTransmogItems[InventorySlotId], {
					["id"] = itemID,
					["reset"] = itemID == Transmog:IDFromLink(eqItemLink),
					["name"] = name,
					["link"] = link,
					["quality"] = quality,
					["equipSlot"] = equipSlot,
					["tex"] = texture,
					["itemLink"] = eqItemLink,
					["itemSubType"] = itemSubType,
				})
			end
		end
		table.sort(AvailableTransmogItems[InventorySlotId], CustomSort)
	end

	local numItems = sizeof(AvailableTransmogItems[InventorySlotId])
	totalPages = ceil(numItems / itemsPerPage)
	TransmogFramePageText:SetText(TEXT(GENERIC_PAGE) .. " " .. currentPage .. "/" .. totalPages)

	if currentPage == 1 then
		TransmogFrameLeftArrow:Disable()
	else
		TransmogFrameLeftArrow:Enable()
	end

	if currentPage == totalPages or numItems < itemsPerPage then
		TransmogFrameRightArrow:Disable()
	else
		TransmogFrameRightArrow:Enable()
	end

	if totalPages > 1 then
		Transmog:ShowPagination()
	else
		Transmog:HidePagination()
	end

	if currentSlotName then
		_G[currentSlotName .. "BorderSelected"]:Show()
	end

	if changePage then
		-- skip drawing previews if we need to change page
		changePage = false
		Transmog_ChangePage(Pages[InventorySlotId] - 1)
		return
	end

	-- Transmog:SetProgressBar(tsize(TransmogDataFromServer[InventorySlotId]), NumTransmogs[InventorySlotId])
	if sizeof(TransmogDataFromServer[InventorySlotId]) == 0 then
		TransmogFrameNoTransmogs:Show()
	end

	if refresh or currentPage == totalPages then
		-- hide all item buttons
		Transmog:HideItems()
	end
	Transmog:HideItemBorders()

	local index = 0
	local row = 0
	local col = 0
	local itemIndex = 1
	local lowerLimit = (currentPage - 1) * itemsPerPage
	local upperLimit = currentPage * itemsPerPage
	local item, button, revert, check, model

	for i = 1, getn(AvailableTransmogItems[InventorySlotId]) do
		item = AvailableTransmogItems[InventorySlotId][i]
		if index >= lowerLimit and index < upperLimit then

			if not ItemButtons[itemIndex] then
				ItemButtons[itemIndex] = CreateFrame("Frame", "TransmogLook" .. itemIndex, TransmogFrame, "TransmogFrameLookTemplate")
				ItemButtons[itemIndex]:SetPoint("TOPLEFT", TransmogFrame, "TOPLEFT", 263 + col * 90, -105 - 120 * row)
				_G["TransmogLook" .. itemIndex .. "ItemModel"]:SetLight(1, 0, -0.3,  0, -1,   0.65, 1.0, 1.0, 1.0,   0.8, 1.0, 1.0, 1.0)
			end

			ItemButtons[itemIndex].name = item.name
			ItemButtons[itemIndex].id = item.id

			button = _G["TransmogLook" .. itemIndex .. "Button"]
			revert = _G["TransmogLook" .. itemIndex .. "ButtonRevert"]
			check = _G["TransmogLook" .. itemIndex .. "ButtonCheck"]
			model = _G["TransmogLook" .. itemIndex .. "ItemModel"]

			button:SetID(item.id)
			revert:Hide()
			check:Hide()

			-- highlight selected item
			if item.id == Selection[InventorySlotId] then
				button:SetNormalTexture("Interface\\TransmogFrame\\item_bg_selected")
			end

			local _, _, _, color = GetItemQualityColor(item.quality)
			AddButtonOnEnterTextTooltip(button, color .. item.name)
			if item.reset then
				revert:Show()
			end

			-- refresh tooltip
			if GetMouseFocus() == button then
				ItemButtons[itemIndex]:Hide()
			end
			ItemButtons[itemIndex]:Show()

			local z = Positions[InventorySlotId][race][sex][1]
			local x = Positions[InventorySlotId][race][sex][2]
			local y = Positions[InventorySlotId][race][sex][3]
			local f = Positions[InventorySlotId][race][sex][4]
			model:SetPosition(0, 0, 0)
			model:SetUnit("player")
			model:Undress()
			model:SetPosition(z, x, y)
			model:SetFacing(f)
			-- oh / ranged
			if InventorySlotId == 16 or InventorySlotId == 17 or InventorySlotId == 18 then
				local _, _, _, _, _, _, _, loc  = GetItemInfo(item.id)
				if loc == "INVTYPE_RANGED" or loc == "INVTYPE_WEAPONOFFHAND" or loc == "INVTYPE_HOLDABLE" then
					model:SetFacing(-0.61)
					if race == "bloodelf" then
						if sex == 2 then
							model:SetFacing(-1)
						end
					end
				else
					model:SetFacing(0.61)
					if race == "goblin" then
						if sex == 1 then
							model:SetFacing(0.9)
						end
					end
				end
				-- shield
				if loc == "INVTYPE_SHIELD" then
					model:SetFacing(-1.5)
					if race == "undead" then
						if sex == 2 then
							model:SetFacing(-1)
							z = z + 2
							y = y - 0.5
						end
					end
					if race == "goblin" then
						if sex == 2 then
							x = x - 0.3
						end
						z = z + 0.2
					end
					if race == "orc" then
						if sex == 2 then
							x = x - 0.8
						end
					end
					if race == "nightelf" then
						x = x - 0.3
						y = y - 1
					end
					if race == "bloodelf" then
						y = y - 1
					end
					model:SetPosition(z, x, y)
				end
			end

			model:TryOn(item.id)

			col = col + 1
			if col == 5 then
				row = row + 1
				col = 0
			end

			itemIndex = itemIndex + 1

		end
		index = index + 1
	end
end

function Transmog:TransmogStatus()
	-- cache data
	for InventorySlotId, itemID in TransmogStatusFromServer do
		if itemID ~= 0 then

			local TransmogItemName = GetItemInfo(itemID)

			if TransmogItemName then
				-- check if we actually have an item equipped
				if GetInventoryItemLink("player", InventorySlotId) then
					local _, _, eqItemLink = strfind(GetInventoryItemLink("player", InventorySlotId), "(item:%d+:%d+:%d+:%d+)")
					local eName = GetItemInfo(eqItemLink)
					EquippedTransmogs[eName] = TransmogItemName
				end
			else
				Transmog:CacheItem(itemID)
			end
		end
	end

	-- add paperdoll textures
	for slotName, InventorySlotId in InventorySlots do
		local frame = _G[slotName]
		if frame then

			local texture
			local tex = gsub(slotName, "Slot", "")
			texture = string.lower(tex)

			if texture == "wrist" then
				texture = texture .. "s"
			end
			if texture == "back" then
				texture = "chest"
			end

			_G[slotName .. "ItemIcon"]:SetTexture("Interface\\Paperdoll\\ui-paperdoll-slot-" .. texture)
			_G[slotName .. "NoEquip"]:Show()
			_G[slotName .. "BorderHi"]:Hide()

			AddButtonOnEnterTextTooltip(frame, InventorySlotNames[InventorySlotId], TEXT(TRANSMOG_NO_ITEM), true)
		end
	end

	-- add item textures
	for slotName, InventorySlotId in InventorySlots do
		EquippedItems[InventorySlotId] = 0
		Selection[InventorySlotId] = 0
		if GetInventoryItemLink("player", InventorySlotId) then

			local _, _, eqItemLink = strfind(GetInventoryItemLink("player", InventorySlotId), "(item:%d+:%d+:%d+:%d+)")
			local itemName, _, _, _, _, _, _, _, tex = GetItemInfo(eqItemLink)

			EquippedItems[InventorySlotId] = Transmog:IDFromLink(eqItemLink)
			
			local frame = _G[slotName]
			
			if frame and frame:IsShown() then
				Selection[InventorySlotId] = EquippedItems[InventorySlotId]
				frame:Enable()
				frame:SetID(InventorySlotId)

				_G[slotName .. "AutoCast"]:Hide()
				_G[slotName .. "AutoCast"]:SetModel("Interface\\Buttons\\UI-AutoCastButton.mdx")
				_G[slotName .. "AutoCast"]:SetAlpha(0.3)
				_G[slotName .. "NoEquip"]:Hide()
				_G[slotName .. "Revert"]:Hide()

				if TransmogStatusFromServer[InventorySlotId] and TransmogStatusFromServer[InventorySlotId] ~= 0 then
					Selection[InventorySlotId] = TransmogStatusFromServer[InventorySlotId]
					_G[slotName .. "BorderHi"]:Show()
					AddButtonOnEnterTooltipFashion(frame, eqItemLink, EquippedTransmogs[itemName], true)

					local _, _, _, _, _, _, _, _, TransmogTex = GetItemInfo(TransmogStatusFromServer[InventorySlotId])

					_G[slotName .. "ItemIcon"]:SetTexture(TransmogTex)
					-- _G[slotName .. "Revert"]:Show()
				else
					_G[slotName .. "BorderHi"]:Hide()
					AddButtonOnEnterTooltipFashion(frame, eqItemLink)
					_G[slotName .. "ItemIcon"]:SetTexture(tex)
				end
			end
		end
	end

	Transmog:CalculateCost()
end

function Transmog_ApplyOnClick()

	local actionIndex = 0

	TransmogFrameApplyButton:Disable()

	Transmog.applyTimer.actions = {}

	for InventorySlotId, itemID in TransmogStatusToServer do

		if TransmogStatusFromServer[InventorySlotId] ~= itemID then

			actionIndex = actionIndex + 1
			local action
			if itemID == 0 then
				action = "reset"
			else
				action = "do"
			end
			Transmog.applyTimer.actions[actionIndex] = {
				["type"] = action,
				["serverSlot"] = Transmog:SlotIdToServerSlot(InventorySlotId),
				["itemId"] = itemID,
				["InventorySlotId"] = InventorySlotId,
				["sent"] = false
			}
		end
	end
	Transmog.itemAnimationFrames = {}
	Transmog.applyTimer:Show()

	PlaySoundFile("Interface\\TransmogFrame\\ui_transmogrify_apply.ogg")

end

function Transmog:AddAnimation(id, reset)
	for slotName, InventorySlotId in InventorySlots do
		if id == InventorySlotId then
			local frame = _G[slotName]
			if frame then
				Transmog.itemAnimationFrames[sizeof(Transmog.itemAnimationFrames) + 1] = {
					["frame"] = frame,
					["borderHi"] = _G[slotName .. "BorderHi"],
					["borderFull"] = _G[slotName .. "BorderFull"],
					["autocast"] = _G[slotName .. "AutoCast"],
					["reset"] = reset,
					["dir"] = 1
				}
				break
			end
		end
	end

	if sizeof(Transmog.itemAnimationFrames) == sizeof(Transmog.applyTimer.actions) then
		Transmog.itemAnimation:Show()
	end
end

function Transmog:UpdateSelection()
	if not currentSlot then
		return
	end
	for i, data in ItemButtons do
		local button = _G["TransmogLook" .. i .. "Button"]
		button:SetNormalTexture("Interface\\TransmogFrame\\item_bg_normal")
		if (currentTab == "items" and data.id == Selection[currentSlot]) or (currentTab == "sets" and data.name == currentOutfit) then
			button:SetNormalTexture("Interface\\TransmogFrame\\item_bg_selected")
		end
	end
end

function Transmog_Try(itemId, slotName, newReset)
	local frame = _G[slotName]
	if newReset and _G[slotName .. "NoEquip"]:IsVisible() then
		return false
	end

	if currentTab == "sets" and not newReset then

		TransmogFramePlayerModel:SetUnit("player")
		local tabardLink = GetInventoryItemLink("player", 19)
		if tabardLink then
			local _, _, tabard = strfind(tabardLink, "item:(%d+)")
			TransmogFramePlayerModel:TryOn(tonumber(tabard))
		end
		Transmog:GetFashionCoins()
		Transmog:TransmogStatus()

		for InventorySlotId, data in TransmogStatusFromServer do
			TransmogStatusToServer[InventorySlotId] = data
		end

		Transmog_LoadOutfit(ItemButtons[itemId].name)

		Transmog:HideItemBorders()
		frame:SetNormalTexture("Interface\\TransmogFrame\\item_bg_selected")

		return true
	end

	if newReset then
		local InventorySlotId = InventorySlots[slotName]
		local equippedItemLink = GetInventoryItemLink("player", InventorySlotId)
		local equippedItemID = Transmog:IDFromLink(equippedItemLink)
		local equippedItemName = (GetItemInfo(equippedItemID))
		-- change back to current transmog if this is second right-click on the same slot
		if TransmogStatusToServer[InventorySlotId] == 0 and TransmogStatusFromServer[InventorySlotId] ~= 0 then
			local transmogItemID = TransmogStatusFromServer[InventorySlotId]
			local transmogItemName = (GetItemInfo(transmogItemID))
			local _, _, _, _, _, _, _, _, tex = GetItemInfo(transmogItemID)

			TransmogStatusToServer[InventorySlotId] = transmogItemID
			Selection[InventorySlotId] = transmogItemID
			EquippedTransmogs[equippedItemName] = transmogItemName
			TransmogFramePlayerModel:TryOn(transmogItemID)
			AddButtonOnEnterTooltipFashion(frame, equippedItemID, transmogItemName, true)
			_G[slotName .. "ItemIcon"]:SetTexture(tex)
			_G[slotName .. "BorderHi"]:Show()
			_G[slotName .. "AutoCast"]:Hide()
			_G[slotName .. "Revert"]:Hide()
			Transmog:CalculateCost()
			Transmog:EnableOutfitSaveButton()
			Transmog:UpdateSelection()
			return
		end
		
		itemId = Transmog:IDFromLink(equippedItemLink)
		TransmogStatusToServer[InventorySlotId] = 0

		_G[slotName .. "BorderHi"]:Hide()
		_G[slotName .. "AutoCast"]:Hide()
		_G[slotName .. "Revert"]:Hide()

		if TransmogStatusFromServer[InventorySlotId] ~= TransmogStatusToServer[InventorySlotId] then
			_G[slotName .. "AutoCast"]:Show()
			_G[slotName .. "Revert"]:Show()
		end

		TransmogFramePlayerModel:TryOn(itemId)
		Selection[InventorySlotId] = itemId
		Transmog:UpdateSelection()

		local _, _, _, _, _, _, _, _, tex = GetItemInfo(itemId)

		_G[slotName .. "ItemIcon"]:SetTexture(tex)

		AddButtonOnEnterTooltipFashion(frame, equippedItemLink)

		local _, _, eqItemLink = strfind(equippedItemLink, "(item:%d+:%d+:%d+:%d+)")
		local eName = GetItemInfo(eqItemLink)

		EquippedTransmogs[eName] = nil

		Transmog:CalculateCost()
		Transmog:EnableOutfitSaveButton()
		return true
	end

	if itemId == Transmog:IDFromLink(GetInventoryItemLink("player", currentSlot)) then
		_G[currentSlotName .. "BorderHi"]:Hide()
		TransmogStatusToServer[currentSlot] = 0
	else
		_G[currentSlotName .. "BorderHi"]:Show()
		TransmogStatusToServer[currentSlot] = itemId
	end

	_G[currentSlotName .. "AutoCast"]:Hide()
	_G[currentSlotName .. "Revert"]:Hide()

	if TransmogStatusFromServer[currentSlot] ~= TransmogStatusToServer[currentSlot] then
		_G[currentSlotName .. "AutoCast"]:Show()
		if TransmogStatusToServer[currentSlot] == 0 then
			_G[currentSlotName .. "Revert"]:Show()
		end
	end

	if slotName == "SecondaryHandSlot" then
		TransmogFramePlayerModel:TryOn(EquippedItems[InventorySlots["MainHandSlot"]])
	end

	TransmogFramePlayerModel:TryOn(itemId)
	Selection[InventorySlots[currentSlotName]] = itemId
	Transmog:UpdateSelection()

	local itemName, itemLink, itemRarity, _, t1, t2, _, itemSlot, tex = GetItemInfo(itemId)

	_G[currentSlotName .. "ItemIcon"]:SetTexture(tex)

	Transmog:CalculateCost()

	Transmog:EnableOutfitSaveButton()

end

function Transmog:IDFromLink(link)
	if tonumber(link) then
		return tonumber(link)
	end
	local _, _, id = strfind(link or "", "item:(%d+)")
	if id then
		return tonumber(id)
	end
end

function Transmog:GetFashionCoins()

	local name, linkString, _, _, _, _, _, _, tex = GetItemInfo(51217)
	if not name then
		return
	end
	local _, _, itemLink = strfind(linkString, "(item:%d+:%d+:%d+:%d+)")

	if not name then
		twferror("fashion coin not cached")
		return
	end
		
	fashionCoins = 0

	for bag = 0, 4 do
		for slot = 0, GetContainerNumSlots(bag) do

			local item = GetContainerItemLink(bag, slot)

			if item then
				local _, itemCount = GetContainerItemInfo(bag, slot)
				if strfind(item, "item:51217:", 1, true) then
					fashionCoins = fashionCoins + tonumber(itemCount)
				end
			end
		end
	end
	TransmogFrameCurrencyText:SetText(fashionCoins)
end

function Transmog:HidePagination()
	TransmogFrameLeftArrow:Hide()
	TransmogFrameRightArrow:Hide()
	TransmogFramePageText:Hide()
end

function Transmog:ShowPagination()
	TransmogFrameLeftArrow:Show()
	TransmogFrameRightArrow:Show()
	TransmogFramePageText:Show()
end

function Transmog:HideItems()
	for index in pairs(ItemButtons) do
		_G["TransmogLook" .. index]:Hide()
	end
end

function Transmog:HideItemBorders()
	for index in pairs(ItemButtons) do
		_G["TransmogLook" .. index .. "Button"]:SetNormalTexture("Interface\\TransmogFrame\\item_bg_normal")
	end
end

function Transmog:CalculateCost(to)

	Transmog:GetFashionCoins()

	local cost = 0
	local resets = 0

	for InventorySlotId, data in TransmogStatusFromServer do
		if data ~= TransmogStatusToServer[InventorySlotId] then
			if TransmogStatusToServer[InventorySlotId] ~= 0 then
				cost = cost + 1
			else
				resets = resets + 1
			end
		end
	end

	if to == 0 then
		cost = 0
		resets = 0
	end

	if cost == 0 then

		if resets > 0 then
			TransmogFrameApplyButton:Enable()
			TransmogFrameApplyButton:SetText(TRANSMOG_APPLY_RESET)
		else
			TransmogFrameApplyButton:Disable()
			TransmogFrameApplyButton:SetText(GENERIC_APPLY)
		end

	else
		if fashionCoins >= cost then
			TransmogFrameApplyButton:Enable()
			TransmogFrameApplyButton:SetText(GENERIC_APPLY)
			TransmogFrameCurrencyText:SetText(fashionCoins .. " |cffff8888(-" .. cost .. ")")
		else
			TransmogFrameApplyButton:Disable()
			TransmogFrameApplyButton:SetText(TRANSMOG_INSUFICCIENT_COINS)
		end
	end
end

function Transmog:HidePlayerItemsAnimation()
	for slot in pairs(InventorySlots) do
		_G[slot.."AutoCast"]:Hide()
		_G[slot.."Revert"]:Hide()
	end
end

function Transmog:HidePlayerItemsBorders()
	for slot in pairs(InventorySlots) do
		_G[slot.."BorderSelected"]:Hide()
	end
end

function Transmog:LockPlayerItems()
	for slot in pairs(InventorySlots) do
		SetDesaturation(_G[slot .. "ItemIcon"], 1)
	end
end

function Transmog_SelectSlot(InventorySlotId, slotName)
	TransmogFrameNoTransmogs:Hide()

	if InventorySlotId == -1 then
		Transmog:HidePlayerItemsBorders()
		-- Transmog:HidePlayerItemsAnimation()
		Transmog:HideItems()
		Transmog:HideItemBorders()
		Transmog:HidePagination()
		TransmogFrameSplash:Show()
		TransmogFrameInstructions:Show()
		TransmogFrameSetBonus:Show()
		TransmogFrameCollectedBar:Hide()
		currentSlotName = nil
		currentSlot = nil
		return true
	end

	if _G[slotName .. "NoEquip"]:IsVisible() then
		return false
	end

	TransmogFrameSplash:Hide()
	TransmogFrameInstructions:Hide()
	TransmogFrameSetBonus:Hide()

	currentPage = 1
	currentSlotName = slotName
	currentSlot = InventorySlotId

	if currentTab == "sets" then
		Transmog_SwitchTab("items")
		return
	end

	if not GetInventoryItemLink("player", currentSlot) then
		Transmog_SelectSlot(-1)
		return
	end

	local _, _, eqItemLink = strfind(GetInventoryItemLink("player", currentSlot), "(item:%d+:%d+:%d+:%d+)")
	local itemName, _, _, _, _, subClass, _, invType = GetItemInfo(eqItemLink)
	local eqItemId = Transmog:IDFromLink(eqItemLink)

	Transmog:HideItems()
	Transmog:HidePlayerItemsBorders()
	changePage = true
	Transmog:Send("GetAvailableTransmogsItemIDs:" .. InventorySlotId .. ":" .. InvTypes[invType] .. ":" .. eqItemId)
end

function TransmogModel_OnLoad()
	this:SetFacing(0.61)

	this:SetScript("OnMouseUp", function()
		this:SetScript("OnUpdate", nil)
	end)

	this:SetScript("OnMouseWheel", function()
		local Z, X, Y = this:GetPosition()
		Z = (arg1 > 0 and Z + 1 or Z - 1)

		this:SetPosition(Z, X, Y)
	end)

	this:SetScript("OnMouseDown", function()
		local StartX, StartY = GetCursorPosition()

		local EndX, EndY, Z, X, Y
		if arg1 == "LeftButton" then
			this:SetScript("OnUpdate", function()
				EndX, EndY = GetCursorPosition()

				this:SetFacing((EndX - StartX) / 34 + this:GetFacing())

				StartX, StartY = GetCursorPosition()
			end)
		elseif arg1 == "RightButton" then
			this:SetScript("OnUpdate", function()
				EndX, EndY = GetCursorPosition()

				Z, X, Y = this:GetPosition(Z, X, Y)
				X = (EndX - StartX) / 45 + X
				Y = (EndY - StartY) / 45 + Y

				this:SetPosition(Z, X, Y)
				StartX, StartY = GetCursorPosition()
			end)
		end
	end)
end

function AddButtonOnEnterTextTooltip(frame, text, ext, error, anchor, x, y)
	frame:SetScript("OnEnter", function()
		if anchor and x and y then
			FashionTooltip:SetOwner(this, anchor, x, y)
		else
			FashionTooltip:SetOwner(this, "ANCHOR_RIGHT", -(this:GetWidth() / 4) + 15, -(this:GetHeight() / 4) + 20)
		end

		if error then
			FashionTooltip:AddLine(FONT_COLOR_CODE_CLOSE .. text)
			FashionTooltip:AddLine("|cffff2020" .. ext)
		else
			FashionTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE .. text)
			if ext then
				FashionTooltip:AddLine(FONT_COLOR_CODE_CLOSE .. ext)
			end
		end
		FashionTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		FashionTooltip:Hide()
	end)
end

function AddButtonOnEnterTooltipFashion(frame, itemLink, TransmogText, revert)
	frame:SetScript("OnEnter", function()
		FashionTooltip:SetOwner(this, "ANCHOR_RIGHT", -(this:GetWidth() / 4) + 10, -(this:GetHeight() / 4))
		local id = Transmog:IDFromLink(itemLink)
		local itemName, itemString, quality = GetItemInfo(id)
		local r, g, b = GetItemQualityColor(quality or 1)
		FashionTooltip:SetText(itemName, r, g, b, 1, false)
		if TransmogText then
			FashionTooltip:AddLine(TRANSMOG_CHANGED_TO, 0.96, 0.44, 0.96, false)
			FashionTooltip:AddLine(TransmogText, 0.96, 0.44, 0.96, false)
			if revert then
				FashionTooltip:AddLine(TRANSMOG_REVERT)
			end
		end
		FashionTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		FashionTooltip:Hide()
	end)
end

function Transmog_ChangePage(dir)
	if (currentPage + dir < 1) or (currentPage + dir > totalPages) then
		return
	end
	currentPage = currentPage + dir
	if currentTab == "items" then
		Transmog:ShowAvailableTransmogs(currentSlot)
		Pages[currentSlot] = currentPage
	else
		Transmog:ShowSets()
	end
end

function Transmog_Revert()
	Transmog:Reset()
	Transmog:CalculateCost(0)
end

function Transmog_SwitchTab(to)

	currentTab = to
	if to == "items" then
		TransmogFrameItemsButton:SetNormalTexture("Interface\\TransmogFrame\\tab_active")
		TransmogFrameItemsButton:SetPushedTexture("Interface\\TransmogFrame\\tab_active")
		TransmogFrameItemsButtonText:SetText(HIGHLIGHT_FONT_COLOR_CODE .. TRANSMOG_ITEMS)

		TransmogFrameSetsButton:SetNormalTexture("Interface\\TransmogFrame\\tab_inactive")
		TransmogFrameSetsButton:SetPushedTexture("Interface\\TransmogFrame\\tab_inactive")
		TransmogFrameSetsButtonText:SetText(TRANSMOG_OUTFITS)

		if currentSlot ~= nil then
			Transmog_SelectSlot(currentSlot, currentSlotName)
		else
			Transmog_SelectSlot(-1)
		end

	elseif to == "sets" then
		-- Transmog:Send("GetSetsStatus:")
		Transmog_SelectSlot(-1)

		TransmogFrameSplash:Hide()
		TransmogFrameInstructions:Hide()
		TransmogFrameSetBonus:Hide()

		TransmogFrameSetsButton:SetNormalTexture("Interface\\TransmogFrame\\tab_active")
		TransmogFrameSetsButton:SetPushedTexture("Interface\\TransmogFrame\\tab_active")
		TransmogFrameSetsButtonText:SetText(HIGHLIGHT_FONT_COLOR_CODE .. TRANSMOG_OUTFITS)

		TransmogFrameItemsButton:SetNormalTexture("Interface\\TransmogFrame\\tab_inactive")
		TransmogFrameItemsButton:SetPushedTexture("Interface\\TransmogFrame\\tab_inactive")
		TransmogFrameItemsButtonText:SetText(TRANSMOG_ITEMS)
		currentPage = 1
		Transmog:ShowSets()
	end
end

function Transmog:ShowSets()
	if currentPage == totalPages then
		Transmog:HideItems()
	end
	Transmog:HideItemBorders()

	local index = 0
	local row = 0
	local col = 0
	local setIndex = 1
	local lowerLimit = (currentPage - 1) * itemsPerPage
	local upperLimit = currentPage * itemsPerPage
	local button, revert, check, model

	for setName, data in pairs(TransmogConfig[player].Outfits) do

		if index >= lowerLimit and index < upperLimit then

			if not ItemButtons[setIndex] then
				ItemButtons[setIndex] = CreateFrame("Frame", "TransmogLook" .. setIndex, TransmogFrame, "TransmogFrameLookTemplate")
				_G["TransmogLook" .. setIndex .. "ItemModel"]:SetLight(1, 0, -0.3,  0, -1,   0.65, 1.0, 1.0, 1.0,   0.8, 1.0, 1.0, 1.0)
			end

			ItemButtons[setIndex]:SetPoint("TOPLEFT", TransmogFrame, "TOPLEFT", 263 + col * 90, -105 - 120 * row)

			ItemButtons[setIndex].name = setName

			button = _G["TransmogLook" .. setIndex .. "Button"]
			revert = _G["TransmogLook" .. setIndex .. "ButtonRevert"]
			check = _G["TransmogLook" .. setIndex .. "ButtonCheck"]
			model = _G["TransmogLook" .. setIndex .. "ItemModel"]
			model = _G["TransmogLook" .. setIndex .. "ItemModel"]

			button:SetID(setIndex)
			revert:Hide()
			check:Hide()

			if GetMouseFocus() == button then
				ItemButtons[setIndex]:Hide()
			end
			ItemButtons[setIndex]:Show()

			model:SetPosition(0, 0, 0)
			model:SetUnit("player")
			model:Undress()
			model:SetPosition(1.5, 0, 0)
			model:SetFacing(0.61)

			local setItemsText = ""
			for slot, slotName in ipairs(InventorySlotNames) do
				local itemID = data[slot]
				if itemID then
					local setItemName, link, quality = GetItemInfo(itemID)
					local _, _, _, color = GetItemQualityColor(quality or 1)
					if setItemName then
						setItemsText = setItemsText .. slotName .. ": " .. color .. setItemName .. FONT_COLOR_CODE_CLOSE .. "\n"
					end
					if slot ~= 16 and slot ~= 17 and slot ~= 18 then
						model:TryOn(itemID)
					end
				end
			end
			model:TryOn(data[18])
			model:TryOn(data[16])
			model:TryOn(data[17])

			AddButtonOnEnterTextTooltip(button, setName, setItemsText)

			col = col + 1
			if col == 5 then
				row = row + 1
				col = 0
			end

			setIndex = setIndex + 1

		end
		index = index + 1
	end

	totalPages = ceil(sizeof(TransmogConfig[player].Outfits) / itemsPerPage)
	TransmogFramePageText:SetText(GENERIC_PAGE .. " " .. currentPage .. "/" .. totalPages)

	if currentPage == 1 then
		TransmogFrameLeftArrow:Disable()
	else
		TransmogFrameLeftArrow:Enable()
	end

	if currentPage == totalPages or sizeof(TransmogConfig[player].Outfits) < itemsPerPage then
		TransmogFrameRightArrow:Disable()
	else
		TransmogFrameRightArrow:Enable()
	end

	if totalPages > 1 then
		Transmog:ShowPagination()
	else
		Transmog:HidePagination()
	end

	-- Transmog:SetProgressBar(completedSets, tsize(AvailableSets))
end

local CharacterPaperDollFrames = {
	CharacterHeadSlot,
	CharacterShoulderSlot,
	CharacterBackSlot,
	CharacterChestSlot,
	CharacterWristSlot,
	CharacterHandsSlot,
	CharacterWaistSlot,
	CharacterLegsSlot,
	CharacterFeetSlot,
	CharacterMainHandSlot,
	CharacterSecondaryHandSlot,
	CharacterRangedSlot,
	CharacterShirtSlot,
	CharacterTabardSlot,
}

-- self
EquipTransmogTooltip:SetScript("OnShow", function()
	if GameTooltip.itemLink then

		if not PaperDollFrame:IsVisible() then
			return
		end

		local _, _, itemLink = strfind(GameTooltip.itemLink, "(item:%d+:%d+:%d+:%d+)")

		if not itemLink then
			return
		end

		for _, frame in next, CharacterPaperDollFrames do
			if GameTooltip:IsOwned(frame) == 1 then

				local itemName = GetItemInfo(itemLink)

				if EquippedTransmogs[itemName] then

					local tLabel = _G[GameTooltip:GetName() .. "TextLeft2"]

					if tLabel then
						tLabel:SetText("|cfff471f5" .. TRANSMOG_CHANGED_TO .. "\n" .. EquippedTransmogs[itemName] .. "\n|cffffffff" .. tLabel:GetText())
					end

					GameTooltip:Show()
					break
				end

			end

		end

	end
end)

EquipTransmogTooltip:SetScript("OnHide", function()
	GameTooltip.itemLink = nil
end)

-- Apply Timer
Transmog.applyTimer = CreateFrame("Frame")
Transmog.applyTimer:Hide()

Transmog.applyTimer:SetScript("OnShow", function()
	this.startTime = GetTime()
	Transmog.applyTimer.actionIndex = 0
end)
Transmog.applyTimer:SetScript("OnHide", function()
end)

Transmog.applyTimer.actions = {}
Transmog.applyTimer.actionIndex = 0

Transmog.applyTimer:SetScript("OnUpdate", function()
	local plus = 0.1
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then

		Transmog.applyTimer.actionIndex = Transmog.applyTimer.actionIndex + 1

		local action = Transmog.applyTimer.actions[Transmog.applyTimer.actionIndex]

		if action then
			if action.type == "do" then
				Transmog:Send("DoTransmog:" .. action.serverSlot .. ":" .. action.itemId .. ":" .. action.InventorySlotId)
				action.sent = true
			else
				if action.type == "reset" then
					Transmog:Send("ResetTransmog:" .. action.serverSlot .. ":" .. action.InventorySlotId)
					action.sent = true
				end
			end
		end

		local allDone = true
		for _, action in Transmog.applyTimer.actions do
			if not action.sent then
				allDone = false
			end
		end
		if allDone then
			Transmog.applyTimer:Hide()
		end
		this.startTime = GetTime()
	end
end)

-- DoTransmog/ResetTransmog Animation
Transmog.itemAnimation = CreateFrame("Frame")
Transmog.itemAnimation:Hide()

Transmog.itemAnimation:SetScript("OnShow", function()
	this.startTime = GetTime()
	for _, frame in Transmog.itemAnimationFrames do
		frame.autocast:Hide()
		if frame.reset then
			frame.borderFull:Show()
			frame.borderFull:SetAlpha(.9)
			frame.borderHi:Show()
			frame.borderHi:SetWidth(48)
			frame.borderHi:SetHeight(48)
		else
			frame.borderFull:Show()
			frame.borderFull:SetAlpha(.2)
			frame.borderHi:Show()
			frame.borderHi:SetWidth(32)
			frame.borderHi:SetHeight(32)
		end
	end
end)
Transmog.itemAnimation:SetScript("OnHide", function()
	currentSlot = nil
	Transmog_SwitchTab("items")
	Transmog:Send("GetTransmogStatus")
	Transmog:CalculateCost(0)
end)

Transmog.itemAnimationFrames = {}

Transmog.itemAnimation:SetScript("OnUpdate", function()
	local plus = 0.01
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then

		for index, frame in Transmog.itemAnimationFrames do
			if frame.reset then
				frame.borderFull:SetAlpha(frame.borderFull:GetAlpha() - 0.05)
				if frame.borderHi:GetWidth() > 32 then
					frame.borderHi:SetWidth(frame.borderHi:GetWidth() - 0.5)
					frame.borderHi:SetHeight(frame.borderHi:GetHeight() - 0.5)
				end
			else
				frame.borderFull:SetAlpha(frame.borderFull:GetAlpha() + 0.05 * frame.dir)
				if frame.borderHi:GetWidth() < 48 then
					frame.borderHi:SetWidth(frame.borderHi:GetWidth() + 0.5)
					frame.borderHi:SetHeight(frame.borderHi:GetHeight() + 0.5)
				end
			end
			if frame.borderFull:GetAlpha() >= 1 then
				frame.dir = -1
			end
			if frame.borderFull:GetAlpha() <= 0.1 then
				frame.borderHi:Hide()
				frame.borderHi:SetWidth(48)
				frame.borderHi:SetHeight(48)

				Transmog.itemAnimationFrames[index] = nil
			end
		end

		if sizeof(Transmog.itemAnimationFrames) == 0 then
			Transmog.itemAnimation:Hide()
		end

		this.startTime = GetTime()

	end
end)

-- delayedLoad Timer - disabled for now
Transmog.delayedLoad = CreateFrame("Frame")
Transmog.delayedLoad:Hide()

Transmog.delayedLoad:SetScript("OnShow", function()
	twfdebug("delayedLoad show")
	this.startTime = GetTime()
end)
Transmog.delayedLoad:SetScript("OnHide", function()
	Transmog:LoadOnce()
	Transmog:Reset(true)
end)

Transmog.delayedLoad:SetScript("OnUpdate", function()
	local gt = GetTime() * 1000
	local st = (this.startTime + 1) * 1000
	if gt >= st then
		Transmog.delayedLoad:Hide()
	end
end)

-- win new transmog
Transmog.newTransmogAlert = CreateFrame("Frame")
Transmog.newTransmogAlert:Hide()
Transmog.newTransmogAlert.wonItems = {}

function Transmog.newTransmogAlert:HideAnchor()
	NewTransmogAlertFrame:SetBackdrop({
		bgFile = "",
		tile = true,
	})
	NewTransmogAlertFrame:EnableMouse(false)
	NewTransmogAlertFrameTitle:Hide()
	NewTransmogAlertFrameTestPlacement:Hide()
	NewTransmogAlertFrameClosePlacement:Hide()
end

Transmog.delayAddWonItem = CreateFrame("Frame")
Transmog.delayAddWonItem:Hide()
Transmog.delayAddWonItem.data = {}

Transmog.delayAddWonItem:SetScript("OnShow", function()
	this.startTime = GetTime()
end)
Transmog.delayAddWonItem:SetScript("OnUpdate", function()
	local plus = 0.2
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then

		local atLeastOne = false
		for id, data in next, Transmog.delayAddWonItem.data do
			if Transmog.delayAddWonItem.data[id] then
				atLeastOne = true
				Transmog:AddWonItem(id)
				Transmog.delayAddWonItem.data[id] = nil
			end
		end

		if not atLeastOne then
			Transmog.delayAddWonItem:Hide()
		end
	end
end)

Transmog.gearChangedDelay = CreateFrame("Frame")
Transmog.gearChangedDelay:Hide()
Transmog.gearChangedDelay.delay = 1

Transmog.gearChangedDelay:SetScript("OnShow", function()
	this.startTime = GetTime()
end)
Transmog.gearChangedDelay:SetScript("OnUpdate", function()
	local gt = GetTime() * 1000
	local st = (this.startTime + Transmog.gearChangedDelay.delay) * 1000
	if gt >= st then

		Transmog_SelectSlot(-1)
		Transmog_Revert()

		Transmog.gearChangedDelay:Hide()
	end
end)

function Transmog:AddWonItem(itemID)
	Transmog:CacheItem(itemID)

	local name, linkString, quality, _, _, _, _, _, tex = GetItemInfo(itemID)

	if name then

		local _, _, itemLink = strfind(linkString, "(item:%d+:%d+:%d+:%d+)")

		if not name or not quality then
			Transmog.delayAddWonItem.data[itemID] = true
			Transmog.delayAddWonItem:Show()
			return false
		end
		local _, _, _, color = GetItemQualityColor(quality)
		twfprint(color.."|H"..linkString.."|h[" .. name .. "]|h|r" .. "|cffFFFF00 " .. TRANSMOG_APPEARANCE_COLLECTED)

		local newTransmogIndex = 0
		for i = 1, sizeof(Transmog.newTransmogAlert.wonItems), 1 do
			if not Transmog.newTransmogAlert.wonItems[i].active then
				newTransmogIndex = i
				break
			end
		end

		if newTransmogIndex == 0 then
			newTransmogIndex = sizeof(Transmog.newTransmogAlert.wonItems) + 1
		end

		if not Transmog.newTransmogAlert.wonItems[newTransmogIndex] then
			Transmog.newTransmogAlert.wonItems[newTransmogIndex] = CreateFrame("Frame", "NewTransmogAlertFrame" .. newTransmogIndex, NewTransmogAlertFrame, "TransmogWonItemTemplate")
		end

		Transmog.newTransmogAlert.wonItems[newTransmogIndex]:SetPoint("TOP", NewTransmogAlertFrame, "BOTTOM", 0, (20 + 100 * newTransmogIndex))
		Transmog.newTransmogAlert.wonItems[newTransmogIndex].active = true
		Transmog.newTransmogAlert.wonItems[newTransmogIndex].frameIndex = 0
		Transmog.newTransmogAlert.wonItems[newTransmogIndex].doAnim = true

		Transmog.newTransmogAlert.wonItems[newTransmogIndex]:SetAlpha(0)
		Transmog.newTransmogAlert.wonItems[newTransmogIndex]:Show()

		_G["NewTransmogAlertFrame" .. newTransmogIndex .. "Icon"]:SetNormalTexture(tex)
		_G["NewTransmogAlertFrame" .. newTransmogIndex .. "Icon"]:SetPushedTexture(tex)
		_G["NewTransmogAlertFrame" .. newTransmogIndex .. "ItemName"]:SetText(HIGHLIGHT_FONT_COLOR_CODE .. name)

		_G["NewTransmogAlertFrame" .. newTransmogIndex .. "Icon"]:SetScript("OnEnter", function()
			FashionTooltip:SetOwner(this, "ANCHOR_RIGHT", 0, 0)
			FashionTooltip:SetHyperlink(itemLink)
			FashionTooltip:Show()
		end)
		_G["NewTransmogAlertFrame" .. newTransmogIndex .. "Icon"]:SetScript("OnLeave", function()
			FashionTooltip:Hide()
		end)

		Transmog:StartNewTransmogAlertAnimation()

	end
end

function Transmog_TestNewTransmogAlert()
	Transmog:AddWonItem(19364)
end

function Transmog:StartNewTransmogAlertAnimation()
	if sizeof(Transmog.newTransmogAlert.wonItems) > 0 then
		Transmog.newTransmogAlert.showLootWindow = true
	end
	if not Transmog.newTransmogAlert:IsVisible() then
		Transmog.newTransmogAlert:Show()
	end
end

Transmog.newTransmogAlert.showLootWindow = false

Transmog.newTransmogAlert:SetScript("OnShow", function()
	this.startTime = GetTime()
end)
Transmog.newTransmogAlert:SetScript("OnUpdate", function()
	if Transmog.newTransmogAlert.showLootWindow then
		if GetTime() >= (this.startTime + 0.03) then

			this.startTime = GetTime()

			for i, d in next, Transmog.newTransmogAlert.wonItems do

				if Transmog.newTransmogAlert.wonItems[i].active then

					local frame = _G["NewTransmogAlertFrame" .. i]
					local image = "loot_frame_xmog_"
					local icon = _G["NewTransmogAlertFrame" .. i .. "Icon"]
					local iconTexture = _G["NewTransmogAlertFrame" .. i .. "IconNormalTexture"]

					icon:SetPoint("LEFT", 160, -9)
					icon:SetWidth(36)
					icon:SetHeight(36)
					iconTexture:SetWidth(36)
					iconTexture:SetHeight(36)

					if Transmog.newTransmogAlert.wonItems[i].frameIndex < 10 then
						image = image .. "0" .. Transmog.newTransmogAlert.wonItems[i].frameIndex
					else
						image = image .. Transmog.newTransmogAlert.wonItems[i].frameIndex
					end

					Transmog.newTransmogAlert.wonItems[i].frameIndex = Transmog.newTransmogAlert.wonItems[i].frameIndex + 1

					if Transmog.newTransmogAlert.wonItems[i].doAnim then

						local backdrop = {
							bgFile = "Interface\\TransmogFrame\\anim\\" .. image,
							tile = false
						}
						if Transmog.newTransmogAlert.wonItems[i].frameIndex <= 30 then
							frame:SetBackdrop(backdrop)
						end
						frame:SetAlpha(frame:GetAlpha() + 0.03)
						icon:SetAlpha(frame:GetAlpha() + 0.03)
					end

					if Transmog.newTransmogAlert.wonItems[i].frameIndex == 35 then
						--stop and hold last frame
						Transmog.newTransmogAlert.wonItems[i].doAnim = false
					end

					if Transmog.newTransmogAlert.wonItems[i].frameIndex > 119 then
						frame:SetAlpha(frame:GetAlpha() - 0.03)
						icon:SetAlpha(frame:GetAlpha() + 0.03)
					end

					if Transmog.newTransmogAlert.wonItems[i].frameIndex == 150 then

						Transmog.newTransmogAlert.wonItems[i].frameIndex = 0
						frame:Hide()
						Transmog.newTransmogAlert.wonItems[i].active = false

					end
				end
			end
		end
	end
end)

function Transmog_ClosePlacement()
	twfprint(TRANSMOG_ANCHOR_CLOSED)
	Transmog.newTransmogAlert:HideAnchor()
end

function Transmog.newTransmogAlert:ShowAnchor()
	NewTransmogAlertFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		tile = true,
	})
	NewTransmogAlertFrame:EnableMouse(true)
	NewTransmogAlertFrameTitle:Show()
	NewTransmogAlertFrameTestPlacement:Show()
	NewTransmogAlertFrameClosePlacement:Show()
end

function OutfitsDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo()
	if sizeof(TransmogConfig[player]["Outfits"]) < UIDROPDOWNMENU_MAXBUTTONS then
		local _, _, _, color = GetItemQualityColor(2)
		info.text = color .. "+ " .. TEXT(TRANSMOG_NEW_OUTFIT)
		info.value = 1
		info.arg1 = 1
		info.checked = false
		info.func = Transmog_NewOutfitPopup
		info.tooltipTitle = nil
		info.tooltipText = nil
		UIDropDownMenu_AddButton(info)
	end
	for name, data in TransmogConfig[player]["Outfits"] do
		info.text = name
		info.value = 1
		info.arg1 = name
		info.checked = currentOutfit == name
		info.func = Transmog_LoadOutfit
		info.tooltipTitle = name
		local descText = ""
		for slot, slotName in ipairs(InventorySlotNames) do
			local itemID = data[slot]
			if itemID then
				local setItemName, link, quality = GetItemInfo(itemID)
				local _, _, _, color = GetItemQualityColor(quality or 1)
				if setItemName then
					descText = descText .. slotName .. ": " .. color .. setItemName .. FONT_COLOR_CODE_CLOSE .. "\n"
				end
			end
		end
		info.tooltipText = descText
		UIDropDownMenu_AddButton(info)
	end
end

local axes, axes2H, bows, guns, maces, maces2H, polearms, swords,
	swords2H, staves, fists, _, daggers, thrown, xbows, wands, fishing = GetAuctionItemSubClasses(1)
local weapon, armor, _, _, _, _, _, _, _, misc =  GetAuctionItemClasses(1)

function Transmog:CanApplyTransmog(itemID, ItemID2)
	local _, _, _, _, itemType, itemSubType, _, invType = GetItemInfo(itemID)
	local _, _, _, _, itemType2, itemSubType2, _, invType2 = GetItemInfo(ItemID2)
	if invType == "INVTYPE_CHEST" or invType == "INVTYPE_ROBE" then
		if invType2 == "INVTYPE_CHEST" or invType2 == "INVTYPE_ROBE" then
			return true
		end
	elseif itemType == weapon and itemType2 == weapon then
		if itemSubType == fists and temSubType == fists then
			if invType == "INVTYPE_WEAPON" or invType == "INVTYPE_WEAPONMAINHAND" then
				if invType2 == "INVTYPE_WEAPON" or invType2 == "INVTYPE_WEAPONMAINHAND" then
					return true
				end
			elseif invType == "INVTYPE_WEAPONOFFHAND" and invType2 == "INVTYPE_WEAPONOFFHAND" then
				return true
			end
		end
		if invType == "INVTYPE_RANGED" or invType == "INVTYPE_RANGEDRIGHT" then
			if invType == invType2 and itemSubType == itemSubType2 then
				return true
			end
		end
		if itemSubType == daggers and itemSubType2 == daggers then
			return true
		end
		if itemSubType == polearms and itemSubType2 == polearms then
			return true
		end
		if itemSubType == staves and itemSubType2 == staves then
			return true
		end
		if itemSubType == axes or itemSubType == maces or itemSubType == swords then
			if itemSubType2 == axes or itemSubType2 == maces or itemSubType2 == swords then
				return true
			end
		end
		if itemSubType == axes2H or itemSubType == maces2H or itemSubType == swords2H then
			if itemSubType2 == axes2H or itemSubType2 == maces2H or itemSubType2 == swords2H then
				return true
			end
		end
	elseif invType == invType2 then
		return true
	end

	return false
end

function Transmog_LoadOutfit(outfit)
	UIDropDownMenu_SetText(outfit, TransmogFrameOutfits)
	currentOutfit = outfit
	Transmog:EnableOutfitSaveButton()
	TransmogFrameDeleteOutfit:Show()
	Transmog:HideItemBorders()

	for slot, itemID in TransmogConfig[player]["Outfits"][outfit] do

		local invType, texture
		local hasItemEquipped = false
		local eqItemLink, eqItemID

		if GetInventoryItemLink("player", slot) then
			_, _, eqItemLink = strfind(GetInventoryItemLink("player", slot), "(item:%d+:%d+:%d+:%d+)")
			eqItemID = Transmog:IDFromLink(eqItemLink)
			hasItemEquipped = true
		end

		if hasItemEquipped then

			if itemID == 0 then
				_, _, _, _, _, _, _, invType, texture = GetItemInfo(eqItemID)
			else
				_, _, _, _, _, _, _, invType, texture = GetItemInfo(itemID)
			end

			if Transmog:CanApplyTransmog(itemID, eqItemID) then
				TransmogFramePlayerModel:TryOn(itemID)
				
				local frame = Transmog:FrameFromInvType(invType)
				if frame then

					_G[frame:GetName() .. "ItemIcon"]:SetTexture(texture)

					if TransmogStatusToServer[slot] ~= itemID then
						_G[frame:GetName() .. "BorderHi"]:Show()
						-- _G[frame:GetName() .. "AutoCast"]:Show()
					end

					if itemID == 0 or itemID == eqItemID then
						_G[frame:GetName() .. "BorderHi"]:Hide()
						-- _G[frame:GetName() .. "AutoCast"]:Hide()
					end

				end
				if itemID ~= eqItemID then
					TransmogStatusToServer[slot] = itemID
				else
					TransmogStatusToServer[slot] = 0
				end
				Selection[slot] = itemID
				_G[frame:GetName() .. "AutoCast"]:Hide()
				_G[frame:GetName() .. "Revert"]:Hide()
				if TransmogStatusFromServer[slot] ~= TransmogStatusToServer[slot] then
					_G[frame:GetName() .. "AutoCast"]:Show()
					if TransmogStatusToServer[slot] == 0 then
						_G[frame:GetName() .. "Revert"]:Show()
					end
				end
			end
		end

	end
	Transmog:CalculateCost()
end

function Transmog_SaveOutfit()
	TransmogConfig[player]["Outfits"][currentOutfit] = {}
	for InventorySlotId, itemID in pairs(Selection) do
		if itemID ~= 0 then
			TransmogConfig[player]["Outfits"][currentOutfit][InventorySlotId] = itemID
		end
	end
	TransmogFrameSaveOutfit:Disable()
	if currentTab == "sets" then
		Transmog:ShowSets()
	end
end

function Transmog:EnableOutfitSaveButton()
	if currentOutfit ~= nil then
		TransmogFrameSaveOutfit:Enable()
	end
end

function Transmog_DeleteOutfit()
	TransmogConfig[player]["Outfits"][currentOutfit] = nil
	TransmogFrameSaveOutfit:Disable()
	TransmogFrameDeleteOutfit:Hide()
	currentOutfit = nil
	UIDropDownMenu_SetText(TEXT(TRANSMOG_OUTFITS), TransmogFrameOutfits)
	Transmog_Revert()
end

StaticPopupDialogs["TRANSMOG_NEW_OUTFIT"] = {
	text = TEXT(TRANSMOG_OUTFIT_NAME) .. ":",
	button1 = TEXT(SAVE),
	button2 = TEXT(CANCEL),
	hasEditBox = 1,
	OnShow = function()
		_G[this:GetName() .. "EditBox"]:SetScript("OnEnterPressed", function()
			StaticPopup1Button1:Click()
		end)

		_G[this:GetName() .. "EditBox"]:SetScript("OnEscapePressed", function()
			_G[this:GetParent():GetName() .. "EditBox"]:SetText("")
			StaticPopup1Button2:Click()
		end)
	end,
	OnAccept = function()
		local outfitName = _G[this:GetParent():GetName() .. "EditBox"]:GetText()
		if trim(outfitName) == "" then
			StaticPopup_Show("TRANSMOG_OUTFIT_EMPTY_NAME")
			return
		end
		if TransmogConfig[player]["Outfits"][outfitName] then
			StaticPopup_Show("TRANSMOG_OUTFIT_EXISTS")
			return
		end
		UIDropDownMenu_SetText(outfitName, TransmogFrameOutfits)
		currentOutfit = outfitName
		Transmog:EnableOutfitSaveButton()
		Transmog_SaveOutfit()
		_G[this:GetParent():GetName() .. "EditBox"]:SetText("")
	end,
	timeout = 0,
	whileDead = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["TRANSMOG_OUTFIT_EXISTS"] = {
	text = TEXT(TRANSMOG_OUTFIT_NAME_TAKEN),
	button1 = TEXT(OKAY),
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["TRANSMOG_OUTFIT_EMPTY_NAME"] = {
	text = TEXT(TRANSMOG_OUTFIT_NAME_EMPTY),
	button1 = TEXT(OKAY),
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["CONFIRM_DELETE_OUTFIT"] = {
	text = TEXT(TRANSMOG_OUTFIT_DELETE),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		Transmog_DeleteOutfit()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}

function Transmog_NewOutfitPopup()
	StaticPopup_Show("TRANSMOG_NEW_OUTFIT")
end

function Transmog:CacheItem(linkOrID)
	if not linkOrID or linkOrID == 0 then
		twfdebug("cache item call with null " .. type(linkOrID))
		return
	end
	if tonumber(linkOrID) then
		if GetItemInfo(linkOrID) then
			return true
		else
			GameTooltip:SetHyperlink("item:"..linkOrID)
		end
		return
	end
	local _, _, id = strfind(linkOrID, "(item:%d+)")
	if id then
		if GetItemInfo(id) then
			return true
		else
			GameTooltip:SetHyperlink(id)
		end
	end
end

SLASH_TRANSMOG1 = "/transmog"
SlashCmdList["TRANSMOG"] = function(cmd)
	if cmd then
		Transmog.newTransmogAlert:ShowAnchor()
	end
end
SLASH_TRANSMOGDEBUG1 = "/transmogdebug"
SlashCmdList["TRANSMOGDEBUG"] = function(cmd)
	if cmd then
		if transmogDebug then
			transmogDebug = false
			twfprint("Transmog debug off")
		else
			transmogDebug = true
			twfprint("Transmog debug on")
		end
	end
end
