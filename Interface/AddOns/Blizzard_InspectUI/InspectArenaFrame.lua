local details, teams = {}, {}

local function UpdateInspectArenaDetails(data)
	explode(data, ADDON_MSG_SUBFIELD_DELIMITER, teams)
	for i = 1, sizeof(teams) do
		explode(teams[i], ADDON_MSG_ARRAY_DELIMITER, details)

		local teamFrame = _G["InspectArenaFrameTeam" .. i]
		local teamFrameName = teamFrame:GetName()

		if details[2] ~= "None" and details[3] ~= "None" then
			teamFrame:SetAlpha(1)

			_G[teamFrameName .. "Text"]:Hide()

			local detailsFrame = _G[teamFrameName .. "Details"]
			local detailsFrameName = detailsFrame:GetName()
			local detailsTeamName = _G[detailsFrameName .. "Name"]

			local rating = tonumber(details[4]) or 0
			local seasonRank = tonumber(details[5]) or 0
			local seasonWins = tonumber(details[6]) or 0
			local seasonGames = tonumber(details[7]) or 0
			local weekRank = 0
			local weekWins = tonumber(details[8]) or 0
			local weekGames = tonumber(details[9]) or 0

			detailsFrame:Show()
			detailsTeamName:SetText(details[2])

			_G[detailsFrameName .. "Rating"]:SetText(rating)
			_G[detailsFrameName .. "WeekRank"]:SetText(weekRank)
			_G[detailsFrameName .. "WeekGames"]:SetText(weekGames)
			_G[detailsFrameName .. "WeekWins"]:SetText(weekWins)
			_G[detailsFrameName .. "WeekLoss"]:SetText(weekGames - weekWins)
			_G[detailsFrameName .. "SeasonRank"]:SetText(seasonRank)
			_G[detailsFrameName .. "SeasonGames"]:SetText(seasonGames)
			_G[detailsFrameName .. "SeasonWins"]:SetText(seasonWins)
			_G[detailsFrameName .. "SeasonLoss"]:SetText(seasonGames - seasonWins)
		end
	end
end

function InspectArenaFrame_OnLoad()
	this:RegisterEvent("CHAT_MSG_ADDON")
end

function InspectArenaFrame_OnEvent()
	if event == "CHAT_MSG_ADDON" then
		if arg1 == "TW_ARENA" and not strfind(arg2, "No teams found") then
			explode(arg2, ADDON_MSG_FIELD_DELIMITER, details)
			if details[1] == "S2C_INFO" and details[2] == UnitName("target") then
				UpdateInspectArenaDetails(details[3])
			end
		end
	end
end

function InspectArenaFrame_OnShow()
	for i = 1, 3 do
		local teamFrame = "InspectArenaFrameTeam" .. i
		_G[teamFrame .. "Details"]:Hide()
		_G[teamFrame .. "Text"]:Show()
	end

	if UnitExists("target") then
		SendAddonMessage("TW_ARENA", "C2S_INFO_INSPECT;" .. UnitName("target"), "GUILD")
	end
end