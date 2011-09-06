DAILY_REQUIRED_POINTS = 20

function onBattlegroundFrag(cid, target)
	doSendAnimatedText(getPlayerPosition(cid), "FRAG!", TEXTCOLOR_DARKRED)
	
	local teams = { [1] = "Time A", [2] = "Time B" }
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") matou " .. getPlayerName(target) .. " (" .. getPlayerLevel(target) .. ") pelo " .. teams[doPlayerGetBattlegroundTeam(cid)] .. "!")

	local dailyActive = (getPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_ACTIVE) == 1) and true or false	
	if(dailyActive) then
		local level, target_level = getPlayerLevel(cid), getPlayerLevel(target)
		local target_min_level = math.floor(level * (0.15))
		
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
end