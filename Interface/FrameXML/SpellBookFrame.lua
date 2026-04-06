MAX_SPELLS = 1024;
MAX_SKILLLINE_TABS = 8;
SPELLS_PER_PAGE = 12;
MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);
BOOKTYPE_SPELL = "spell";
BOOKTYPE_PET = "pet";
SPELLBOOK_PAGENUMBERS = {};

SpecialSpellTabs = {
	"Interface\\Icons\\Ability_Mount_RidingHorse", -- Mounts
	"Interface\\Icons\\Spell_Shaman_Hex",          -- Companions
	"Interface\\Icons\\INV_Scroll_15",             -- Glyphs
	"Interface\\Icons\\inv_misc_toy_10",           -- Toys
}

SpellTabInfo = {}
for i = 1, MAX_SKILLLINE_TABS do
	SpellTabInfo[i] = { id = nil, name = nil, texture = nil, offset = 0, numSpells = 0 }
end

function SpellBookFrame_UpdateTabsInfo()
	local tab = 1
	for i = 1, MAX_SKILLLINE_TABS do
		local name, texture, offset, numSpells = GetSpellTabInfo(i)
		if texture and not tContains(SpecialSpellTabs, texture) then
			SpellTabInfo[tab].id = i
			SpellTabInfo[tab].name = name
			SpellTabInfo[tab].texture = texture
			SpellTabInfo[tab].offset = offset
			SpellTabInfo[tab].numSpells = numSpells
			tab = tab + 1
		end
	end
	for i = 1, getn(SpecialSpellTabs) do
		for j = 1, MAX_SKILLLINE_TABS do
			local name, texture, offset, numSpells = GetSpellTabInfo(j)
			if texture and strlower(SpecialSpellTabs[i]) == strlower(texture) then
				SpellTabInfo[tab].id = j
				SpellTabInfo[tab].name = name
				SpellTabInfo[tab].texture = texture
				SpellTabInfo[tab].offset = offset
				SpellTabInfo[tab].numSpells = numSpells
				tab = tab + 1
			end
		end
	end
end

function SpellBook_GetTabInfo(tab)
	if not SpellTabInfo[1].name then
		SpellBookFrame_UpdateTabsInfo()
	end
	if SpellTabInfo[tab] then
		return SpellTabInfo[tab].name, SpellTabInfo[tab].texture, SpellTabInfo[tab].offset, SpellTabInfo[tab].numSpells
	else
		return nil, nil, 0, 0
	end
end

function SpellBookFrameTabButton_OnClick()
	-- suppress the hiding sound so we don't play a hide and show sound simultaneously
	SpellBookFrame.suppressCloseSound = true;
	ToggleSpellBook(this.bookType);
	SpellBookFrame.suppressCloseSound = false;
end

function ToggleSpellBook(bookType)
	-- If has no pet spells and is trying to open the corresponding book, then do nothing
	if ( not HasPetSpells() and bookType == BOOKTYPE_PET ) then
		return;
	end

	local isShown = SpellBookFrame:IsShown();
	if ( isShown and (SpellBookFrame.bookType ~= bookType) ) then
		SpellBookFrame.suppressCloseSound = true;
	end

	HideUIPanel(SpellBookFrame);
	if ( (not isShown or (SpellBookFrame.bookType ~= bookType)) ) then
		SpellBookFrame.bookType = bookType;
		ShowUIPanel(SpellBookFrame);
	end
	SpellBookFrame_UpdatePages();

	SpellBookFrame.suppressCloseSound = false;
end

function SpellBookFrame_OnLoad()
	this:RegisterEvent("SPELLS_CHANGED");
	this:RegisterEvent("LEARNED_SPELL_IN_TAB");

	SpellBookFrame.bookType = BOOKTYPE_SPELL;
	-- Init page nums
	SPELLBOOK_PAGENUMBERS[1] = 1;
	SPELLBOOK_PAGENUMBERS[2] = 1;
	SPELLBOOK_PAGENUMBERS[3] = 1;
	SPELLBOOK_PAGENUMBERS[4] = 1;
	SPELLBOOK_PAGENUMBERS[5] = 1;
	SPELLBOOK_PAGENUMBERS[6] = 1;
	SPELLBOOK_PAGENUMBERS[7] = 1;
	SPELLBOOK_PAGENUMBERS[8] = 1;
	SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = 1;

	-- Set to the first tab by default
	SpellBookSkillLineTab_OnClick(1);

	-- Initialize tab flashing
	SpellBookFrame.flashTabs = nil;
end

function SpellBookFrame_OnEvent()
	if ( event == "SPELLS_CHANGED" ) then
		SpellBookFrame_UpdateTabsInfo()
		if ( SpellBookFrame:IsVisible() ) then
			SpellBookFrame_Update();
		end
	elseif ( event == "LEARNED_SPELL_IN_TAB" ) then
		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			return;
		end
		local flashFrame, tab;
		for i, data in pairs(SpellTabInfo) do
			if data.id == arg1 then
				tab = i;
				break;
			end
		end
		flashFrame = tab and _G["SpellBookSkillLineTab"..tab.."Flash"];
		if ( flashFrame ) then
			flashFrame:Show();
			SpellBookFrame.flashTabs = 1;
		end
	end
end

function SpellBookFrame_OnShow()
	UpdateMicroButtons();
	SpellBookFrame_Update(1);

	-- If there are tabs waiting to flash, then flash them... yeah..
	if ( SpellBookFrame.flashTabs ) then
		UIFrameFlash(SpellBookTabFlashFrame, 0.5, 0.5, 30, nil);
	end

	-- Show multibar slots
	MultiActionBar_ShowAllGrids();
	SpellBookFrame_PlayOpenSound();
end

function SpellBookFrame_OnHide()
	SpellBookFrame_PlayCloseSound();
	UpdateMicroButtons();

	-- Stop the flash frame from flashing if its still flashing.. flash flash flash
	UIFrameFlashRemoveFrame(SpellBookTabFlashFrame);
	-- Hide all the flashing textures
	for i=1, MAX_SKILLLINE_TABS do
		_G["SpellBookSkillLineTab"..i.."Flash"]:Hide();
	end

	-- Hide multibar slots
	MultiActionBar_HideAllGrids();
end

function SpellBookFrame_Update(showing)
	-- Hide all tabs
	SpellBookFrameTabButton1:Hide();
	SpellBookFrameTabButton2:Hide();
	SpellBookFrameTabButton3:Hide();

	-- Setup skillline tabs
	if ( showing ) then
		SpellBookSkillLineTab_OnClick(SpellBookFrame.selectedSkillLine);
		UpdateSpells();
	end

	local numSkillLineTabs = GetNumSpellTabs();
	local name, texture, offset, numSpells;
	local skillLineTab;
	for i=1, MAX_SKILLLINE_TABS do
		skillLineTab = _G["SpellBookSkillLineTab"..i];
		if ( i <= numSkillLineTabs and SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
			name, texture, offset, numSpells = SpellBook_GetTabInfo(i);
			skillLineTab:SetNormalTexture(texture);
			skillLineTab.tooltip = name;
			skillLineTab:Show();

			-- Set the selected tab
			if ( SpellBookFrame.selectedSkillLine == i ) then
				skillLineTab:SetChecked(true);
			else
				skillLineTab:SetChecked(false);
			end
		else
			skillLineTab:Hide();
		end
	end

	local point, relativeTo, relativePoint, x, y = SpellBookSkillLineTab1:GetPoint();
	if ( _G["SpellBookSkillLineTab"..MAX_SKILLLINE_TABS]:IsShown() ) then
		if y < -48 then
			SpellBookSkillLineTab1:SetPoint(point, relativeTo, relativePoint, x, -47);
		end
	else
		SpellBookSkillLineTab1:SetPoint(point, relativeTo, relativePoint, x, -65)
	end

	-- Setup tabs
	local hasPetSpells, petToken = HasPetSpells();
	SpellBookFrame.petTitle = nil;
	if ( hasPetSpells ) then
		SpellBookFrame_SetTabType(SpellBookFrameTabButton1, BOOKTYPE_SPELL);
		SpellBookFrame_SetTabType(SpellBookFrameTabButton2, BOOKTYPE_PET, petToken);
	else
		SpellBookFrame_SetTabType(SpellBookFrameTabButton1, BOOKTYPE_SPELL);

		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			-- if has no pet spells but trying to show the pet spellbook close the window;
			HideUIPanel(SpellBookFrame);
			SpellBookFrame.bookType = BOOKTYPE_SPELL;
		end
	end

	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		SpellBookTitleText:SetText(SPELLBOOK);
		SpellBookFrame_ShowSpells();
		SpellBookFrame_UpdatePages();
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		SpellBookTitleText:SetText(SpellBookFrame.petTitle);
		SpellBookFrame_ShowSpells();
		SpellBookFrame_UpdatePages();
	end
end

function SpellBookFrame_SetTabType(tabButton, bookType, token)
	if ( bookType == BOOKTYPE_SPELL ) then
		tabButton.bookType = BOOKTYPE_SPELL;
		tabButton:SetText(SPELLBOOK);
		tabButton:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 1);
		tabButton.binding = "TOGGLESPELLBOOK";
	else
		tabButton.bookType = BOOKTYPE_PET;
		tabButton:SetText(_G["PET_TYPE_"..token]);
		tabButton:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 1);
		tabButton.binding = "TOGGLEPETBOOK";
		SpellBookFrame.petTitle = _G["PET_TYPE_"..token];
	end
	if ( SpellBookFrame.bookType == bookType ) then
		tabButton:Disable();
	else
		tabButton:Enable();
	end
	tabButton:Show();
end

function SpellButton_OnLoad()
	this:RegisterForDrag("LeftButton");
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function SpellButton_OnShow()
	this:RegisterEvent("SPELLS_CHANGED");
	this:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	this:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	this:RegisterEvent("CRAFT_SHOW");
	this:RegisterEvent("CRAFT_CLOSE");
	this:RegisterEvent("TRADE_SKILL_SHOW");
	this:RegisterEvent("TRADE_SKILL_CLOSE");
	this:RegisterEvent("PET_BAR_UPDATE");
	SpellButton_UpdateButton();
end

function SpellButton_OnHide()
	this:UnregisterEvent("SPELLS_CHANGED");
	this:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
	this:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	this:UnregisterEvent("CRAFT_SHOW");
	this:UnregisterEvent("CRAFT_CLOSE");
	this:UnregisterEvent("TRADE_SKILL_SHOW");
	this:UnregisterEvent("TRADE_SKILL_CLOSE");
	this:UnregisterEvent("PET_BAR_UPDATE");
end

function SpellButton_OnEvent(event)
	if ( event == "SPELLS_CHANGED" or event == "SPELL_UPDATE_COOLDOWN" ) then
		SpellButton_UpdateButton();
	elseif ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		SpellButton_UpdateSelection();
	elseif ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		SpellButton_UpdateSelection();
	elseif ( event == "PET_BAR_UPDATE" ) then
		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			SpellButton_UpdateButton();
		end
	end
end

function SpellButton_OnEnter()
	local id = SpellBook_GetSpellID(this:GetID());
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	if ( GameTooltip:SetSpell(id, SpellBookFrame.bookType) ) then
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		this.updateTooltip = nil;
	end
end

function SpellButton_OnUpdate(elapsed)
	if ( not this.updateTooltip ) then
		return;
	end

	this.updateTooltip = this.updateTooltip - elapsed;
	if ( this.updateTooltip > 0 ) then
		return;
	end

	if ( GameTooltip:IsOwned(this) ) then
		SpellButton_OnEnter();
	else
		this.updateTooltip = nil;
	end
end

function SpellButton_OnClick(drag)
	local id = SpellBook_GetSpellID(this:GetID());
	if ( id > MAX_SPELLS ) then
		return;
	end

	if ( IsSpellPassive(id, SpellBookFrame.bookType) ) then
		return;
	end

	this:SetChecked(IsCurrentCast(id, SpellBookFrame.bookType));

	if ( drag ) then
		PickupSpell(id, SpellBookFrame.bookType);
	elseif ( IsShiftKeyDown() ) then
		if ( MacroFrame and MacroFrame:IsVisible() ) then
			local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType);
			if ( spellName ) then
				if ( subSpellName and (strlen(subSpellName) > 0) ) then
					MacroFrame_AddMacroLine(SLASH_CAST1.." "..spellName.."("..subSpellName..")");
				else
					MacroFrame_AddMacroLine(SLASH_CAST1.." "..spellName);
				end
			end
		else
			PickupSpell(id, SpellBookFrame.bookType );
		end
	elseif ( arg1 ~= "LeftButton" and SpellBookFrame.bookType == BOOKTYPE_PET ) then
		ToggleSpellAutocast(id, SpellBookFrame.bookType);
	else
		CastSpell(id, SpellBookFrame.bookType);
		SpellButton_UpdateSelection();
	end
end

function SpellButton_UpdateSelection()
	local temp, texture, offset, numSpells = SpellBook_GetTabInfo(SpellBookFrame.selectedSkillLine);
	local id = SpellBook_GetSpellID(this:GetID());
	if ( (SpellBookFrame.bookType ~= BOOKTYPE_PET) and (id > (offset + numSpells)) ) then
		this:SetChecked(false);
		return;
	end

	if ( IsCurrentCast(id,  SpellBookFrame.bookType) ) then
		this:SetChecked(true);
	else
		this:SetChecked(false);
	end
end

function SpellButton_UpdateButton()
	if ( not this:IsVisible() ) then
		return;
	end
	if ( GameTooltip:IsOwned(this) ) then
		SpellButton_OnEnter();
	end

	if ( not SpellBookFrame.selectedSkillLine ) then
		SpellBookFrame.selectedSkillLine = 1;
	end
	local temp, texture, offset, numSpells = SpellBook_GetTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineOffset = offset;
	local id = SpellBook_GetSpellID(this:GetID());
	local name = this:GetName();
	local iconTexture = _G[name.."IconTexture"];
	local spellString = _G[name.."SpellName"];
	local subSpellString = _G[name.."SubSpellName"];
	local cooldown = _G[name.."Cooldown"];
	local autoCastableTexture = _G[name.."AutoCastable"];
	local autoCastModel = _G[name.."AutoCast"];
	if ( (SpellBookFrame.bookType ~= BOOKTYPE_PET) and (id > (offset + numSpells)) ) then
		this:Disable();
		iconTexture:Hide();
		spellString:Hide();
		subSpellString:Hide();
		cooldown:Hide();
		autoCastableTexture:Hide();
		autoCastModel:Hide();
		this:SetChecked(0);
		_G[name.."NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0);
		return;
	else
		this:Enable();
	end
	local texture = GetSpellTexture(id, SpellBookFrame.bookType);
	local highlightTexture = _G[name.."Highlight"];
	local normalTexture = _G[name.."NormalTexture"];
	-- If no spell, hide everything and return
	if ( not texture or (strlen(texture) == 0) ) then
		iconTexture:Hide();
		spellString:Hide();
		subSpellString:Hide();
		cooldown:Hide();
		autoCastableTexture:Hide();
		autoCastModel:Hide();
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		this:SetChecked(0);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
		return;
	end

	local start, duration, enable = GetSpellCooldown(id, SpellBookFrame.bookType);
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
	if ( enable == 1 ) then
		iconTexture:SetVertexColor(1.0, 1.0, 1.0);
	else
		iconTexture:SetVertexColor(0.4, 0.4, 0.4);
	end

	local autoCastAllowed, autoCastEnabled = GetSpellAutocast(id, SpellBookFrame.bookType);
	if ( autoCastAllowed ) then
		autoCastableTexture:Show();
	else
		autoCastableTexture:Hide();
	end
	if ( autoCastEnabled ) then
		autoCastModel:Show();
	else
		autoCastModel:Hide();
	end

	local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType);
	local isPassive = IsSpellPassive(id, SpellBookFrame.bookType);
	if ( isPassive ) then
		normalTexture:SetVertexColor(0, 0, 0);
		highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
		spellString:SetTextColor(PASSIVE_SPELL_FONT_COLOR.r, PASSIVE_SPELL_FONT_COLOR.g, PASSIVE_SPELL_FONT_COLOR.b);
	else
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	iconTexture:SetTexture(texture);
	spellString:SetText(spellName);
	subSpellString:SetText(subSpellName);
	if ( subSpellName ~= "" ) then
		spellString:SetPoint("LEFT", this, "RIGHT", 4, 4);
	else
		spellString:SetPoint("LEFT", this, "RIGHT", 4, 2);
	end

	iconTexture:Show();
	spellString:Show();
	subSpellString:Show();
	SpellButton_UpdateSelection();
end

function PrevPageButton_OnClick()
	local pageNum = SpellBook_GetCurrentPage() - 1;
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = pageNum;
	else
		SpellBookTitleText:SetText(SpellBookFrame.petTitle);
		-- Need to change to pet book pageturn sound
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = pageNum;
	end
	SpellBook_UpdatePageArrows();
	SpellBookPageText:SetText(format(PAGE_NUMBER, pageNum));
	UpdateSpells();
end

function NextPageButton_OnClick()
	local pageNum = SpellBook_GetCurrentPage() + 1;
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = pageNum;
	else
		SpellBookTitleText:SetText(SpellBookFrame.petTitle);
		-- Need to change to pet book pageturn sound
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = pageNum;
	end
	SpellBook_UpdatePageArrows();
	SpellBookPageText:SetText(format(PAGE_NUMBER, pageNum));
	UpdateSpells();
end

function SpellBookSkillLineTab_OnClick(id)
	local update;
	if ( not id ) then
		update = 1;
		id = this:GetID();
	end
	if ( SpellBookFrame.selectedSkillLine ~= id ) then
		PlaySound("igAbiliityPageTurn");
	end
	SpellBookFrame.selectedSkillLine = id;
	local name, texture, offset, numSpells = SpellBook_GetTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineOffset = offset;
	SpellBookFrame.selectedSkillLineNumSpells = numSpells;
	SpellBook_UpdatePageArrows();
	SpellBookFrame_Update();
	SpellBookPageText:SetText(format(PAGE_NUMBER, SpellBook_GetCurrentPage()));
	if ( update ) then
		UpdateSpells();
	end
	-- Stop tab flashing
	local tabFlash = _G[this:GetName().."Flash"];
	if ( tabFlash ) then
		tabFlash:Hide();
	end
end

function SpellBook_GetSpellID(id)
	if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		return id + (SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] - 1));
	else
		return id + SpellBookFrame.selectedSkillLineOffset + ( SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] - 1));
	end
end

function SpellBook_UpdatePageArrows()
	local currentPage, maxPages = SpellBook_GetCurrentPage();
	if ( currentPage == 1 ) then
		SpellBookPrevPageButton:Disable();
	else
		SpellBookPrevPageButton:Enable();
	end
	if ( currentPage == maxPages ) then
		SpellBookNextPageButton:Disable();
	else
		SpellBookNextPageButton:Enable();
	end
end

function SpellBook_GetCurrentPage()
	local currentPage, maxPages;
	local numPetSpells = HasPetSpells();
	if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		currentPage = SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET];
		maxPages = ceil(numPetSpells/SPELLS_PER_PAGE);
	else
		currentPage = SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine];
		local name, texture, offset, numSpells = SpellBook_GetTabInfo(SpellBookFrame.selectedSkillLine);
		maxPages = ceil(numSpells/SPELLS_PER_PAGE);
	end
	return currentPage, maxPages;
end

function SpellBookFrame_HideSpells()
	for i = 1, SPELLS_PER_PAGE do
		_G["SpellButton" .. i]:Hide();
	end
	for i = 1, MAX_SKILLLINE_TABS do
		_G["SpellBookSkillLineTab" .. i]:Hide();
	end
	SpellBookPrevPageButton:Hide();
	SpellBookNextPageButton:Hide();
	SpellBookPageText:Hide();
end

function SpellBookFrame_ShowSpells()
	for i = 1, SPELLS_PER_PAGE do
		_G["SpellButton" .. i]:Show();
	end
	SpellBookPrevPageButton:Show();
	SpellBookNextPageButton:Show();
	SpellBookPageText:Show();
end

function SpellBookFrame_UpdatePages()
	local currentPage, maxPages = SpellBook_GetCurrentPage();
	if ( maxPages == 0 ) then
		return;
	end
	if ( currentPage > maxPages ) then
		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = maxPages;
		else
			SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = maxPages;
		end
		currentPage = maxPages;
		UpdateSpells();
		if ( currentPage == 1 ) then
			SpellBookPrevPageButton:Disable();
		else
			SpellBookPrevPageButton:Enable();
		end
		if ( currentPage == maxPages ) then
			SpellBookNextPageButton:Disable();
		else
			SpellBookNextPageButton:Enable();
		end
	end
	if ( currentPage == 1 ) then
		SpellBookPrevPageButton:Disable();
	else
		SpellBookPrevPageButton:Enable();
	end
	if ( currentPage == maxPages ) then
		SpellBookNextPageButton:Disable();
	else
		SpellBookNextPageButton:Enable();
	end
	SpellBookPageText:SetText(format(PAGE_NUMBER, currentPage));
end

function SpellBookFrame_PlayOpenSound()
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igSpellBookOpen");
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		-- Need to change to pet book open sound
		PlaySound("igAbilityOpen");
	else
		PlaySound("igSpellBookOpen");
	end
end

function SpellBookFrame_PlayCloseSound()
	if ( not SpellBookFrame.suppressCloseSound ) then
		if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
			PlaySound("igSpellBookClose");
		else
			-- Need to change to pet book close sound
			PlaySound("igAbilityClose");
		end
	end
end
