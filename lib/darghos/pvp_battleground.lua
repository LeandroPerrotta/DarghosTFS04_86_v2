pvpBattleground = {
	team1 = {},
	team2 = {},
	team1_outfit = {body = 114, legs = 114, head = 82, feet = 91},
	team2_outfit = {body = 114, legs = 114, head = 94, feet = 0}
}

function pvpBattleground.saveKill(cid, isfrag)

	db.executeQuery("INSERT INTO `battleground_kills` VALUES (" .. getPlayerGUID(cid) .. ", " .. ((isfrag) and 1 or 0) .. ", " .. os.time() .. ");")
end

function pvpBattleground.saveDeath(cid)
	db.executeQuery("INSERT INTO `battleground_deaths` VALUES (" .. getPlayerGUID(cid) .. ", " .. os.time() .. ");")
end

function pvpBattleground.onKill(cid, target, flags)

	-- preve fogo amigo
	if(getPlayerTown(target) == getPlayerTown(cid)) then
		return
	end

	local FLAG_IS_LAST = 1
	local isfrag = getBooleanFromString(bit.uband(flags, FLAG_IS_LAST))
	
	pvpBattleground.saveKill(cid, isfrag)
	
	if(isfrag) then
		pvpBattleground.saveDeath(target)
	end
end

function pvpBattleground.onEnter(cid)

	local team1, team2, team1_outfit, team2_outfit = pvpBattleground.team1, pvpBattleground.team2, pvpBattleground.team1_outfit, pvpBattleground.team2_outfit
	
	storePlayerOutfit(cid)
	local outfit = getCreatureOutfit(cid)
	
	local goIn = team1
	outfit.lookBody = team1_outfit.body
	outfit.lookLegs = team1_outfit.legs
	outfit.lookHead = team1_outfit.head
	outfit.lookFeet = team1_outfit.feet
	
	local respawn = temp_towns.BATTLEGROUND_TEAM_1
	
	if(#team1 > #team2) then
		goIn = team2
		respawn = temp_towns.BATTLEGROUND_TEAM_2
		
		outfit.lookBody = team2_outfit.body
		outfit.lookLegs = team2_outfit.legs		
		outfit.lookHead = team2_outfit.head		
		outfit.lookFeet = team2_outfit.feet		
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