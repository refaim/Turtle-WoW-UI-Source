function RealmWizard_OnLoad()
	this:SetSequence(0);
	this:SetCamera(0);
end

function RealmWizard_OnShow()
	RealmWizardGameTypeButton1:Click(1);
	if ( not RealmWizard.selectedCategory ) then
		RealmWizardSuggest:Disable();
	end
	RealmWizard_UpdateCategories(GetRealmCategories());
end

function RealmWizard_UpdateCategories(...)
	if ( arg.n > MAX_REALM_CATEGORY_TABS ) then
		message("Not enough category tabs!  Tell Derek");
	end
	local button, buttonText;
	local numCategoriesShown = 0;
	for i=1, MAX_REALM_CATEGORY_TABS do
		button = getglobal("RealmWizardLocationButton"..i);
		buttonText = getglobal("RealmWizardLocationButton"..i.."Text");
		if ( i <= arg.n ) then
			buttonText:SetText(arg[i]);
			if ( i == RealmWizard.selectedCategory ) then
				button:SetChecked(1);
			else
				button:SetChecked(nil);
			end
			button:Show();
			numCategoriesShown = numCategoriesShown + 1;
		else
			button:Hide();
		end
	end
	RealmWizardLocation:SetHeight(numCategoriesShown * 28 + RealmWizardLocationLabelDescription:GetHeight() + 50);
end

function RealmWizardLocationButton_OnClick(id)
	RealmWizardSuggest:Enable();
	RealmWizard.selectedCategory = id;
	RealmWizard_UpdateCategories(GetRealmCategories());
end

-- Wrapper function so it can be included as a dialog function
function RealmWizard_SetRealm()
	ChangeRealm(RealmWizard.suggestedCategory, RealmWizard.suggestedID);
end

function RealmWizard_Exit()
	DisconnectFromServer();
	SetGlueScreen("login");
end

function RealmWizard_OnKeyDown()
	if ( arg1 == "ESCAPE" ) then
		RealmWizard_Exit();
	elseif ( arg1 == "ENTER" ) then
		RealmWizardSuggest:Click();
	elseif ( arg1 == "PRINTSCREEN" ) then
		Screenshot();
	end
end
