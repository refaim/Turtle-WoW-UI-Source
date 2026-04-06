
local DressUpItem_orig = DressUpItem;

function DressUpItem(item)
	if ( not item ) then
		return;
	end
	if ( AuctionFrame:IsShown() ) then
		if ( not AuctionDressUpFrame:IsShown() ) then
			ShowUIPanel(AuctionDressUpFrame);
			AuctionDressUpModel:SetUnit("player");
		end
		AuctionDressUpModel:TryOn(item);
	else
		DressUpItem_orig(item);
	end
end

function SetAuctionDressUpBackground()
	local texture = DressUpTexturePath();
	AuctionDressUpBackgroundTop:SetTexture(texture..1);
	AuctionDressUpBackgroundBot:SetTexture(texture..3);
end

function AuctionDressUpFrame_OnShow()
	UIPanelWindows["AuctionFrame"].width = 1020;
	UpdateUIPanelPositions(AuctionFrame);
	PlaySound("igCharacterInfoOpen");
end

function AuctionDressUpFrame_OnHide()
	UIPanelWindows["AuctionFrame"].width = 840;
	UpdateUIPanelPositions();
	PlaySound("igCharacterInfoClose");
end
