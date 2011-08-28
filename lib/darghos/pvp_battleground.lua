pvpBattleground = {
	team1 = {},
	team2 = {},
	team1_outfit = {body = 87, legs = 87},
	team2_outfit = {body = 94, legs = 94}
}

function pvpBattleground.saveKill(cid, isfrag)

	db.executeQuery("INSERT INTO `battleground_kills` VALUES (" .. getPlayerGUID(cid) .. ", " .. ((isfrag) and 1 or 0) .. ", " .. os.time() .. ");")
end

function pvpBattleground.saveDeath(cid)
	db.executeQuery("INSERT INTO `battleground_deaths` VALUES (" .. getPlayerGUID(cid) .. ", " .. os.time() .. ");")
end

function pvpBattleground.onKill(cid, target, flags)

	local FLAG_IS_LAST = 1
	local isfrag = getBooleanFromString(bit.uband(flags, FLAG_IS_LAST))
	
	pvpBattleground.saveKill(cid, isfrag)
	
	if(isfrag) then
		pvpBattleground.saveDeath(target)
	end
end

function pvpBattleground.onEnter(cid)

	local team1, team2 = pvpBattleground.team1, pvpBattleground.team2
	
	storePlayerOutfit(cid)
	local outfit = getCreatureOutfit(cid)
	
	local goIn = team1
	outfit.body = team1_outfit.body
	outfit.body = team1_outfit.legs
	
	local respawn = temp_towns.BATTLEGROUND_TEAM_1
	
	if(#team1 > #team2) then
		goIn = team2
		respawn = temp_towns.BATTLEGROUND_TEAM_2
		
		outfit.body = team2_outfit.body
		outfit.legs = team2_outfit.legs		
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
	
	return true
end

function pvpBattleground.onExit(cid)

	local team1, team2 = pvpBattleground.team1, pvpBattleground.team2
	local respawn = getPlayerTown(cid)
	local town_id = getPlayerStorageValue(cid, sid.TEMPLE_ID)
	
	restorePlayerOutfit(cid)
	doPlayerSetTown(cid, town_id)
	doPlayerRemoveDoubleDamage(cid)	
	unlockTeleportScroll(cid)
	unlockChangeOutfit(cid)
	unregisterCreatureEvent(cid, "pvpBattleground_onKill")
	
	local destPos = getThingPos(uid.BATTLEGROUND_LEAVE)
	doTeleportThing(cid, destPos)
	doSendMagicEffect(destPos, CONST_ME_MAGIC_BLUE)	
	
	local pos = nil
	
	if(respawn == temp_towns.BATTLEGROUND_TEAM_1) then
		pos = table.find(team1, cid)
		team1[pos] = nil	
	elseif(respawn == temp_towns.BATTLEGROUND_TEAM_2) then
		pos = table.find(team2, cid)
		team2[pos] = nil	
	else
		print("[PvP Battleground] Player exiting with temporary town respawn wrong: " .. getPlayerName(cid))
		return false
	end
	
	
	return true
end