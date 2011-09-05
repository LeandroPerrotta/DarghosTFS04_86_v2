BROADCAST_STATISTICS_INTERVAL = 20

pvpBattleground = {

}

function pvpBattleground.onInit()
	addEvent(pvpBattleground.broadcastStatistics, 1000 * 60 * BROADCAST_STATISTICS_INTERVAL)
end

function pvpBattleground.broadcastStatistics()

	local msg = "Estatisticas Battleground (ultimos " .. BROADCAST_STATISTICS_INTERVAL .. " minutos):\n\n";
	
	local data = getBattlegroundStatistics()
	
	if(not data) then
		addEvent(pvpBattleground.broadcastStatistics, 1000 * 60 * BROADCAST_STATISTICS_INTERVAL)
		return
	end
	
	local i = 1
	for k,v in pairs(data) do
		
		local cid = getPlayerByGUID(v.player_id)
		if(cid ~= nil) then
		
			local teams = { [1] = "Time A", [2] = "Time B" }
			local team = teams[doPlayerGetBattlegroundTeam(cid)]
			
			if(team ~= nil) then
				team = "Fora"
			end
			
			local spaces_c = 40 - string.len(getPlayerName(cid))
			
			local spaces = ""	
			for i=1, spaces_c do spaces = spaces .. " " end
					
			msg = msg .. i .. "# " .. getPlayerName(cid) .. " (" .. team .. ")".. spaces .. "" .. v.kills .. " / " .. v.deaths .. "  [" .. v.assists .. "] \n"	
			i = i + 1
		end
	end
	
	broadcastChannel(CUSTOM_CHANNEL_PVP, msg, TALKTYPE_TYPES["channel-orange"])
	addEvent(pvpBattleground.broadcastStatistics, 1000 * 60 * BROADCAST_STATISTICS_INTERVAL)
end

function pvpBattleground.onEnter(cid)

	if(doPlayerJoinBattleground(cid)) then
		lockTeleportScroll(cid)
	
		local teams = { [1] = "Time A", [2] = "Time B" }
		local team = teams[doPlayerGetBattlegroundTeam(cid)]
		
		registerCreatureEvent(cid, "onBattlegroundFrag")
		
		broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") juntou-se a batalha pelo " .. team .. ".")
		
		return true
	end
	
	return false
end

function pvpBattleground.onExit(cid)

	if(doPlayerLeaveBattleground(cid)) then
		broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") saiu da batalha.")
		unlockTeleportScroll(cid)
		unregisterCreatureEvent(cid, "onBattlegroundFrag")
		
		return true
	end
	
	doPlayerSendCancel(cid, "Após entrar em uma Battleground é necessario aguardar 1 minuto para sair.")
	return false	
end