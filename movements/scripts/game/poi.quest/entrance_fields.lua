function onStepIn(cid, item, position, fromPosition)

	local damages = {
		300,
		600,
		2400,
		3600,
		6000,
		getCreatureHealth(cid)
	}
	
	local strActionID = tostring(item.actionid)
	
	local playerVocation = getPlayerVocation(cid)
	
	local currentVocation = string.sub(strActionID, 3, 3)	
	
	if((currentVocation ~= playerVocation) and ((currentVocation + 4) ~= playerVocation)) then
	
		local index = tonumber(string.sub(strActionID, 4, 4))
		local damage = tonumber(damages[index])
		
		doCreatureAddHealth(cid, -damage, CONST_ME_FIREAREA, COLOR_RED)
	
		doPlayerSendCancel(cid, "Você está no caminho errado!")
	end
	
	return true
	
end