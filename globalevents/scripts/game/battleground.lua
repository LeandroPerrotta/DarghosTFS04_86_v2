local lastEvent = nil
local bonusEvent = nil

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

function onBattlegroundStart(notJoinPlayers)

	local wallsUidStart, wallsUidEnd = 20502, 20509
	local ITEM_GATE = 10652
	
	for i = wallsUidStart, wallsUidEnd do
		local thing = getTileItemById(getThingPos(i), ITEM_GATE)
		doRemoveItem(thing.uid)
	end
	
	if(notJoinPlayers > 0) then
		broadcastChannel(CUSTOM_CHANNEL_PVP, notJoinPlayers .. " jogadores n�o compareceram ao inicio da partida e poder�o ser substituidos! Se voc� deseja IMEDIATAMENTE substituir esses jogadores digite '!bg entrar'!", TALKTYPE_TYPES["channel-orange"])	
	end
	
	addEvent(messageTimeLeft, 100)
	
	if(bonusEvent ~= nil) then
		stopEvent(bonusEvent)
	end
	
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
		msg = "" .. teams[winnerTeam] .. " � o VENCEDOR por ";
		
		if(points[winnerTeam] == BG_CONFIG_WINPOINTS) then
			msg = msg .. "pontos necess�rio para vitoria!"
		else
			msg = msg .. "mais pontos ao fim da partida!"
		end
	else
		msg = "N�o h� vencedor! EMPATE por igualdade de pontos ao fim da partida!"
	end	
	
	broadcastChannel(CUSTOM_CHANNEL_PVP, "Partida encerrada. " .. msg, TALKTYPE_TYPES["channel-orange"])

	minutesLeftMessage = BG_CONFIG_DURATION / 60
	secondsLeftMessage = 1
	lastEvent = nil	
	
	if(pvpBattleground.hasGain()) then
		bonusEvent = addEvent("checkBonus", 1000 * BG_BONUS_INTERVAL)
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
	{ interval = 30, text = "A partida iniciar� em 1 minuto e 30 segundos."},
	{ interval = 30, text = "A partida iniciar� em 1 minuto."},
	{ interval = 10, text = "A partida iniciar� em 30 segundos."},
	{ interval = 10, text = "A partida iniciar� em 20 segundos."},
	{ interval = 5, text = "A partida iniciar� em 10 segundos."},
	{ interval = 1, text = "A partida iniciar� em 5 segundos."},
	{ interval = 1, text = "A partida iniciar� em 4 segundos."},
	{ interval = 1, text = "A partida iniciar� em 3 segundos."},
	{ interval = 1, text = "A partida iniciar� em 2 segundos."},
	{ interval = 1, text = "A partida iniciar� em 1 segundo."},
	{ text = "A partida est� iniciada!"}
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
		broadcastChannel(CUSTOM_CHANNEL_PVP, "A partida iniciar� em 2 minutos.", TALKTYPE_TYPES["channel-orange"])
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

function checkBonus(onlyAlert)

	onlyAlert = onlyAlert or false

	if(not pvpBattleground.hasGain()) then
		return
	end

	local bonus = pvpBattleground.getBonus()
	bonus = bonus + 1
	
	local percent = bonus * BG_EACH_BONUS_PERCENT
	
	local hourStr = "na ultima hora"
	if(bonus > 1) then
		hourStr = "h� " .. bonus .. " horas"
	end
	
	doBroadcastMessage("Nenhuma Battleground foi iniciada " .. hourStr .. ", ser� concedido bon�s extra de " .. percent .. "% mais experience ao time vencedor da proxima Battleground! Garanta seu lugar na proxima e aproveite! -> !bg entrar",  MESSAGE_TYPES["green"])
	bonusEvent = addEvent("checkBonus", 1000 * BG_BONUS_INTERVAL)
	
	if(not onlyAlert) then
		pvpBattleground.setBonus(bonus)
	end
end

function onTime(time)

	local date = os.date("*t")	
	
	if(not isInArray(BG_GAIN_EVERYHOUR_DAYS, date.wday)) then
		if(date.hour == BG_GAIN_START_HOUR) then
			doBroadcastMessage("Este � um alerta para avisar que esta iniciado o periodo de recompensas em Battlegrounds de hoje! S�o mais de 12 horas de muito PvP para voc� aproveitar e conseguir experiencia, dinheiro, rating e fa�anhas no sistema! Tenha um bom dia!",  MESSAGE_TYPES["green"])
		
			if(pvpBattleground.getBonus() > 0) then
				addEvent("checkBonus", 1000 * 10, true)
			end
		elseif(date.hour == BG_GAIN_END_HOUR) then
			doBroadcastMessage("Este � um alerta para avisar que esta encerrado o periodo de recompensas em Battlegrounds por hoje! As Battlegrounds ir�o voltar a conceder recompensas a 11:00! Tenha uma boa noite!",  MESSAGE_TYPES["green"])
		end
	end
	
	return true
end