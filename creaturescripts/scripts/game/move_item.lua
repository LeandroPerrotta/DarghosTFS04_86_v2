function onMoveItem(cid, item, position)

	if(position.x == CONTAINER_POSITION) then
	
		if(getBooleanFromString(bit.uband(position.y, 64))) then
			return onMoveContainerItem(cid, item, position.z)
		else
			return onMoveSlotItem(cid, item, position.y)
		end		
	end
	
	return onMoveGroundItem(cid, item, position)
end

SOULBOUND_ITEMS = { 2392 }

function onMoveGroundItem(cid, item, position)

	--[[
	local isSoulBound = isInArray(SOULBOUND_ITEMS, item.itemid)
	if(isSoulBound) then
		doPlayerSendCancel(cid, "Este item foi preso a sua alma pelos Deuses, você não pode o colocar em lugares que ele possa ser pegado por alguém.")
		return false
	end
	--]]

	if(getTileInfo(position).depot) then
		local dist = getDistanceBetween(getPlayerPosition(cid), position)
		if(depotBusy(position) and dist > 1) then			
			doPlayerSendCancel(cid, "Você não pode jogar um item no depot de outra pessoa.")
			return false
		end
	end
	
	return true
end

function depotBusy(position)

	local _pos = table.copy(position)
	_pos.x = _pos.x + 1
	if(isPlayer(getTopCreature(_pos).uid)) then
		return true
	end
	
	_pos = table.copy(position)
	_pos.x = _pos.x - 1
	if(isPlayer(getTopCreature(_pos).uid)) then
		return true
	end	
	
	_pos = table.copy(position)
	_pos.y = _pos.y + 1
	if(isPlayer(getTopCreature(_pos).uid)) then
		return true
	end
	
	_pos = table.copy(position)
	_pos.y = _pos.y - 1
	if(isPlayer(getTopCreature(_pos).uid)) then
		return true
	end	

	return false
end

function onMoveContainerItem(cid, item, containerPos)

	return true
end

function onMoveSlotItem(cid, item, slot)

	--[[
	local isSoulBound = isInArray(SOULBOUND_ITEMS, item.itemid)
	if(isSoulBound) then
		if(slot == CONST_SLOT_RIGHT or slot == CONST_SLOT_LEFT) then
			doItemEraseAttribute(item.uid, "attack")
			doItemSetAttribute(item.uid, "attack", 81)
		end
	end
	--]]

	return true
end