-- this file should contains only functions to improve scripting experience
function onTalkContains(msg, callback)
	local function onTalk(name, level, mode, message, channelId, creaturePos)
		if message:lower():find(msg:lower()) then
			callback(name, level, mode, message, channelId, creaturePos)
		end
	end
	connect(g_game, {onTalk = onTalk})
	return onTalk
end

function onScriptCallback(initFunc, terminateFunc, file)
	if file then
		if type(file) ~= "string" then 
			error("file parameter must be a string")	
		end
		dofile(file)
	end
	if type(initFunc) ~= "function" or type(terminateFunc) ~= "function" then
		error("initFunc and terminateFunc must be a function") 
	end
	ScriptsManager.unhook() -- avoid getting data from functions called by initFunc
	return initFunc()
end

function sendEquipItem(id)
	local protocol = g_game.getProtocolGame()
	local msg = OutputMessage.create()
	msg:addU8(119)    
	msg:addU16(id)
	protocol:send(msg)
end