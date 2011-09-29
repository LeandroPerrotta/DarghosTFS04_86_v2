--DAILY_REQUIRED_POINTS = 20

function onBattlegroundLeave(cid)
	unlockTeleportScroll(cid)
	unregisterCreatureEvent(cid, "onBattlegroundFrag")
	unregisterCreatureEvent(cid, "onBattlegroundEnd")
	unregisterCreatureEvent(cid, "onBattlegroundLeave")
	unregisterCreatureEvent(cid, "OnChangeOutfit")
end

function onBattlegroundEnd(cid, winner)

	local points = getBattlegroundTeamsPoints()

	local winnerTeam = BATTLEGROUND_TEAM_NONE

	if(points[BATTLEGROUND_TEAM_ONE] ~= points[BATTLEGROUND_TEAM_TWO]) then
		winnerTeam = (points[BATTLEGROUND_TEAM_ONE] > points[BATTLEGROUND_TEAM_TWO]) and BATTLEGROUND_TEAM_ONE or BATTLEGROUND_TEAM_TWO
	end

	if(winner) then
		local canGain = true
		local leftGainsMsg = ""
		
		if(not isPremium(cid)) then
			local gains = getPlayerStorageValue(cid, sid.BATTLEGROUND_FREE_EXP_GAINS)
			gains = (gains ~= -1) and gains or 0
			gains = gains + 1
			
			local leftGains = FREE_EXP_GAINS_DAY_LIMIT		
			leftGains = leftGains - gains		
			
			if(leftGains == 0) then
				canGain = false
			else
				leftGainsMsg = " Você receberá este beneficio por mais ".. leftGains .. " vezes hoje."
				
				if(leftGains == 1) then
					leftGainsMsg = " Você receberá este beneficio por mais uma vez hoje."
				end		
				
				setPlayerStorageValue(cid, sid.BATTLEGROUND_FREE_EXP_GAINS, gains)	
			end
		end
		
		if(canGain) then
			local expGain = pvpBattleground.getExperienceGain(cid)
			local msg = "Você adquiriu " .. expGain .. " pontos de experiencia pela vitoria na Battleground!"
			
			if(not isPremium(cid)) then
				msg = msg .. leftGainsMsg
			end
			
			doPlayerAddExp(cid, expGain)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
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