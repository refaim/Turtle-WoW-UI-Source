ChatFrame_OnEvent_Original = ChatFrame_OnEvent

function ChatFrame_OnEvent(event)
	if  event == "CHAT_MSG_HARDCORE" then
	
		--Remove GM's coloured text from the message
		local output,c = string.gsub(arg1, "^|c", "")
		if c then _, _, output = string.find(arg1,"(ª.*ª)") end
		if output == nil then output = arg1 end

		--Some checks to see if the message is the spoofed AddonMessage
		local _,c=string.gsub(output,"ª","")
		if string.sub(output,1, 2) == "ª" and string.sub(output,-2) == "ª" and c == 3 then
			
			--[[
			-- This is an example of how you could convert this CHAT_MSG into a similar format to a regular CHAT_MSG_ADDON event.
			-- I recommend using copying this entire function as is and expanding this commented section for your addons.
			
			local tbl = {}
			for v in string.gfind(output, "[^ª]+") do
				tinsert(tbl, v)
			end
				
			local prefix = tbl[1]
			local text = tbl[2]
			local sender = arg2
			local msgType = "HARDCORE"
					
			]]--
			return false --Hides the "AddonMessage" from the Hardcore chat client side.
		end
	end
	ChatFrame_OnEvent_Original(event)
end

-- Extends SendAddonMessage() to support a "HARDCORE" type.
SendAddonMessage_Original = SendAddonMessage
function SendAddonMessage(prefix, text, msgType, target)

	if msgType == "HARDCORE" then
		SendChatMessage("ª"..prefix.."ª"..text.."ª","HARDCORE")
		return false
	else
		SendAddonMessage_Original(prefix,text,msgType)
	end
end