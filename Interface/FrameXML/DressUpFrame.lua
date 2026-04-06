function DressUpTabard()
	local tabardLink = GetInventoryItemLink("player", 19);
	local _, _, itemID = strfind(tabardLink or "", "item:(%d+)");
	if itemID then
		DressUpModel:TryOn(tonumber(itemID));
	end
end

function DressUpItem(item)
	if ( not DressUpFrame:IsVisible() ) then
		ShowUIPanel(DressUpFrame);
		DressUpModel:SetUnit("player");
		DressUpTabard()
	end
	DressUpModel:TryOn(item);
end

function DressUpItemLink(link)
	if ( not link ) then
		return;
	end
	local item = gsub(link, ".*item:(%d+).*", "%1", 1);
	DressUpItem(item);
end

function DressUpTexturePath()
	local _, race = UnitRace("player");
	if ( not race ) then
		race = "Orc";
	end
	return "Interface\\DressUpFrame\\DressUpBackground-"..race;
end

function SetDressUpBackground()
	local texture = DressUpTexturePath();
	DressUpBackgroundTopLeft:SetTexture(texture..1);
	DressUpBackgroundTopRight:SetTexture(texture..2);
	DressUpBackgroundBotLeft:SetTexture(texture..3);
	DressUpBackgroundBotRight:SetTexture(texture..4);
end
