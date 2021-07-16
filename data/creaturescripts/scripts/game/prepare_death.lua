function onPrepareDeath(cid, deathList)
	
	if(isPlayer(cid)) then
	
		if(doRoyalBlessIsEnable()) then
			return useRoyalBless(cid)
		end
	end
	
	return true
end

function useRoyalBless(cid)
	
	doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)))
	doRemoveCreature(cid, true)
	
	return false
end