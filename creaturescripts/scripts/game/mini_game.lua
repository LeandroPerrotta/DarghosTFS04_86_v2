function onDeath(cid, corpse, deathList)
	
	setGlobalStorageValue(gid.EVENT_MINI_GAME_STATE, -1)
	doCreatureSay(cid, "O Comander foi derrotado, o evento Warmaster Game por esta semana esta encerrado. Todos serão enviados para seus templos em 2 minutos.", TALKTYPE_ORANGE_1)
	addEvent(kickPlayers, 1000 * 60 * 2)
		
	return true
end 

function kickPlayers()

	for _, pid in ipairs(getPlayersOnline()) do
		local isInside = getPlayerStorageValue(pid, sid.INSIDE_MINI_GAME)
		if(isInside == 1) then
		
			doSendMagicEffect(getCreaturePosition(pid), CONST_ME_MAGIC_BLUE)
			doTeleportThing(pid, getPlayerMasterPos(pid))	
			setPlayerStorageValue(pid, sid.INSIDE_MINI_GAME, -1)
		end
	end
end