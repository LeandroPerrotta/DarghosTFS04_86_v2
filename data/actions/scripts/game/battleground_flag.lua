function onUse(cid, item, fromPosition, itemEx, toPosition)
	
	local pos = table.copy(fromPosition)
	pos["stackpos"] = 0
	local ground = getThingFromPos(pos)

	if(ground.uid ~= 0) then
		local team = getPlayerBattlegroundTeam(cid)
		local enemy = (getPlayerBattlegroundTeam(cid) == BATTLEGROUND_TEAM_ONE) and BATTLEGROUND_TEAM_TWO or BATTLEGROUND_TEAM_ONE
		local flagTeam = (ground.uid == uid.BATTLEGROUND_TEAM_ONE_FLAG) and BATTLEGROUND_TEAM_ONE or BATTLEGROUND_TEAM_TWO
		if(flagTeam == enemy) then
		
			local teams = { "Time A", "Time B" }
			local points = getBattlegroundTeamsPoints()
			setBattlegroundTeamsPoints(team, points[team] + BATTLEGROUND_FLAG_BONUS_POINTS)
			points = getBattlegroundTeamsPoints()
		
			local msg = "[Battleground | (" .. teams[BATTLEGROUND_TEAM_ONE] .. ") " .. points[BATTLEGROUND_TEAM_ONE] .. " X " .. points[BATTLEGROUND_TEAM_TWO] .. " (" .. teams[BATTLEGROUND_TEAM_TWO] .. ")] "
			msg = msg .. getPlayerName(cid) .. " (" .. getPlayerLevel(cid) .. ") destruiu a bandeira do time oponente pelo " .. teams[team] .. " conquistando o bonus de " .. BATTLEGROUND_FLAG_BONUS_POINTS .. " pontos!"
			pvpBattleground.onGainHonor(cid, BATTLEGROUND_HONOR_DESTROY_FLAG, true)
		
			doRemoveItem(item.uid)
			pvpBattleground.sendPvpChannelMessage(msg, PVPCHANNEL_MSGMODE_INBATTLE)
		else
			doPlayerSendCancel(cid, "Você não pode destruir a sua propria bandeira! Destrua a bandeira dos oponentes!")
		end
	end
	
	return true
end