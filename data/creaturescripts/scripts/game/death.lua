function onDeath(cid, corpse, deathList)
	if isPlayer(cid) then
		--Fun??es que ser?o chamadas quando um jogador morrer...
		
		Dungeons.onPlayerDeath(cid)
		setPlayerStorageValue(cid, sid.GIVE_ITEMS_AFTER_DEATH, 1)
		deathInDemonOak(cid)
	end	
	
	if(isMonster(cid)) then
	
		local inquisitionBosses = {"ushuriel", "madareth", "zugurosh", "latrivan", "golgordan", "annihilon", "hellgorak"}
	
		if(string.lower(getCreatureName(cid)) == "koshei the deathless") then
		
			function resummonKoshei(cid, corpse)
			
				if(getGlobalStorageValue(gid.KOSHEI_DEATH) == 1) then
					setGlobalStorageValue(gid.KOSHEI_DEATH, -1)
					return
				end
			
				local pos = getThingPos(uid.KOSHEI_POS)
				local koshei = doSummonCreature("Koshei the Deathless", pos)
				registerCreatureEvent(koshei, "monsterDeath")
				doCreatureSay(koshei, "Mas que tolice! Eu sou IMORTAL MUAHAHAHAHHA", TALKTYPE_ORANGE_1)				
			end
		
			doCreatureSay(cid, "Argh! Você realmente acha que me derrotou? <...>", TALKTYPE_ORANGE_1)
			doItemSetAttribute(corpse.uid, "kosheiDeathDate", os.time())
			addEvent(resummonKoshei, 1000 * 4, cid, corpse)
		elseif(isInArray(inquisitionBosses, string.lower(getCreatureName(cid)))) then
			addEvent(summonInquisitionBoss, 1000 * 60 * 60, string.lower(getCreatureName(cid)))
		elseif(string.lower(getCreatureName(cid)) == "lord vankyner") then
			onLordVankynerDie()
		elseif(string.lower(getCreatureName(cid)) == "dark general") then
			onDarkGeneralDie(cid, corpse, deathList)
		end
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