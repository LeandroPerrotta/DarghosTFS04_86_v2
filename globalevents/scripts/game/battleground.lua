function onBattlegroundStart()

	local wallsUidStart, wallsUidEnd = 20502, 20509
	local ITEM_GATE = 10652
	
	for i = wallsUidStart, wallsUidEnd do
		local thing = getTileItemById(getThingPos(i), ITEM_GATE)
		doRemoveItem(thing.uid)
	end
	
	return true
end

function onBattlegroundEnd()

	local wallsUidStart, wallsUidEnd = 20502, 20509
	local ITEM_GATE = 10652
	
	for i = wallsUidStart, wallsUidEnd do
		local pos = getThingPos(i)
		doCreateItem(ITEM_GATE, pos)
	end
	
	return true
end

local messages = {
	{ interval = 30, text = "A partida iniciará em 1 minuto e 30 segundos."},
	{ interval = 30, text = "A partida iniciará em 1 minuto."},
	{ interval = 30, text = "A partida iniciará em 30 segundos."},
	{ interval = 10, text = "A partida iniciará em 20 segundos."},
	{ interval = 10, text = "A partida iniciará em 10 segundos."},
	{ interval = 5, text = "A partida iniciará em 5 segundos."},
	{ interval = 1, text = "A partida iniciará em 4 segundos."},
	{ interval = 1, text = "A partida iniciará em 3 segundos."},
	{ interval = 1, text = "A partida iniciará em 2 segundos."},
	{ interval = 1, text = "A partida iniciará em 1 segundo."},
	{ interval = 1, text = "A partida está iniciada!"}
}

local message = 0

function onBattlegroundPrepare()

	addEvent(1000, showMessage)
	return true
end

function showMessage()

	local reset = false
	if(message == #messages) then
		reset = true
	end

	if(message == 0)  then
		broadcastChannel(CUSTOM_CHANNEL_PVP, "A partida iniciará em 2 minutos.", TALKTYPE_TYPES["channel-orange"])
		addEvent(1000 * 29, showMessage)
	else
		broadcastChannel(CUSTOM_CHANNEL_PVP, messages[message].text, TALKTYPE_TYPES["channel-orange"])
		if(not reset) then
			addEvent(1000 * messages[message].interval, showMessage)
		end
	end
	
	if(not reset) then
		message = message + 1	
	else
		message = 0
	end
end