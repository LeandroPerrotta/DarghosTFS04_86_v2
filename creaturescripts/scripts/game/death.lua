function onDeath(cid, corpse, deathList)
	if isPlayer(cid) == TRUE then
		--Fun��es que ser�o chamadas quando um jogador morrer...
		
		Dungeons.onPlayerDeath(cid)
		setPlayerStorageValue(cid, sid.GIVE_ITEMS_AFTER_DEATH, 1)
		deathInDemonOak(cid)
	end	
	
	if(isMonster(cid)) then
		if(string.lower(getCreatureName(cid)) == "koshei the deathless") then
		
			function resummonKoshei(cid, corpse)
			
				if(getGlobalStorageValue(gid.KOSHEI_DEATH) == 1) then
					doCreatureSay(cid, "Aaarrghhh!! Este miseravel conhece minha fraquesa!! Eu ainda retornarei!!", TALKTYPE_ORANGE_1)
					setGlobalStorageValue(gid.KOSHEI_DEATH, -1)
					return
				end
			
				doCreatureSay(cid, "Mas que tolice! Eu sou IMORTAL MUAHAHAHAHHA", TALKTYPE_ORANGE_1)
				doRemoveItem(corpse.uid)
				local pos = getThingPos(uid.KOSHEI_POS)
				local koshei = doSummonCreature("Koshei the Deathless")
				addCreatureEvent(koshei, "monsterDeath")				
			end
		
			doCreatureSay(cid, "Argh! Você realmente acha que me derrotou? <...>", TALKTYPE_ORANGE_1)
			doItemSetAttribute(corpse.uid, "kosheiCorpse", true)
			addEvent(resummonKoshei, 1000 * 4, cid, corpse)
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