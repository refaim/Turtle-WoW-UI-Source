local spellCom = CreateFrame("Frame")

spellCom:RegisterEvent("ADDON_LOADED")

local function Send(name, msg)
	SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. name .. ">", msg, "GUILD")
end

local tip = {}

function SpellChatLinks_HandleMessage(message, sender)
	if strfind(message, "SpellInfoAnswer_", 1, true) or strfind(message, "TalentInfoAnswer_", 1, true) then
		local _, _, spellInfo = string.find(message, "_(.+)")

		if not spellInfo then
			return
		end

		local data = explode(spellInfo, "@")

		ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
		for i = 1, getn(data) do
			local _, _, side, line, text, r, g, b = strfind(data[i], "(%u)(%d+);(.+);(%d%.%d%d),(%d%.%d%d),(%d%.%d%d)")
			if side == "L" then
				ItemRefTooltip:AddLine(text, r, g, b, i == getn(data))
				_G["ItemRefTooltipTextLeft" .. line]:Show()
			elseif side == "R" then
				_G["ItemRefTooltipTextRight" .. line]:SetText(text)
				_G["ItemRefTooltipTextRight" .. line]:SetTextColor(r, g, b)
				_G["ItemRefTooltipTextRight" .. line]:Show()
			end
		end
		ItemRefTooltip:Show()

	elseif strfind(message, "TalentInfoRequest_", 1, true) then
		local _, _, tab, id = string.find(message, "_(%d+)_(%d+)")

		if not tab or not id then
			return
		end

		GameTooltip:ClearLines()
		GameTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
		GameTooltip:SetTalent(tonumber(tab), tonumber(id))
		GameTooltip:Show()

		wipe(tip)
		local msg = ""
		for i = 1, GameTooltip:NumLines() do
			local left = _G["GameTooltipTextLeft" .. i]
			local right = _G["GameTooltipTextRight" .. i]
			local textleft = left and left:IsVisible() and left:GetText()
			local textRight = right and right:IsVisible() and right:GetText()
			if textleft and textleft == TOOLTIP_TALENT_NEXT_RANK then
				tremove(tip)
				break
			end
			if textleft and textleft ~= TOOLTIP_TALENT_LEARN then
				local r, g, b = left:GetTextColor()
				r, g, b = format("%.2f", r), format("%.2f", g), format("%.2f", b)
				tinsert(tip, "L"..i..";"..textleft..";"..r..","..g..","..b)
				if textRight then
					r, g, b = right:GetTextColor()
					r, g, b = format("%.2f", r), format("%.2f", g), format("%.2f", b)
					tinsert(tip, "R"..i..";"..textRight..";"..r..","..g..","..b)
				end
			end
		end
		GameTooltip:Hide()

		msg = table.concat(tip, "@")
		if msg ~= "" then
			Send(sender, "TalentInfoAnswer_" .. msg)
		end

	elseif strfind(message, "SpellInfoRequest_", 1, true) then
		local _, _, spell, bookType = string.find(message, "_(%d+)_(%w+)")
		local id = tonumber(spell)

		if not id or not bookType then
			return
		end
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
		GameTooltip:SetSpell(id, bookType)
		GameTooltip:Show()

		wipe(tip)
		local msg = ""
		for i = 1, GameTooltip:NumLines() do
			local left = _G["GameTooltipTextLeft" .. i]
			local right = _G["GameTooltipTextRight" .. i]
			local textleft = left and left:IsVisible() and left:GetText()
			local textRight = right and right:IsVisible() and right:GetText()
			if textleft then
				local r, g, b = left:GetTextColor()
				r, g, b = format("%.2f", r), format("%.2f", g), format("%.2f", b)
				tinsert(tip, "L"..i..";"..textleft..";"..r..","..g..","..b)
				if textRight then
					r, g, b = right:GetTextColor()
					r, g, b = format("%.2f", r), format("%.2f", g), format("%.2f", b)
					tinsert(tip, "R"..i..";"..textRight..";"..r..","..g..","..b)
				end
			end
		end
		GameTooltip:Hide()

		msg = table.concat(tip, "@")
		if msg ~= "" then
			Send(sender, "SpellInfoAnswer_" .. msg)
		end
	end
end

spellCom:SetScript("OnEvent", function()
	if event == "ADDON_LOADED" and arg1 ~= "Blizzard_TalentUI" then
		return
	end

	local talent_click = TalentFrameTalent_OnClick

	TalentFrameTalent_OnClick = function()
		if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
			local name = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), this:GetID())
			local talent = "|cFF71D5FF|Htalent:" .. PanelTemplates_GetSelectedTab(TalentFrame) .. ":" .. this:GetID() .. ":" .. UnitName("player") .. ":|h[" .. name .. "]|h|r"
			ChatFrameEditBox:Insert(talent)
			return
		end
		talent_click()
	end

	spellCom:UnregisterEvent("ADDON_LOADED")
end)

local spell_button_click = SpellButton_OnClick

function SpellButton_OnClick(drag)
	local id = SpellBook_GetSpellID(this:GetID())
	if ( id > MAX_SPELLS ) then
		return
	end
	this:SetChecked(IsCurrentCast(id, SpellBookFrame.bookType))
	if IsShiftKeyDown() and not drag and ChatFrameEditBox:IsVisible() and not (MacroFrame and MacroFrame:IsVisible()) then
		local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType)
		if spellName then
			ChatFrameEditBox:Insert("|cFF71D5FF|Hspell:"..id..":"..SpellBookFrame.bookType..":"..UnitName("player")..":|h["..spellName.."]|h|r")
		end
	else
		spell_button_click(drag)
	end
end

local hyperlink_show = ChatFrame_OnHyperlinkShow

ChatFrame_OnHyperlinkShow = function(link, text, button)
	if string.sub(link, 1, 5) == "spell" then

		if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
			ChatFrameEditBox:Insert(text)
			return
		end

		local _, _, index, bookType, player = string.find(link, "spell:(%d+):(%w+):(%w+)")

		if not index or not bookType or not player then
			return
		end
		if player == UnitName("player") then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
			ItemRefTooltip:SetSpell(tonumber(index), bookType)
			ItemRefTooltip:Show()
		else
			Send(player, "SpellInfoRequest_" .. index.."_"..bookType)
		end

	elseif string.sub(link, 1, 6) == "talent" then
		if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
			ChatFrameEditBox:Insert(text)
			return
		end

		local _, _, tree, index, player = string.find(link, "talent:(%d+):(%d+):(%w+)")

		if not tree or not index or not player then
			return
		end

		if player == UnitName("player") then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
			ItemRefTooltip:SetTalent(tonumber(tree), tonumber(index))
			for i = 1, ItemRefTooltip:NumLines() do
				local left = _G["ItemRefTooltipTextLeft"..i]
				if left then
					if left:GetText() == TOOLTIP_TALENT_LEARN then
						left:SetText()
						left:Hide()
					elseif left:GetText() == TOOLTIP_TALENT_NEXT_RANK then
						for j = i - 1, ItemRefTooltip:NumLines() do
							left = _G["ItemRefTooltipTextLeft"..j]
							if left then
								left:SetText()
								left:Hide()
							end
						end
						break
					end
				end
			end
			ItemRefTooltip:Show()
		else
			Send(player, "TalentInfoRequest_" .. tree .. "_" .. index)
		end

	else
		hyperlink_show(link, text, button)
	end
end
