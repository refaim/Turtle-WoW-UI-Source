REALM_BUTTON_HEIGHT = 16;
MAX_REALMS_DISPLAYED = 18;
REALM_LIST_REFRESH_TIME = 5;
MAX_REALM_CATEGORY_TABS = 8;

function RealmList_OnLoad()
	this:RegisterEvent("OPEN_REALM_LIST");
	this.currentRealm = 0;
	this.offset = 0;
end

function RealmList_OnEvent()
	if ( event == "OPEN_REALM_LIST" ) then
		if ( this:IsVisible() ) then
			RealmListUpdate();
		else
			this:Show();
		end
	end
end

function RealmListUpdate()
	-- Just for the first time the frame is loaded
	if ( not RealmList.selectedCategory ) then
		RealmList.selectedCategory = 1;
	end
	
	-- Set the refresh timer
	RealmList.refreshTime = REALM_LIST_REFRESH_TIME;

	-- Set up the category tabs
	RealmList_UpdateTabs(GetRealmCategories());

	local numRealms = GetNumRealms(RealmList.selectedCategory);
	local name, numCharacters, invalidRealm, currentRealm, pvp, rp, load;
	local realmIndex;
	local pvpText, loadText, isFull;

	RealmListOkButton:Disable();
	RealmListHighlight:Hide();
	for i=1, MAX_REALMS_DISPLAYED, 1 do
		realmIndex = RealmList.offset + i;
		local button = getglobal("RealmListRealmButton"..i);
		if ( realmIndex > numRealms ) then
			button:Hide();
		else
			name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load = GetRealmInfo(RealmList.selectedCategory, realmIndex);

			if ( not name ) then
				button:Hide();
			else
				pvpText = getglobal("RealmListRealmButton"..i.."PVP");
				if ( pvp and rp ) then
					pvpText:SetText(RPPVP_PARENTHESES);
					pvpText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				elseif ( rp ) then
					pvpText:SetText(RP_PARENTHESES);
					pvpText:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				elseif ( pvp ) then
					pvpText:SetText(PVP_PARENTHESES);
					pvpText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				else
					pvpText:SetText(GAMETYPE_NORMAL);
					pvpText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end

				isFull = nil;
				loadText = getglobal("RealmListRealmButton"..i.."Load");
				
				if ( realmDown ) then
					loadText:SetText(REALM_DOWN);
					loadText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				elseif ( load == -3.0 ) then
					loadText:SetText(LOAD_RECOMMENDED);
					loadText:SetTextColor(BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b);
				elseif ( load == -2.0 ) then
					loadText:SetText(LOAD_NEW);
					loadText:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				elseif ( load == 2.0 ) then
					loadText:SetText(LOAD_FULL);
					loadText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
					isFull = 1;
				elseif ( load > 0 ) then
					loadText:SetText(LOAD_HIGH);
					loadText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				elseif ( load < 0 ) then
					loadText:SetText(LOAD_LOW);
					loadText:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				else
					loadText:SetText(LOAD_MEDIUM);
					loadText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end

				button:SetText(name);
				players = getglobal("RealmListRealmButton"..i.."Players");
				if ( numCharacters > 0 ) then
					players:SetText("("..numCharacters..")");
				else
					players:SetText("");
				end
				if ( realmDown ) then
					button:SetTextColor(0.5, 0.5, 0.5);
					button:SetHighlightTextColor(0.8, 0.8, 0.8);
				else
					if ( invalidRealm ) then
						button:SetTextColor(1.0, 0.1, 0.1);
						button:SetHighlightTextColor(1.0, 0.5, 0.5);
					else
						if ( numCharacters > 0 ) then
							button:SetTextColor(0.1, 1.0, 0.1);
							button:SetHighlightTextColor(1.0, 1.0, 1.0);
						else
							button:SetTextColor(1.0, 0.78, 0.0);
							button:SetHighlightTextColor(1.0, 1.0, 1.0);
						end
						
					end
				end
				
				button:Show();
				button:SetID(realmIndex);
				button.name = name;

				if ( realmDown ) then
					button:Disable();
				else
					button:Enable();
				end
				
				if ( RealmList.selectedName ) then
					if ( name == RealmList.selectedName ) then
						RealmList.currentRealm = realmIndex;
						button:LockHighlight();
						RealmListOkButton:Enable();
						RealmListHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
						
						-- If realm is full and the player has no chars on that server show a dialog
						if ( isFull and numCharacters == 0 ) then
							RealmList.showRealmIsFullDialog = 1;
						else
							RealmList.showRealmIsFullDialog = nil;
						end
						
						if ( realmDown ) then
							RealmListHighlight:Hide();
							RealmListOkButton:Disable();
						else
							RealmListHighlight:Show();
							pvpText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
							loadText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
							RealmListOkButton:Enable();
							if ( invalidRealm ) then
								RealmListHighlightTexture:SetVertexColor(1.0, 0.1, 0.1);
							else
								if ( numCharacters > 0 ) then
									RealmListHighlightTexture:SetVertexColor(0.1, 1.0, 0.1);
								else
									RealmListHighlightTexture:SetVertexColor(1.0, 0.78, 0.0);
								end
							end
						end
					else
						button:UnlockHighlight();
					end
				else
					if ( currentRealm == 1 ) then
						RealmList.currentRealm = realmIndex;
						button:LockHighlight();
						RealmListHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
						if ( realmDown ) then
							RealmListHighlight:Hide();
							RealmListOkButton:Disable();
						else
							RealmListHighlight:Show();
							pvpText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
							loadText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
							RealmListOkButton:Enable();
							if ( invalidRealm ) then
								RealmListHighlightTexture:SetVertexColor(1.0, 0.1, 0.1);
							else
								if ( numCharacters > 0 ) then
									RealmListHighlightTexture:SetVertexColor(0.1, 1.0, 0.1);
								else
									RealmListHighlightTexture:SetVertexColor(1.0, 0.78, 0.0);
								end
							end
						end
					else
						button:UnlockHighlight();
					end
				end			
			end
		end
	end

	RealmList.selectedName = nil;

	-- ScrollFrame stuff
	GlueScrollFrame_Update(RealmListScrollFrame, numRealms, MAX_REALMS_DISPLAYED, REALM_BUTTON_HEIGHT, RealmListHighlight, 557,  587);
end

function RealmList_UpdateTabs(...)
	if ( arg.n > MAX_REALM_CATEGORY_TABS ) then
		message("Not enough category tabs!  Tell Derek");
	end
	local tab;
	for i=1, MAX_REALM_CATEGORY_TABS do
		tab = getglobal("RealmListTab"..i);
		if ( arg.n == 1 ) then
			tab:Hide();
		elseif ( i <= arg.n ) then
			tab:SetText(arg[i]);
			GlueTemplates_TabResize(0, tab);
			tab:Show();
		else
			tab:Hide();
		end
	end
	GlueTemplates_SetNumTabs(RealmList, arg.n);
	if ( not GlueTemplates_GetSelectedTab(RealmList) ) then
		GlueTemplates_SetTab(RealmList, 1);
	end
end

function RealmList_OnKeyDown()
	if ( arg1 == "ESCAPE" ) then
		RealmList_OnCancel();
	elseif ( arg1 == "ENTER" ) then
		RealmList_OnOk();
	elseif ( arg1 == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function RealmList_OnOk()
	PlaySound("gsLoginChangeRealmOK");
	RealmList:Hide();
	-- If trying to join a Full realm then popup a dialog
	if ( RealmList.showRealmIsFullDialog ) then
		GlueDialog_Show("REALM_IS_FULL");
		return;
	end
	if ( RealmList.currentRealm > 0 ) then
		ChangeRealm(RealmList.selectedCategory , RealmList.currentRealm);
	end
end

function RealmList_OnCancel()
	PlaySound("gsLoginChangeRealmCancel");
	RealmList:Hide();
	RealmListDialogCancelled();
	if ( GetNumRealms(RealmList.selectedCategory) == 0 ) then
		SetGlueScreen("realmwizard");
	end
end

function RealmSelectButton_OnClick(id)
	RealmList.refreshTime = REALM_LIST_REFRESH_TIME;
	RealmList.currentRealm = id;
	RealmList.selectedName = this.name;
	RealmListUpdate();
end

function RealmSelectButton_OnDoubleClick(id)
	RealmList.currentRealm = id;
	RealmList.selectedName = this.name;
	RealmList_OnOk();
end

function RealmListScrollFrame_OnVerticalScroll()
	RealmList.refreshTime = REALM_LIST_REFRESH_TIME;
	local scrollbar = getglobal(this:GetName().."ScrollBar");
	scrollbar:SetValue(arg1);
	RealmList.offset = floor((arg1 / REALM_BUTTON_HEIGHT) + 0.5);
	RealmListUpdate();
end

function RealmList_OnShow()
	this.refreshTime = REALM_LIST_REFRESH_TIME;
	local selectedCategory = GetSelectedCategory();
	if ( selectedCategory == 0 ) then
		selectedCategory = 1;
	end
	local button = getglobal("RealmListTab"..selectedCategory);
	if ( button ) then
		RealmListTab_OnClick(button);
		GlueTemplates_SetTab(RealmList, selectedCategory);
	end
	RealmListUpdate();
end

function RealmList_OnHide()
	CancelRealmListQuery();
end

function RealmList_OnUpdate(elapsed)
	if ( this.refreshTime ) then
		this.refreshTime = this.refreshTime - elapsed;
		if ( this.refreshTime <= 0 ) then
			this.refreshTime = nil;
			RequestRealmList();
		end
	end
end

function RealmListTab_OnClick(tab)
	if ( not tab ) then
		tab = this;
	end
	RealmList.selectedCategory = tab:GetID();
	RealmListUpdate();
end
