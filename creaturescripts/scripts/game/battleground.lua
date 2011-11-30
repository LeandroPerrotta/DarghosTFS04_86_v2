--DAILY_REQUIRED_POINTS = 20

function onBattlegroundLeave(cid)
	unlockTeleportScroll(cid)
	unregisterCreatureEvent(cid, "onBattlegroundFrag")
	unregisterCreatureEvent(cid, "onBattlegroundEnd")
	unregisterCreatureEvent(cid, "onBattlegroundLeave")
	unregisterCreatureEvent(cid, "onBattlegroundThink")
	unregisterCreatureEvent(cid, "OnChangeOutfit")
	
	if(isInTrainingIsland(cid)) then
		doUpdateCreaturePassable(cid)
	end	
	
	-- islando of peace
	local onIslandOfPeace = getPlayerTown(cid) == towns.ISLAND_OF_PEACE
	if(onIslandOfPeace) then
		doUpdateCreaturePassable(cid)
	end	
	
	doRemoveCondition(cid, CONDITION_INFIGHT)
end

function onBattlegroundEnd(cid, winner, timeIn, bgDuration)

	local points = getBattlegroundTeamsPoints()

	local winnerTeam = BATTLEGROUND_TEAM_NONE
	local loserTeam = nil

	if(points[BATTLEGROUND_TEAM_ONE] ~= points[BATTLEGROUND_TEAM_TWO]) then
		winnerTeam = (points[BATTLEGROUND_TEAM_ONE] > points[BATTLEGROUND_TEAM_TWO]) and BATTLEGROUND_TEAM_ONE or BATTLEGROUND_TEAM_TWO
		loserTeam = (winnerTeam == BATTLEGROUND_TEAM_ONE) and BATTLEGROUND_TEAM_TWO or BATTLEGROUND_TEAM_ONE
	end
	
	if(pvpBattleground.hasGain()) then
		if(not winner and winnerTeam ~= BATTLEGROUND_TEAM_NONE) then
			local removedRating = pvpBattleground.removePlayerRating(cid, timeIn, bgDuration)
			local ratingMessage = "Você piorou a sua classificação (rating) em " .. removedRating .. " pontos por sua derrota na Battleground."
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, ratingMessage)		
			
			local gold = 20000
			
			if(not isPremium(cid)) then
				gold = gold * (FREE_GAINS_PERCENT / 100)
			end
			
			local msg = "Não foi dessa vez... Por derrotas não são concedido premios de experience, mas você recebeu " .. gold .. " moedas de ouro para ajudar a repor os suprimentos gastos e se preparar para a proxima Battleground!"
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)	
			doPlayerAddMoney(cid, gold)			
			
			playerHistory.logBattlegroundLost(cid, newRating)
		end
	
		if(winner or winnerTeam == BATTLEGROUND_TEAM_NONE) then
		
			if(winner and points[winnerTeam] == BG_CONFIG_WINPOINTS	and points[loserTeam] == 0 and not playerHistory.hasAchievBattlegroundPerfect(cid)) then
				playerHistory.achievBattlegroundPerfect(cid)
			end		
					
			local expGain = pvpBattleground.getExperienceGain(cid)
			local staminaMinutes = getPlayerStamina(cid)		
			local staminaChange = timeIn / 60
			
			expGain = math.floor(expGain * (timeIn / bgDuration)) -- calculamo a exp obtida com base no tempo de participação do jogador
			expGain = math.floor(expGain * (bgDuration / BG_CONFIG_DURATION)) -- calculamo a exp obtida com base na duração da battleground
			
			-- iremos reduzir o ganho de exp conforme o player se afasta da média de kills definida para o grupo até um limite de 50% de redução
			local playerInfo = getPlayerBattlegroundInfo(cid)
			local killsAvg = math.ceil(points[getPlayerBattlegroundTeam(cid)] / BG_CONFIG_TEAMSIZE)
			local killsRate = math.random(math.min(killsAvg, playerInfo.kills) * 100, killsAvg * 100) / (killsAvg * 100)
			
			expGain = math.ceil(expGain * (math.max(0.5, killsRate)))
		
			local gold = 60000
			
			if(not isPremium(cid)) then
				gold = gold * (FREE_GAINS_PERCENT / 100)
			end			
			
			local msg = "Você adquiriu " .. expGain .. " pontos de experiência além de " .. gold .. " moedas de ouro para ajudar a você repor os suprimentos gastos pela vitoria na Battleground!"
			
			local currentRating = getPlayerBattlegroundRating(cid)
			local changeRating = pvpBattleground.getChangeRating(cid, timeIn, bgDuration)
			local ratingMessage = "Você melhorou a sua classificação (rating) em " .. changeRating .. " pontos pela vitoria na Battleground."
		
			if(winnerTeam == BATTLEGROUND_TEAM_NONE) then
			
				staminaChange = math.floor(newStamina / 2)
				expGain = math.floor(expGain / 2)
				gold = 30000
				msg = "Você adquiriu " .. expGain .. " pontos de experiencia e " .. gold .. " moedas de ouro pelo empate na Battleground!"
				
				changeRating = math.floor(changeRating / 2)
				ratingMessage = "Você melhorou a sua classificação (rating) em " .. changeRating .. " pontos por seu empate na Battleground."
				playerHistory.logBattlegroundDraw(cid, currentRating + changeRating)
			else
				playerHistory.logBattlegroundWin(cid, currentRating + changeRating)
			end		
			
			if(not playerHistory.hasAchievBattlegroundGet1500Rating(cid)
				and currentRating < 1500
				and currentRating + changeRating >= 1500) then
				playerHistory.achievBattlegroundGet1500Rating(cid)
			end
			
			if(not playerHistory.hasAchievBattlegroundGet2000Rating(cid)
				and currentRating < 2000
				and currentRating + changeRating >= 2000) then
				playerHistory.achievBattlegroundGet2000Rating(cid)
			end				
			
			doPlayerSetStamina(cid, staminaMinutes - staminaChange)
			doPlayerSetBattlegroundRating(cid, currentRating + changeRating)
			doPlayerAddMoney(cid, gold)
			doPlayerAddExp(cid, expGain)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
			if(not isPremium(cid)) then
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Adquira já sua conta premium, ajude o Darghos a continuar inovando como com as Battlegrounds e ainda receba até três vezes mais recompensas! www.darghos.com.br/index.php?ref=account.premium")
			end			
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, ratingMessage)	
		end
	else
		if(BG_ENABLED_GAINS) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Recompensa de experiencia, dinheiro e rating não concedida. Recompensas só são concedidas entre as AM 11:00 (onze da manha) e as AM 01:00 (uma da manha), expeto aos sabados e domingos.")
		else
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "A battleground esta passando por revisões e somente está funcionando no modo sem ganhos, por isso nenhum tipo de ganho ou perda foi concedido por esta partida.")
		end
	end
	
	pvpBattleground.showResult(cid, winnerTeam)
end

function onBattlegroundFrag(cid, target)
	doSendAnimatedText(getPlayerPosition(cid), "FRAG!", TEXTCOLOR_DARKRED)
	
	local teams = { "Time A", "Time B" }	
	local points = getBattlegroundTeamsPoints()
	
	pvpBattleground.sendPvpChannelMessage("[Battleground | (" .. teams[BATTLEGROUND_TEAM_ONE] .. ") " .. points[BATTLEGROUND_TEAM_ONE] .. " X " .. points[BATTLEGROUND_TEAM_TWO] .. " (" .. teams[BATTLEGROUND_TEAM_TWO] .. ")] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") matou " .. getPlayerName(target) .. " (" .. getPlayerLevel(target) .. ") pelo " .. teams[getPlayerBattlegroundTeam(cid)] .. "!", PVPCHANNEL_MSGMODE_INBATTLE)

	if(pvpBattleground.hasGain()) then
		
		local playerInfo = getPlayerBattlegroundInfo(cid)
		if(not playerHistory.hasAchievBattlegroundInsaneKiller(cid)
			and playerInfo.kills >= 25 and playerInfo.deaths == 0) then
			playerHistory.achievBattlegroundInsaneKiller(cid)
		end
	end
	--[[
	local dailyActive = (getPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_ACTIVE) == 1) and true or false	
	if(dailyActive) then
		local level, target_level = getPlayerLevel(cid), getPlayerLevel(target)
		local target_min_level = level - math.floor(level * (0.15))
		
		if(target_level >= target_min_level) then
			local points = math.max(getPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_POINTS), 0)
			points = points + 1
			points = math.min(points, DAILY_REQUIRED_POINTS)
			
			if(points < DAILY_REQUIRED_POINTS) then
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Você precisa derrotar mais " .. (DAILY_REQUIRED_POINTS - points) .. " adversários para completar a sua missão.")
			elseif(points == DAILY_REQUIRED_POINTS) then
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Você concluiu a sua missão! Volte a falar com Dhor'Thar para receber a sua recompensa!")
			end
			
			setPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_POINTS, points)
		end
	end
	
	dailyActive = (getPlayerStorageValue(target, sid.DAILY_BATTLEGROUND_ACTIVE) == 1) and true or false	
	if(dailyActive) then
		local points = math.max(getPlayerStorageValue(target, sid.DAILY_BATTLEGROUND_POINTS), 0)
		if(points > 0) then
			points = points - 1
			doPlayerSendTextMessage(target, MESSAGE_STATUS_CONSOLE_ORANGE, "Você foi derrotado por outro jogador na battleground e perdeu 1 ponto, você precisa derrotar mais " .. (DAILY_REQUIRED_POINTS - points) .. " adversários para completar a sua missão.")
			setPlayerStorageValue(target, sid.DAILY_BATTLEGROUND_POINTS, points)
		end
	end
	--]]
end

function onThink(cid, interval)

	if(not doPlayerIsInBattleground(cid)) then
		return
	end
	
	local points = getBattlegroundTeamsPoints()
	local opponent = (getPlayerBattlegroundTeam(cid) == BATTLEGROUND_TEAM_ONE) and BATTLEGROUND_TEAM_TWO or BATTLEGROUND_TEAM_ONE
	if(points[getPlayerBattlegroundTeam(cid)] <= points[opponent]) then
		return
	end
	
	local lastCheck = getPlayerStorageValue(cid, sid.BATTLEGROUND_LAST_PZCHECK)
	
	local tile = getTileInfo(getCreaturePosition(cid))
	if(not tile.protection) then		
		return
	end	
	
	local pzTicks = incPlayerStorageValue(cid, sid.BATTLEGROUND_PZTICKS, interval)
	local inPzForLongTime = getPlayerStorageValue(cid, sid.BATTLEGROUND_LONG_TIME_PZ) == 1
	
	if(inPzForLongTime) then
		if(pzTicks > 1000 * BG_WINNER_INPZ_PUNISH_INTERVAL) then
			points[opponent] = points[opponent] + 1
			setBattlegroundTeamsPoints(opponent, points[opponent])
			setPlayerStorageValue(cid, sid.BATTLEGROUND_PZTICKS, 0)
			local teams = { "Time A", "Time B" }	
			pvpBattleground.sendPvpChannelMessage("[Battleground | (" .. teams[BATTLEGROUND_TEAM_ONE] .. ") " .. points[BATTLEGROUND_TEAM_ONE] .. " X " .. points[BATTLEGROUND_TEAM_TWO] .. " (" .. teams[BATTLEGROUND_TEAM_TWO] .. ")] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") do " .. teams[getPlayerBattlegroundTeam(cid)] .. " ficou muito tempo dentro de area protegida enquanto seu time ganhava sem entrar em combate concedendo um ponto aos oponentes!", PVPCHANNEL_MSGMODE_INBATTLE)
		end
	else
		if(pzTicks > 1000 * BG_WINNER_INPZ_PUNISH_INTERVAL) then
			setPlayerStorageValue(cid, sid.BATTLEGROUND_LONG_TIME_PZ, 1)
			setPlayerStorageValue(cid, sid.BATTLEGROUND_PZTICKS, 0)
			doCreatureSay(cid, "Fugindo da batalha? Entre em combate com os inimigos ou seu time sofrerá penalidades!", TALKTYPE_ORANGE_1)		
		end	
	end
end