pvpBattleground = {
	team1 = {},
	team2 = {}
}

function pvpBattleground.onKill(cid, flags)

	local FLAG_IS_LAST = 1

	local isLast = bit.uband(flags, FLAG_IS_LAST)
	
	print(table.show(isLast))
	
	if(isLast) then
		print("Is last!")
	else
		print("Is not last..")
	end
end

function pvpBattleground.onEnter(cid)

	local team1, team2 = pvpBattleground.team1, pvpBattleground.team2
	
	local goIn = team1
	local respawn = temp_towns.BATTLEGROUND_TEAM_1
	
	if(#team1 > #team2) then
		goIn = team2
		respawn = temp_towns.BATTLEGROUND_TEAM_2
	end
	
	table.insert(goIn, cid)
	
	local town_id = getPlayerTown(cid)
	setPlayerStorageValue(cid, sid.TEMPLE_ID, town_id)
	
	doPlayerSetTown(cid, respawn)
	local destPos = getTownTemplePosition(respawn)
	
	doPlayerSetDoubleDamage(cid)
	lockTeleportScroll(cid)
	doTeleportThing(cid, destPos)
	doSendMagicEffect(destPos, CONST_ME_MAGIC_BLUE)
	registerCreatureEvent(cid, "pvpBattleground_onKill")
	
	return true
end

function pvpBattleground.onExit(cid)

	local team1, team2 = pvpBattleground.team1, pvpBattleground.team2
	local respawn = getPlayerTown(cid)
	local town_id = getPlayerStorageValue(cid, sid.TEMPLE_ID)
	
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