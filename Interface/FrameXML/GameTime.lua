
GAMETIME_DAWN = ( 5 * 60) + 30;		-- 5:30 AM
GAMETIME_DUSK = (21 * 60) +  0;		-- 9:00 PM
local hourDiff = 0;
local minDiff = 0;

function GameTimeFrame_OnEvent()
	if event == "PLAYER_LOGIN" then
		SendAddonMessage("TW_TIME", "", "GUILD")
	elseif event == "CHAT_MSG_ADDON" and arg1 == "TW_TIME" then
		local _, _, hour, minute = strfind(arg2, "(%d+):(%d+)");
		if hour and minute then
			hourDiff = tonumber(date("%H")) - tonumber(hour);
			minDiff = tonumber(date("%M")) - tonumber(minute);
			this:UnregisterEvent("CHAT_MSG_ADDON");
			this:UnregisterEvent("PLAYER_LOGIN");
		end
	end
end

function GetServerTime()
	local localHour, localMin = tonumber(date("%H")), tonumber(date("%M"));
	local serverHour = mod((localHour - hourDiff) + 24, 24);
	local serverMin = mod((localMin - minDiff) + 60, 60);
	return serverHour, serverMin;
end

function GameTimeFrame_Update()
	local hour, minute = GetGameTime();
	local time = (hour * 60) + minute;
	if ( time ~= this.timeOfDay ) then
		this.timeOfDay = time;
		local minx = 0;
		local maxx = 50/128;
		local miny = 0;
		local maxy = 50/64;
		if ( time < GAMETIME_DAWN or time >= GAMETIME_DUSK ) then
			minx = minx + 0.5;
			maxx = maxx + 0.5;
		end
		GameTimeTexture:SetTexCoord(minx, maxx, miny, maxy);

		if ( GameTooltip:IsOwned(this) ) then
			GameTimeFrame_UpdateTooltip(hour, minute);
		end
	end
end

function GameTimeFrame_UpdateTooltip(hours, minutes)
	GameTooltip:ClearLines();
	GameTooltip:AddLine(GAMETIME_TITLE, 1, 1, 1)
	GameTooltip:AddDoubleLine(GAMETIME_ZONE, GameTime_FormatTime(hours, minutes));
	GameTooltip:AddDoubleLine(GAMETIME_SERVER, GameTime_FormatTime(GetServerTime()));
	GameTooltip:AddDoubleLine(GAMETIME_LOCAL, GameTime_FormatTime(date("%H"), date("%M")));
	GameTooltip:Show();
end

function GameTime_GetTime()
	local hour, minute = GetGameTime();
	return GameTime_FormatTime(hour, minute);
end

function GameTime_FormatTime(hour, minute)
	hour, minute = tonumber(hour), tonumber(minute);

	if ( TwentyFourHourTime ) then
		return format(TIME_TWENTYFOURHOURS, hour, minute);
	end

	local pm = 0;
	if ( hour >= 12 ) then
		pm = 1;
	end
	if ( hour > 12 ) then
		hour = hour - 12;
	end
	if ( hour == 0 ) then
		hour = 12;
	end
	if ( pm == 0 ) then
		return format(TIME_TWELVEHOURAM, hour, minute);
	else
		return format(TIME_TWELVEHOURPM, hour, minute);
	end
end
