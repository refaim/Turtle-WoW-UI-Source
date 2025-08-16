local handler = CreateFrame("Frame")
handler:RegisterEvent("VARIABLES_LOADED")
handler:SetScript("OnEvent", function()
    Turtle_ChallengesCache = Turtle_ChallengesCache or {}

    local realm = GetRealmName()
    if not Turtle_ChallengesCache[realm] then
        Turtle_ChallengesCache[realm] = {}
    end
end)