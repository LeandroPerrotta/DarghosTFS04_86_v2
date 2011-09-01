BROADCAST_STATISTICS_INTERVAL = 20

pvpBattleground = {
	team1 = {},
	team2 = {},
	team1_outfit = {body = 114, legs = 114, head = 82, feet = 91},
	team2_outfit = {body = 94, legs = 94, head = 77, feet = 79},
	init = false
}

function pvpBattleground.onInit()
	pvpBattleground.init = true
	addEvent(pvpBattleground.broadcastStatistics, 1000 * 60 * BROADCAST_STATISTICS_INTERVAL)
end

function pvpBattleground.broadcastStatistics()

	local datePattern = os.time() - (60 * BROADCAST_STATISTICS_INTERVAL)

	local msg = "Estatisticas Battleground (ultimos " .. BROADCAST_STATISTICS_INTERVAL .. " minutos):\n\n";
	
	local data, result = {}, db.getResult("SELECT result.player_id, players.name, result.kills, result.assists, result.deaths FROM ((SELECT player_id, COUNT(*) as kills, 0 as assists, 0 as deaths FROM battleground_kills WHERE is_frag = 1 AND `date` > " .. datePattern .. " GROUP BY player_id) UNION (SELECT player_id, 0 as kills, 0 as assists, COUNT(*) as deaths FROM battleground_deaths WHERE  `date` > " .. datePattern .. " GROUP BY player_id) UNION (SELECT player_id, 0 as kills, COUNT(*) as assists, 0 as deaths FROM battleground_kills WHERE `date` > " .. datePattern .. " GROUP BY player_id)) AS result LEFT JOIN players ON players.id = result.player_id ORDER BY result.kills DESC, result.deaths ASC;")
	if(result:getID() ~= -1) then
		repeat
			if(data[result:getDataInt("player_id")] == nil) then
				data[result:getDataInt("player_id")] = {name = result:getDataString("name"), kills = result:getDataInt("kills"), assists = result:getDataInt("assists"), deaths = result:getDataInt("deaths")}
			else
				data[result:getDataInt("player_id")]["kills"] = data[result:getDataInt("player_id")]["kills"] + result:getDataInt("kills")
				data[result:getDataInt("player_id")]["assists"] = data[result:getDataInt("player_id")]["assists"] + result:getDataInt("assists")
				data[result:getDataInt("player_id")]["deaths"] = data[result:getDataInt("player_id")]["deaths"] + result:getDataInt("deaths")
			end
		until not(result:next())
		result:free()
	else
		addEvent(pvpBattleground.broadcastStatistics, 1000 * 60 * BROADCAST_STATISTICS_INTERVAL)
		return
	end
	
	local i = 1
	for k,v in pairs(data) do
		
		local pid = getPlayerByNameWildcard(v.name)
		if(pid ~= nil) then
			local team = nil
		
			if(table.find(pvpBattleground.team1, pid) ~= nil) then
				team = "Time A"
			elseif(table.find(pvpBattleground.team2, pid) ~= nil) then
				team = "Time B"
			end
			
			local spaces_c = 40 - string.len(v.name)
			
			local spaces = ""	
			for i=1, spaces_c do spaces = spaces .. " " end
			
			
			if(team ~= nil) then
				msg = msg .. i .. "# " .. v.name .. " (" .. team .. ")".. spaces .. "" .. v.kills .. " / " .. v.deaths .. "  [" .. v.assists .. "] \n"	
				i = i + 1
			end	
		end
	end
	
	broadcastChannel(CUSTOM_CHANNEL_PVP, msg, TALKTYPE_TYPES["channel-orange"])
	addEvent(pvpBattleground.broadcastStatistics, 1000 * 60 * BROADCAST_STATISTICS_INTERVAL)
end

function pvpBattleground.saveKill(cid, isfrag)

	db.executeQuery("INSERT INTO `battleground_kills` VALUES (" .. getPlayerGUID(cid) .. ", " .. ((isfrag) and 1 or 0) .. ", " .. os.time() .. ");")
end

function pvpBattleground.saveDeath(cid)
	db.executeQuery("INSERT INTO `battleground_deaths` VALUES (" .. getPlayerGUID(cid) .. ", " .. os.time() .. ");")
end

function pvpBattleground.onKill(cid, target, flags)

	if(not isPlayer(cid) or not isPlayer(target)) then
		return
	end

	-- preve fogo amigo
	if(getPlayerTown(target) == getPlayerTown(cid)) then
		return
	end

	local FLAG_IS_LAST = 1
	local isfrag = getBooleanFromString(bit.uband(flags, FLAG_IS_LAST))
	
	pvpBattleground.saveKill(cid, isfrag)
	
	if(isfrag) then
		doSendAnimatedText(getPlayerPosition(cid), "FRAG!", TEXTCOLOR_DARKRED)
		pvpBattleground.saveDeath(target)
		local team_str = (getPlayerTown(cid) == temp_towns.BATTLEGROUND_TEAM_1) and "Time A" or "Time B"
		broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground - " .. team_str .. "] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") matou " .. getPlayerName(target) .. " (" .. getPlayerLevel(target) .. ")!")
	end
end

function pvpBattleground.onEnter(cid)

	if(not pvpBattleground.init) then
		pvpBattleground.onInit()
	end

	local team1, team2, team1_outfit, team2_outfit = pvpBattleground.team1, pvpBattleground.team2, pvpBattleground.team1_outfit, pvpBattleground.team2_outfit
	
	storePlayerOutfit(cid)
	local outfit = getCreatureOutfit(cid)
	
	local goIn = team1
	outfit.lookBody = team1_outfit.body
	outfit.lookLegs = team1_outfit.legs
	outfit.lookHead = team1_outfit.head
	outfit.lookFeet = team1_outfit.feet
	
	local respawn = temp_towns.BATTLEGROUND_TEAM_1
	local team_str = "Time A"
	
	if(#team1 > #team2) then
		goIn = team2
		respawn = temp_towns.BATTLEGROUND_TEAM_2
		
		outfit.lookBody = team2_outfit.body
		outfit.lookLegs = team2_outfit.legs		
		outfit.lookHead = team2_outfit.head		
		outfit.lookFeet = team2_outfit.feet		
		
		team_str = "Time B"
	end
	
	table.insert(goIn, cid)
	
	local town_id = getPlayerTown(cid)
	setPlayerStorageValue(cid, sid.TEMPLE_ID, town_id)
	
	doPlayerSetTown(cid, respawn)
	local destPos = getTownTemplePosition(respawn)
	
	doCreatureChangeOutfit(cid, outfit)
	
	doPlayerSetDoubleDamage(cid)
	lockTeleportScroll(cid)
	lockChangeOutfit(cid)
	doTeleportThing(cid, destPos)
	doSendMagicEffect(destPos, CONST_ME_MAGIC_BLUE)
	registerCreatureEvent(cid, "pvpBattleground_onKill")
	
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground - " .. team_str .. "] O jogador " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") juntou-se a batalha.")
	
	return true
end

function pvpBattleground.onExit(cid)

	local team1, team2 = pvpBattleground.team1, pvpBattleground.team2
	local respawn = getPlayerTown(cid)
	local town_id = getPlayerStorageValue(cid, sid.TEMPLE_ID)
	
	unlockChangeOutfit(cid)
	restorePlayerOutfit(cid)
	doPlayerSetTown(cid, town_id)
	doPlayerRemoveDoubleDamage(cid)	
	unlockTeleportScroll(cid)
	
	unregisterCreatureEvent(cid, "pvpBattleground_onKill")
	
	local destPos = getThingPos(uid.BATTLEGROUND_LEAVE)
	doTeleportThing(cid, destPos)
	doSendMagicEffect(destPos, CONST_ME_MAGIC_BLUE)	
	
	local pos = nil
	local team_str = nil
	
	if(respawn == temp_towns.BATTLEGROUND_TEAM_1) then
		pos = table.find(team1, cid)
		team1[pos] = nil	
		team_str = "Time A"
	elseif(respawn == temp_towns.BATTLEGROUND_TEAM_2) then
		pos = table.find(team2, cid)
		team2[pos] = nil	
		team_str = "Time B"
	else
		print("[PvP Battleground] Player exiting with temporary town respawn wrong: " .. getPlayerName(cid))
		return false
	end
	
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground - " .. team_str .. "] O jogador " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") saiu da batalha.")
	return true
end