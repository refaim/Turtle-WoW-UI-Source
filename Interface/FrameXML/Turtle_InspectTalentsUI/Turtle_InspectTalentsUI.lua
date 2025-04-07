local talentLoaded, talentReason = LoadAddOn("Blizzard_TalentUI")
local inspectLoaded, inspectReason = LoadAddOn("Blizzard_InspectUI")

if talentLoaded and inspectLoaded then
	local TWInspectFrame_Show = InspectFrame_Show
	if TWInspectFrame_Show then
		InspectFrame_Show = function(unit)
			TWInspectFrame_Show(unit)
			if UnitName('target') then
				SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. UnitName('target') ..">", "INSShowTransmogs", "GUILD")
			end
			if not InspectFrameTab3 then
				CreateFrame('Button', 'InspectFrameTab3', InspectFrame, 'CharacterFrameTabButtonTemplate')
				InspectFrameTab3:SetPoint("LEFT", InspectFrameTab2, "RIGHT", -16, 0)
				InspectFrameTab3:SetID(3)
				InspectFrameTab3:SetText(TALENTS)
				InspectFrameTab3:SetScript("OnEnter", function()
					GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
					GameTooltip:SetText(TALENTS, 1.0,1.0,1.0 );
				end)
				InspectFrameTab3:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
				InspectFrameTab3:SetScript("OnClick", function()
					InspectFrameTalentsTab_OnClick()
				end)
				InspectFrameTab3:Show()
				PanelTemplates_TabResize(0, InspectFrameTab3);

				INSPECTFRAME_SUBFRAMES = { "InspectPaperDollFrame", "InspectHonorFrame", "InspectTalentsFrame" };
				UIPanelWindows["InspectFrame"] = { area = "left", pushable = 0 };

				PanelTemplates_SetNumTabs(InspectFrame, 3)
				PanelTemplates_SetTab(InspectFrame, 1)
			end
		end
	end
end

local loadedFor = ""

function InspectFrameTalentsTab_OnClick()
	if loadedFor ~= UnitName('target') then
		Ins_Init()
		SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. UnitName('target') ..">", "INSShowTalents", "GUILD")
	else
		TWInspectTalents_Show()
	end
	PlaySound("igCharacterInfoTab");
	loadedFor = UnitName('target')
end
