function needCheckTradeItem(item_id)
	return isInArray({CUSTOM_ITEMS.PREMIUM_SCROLL, CUSTOM_ITEMS.OUTFIT_TICKET}, item_id)
end

function searchItemInContainer(container, foundItems)    
    for k = (getContainerSize(container) - 1), 0, -1 do
        local tmp = getContainerItem(container, k)
        
        if (isInArray(cannotBeTraded, tmp.itemid)) then	
    		foundItems = foundItems + 1
        elseif isContainer(tmp.uid) then
        	searchItemInContainer(tmp.uid, foundItems)
        end
    end
end

function canTradeItem(item)

	local unusableCount = 0
	
	function searchAlreadyUsedItems(container)
	    for k = (getContainerSize(container) - 1), 0, -1 do
	        local tmp = getContainerItem(container, k)
	        
	        if (needCheckTradeItem(tmp.itemid)) then	
	        
	        	local log_id = getItemAttribute(tmp.uid, "itemShopLogId")
	        	
	        	if(not log_id or not canUseShopItem(log_id)) then
	        	
	        		unusableCount = unusableCount + 1
	        	end
	        elseif isContainer(tmp.uid) then
	        	searchAlreadyUsedItems(tmp.uid)
	        end
	    end
	end	
	
	if(isContainer(item.uid)) then
		searchAlreadyUsedItems(item.uid)	
	else
		if(needCheckTradeItem(item.itemid)) then				
        	local log_id = getItemAttribute(item.uid, "itemShopLogId")
        	
        	if(not log_id or not canUseShopItem(log_id)) then
        	
        		unusableCount = unusableCount + 1
        	end			
		end	
	end
	
	if(unusableCount > 0) then
		return false
	end
	
	return true
end

function onTradeAccept(cid, target, item, targetItem)

	local foundItems = 0
	
	--[[
	if(isContainer(item.uid)) then
		searchItemInContainer(item.uid, foundItems)
	else
		if(isInArray(cannotBeTraded, item.itemid)) then	
			foundItems = foundItems + 1
		end
	end
	
	if(isContainer(targetItem.uid)) then
		searchItemInContainer(targetItem.uid, foundItems)
	else
		if(isInArray(cannotBeTraded, targetItem.itemid)) then	
			foundItems = foundItems + 1
		end
	end	
	]]--
	
	if(doPlayerIsPvpEnable(cid) and not doPlayerIsPvpEnable(target) and hasCondition(cid, CONDITION_INFIGHT)) then
		doPlayerSendCancel(cid, "Você não pode trocar um item com um jogador Pacifico enquanto estiver em combate.")
		return false
	end	
	
	if(not canTradeItem(item) or not canTradeItem(targetItem)) then
		foundItems = 1
	end
	
	if(foundItems > 0) then
	
		local msg = "Você ou seu parceiro de troca colocou um item não trocavel. Remova itens não trocaveis e tente novamente."
	
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, msg)
		doPlayerSendTextMessage(target, MESSAGE_INFO_DESCR, msg)

		return false
	end
	
	return true
end