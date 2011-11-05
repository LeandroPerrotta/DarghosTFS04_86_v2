FREE_GAINS_PERCENT = 30
BG_EXP_RATE = 2
BG_EACH_BONUS_PERCENT = 50
BG_BONUS_INTERVAL = 60 * 60

BG_CONFIG_TEAMSIZE = 6
BG_CONFIG_WINPOINTS = 50
BG_CONFIG_DURATION = 60 * 15

BG_AFK_TIME_LIMIT = 60 * 2
BG_WINNER_INPZ_PUNISH_INTERVAL = 60

BG_LASTPLAYERS_BROADCAST_INTERVAL = 60 * 3

BG_RET_NO_ERROR = 0
BG_RET_CLOSED = 1
BG_RET_CAN_NOT_JOIN = 2
BG_RET_PUT_IN_WAITLIST = 3
BG_RET_PUT_INSIDE = 4
BG_RET_PUT_DIRECTLY = 5
BG_RET_ALREADY_IN_WAITLIST = 6
BG_RET_INFIGHT = 7

PVPCHANNEL_MSGMODE_BROADCAST = 0
PVPCHANNEL_MSGMODE_INBATTLE = 1
PVPCHANNEL_MSGMODE_OUTBATTLE = 2

BATTLEGROUND_TEAM_NONE = 0
BATTLEGROUND_TEAM_ONE = 1
BATTLEGROUND_TEAM_TWO = 2

BATTLEGROUND_STATUS_BUILDING_TEAMS = 0
BATTLEGROUND_STATUS_PREPARING = 1
BATTLEGROUND_STATUS_STARTED = 2
BATTLEGROUND_STATUS_FINISHED = 3

BATTLEGROUND_MIN_LEVEL = 100
BATTLEGROUND_CAN_NON_PVP = true

BG_GAIN_EVERYHOUR_DAYS = { WEEKDAY.SATURDAY, WEEKDAY.SUNDAY }
BG_GAIN_START_HOUR = 11
BG_GAIN_END_HOUR = 1

pvpBattleground = {
	lastJoinBroadcastMassage = 0
}

BATTLEGROUND_RATING = 3
BATTLEGROUND_HIGH_RATE = 1601
BATTLEGROUND_LOW_RATE = 501

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

function pvpBattleground.removePlayerRating(cid, timeIn, bgDuration, deserting)

	deserting = deserting or false

	local currentRating = pvpBattleground.getPlayerRating(cid)
	local changeRating = pvpBattleground.getChangeRating(cid, timeIn, bgDuration)
	
	if(not deserting) then
		if(currentRating >= BATTLEGROUND_HIGH_RATE) then
			changeRating = math.floor(changeRating)
		elseif(currentRating < BATTLEGROUND_LOW_RATE) then
			changeRating = math.floor(changeRating * 0.25)
		else
			changeRating = math.floor(changeRating * 0.75)
		end
	else
		changeRating = math.floor(changeRating)
	end
	
	local newRating = math.max(currentRating - changeRating, 0)		
	
	pvpBattleground.setPlayerRating(cid, newRating)
	
	return math.min(changeRating, currentRating)
end

function pvpBattleground.getChangeRating(cid, timeIn, bgDuration)

	local currentRating = pvpBattleground.getPlayerRating(cid)
	local ratingMultipler = pvpBattleground.getRatingMultipler(cid, currentRating)
	local changeRating = ratingMultipler * BATTLEGROUND_RATING
	
	return math.floor(changeRating * (timeIn / bgDuration))	
end

function pvpBattleground.getExpGainRate(cid)

	local rate = BG_EXP_RATE
	local bonus = pvpBattleground.getBonus()
	if(bonus > 0) then
		rate = rate + (bonus * (BG_EACH_BONUS_PERCENT / 100))
		pvpBattleground.setBonus(0)
	end
	
	if(not isPremium(cid)) then
		rate = rate * (FREE_GAINS_PERCENT / 100)
	else
		local staminaMinutes = getPlayerStamina(cid)
		local bonusStamina = 40 * 60
		
		if(staminaMinutes > bonusStamina) then
			rate = rate + 0.5
		end
	end

	return rate
end

function pvpBattleground.getBonus()
	return math.max(0, getGlobalStorageValue(gid.BATTLEGROUND_BONUS))
end

function pvpBattleground.setBonus(bonus)
	return setGlobalStorageValue(gid.BATTLEGROUND_BONUS, bonus)
end

function pvpBattleground.onInit()
	local configs = {
		teamSize = BG_CONFIG_TEAMSIZE,
		winPoints = BG_CONFIG_WINPOINTS,
		duration = BG_CONFIG_DURATION,
	}
	
	setBattlegroundConfigs(configs)
	pvpBattleground.setBonus(0)
end

function pvpBattleground.close()
	battlegroundClose()
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] Battleground temporareamente fechada. Voltará em alguns instantes.", TALKTYPE_TYPES["channel-red"])
end

function pvpBattleground.hasGain()
	local date = os.date("*t")
	return ((date.hour >= BG_GAIN_START_HOUR and date.hour <= 23)
		or (date.hour >= 0 and date.hour < BG_GAIN_END_HOUR)
		or isInArray(BG_GAIN_EVERYHOUR_DAYS, date.wday))
end

function pvpBattleground.drawRank()

	local msg = ""
	local teams = { "Time A", "Time B" }
	local data = getBattlegroundStatistics()
	
	if(data and #data > 0) then
		local i = 1
		for k,v in pairs(data) do
			
			local _cid = v.player_id
			if(_cid ~= nil and isPlayer(_cid)) then
				
				local team = teams[doPlayerGetBattlegroundTeam(_cid)]
				
				if(team == nil) then
					team = "Fora"
				end
				
				local spaces_c = 40 - string.len(getPlayerName(_cid)) - string.len(team)
				
				local spaces = ""	
				for i=1, spaces_c do spaces = spaces .. " " end
						
				msg = msg .. i .. "# " .. getPlayerName(_cid) .. " (" .. team .. ")".. spaces .. "" .. v.kills .. " / " .. v.deaths .. "  [" .. v.assists .. "] \n"	
				i = i + 1
			end
		end
	end	
	
	return msg
end

function pvpBattleground.showStatistics(cid)

	local teams = { "Time A", "Time B" }
	
	local points = getBattlegroundTeamsPoints()	
	
	local msg = "Estatisticas da Partida:\n\n"
	
	msg = msg .. "(" .. teams[BATTLEGROUND_TEAM_ONE] .. ") " .. points[BATTLEGROUND_TEAM_ONE] .. " X " .. points[BATTLEGROUND_TEAM_TWO] .. " (" .. teams[BATTLEGROUND_TEAM_TWO] .. ")\n\n"
	
	msg = msg .. pvpBattleground.drawRank()
	doPlayerPopupFYI(cid, msg)
end

function pvpBattleground.showResult(cid, winnner)

	clear = clear or true

	local teams = { "Time A", "Time B" }
	
	local msg = "Não houve vencedor, declarado EMPATE!\n\n"
	
	if(winnner ~= BATTLEGROUND_TEAM_NONE) then
		msg = "O " .. teams[winnner] .. " é o VENCEDOR!\n\n"
	end
	
	msg = msg .. pvpBattleground.drawRank()
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
		
		local player = v
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
	return math.floor(getPlayerExperience(cid) * 0.0005 * getPlayerMultiple(cid, STAGES_EXPERIENCE) * pvpBattleground.getExpGainRate(cid))
end

function pvpBattleground.playerSpeakTeam(cid, message)
	
	local team_id = doPlayerGetBattlegroundTeam(cid)
	
	if(team_id == BATTLEGROUND_TEAM_NONE) then
		return false
	end
	
	local playersTeam = getBattlegroundPlayersByTeam(team_id)
	
	for k,v in pairs(playersTeam) do
		local target = v
		doPlayerSendChannelMessage(target, getPlayerName(cid) .. " [" .. getPlayerLevel(cid) .. " | " .. pvpBattleground.getPlayerRating(cid) .. "]", message, TALKTYPE_TYPES["channel-yellow"], CUSTOM_CHANNEL_BG_CHAT)		
	end
	
	return true
end

function pvpBattleground.sendPvpChannelMessage(message, mode, talktype)

	mode = mode or PVP_CHANNEL_BROADCAST

	if(mode == PVPCHANNEL_MSGMODE_BROADCAST) then
		broadcastChannel(CUSTOM_CHANNEL_PVP, message)
	elseif(mode == PVPCHANNEL_MSGMODE_INBATTLE) then
		local users = getChannelUsers(CUSTOM_CHANNEL_PVP)
		talktype = talktype or TALKTYPE_TYPES["channel-white"]
		
		for k,v in pairs(users) do		
			if(doPlayerGetBattlegroundTeam(v) ~= BATTLEGROUND_TEAM_NONE) then
				doPlayerSendChannelMessage(v, "", message, talktype, CUSTOM_CHANNEL_PVP)
			end				
		end		
	elseif(mode == PVPCHANNEL_MSGMODE_OUTBATTLE) then
		local users = getChannelUsers(CUSTOM_CHANNEL_PVP)
		talktype = talktype or TALKTYPE_TYPES["channel-white"]
		
		for k,v in pairs(users) do		
			if(doPlayerGetBattlegroundTeam(v) == BATTLEGROUND_TEAM_NONE) then
				doPlayerSendChannelMessage(v, "", message, talktype, CUSTOM_CHANNEL_PVP)
			end				
		end	
	end
end

function pvpBattleground.broadcastLeftOnePlayer()

	if(pvpBattleground.lastJoinBroadcastMassage > 0 and pvpBattleground.lastJoinBroadcastMassage + BG_LASTPLAYERS_BROADCAST_INTERVAL > os.time()) then
		return
	end

	local messages = {
		"Quer ganhar experiencia e dinheiro se divertindo com PvP? Participe da proxima battleground! Restam apénas mais um para fechar os times 6x6! -> !bg entrar",
		"Restam apénas mais um jogador para fechar os times 6x6 para a proxima Battleground! Ganhe recompensas! Ao morrer nada é perdido! Divirta-se! -> !bg entrar",
		"Gosta de PvP? Prove seu valor! Restam apénas mais um jogadore para fechar os times 6x6 para a proxima Battleground! -> !bg entrar",
		"Não conheçe o sistema de Battlegrounds? Conheça agora! Falta apénas você para o proxima batalha 6x6! Não há perdas nas mortes, ajude o time na vitoria e ganhe recompensas! -> !bg entrar",
	}
	
	local rand = math.random(1, #messages)
	doBroadcastMessage(messages[rand], MESSAGE_INFO_DESCR)
	pvpBattleground.lastJoinBroadcastMassage = os.time()
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
	
	local closeTeam = getBattlegroundWaitlistSize() == (BG_CONFIG_TEAMSIZE * 2) - 1
	local ret = doPlayerJoinBattleground(cid)

	if(ret == BG_RET_CLOSED) then
		doPlayerSendCancel(cid, "A battleground está temporareamente fechada.")	
		return false
	end

	if(ret == BG_RET_CAN_NOT_JOIN) then
		doPlayerSendCancel(cid, "Você abandonou uma battleground e foi marcado como desertor, e não poderá entrar em outra durante 20 minutos.")
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
		
		if(getBattlegroundWaitlistSize() == 1) then
			leftStr = "Um jogador "
		else
			leftStr = "Mais um jogador "
		end
		
		leftStr = leftStr .. "deseja participar de uma Battleground. "
		
		if(getBattlegroundWaitlistSize() < BG_CONFIG_TEAMSIZE * 2) then
		
			local playersLeft = (BG_CONFIG_TEAMSIZE * 2) - getBattlegroundWaitlistSize()
			
			leftStr = leftStr .. "Restam "
			
			if(playersLeft <= 2) then
				leftStr = leftStr .. "apénas "
			end
			
			if(playersLeft == 1) then
				pvpBattleground.broadcastLeftOnePlayer()
			end
			
			leftStr = leftStr .. "mais " .. (BG_CONFIG_TEAMSIZE * 2) - getBattlegroundWaitlistSize() .. " jogadores para iniciar a proxima partida! Quer participar também? Digite '!bg entrar'" 
		else
			closeTeam = false
			leftStr = leftStr .. " Quer participar também? Digite '!bg entrar'"
		end
	
		if(not closeTeam) then
			pvpBattleground.sendPvpChannelMessage("[Battleground] " .. leftStr, PVPCHANNEL_MSGMODE_OUTBATTLE)
		else
			pvpBattleground.sendPvpChannelMessage("[Battleground] Os times para a proxima battleground estão completos! A nova partida começará em instantes, assim que a Battleground estiver vazia...", PVPCHANNEL_MSGMODE_OUTBATTLE)
		end
		
		return true
	elseif(ret == BG_RET_PUT_INSIDE or ret == BG_RET_PUT_DIRECTLY) then
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
		registerCreatureEvent(cid, "onBattlegroundThink")
		registerCreatureEvent(cid, "onBattlegroundLeave")		
		
		doPlayerSetIdleTime(cid, 0)
		
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
		
		if(ret == BG_RET_PUT_DIRECTLY) then
			pvpBattleground.sendPvpChannelMessage("[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") apresentou-se para recompor o " .. team .. ".", PVPCHANNEL_MSGMODE_INBATTLE)
		end
		
		doPlayerOpenChannel(cid, CUSTOM_CHANNEL_BG_CHAT)
		return true
	end
	
	return false
end

function pvpBattleground.onExit(cid, idle)

	idle = idle or false

	if(getBattlegroundStatus() ~= BATTLEGROUND_STATUS_STARTED) then
		doPlayerSendCancel(cid, "Aguarde o inicio da Battleground para abandonar-la.")
		return false
	end

	local ret = doPlayerLeaveBattleground(cid)

	if(ret == BG_RET_NO_ERROR) then
		if(not idle) then
			pvpBattleground.sendPvpChannelMessage("[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") desertou a batalha!", PVPCHANNEL_MSGMODE_INBATTLE)		
		else
			pvpBattleground.sendPvpChannelMessage("[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") foi expulso por inatividade!", PVPCHANNEL_MSGMODE_INBATTLE)	
		end
		
		pvpBattleground.sendPvpChannelMessage("[Battleground] Um jogador desertou a batalha! Quer substituir-lo imediatamente? Digite '!bg entrar'!", PVPCHANNEL_MSGMODE_OUTBATTLE)
		
		local removedRating = pvpBattleground.removePlayerRating(cid, BG_CONFIG_DURATION, BG_CONFIG_DURATION, true)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você piorou a sua classificação (rating) em " .. removedRating .. " pontos por seu abandono da Battleground.")
		
		return true
	end
	
	return false	
end

function pvpBattleground.onReportIdle(cid, idle_player)

	if(not doPlayerIsInBattleground(idle_player) or 
		(doPlayerGetBattlegroundTeam(cid) ~= doPlayerGetBattlegroundTeam(idle_player))
		) then
		pvpBattleground.sendPlayerChannelMessage(cid, "Este jogador não pertence a seu time ou não está na Battleground.")
		return
	end
	
	if(getBattlegroundStatus() ~= BATTLEGROUND_STATUS_STARTED) then
		pvpBattleground.sendPlayerChannelMessage(cid, "Somente é permitido fazer denúncias após a Battleground ter iniciado.")
		return
	end	
	
	local report_block = getPlayerStorageValue(cid, sid.BATTLEGROUND_INVALID_REPORT_BLOCK)
	if(report_block ~= 0 and os.time() <= report_block) then
		pvpBattleground.sendPlayerChannelMessage(cid, "Você está impossibilitado de efetuar denuncias de jogadores inativos momentaneamente por uma denuncia invalida recente.")
		return
	end
	
	setPlayerStorageValue(idle_player, sid.BATTLEGROUND_LAST_REPORT, os.time())
	
	pvpBattleground.sendPlayerChannelMessage(cid, "Você denunciou o jogador " .. getPlayerName(idle_player) .. " como inativo com! Ele será expulso da Battleground se continuar inativo no proximo minuto.")
	doPlayerPopupFYI(idle_player, "ATENÇÃO: \n\nVocê foi acusado de estar inativo dentro da Battleground, o que é proibido!\nVocê tem " .. BG_AFK_TIME_LIMIT .. " segundos para entrar em combate com um oponente ou será expulso da batalha e marcado como desertor!")
	addEvent(pvpBattleground.validateReport, 1000 * BG_AFK_TIME_LIMIT, cid, idle_player)
end

function pvpBattleground.validateReport(cid, idle_player)

	if(getBattlegroundStatus() ~= BATTLEGROUND_STATUS_STARTED) then
		return
	end

	if(not isPlayer(idle_player) or not isPlayer(cid)) then
		return
	end
	
	if(not doPlayerIsInBattleground(idle_player)) then
		return
	end

	local lastDmg = getPlayerStorageValue(idle_player, sid.BATTLEGROUND_LAST_DAMAGE) 
	local reportIn = getPlayerStorageValue(idle_player, sid.BATTLEGROUND_LAST_REPORT)
	if(lastDmg == 0 or lastDmg <= reportIn) then		
		pvpBattleground.onExit(idle_player, true)
	else
		setPlayerStorageValue(cid, sid.BATTLEGROUND_INVALID_REPORT_BLOCK, os.time() + (60 * 3))
		pvpBattleground.sendPlayerChannelMessage(cid, "Não foi constatado que o jogador que você reportou estava inativo. Pela denuncia invalida você nao poderá denunciar outros jogadores por 3 minutos.")
	end
end

function pvpBattleground.spamDebuffSpell(cid, min, max, playerDebbufs)

	if(doPlayerIsInBattleground(cid)) then
		if(playerDebbufs[cid] == nil) then
			table.insert(playerDebbufs, cid, { percent = 70, expires = os.time() + 3})
		else	
			if(os.time() <= playerDebbufs[cid]["expires"]) then
				min = min * (playerDebbufs[cid]["percent"] / 100)
				max = max * (playerDebbufs[cid]["percent"] / 100)
				
				if(playerDebbufs[cid]["percent"] == 70) then
					playerDebbufs[cid]["percent"] = 50
				end
				
				playerDebbufs[cid]["expires"] = os.time() + 3
			else
				playerDebbufs[cid]["percent"] = 70
				playerDebbufs[cid]["expires"] = os.time() + 3	
			end
		end
	end
	
	return min, max, playerDebbufs
end
