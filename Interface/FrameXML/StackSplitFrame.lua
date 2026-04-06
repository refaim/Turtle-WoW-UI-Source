
function OpenStackSplitFrame(maxStack, parent, anchor, anchorTo, minSplit)
	if ( StackSplitFrame.owner ) then
		StackSplitFrame.owner.hasStackSplit = 0;
	end

	if ( not maxStack or (maxStack <= 1) or (minSplit and maxStack <= minSplit) ) then
		StackSplitFrame:Hide();
		return;
	end

	StackSplitFrame.isMultiStack = minSplit and minSplit > 1;
	StackSplitFrame.maxStack = maxStack;
	StackSplitFrame.owner = parent;
	parent.hasStackSplit = 1;
	StackSplitFrame.minSplit = minSplit or 1;
	StackSplitFrame.split = StackSplitFrame.minSplit;
	StackSplitFrame.typing = 0;

	StackSplitFrame_UpdateText();

	StackSplitLeftButton:Disable();
	StackSplitRightButton:Enable();

	StackSplitFrame:ClearAllPoints();
	StackSplitFrame:SetPoint(anchor, parent, anchorTo, 0, 0);
	StackSplitFrame:Show();
end

function StackSplitFrame_UpdateText()
	if ( StackSplitFrame.isMultiStack ) then
		StackItemCountText:Show();
		StackItemCountText:SetText(format("%dx%d", StackSplitFrame.split / StackSplitFrame.minSplit, StackSplitFrame.minSplit));
	else
		StackItemCountText:Hide();
	end
	StackSplitText:SetText(StackSplitFrame.split);
end

function UpdateStackSplitFrame(maxStack)
	StackSplitFrame.maxStack = maxStack;
	if ( StackSplitFrame.maxStack < 2 ) then
		if ( StackSplitFrame.owner ) then
			StackSplitFrame.owner.hasStackSplit = 0;
		end
		StackSplitFrame:Hide();
		return;
	end

	if ( StackSplitFrame.split > StackSplitFrame.maxStack ) then
		StackSplitFrame.split = StackSplitFrame.maxStack;
		StackSplitText:SetText(StackSplitFrame.split);
	end

	if ( StackSplitFrame.split == StackSplitFrame.maxStack ) then
		StackSplitRightButton:Disable();
	else
		StackSplitRightButton:Enable();
	end

	if ( StackSplitFrame.split == 1 ) then
		StackSplitLeftButton:Disable();
	else
		StackSplitLeftButton:Enable();
	end
end

function StackSplitFrame_OnChar()
	if ( arg1 < "0" or arg1 > "9" ) then
		return;
	elseif ( this.isMultiStack and this.maxStack < this.minSplit * arg1 ) then
		this.typing = 0;
		return;
	end

	if ( this.typing == 0 ) then
		this.typing = 1;
		this.split = 0;
	end

	local split = (this.split * 10) + (this.minSplit * arg1);
	if ( split == this.split ) then
		if ( this.split == 0 ) then
			this.split = this.minSplit;
		end
		return;
	end

	if ( split <= this.maxStack ) then
		this.split = split;

		StackSplitFrame_UpdateText();

		if ( split == this.maxStack ) then
			StackSplitRightButton:Disable();
		else
			StackSplitRightButton:Enable();
		end

		if ( split == this.minSplit ) then
			StackSplitLeftButton:Disable();
		else
			StackSplitLeftButton:Enable();
		end
	elseif ( split == 0 ) then
		this.split = 1;
	end
end

function StackSplitFrame_OnKeyDown()
	if ( arg1 == "BACKSPACE" or arg1 == "DELETE" ) then
		if ( this.typing == 0 or this.split == this.minSplit ) then
			this.typing = 0;
			return;
		end

		this.split = floor(this.split / 10);
		if ( this.split <= this.minSplit ) then
			this.split = this.minSplit;
			this.typing = 0;
			StackSplitLeftButton:Disable();
		else
			StackSplitLeftButton:Enable();
		end

		StackSplitFrame_UpdateText();

		if ( this.split == this.maxStack ) then
			StackSplitRightButton:Disable();
		else
			StackSplitRightButton:Enable();
		end
	elseif ( arg1 == "ENTER" ) then
		StackSplitFrameOkay_Click();
	elseif ( arg1 == "ESCAPE" ) then
		StackSplitFrameCancel_Click();
	elseif ( arg1 == "LEFT" or arg1 == "DOWN" ) then
		StackSplitFrameLeft_Click();
	elseif ( arg1 == "RIGHT" or arg1 == "UP" ) then
		StackSplitFrameRight_Click();
	end
end

function StackSplitFrameLeft_Click()
	this.typing = 0;
	if ( StackSplitFrame.split == StackSplitFrame.minSplit ) then
		return;
	end

	StackSplitFrame.split = StackSplitFrame.split - StackSplitFrame.minSplit;
	StackSplitFrame_UpdateText();

	if ( StackSplitFrame.split == StackSplitFrame.minSplit ) then
		StackSplitLeftButton:Disable();
	end
	StackSplitRightButton:Enable();
end

function StackSplitFrameRight_Click()
	this.typing = 0;
	if ( StackSplitFrame.split == StackSplitFrame.maxStack ) then
		return;
	end

	StackSplitFrame.split = StackSplitFrame.split + StackSplitFrame.minSplit;
	StackSplitFrame_UpdateText()

	if ( StackSplitFrame.split == StackSplitFrame.maxStack ) then
		StackSplitRightButton:Disable();
	end
	StackSplitLeftButton:Enable();
end

function StackSplitFrameOkay_Click()
	if ( StackSplitFrame.owner ) then
		StackSplitFrame.owner.SplitStack(StackSplitFrame.owner, StackSplitFrame.split);
	end
	StackSplitFrame:Hide();
end

function StackSplitFrameCancel_Click()
	StackSplitFrame:Hide();
end

function StackSplitFrame_OnHide()
	if ( StackSplitFrame.owner ) then
		StackSplitFrame.owner.hasStackSplit = 0;
	end
end

function StackSplitFrame_OnMouseWheel()
	if ( arg1 == 1 ) then
		if ( IsShiftKeyDown() ) then
			if ( StackSplitFrame.split == StackSplitFrame.maxStack ) then
				return;
			end
			StackSplitFrame.split = StackSplitFrame.maxStack;
			StackSplitLeftButton:Enable();
			StackSplitRightButton:Disable();
			StackSplitFrame_UpdateText();
		else
			StackSplitFrameRight_Click();
		end
	elseif ( arg1 == -1 ) then
		if ( IsShiftKeyDown() ) then
			if ( StackSplitFrame.split == StackSplitFrame.minSplit ) then
				return;
			end
			StackSplitFrame.split = StackSplitFrame.minSplit;
			StackSplitLeftButton:Disable();
			StackSplitRightButton:Enable();
			StackSplitFrame_UpdateText();
		else
			StackSplitFrameLeft_Click();
		end
	end
end