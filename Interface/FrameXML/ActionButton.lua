CURRENT_ACTIONBAR_PAGE = 1;
NUM_ACTIONBAR_PAGES = 6;
NUM_ACTIONBAR_BUTTONS = 12;
ATTACK_BUTTON_FLASH_TIME = 0.4;

BOTTOMLEFT_ACTIONBAR_PAGE = 6;
BOTTOMRIGHT_ACTIONBAR_PAGE = 5;
LEFT_ACTIONBAR_PAGE = 4;
RIGHT_ACTIONBAR_PAGE = 3;
RANGE_INDICATOR = "●";

-- Table of actionbar pages and whether they're viewable or not
VIEWABLE_ACTION_BAR_PAGES = {1, 1, 1, 1, 1, 1};

function ActionButtonDown(id)
	local button;
	if ( BonusActionBarFrame:IsShown() ) then
		button = _G["BonusActionButton"..id];
	else
		button = _G["ActionButton"..id];
	end
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
end

function ActionButtonUp(id, onSelf)
	local button;
	if ( BonusActionBarFrame:IsShown() ) then
		button = _G["BonusActionButton"..id];
	else
		button = _G["ActionButton"..id];
	end

	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		if ( MacroFrame_SaveMacro ) then
			MacroFrame_SaveMacro();
		end
		UseAction(button.action, 0, onSelf);
		if ( IsCurrentAction(button.action) ) then
			button:SetChecked(1);
		else
			button:SetChecked(0);
		end
	end
end

function ActionBar_PageUp()
	CURRENT_ACTIONBAR_PAGE = CURRENT_ACTIONBAR_PAGE + 1;
	local nextPage;
	for i=CURRENT_ACTIONBAR_PAGE, NUM_ACTIONBAR_PAGES do
		if ( VIEWABLE_ACTION_BAR_PAGES[i] ) then
			nextPage = i;
			break;
		end
	end

	if ( not nextPage ) then
		CURRENT_ACTIONBAR_PAGE = 1;
	else
		CURRENT_ACTIONBAR_PAGE = nextPage;
	end
	ChangeActionBarPage();
end

function ActionBar_PageDown()
	CURRENT_ACTIONBAR_PAGE = CURRENT_ACTIONBAR_PAGE - 1;
	local prevPage;
	for i=CURRENT_ACTIONBAR_PAGE, 1, -1 do
		if ( VIEWABLE_ACTION_BAR_PAGES[i] ) then
			prevPage = i;
			break;
		end
	end

	if ( not prevPage ) then
		for i=NUM_ACTIONBAR_PAGES, 1, -1 do
			if ( VIEWABLE_ACTION_BAR_PAGES[i] ) then
				prevPage = i;
				break;
			end
		end
	end
	CURRENT_ACTIONBAR_PAGE = prevPage;
	ChangeActionBarPage();
end

function ActionButton_OnLoad()
	this.showgrid = 0;
	this.flashing = 0;
	this.flashtime = 0;
	this:RegisterForDrag("LeftButton", "RightButton");
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("ACTIONBAR_SHOWGRID");
	this:RegisterEvent("ACTIONBAR_HIDEGRID");
	this:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	this:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	this:RegisterEvent("UPDATE_BINDINGS");
	ActionButton_UpdateAction();
	ActionButton_UpdateHotkeys(this.buttonType);
end

function ActionButton_UpdateHotkeys(actionButtonType)
	if ( not actionButtonType ) then
		actionButtonType = "ACTIONBUTTON";
	end
	local hotkey = _G[this:GetName().."HotKey"];
	local binding = actionButtonType..this:GetID();
	local action = this.action;

	if ( GetBindingText(GetBindingKey(binding), "KEY_", 1) == "" ) then
		if ( not HasAction(action) ) then
			hotkey:SetText("");
		elseif ( ActionHasRange(action) ) then
			if ( IsActionInRange(action) ) then
				hotkey:SetText(RANGE_INDICATOR);
				hotkey:SetTextHeight(8);
				hotkey:SetPoint("TOPRIGHT", this:GetName(), "TOPRIGHT", -3, 5);
			else
				hotkey:SetText("");
			end
		end
	else
		hotkey:SetText(GetBindingText(GetBindingKey(binding), "KEY_", 1));
	end
end

function ActionButton_Update()
	local name = this:GetName();
	local action = this.action;
	local icon = _G[name.."Icon"];
	local buttonCooldown = _G[name.."Cooldown"];
	local texture = GetActionTexture(action);

	if ( HasAction(action) ) then
		if ( not this.eventsRegistered ) then
			this:RegisterEvent("ACTIONBAR_UPDATE_STATE");
			this:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
			this:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
			this:RegisterEvent("PLAYER_AURAS_CHANGED");
			this:RegisterEvent("PLAYER_TARGET_CHANGED");
			this:RegisterEvent("UNIT_INVENTORY_CHANGED");
			this:RegisterEvent("CRAFT_SHOW");
			this:RegisterEvent("CRAFT_CLOSE");
			this:RegisterEvent("TRADE_SKILL_SHOW");
			this:RegisterEvent("TRADE_SKILL_CLOSE");
			this:RegisterEvent("PLAYER_ENTER_COMBAT");
			this:RegisterEvent("PLAYER_LEAVE_COMBAT");
			this:RegisterEvent("START_AUTOREPEAT_SPELL");
			this:RegisterEvent("STOP_AUTOREPEAT_SPELL");
			this.eventsRegistered = 1;
		end
		this:Show();
		ActionButton_UpdateState();
		ActionButton_UpdateUsable();
		ActionButton_UpdateCooldown();
		ActionButton_UpdateFlash();
	else
		if ( this.eventsRegistered ) then
			this:UnregisterEvent("ACTIONBAR_UPDATE_STATE");
			this:UnregisterEvent("ACTIONBAR_UPDATE_USABLE");
			this:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			this:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
			this:UnregisterEvent("PLAYER_AURAS_CHANGED");
			this:UnregisterEvent("PLAYER_TARGET_CHANGED");
			this:UnregisterEvent("UNIT_INVENTORY_CHANGED");
			this:UnregisterEvent("CRAFT_SHOW");
			this:UnregisterEvent("CRAFT_CLOSE");
			this:UnregisterEvent("TRADE_SKILL_SHOW");
			this:UnregisterEvent("TRADE_SKILL_CLOSE");
			this:UnregisterEvent("PLAYER_ENTER_COMBAT");
			this:UnregisterEvent("PLAYER_LEAVE_COMBAT");
			this:UnregisterEvent("START_AUTOREPEAT_SPELL");
			this:UnregisterEvent("STOP_AUTOREPEAT_SPELL");
			this.eventsRegistered = nil;
		end
		if ( this.showgrid == 0 ) then
			this:Hide();
		else
			buttonCooldown:Hide();
		end
	end

	-- Add a green border if button is an equipped item
	local border = _G[name.."Border"];
	if ( IsEquippedAction(action) ) then
		border:SetVertexColor(0, 1.0, 0, 0.35);
		border:Show();
	else
		border:Hide();
	end

	-- Update Macro Text
	local macroName = _G[name.."Name"];
	macroName:SetText(GetActionText(action));

	if ( texture ) then
		icon:SetTexture(texture);
		icon:Show();
		this.rangeTimer = -1;
		this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
	else
		icon:Hide();
		buttonCooldown:Hide();
		this.rangeTimer = nil;
		this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		local hotkey = _G[name.."HotKey"];
		if ( hotkey:GetText() == RANGE_INDICATOR ) then
			hotkey:Hide();
		else
			hotkey:SetVertexColor(0.6, 0.6, 0.6);
		end
	end
	ActionButton_UpdateCount();

	if ( GameTooltip:IsOwned(this) ) then
		ActionButton_SetTooltip();
	else
		this.updateTooltip = nil;
	end
end

function ActionButton_ShowGrid(button)
	if ( not button ) then
		button = this;
	end
	button.showgrid = button.showgrid + 1;
	_G[button:GetName().."NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0, 0.5);
	button:Show();
end

function ActionButton_HideGrid(button)
	if ( not button ) then
		button = this;
	end
	if ( button.showgrid > 0 ) then
		button.showgrid = button.showgrid - 1;
	end
	if ( button.showgrid == 0 and not HasAction(button.action) ) then
		button:Hide();
	end
end

function ActionButton_UpdateState()
	if ( IsCurrentAction(this.action) or IsAutoRepeatAction(this.action) ) then
		this:SetChecked(1);
	else
		this:SetChecked(0);
	end
end

function ActionButton_UpdateUsable()
	local icon = _G[this:GetName().."Icon"];
	local normalTexture = _G[this:GetName().."NormalTexture"];
	local isUsable, notEnoughMana = IsUsableAction(this.action);
	if ( isUsable ) then
		icon:SetVertexColor(1.0, 1.0, 1.0);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	elseif ( notEnoughMana ) then
		icon:SetVertexColor(0.5, 0.5, 1.0);
		normalTexture:SetVertexColor(0.5, 0.5, 1.0);
	else
		icon:SetVertexColor(0.4, 0.4, 0.4);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
end

function ActionButton_UpdateCount()
	local text = _G[this:GetName().."Count"];
	if ( IsConsumableAction(this.action) ) then
		text:SetText(GetActionCount(this.action));
	else
		text:SetText("");
	end
end

function ActionButton_UpdateCooldown()
	local cooldown = _G[this:GetName().."Cooldown"];
	local start, duration, enable = GetActionCooldown(this.action);
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
end

function ActionButton_UpdateAction()
	local action = ActionButton_GetPagedID(this);
	if ( action ~= this.action ) then
		this.action = action;
		ActionButton_Update();
	end
end

function ActionButton_OnEvent(event)
	if ( event == "ACTIONBAR_SLOT_CHANGED" ) then
		if ( arg1 == 0 or arg1 == this.action ) then
			ActionButton_Update();
		end
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		ActionButton_Update();
		return;
	end
	if ( event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_BONUS_ACTIONBAR" ) then
		ActionButton_UpdateAction();
		return;
	end
	if ( event == "ACTIONBAR_SHOWGRID" ) then
		ActionButton_ShowGrid();
		return;
	end
	if ( event == "ACTIONBAR_HIDEGRID" ) then
		ActionButton_HideGrid();
		return;
	end
	if ( event == "UPDATE_BINDINGS" ) then
		ActionButton_UpdateHotkeys(this.buttonType);
		return;
	end

	-- All event handlers below this line are only set when the button has an action

	if ( event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_AURAS_CHANGED" ) then
		ActionButton_UpdateUsable();
		ActionButton_UpdateHotkeys(this.buttonType);
	elseif ( event == "UNIT_INVENTORY_CHANGED" ) then
		if ( arg1 == "player" ) then
			ActionButton_Update();
		end
	elseif ( event == "ACTIONBAR_UPDATE_STATE" ) then
		ActionButton_UpdateState();
	elseif ( event == "ACTIONBAR_UPDATE_USABLE" or event == "UPDATE_INVENTORY_ALERTS" or event == "ACTIONBAR_UPDATE_COOLDOWN" ) then
		ActionButton_UpdateUsable();
		ActionButton_UpdateCooldown();
	elseif ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		ActionButton_UpdateState();
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		if ( IsAttackAction(this.action) ) then
			ActionButton_StartFlash();
		end
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		if ( IsAttackAction(this.action) ) then
			ActionButton_StopFlash();
		end
	elseif ( event == "START_AUTOREPEAT_SPELL" ) then
		if ( IsAutoRepeatAction(this.action) ) then
			ActionButton_StartFlash();
		end
	elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
		if ( ActionButton_IsFlashing() and not IsAttackAction(this.action) ) then
			ActionButton_StopFlash();
		end
	end
end

function ActionButton_SetTooltip()
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, this);
	else
		local parent = this:GetParent();
		if ( parent == MultiBarBottomRight or parent == MultiBarRight or parent == MultiBarLeft ) then
			GameTooltip:SetOwner(this, "ANCHOR_LEFT");
		else
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
		end
	end

	if ( GameTooltip:SetAction(this.action) ) then
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		this.updateTooltip = nil;
	end
end

function ActionButton_OnUpdate(elapsed)
	local hotkey = _G[this:GetName().."HotKey"];
	local action = this.action;

	if ( hotkey:GetText() == RANGE_INDICATOR ) then
		if ( IsActionInRange(action) == 1 ) then
			hotkey:Hide();
		else
			hotkey:Show();
		end
	end

	if ( ActionButton_IsFlashing() ) then
		local flashtime = this.flashtime;
		flashtime = flashtime - elapsed;
		if ( this.flashtime <= 0 ) then
			local overtime = -flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

			local flashTexture = _G[this:GetName().."Flash"];
			if ( flashTexture:IsVisible() ) then
				flashTexture:Hide();
			else
				flashTexture:Show();
			end
		end
		this.flashtime = flashtime;
	end

	-- Handle range indicator
	local rangeTimer = this.rangeTimer;
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed;

		if ( rangeTimer <= 0 ) then
			local count = _G[this:GetName().."HotKey"];
			if ( IsActionInRange(action) == 0 ) then
				count:SetVertexColor(1.0, 0.1, 0.1);
			else
				count:SetVertexColor(0.6, 0.6, 0.6);
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end
		this.rangeTimer = rangeTimer;
	end

	if ( not this.updateTooltip ) then
		return;
	end

	this.updateTooltip = this.updateTooltip - elapsed;
	if ( this.updateTooltip > 0 ) then
		return;
	end

	if ( GameTooltip:IsOwned(this) ) then
		ActionButton_SetTooltip();
	else
		this.updateTooltip = nil;
	end
end

function ActionButton_GetPagedID(button)
	if ( button.isBonus and CURRENT_ACTIONBAR_PAGE == 1 ) then
		local offset = GetBonusBarOffset();
		if ( offset == 0 and BonusActionBarFrame and BonusActionBarFrame.lastBonusBar ) then
			offset = BonusActionBarFrame.lastBonusBar;
		end
		return (button:GetID() + ((NUM_ACTIONBAR_PAGES + offset - 1) * NUM_ACTIONBAR_BUTTONS));
	end

	local parentName = button:GetParent():GetName();
	if ( parentName == "MultiBarBottomLeft" ) then
		return (button:GetID() + ((BOTTOMLEFT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS));
	elseif ( parentName == "MultiBarBottomRight" ) then
		return (button:GetID() + ((BOTTOMRIGHT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS));
	elseif ( parentName == "MultiBarLeft" ) then
		return (button:GetID() + ((LEFT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS));
	elseif ( parentName == "MultiBarRight" ) then
		return (button:GetID() + ((RIGHT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS));
	else
		return (button:GetID() + ((CURRENT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
	end
end

function ActionButton_UpdateFlash()
	local action = this.action;
	if ( (IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action) ) then
		ActionButton_StartFlash();
	else
		ActionButton_StopFlash();
	end
end

function ActionButton_StartFlash()
	this.flashing = 1;
	this.flashtime = 0;
	ActionButton_UpdateState();
end

function ActionButton_StopFlash()
	this.flashing = 0;
	_G[this:GetName().."Flash"]:Hide();
	ActionButton_UpdateState();
end

function ActionButton_IsFlashing()
	if ( this.flashing == 1 ) then
		return 1;
	else
		return nil;
	end
end
