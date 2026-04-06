INSPECT_TRANSMOG_DATA = {
	[1] = { frame = "InspectHeadSlot", transmogID = nil, equipID = nil },
	[3] = { frame = "InspectShoulderSlot", transmogID = nil, equipID = nil },
	[4] = { frame = "InspectShirtSlot", transmogID = nil, equipID = nil },
	[5] = { frame = "InspectChestSlot", transmogID = nil, equipID = nil },
	[6] = { frame = "InspectWaistSlot", transmogID = nil, equipID = nil },
	[7] = { frame = "InspectLegsSlot", transmogID = nil, equipID = nil },
	[8] = { frame = "InspectFeetSlot", transmogID = nil, equipID = nil },
	[9] = { frame = "InspectWristSlot", transmogID = nil, equipID = nil },
	[10] = { frame = "InspectHandsSlot", transmogID = nil, equipID = nil },
	[15] = { frame = "InspectBackSlot", transmogID = nil, equipID = nil },
	[16] = { frame = "InspectMainHandSlot", transmogID = nil, equipID = nil },
	[17] = { frame = "InspectSecondaryHandSlot", transmogID = nil, equipID = nil },
	[18] = { frame = "InspectRangedSlot", transmogID = nil, equipID = nil },
	[19] = { frame = "InspectTabardSlot", transmogID = nil, equipID = nil },
}

local DelayFrame = CreateFrame("Frame")
local DelayQueue = {}
DelayFrame:SetScript("OnUpdate", function()
	for func in pairs(DelayQueue) do
		if tonumber(DelayQueue[func]) then
			DelayQueue[func] = tonumber(DelayQueue[func]) - arg1
			if DelayQueue[func] <= 0 then
				func()
				DelayQueue[func] = nil
			end
		end
	end
end)

local function RequestTransmogInspectData()
	local target = UnitName("target")
	if target then
		SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. target .. ">", "INSShowTransmogs", "GUILD")
	end
end

function InspectPaperDollFrame_HandleMessage(message, from)
	local name = InspectFrame and InspectFrame.unit and UnitName(InspectFrame.unit)
	local _, _, slot, transmogID, equipID = strfind(message, "INSTransmogs"..ADDON_MSG_FIELD_DELIMITER.."(.+)"..ADDON_MSG_FIELD_DELIMITER.."(%d+)"..ADDON_MSG_FIELD_DELIMITER.."(%d+)")
	if slot == "start" or not (name and from and name == from) then
		for k in pairs(INSPECT_TRANSMOG_DATA) do
			INSPECT_TRANSMOG_DATA[k].equipID = nil
			INSPECT_TRANSMOG_DATA[k].transmogID = nil
		end
		return
	end
	slot, transmogID, equipID = tonumber(slot), tonumber(transmogID), tonumber(equipID)
	if slot and transmogID and equipID and INSPECT_TRANSMOG_DATA[slot] then
		INSPECT_TRANSMOG_DATA[slot].transmogID = transmogID ~= 0 and transmogID or nil
		INSPECT_TRANSMOG_DATA[slot].equipID = equipID ~= 0 and equipID or nil
		Transmog:CacheItem(transmogID)
	end
end

function InspectPaperDollFrame_OnLoad()
	this:RegisterEvent("UNIT_MODEL_CHANGED");
	this:RegisterEvent("UNIT_LEVEL");
end

function InspectPaperDollFrame_OnEvent(event, unit)
	if ( unit and unit == InspectFrame.unit ) then
		if ( event == "UNIT_MODEL_CHANGED" ) then
			InspectModelFrame:SetUnit(InspectFrame.unit);
		elseif ( event == "UNIT_LEVEL" ) then
			InspectPaperDollFrame_SetLevel();
		end
		return;
	end
end

function InspectPaperDollFrame_SetLevel()
	local unit = InspectFrame.unit;
	InspectLevelText:SetText(format(PLAYER_LEVEL,UnitLevel(unit), UnitRace(unit), UnitClass(unit)));
end

function InspectPaperDollFrame_OnShow()
	InspectModelFrame:SetUnit(InspectFrame.unit);
	InspectPaperDollFrame_SetLevel();
	InspectPaperDollItemSlotButton_Update(InspectHeadSlot);
	InspectPaperDollItemSlotButton_Update(InspectNeckSlot);
	InspectPaperDollItemSlotButton_Update(InspectShoulderSlot);
	InspectPaperDollItemSlotButton_Update(InspectBackSlot);
	InspectPaperDollItemSlotButton_Update(InspectChestSlot);
	InspectPaperDollItemSlotButton_Update(InspectShirtSlot);
	InspectPaperDollItemSlotButton_Update(InspectTabardSlot);
	InspectPaperDollItemSlotButton_Update(InspectWristSlot);
	InspectPaperDollItemSlotButton_Update(InspectHandsSlot);
	InspectPaperDollItemSlotButton_Update(InspectWaistSlot);
	InspectPaperDollItemSlotButton_Update(InspectLegsSlot);
	InspectPaperDollItemSlotButton_Update(InspectFeetSlot);
	InspectPaperDollItemSlotButton_Update(InspectFinger0Slot);
	InspectPaperDollItemSlotButton_Update(InspectFinger1Slot);
	InspectPaperDollItemSlotButton_Update(InspectTrinket0Slot);
	InspectPaperDollItemSlotButton_Update(InspectTrinket1Slot);
	InspectPaperDollItemSlotButton_Update(InspectMainHandSlot);
	InspectPaperDollItemSlotButton_Update(InspectSecondaryHandSlot);
	InspectPaperDollItemSlotButton_Update(InspectRangedSlot);

	RequestTransmogInspectData()
end

function InspectPaperDollItemSlotButton_OnLoad()
	this:RegisterEvent("UNIT_INVENTORY_CHANGED");
	local slotName = this:GetName();
	local id;
	local textureName;
	local checkRelic;
	id, textureName, checkRelic = GetInventorySlotInfo(strsub(slotName,8));
	this:SetID(id);
	local texture = _G[slotName.."IconTexture"];
	texture:SetTexture(textureName);
	this.backgroundTextureName = textureName;
	this.checkRelic = checkRelic;
end

function InspectPaperDollItemSlotButton_OnEvent(event)
	if ( event == "UNIT_INVENTORY_CHANGED" ) then
		if ( arg1 == InspectFrame.unit ) then
			InspectPaperDollItemSlotButton_Update(this);
			DelayQueue[RequestTransmogInspectData] = 1.5
		end
		return;
	end
end

function InspectPaperDollItemSlotButton_OnClick(button)
	if ( IsControlKeyDown() ) then
		DressUpItemLink(GetInventoryItemLink(InspectFrame.unit, this:GetID()));
	elseif ( IsShiftKeyDown() ) then
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:Insert(GetInventoryItemLink(InspectFrame.unit, this:GetID()));
		end
	end
end

function InspectPaperDollItemSlotButton_Update(button)
	local unit = InspectFrame.unit;
	local textureName = GetInventoryItemTexture(unit, button:GetID());
	if ( textureName ) then
		SetItemButtonTexture(button, textureName);
		SetItemButtonCount(button, GetInventoryItemCount(unit, button:GetID()));
		button.hasItem = 1;
	else
		textureName = button.backgroundTextureName;
		if ( button.checkRelic and UnitHasRelicSlot(unit) ) then
			textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
		end
		SetItemButtonTexture(button, textureName);
		SetItemButtonCount(button, 0);
		button.hasItem = nil;
	end
	if ( GameTooltip:IsOwned(button) ) then
		if ( textureName ) then
			if ( not GameTooltip:SetInventoryItem(InspectFrame.unit, button:GetID()) ) then
				GameTooltip:SetText(_G[strupper(strsub(button:GetName(), 8))]);
			end
		else
			GameTooltip:Hide();
		end
	end
end

function InspectTransmogTooltip_OnShow()
	if not (InspectPaperDollFrame and InspectPaperDollFrame:IsVisible() and GameTooltip.itemLink) then
		return
	end

	local _, _, itemLink = strfind(GameTooltip.itemLink, "(item:%d+:%d+:%d+:%d+)")

	if not itemLink then
		return
	end

	for slot, data in pairs(INSPECT_TRANSMOG_DATA) do
		if GameTooltip:IsOwned(_G[data.frame]) then
			local line2 = GameTooltipTextLeft2

			if line2 and line2:GetText() and data.transmogID then
				local itemName = GetItemInfo(data.transmogID)
				if itemName then
					line2:SetText("|cfff471f5"..TRANSMOG_CHANGED_TO.."\n" .. itemName .. "|r\n" .. line2:GetText())
					GameTooltip:Show()
				end
			end

			return
		end
	end
end