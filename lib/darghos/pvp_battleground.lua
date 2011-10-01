BROADCAST_STATISTICS_INTERVAL = 20
FREE_EXP_GAINS_DAY_LIMIT = 4

BG_CONFIG_TEAMSIZE = 6
BG_CONFIG_WINPOINTS = 50
BG_CONFIG_DURATION = 60 * 15

BG_RET_NO_ERROR = 0
BG_RET_CLOSED = 1
BG_RET_CAN_NOT_JOIN = 2
BG_RET_PUT_IN_WAITLIST = 3
BG_RET_PUT_INSIDE = 4
BG_RET_ALREADY_IN_WAITLIST = 5
BG_RET_INFIGHT = 6

BATTLEGROUND_TEAM_NONE = 0
BATTLEGROUND_TEAM_ONE = 1
BATTLEGROUND_TEAM_TWO = 2

BATTLEGROUND_MIN_LEVEL = 100
BATTLEGROUND_CAN_NON_PVP = true

BG_GAIN_EVERYHOUR_DAYS = { WEEKDAY.SATURDAY, WEEKDAY.SUNDAY }
BG_GAIN_START_HOUR = 12
BG_GAIN_END_HOUR = 2

pvpBattleground = {}

BATTLEGROUND_RATING = 3
BATTLEGROND_HIGH_RATE = 1601

battlegrondRatingTable = {

	{to = 400, multipler = 35},
	{from = 401, to = 800, multipler = 25},
	{from = 801, to = 1000, multipler = 10},
	{from = 1001, to = 1200, multipler = 8},
	{from = 1201, to = 1400, multipler = 6},
	{from = 1401, to = 1600, multipler = 5},
	{from = 1601, to = 2000, multipler = 4},
	{from = 2001, to = 2400, multipler = 3},
	{from = 2401, to = 2800, multipler = 2},
	{from = 2801, multipler = 1}
}

function pvpBattleground.getRatingMultipler(cid, rating)

	for k,v in pairs(battlegrondRatingTable) do
		local from = v.from or 0	
		local isLast = (v.to == nil) and true or false
		
		if(not isLast) then
			if(rating >= from and rating <= v.to) then
				return v.multipler
			end
		else
			return v.multipler
		end
	end
	
	return nil
end

function pvpBattleground.getPlayerRating(cid)
	local result = db.getResult("SELECT `battleground_rating` FROM `players` WHERE `id` = " .. getPlayerGUID(cid) .. ";")
	
	if(result:getID() ~= -1) then
		local rating = result:getDataInt("battleground_rating")
		result:free()
		
		return rating
	end	
end

function pvpBattleground.setPlayerRating(cid, rating)
	db.executeQuery("UPDATE `players` SET `battleground_rating` = " .. rating .. " WHERE `id` = " .. getPlayerGUID(cid) .. ";")
end

function pvpBattleground.onInit()
	local configs = {
		teamSize = BG_CONFIG_TEAMSIZE,
		winPoints = BG_CONFIG_WINPOINTS,
		duration = BG_CONFIG_DURATION,
	}
	
	setBattlegroundConfigs(configs)
end

function pvpBattleground.close()
	battlegroundClose()
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] Battleground temporareamente fechada. Voltará em alguns instantes.", TALKTYPE_TYPES["channel-red"])
end

function pvpBattleground.showResult(cid, winnner)

	clear = clear or true

	local teams = { "Time A", "Time B" }
	
	local msg = "Não houve vencedor, declarado EMPATE!\n\n";
	
	if(winnner ~= BATTLEGROUND_TEAM_NONE) then
		msg = "O " .. teams[winnner] .. " é o VENCEDOR!\n\n";
	end
	
	local data = getBattlegroundStatistics()
	
	if(data and #data > 0) then
		local i = 1
		for k,v in pairs(data) do
			
			local cid = getPlayerByGUID(v.player_id)
			if(cid ~= nil) then
				
				local team = teams[doPlayerGetBattlegroundTeam(cid)]
				
				if(team == nil) then
					team = "Fora"
				end
				
				local spaces_c = 40 - string.len(getPlayerName(cid)) - string.len(team)
				
				local spaces = ""	
				for i=1, spaces_c do spaces = spaces .. " " end
						
				msg = msg .. i .. "# " .. getPlayerName(cid) .. " (" .. team .. ")".. spaces .. "" .. v.kills .. " / " .. v.deaths .. "  [" .. v.assists .. "] \n"	
				i = i + 1
			end
		end
	end
	
	doPlayerPopupFYI(cid, msg)
end

function pvpBattleground.getInformations()
	local msg = ""
	msg = msg .. "Este é um sistema de PvP do Darghos, e o objetivo é seu time atingir 50 pontos, obtidos ao derrotar um oponente. A partida tem duração de até 15 minuto\n"
	msg = msg .. "se ao final do tempo nenhum time tiver atingido os 50 pontos a vitoria é concedida ao com maior numero de pontos, e empate no caso de igualdade de pontos\n"
	msg = msg .. "Aos participantes do time vencedor é concedido uma quantidade de pontos de experiencia e algum dinheiro!\n"
	msg = msg .. "Ao morrer você não perderá nada e nascera na base de seu time. Dentro da Battleground os danos são mais efetivos contra inimigos (100%) e diminuidos em aliados (25%)!\n"
	msg = msg .. "Use o PvP Channel para se comunicar com seus companheiros, somente eles poderão ler suas mensagens. Boa sorte!\n"

	return msg
end

function pvpBattleground.getPlayersTeamString(team_id)
	team_id = tonumber(team_id)
	local playersTeam = getBattlegroundPlayersByTeam(team_id)
	local teams = {[1] = "Time A", [2] = "Time B"}
	local msg = "Membros do " .. teams[team_id] .. " (comando \"!bg team\"):\n"
	
	if(playersTeam == nil or #playersTeam == 0) then return msg .. "Nenhum" end
	
	local islast = false
	for k,v in pairs(playersTeam) do
		
		if(#playersTeam == k) then
			islast = true
		end
		
		local player = getPlayerByGUID(v)
		
		if(player) then
			msg = msg .. getPlayerName(player) .. " (" .. getPlayerLevel(player) .. ")"
			msg = msg .. ((islast) and ".\n" or ", ")
		end
	end
	
	return msg
end

function pvpBattleground.sendPlayerChannelMessage(cid, msg, type)

	type = (type ~= nil) and type or TALKTYPE_TYPES["channel-white"]
	doPlayerSendChannelMessage(cid, "", msg, type, CUSTOM_CHANNEL_PVP)
end

function pvpBattleground.getExperienceGain(cid)
	return math.floor(getPlayerExperience(cid) * 0.0005 * getPlayerMultiple(cid, STAGES_EXPERIENCE))
end

function pvpBattleground.playerSpeakTeam(cid, message)
	
	local team_id = doPlayerGetBattlegroundTeam(cid)
	
	if(team_id == BATTLEGROUND_TEAM_NONE) then
		return false
	end
	
	local playersTeam = getBattlegroundPlayersByTeam(team_id)
	
	for k,v in pairs(playersTeam) do
		local target = getPlayerByGUID(v)
		doPlayerSendChannelMessage(target, getPlayerName(cid) .. " [" .. getPlayerLevel(cid) .. " | " .. pvpBattleground.getPlayerRating(cid) .. "]", message, TALKTYPE_TYPES["channel-yellow"], CUSTOM_CHANNEL_PVP)		
	end
	
	return true
end

function pvpBattleground.onEnter(cid)

	if(not isPlayer(cid)) then
		return false
	end

	if(getCreatureCondition(cid, CONDITION_OUTFIT)) then
		doPlayerSendCancel(cid, "Você não pode entrar na battleground enquanto estiver sob certos efeitos magicos.")
		return false
	end
	
	if(getPlayerLevel(cid) < BATTLEGROUND_MIN_LEVEL) then
		doPlayerSendCancel(cid, "So é permitido jogadores com level " .. BATTLEGROUND_MIN_LEVEL .. " ou superior a participarem de uma battleground.")
		return false	
	end
	
	local onIslandOfPeace = getPlayerTown(cid) == towns.ISLAND_OF_PEACE
	if(not BATTLEGROUND_CAN_NON_PVP and onIslandOfPeace) then
		doPlayerSendCancel(cid, "So é permitido jogadores em areas Open PvP a participarem de Battlegrounds.")
		return false	
	end	
	
	local ret = doPlayerJoinBattleground(cid)

	if(ret == BG_RET_CLOSED) then
		doPlayerSendCancel(cid, "A battleground está temporareamente fechada.")	
		return false
	end

	if(ret == BG_RET_CAN_NOT_JOIN) then
		doPlayerSendCancel(cid, "Você abandonou uma battleground e foi marcado como desertor, e não poderá entrar em outra durante 10 minutos.")
		return false
	end	
	
	if(ret == BG_RET_ALREADY_IN_WAITLIST) then
		doPlayerSendCancel(cid, "Você já se encontra na fila para a battleground!")
		return false	
	end
	
	if(ret == BG_RET_INFIGHT) then
		doPlayerSendCancel(cid, "Você está em condição de batalha, aguarde sair a condição e tente novamente.")
		return false
	end
		
	if(ret == BG_RET_PUT_IN_WAITLIST) then
		
		local leftStr = ""
		
		if(getBattlegroundWaitlistSize() < BG_CONFIG_TEAMSIZE * 2) then
		
			local playersLeft = (BG_CONFIG_TEAMSIZE * 2) - getBattlegroundWaitlistSize()
			
			leftStr = " Restam "
			
			if(playersLeft <= 2) then
				leftStr = leftStr .. "apénas "
			end
			
			leftStr = leftStr .. "mais " .. (BG_CONFIG_TEAMSIZE * 2) - getBattlegroundWaitlistSize() .. " jogadores para iniciar a proxima partida! Quer participar também? Digite '!bg entrar'" 
		end
	
		broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") aguarda por uma battleground." .. leftStr)	
		return true
	elseif(ret == BG_RET_PUT_INSIDE) then
		lockTeleportScroll(cid)
		registerCreatureEvent(cid, "OnChangeOutfit")
		
		-- teleportando direto da ilha de treinamento...
		if(isInTrainingIsland(cid)) then
			doUpdateCreatureImpassable(cid)
		end
		
		-- islando of peace
		if(BATTLEGROUND_CAN_NON_PVP and onIslandOfPeace) then
			doUpdateCreatureImpassable(cid)
		end
	
		local teams = { [1] = "Time A", [2] = "Time B" }
		local team = teams[doPlayerGetBattlegroundTeam(cid)]
		
		registerCreatureEvent(cid, "onBattlegroundFrag")
		registerCreatureEvent(cid, "onBattlegroundEnd")
		registerCreatureEvent(cid, "onBattlegroundLeave")
		
		local msg = "Bem vindo ao sistema de Battleground do Darghos!\n"
		
		local isFirstBattleground = getPlayerStorageValue(cid, sid.FIRST_BATTLEGROUND)		
		if(isFirstBattleground == -1) then
			msg = msg .. pvpBattleground.getInformations()
			pvpBattleground.sendPlayerChannelMessage(cid, msg)
			msg = ""
			setPlayerStorageValue(cid, sid.FIRST_BATTLEGROUND, 1)	
		end
		
		msg = msg .. pvpBattleground.getPlayersTeamString(doPlayerGetBattlegroundTeam(cid))
		msg = msg .. "\nDivirta-se!"
		
		pvpBattleground.sendPlayerChannelMessage(cid, msg)
		--broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") juntou-se a batalha pelo " .. team .. ".")	
		return true
	end
	
	return false
end

function pvpBattleground.onExit(cid)

	local ret = doPlayerLeaveBattleground(cid)

	if(ret == BG_RET_NO_ERROR) then
		broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") abandonou a batalha.")		
		return true
	end
	
	return false	
end