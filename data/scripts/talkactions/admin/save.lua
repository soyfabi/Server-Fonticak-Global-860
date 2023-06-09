local savingEvent = 0
function saveLoop(delay)
	if delay > 0 then
		savingEvent = addEvent(saveLoop, delay, delay)
	end
end

local save = TalkAction("/save")

function save.onSay(player, words, param)
	if player:getGroup():getAccess() then
		if isNumber(param) then
			stopEvent(savingEvent)
			saveLoop(tonumber(param) * 60 * 1000)
		else
			saveServer()
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Server is saved ...")
		end
	end
end

save:separator(" ")
save:register()
