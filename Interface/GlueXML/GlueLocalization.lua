function Localize()
	-- Put all locale specific string adjustments here
	--SHOW_CONTEST_AGREEMENT = 1;
end

function LocalizeFrames()
	-- Put all locale specific UI adjustments here
	--WorldOfWarcraftRating:SetTexture("Interface\\Glues\\Common\\Glues-WoW-Logo");
	WorldOfWarcraftRating:SetTexture("");
	local size = 122
	WorldOfWarcraftRating:SetHeight(size)
	WorldOfWarcraftRating:SetWidth(size*2)
	WorldOfWarcraftRating:ClearAllPoints();
	WorldOfWarcraftRating:SetPoint("TOP", "AccountLogin", "TOP", 0, -10);
	WorldOfWarcraftRating:Show();
	
	-- Random name button is for English only
	CharacterCreateRandomName:Show();
end
