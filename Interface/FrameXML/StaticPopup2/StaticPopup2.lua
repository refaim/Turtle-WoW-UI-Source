STATICPOPUP2_NUMDIALOGS = 4;

StaticPopup2Dialogs = { };


function StaticPopup2_FindVisible(which, data)
    local info = StaticPopup2Dialogs[which];
    if ( not info ) then
        return nil;
    end
    for index = 1, STATICPOPUP2_NUMDIALOGS, 1 do
        local frame = _G["StaticPopup2"..index];
        if ( frame:IsShown() and (frame.which == which) and (not info.multiple or (frame.data == data)) ) then
            return frame;
        end
    end
    return nil;
end

function StaticPopup2_Resize(dialog, which)
    local text = _G[dialog:GetName().."Text"];
    local editBox = _G[dialog:GetName().."EditBox"];
    local button1 = _G[dialog:GetName().."Button1"];

    local width = 320;
    dialog:SetWidth(320);
    if ( StaticPopup2Dialogs[which].button3 ) then
        width = 440;
    elseif (StaticPopup2Dialogs[which].hasWideEditBox or StaticPopup2Dialogs[which].showAlert) then
        -- Widen
        width = 420;
    elseif ( which == "HELP_TICKET" ) then
        width = 350;
    end
    dialog:SetWidth(width);

    if ( StaticPopup2Dialogs[which].hasEditBox ) then
        if ( StaticPopup2Dialogs[which].hasWideEditBox  ) then

        end
        dialog:SetHeight(16 + text:GetHeight() + 8 + editBox:GetHeight() + 8 + button1:GetHeight() + 16);
    elseif ( StaticPopup2Dialogs[which].hasMoneyFrame ) then
        dialog:SetHeight(16 + text:GetHeight() + 8 + button1:GetHeight() + 32);
    elseif ( StaticPopup2Dialogs[which].hasMoneyInputFrame ) then
        dialog:SetHeight(16 + text:GetHeight() + 8 + button1:GetHeight() + 38);
    elseif ( StaticPopup2Dialogs[which].hasItemFrame ) then
        dialog:SetHeight(16 + text:GetHeight() + 8 + button1:GetHeight() + 80);
    else
        dialog:SetHeight(16 + text:GetHeight() + 8 + button1:GetHeight() + 16);
    end
end

function StaticPopup2_Show(which, text_arg1, text_arg2, text_arg3, data)
    local info = StaticPopup2Dialogs[which];
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
        for index = 1, STATICPOPUP2_NUMDIALOGS, 1 do
            local frame = _G["StaticPopup2"..index];
            if ( frame:IsShown() and StaticPopup2Dialogs[frame.which].exclusive ) then
                frame:Hide();
                local OnCancel = StaticPopup2Dialogs[frame.which].OnCancel;
                if ( OnCancel ) then
                    OnCancel(frame.data, "override");
                end
                break;
            end
        end
    end

    if ( info.cancels ) then
        for index = 1, STATICPOPUP2_NUMDIALOGS, 1 do
            local frame = _G["StaticPopup2"..index];
            if ( frame:IsShown() and (frame.which == info.cancels) ) then
                frame:Hide();
                local OnCancel = StaticPopup2Dialogs[frame.which].OnCancel;
                if ( OnCancel ) then
                    OnCancel(frame.data, "override");
                end
            end
        end
    end

    if ( (which == "CAMP") or (which == "QUIT") ) then
        for index = 1, STATICPOPUP2_NUMDIALOGS, 1 do
            local frame = _G["StaticPopup2"..index];
            if ( frame:IsShown() and not StaticPopup2Dialogs[frame.which].notClosableByLogout ) then
                frame:Hide();
                local OnCancel = StaticPopup2Dialogs[frame.which].OnCancel;
                if ( OnCancel ) then
                    OnCancel(frame.data, "override");
                end
            end
        end
    end

    if ( which == "DEATH" ) then
        for index = 1, STATICPOPUP2_NUMDIALOGS, 1 do
            local frame = _G["StaticPopup2"..index];
            if ( frame:IsShown() and not StaticPopup2Dialogs[frame.which].whileDead ) then
                frame:Hide();
                local OnCancel = StaticPopup2Dialogs[frame.which].OnCancel;
                if ( OnCancel ) then
                    OnCancel(frame.data, "override");
                end
            end
        end
    end

    -- Pick a free dialog to use
    local dialog = nil;
    -- Find an open dialog of the requested type
    dialog = StaticPopup2_FindVisible(which, data);
    if ( dialog ) then
        local OnCancel = StaticPopup2Dialogs[which].OnCancel;
        if ( OnCancel ) then
            OnCancel(dialog.data, "override");
        end
        dialog:Hide();
    end
    if ( not dialog ) then
        -- Find a free dialog
        local index = 1;
        if ( StaticPopup2Dialogs[which].preferredIndex ) then
            index = StaticPopup2Dialogs[which].preferredIndex;
        end
        for i = index, STATICPOPUP2_NUMDIALOGS do
            local frame = _G["StaticPopup2"..i];
            if ( not frame:IsShown() ) then
                dialog = frame;
                break;
            end
        end

        --If dialog not found and there's a preferredIndex then try to find an available frame before the preferredIndex
        if ( not dialog and StaticPopup2Dialogs[which].preferredIndex ) then
            for i = 1, StaticPopup2Dialogs[which].preferredIndex do
                local frame = _G["StaticPopup2"..i];
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

    -- Set the text of the dialog
    local text = _G[dialog:GetName().."Text"];
	text.text_arg1 = text_arg1;
	text.text_arg2 = text_arg2;
	text.text_arg3 = text_arg3;
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
    elseif ( which == "BILLING_NAG" ) then
        text:SetText(format(StaticPopup2Dialogs[which].text, text_arg1, GetText("MINUTES", nil, text_arg1)));
    else
        text:SetText(format(StaticPopup2Dialogs[which].text, text_arg1, text_arg2, text_arg3));
    end

    -- If is any of the guild message popups
    local wideEditBox = _G[dialog:GetName().."WideEditBox"];
    local editBox = _G[dialog:GetName().."EditBox"];
    local alertIcon = _G[dialog:GetName().."AlertIcon"];
    if ( info.showAlert ) then
        alertIcon:Show();
    else
        alertIcon:Hide();
    end

    -- If is the ticket edit dialog then show the close button
    if ( which == "HELP_TICKET" ) then
        _G[dialog:GetName().."CloseButton"]:Show();
    else
        _G[dialog:GetName().."CloseButton"]:Hide();
    end

    -- Set the editbox of the dialog
    if ( StaticPopup2Dialogs[which].hasEditBox ) then
        if ( StaticPopup2Dialogs[which].hasWideEditBox ) then
            wideEditBox:Show();
            editBox:Hide();

            if ( StaticPopup2Dialogs[which].maxLetters ) then
                wideEditBox:SetMaxLetters(StaticPopup2Dialogs[which].maxLetters);
            end
            if ( StaticPopup2Dialogs[which].maxBytes ) then
                wideEditBox:SetMaxBytes(StaticPopup2Dialogs[which].maxBytes);
            end
        else
            wideEditBox:Hide();
            editBox:Show();

            if ( StaticPopup2Dialogs[which].maxLetters ) then
                editBox:SetMaxLetters(StaticPopup2Dialogs[which].maxLetters);
            end
            if ( StaticPopup2Dialogs[which].maxBytes ) then
                editBox:SetMaxBytes(StaticPopup2Dialogs[which].maxBytes);
            end
        end
    else
        wideEditBox:Hide();
        editBox:Hide();
    end

    -- Show or hide money frame
    if ( StaticPopup2Dialogs[which].hasMoneyFrame ) then
        _G[dialog:GetName().."MoneyFrame"]:Show();
        _G[dialog:GetName().."MoneyInputFrame"]:Hide();
    elseif ( StaticPopup2Dialogs[which].hasMoneyInputFrame ) then
        _G[dialog:GetName().."MoneyInputFrame"]:Show();
        _G[dialog:GetName().."MoneyFrame"]:Hide();

        _G[dialog:GetName().."MoneyInputFrameGold"]:SetMaxLetters(6)
        _G[dialog:GetName().."MoneyInputFrameSilver"]:SetMaxLetters(6)
        _G[dialog:GetName().."MoneyInputFrameCopper"]:SetMaxLetters(6)

        -- Set OnEnterPress for money input frames
        if ( StaticPopup2Dialogs[which].EditBoxOnEnterPressed ) then
            _G[dialog:GetName().."MoneyInputFrameGold"]:SetScript("OnEnterPressed", StaticPopup2_EditBoxOnEnterPressed);
            _G[dialog:GetName().."MoneyInputFrameSilver"]:SetScript("OnEnterPressed", StaticPopup2_EditBoxOnEnterPressed);
            _G[dialog:GetName().."MoneyInputFrameCopper"]:SetScript("OnEnterPressed", StaticPopup2_EditBoxOnEnterPressed);
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
    if ( StaticPopup2Dialogs[which].hasItemFrame ) then
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
    if ( StaticPopup2Dialogs[which].button3 and ( not StaticPopup2Dialogs[which].DisplayButton3 or StaticPopup2Dialogs[which].DisplayButton3() ) ) then
        button1:ClearAllPoints();
        button2:ClearAllPoints();
        button3:ClearAllPoints();
        if ( StaticPopup2Dialogs[which].hasEditBox ) then
            button1:SetPoint("TOPRIGHT", editBox, "BOTTOM", -72, -8);
            button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
            button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);

        elseif ( StaticPopup2Dialogs[which].hasMoneyFrame ) then
            button1:SetPoint("TOPRIGHT", text, "BOTTOM", -72, -24);
            button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
            button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);

        elseif ( StaticPopup2Dialogs[which].hasMoneyInputFrame ) then
            button1:SetPoint("TOPRIGHT", text, "BOTTOM", -72, -30);
            button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
            button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);

        elseif ( StaticPopup2Dialogs[which].hasItemFrame ) then
            button1:SetPoint("TOPRIGHT", text, "BOTTOM", -72, -70);
            button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
            button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);
        else
            button1:SetPoint("TOPRIGHT", text, "BOTTOM", -72, -8);
            button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
            button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);
        end
        button2:SetText(StaticPopup2Dialogs[which].button2);
        button3:SetText(StaticPopup2Dialogs[which].button3);
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

    elseif ( StaticPopup2Dialogs[which].button2 and
            ( not StaticPopup2Dialogs[which].DisplayButton2 or StaticPopup2Dialogs[which].DisplayButton2() ) ) then
        button1:ClearAllPoints();
        button2:ClearAllPoints();
        if ( StaticPopup2Dialogs[which].hasEditBox ) then
            button1:SetPoint("TOPRIGHT", editBox, "BOTTOM", -6, -8);
            button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
        elseif ( StaticPopup2Dialogs[which].hasMoneyFrame ) then
            button1:SetPoint("TOPRIGHT", text, "BOTTOM", -6, -24);
            button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
        elseif ( StaticPopup2Dialogs[which].hasMoneyInputFrame ) then
            button1:SetPoint("TOPRIGHT", text, "BOTTOM", -6, -30);
            button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
        elseif ( StaticPopup2Dialogs[which].hasItemFrame ) then
            button1:SetPoint("TOPRIGHT", text, "BOTTOM", -6, -70);
            button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
        else
            button1:SetPoint("TOPRIGHT", text, "BOTTOM", -6, -8);
            button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
        end
        button2:SetText(StaticPopup2Dialogs[which].button2);
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
        button1:SetPoint("TOP", text, "BOTTOM", 0, -8);
        button2:Hide();
        button3:Hide();
    end
    if ( StaticPopup2Dialogs[which].button1 ) then
        button1:SetText(StaticPopup2Dialogs[which].button1);
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
    dialog.timeleft = StaticPopup2Dialogs[which].timeout;
    dialog.hideOnEscape = StaticPopup2Dialogs[which].hideOnEscape;
    -- Clear out data
    dialog.data = nil;

    if ( StaticPopup2Dialogs[which].StartDelay ) then
        dialog.startDelay = StaticPopup2Dialogs[which].StartDelay();
        button1:Disable();
    else
        dialog.startDelay = nil;
        button1:Enable();
    end

    -- Finally size and show the dialog
    dialog:Show();
    StaticPopup2_Resize(dialog, which);

    if ( StaticPopup2Dialogs[which].sound ) then
        PlaySound(StaticPopup2Dialogs[which].sound);
    end

    return dialog;
end

function StaticPopup2_Hide(which, data)
    for index = 1, STATICPOPUP2_NUMDIALOGS, 1 do
        local dialog = _G["StaticPopup2"..index];
        if ( (dialog.which == which) and (not data or (data == dialog.data)) ) then
            dialog:Hide();
        end
    end
end

function StaticPopup2_OnUpdate(dialog, elapsed)
    if ( dialog.timeleft > 0 ) then
        local which = dialog.which;
        local timeleft = dialog.timeleft - elapsed;
        if ( timeleft <= 0 ) then
            dialog.timeleft = 0;
            local OnCancel = StaticPopup2Dialogs[which].OnCancel;
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
                    text:SetText(format(StaticPopup2Dialogs[which].text, GetBindLocation(), timeleft, GetText("SECONDS_P1", nil, timeleft)));
                else
                    text:SetText(format(StaticPopup2Dialogs[which].text, GetBindLocation(), ceil(timeleft / 60), GetText("MINUTES_P1", nil, ceil(timeleft / 60))));
                end
            elseif ( which == "CONFIRM_SUMMON" ) then
                if ( timeleft < 60 ) then
                    text:SetText(format(StaticPopup2Dialogs[which].text, GetSummonConfirmSummoner(), GetSummonConfirmAreaName(), timeleft, GetText("SECONDS_P1", nil, timeleft)));
                else
                    text:SetText(format(StaticPopup2Dialogs[which].text, GetSummonConfirmSummoner(), GetSummonConfirmAreaName(), ceil(timeleft / 60), GetText("MINUTES_P1", nil, ceil(timeleft / 60))));
                end
            else
                if ( timeleft < 60 ) then
                    text:SetText(format(StaticPopup2Dialogs[which].text, timeleft, GetText("SECONDS_P1", nil, timeleft)));
                else
                    text:SetText(format(StaticPopup2Dialogs[which].text, ceil(timeleft / 60), GetText("MINUTES_P1", nil, ceil(timeleft / 60))));
                end
            end
            if ( not hasText ) then
                StaticPopup2_Resize(dialog, which);
            end
        end
    end
    if ( dialog.startDelay ) then
        local which = dialog.which;
        local timeleft = dialog.startDelay - elapsed;
        if ( timeleft <= 0 ) then
            dialog.startDelay = nil;
            local text = _G[dialog:GetName().."Text"];
            text:SetText(format(StaticPopup2Dialogs[which].text, text.text_arg1, text.text_arg2, text.text_arg3));
            local button1 = _G[dialog:GetName().."Button1"];
            button1:Enable();
            StaticPopup2_Resize(dialog, which);
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
                    text:SetText(format(StaticPopup2Dialogs[which].delayText, text.text_arg1, timeleft, GetText("SECONDS_P1", nil, timeleft)));
                else
                    text:SetText(format(StaticPopup2Dialogs[which].delayText, text.text_arg1, ceil(timeleft / 60), GetText("MINUTES_P1", nil, ceil(timeleft / 60))));
                end
            else
                if ( timeleft < 60 ) then
                    text:SetText(format(StaticPopup2Dialogs[which].delayText, timeleft, GetText("SECONDS_P1", nil, timeleft)));
                else
                    text:SetText(format(StaticPopup2Dialogs[which].delayText, ceil(timeleft / 60), GetText("MINUTES_P1", nil, ceil(timeleft / 60))));
                end
            end
            if ( not hasText ) then
                StaticPopup2_Resize(dialog, which);
            end
        end
    end

    local onUpdate = StaticPopup2Dialogs[dialog.which].OnUpdate;
    if ( onUpdate ) then
        onUpdate(elapsed, dialog);
    end
end

function StaticPopup2_EditBoxOnEnterPressed()
    local EditBoxOnEnterPressed, which, dialog;
    if ( this:GetParent().which ) then
        which = this:GetParent().which;
        dialog = this:GetParent();
    elseif ( this:GetParent():GetParent().which ) then
        -- This is needed if this is a money input frame since it's nested deeper than a normal edit box
        which = this:GetParent():GetParent().which;
        dialog = this:GetParent():GetParent();
    end
    EditBoxOnEnterPressed = StaticPopup2Dialogs[which].EditBoxOnEnterPressed;
    if ( EditBoxOnEnterPressed ) then
        EditBoxOnEnterPressed(dialog.data);
    end
end

function StaticPopup2_EditBoxOnEscapePressed()
    local EditBoxOnEscapePressed = StaticPopup2Dialogs[this:GetParent().which].EditBoxOnEscapePressed;
    if ( EditBoxOnEscapePressed ) then
        EditBoxOnEscapePressed(this:GetParent().data);
    end
end

function StaticPopup2_EditBoxOnTextChanged()
    local EditBoxOnTextChanged = StaticPopup2Dialogs[this:GetParent().which].EditBoxOnTextChanged;
    if ( EditBoxOnTextChanged ) then
        EditBoxOnTextChanged(this:GetParent().data);
    end
end

function StaticPopup2_OnShow()
    PlaySound("igMainMenuOpen");
    local OnShow = StaticPopup2Dialogs[this.which].OnShow;

    if ( OnShow ) then
        OnShow(this.data);
    end
    if ( StaticPopup2Dialogs[this.which].hasMoneyInputFrame ) then
        _G[this:GetName().."MoneyInputFrameGold"]:SetFocus();
    end
end

function StaticPopup2_OnHide()
    PlaySound("igMainMenuClose");

    local OnHide = StaticPopup2Dialogs[this.which].OnHide;
    if ( OnHide ) then
        OnHide(this.data);
    end
end

function StaticPopup2_OnClick(dialog, index)
    local which = dialog.which;
    local dontHide = nil;
    if ( index == 1 ) then
        local OnAccept = StaticPopup2Dialogs[dialog.which].OnAccept;
        if ( OnAccept ) then
            dontHide = OnAccept(dialog.data, dialog.data2);
        end
    elseif ( index == 3 ) then
        local OnAlt = StaticPopup2Dialogs[dialog.which].OnAlt;
        if ( OnAlt ) then
            OnAlt(dialog.data, "clicked");
        end
    else
        local OnCancel = StaticPopup2Dialogs[dialog.which].OnCancel;
        if ( OnCancel ) then
            OnCancel(dialog.data, "clicked");
        end
    end

    if ( not dontHide and (which == dialog.which) ) then
        dialog:Hide();
    end
end

function StaticPopup2_Visible(which)
    for index = 1, STATICPOPUP2_NUMDIALOGS, 1 do
        local frame = _G["StaticPopup2"..index];
        if( frame:IsShown() and (frame.which == which) ) then
            return frame:GetName();
        end
    end
    return nil;
end

function StaticPopup2_EscapePressed()
    local closed = nil;
    for index = 1, STATICPOPUP2_NUMDIALOGS, 1 do
        local frame = _G["StaticPopup2"..index];
        if( frame:IsShown() and frame.hideOnEscape ) then
            local OnCancel = StaticPopup2Dialogs[frame.which].OnCancel;
            if ( OnCancel ) then
                OnCancel(frame.data, "clicked");
            end
            frame:Hide();
            closed = 1;
        end
    end
    return closed;
end
