function onDeath(cid, corpse, deathList)
	if isPlayer(cid) == TRUE then
		--Fun��es que ser�o chamadas quando um jogador morrer...
		
		Dungeons.onPlayerDeath(cid)
		setPlayerStorageValue(cid, sid.GIVE_ITEMS_AFTER_DEATH, 1)
		deathInDemonOak(cid)
	end	
	
	return true
end 

function deathInDemonOak(cid)
	local playerInside = getGlobalStorageValue(gid.DEMON_OAK_PLAYER_INSIDE)
	
	if(playerInside ~= -1 and playerInside == cid) then
		setGlobalStorageValue(gid.DEMON_OAK_PLAYER_INSIDE, -1)
		unlockTeleportScroll(cid)
	end
end