function onSay(cid, words, param, channel)
	if(param == '') then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command param required.")
		return true
	end

	local t = string.explode(param, ",")
	local ret = RETURNVALUE_NOERROR
	local pos = getCreaturePosition(cid)

	if(t[1] == "teleport") then
		local id = 1387
		local orig_pos = getCreatureLookPosition(cid)
		local dest_pos = { x = tonumber(t[2]), y = tonumber(t[3]), z = tonumber(t[4])}
		
		doCreateTeleport(id, dest_pos, orig_pos)
		return true
	end
	
	local id = tonumber(t[1])
	if(not id) then
		id = getItemIdByName(t[1], false)
		if(not id) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Item wich such name does not exists.")
			return true
		end
	end

	local amount = 100
	if(t[2]) then
		amount = t[2]
	end

	local item = doCreateItemEx(id, amount)
	if(t[3] and getBooleanFromString(t[3])) then
		if(t[4] and getBooleanFromString(t[4])) then
			pos = getCreatureLookPosition(cid)
		end

		ret = doTileAddItemEx(pos, item)
	else
		ret = doPlayerAddItemEx(cid, item, true)
	end

	if(ret ~= RETURNVALUE_NOERROR) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Couldn't add item: " .. t[1])
		return true
	end

	doDecayItem(item)
	if(not isPlayerGhost(cid)) then
		doSendMagicEffect(pos, CONST_ME_MAGIC_RED)
	end

	return true
end
