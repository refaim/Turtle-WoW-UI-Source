
GAMETIME_DAWN = ( 5 * 60) + 30;		-- 5:30 AM
GAMETIME_DUSK = (21 * 60) +  0;		-- 9:00 PM

function GameTimeFrame_Update()
	local hour, minute = GetGameTime();
	local time = (hour * 60) + minute;
	if(time ~= this.timeOfDay) then
		this.timeOfDay = time;
		local minx = 0;
		local maxx = 50/128;
		local miny = 0;
		local maxy = 50/64;
		if(time < GAMETIME_DAWN or time >= GAMETIME_DUSK) then
			minx = minx + 0.5;
			maxx = maxx + 0.5;
		end
		GameTimeTexture:SetTexCoord(minx, maxx, miny, maxy);

		if(GameTooltip:IsOwned(this)) then
			GameTimeFrame_UpdateTooltip(hour, minute);
		end
	end
end

function GameTimeFrame_UpdateTooltip(hours, minutes)
	if(TwentyFourHourTime) then
		GameTooltip:AddLine("Zone: "..format(TEXT(TIME_TWENTYFOURHOURS), hours, minutes))

		hours, minutes = GetGameTime()
		SetMapToCurrentZone()
		local continent = GetCurrentMapContinent()

		if continent == 1 then
			hours = hours + 12

			if hours >= 24 then
				hours = hours - 24
			end
		end
		GameTooltip:AddLine("Server: "..format(TEXT(TIME_TWENTYFOURHOURS), hours, minutes))

		hours, minutes = date("%H"), date("%M")
		GameTooltip:AddLine("Local: "..format(TEXT(TIME_TWENTYFOURHOURS), hours, minutes))
		GameTooltip:Show()
	else
		GameTimeAMPM(hours, minutes)

		hours, minutes = GetGameTime()
		SetMapToCurrentZone()
		local continent = GetCurrentMapContinent()
		if continent == 1 then
			hours = hours + 12
			if hours >= 24 then
				hours = hours - 24
			end
		end
		GameTimeAMPM(hours, minutes)

		hours, minutes = date("%H"), date("%M")

		GameTimeAMPM(hours, minutes)
		GameTooltip:Show()
	end
end

function GameTime_GetTime()
	local hour, minute = GetGameTime();

	if(TwentyFourHourTime) then
		return format(TEXT(TIME_TWENTYFOURHOURS), hour, minute);
	else
		local pm = 0;
		if(hour >= 12) then
			pm = 1;
		end
		if(hour > 12) then
			hour = hour - 12;
		end
		if(hour == 0) then
			hour = 12;
		end
		if(pm == 0) then
			return format(TEXT(TIME_TWELVEHOURAM), hour, minute);
		else
			return format(TEXT(TIME_TWELVEHOURPM), hour, minute);
		end
	end
end

function GameTimeAMPM(hours,minutes)

	local pm = 0;
	if(hours >= 12) then
		pm = 1;
	end
	if(hours > 12) then
		hours = hours - 12;
	end
	if(hours == 0) then
		hours = 12;
	end
	if(pm == 0) then
		GameTooltip:AddLine(format(TEXT(TIME_TWELVEHOURAM), hours, minutes));
	else
		GameTooltip:AddLine(format(TEXT(TIME_TWELVEHOURPM), hours, minutes));
	end
end
