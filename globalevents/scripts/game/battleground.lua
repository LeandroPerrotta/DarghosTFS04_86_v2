local lastEvent = nil

local minutesLeftMessage = BG_CONFIG_DURATION / 60
local secondsLeftMessage = 1
local secondsLeftMessages = {
	{ interval = 10, text = "Restam 30 segundos para o fim da partida."},
	{ interval = 10, text = "Restam 20 segundos para o fim da partida."},
	{ interval = 5, text = "Restam 10 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 5 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 4 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 3 segundos para o fim da partida."},
	{ interval = 1, text = "Restam 2 segundos para o fim da partida."},
	{ text = "Restam 1 segundo para o fim da partida."},
}

function onBattlegroundStart()

	local wallsUidStart, wallsUidEnd = 20502, 20509
	local ITEM_GATE = 10652
	
	for i = wallsUidStart, wallsUidEnd do
		local thing = getTileItemById(getThingPos(i), ITEM_GATE)
		doRemoveItem(thing.uid)
	end
	
	addEvent(messageTimeLeft, 100)
	
	return true
end

function messageTimeLeft()

	if(minutesLeftMessage >= 1)  then
	
		local minutesStr = "minutos"
		if(minutesLeftMessage == 1)then
			minutesStr = "minuto"
		end
	
		broadcastChannel(CUSTOM_CHANNEL_PVP, "Restam " .. minutesLeftMessage .. " " .. minutesStr .. " para o fim da partida.", TALKTYPE_TYPES["channel-orange"])
		minutesLeftMessage = minutesLeftMessage - 1
		
		if(minutesLeftMessage > 0) then
			lastEvent = addEvent(messageTimeLeft, 1000 * 60)
		else
			lastEvent = addEvent(messageTimeLeft, 1000 * 30)
		end
	else
		local reset = false
		if(secondsLeftMessage == #secondsLeftMessages) then
			reset = true
		end	
	
		broadcastChannel(CUSTOM_CHANNEL_PVP, secondsLeftMessages[secondsLeftMessage].text, TALKTYPE_TYPES["channel-orange"])
		
		if(not reset) then
			lastEvent = addEvent(messageTimeLeft, 1000 * secondsLeftMessages[secondsLeftMessage].interval)
			secondsLeftMessage = secondsLeftMessage + 1	
		else
			minutesLeftMessage = BG_CONFIG_DURATION / 60
			secondsLeftMessage = 1
			lastEvent = nil
		end		
	end
end

function onBattlegroundEnd()

	addEvent(addWalls, 1000 * 6)	
	
	if(lastEvent ~= nil) then
		stopEvent(lastEvent)
		timeLeftMessage = 0
		lastEvent = nil
	end
	
	local points = getBattlegroundTeamsPoints()

	local teams = { "Time A", "Time B" }
	local msg = nil;
	
	if(points[BATTLEGROUND_TEAM_ONE] ~= points[BATTLEGROUND_TEAM_TWO]) then
		local winnerTeam = BATTLEGROUND_TEAM_NONE
		winnerTeam = (points[BATTLEGROUND_TEAM_ONE] > points[BATTLEGROUND_TEAM_TWO]) and BATTLEGROUND_TEAM_ONE or BATTLEGROUND_TEAM_TWO
		msg = "" .. teams[winnerTeam] .. " é o VENCEDOR por ";
		
		if(points[winnerTeam] == BG_CONFIG_WINPOINTS) then
			msg = msg .. "pontos necessário para vitoria!"
		else
			msg = msg .. "mais pontos ao fim da partida!"
		end
	else
		msg = "Não há vencedor! EMPATE por igualdade de pontos ao fim da partida!"
	end	
	
	broadcastChannel(CUSTOM_CHANNEL_PVP, "Partida encerrada. " .. msg, TALKTYPE_TYPES["channel-orange"])

	minutesLeftMessage = BG_CONFIG_DURATION / 60
	secondsLeftMessage = 1
	lastEvent = nil	
	
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

	addEvent(showMessage, 5000)
	return true
end

function showMessage()

	local reset = false
	if(message == #messages) then
		reset = true
	end

	if(message == 0)  then
		broadcastChannel(CUSTOM_CHANNEL_PVP, "A partida iniciará em 2 minutos.", TALKTYPE_TYPES["channel-orange"])
		addEvent(showMessage, 1000 * 30)
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