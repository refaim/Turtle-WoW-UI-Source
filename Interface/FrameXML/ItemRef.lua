ItemRefStaticPopups = {
	"ADD_FRIEND",
	"ADD_IGNORE",
	"ADD_GUILDMEMBER",
	"ADD_RAIDMEMBER",
	"ARENA_POPUP_INVITE_PLAYER",
};

function SetItemRef(link, text, button)
	if ( strsub(link, 1, 6) == "player" ) then
		local name = strsub(link, 8);
		if ( name and (strlen(name) > 0) ) then
			name = gsub(name, "([^%s]*)%s+([^%s]*)%s+([^%s]*)", "%3");
			name = gsub(name, "([^%s]*)%s+([^%s]*)", "%2");
			if ( IsShiftKeyDown() ) then
				for _, value in ipairs(ItemRefStaticPopups) do
					local staticPopup = StaticPopup_Visible(value);
					if ( staticPopup ) then
						_G[staticPopup.."EditBox"]:SetText(name);
						return;
					end
				end
				if ( ChatFrameEditBox:IsVisible() ) then
					ChatFrameEditBox:Insert(name);
				else
					SendWho("n-"..name);
				end
			elseif ( button == "RightButton" ) then
				FriendsFrame_ShowDropdown(name, 1);
			else
				ChatFrame_SendTell(name);
			end
		end
		return;
	end

	if ( IsControlKeyDown() ) then
		DressUpItemLink(text);
	elseif ( IsShiftKeyDown() ) then
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:Insert(text);
		end
	else
		ShowUIPanel(ItemRefTooltip);
		if ( not ItemRefTooltip:IsVisible() ) then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
		end
		ItemRefTooltip:SetHyperlink(link);
	end
end
