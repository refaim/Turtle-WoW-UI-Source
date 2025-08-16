local spellCom = CreateFrame("Frame")
spellCom:RegisterEvent("CHAT_MSG_ADDON")
spellCom:RegisterEvent("VARIABLES_LOADED")

local function Send(name, msg)
	SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. name .. ">", msg, "GUILD")
end

local function ShowSpellTooltip(arg)
	local _, _, spellInfo = string.find(arg, "_(.+)")
	if spellInfo then
		ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")

		local data = explode(spellInfo, "@")
		for _, s in pairs(data) do
			local _, _, side, line, text = strfind(s, "(%u)(%d+);(.+)")
			if side == "L" then
				text = gsub(text, "%*dd%*", ":")
				if string.find(text, ".", 1, true) then
					ItemRefTooltip:AddLine(text, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
				else
					ItemRefTooltip:AddLine(text, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, false)
				end
				_G["ItemRefTooltipTextLeft" .. line]:Show()
			end

			if side == "R" then
				text = gsub(text, "%*dd%*", ":")
				_G["ItemRefTooltipTextRight" .. line]:SetText(text)
				_G["ItemRefTooltipTextRight" .. line]:Show()
			end
		end
		ItemRefTooltip:Show()
	end
end

spellCom:SetScript("OnEvent", function()
	if event == "VARIABLES_LOADED" then
		spellCom.HookFunctions()
	end

	if event == "CHAT_MSG_ADDON" and arg1 == "TW_CHAT_MSG_WHISPER" then

		local message = arg2
		local from = arg4

		if string.find(message, "SpellInfoAnswer_", 1, true) then
			ShowSpellTooltip(message)
		end
		if string.find(message, "TalentInfoAnswer_", 1, true) then
			ShowSpellTooltip(message)
		end
		if string.find(message, "TalentInfoRequest_", 1, true) then
			local _, _, tab, id = string.find(message, "_(%d+)_(%d+)")
			if tab and id then
				GameTooltip:ClearLines()
				GameTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
				GameTooltip:SetTalent(tonumber(tab), tonumber(id))
				GameTooltip:Show()

				local tip = ""
				for i = 1, 30 do
					local left = _G["GameTooltipTextLeft" .. i]
					local right = _G["GameTooltipTextRight" .. i]
					local textleft = left and left:IsVisible() and left:GetText()
					local textRight = right and right:IsVisible() and right:GetText()
					if textleft then
						tip = tip .. "L" .. i .. ";" .. textleft .. "@"
					end
					if textRight then
						tip = tip .. "R" .. i .. ";" .. textRight .. "@"
					end
				end
				GameTooltip:Hide()

				if tip ~= "" then
					tip = gsub(tip, ":", "*dd*")
					tip = gsub(tip, TOOLTIP_TALENT_LEARN, "")
					Send(from, ":TalentInfoAnswer_" .. tip)
				end

			end
		end
		if string.find(message, "SpellInfoRequest_", 1, true) then
			local _, _, spellData = string.find(message, "_(%d+)")
			local id = tonumber(spellData)
			if id then
				GameTooltip:ClearLines()
				GameTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
				GameTooltip:SetSpell(id, SpellBookFrame.bookType)
				GameTooltip:Show()

				local tip = ""
				for i = 1, 30 do
					local left = _G["GameTooltipTextLeft" .. i]
					local right = _G["GameTooltipTextRight" .. i]
					local textleft = left and left:IsVisible() and left:GetText()
					local textRight = right and right:IsVisible() and right:GetText()
					if textleft then
						tip = tip .. "L" .. i .. ";" .. textleft .. "@"
					end
					if textRight then
						tip = tip .. "R" .. i .. ";" .. textRight .. "@"
					end
				end
				GameTooltip:Hide()

				if tip ~= "" then
					tip = gsub(tip, ":", "*dd*")
					Send(from, ":SpellInfoAnswer_" .. tip)
				end
			end
		end
	end
end)

function SpellButton_OnClick(drag)
	local id = SpellBook_GetSpellID(this:GetID())
	if (id > MAX_SPELLS) then
		return
	end
	this:SetChecked("false")
	if (drag) then
		PickupSpell(id, SpellBookFrame.bookType)
	elseif (IsShiftKeyDown()) then
		local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType)
		if (MacroFrame and MacroFrame:IsVisible()) then
			if (spellName and not IsSpellPassive(id, SpellBookFrame.bookType)) then
				if (subSpellName and (string.len(subSpellName) > 0)) then
					MacroFrame_AddMacroLine(TEXT(SLASH_CAST1) .. " " .. spellName .. "(" .. subSpellName .. ")")
				else
					MacroFrame_AddMacroLine(TEXT(SLASH_CAST1) .. " " .. spellName)
				end
			end
		elseif ChatFrameEditBox:IsVisible() and spellName then
			local spell = "|cFF71D5FF|Hspell:" .. id .. ":0:" .. UnitName("player") .. ":|h[" .. spellName .. "]|h|r"
			ChatFrameEditBox:Insert(spell)
		else
			PickupSpell(id, SpellBookFrame.bookType)
		end
	elseif (arg1 ~= "LeftButton" and SpellBookFrame.bookType == BOOKTYPE_PET) then
		ToggleSpellAutocast(id, SpellBookFrame.bookType)
	else
		CastSpell(id, SpellBookFrame.bookType)
		SpellButton_UpdateSelection()
	end
end

function spellCom.HookFunctions()
	local talent_click = TalentFrameTalent_OnClick

	if talent_click then
		TalentFrameTalent_OnClick = function()
			if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
				local name = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), this:GetID())
				local talent = "|cFF71D5FF|Htalent:" .. PanelTemplates_GetSelectedTab(TalentFrame) .. ":" .. this:GetID() .. ":" .. UnitName("player") .. ":|h[" .. name .. "]|h|r"
				ChatFrameEditBox:Insert(talent)
				return
			end
			talent_click()
		end
	end

	local hyperlink_show = ChatFrame_OnHyperlinkShow

	if hyperlink_show then
		ChatFrame_OnHyperlinkShow = function(link, text, button)
			if string.sub(link, 1, 5) == "spell" then

				if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
					ChatFrameEditBox:Insert(text)
					return
				end

				local _, _, index, player = string.find(link, "spell:(%d+):%d+:(%w+)")
				if index and player then
					Send(player, ":SpellInfoRequest_" .. index)
				end

				return
			elseif string.sub(link, 1, 6) == "talent" then
				if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
					ChatFrameEditBox:Insert(text)
					return
				end

				local _, _, tree, index, player = string.find(link, "talent:(%d+):(%d+):(%w+)")

				if tree and index and player then
					Send(player, ":TalentInfoRequest_" .. tree .. "_" .. index)
				end

				return
			end

			hyperlink_show(link, text, button)
		end
	end
end
