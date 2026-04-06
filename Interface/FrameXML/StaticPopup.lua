
STATICPOPUP_NUMDIALOGS = 4;
StaticPopup_DisplayedFrames = {};
StaticPopupDialogs = {};

StaticPopupDialogs["TAKE_GM_SURVEY"] = {
	text = TAKE_GM_SURVEY,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		GMSurveyFrame_LoadUI();
		ShowUIPanel(GMSurveyFrame);
		TicketStatusFrame:Hide();
	end,
	OnCancel = function()
		TicketStatusFrame.hasGMSurvey = nil;
		TicketStatusFrame:Hide();
	end,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_RESET_INSTANCES"] = {
	text = CONFIRM_RESET_INSTANCES,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ResetInstances();
	end,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_TOGGLE_XP_ON"] = {
	text = CONFIRM_TOGGLE_XP_ON,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		SendChatMessage(".xp on", "GUILD");
	end,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_TOGGLE_XP_OFF"] = {
	text = CONFIRM_TOGGLE_XP_OFF,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		SendChatMessage(".xp off", "GUILD");
	end,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_GUILD_DISBAND"] = {
	text = CONFIRM_GUILD_DISBAND,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		GuildDisband();
	end,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_BUY_BANK_SLOT"] = {
	text = CONFIRM_BUY_BANK_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		PurchaseSlot();
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", BankFrame.nextSlotCost);
	end,
	hasMoneyFrame = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_BUY_STABLE_SLOT"] = {
	text = CONFIRM_BUY_STABLE_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		BuyStableSlot();
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", GetNextStableSlotCost());
	end,
	hasMoneyFrame = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["MACRO_ACTION_FORBIDDEN"] = {
	text = MACRO_ACTION_FORBIDDEN,
	button1 = OKAY,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
	text = ADDON_ACTION_FORBIDDEN,
	button1 = DISABLE,
	button2 = IGNORE,
	OnAccept = function(data)
		DisableAddOn(data);
		ReloadUI();
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"] = {
	text = CONFIRM_LOOT_DISTRIBUTION,
	button1 = YES,
	button2 = NO,
	OnAccept = function(data)
		GiveMasterLoot(LootFrame.selectedSlot, data);
	end,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = {
	text = CONFIRM_BATTLEFIELD_ENTRY,
	button1 = ENTER_BATTLE,
	button2 = HIDE,
	OnAccept = function(data)
		AcceptBattlefieldPort(data, 1);
	end,
	whileDead = 1,
	hideOnEscape = 1,
	multiple = 1
};

StaticPopupDialogs["CONFIRM_GUILD_LEAVE"] = {
	text = CONFIRM_GUILD_LEAVE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		GuildLeave();
	end,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_GUILD_PROMOTE"] = {
	text = CONFIRM_GUILD_PROMOTE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(name)
		GuildSetLeaderByName(name);
	end,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["RENAME_GUILD"] = {
	text = RENAME_GUILD_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 24,
	OnAccept = function()
		local text = _G[this:GetParent():GetName().."EditBox"]:GetText();
		RenamePetition(text);
	end,
	EditBoxOnEnterPressed = function()
		local text = _G[this:GetParent():GetName().."EditBox"]:GetText();
		RenamePetition(text);
		this:GetParent():Hide();
	end,
	OnShow = function()
		_G[this:GetName().."EditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."EditBox"]:SetText("");
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["HELP_TICKET_QUEUE_DISABLED"] = {
	text = HELP_TICKET_QUEUE_DISABLED,
	button1 = OKAY,
	showAlert = 1,
}

StaticPopupDialogs["CONFIRM_LEAVE_QUEUE"] = {
	text = CONFIRM_LEAVE_QUEUE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		CancelMeetingStoneRequest();
	end,
	hideOnEscape = 1
};

StaticPopupDialogs["CLIENT_RESTART_ALERT"] = {
	text = CLIENT_RESTART_ALERT,
	button1 = OKAY,
	showAlert = 1,
};

StaticPopupDialogs["MEMORY_EXHAUSTED"] = {
	text = MEMORY_EXHAUSTED,
	button1 = QUIT_NOW,
	OnAccept = function()
		ForceQuit();
	end,
	whileDead = 1,
};

StaticPopupDialogs["COD_ALERT"] = {
	text = COD_INSUFFICIENT_MONEY,
	button1 = CLOSE,
	hideOnEscape = 1
};

StaticPopupDialogs["COD_CONFIRMATION"] = {
	text = COD_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		TakeInboxItem(InboxFrame.openMailID);
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", OpenMailFrame.cod);
	end,
	hasMoneyFrame = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["DELETE_MAIL"] = {
	text = DELETE_MAIL_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		DeleteInboxItem(InboxFrame.openMailID);
		InboxFrame.openMailID = nil;
		HideUIPanel(OpenMailFrame);
	end,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["DELETE_MONEY"] = {
	text = DELETE_MONEY_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		DeleteInboxItem(InboxFrame.openMailID);
		InboxFrame.openMailID = nil;
		HideUIPanel(OpenMailFrame);
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", OpenMailFrame.money);
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SEND_MONEY"] = {
	text = SEND_MONEY_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		if ( SetSendMailMoney(MoneyInputFrame_GetCopper(SendMailMoney)) ) then
			SendMailFrame_SendMail();
		end
	end,
	OnCancel = function()
		SendMailMailButton:Enable();
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", MoneyInputFrame_GetCopper(SendMailMoney));
	end,
	hasMoneyFrame = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["JOIN_CHANNEL"] = {
	text = ADD_CHANNEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnAccept = function()
		local channel = _G[this:GetParent():GetName().."EditBox"]:GetText();
		JoinChannelByName(channel, nil, FCF_GetCurrentChatFrameID());
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		_G[this:GetParent():GetName().."EditBox"]:SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local channel = _G[this:GetParent():GetName().."EditBox"]:GetText();
		JoinChannelByName(channel, nil, FCF_GetCurrentChatFrameID());
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		_G[this:GetParent():GetName().."EditBox"]:SetText("");
		this:GetParent():Hide();
	end,
	hideOnEscape = 1
};

StaticPopupDialogs["NAME_CHAT"] = {
	text = NAME_CHAT_WINDOW,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnAccept = function(renameID)
		local name = _G[this:GetParent():GetName().."EditBox"]:GetText();
		if ( renameID ) then
			FCF_SetWindowName(_G["ChatFrame"..renameID], name);
		else
			FCF_OpenNewWindow(name);
		end
		_G[this:GetParent():GetName().."EditBox"]:SetText("");
		FCF_DockUpdate();
	end,
	EditBoxOnEnterPressed = function(renameID)
		local name = _G[this:GetParent():GetName().."EditBox"]:GetText();
		if ( renameID ) then
			FCF_SetWindowName(_G["ChatFrame"..renameID], name);
		else
			FCF_OpenNewWindow(name);
		end
		_G[this:GetParent():GetName().."EditBox"]:SetText("");
		FCF_DockUpdate();
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function ()
		this:GetParent():Hide();
	end,
	hideOnEscape = 1
};

StaticPopupDialogs["HELP_TICKET_ABANDON_CONFIRM"] = {
	text = HELP_TICKET_ABANDON_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(prevFrame)
		DeleteGMTicket();
	end,
	OnCancel = function(prevFrame)
	end,
	whileDead = 1,
	hideOnEscape = 1
}
StaticPopupDialogs["HELP_TICKET"] = {
	text = HELP_TICKET_EDIT_ABANDON,
	button1 = HELP_TICKET_EDIT,
	button2 = HELP_TICKET_ABANDON,
	OnAccept = function()
		if ( PETITION_QUEUE_ACTIVE ) then
			ShowUIPanel(HelpFrame);
			HelpFrame_ShowFrame("OpenTicket");
		else
			HideUIPanel(HelpFrame);
			StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
		end
	end,
	OnCancel = function()
		local currentFrame = this:GetParent();
		local dialogFrame = StaticPopup_Show("HELP_TICKET_ABANDON_CONFIRM");
		dialogFrame.data = currentFrame;
	end,
	whileDead = 1
}
StaticPopupDialogs["PETRENAMECONFIRM"] = {
	text = PET_RENAME_CONFIRMATION,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		PetRename(this:GetParent().data);
	end,
	hideOnEscape = 1
}
StaticPopupDialogs["DEATH"] = {
	text = DEATH_RELEASE_TIMER,
	button1 = DEATH_RELEASE,
	button2 = USE_SOULSTONE,
	OnShow = function()
		this.timeleft = GetReleaseTimeRemaining();
		local text = HasSoulstone();
		if ( text ) then
			_G[this:GetName().."Button2"]:SetText(text);
		end
		if ( this.timeleft == -1 ) then
			_G[this:GetName().."Text"]:SetText(DEATH_RELEASE_NOTIMER);
		end
	end,
	OnAccept = function()
		RepopMe();
	end,
	OnCancel = function(data, reason)
		if ( reason == "override" ) then
			return;
		end
		if ( reason == "timeout" ) then
			return;
		end
		if ( reason == "clicked" ) then
			if ( HasSoulstone() ) then
				UseSoulstone();
			else
				RepopMe();
			end
		end
	end,
	DisplayButton2 = function()
		return HasSoulstone();
	end,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	cancels = "RECOVER_CORPSE"
};
StaticPopupDialogs["RESURRECT"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RESURRECT_REQUEST_TIMER,
	text = RESURRECT_REQUEST,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function()
		this.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function()
		AcceptResurrect();
	end,
	OnCancel = function()
		DeclineResurrect();
		if ( UnitIsDead("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = 60,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["RESURRECT_NO_SICKNESS"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RESURRECT_REQUEST_NO_SICKNESS_TIMER,
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function()
		this.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function()
		AcceptResurrect();
	end,
	OnCancel = function()
		DeclineResurrect();
		if ( UnitIsDead("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = 60,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["RESURRECT_NO_TIMER"] = {
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function()
		this.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function()
		AcceptResurrect();
	end,
	OnCancel = function()
		DeclineResurrect();
		if ( UnitIsDead("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = 60,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["SKINNED"] = {
	text = DEATH_CORPSE_SKINNED,
	button1 = ACCEPT,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
};
StaticPopupDialogs["SKINNED_REPOP"] = {
	text = DEATH_CORPSE_SKINNED,
	button1 = DEATH_RELEASE,
	button2 = DECLINE,
	OnAccept = function()
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
		RepopMe();
	end,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["TRADE"] = {
	text = TRADE_WITH_QUESTION,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		BeginTrade();
	end,
	OnCancel = function()
		CancelTrade();
	end,
	timeout = 60,
	hideOnEscape = 1
};
StaticPopupDialogs["PARTY_INVITE"] = {
	text = INVITATION,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	OnShow = function()
		StaticPopupDialogs["PARTY_INVITE"].inviteAccepted = nil;
	end,
	OnAccept = function()
		AcceptGroup();
		StaticPopupDialogs["PARTY_INVITE"].inviteAccepted = 1;
	end,
	OnCancel = function()
		DeclineGroup();
	end,
	OnHide = function()
		if ( not StaticPopupDialogs["PARTY_INVITE"].inviteAccepted ) then
			DeclineGroup();
		end
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILD_INVITE"] = {
	text = GUILD_INVITATION,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnAccept = function()
		AcceptGuild();
	end,
	OnCancel = function()
		DeclineGuild();
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["CAMP"] = {
	text = CAMP_TIMER,
	button1 = CANCEL,
	--button2 = CAMP_NOW,
	OnAccept = function()
		CancelLogout();
		--ForceLogout();
		-- uncomment the next line once forced logouts are completely implemented (they currently have a failure case)
		-- this.timeleft = 0;
	end,
	OnHide = function()
		if ( this.timeleft > 0 ) then
			CancelLogout();
			this:Hide();
		end
	end,
	timeout = 20,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["QUIT"] = {
	text = QUIT_TIMER,
	button1 = QUIT_NOW,
	button2 = CANCEL,
	OnAccept = function()
		ForceQuit();
		this.timeleft = 0;
	end,
	OnHide = function()
		if ( this.timeleft > 0 ) then
			CancelLogout();
		end
	end,
	timeout = 20,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["LOOT_BIND"] = {
	text = LOOT_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(slot)
		LootSlot(slot);
	end,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["EQUIP_BIND"] = {
	text = EQUIP_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(slot)
		EquipPendingItem(slot);
	end,
	OnCancel = function(slot)
		CancelPendingEquip(slot);
	end,
	OnHide = function(slot)
		CancelPendingEquip(slot);
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["AUTOEQUIP_BIND"] = {
	text = EQUIP_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(slot)
		EquipPendingItem(slot);
	end,
	OnCancel = function(slot)
		CancelPendingEquip(slot);
	end,
	OnHide = function(slot)
		CancelPendingEquip(slot);
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["USE_BIND"] = {
	text = USE_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		ConfirmBindOnUse();
	end,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["DELETE_ITEM"] = {
	text = DELETE_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		DeleteCursorItem();
	end,
	OnCancel = function ()
		ClearCursor();
	end,
	OnUpdate = function ()
		if ( not CursorHasItem() ) then
			StaticPopup_Hide("DELETE_ITEM");
		end
	end,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["DELETE_GOOD_ITEM"] = {
	text = DELETE_GOOD_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		DeleteCursorItem();
	end,
	OnCancel = function ()
		ClearCursor();
	end,
	OnUpdate = function ()
		if ( not CursorHasItem() ) then
			StaticPopup_Hide("DELETE_GOOD_ITEM");
		end
	end,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function()
		_G[this:GetName().."Button1"]:Disable();
		_G[this:GetName().."EditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."EditBox"]:SetText("");
	end,
	EditBoxOnEnterPressed = function()
		if ( _G[this:GetParent():GetName().."Button1"]:IsEnabled() == 1 ) then
			DeleteCursorItem();
			this:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function ()
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		if ( strupper(editBox:GetText()) ==  DELETE_ITEM_CONFIRM_STRING ) then
			_G[this:GetParent():GetName().."Button1"]:Enable();
		else
			_G[this:GetParent():GetName().."Button1"]:Disable();
		end
	end
};
StaticPopupDialogs["QUEST_ACCEPT"] = {
	text = QUEST_ACCEPT,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ConfirmAcceptQuest();
	end,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ABANDON_PET"] = {
	text = ABANDON_PET,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		PetAbandon();
	end,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ABANDON_QUEST"] = {
	text = ABANDON_QUEST_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		AbandonQuest();
		PlaySound("igQuestLogAbandonQuest");
	end,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"] = {
	text = ABANDON_QUEST_CONFIRM_WITH_ITEMS,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		AbandonQuest();
		PlaySound("igQuestLogAbandonQuest");
	end,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_FRIEND"] = {
	text = ADD_FRIEND_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		AddFriend(editBox:GetText());
	end,
	OnShow = function()
		_G[this:GetName().."EditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."EditBox"]:SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		AddFriend(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_IGNORE"] = {
	text = ADD_IGNORE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		AddIgnore(editBox:GetText());
	end,
	OnShow = function()
		_G[this:GetName().."EditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."EditBox"]:SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		AddIgnore(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_GUILDMEMBER"] = {
	text = ADD_GUILDMEMBER_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		GuildInviteByName(editBox:GetText());
	end,
	OnShow = function()
		_G[this:GetName().."EditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."EditBox"]:SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		GuildInviteByName(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_RAIDMEMBER"] = {
	text = ADD_RAIDMEMBER_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		InviteByName(editBox:GetText());
	end,
	OnShow = function()
		_G[this:GetName().."EditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."EditBox"]:SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		InviteByName(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["REMOVE_GUILDMEMBER"] = {
	text = format(REMOVE_GUILDMEMBER_LABEL, "XXX"),
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		GuildUninviteByName(GuildFrame.selectedName);
		GuildMemberDetailFrame:Hide();
	end,
	OnShow = function()
		_G[this:GetName().."Text"]:SetText(format(REMOVE_GUILDMEMBER_LABEL, GuildFrame.selectedName));
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_GUILDRANK"] = {
	text = ADD_GUILDRANK_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 15,
	OnAccept = function()
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		GuildControlAddRank(editBox:GetText());
		GuildControlSetRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
		GuildControlCheckboxUpdate(GuildControlGetRankFlags());
		CloseDropDownMenus();
	end,
	OnShow = function()
		_G[this:GetName().."EditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."EditBox"]:SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		GuildControlAddRank(editBox:GetText());
		GuildControlSetRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
		GuildControlCheckboxUpdate(GuildControlGetRankFlags());
		CloseDropDownMenus();
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["SET_GUILDMOTD"] = {
	text = SET_GUILDMOTD_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 128,
	hasWideEditBox = 1,
	OnAccept = function()
		local editBox = _G[this:GetParent():GetName().."WideEditBox"];
		GuildSetMOTD(editBox:GetText());
	end,
	OnShow = function()
		--_G[this:GetName().."WideEditBox"]:SetText(GetGuildRosterMOTD());
		_G[this:GetName().."WideEditBox"]:SetText(CURRENT_GUILD_MOTD);
		_G[this:GetName().."WideEditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."WideEditBox"]:SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = _G[this:GetParent():GetName().."WideEditBox"];
		GuildSetMOTD(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["SET_GUILDPLAYERNOTE"] = {
	text = SET_GUILDPLAYERNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	hasWideEditBox = 1,
	OnAccept = function()
		local editBox = _G[this:GetParent():GetName().."WideEditBox"];
		GuildRosterSetPublicNote(GetGuildRosterSelection(), editBox:GetText());
	end,
	OnShow = function()
		local name, rank, rankIndex, level, class, zone, note, officernote, online;
		name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

		_G[this:GetName().."WideEditBox"]:SetText(note);
		_G[this:GetName().."WideEditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."WideEditBox"]:SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = _G[this:GetParent():GetName().."WideEditBox"];
		GuildRosterSetPublicNote(GetGuildRosterSelection(), editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["SET_GUILDOFFICERNOTE"] = {
	text = SET_GUILDOFFICERNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	hasWideEditBox = 1,
	OnAccept = function()
		local editBox = _G[this:GetParent():GetName().."WideEditBox"];
		GuildRosterSetOfficerNote(GetGuildRosterSelection(), editBox:GetText());
	end,
	OnShow = function()
		local name, rank, rankIndex, level, class, zone, note, officernote, online;
		name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

		_G[this:GetName().."WideEditBox"]:SetText(officernote);
		_G[this:GetName().."WideEditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."WideEditBox"]:SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = _G[this:GetParent():GetName().."WideEditBox"];
		GuildRosterSetOfficerNote(GetGuildRosterSelection(), editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["RENAME_PET"] = {
	text = PET_RENAME_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local text = _G[this:GetParent():GetName().."EditBox"]:GetText();
		local dialogFrame = StaticPopup_Show("PETRENAMECONFIRM", text);
		if ( dialogFrame ) then
			dialogFrame.data = text;
		end
	end,
	EditBoxOnEnterPressed = function()
		local text = _G[this:GetParent():GetName().."EditBox"]:GetText();
		local dialogFrame = StaticPopup_Show("PETRENAMECONFIRM", text);
		if ( dialogFrame ) then
			dialogFrame.data = text;
		end
		this:GetParent():Hide();
	end,
	OnShow = function()
		_G[this:GetName().."EditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."EditBox"]:SetText("");
	end,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["DUEL_REQUESTED"] = {
	text = DUEL_REQUESTED,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	OnAccept = function()
		AcceptDuel();
	end,
	OnCancel = function()
		CancelDuel();
	end,
	timeout = 60,
	hideOnEscape = 1
};
StaticPopupDialogs["DUEL_OUTOFBOUNDS"] = {
	text = DUEL_OUTOFBOUNDS_TIMER,
	timeout = 10,
};
StaticPopupDialogs["UNLEARN_SKILL"] = {
	text = UNLEARN_SKILL,
	button1 = UNLEARN,
	button2 = CANCEL,
	OnAccept = function(index)
		AbandonSkill(index);
	end,
	timeout = 60,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["XP_LOSS"] = {
	text = CONFIRM_XP_LOSS,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(data)
		if ( data ) then
			_G[this:GetParent():GetName().."Text"]:SetText(format(CONFIRM_XP_LOSS_AGAIN, data));
			this:GetParent().data = nil;
			return 1;
		else
			AcceptXPLoss();
		end
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not CheckSpiritHealerDist() ) then
			dialog:Hide();
		end
	end,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["XP_LOSS_NO_SICKNESS"] = {
	text = CONFIRM_XP_LOSS_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(data)
		if ( data ) then
			_G[this:GetParent():GetName().."Text"]:SetText(CONFIRM_XP_LOSS_AGAIN_NO_SICKNESS);
			this:GetParent().data = nil;
			return 1;
		else
			AcceptXPLoss();
		end
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not CheckSpiritHealerDist() ) then
			dialog:Hide();
		end
	end,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["RECOVER_CORPSE"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RECOVER_CORPSE_TIMER,
	text = RECOVER_CORPSE,
	button1 = ACCEPT,
	OnAccept = function()
		RetrieveCorpse();
		return 1;
	end,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};
StaticPopupDialogs["RECOVER_CORPSE_INSTANCE"] = {
	text = RECOVER_CORPSE_INSTANCE,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};
--[[ The old version of the dialog... the new one auto-accepts for you.
StaticPopupDialogs["AREA_SPIRIT_HEAL"] = {
	text = AREA_SPIRIT_HEAL,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function()
		this.timeleft = GetAreaSpiritHealerTime();
	end,
	OnAccept = function()
		AcceptAreaSpiritHeal();
		_G[this:GetParent():GetName().."Button1"]:Hide();
		_G[this:GetParent():GetName().."Button2"]:Hide();
		return 1;
	end,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
]]
StaticPopupDialogs["AREA_SPIRIT_HEAL"] = {
	text = AREA_SPIRIT_HEAL,
	button1 = CANCEL,
	OnShow = function()
		this.timeleft = GetAreaSpiritHealerTime();
		AcceptAreaSpiritHeal();
	end,
	OnAccept = function()
		CancelAreaSpiritHeal();
	end,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["BIND_ENCHANT"] = {
	text = BIND_ENCHANT,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		BindEnchant();
	end,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["REPLACE_ENCHANT"] = {
	text = REPLACE_ENCHANT,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ReplaceEnchant();
	end,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["TRADE_REPLACE_ENCHANT"] = {
	text = REPLACE_ENCHANT,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ReplaceTradeEnchant();
	end,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["INSTANCE_BOOT"] = {
	text = INSTANCE_BOOT_TIMER,
	OnShow = function()
		this.timeleft = GetInstanceBootTimeRemaining();
		if ( this.timeleft <= 0 ) then
			StaticPopup_Hide("INSTANCE_BOOT");
		end
	end,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};
StaticPopupDialogs["CONFIRM_TALENT_WIPE"] = {
	text = CONFIRM_TALENT_WIPE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		ConfirmTalentWipe();
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not CheckTalentMasterDist() ) then
			dialog:Hide();
		end
	end,
	hasMoneyFrame = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_PET_UNLEARN"] = {
	text = CONFIRM_PET_UNLEARN,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		ConfirmPetUnlearn();
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not CheckPetUntrainerDist() ) then
			dialog:Hide();
		end
	end,
	hasMoneyFrame = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_BINDER"] = {
	text = CONFIRM_BINDER,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		ConfirmBinder();
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not CheckBinderDist() ) then
			dialog:Hide();
		end
	end,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_SUMMON"] = {
	text = CONFIRM_SUMMON;
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function()
		this.timeleft = GetSummonConfirmTimeLeft();
	end,
	OnAccept = function()
		ConfirmSummon();
	end,
	OnUpdate = function(elapsed, dialog)
		local button = _G[dialog:GetName().."Button1"];
		if ( UnitAffectingCombat("player") ) then
			button:Disable();
		else
			button:Enable();
		end
	end,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["BILLING_NAG"] = {
	text = BILLING_NAG_DIALOG;
	button1 = OKAY,
	showAlert = 1
};
StaticPopupDialogs["IGR_BILLING_NAG"] = {
	text = IGR_BILLING_NAG_DIALOG;
	button1 = OKAY,
	showAlert = 1
};
StaticPopupDialogs["CONFIRM_LOOT_ROLL"] = {
	text = LOOT_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(id, rollType)
		ConfirmLootRoll(id, rollType);
	end,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["GOSSIP_ENTER_CODE"] = {
	text = ENTER_CODE,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function(data)
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		SelectGossipOption(data, editBox:GetText());
	end,
	OnShow = function()
		_G[this:GetName().."EditBox"]:SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		_G[this:GetName().."EditBox"]:SetText("");
	end,
	EditBoxOnEnterPressed = function(data)
		local editBox = _G[this:GetParent():GetName().."EditBox"];
		SelectGossipOption(data, editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["OPTIONS_CONFIRM_DEFAULTS"] = {
	text = CONFIRM_DEFAULTS_RESET,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		OptionsFrame_SetDefaults()
	end,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
};

StaticPopupDialogs["CONFIRM_QUEST_REQUIRES_MONEY"] = {
	text = QUEST_MONEY_ALERT,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		QuestRewardCompleteButton_OnClick(true);
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName() .. "MoneyFrame", GetQuestMoneyToGet());
	end,
	hasMoneyFrame = 1,
	hideOnEscape = 1,
};

function StaticPopup_FindVisible(which, data)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = _G["StaticPopup"..index];
		if ( frame:IsShown() and (frame.which == which) and (not info.multiple or (frame.data == data)) ) then
			return frame;
		end
	end
	return nil;
end

function StaticPopup_Resize(dialog, which)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	local text = _G[dialog:GetName().."Text"];
	local editBox = _G[dialog:GetName().."EditBox"];
	local button1 = _G[dialog:GetName().."Button1"];

	local maxHeightSoFar = dialog.maxHeightSoFar or 0;
	local maxWidthSoFar = dialog.maxWidthSoFar or 0;

	local width = 320;
	if ( info.button3 ) then
		width = 440;
	elseif ( info.hasWideEditBox or info.showAlert ) then
		-- Widen
		width = 420;
	elseif ( which == "HELP_TICKET" ) then
		width = 350;
	end
	if ( width > maxWidthSoFar )  then
		dialog:SetWidth(width);
		dialog.maxWidthSoFar = width;
	end

	local height = 32 + text:GetHeight() + 8 + button1:GetHeight();
	if ( info.hasEditBox ) then
		height = height + 8 + editBox:GetHeight();
	elseif ( info.hasMoneyFrame ) then
		height = height + 16;
	elseif ( info.hasMoneyInputFrame ) then
		height = height + 22;
	end
	if ( info.hasItemFrame ) then
		height = height + 64;
	end
	if ( height > maxHeightSoFar ) then
		dialog:SetHeight(height);
		dialog.maxHeightSoFar = height;
	end
end

function StaticPopup_Show(which, text_arg1, text_arg2, data)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	if ( UnitIsDeadOrGhost("player") and not info.whileDead ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	if ( InCinematic() and not info.interruptCinematic ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	if ( info.exclusive ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = _G["StaticPopup"..index];
			if ( frame:IsShown() and StaticPopupDialogs[frame.which].exclusive ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame.data, "override");
				end
				break;
			end
		end
	end

	if ( info.cancels ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = _G["StaticPopup"..index];
			if ( frame:IsShown() and (frame.which == info.cancels) ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame.data, "override");
				end
			end
		end
	end

	if ( (which == "CAMP") or (which == "QUIT") ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = _G["StaticPopup"..index];
			if ( frame:IsShown() and not StaticPopupDialogs[frame.which].notClosableByLogout ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame.data, "override");
				end
			end
		end
	end

	if ( which == "DEATH" ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = _G["StaticPopup"..index];
			if ( frame:IsShown() and not StaticPopupDialogs[frame.which].whileDead ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame.data, "override");
				end
			end
		end
	end

	-- Pick a free dialog to use
	local dialog = nil;
	-- Find an open dialog of the requested type
	dialog = StaticPopup_FindVisible(which, data);
	if ( dialog ) then
		local OnCancel = info.OnCancel;
		if ( OnCancel ) then
			OnCancel(dialog.data, "override");
		end
		dialog:Hide();
	end
	if ( not dialog ) then
		-- Find a free dialog
		local index = 1;
		if ( info.preferredIndex ) then
			index = info.preferredIndex;
		end
		for i = index, STATICPOPUP_NUMDIALOGS do
			local frame = _G["StaticPopup"..i];
			if ( not frame:IsShown() ) then
				dialog = frame;
				break;
			end
		end

		--If dialog not found and there's a preferredIndex then try to find an available frame before the preferredIndex
		if ( not dialog and info.preferredIndex ) then
			for i = 1, info.preferredIndex do
				local frame = _G["StaticPopup"..i];
				if ( not frame:IsShown() ) then
					dialog = frame;
					break;
				end
			end
		end
	end
	if ( not dialog ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	dialog.maxHeightSoFar, dialog.maxWidthSoFar = 0, 0;
	-- Set the text of the dialog
	local text = _G[dialog:GetName().."Text"];
	if ( (which == "DEATH") or
			(which == "CAMP") or
			(which == "QUIT") or
			(which == "DUEL_OUTOFBOUNDS") or
			(which == "RECOVER_CORPSE") or
			(which == "RESURRECT") or
			(which == "RESURRECT_NO_SICKNESS") or
			(which == "INSTANCE_BOOT") or
			(which == "CONFIRM_SUMMON") or
			(which == "AREA_SPIRIT_HEAL") ) then
		text:SetText(" ");	-- The text will be filled in later.
		text.text_arg1 = text_arg1;
		text.text_arg2 = text_arg2;
	elseif ( which == "BILLING_NAG" ) then
		text:SetText(format(info.text, text_arg1, GetText("MINUTES", nil, text_arg1)));
	else
		text:SetText(format(info.text, text_arg1, text_arg2));
	end

	-- If is any of the guild message popups
	local alertIcon = _G[dialog:GetName().."AlertIcon"];
	alertIcon:Hide();
	dialog:SetWidth(320);
	if ( (which == "SET_GUILDMOTD") or (which == "SET_GUILDPLAYERNOTE") or (which == "SET_GUILDPLAYERNOTE") or (which == "SET_GUILDOFFICERNOTE" )) then
		-- Widen
		dialog:SetWidth(420);
	elseif ( info.showAlert ) then
		-- If is the delete item dialog display the error image
		dialog:SetWidth(420);
		alertIcon:Show();
	end

	-- If is the ticket edit dialog then show the close button
	if ( which == "HELP_TICKET" ) then
		_G[dialog:GetName().."CloseButton"]:Show();
		dialog:SetWidth(350);
	else
		_G[dialog:GetName().."CloseButton"]:Hide();
	end

	-- Set the editbox of the dialog
	local wideEditBox = _G[dialog:GetName().."WideEditBox"];
	local editBox = _G[dialog:GetName().."EditBox"];
	if ( info.hasEditBox ) then
		if ( info.hasWideEditBox ) then
			wideEditBox:Show();
			editBox:Hide();

			if ( info.maxLetters ) then
				wideEditBox:SetMaxLetters(info.maxLetters);
			end
			if ( info.maxBytes ) then
				wideEditBox:SetMaxBytes(info.maxBytes);
			end
			wideEditBox:SetText("");
		else
			wideEditBox:Hide();
			editBox:Show();

			if ( info.maxLetters ) then
				editBox:SetMaxLetters(info.maxLetters);
			end
			if ( info.maxBytes ) then
				editBox:SetMaxBytes(info.maxBytes);
			end
			editBox:SetText("");
		end
	else
		wideEditBox:Hide();
		editBox:Hide();
	end

	-- Show or hide money frame
	if ( info.hasMoneyFrame ) then
		_G[dialog:GetName().."MoneyFrame"]:Show();
		_G[dialog:GetName().."MoneyInputFrame"]:Hide();
	elseif ( info.hasMoneyInputFrame ) then
		_G[dialog:GetName().."MoneyInputFrame"]:Show();
		_G[dialog:GetName().."MoneyFrame"]:Hide();
		-- Set OnEnterPress for money input frames
		if ( info.EditBoxOnEnterPressed ) then
			_G[dialog:GetName().."MoneyInputFrameGold"]:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			_G[dialog:GetName().."MoneyInputFrameSilver"]:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			_G[dialog:GetName().."MoneyInputFrameCopper"]:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
		else
			_G[dialog:GetName().."MoneyInputFrameGold"]:SetScript("OnEnterPressed", nil);
			_G[dialog:GetName().."MoneyInputFrameSilver"]:SetScript("OnEnterPressed", nil);
			_G[dialog:GetName().."MoneyInputFrameCopper"]:SetScript("OnEnterPressed", nil);
		end
	else
		_G[dialog:GetName().."MoneyFrame"]:Hide();
		_G[dialog:GetName().."MoneyInputFrame"]:Hide();
	end

	-- Show or hide item button
	if ( info.hasItemFrame ) then
		_G[dialog:GetName().."ItemFrame"]:Show();
		if ( data and type(data) == "table" ) then
			_G[dialog:GetName().."ItemFrame"].link = data.link
			_G[dialog:GetName().."ItemFrameIconTexture"]:SetTexture(data.texture);
			local nameText = _G[dialog:GetName().."ItemFrameText"];
			nameText:SetTextColor(unpack(data.color or {1, 1, 1, 1}));
			nameText:SetText(data.name);
			if ( data.count and data.count > 1 ) then
				_G[dialog:GetName().."ItemFrameCount"]:SetText(data.count);
				_G[dialog:GetName().."ItemFrameCount"]:Show();
			else
				_G[dialog:GetName().."ItemFrameCount"]:Hide();
			end
		end
	else
		_G[dialog:GetName().."ItemFrame"]:Hide();
	end

	-- Set the buttons of the dialog
	local button1 = _G[dialog:GetName().."Button1"];
	local button2 = _G[dialog:GetName().."Button2"];
	local button3 = _G[dialog:GetName().."Button3"];
	if ( info.button3 and (not info.DisplayButton3 or info.DisplayButton3()) ) then
		button1:ClearAllPoints();
		button2:ClearAllPoints();
		button3:ClearAllPoints();
		button1:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -72, 16);
		button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
		button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);
		button2:SetText(info.button2);
		button3:SetText(info.button3);
		local width = button2:GetTextWidth();
		if ( width > 110 ) then
			button2:SetWidth(width + 20);
		else
			button2:SetWidth(120);
		end
		button2:Enable();
		button2:Show();

		width = button3:GetTextWidth();
		if ( width > 110 ) then
			button3:SetWidth(width + 20);
		else
			button3:SetWidth(120);
		end
		button3:Enable();
		button3:Show();
	elseif ( info.button2 and (not info.DisplayButton2 or info.DisplayButton2()) ) then
		button1:ClearAllPoints();
		button2:ClearAllPoints();
		button1:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -6, 16);
		button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
		button2:SetText(info.button2);
		local width = button2:GetTextWidth();
		if ( width > 110 ) then
			button2:SetWidth(width + 20);
		else
			button2:SetWidth(120);
		end
		button2:Enable();
		button2:Show();
		button3:Hide();
	else
		button1:ClearAllPoints();
		button1:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 16);
		button2:Hide();
		button3:Hide();
	end
	if ( info.button1 ) then
		button1:SetText(info.button1);
		local width = button1:GetTextWidth();
		if ( width > 120 ) then
			button1:SetWidth(width + 20);
		else
			button1:SetWidth(120);
		end
		button1:Enable();
		button1:Show();
	else
		button1:Hide();
	end

	-- Set the miscellaneous variables for the dialog
	dialog.which = which;
	dialog.timeleft = info.timeout or 0;
	dialog.hideOnEscape = info.hideOnEscape;
	dialog.exclusive = info.exclusive;
	dialog.enterClicksFirstButton = info.enterClicksFirstButton;
	dialog.data = data;

	if ( info.StartDelay ) then
		dialog.startDelay = info.StartDelay();
		button1:Disable();
	else
		dialog.startDelay = nil;
		button1:Enable();
	end

	-- Finally size and show the dialog
	if ( not tContains(StaticPopup_DisplayedFrames, dialog) ) then
		local lastFrame = StaticPopup_DisplayedFrames[getn(StaticPopup_DisplayedFrames)];
		if ( lastFrame ) then
			dialog:SetPoint("TOP", lastFrame, "BOTTOM", 0, 0);
		else
			dialog:SetPoint("TOP", UIParent, "TOP", 0, -135);
		end
		tinsert(StaticPopup_DisplayedFrames, dialog);
	end
	dialog:Show();

	StaticPopup_Resize(dialog, which);

	if ( info.sound ) then
		PlaySound(info.sound);
	end

	return dialog;
end

function StaticPopup_Hide(which, data)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local dialog = _G["StaticPopup"..index];
		if ( (dialog.which == which) and (not data or (data == dialog.data)) ) then
			dialog:Hide();
		end
	end
end

function StaticPopup_OnUpdate(dialog, elapsed)
	if ( dialog.timeleft > 0 ) then
		local which = dialog.which;
		local info = StaticPopupDialogs[which];
		local timeleft = dialog.timeleft - elapsed;
		if ( timeleft <= 0 ) then
			dialog.timeleft = 0;
			local OnCancel = info.OnCancel;
			if ( OnCancel ) then
				OnCancel(dialog.data, "timeout");
			end
			dialog:Hide();
			return;
		end
		dialog.timeleft = timeleft;

		if ( (which == "DEATH") or
				(which == "CAMP")  or
				(which == "QUIT") or
				(which == "DUEL_OUTOFBOUNDS") or
				(which == "INSTANCE_BOOT") or
				(which == "CONFIRM_SUMMON") or
				(which == "AREA_SPIRIT_HEAL") ) then
			local text = _G[dialog:GetName().."Text"];
			local hasText = nil;
			if ( text:GetText() ~= " " ) then
				hasText = 1;
			end
			timeleft = ceil(timeleft);
			if ( which == "INSTANCE_BOOT" ) then
				if ( timeleft < 60 ) then
					text:SetText(format(info.text, GetBindLocation(), timeleft, GetText("SECONDS", nil, timeleft)));
				else
					text:SetText(format(info.text, GetBindLocation(), ceil(timeleft / 60), GetText("MINUTES", nil, ceil(timeleft / 60))));
				end
			elseif ( which == "CONFIRM_SUMMON" ) then
				if ( timeleft < 60 ) then
					text:SetText(format(info.text, GetSummonConfirmSummoner(), GetSummonConfirmAreaName(), timeleft, GetText("SECONDS", nil, timeleft)));
				else
					text:SetText(format(info.text, GetSummonConfirmSummoner(), GetSummonConfirmAreaName(), ceil(timeleft / 60), GetText("MINUTES", nil, ceil(timeleft / 60))));
				end
			else
				if ( timeleft < 60 ) then
					text:SetText(format(info.text, timeleft, GetText("SECONDS", nil, timeleft)));
				else
					text:SetText(format(info.text, ceil(timeleft / 60), GetText("MINUTES", nil, ceil(timeleft / 60))));
				end
			end
			if ( not hasText ) then
				StaticPopup_Resize(dialog, which);
			end
		end
	end
	if ( dialog.startDelay ) then
		local which = dialog.which;
		local info = StaticPopupDialogs[which];
		local timeleft = dialog.startDelay - elapsed;
		if ( timeleft <= 0 ) then
			dialog.startDelay = nil;
			local text = _G[dialog:GetName().."Text"];
			text:SetText(format(info.text, text.text_arg1, text.text_arg2));
			local button1 = _G[dialog:GetName().."Button1"];
			button1:Enable();
			StaticPopup_Resize(dialog, which);
			return;
		end
		dialog.startDelay = timeleft;

		if ( which == "RECOVER_CORPSE" or (which == "RESURRECT") or (which == "RESURRECT_NO_SICKNESS") ) then
			local text = _G[dialog:GetName().."Text"];
			local hasText = nil;
			if ( text:GetText() ~= " " ) then
				hasText = 1;
			end
			timeleft = ceil(timeleft);
			if ( (which == "RESURRECT") or (which == "RESURRECT_NO_SICKNESS") ) then
				if ( timeleft < 60 ) then
					text:SetText(format(info.delayText, text.text_arg1, timeleft, GetText("SECONDS", nil, timeleft)));
				else
					text:SetText(format(info.delayText, text.text_arg1, ceil(timeleft / 60), GetText("MINUTES", nil, ceil(timeleft / 60))));
				end
			else
				if ( timeleft < 60 ) then
					text:SetText(format(info.delayText, timeleft, GetText("SECONDS", nil, timeleft)));
				else
					text:SetText(format(info.delayText, ceil(timeleft / 60), GetText("MINUTES", nil, ceil(timeleft / 60))));
				end
			end
			if ( not hasText ) then
				StaticPopup_Resize(dialog, which);
			end
		end
	end

	local onUpdate = StaticPopupDialogs[dialog.which].OnUpdate;
	if ( onUpdate ) then
		onUpdate(elapsed, dialog);
	end
end

function StaticPopup_EditBoxOnEnterPressed()
	local EditBoxOnEnterPressed, which, dialog;
	local parent = this:GetParent();
	if ( parent.which ) then
		which = parent.which;
		dialog = parent;
	elseif ( parent:GetParent().which ) then
		-- This is needed if this is a money input frame since it's nested deeper than a normal edit box
		which = parent:GetParent().which;
		dialog = parent:GetParent();
	end
	EditBoxOnEnterPressed = StaticPopupDialogs[which].EditBoxOnEnterPressed;
	if ( EditBoxOnEnterPressed ) then
		EditBoxOnEnterPressed(dialog.data);
	end
end

function StaticPopup_EditBoxOnEscapePressed()
	local EditBoxOnEscapePressed = StaticPopupDialogs[this:GetParent().which].EditBoxOnEscapePressed;
	if ( EditBoxOnEscapePressed ) then
		EditBoxOnEscapePressed(this:GetParent().data);
	end
end

function StaticPopup_EditBoxOnTextChanged()
	local EditBoxOnTextChanged = StaticPopupDialogs[this:GetParent().which].EditBoxOnTextChanged;
	if ( EditBoxOnTextChanged ) then
		EditBoxOnTextChanged(this:GetParent().data);
	end
end

function StaticPopup_OnShow()
	PlaySound("igMainMenuOpen");
	local OnShow = StaticPopupDialogs[this.which].OnShow;
	if ( StaticPopupDialogs[this.which].hasMoneyInputFrame ) then
		_G[this:GetName().."MoneyInputFrameGold"]:SetFocus();
	end
	if ( OnShow ) then
		OnShow(this.data);
	end
end

function StaticPopup_OnHide()
	PlaySound("igMainMenuClose");
	local displayedFrames = StaticPopup_DisplayedFrames;
	local index = getn(displayedFrames);
	while ( index >= 1 and not displayedFrames[index]:IsShown() ) do
		tremove(displayedFrames, index);
		index = index - 1;
	end
	local OnHide = StaticPopupDialogs[this.which].OnHide;
	if ( OnHide ) then
		OnHide(this.data);
	end
end

function StaticPopup_OnClick(dialog, index)
	if ( not dialog:IsShown() ) then
		return;
	end
	local which = dialog.which;
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end
	local hide = true;
	if ( index == 1 ) then
		local OnAccept = info.OnAccept;
		if ( OnAccept ) then
			hide = not OnAccept(dialog.data, dialog.data2);
		end
	elseif ( index == 3 ) then
		local OnAlt = info.OnAlt;
		if ( OnAlt ) then
			OnAlt(dialog, dialog.data, "clicked");
		end
	else
		local OnCancel = info.OnCancel;
		if ( OnCancel ) then
			hide = not OnCancel(dialog.data, "clicked");
		end
	end

	if ( hide and (which == dialog.which) ) then
		dialog:Hide();
	end
end

function StaticPopup_Visible(which)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = _G["StaticPopup"..index];
		if( frame:IsShown() and (frame.which == which) ) then
			return frame:GetName();
		end
	end
	return nil;
end

function StaticPopup_EscapePressed()
	local closed = nil;
	for _, frame in pairs(StaticPopup_DisplayedFrames) do
		if ( frame:IsShown() and frame.hideOnEscape ) then
			local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
			if ( OnCancel ) then
				OnCancel(frame.data, "clicked");
			end
			frame:Hide();
			closed = 1;
		end
	end
	return closed;
end

function StaticPopup_OnEvent()
	this.maxHeightSoFar = 0;
	StaticPopup_Resize(this, this.which);
end
