
-- This variable is used in CharacterCreate too!
MAX_CLASSES_PER_RACE = 8;

function RaceSelect_OnLoad()
	this:RegisterEvent("UPDATE_SELECTED_RACE");

	this.selected = nil;
	this:SetSequence(0);
	this:SetCamera(0);

	SetRaceSelectFrame("RaceSelect");
end

function RaceSelect_OnEvent()
	if ( event == "UPDATE_SELECTED_RACE" ) then
		UpdateSelectedRace(arg1);
	end
end

function RaceSelect_OnKeyDown()
	if ( arg1 == "ESCAPE" ) then
		RaceSelect_Back();
	elseif (arg1 == "ENTER" ) then
		RaceSelect_OnOk();
	end
end

function RaceSelect_OnMouseUp()
	RaceSelectProcessClick();
end

function RaceSelect_OnUpdate()
	if ( this:IsVisible() ) then
		UpdateRaceHighlight();
	end
end

function UpdateSelectedRace(raceName)
	RaceSelect.selected = raceName;
	if ( not raceName ) then
		RaceSelectInfoFrame:Hide();
		return;
	end

	PlaySound("gsCharacterCreationRace");
	GlueFrameFadeOut(RaceSelectInfoFrame, RACE_SELECT_INFO_FADE_OUT, RaceSelectInfo_FadeIn);
end

function RaceSelectInfo_FadeIn()
	local factionName, internalFactionName = GetFactionForRace();
	local infoText = TEXT(getglobal("RACE_INFO_"..strupper(gsub(RaceSelect.selected, "(%.*)%s+(%.*)", "%1".."%2"))));
	local abilityText = TEXT(getglobal("ABILITY_INFO_"..strupper(RaceSelect.selected)));
	local factionText = TEXT(getglobal("FACTION_INFO_"..strupper(internalFactionName)));
	RaceSelectRaceName:SetText(RaceSelect.selected);
	RaceSelectRaceInfo:SetText(infoText);
	RaceSelectAbilityInfo:SetText(abilityText);
	RaceSelectFactionName:SetText(factionName);
	RaceSelectFactionInfo:SetText(factionText);
	RaceSelectInfoFrame:Show();
	GlueFrameFadeIn(RaceSelectInfoFrame, RACE_SELECT_INFO_FADE_IN);
	UpdateAvailableClasses(GetClassesForRace());
end

function UpdateAvailableClasses(...)
	if ( arg.n > MAX_CLASSES_PER_RACE ) then
		message("Too many classes!  Update MAX_CLASSES_PER_RACE");
		return;
	end

	for i=1, arg.n, 1 do
		local string = getglobal("RaceSelectClass"..i);
		string:SetText("- "..arg[i]);
		string:Show();
	end
	for i=arg.n + 1, MAX_CLASSES_PER_RACE, 1 do
		getglobal("RaceSelectClass"..i):Hide();
	end
end

function RaceSelect_OnOk()
	if ( not RaceSelect.selected ) then
		return;
	end
	PlaySound("gsCharacterSelectionCreateNew");
	SetGlueScreen("charcreate");
end

function RaceSelect_Back()
	PlaySound("gsCharacterCreationCancel");
	SetGlueScreen("charselect");
end
