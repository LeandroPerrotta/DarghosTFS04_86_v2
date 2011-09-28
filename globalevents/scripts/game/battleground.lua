local lastEvent = nil

local timeLeftMessage = 0
local timeLeftMessages = {
	{ interval = 60*5, text = "Restam 10 minuto para o fim da partida."},
	{ interval = 60*3, text = "Restam 5 minutos para o fim da partida."},
	{ interval = 60, text = "Restam 2 minutos para o fim da partida."},
	{ interval = 30, text = "Restam 1 minuto para o fim da partida."},
	{ interval = 10, text = "Restam 30 segundos para o fim da partida."},
	{ interval = 10, text = "Restam 20 segundos para o fim da partida."},
	{ interval = 5, text = "Restam 10 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 5 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 4 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 3 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 2 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 1 segundos para o fim da partida."},
	{ text = "A partida está encerrada!"}
}

function onBattlegroundStart()

	local wallsUidStart, wallsUidEnd = 20502, 20509
	local ITEM_GATE = 10652
	
	for i = wallsUidStart, wallsUidEnd do
		local thing = getTileItemById(getThingPos(i), ITEM_GATE)
		doRemoveItem(thing.uid)
	end
	
	addEvent(messageTimeLeft, 1000)
	
	return true
end

function messageTimeLeft()
	local reset = false
	if(timeLeftMessage == #timeLeftMessages) then
		reset = true
	end

	if(timeLeftMessage == 0)  then
		broadcastChannel(CUSTOM_CHANNEL_PVP, "Restam 15 minutos para o fim da partida.", TALKTYPE_TYPES["channel-orange"])
		lastEvent = addEvent(showMessage, 1000 * 29)
	else
		broadcastChannel(CUSTOM_CHANNEL_PVP, timeLeftMessage[timeLeftMessage].text, TALKTYPE_TYPES["channel-orange"])
		if(not reset) then
			lastEvent = addEvent(showMessage, 1000 * timeLeftMessage[timeLeftMessage].interval)
		end
	end
	
	if(not reset) then
		timeLeftMessage = timeLeftMessage + 1	
	else
		timeLeftMessage = 0
		lastEvent = nil
	end
end

function onBattlegroundEnd()

	addEvent(addWalls, 1000 * 6)	
	
	if(lastEvent ~= nil) then
		stopEvent(lastEvent)
		timeLeftMessage = 0
		lastEvent = nil
	end
	
	return true
end

function addWalls()

	clearBattlegroundStatistics()

	local wallsUidStart, wallsUidEnd = 20502, 20509
	local ITEM_GATE = 10652
	
	for i = wallsUidStart, wallsUidEnd do
		local pos = getThingPos(i)
		doCreateItem(ITEM_GATE, pos)
	end
end

local messages = {
	{ interval = 30, text = "A partida iniciará em 1 minuto e 30 segundos."},
	{ interval = 30, text = "A partida iniciará em 1 minuto."},
	{ interval = 10, text = "A partida iniciará em 30 segundos."},
	{ interval = 10, text = "A partida iniciará em 20 segundos."},
	{ interval = 5, text = "A partida iniciará em 10 segundos."},
	{ interval = 1, text = "A partida iniciará em 5 segundos."},
	{ interval = 1, text = "A partida iniciará em 4 segundos."},
	{ interval = 1, text = "A partida iniciará em 3 segundos."},
	{ interval = 1, text = "A partida iniciará em 2 segundos."},
	{ interval = 1, text = "A partida iniciará em 1 segundo."},
	{ text = "A partida está iniciada!"}
}

local message = 0

function onBattlegroundPrepare()

	addEvent(showMessage, 1000)
	return true
end

function showMessage()

	local reset = false
	if(message == #messages) then
		reset = true
	end

	if(message == 0)  then
		broadcastChannel(CUSTOM_CHANNEL_PVP, "A partida iniciará em 2 minutos.", TALKTYPE_TYPES["channel-orange"])
		addEvent(showMessage, 1000 * 29)
	else
		broadcastChannel(CUSTOM_CHANNEL_PVP, messages[message].text, TALKTYPE_TYPES["channel-orange"])
		if(not reset) then
			addEvent(showMessage, 1000 * messages[message].interval)
		end
	end
	
	if(not reset) then
		message = message + 1	
	else
		message = 0
	end
end