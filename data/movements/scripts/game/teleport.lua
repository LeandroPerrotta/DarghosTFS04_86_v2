local function pushBack(cid, position, fromPosition, displayMessage)
	doTeleportThing(cid, fromPosition, false)
	doSendMagicEffect(position, CONST_ME_MAGIC_BLUE)
	if(displayMessage) then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "The tile seems to be protected against unwanted intruders.")
	end
end

function onStepIn(cid, item, position, fromPosition)

	if(item.actionid >= 30020 and item.actionid < 30100) then
	
		local city = getTownNameById(item.actionid - 30020)
		doPlayerSetTown(cid, item.actionid - 30020)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_DEFAULT,"Now you are a citizen of "..city..".")
		
		return TRUE
	elseif(item.actionid > 30100 and item.actionid < 30200) then
	
		local town_id = item.actionid - 30100
		
		if(town_id == towns.ARACURA and not doPlayerIsPvpEnable(cid)) then
			doPlayerSendCancel(cid, "Somente jogadores com PvP ativo podem viajar para está cidade.")
			pushBack(cid, position, fromPosition)
			return false
		end
		
		local town_name = getTownNameById(town_id)
		doTeleportThing(cid, getTownTemplePosition(town_id))
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_DEFAULT,"Bem vindo a cidade de ".. town_name .."!")
		
		return TRUE
	end
	
	if(item.actionid == aid.BATTLEGROUND_EXIT) then
		local ret = pvpBattleground.onExit(cid)
		if(not ret) then
			pushBack(cid, position, fromPosition)
			return false
		end
	elseif(isInArray({aid.BATTLEGROUND_LEAVE_BASE_TEAM_ONE, aid.BATTLEGROUND_LEAVE_BASE_TEAM_TWO}, item.actionid)) then
		local team = (item.actionid == aid.BATTLEGROUND_LEAVE_BASE_TEAM_ONE) and BATTLEGROUND_TEAM_ONE or BATTLEGROUND_TEAM_TWO
		local ret = pvpBattleground.onLeaveBase(cid, team)
		if(not ret) then
			pushBack(cid, position, fromPosition)
			return false
		end
	end
	
	if(item.actionid == aid.INQ_UNGREEZ_PORTAL and not onEnterInUngreezPortal(cid, position, fromPosition)) then
		pushBack(cid, position, fromPosition)
		return false
	end
	
	if(item.actionid >= aid.SHRINE_MIN and item.actionid <= aid.SHRINE_MAX) then
		return teleportToShrine(cid, item, position, fromPosition)
	end
	
	if(item.uid == uid.TELEPORT_BACK) then
		return doTeleportBack(cid)
	elseif(item.uid == uid.TELEPORT_GO) then
		return doTeleportBack(cid, fromPosition)
	end
	
	if(item.actionid ~= nil and item.actionid == aid.CHURCH_PORTAL) then
	
		local destPos = getThingPos(uid.CHURCH_PORTAL_DEST)
	
		local chamberTemptation = getPlayerStorageValue(cid, QUESTLOG.DIVINE_ANKH.CHAMBER_TEMPTATION)
		
		if(chamberTemptation == 3) then
			doTeleportThing(cid, destPos)
			doSendMagicEffect(destPos, CONST_ME_MAGIC_BLUE)
			return TRUE
		end
		
		--print("Church portal")
		
		destPos = getThingPos(uid.CHURCH_PORTAL_FAIL)
		
		doTeleportThing(cid, destPos)
		doSendMagicEffect(destPos, CONST_ME_MAGIC_BLUE)	
		
		doPlayerSendCancel(cid, "Você não pode passar por aqui.")
		return TRUE
	end
	
	return TRUE
end

function teleportToShrine(cid, item, position, fromPosition)

	local actionid = item.actionid

	if((actionid == aid.SHRINE_FIRE or actionid == aid.SHRINE_ENERGY) and not isSorcerer(cid)) then
	
		doPlayerSendCancel(cid, "Somente sorcerers podem atravessar o portal para este santuario.")
		pushBack(cid, position, fromPosition)
		return false
	end
	
	if((actionid == aid.SHRINE_EARTH or actionid == aid.SHRINE_ICE) and not isDruid(cid)) then
	
		doPlayerSendCancel(cid, "Somente druids podem atravessar o portal para este santuario.")
		pushBack(cid, position, fromPosition)
		return false
	end
	
	doTeleportBack(cid, fromPosition)
	
	local destPos = nil
	
	if(actionid == aid.SHRINE_EARTH) then
		destPos = getThingPosition(uid.SHRINE_EARTH_POS)
	elseif(actionid == aid.SHRINE_ICE) then
		destPos = getThingPosition(uid.SHRINE_ICE_POS)
	elseif(actionid == aid.SHRINE_FIRE) then
		destPos = getThingPosition(uid.SHRINE_FIRE_POS)
	elseif(actionid == aid.SHRINE_ENERGY) then
		destPos = getThingPosition(uid.SHRINE_ENERGY_POS)
	else
		print("[Darghos Movement] teleportToShrine - Destination shrine pos not found, check action id.")
	end
	
	doTeleportThing(cid, destPos)
	doSendMagicEffect(destPos, CONST_ME_MAGIC_BLUE)		
	
	return true
end
