local ADDON_PREFIX = "TW_HONOR"
local ADDON_CHANNEL = "GUILD"

function HonorFrame_OnLoad()
	this:RegisterEvent("PLAYER_PVP_KILLS_CHANGED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_PVP_RANK_CHANGED");
	this:RegisterEvent("CHAT_MSG_ADDON");
end

local function FormatCurrencySpaces(value)
	local s = tostring(value)
	local formatted

	repeat
		s, formatted = string.gsub(s, "^(-?%d+)(%d%d%d)", "%1 %2")
	until formatted == 0

	return s
end

local function UpdateHonorPoints(points)
	HonorFrameCurrentHonor:SetText(FormatCurrencySpaces(points));
	local factionGroup = UnitFactionGroup("player");
	local honorTexture = "Interface\\TargetingFrame\\UI-PVP-Horde";
	if ( factionGroup ) then
		honorTexture = "Interface\\TargetingFrame\\UI-PVP-"..factionGroup;
	end


	HonorFrameHonorIcon:SetTexture(honorTexture);
end


function HonorFrame_OnEvent()
	if ( event == "PLAYER_PVP_KILLS_CHANGED" or event == "PLAYER_PVP_RANK_CHANGED") then
		HonorFrame_Update();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		HonorFrame_Update(1);

	elseif event == "CHAT_MSG_ADDON" then
		if arg1 ~= ADDON_PREFIX then
			return
		end

		local args = explode(arg2, ADDON_MSG_FIELD_DELIMITER);

		if args[1] == "S2C_HONOR_RESPONSE" then
			UpdateHonorPoints(args[2]);
		end
	end
end

local function Send(message)
	SendAddonMessage(ADDON_PREFIX, message, ADDON_CHANNEL)
end

function HonorFrame_OnShow()
	Send("C2S_HONOR_REQUEST");
end



function HonorFrame_Update(updateAll)
	local hk, dk, contribution, rank, highestRank, rankName, rankNumber;

	-- This only gets set on player entering the world
	if ( updateAll ) then
		-- Yesterday's values
		hk, dk, contribution = GetPVPYesterdayStats();
		HonorFrameYesterdayHKValue:SetText(hk);
		HonorFrameYesterdayContributionValue:SetText(contribution);
		-- This Week's values
		hk, contribution = GetPVPThisWeekStats();
		HonorFrameThisWeekHKValue:SetText(hk);
		HonorFrameThisWeekContributionValue:SetText(contribution);
		-- Last Week's values
		hk, dk, contribution, rank = GetPVPLastWeekStats();
		HonorFrameLastWeekHKValue:SetText(hk);
		HonorFrameLastWeekContributionValue:SetText(contribution);
		HonorFrameLastWeekStandingValue:SetText(rank);
	end

	-- This session's values
	hk, dk = GetPVPSessionStats();
	HonorFrameCurrentHKValue:SetText(hk);
	HonorFrameCurrentDKValue:SetText(dk);

	-- Lifetime stats
	hk, dk, highestRank = GetPVPLifetimeStats();
	HonorFrameLifeTimeHKValue:SetText(hk);
	HonorFrameLifeTimeDKValue:SetText(dk);
	rankName, rankNumber = GetPVPRankInfo(highestRank);
	if ( not rankName ) then
		rankName = NONE;
	end
	HonorFrameLifeTimeRankValue:SetText(rankName);

	-- Set rank name and number
	rankName, rankNumber = GetPVPRankInfo(UnitPVPRank("player"));
	if ( not rankName ) then
		rankName = NONE;
	end
	HonorFrameCurrentPVPTitle:SetText(rankName);
	HonorFrameCurrentPVPRank:SetText("("..RANK.." "..rankNumber..")");

	-- Set icon
	if ( rankNumber > 0 ) then
		HonorFramePvPIcon:SetTexture(format("%s%02d","Interface\\PvPRankBadges\\PvPRank",rankNumber));
		HonorFramePvPIcon:Show();
	else
		HonorFramePvPIcon:Hide();
	end

	-- Set rank progress and bar color
	local factionGroup, factionName = UnitFactionGroup("player");
	if ( factionGroup == "Alliance" ) then
		HonorFrameProgressBar:SetStatusBarColor(0.05, 0.15, 0.36);
	else
		HonorFrameProgressBar:SetStatusBarColor(0.63, 0.09, 0.09);
	end
	HonorFrameProgressBar:SetValue(GetPVPRankProgress());

	-- Recenter rank text
	HonorFrameCurrentPVPTitle:SetPoint("TOP", "HonorFrame", "TOP", - HonorFrameCurrentPVPRank:GetWidth()/2, -83);
end