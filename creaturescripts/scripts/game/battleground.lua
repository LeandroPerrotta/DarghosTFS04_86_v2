--DAILY_REQUIRED_POINTS = 20

function onBattlegroundLeave(cid)
	unlockTeleportScroll(cid)
	unregisterCreatureEvent(cid, "onBattlegroundFrag")
	unregisterCreatureEvent(cid, "onBattlegroundEnd")
	unregisterCreatureEvent(cid, "onBattlegroundLeave")
	unregisterCreatureEvent(cid, "OnChangeOutfit")
	
	if(isInTrainingIsland(cid)) then
		doUpdateCreaturePassable(cid)
	end	
	
	-- islando of peace
	local onIslandOfPeace = getPlayerTown(cid) == towns.ISLAND_OF_PEACE
	if(onIslandOfPeace) then
		doUpdateCreaturePassable(cid)
	end	
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
	
		local currentRating = pvpBattleground.getPlayerRating(cid)
		local ratingMultipler = pvpBattleground.getRatingMultipler(cid, currentRating)
		local changeRating = ratingMultipler * BATTLEGROUND_RATING
		
		changeRating = math.floor(changeRating * (timeIn / bgDuration))
	
		if(not winner and winnerTeam ~= BATTLEGROUND_TEAM_NONE) then
			if(currentRating >= BATTLEGROND_HIGH_RATE) then
				changeRating = math.floor(changeRating * 1.25)
			else
				changeRating = math.floor(changeRating * 0.75)
			end
			
			local newRating = math.max(currentRating - changeRating, 0)	
			local ratingMessage = "Você piorou a sua classificação (rating) em " .. math.max(changeRating, currentRating) .. " pontos por sua derrota na Battleground."
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, ratingMessage)		
			pvpBattleground.setPlayerRating(cid, newRating)
			
			if(isPremium(cid)) then
				local gold = 20000
				local msg = "Não foi dessa vez... Por derrotas não são concedido premios de experience, mas você recebeu " .. gold .. " moedas de ouro para ajudar a repor os suprimentos gastos e se preparar para a proxima Battleground!"
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)	
				doPlayerAddMoney(cid, gold)
			end
			
			playerHistory.logBattlegroundLost(cid, newRating)
		end
	
		if(winner or winnerTeam == BATTLEGROUND_TEAM_NONE) then
		
			if(winner and points[winnerTeam] == BG_CONFIG_WINPOINTS	and points[loserTeam] == 0 and not playerHistory.hasAchievBattlegroundPerfect(cid)) then
				playerHistory.achievBattlegroundPerfect(cid)
			end		
		
			local canGain = true
			local leftGainsMsg = ""
			
			if(not isPremium(cid)) then
				local gains = getPlayerStorageValue(cid, sid.BATTLEGROUND_FREE_EXP_GAINS)
				gains = (gains ~= -1) and gains or 0
				gains = gains + 1
				
				local leftGains = FREE_EXP_GAINS_DAY_LIMIT		
				leftGains = leftGains - gains		
				
				if(leftGains == 0) then
					leftGainsMsg = " Está é ultima vez que você recebera esta recompensa hoje. Adquirá já sua conta premium e continue recebendo a recompensa ilimitadamente, além disso contribua para o Darghos seguir implementando sistemas inovadores como a Battleground!"
					setPlayerStorageValue(cid, sid.BATTLEGROUND_FREE_EXP_GAINS, gains)
				elseif(leftGains == -1) then
					doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você ja atingiu o limite diario de 4 battleground recompensadas para jogadores sem uma Conta Premium. Adquirá já sua conta premium e continue recebendo a recompensa ilimitadamente, além disso contribua para o Darghos seguir implementando sistemas inovadores como a Battleground!")
					canGain = false
				else
					leftGainsMsg = " Você receberá esta recompensa por mais ".. leftGains .. " vezes hoje."
					
					if(leftGains == 1) then
						leftGainsMsg = " Você receberá esta recompensa por mais uma vez hoje."
					end		
					
					setPlayerStorageValue(cid, sid.BATTLEGROUND_FREE_EXP_GAINS, gains)	
				end
			end
			
			if(canGain) then
				local expGain = pvpBattleground.getExperienceGain(cid)
				
				expGain = math.floor(expGain * (timeIn / bgDuration)) -- calculamo a exp obtida com base no tempo de participação do jogador
				expGain = math.floor(expGain * (bgDuration / BG_CONFIG_DURATION)) -- calculamo a exp obtida com base na duração da battleground
				
				-- iremos reduzir o ganho de exp conforme o player se afasta da média de kills definida para o grupo até um limite de 50% de redução
				local playerInfo = getPlayerBattlegroundInfo(cid)
				local killsAvg = math.ceil(points[doPlayerGetBattlegroundTeam(cid)] / BG_CONFIG_TEAMSIZE)
				local killsRate = math.random(math.min(killsAvg, playerInfo.kills) * 100, killsAvg * 100) / (killsAvg * 100)
				
				expGain = math.ceil(expGain * (math.max(0.5, killsRate)))
			
				local gold = 60000
				local msg = "Você adquiriu " .. expGain .. " pontos de experiência além de " .. gold .. " moedas de ouro para ajudar a você repor os suprimentos gastos pela vitoria na Battleground!"
				
				local ratingMessage = "Você melhorou a sua classificação (rating) em " .. changeRating .. " pontos pela vitoria na Battleground."
			
				if(winnerTeam == BATTLEGROUND_TEAM_NONE) then
					expGain = math.floor(expGain / 2)
					gold = 30000
					msg = "Você adquiriu " .. expGain .. " pontos de experiencia e " .. gold .. " moedas de ouro pelo empate na Battleground!"
					
					changeRating = math.floor(changeRating / 2)
					ratingMessage = "Você melhorou a sua classificação (rating) em " .. changeRating .. " pontos por seu empate na Battleground."
					playerHistory.logBattlegroundDraw(cid, currentRating + changeRating)
				else
					playerHistory.logBattlegroundWin(cid, currentRating + changeRating)
				end		
				
				if(not isPremium(cid)) then
					msg = msg .. leftGainsMsg
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
				
				pvpBattleground.setPlayerRating(cid, currentRating + changeRating)
				doPlayerAddMoney(cid, gold)
				doPlayerAddExp(cid, expGain)
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, ratingMessage)
			end		
		end
	else
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Recompensa de experiencia, dinheiro e rating não concedida. Recompensas só são concedidas entre as AM 11:00 (onze da manha) e as AM 01:00 (uma da manha), expeto aos sabados e domingos.")
	end
	
	pvpBattleground.showResult(cid, winnerTeam)
end

function onBattlegroundFrag(cid, target)
	doSendAnimatedText(getPlayerPosition(cid), "FRAG!", TEXTCOLOR_DARKRED)
	
	local teams = { "Time A", "Time B" }	
	local points = getBattlegroundTeamsPoints()
	
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground | (" .. teams[BATTLEGROUND_TEAM_ONE] .. ") " .. points[BATTLEGROUND_TEAM_ONE] .. " X " .. points[BATTLEGROUND_TEAM_TWO] .. " (" .. teams[BATTLEGROUND_TEAM_TWO] .. ")] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") matou " .. getPlayerName(target) .. " (" .. getPlayerLevel(target) .. ") pelo " .. teams[doPlayerGetBattlegroundTeam(cid)] .. "!")

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