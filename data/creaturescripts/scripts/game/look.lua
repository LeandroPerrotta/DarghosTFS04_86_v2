function onLook(cid, thing, position, lookDistance)    

	local item_id = thing.itemid	
	if(item_id == CUSTOM_ITEMS.OUTFIT_TICKET) then
		lookingOutfitTicket(cid, thing)
	end

	return true
end