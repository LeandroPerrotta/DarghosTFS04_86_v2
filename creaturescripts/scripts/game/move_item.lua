function onMoveItem(cid, item, position)

	if(getTileInfo(position).depot) then
		local checkPos = getCreatureLookPosition(cid)
		if(checkPos.x ~= position.x
			or checkPos.y ~= position.y
			or checkPos.z ~= position.z) then
			
			doPlayerSendCancel(cid, "Voc� n�o pode jogar um item no depot de outra pessoa.")
			return false
		end
	end
	
	return true
end
