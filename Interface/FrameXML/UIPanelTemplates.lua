-- functions to manage tab interfaces where only one tab of a group may be selected
function PanelTemplates_Tab_OnClick(frame)
	PanelTemplates_SetTab(frame, this:GetID())
end

function PanelTemplates_SetTab(frame, id)
	frame.selectedTab = id;
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_GetSelectedTab(frame)
	return frame.selectedTab;
end

function PanelTemplates_UpdateTabs(frame)
	if ( frame.selectedTab ) then
		local tab;
		for i=1, frame.numTabs, 1 do
			tab = _G[frame:GetName().."Tab"..i];
			if ( tab.isDisabled ) then
				PanelTemplates_SetDisabledTabState(tab);
			elseif ( i == frame.selectedTab ) then
				PanelTemplates_SelectTab(tab);
			else
				PanelTemplates_DeselectTab(tab);
			end
		end
	end
end

function PanelTemplates_TabResize(padding, tab, absoluteSize, maxWidth)
	local tabName;
	if ( tab ) then
		tabName = tab:GetName();
	else
		tabName = this:GetName();
		tab = this;
	end
	local buttonMiddle = _G[tabName.."Middle"];
	local buttonMiddleDisabled = _G[tabName.."MiddleDisabled"];
	local sideWidths = 2 * _G[tabName.."Left"]:GetWidth();
	local tabText = _G[tab:GetName().."Text"];
	local width, tabWidth;

	-- If there's an absolute size specified then use it
	if ( absoluteSize ) then
		if ( absoluteSize < sideWidths) then
			width = 1;
			tabWidth = sideWidths
		else
			width = absoluteSize - sideWidths;
			tabWidth = absoluteSize
		end
		tabText:SetWidth(width);
	else
		-- Otherwise try to use padding
		if ( padding ) then
			width = tabText:GetWidth() + padding;
		else
			width = tabText:GetWidth() + 24;
		end
		-- If greater than the maxWidth then cap it
		if ( maxWidth and width > maxWidth ) then
			if ( padding ) then
				width = maxWidth + padding;
			else
				width = maxWidth + 24;
			end
			tabText:SetWidth(width);
		else
			tabText:SetWidth(0);
		end
		tabWidth = width + sideWidths;
	end

	if ( buttonMiddle ) then
		buttonMiddle:SetWidth(width);
	end
	if ( buttonMiddleDisabled ) then
		buttonMiddleDisabled:SetWidth(width);
	end

	tab:SetWidth(tabWidth);
	local highlightTexture = _G[tabName.."HighlightTexture"];
	if ( highlightTexture ) then
		highlightTexture:SetWidth(tabWidth);
	end
end

function PanelTemplates_SetNumTabs(frame, numTabs)
	frame.numTabs = numTabs;
end

function PanelTemplates_DisableTab(frame, index)
	_G[frame:GetName().."Tab"..index].isDisabled = 1;
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_EnableTab(frame, index)
	local tab = _G[frame:GetName().."Tab"..index];
	tab.isDisabled = nil;
	-- Reset text color
	tab:SetDisabledTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_DeselectTab(tab)
	local name = tab:GetName();
	_G[name.."Left"]:Show();
	_G[name.."Middle"]:Show();
	_G[name.."Right"]:Show();
	--tab:UnlockHighlight();
	tab:Enable();
	_G[name.."LeftDisabled"]:Hide();
	_G[name.."MiddleDisabled"]:Hide();
	_G[name.."RightDisabled"]:Hide();
end

function PanelTemplates_SelectTab(tab)
	local name = tab:GetName();
	_G[name.."Left"]:Hide();
	_G[name.."Middle"]:Hide();
	_G[name.."Right"]:Hide();
	--tab:LockHighlight();
	tab:Disable();
	_G[name.."LeftDisabled"]:Show();
	_G[name.."MiddleDisabled"]:Show();
	_G[name.."RightDisabled"]:Show();

	if ( GameTooltip:IsOwned(tab) ) then
		GameTooltip:Hide();
	end
end

function PanelTemplates_SetDisabledTabState(tab)
	local name = tab:GetName();
	_G[name.."Left"]:Show();
	_G[name.."Middle"]:Show();
	_G[name.."Right"]:Show();
	--tab:UnlockHighlight();
	tab:Disable();
	tab.text = tab:GetText();
	-- Gray out text
	tab:SetDisabledTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	_G[name.."LeftDisabled"]:Hide();
	_G[name.."MiddleDisabled"]:Hide();
	_G[name.."RightDisabled"]:Hide();
end

function ScrollFrameTemplate_OnMouseWheel(value)
	local scrollBar = _G[this:GetName().."ScrollBar"];
	if ( value > 0 ) then
		scrollBar:SetValue(scrollBar:GetValue() - (scrollBar:GetHeight() / 2));
	else
		scrollBar:SetValue(scrollBar:GetValue() + (scrollBar:GetHeight() / 2));
	end
end

-- Function to handle the update of manually calculated scrollframes.  Used mostly for listings with an indeterminate number of items
function FauxScrollFrame_Update(frame, numItems, numToDisplay, valueStep, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth )
	-- If more than one screen full of skills then show the scrollbar
	local frameName = frame:GetName();
	local scrollBar = _G[ frameName.."ScrollBar" ];
	local showScrollBar;
	if ( numItems > numToDisplay ) then
		frame:Show();
		showScrollBar = 1;
	else
		scrollBar:SetValue(0);
		frame:Hide();
	end
	if ( frame:IsVisible() ) then
		local scrollChildFrame = _G[ frameName.."ScrollChildFrame" ];
		local scrollUpButton = _G[ frameName.."ScrollBarScrollUpButton" ];
		local scrollDownButton = _G[ frameName.."ScrollBarScrollDownButton" ];
		local scrollFrameHeight = 0;
		local scrollChildHeight = 0;

		if ( numItems > 0 ) then
			scrollFrameHeight = (numItems - numToDisplay) * valueStep;
			scrollChildHeight = numItems * valueStep;
			if ( scrollFrameHeight < 0 ) then
				scrollFrameHeight = 0;
			end
			scrollChildFrame:Show();
		else
			scrollChildFrame:Hide();
		end
		scrollBar:SetMinMaxValues(0, scrollFrameHeight);
		scrollBar:SetValueStep(valueStep);
		scrollChildFrame:SetHeight(scrollChildHeight);

		-- Arrow button handling
		if ( scrollBar:GetValue() == 0 ) then
			scrollUpButton:Disable();
		else
			scrollUpButton:Enable();
		end
		if ((scrollBar:GetValue() - scrollFrameHeight) == 0) then
			scrollDownButton:Disable();
		else
			scrollDownButton:Enable();
		end

		-- Shrink because scrollbar is shown
		if ( highlightFrame ) then
			highlightFrame:SetWidth(smallHighlightWidth);
		end
		if ( button ) then
			for i=1, numToDisplay do
				_G[button..i]:SetWidth(smallWidth);
			end
		end
	else
		-- Widen because scrollbar is hidden
		if ( highlightFrame ) then
			highlightFrame:SetWidth(bigHighlightWidth);
		end
		if ( button ) then
			for i=1, numToDisplay do
				_G[button..i]:SetWidth(bigWidth);
			end
		end
	end
	return showScrollBar;
end

function FauxScrollFrame_OnVerticalScroll(itemHeight, updateFunction)
	local scrollbar = _G[this:GetName().."ScrollBar"];
	scrollbar:SetValue(arg1);
	this.offset = floor((arg1 / itemHeight) + 0.5);
	updateFunction();
end

function FauxScrollFrame_GetOffset(frame)
	return frame.offset;
end

function FauxScrollFrame_SetOffset(frame, offset)
	frame.offset = offset;
end

-- Scrollframe functions
function ScrollFrame_OnLoad()
	_G[this:GetName().."ScrollBarScrollDownButton"]:Disable();
	_G[this:GetName().."ScrollBarScrollUpButton"]:Disable();

	local scrollbar = _G[this:GetName().."ScrollBar"];
	scrollbar:SetMinMaxValues(0, 0);
	scrollbar:SetValue(0);
	this.offset = 0;
end

function ScrollFrame_OnScrollRangeChanged(scrollrange)
	local scrollbar = _G[this:GetName().."ScrollBar"];
	if ( not scrollrange ) then
		scrollrange = this:GetVerticalScrollRange();
	end
	local value = scrollbar:GetValue();
	if ( value > scrollrange ) then
		value = scrollrange;
	end
	scrollbar:SetMinMaxValues(0, scrollrange);
	scrollbar:SetValue(value);
	if ( floor(scrollrange) == 0 ) then
		if (this.scrollBarHideable ) then
			_G[this:GetName().."ScrollBar"]:Hide();
			_G[scrollbar:GetName().."ScrollDownButton"]:Hide();
			_G[scrollbar:GetName().."ScrollUpButton"]:Hide();
		else
			_G[scrollbar:GetName().."ScrollDownButton"]:Disable();
			_G[scrollbar:GetName().."ScrollUpButton"]:Disable();
			_G[scrollbar:GetName().."ScrollDownButton"]:Show();
			_G[scrollbar:GetName().."ScrollUpButton"]:Show();
		end
		_G[scrollbar:GetName().."ThumbTexture"]:Hide();
	else
		_G[scrollbar:GetName().."ScrollDownButton"]:Show();
		_G[scrollbar:GetName().."ScrollUpButton"]:Show();
		_G[this:GetName().."ScrollBar"]:Show();
		_G[scrollbar:GetName().."ScrollDownButton"]:Enable();
		_G[scrollbar:GetName().."ThumbTexture"]:Show();
	end

	-- Hide/show scrollframe borders
	local top = _G[this:GetName().."Top"];
	local bottom = _G[this:GetName().."Bottom"];
	local middle = _G[this:GetName().."Middle"];
	if ( top and bottom and this.scrollBarHideable) then
		if ( this:GetVerticalScrollRange() == 0 ) then
			top:Hide();
			bottom:Hide();
		else
			top:Show();
			bottom:Show();
		end
	end
	if ( middle and this.scrollBarHideable) then
		if ( this:GetVerticalScrollRange() == 0 ) then
			middle:Hide();
		else
			middle:Show();
		end
	end
end

function ScrollingEdit_OnTextChanged(scrollFrame)
	if ( not scrollFrame ) then
		scrollFrame = this:GetParent();
	end
	scrollFrame:UpdateScrollChildRect();
end

function ScrollingEdit_OnCursorChanged(x, y, w, h)
	this.cursorOffset = y;
	this.cursorHeight = h;
end

function ScrollingEdit_OnUpdate(scrollFrame)
	if ( this.cursorOffset ) then
		if ( not scrollFrame ) then
			scrollFrame = this:GetParent();
		end
		local height = scrollFrame:GetHeight();
		local range = scrollFrame:GetVerticalScrollRange();
		local scroll = scrollFrame:GetVerticalScroll();
		local size = height + range;
		local cursorOffset = -this.cursorOffset;
		while ( cursorOffset < scroll ) do
			scroll = (scroll - (height / 2));
			if ( scroll < 0 ) then
				scroll = 0;
			end
			scrollFrame:SetVerticalScroll(scroll);
		end
		while ( (cursorOffset + this.cursorHeight) > (scroll + height) and scroll < range ) do
			scroll = (scroll + (height / 2));
			if ( scroll > range ) then
				scroll = range;
			end
			scrollFrame:SetVerticalScroll(scroll);
		end
		this.cursorOffset = nil;
	end
end
