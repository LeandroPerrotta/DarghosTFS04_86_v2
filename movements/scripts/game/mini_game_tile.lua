function onStepIn(cid, item, position, fromPosition)
	
	local eventState = getGlobalStorageValue(gid.EVENT_MINI_GAME_STATE)
	
	if(eventState ~= 1) then
		
		doTeleportThing(cid, fromPosition, false)
		doSendMagicEffect(position, CONST_ME_MAGIC_BLUE)
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Este evento s� � aberto aos domingos e ter�as a partir das 15:00.")	
	end
	
	return true
end
