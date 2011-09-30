--DAILY_REQUIRED_POINTS = 20

function onBattlegroundLeave(cid)
	unlockTeleportScroll(cid)
	unregisterCreatureEvent(cid, "onBattlegroundFrag")
	unregisterCreatureEvent(cid, "onBattlegroundEnd")
	unregisterCreatureEvent(cid, "onBattlegroundLeave")
	unregisterCreatureEvent(cid, "OnChangeOutfit")
end

function onBattlegroundEnd(cid, winner, timeIn, bgDuration)

	local points = getBattlegroundTeamsPoints()

	local winnerTeam = BATTLEGROUND_TEAM_NONE

	if(points[BATTLEGROUND_TEAM_ONE] ~= points[BATTLEGROUND_TEAM_TWO]) then
		winnerTeam = (points[BATTLEGROUND_TEAM_ONE] > points[BATTLEGROUND_TEAM_TWO]) and BATTLEGROUND_TEAM_ONE or BATTLEGROUND_TEAM_TWO
	end

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
		
		if(currentRating - changeRating > 0) then
			local ratingMessage = "Voc� piorou a sua classifica��o (rating) em " .. changeRating .. " pontos por sua derrota na Battleground."
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, ratingMessage)		
			pvpBattleground.setPlayerRating(cid, currentRating - changeRating)
		end
	end

	if(winner or winnerTeam == BATTLEGROUND_TEAM_NONE) then
		local canGain = true
		local leftGainsMsg = ""
		
		if(not isPremium(cid)) then
			local gains = getPlayerStorageValue(cid, sid.BATTLEGROUND_FREE_EXP_GAINS)
			gains = (gains ~= -1) and gains or 0
			gains = gains + 1
			
			local leftGains = FREE_EXP_GAINS_DAY_LIMIT		
			leftGains = leftGains - gains		
			
			if(leftGains == 0) then
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Voc� ja atingiu o limite diario de 4 battleground recompensadas para jogadores sem uma Conta Premium. Adquir� j� sua conta premium e continue recebendo a recompensa ilimitadamente, al�m disso contribua para o Darghos seguir implementando sistemas inovadores como a Battleground!")
				canGain = false
			else
				leftGainsMsg = " Voc� receber� este beneficio por mais ".. leftGains .. " vezes hoje."
				
				if(leftGains == 1) then
					leftGainsMsg = " Voc� receber� este beneficio por mais uma vez hoje."
				end		
				
				setPlayerStorageValue(cid, sid.BATTLEGROUND_FREE_EXP_GAINS, gains)	
			end
		end
		
		if(canGain) then
			local expGain = pvpBattleground.getExperienceGain(cid)
			
			local maxBattlegroundDuration = 60 * 15
			
			expGain = math.floor(expGain * (timeIn / bgDuration)) -- calculamo a exp obtida com base no tempo de participa��o do jogador
			expGain = math.floor(expGain * (bgDuration / maxBattlegroundDuration)) -- calculamo a exp obtida com base na dura��o da battleground
			
			-- iremos reduzir o ganho de exp conforme o player se afasta da m�dia de kills definida para o grupo at� um limite de 50% de redu��o
			local playerInfo = getPlayerBattlegroundInfo(cid)
			local killsAvg = math.floor(points[winnerTeam] / 6)
			local killsRate = math.min(playerInfo.kills, killsAvg) / killsAvg
			expGain = math.floor(expGain * (math.max(0.5, killsRate)))
		
			local msg = "Voc� adquiriu " .. expGain .. " pontos de experiencia e 2 crystal coins pela vitoria na Battleground!"
			local gold = 20000
			
			local ratingMessage = "Voc� melhorou a sua classifica��o (rating) em " .. changeRating .. " pontos pela vitoria na Battleground."
		
			if(winnerTeam == BATTLEGROUND_TEAM_NONE) then
				expGain = math.floor(expGain / 2)
				gold = 10000
				msg = "Voc� adquiriu " .. expGain .. " pontos de experiencia e 1 crystal coins pelo empate na Battleground!"
				
				changeRating = math.floor(changeRating / 2)
				ratingMessage = "Voc� melhorou a sua classifica��o (rating) em " .. changeRating .. " pontos por seu empate na Battleground."
				pvpBattleground.setPlayerRating(cid, currentRating + changeRating)
			end		
			
			if(not isPremium(cid)) then
				msg = msg .. leftGainsMsg
			end
			
			doPlayerAddMoney(cid, gold)
			doPlayerAddExp(cid, expGain)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, ratingMessage)
		end		
	end
	
	

	pvpBattleground.showResult(cid, winnerTeam)
end

function onBattlegroundFrag(cid, target)
	doSendAnimatedText(getPlayerPosition(cid), "FRAG!", TEXTCOLOR_DARKRED)
	
	local teams = { "Time A", "Time B" }	
	local points = getBattlegroundTeamsPoints()
	
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground | (" .. teams[BATTLEGROUND_TEAM_ONE] .. ") " .. points[BATTLEGROUND_TEAM_ONE] .. " X " .. points[BATTLEGROUND_TEAM_TWO] .. " (" .. teams[BATTLEGROUND_TEAM_TWO] .. ")] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") matou " .. getPlayerName(target) .. " (" .. getPlayerLevel(target) .. ") pelo " .. teams[doPlayerGetBattlegroundTeam(cid)] .. "!")

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
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Voc� precisa derrotar mais " .. (DAILY_REQUIRED_POINTS - points) .. " advers�rios para completar a sua miss�o.")
			elseif(points == DAILY_REQUIRED_POINTS) then
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Voc� concluiu a sua miss�o! Volte a falar com Dhor'Thar para receber a sua recompensa!")
			end
			
			setPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_POINTS, points)
		end
	end
	
	dailyActive = (getPlayerStorageValue(target, sid.DAILY_BATTLEGROUND_ACTIVE) == 1) and true or false	
	if(dailyActive) then
		local points = math.max(getPlayerStorageValue(target, sid.DAILY_BATTLEGROUND_POINTS), 0)
		if(points > 0) then
			points = points - 1
			doPlayerSendTextMessage(target, MESSAGE_STATUS_CONSOLE_ORANGE, "Voc� foi derrotado por outro jogador na battleground e perdeu 1 ponto, voc� precisa derrotar mais " .. (DAILY_REQUIRED_POINTS - points) .. " advers�rios para completar a sua miss�o.")
			setPlayerStorageValue(target, sid.DAILY_BATTLEGROUND_POINTS, points)
		end
	end
	--]]
end