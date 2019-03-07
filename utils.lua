-- this file should contains only functions to improve scripting experience
function onTalkContains(msg, callback)
	local function onTalk(name, level, mode, message, channelId, creaturePos)
		if message:find(msg) then
			callback(name, level, mode, message, channelId, creaturePos)
		end
	end
	connect(g_game, {onTalk = onTalk})
	return onTalk
end

function sendEquipItem(id)
	local protocol = g_game.getProtocolGame()
	local msg = OutputMessage.create()
	msg:addU8(119)    
	msg:addU16(id)
	protocol:send(msg)
end