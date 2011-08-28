-- ACTIONS HANDLER

function defaultActions(cid, item, fromPosition, itemEx, toPosition)

	local item_id = item.itemid
	
	local ret = false
	
	if(item_id == CUSTOM_ITEMS.TELEPORT_RUNE) then
		ret = teleportRune.onUse(cid, item, fromPosition, itemEx, toPosition)
	elseif(item_id == CUSTOM_ITEMS.UNHOLY_SWORD) then
		ret = unholySword.onUse(cid, item, fromPosition, itemEx, toPosition)
	elseif(item_id == CUSTOM_ITEMS.PREMIUM_SCROLL) then
		ret = premiumScroll.onUse(cid, item, fromPosition, itemEx, toPosition)
	elseif(item_id == CUSTOM_ITEMS.OUTFIT_TICKET) then
		ret = outfitTicket.onUse(cid, item, fromPosition, itemEx, toPosition)
	end
	
	return ret
end

outfitTicket = {}

function outfitTicket.onUse(cid, item, fromPosition, itemEx, toPosition)
	
	local outfitId = item.actionid or 0
	local outfitName = {
		[1] = "Citizen",
		[2] = "Hunter",
		[3] = "Mage",
		[4] = "Knight",
		[5] = "Noble",
		[6] = "Summoner",
		[7] = "Warrior",
		[8] = "Barbarian",
		[9] = "Druid",
		[10] = "Wizard",
		[11] = "Oriental",
		[12] = "Pirate",
		[13] = "Assassin",
		[14] = "Beggar",
		[15] = "Shaman",
		[16] = "Norse",
		[17] = "Nightmare",
		[18] = "Jester",
		[19] = "Brotherhood",
		[20] = "Demonhunter",
		[21] = "Yalaharian",
		[22] = "Warmaster",
		[23] = "Wayfarer"
	}

	local tempName = "Unkwnown"

	if(outfitName[outfitId] ~= nil) then
		tempName = outfitName[outfitId]
	else
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "This is an invalid outfit ticket. Report to game master!")
		return true
	end
	
	local playerOutfit = { outfit = false, first_addon = false, second_addon = false }
	
	if(canPlayerWearOutfitId(cid, outfitId, 0)) then
		playerOutfit.outfit = true
	end
	
	if(canPlayerWearOutfitId(cid, outfitId, 1)) then
		playerOutfit.first_addon = true
	end
	
	if(canPlayerWearOutfitId(cid, outfitId, 2)) then
		playerOutfit.second_addon = true
	end
	
	if(not playerOutfit.outfit) then
		local log_id = getItemAttribute(item.uid, "itemShopLogId")
		
		if(log_id or not doLogItemShopUse(cid, log_id)) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "The benefit of this item has already been provided. Issue reported.")
			return true
		end		
	
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You earned the " .. tempName .. " outfit!")
		doPlayerAddOutfitId(cid, outfitId, 0)
	elseif(not playerOutfit.first_addon) then
		local log_id = getItemAttribute(item.uid, "itemShopLogId")
		
		if(log_id or not doLogItemShopUse(cid, log_id)) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "The benefit of this item has already been provided. Issue reported.")
			return true
		end		
	
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You earned the first addon for " .. tempName .. " outfit!")
		doPlayerAddOutfitId(cid, outfitId, 1)	
	elseif(not playerOutfit.second_addon) then
		local log_id = getItemAttribute(item.uid, "itemShopLogId")
		
		if(log_id or not doLogItemShopUse(cid, log_id)) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "The benefit of this item has already been provided. Issue reported.")
			return true
		end		
		
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You earned the second addon for " .. tempName .. " outfit!")
		doPlayerAddOutfitId(cid, outfitId, 2)
	else
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You already have the full " .. tempName .. " outfit!")
		return true		
	end
	
	sendEnvolveEffect(cid, CONST_ME_HOLYAREA)
	doRemoveItem(item.uid)
	return true
end

premiumScroll = {}

premiumScroll.PREMIUM_DAYS_TO_ADD = 30

function premiumScroll.onUse(cid, item, frompos, item2, topos)
	
	local log_id = getItemAttribute(item.uid, "itemShopLogId")
	
	if(not log_id or not doLogItemShopUse(cid, log_id)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_SMALL, "The benefit of this item has already been provided. Issue reported.")
		return true
	end
	
	doPlayerAddPremiumDays(cid, premiumScroll.PREMIUM_DAYS_TO_ADD)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "You have earned " .. premiumScroll.PREMIUM_DAYS_TO_ADD .. " days of premium time with this premium scroll! Good luck!")
	doRemoveItem(item.uid)	
	
	return true
end

teleportRune = {}

teleportRune.STATE_NONE = -1
teleportRune.STATE_TELEPORTING_FIRST = 0
teleportRune.STATE_TELEPORTING_SECOND = 1
teleportRune.STATE_TELEPORTING_THIRD = 2

teleportRune.TELEPORT_USAGE_NEVER = -1
teleportRune.TELEPORT_USAGE_INTERVAL = 60 * 30 -- 30 minutos

function teleportRune.onUse(cid, item, frompos, item2, topos)

	local onIsland = (getPlayerStorageValue(cid, sid.IS_ON_TRAINING_ISLAND) == 1) and true or false
	
	if(onIsland or teleportScrollIsLocked(cid)) then
		doPlayerSendCancel(cid, "Você não pode usar este item neste lugar!")
		return true
	end

	if(hasCondition(cid, CONDITION_INFIGHT) == TRUE) then
		doPlayerSendCancel(cid, "Você não pode usar este item enquanto estiver em batalha!")
		return true
	end
	
	if(getPlayerStorageValue(cid, sid.TELEPORT_RUNE_STATE) ~= teleportRune.STATE_NONE) then
		doPlayerSendCancel(cid, "A carga já sendo carregada, tenha paciencia!")
		return true
	end
	
	local lastTeleportRuneUsage = getPlayerStorageValue(cid, sid.TELEPORT_RUNE_LAST_USAGE)
	if(lastTeleportRuneUsage ~= teleportRune.TELEPORT_USAGE_NEVER and os.time() <= lastTeleportRuneUsage + teleportRune.TELEPORT_USAGE_INTERVAL) then
		local secondsLeft = (lastTeleportRuneUsage + teleportRune.TELEPORT_USAGE_INTERVAL) - os.time()
		
		if(secondsLeft >= 60) then
			doPlayerSendCancel(cid, "Você deve aguardar " .. math.floor(secondsLeft / 60) .. " minutos para que sua teleport rune descançe e possa usar-la novamente.")
		else
			doPlayerSendCancel(cid, "Você deve aguardar menos de um minuto para que sua teleport rune termine de descançar e possa usar-la novamente.")
		end
		
		doPlayerSendCancel(cid, "Você deve aguardar " .. math.ceil(((lastTeleportRuneUsage + teleportRune.TELEPORT_USAGE_INTERVAL) - os.time()) / 60) .. " minutos para que sua teleport rune descançe e possa usar-la novamente.")
		return true
	end
	
	doCreatureSay(cid, "Faltam 30 segundos para minha teleport rune ser carregada...", TALKTYPE_ORANGE_1)
	setPlayerStorageValue(cid, sid.TELEPORT_RUNE_STATE, teleportRune.STATE_TELEPORTING_FIRST)
	addEvent(teleportRune.firstStep, 1000 * 10, cid)
	
	return true
end

function teleportRune.firstStep(cid)
	if(isCreature(cid) == FALSE) then
		return
	end
	
	if(hasCondition(cid, CONDITION_INFIGHT) == TRUE) then
		setPlayerStorageValue(cid, sid.TELEPORT_RUNE_STATE, teleportRune.STATE_NONE)
		doCreatureSay(cid, "Arggh! Entrei em batalha! O transporte foi abortado!", TALKTYPE_ORANGE_1)
		return
	end	
	
	doCreatureSay(cid, "Faltam 20 segundos para minha teleport rune ser carregada...", TALKTYPE_ORANGE_1)
	setPlayerStorageValue(cid, sid.TELEPORT_RUNE_STATE, teleportRune.STATE_TELEPORTING_SECOND)
	addEvent(teleportRune.secondStep, 1000 * 10, cid)
end

function teleportRune.secondStep(cid)
	if(isCreature(cid) == FALSE) then
		return
	end
	
	if(hasCondition(cid, CONDITION_INFIGHT) == TRUE) then
		setPlayerStorageValue(cid, sid.TELEPORT_RUNE_STATE, teleportRune.STATE_NONE)
		doCreatureSay(cid, "Arggh! Entrei em batalha! O transporte foi abortado!", TALKTYPE_ORANGE_1)
		return
	end	
	
	doCreatureSay(cid, "Faltam 10 segundos para minha teleport rune ser carregada...", TALKTYPE_ORANGE_1)
	setPlayerStorageValue(cid, sid.TELEPORT_RUNE_STATE, teleportRune.STATE_TELEPORTING_THIRD)
	addEvent(teleportRune.thirdStep, 1000 * 10, cid)
end

function teleportRune.thirdStep(cid)
	if(isCreature(cid) == FALSE) then
		return
	end
	
	if(hasCondition(cid, CONDITION_INFIGHT) == TRUE) then
		setPlayerStorageValue(cid, sid.TELEPORT_RUNE_STATE, teleportRune.STATE_NONE)
		doCreatureSay(cid, "Arggh! Entrei em batalha! O transporte foi abortado!", TALKTYPE_ORANGE_1)
		return
	end	
	
	doCreatureSay(cid, "Finalmente minha teleport rune foi carregada!", TALKTYPE_ORANGE_1)
	
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)	
	doTeleportThing(cid, getPlayerMasterPos(cid))
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)	
	
	setPlayerStorageValue(cid, sid.TELEPORT_RUNE_STATE, teleportRune.STATE_NONE)
	setPlayerStorageValue(cid, sid.TELEPORT_RUNE_LAST_USAGE, os.time())
end