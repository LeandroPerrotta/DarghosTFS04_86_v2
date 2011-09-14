-- Custom Modules do Darghos para o NPC System padrão do Jiddo

D_CustomNpcModules = {}

function D_CustomNpcModules.addonTradeItems(cid, message, keywords, parameters, node)

	local npcHandler = parameters.npcHandler
	
	if(npcHandler == nil) then
		print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
		return false
	end

	if(not npcHandler:isFocused(cid)) then
		return false
	end

	local foundAll = true

	local itemsToRemove = {}

	for _,item in pairs(parameters.neededItems) do
	
		local count = item.count or 1
	
		if(item.anyOf ~= nil) then
		
			local found = false
		
			for _,sub in pairs(item.anyOf) do
			
				count = sub.count or count
				
				if(sub.id == nil and sub.name == nil) then
					print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - An value of sub-item table not have both id and name.')
					return false
				end
				
				local itemtype = sub.id or getItemIdByName(sub.name)
				
				if(not itemtype) then
					print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - Can not found a id for an sub-item called ' .. item.name .. '.')
					return false			
				end				
			
				if(getPlayerItemCount(cid, itemtype) >= count) then
					found = true
					table.insert(itemsToRemove, {id = itemtype, count = count})
					break
				end			
			end
			
			if(not found) then
				foundAll = false
				break
			end		
		else	
			if(item.id == nil and item.name == nil) then
				print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - An value of item table not have both id and name.')
				return false
			end
			
			local itemtype = item.id or getItemIdByName(item.name)
			
			if(not itemtype) then
				print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - Can not found a id for an item called ' .. item.name .. '.')
				return false			
			end
		
			if(getPlayerItemCount(cid, itemtype) >= count) then
				table.insert(itemsToRemove, {id = itemtype, count = count})
			else
				foundAll = false
				break
			end			
		end
	end
	
	if(not foundAll) then		
		local msg = parameters.fail or "Sorry but you not have all needed items..."
		npcHandler:say(msg, cid)
		npcHandler:resetNpc()
		return true
	end
	
	local neededCap = 0
	
	for _,item in pairs(parameters.receiveItems) do
	
		neededCap = neededCap + getItemWeightById(item.id, item.count)
	end		
	
	if(getPlayerFreeCap(cid) < neededCap) then
		npcHandler:say("You do not have enough capacity for all items.", cid)
		npcHandler:resetNpc()
		return true	
	end
	
	for k,v in pairs(itemsToRemove) do
		if(not doPlayerRemoveItem(cid, v.id, v.count)) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - Impossible to remove an previously checked item, aborted. Details:', '{player=' .. getCreatureName(cid) .. ', item_id=' .. v.id .. ', count=' .. v.count .. '}', 'Added items: ' .. table.show(addedItems))
			return false
		end
	end	
	
	local addedItems = {}
	
	for _,item in pairs(parameters.receiveItems) do
	
		local count = item.count or 1
	
		local tmp = doCreateItemEx(item.id, count)
		if(doPlayerAddItemEx(cid, tmp, true) ~= RETURNVALUE_NOERROR) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'D_CustomNpcModules.addonTradeItems - Impossible to give an item, aborted. Details:', '{player=' .. getCreatureName(cid) .. ', item_id=' .. v.id .. ', count=' .. v.count .. '}', 'Added items: ' .. table.show(addedItems))
			return false
		else
			table.insert(addedItems, {id = item.id, count = item.count})
		end
	end		
	
	local msg = parameters.success or "Thanks! Here it is! I hope you are happy!"
	npcHandler:say(msg, cid)
	npcHandler:resetNpc()
	return true	
end

function D_CustomNpcModules.travelTrainingIsland(cid, message, keywords, parameters, node)
	local npcHandler = parameters.npcHandler
	if(npcHandler == nil) then
		print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
		return false
	end

	if(not npcHandler:isFocused(cid)) then
		return false
	end

	local storage, pzLocked = parameters.storageValue or (EMPTY_STORAGE + 1), parameters.allowLocked or false
	if(parameters.premium and not isPlayerPremiumCallback(cid)) then
		npcHandler:say('I can only allow premium players to travel with me.', cid)
	elseif(parameters.level ~= nil and getPlayerLevel(cid) < parameters.level) then
		npcHandler:say('You must reach level ' .. parameters.level .. ' before I can let you go there.', cid)
	elseif(parameters.storageId ~= nil and getPlayerStorageValue(cid, parameters.storageId) < storage) then
		npcHandler:say(parameters.storageInfo or 'You may not travel there!', cid)
	elseif(not pzLocked and isPlayerPzLocked(cid)) then
		npcHandler:say('Get out of there with this blood!', cid)
	elseif(not doPlayerRemoveMoney(cid, parameters.cost)) then
		npcHandler:say('You do not have enough money.', cid)
	else
		npcHandler:say('It was a pleasure doing business with you.', cid)
		npcHandler:releaseFocus(cid)
		
		if(parameters.entering ~= nil and parameters.entering) then
			setPlayerStorageValue(cid, sid.IS_ON_TRAINING_ISLAND, 1)
			doUpdateCreaturePassable(cid)
			customStaminaUpdate(cid)
		else
			setPlayerStorageValue(cid, sid.IS_ON_TRAINING_ISLAND, STORAGE_NULL)
			setPlayerStorageValue(cid, sid.NEXT_STAMINA_UPDATE, STORAGE_NULL)	
			doUpdateCreatureImpassable(cid)
		end

		doTeleportThing(cid, parameters.destination, false)
		doSendMagicEffect(parameters.destination, CONST_ME_TELEPORT)
	end

	npcHandler:resetNpc()
	return true
end

function D_CustomNpcModules.pvpBless(cid, message, keywords, parameters, node)

	local npcHandler = parameters.npcHandler
	if(npcHandler == nil) then
		print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.bless - Call without any npcHandler instance.')
		return false
	end

	if(not npcHandler:isFocused(cid)) then
		return false
	end

	local price = parameters.baseCost
	if(getPlayerLevel(cid) > parameters.startLevel) then
		price = (price + ((math.min(parameters.endLevel, getPlayerLevel(cid)) - parameters.startLevel) * parameters.levelCost))
	end

	if(getPlayerPVPBlessing(cid)) then
		npcHandler:say("De novo? Os deuses j� lhe aben�oaram!", cid)
	elseif(not doPlayerRemoveMoney(cid, price)) then
		npcHandler:say("Voc� n�o tem moedas sulficientes para a ben��o...", cid)
	else
		npcHandler:say("Agora suas ben��es normais est�o protegidas contra mortes para outros jogadores! Boa sorte!", cid)
		doPlayerSetPVPBlessing(cid)
	end

	npcHandler:resetNpc()
	return true
end

function D_CustomNpcModules.inquisitionBless(cid, message, keywords, parameters, node)
	local npcHandler = parameters.npcHandler
	if(npcHandler == nil) then
		print('StdModule.bless called without any npcHandler instance.')
		return false
	end

	if(not npcHandler:isFocused(cid)) then
		return false
	end

	local questStatus = getPlayerStorageValue(cid, QUESTLOG.INQUISITION.MISSION_SHADOW_NEXUS)
	
	if(questStatus ~= 1) then
		npcHandler:say('Voc� precisa completar todas as miss�es no combate as for�as demoniacas para que eu possa lhe aben�oar.', cid)
		npcHandler:resetNpc()
		
		return true	
	end

	if(isPlayerPremiumCallback(cid) or not getBooleanFromString(getConfigValue('blessingsOnlyPremium')) or not parameters.premium) then
		local price = parameters.baseCost
		if(getPlayerLevel(cid) > parameters.startLevel) then
			price = (price + ((math.min(parameters.endLevel, getPlayerLevel(cid)) - parameters.startLevel) * parameters.levelCost))
		end
		
		price = (price * 5) * parameters.aditionalCostMultipler

		if(getPlayerBlessing(cid, 1) or getPlayerBlessing(cid, 2) or getPlayerBlessing(cid, 3) or getPlayerBlessing(cid, 4) or getPlayerBlessing(cid, 5)) then
			npcHandler:say("Voc� j� possui uma ou mais ben��es, eu somente posso aben�oar quem n�o foi aben�oado por nenhum Deus.", cid)
		elseif(not doPlayerRemoveMoney(cid, price)) then
			npcHandler:say("Voc� n�o tem dinheiro sulficiente. Em seu level, s�o necessarios " .. price .. " gold coins.", cid)
		else
			npcHandler:say("Voc� recebeu todas as ben��es! Voc� esta completamente protegido!", cid)
			
			doPlayerAddBlessing(cid, 1)
			doPlayerAddBlessing(cid, 2)
			doPlayerAddBlessing(cid, 3)
			doPlayerAddBlessing(cid, 4)
			doPlayerAddBlessing(cid, 5)
		end
	else
		npcHandler:say('Eu somente posso aben�oar jogadores com uma premium account.', cid)
	end

	npcHandler:resetNpc()
	return true
end

function D_CustomNpcModules.addTradeList(shopModule, tradelist_name)

	local list = trade_lists[tradelist_name]
	
	if(list == nil) then
		print("[Warning] D_CustomNpcModules.addTradeList - Trade list with name " .. tradelist_name .. " not found.")
		return
	end	
	
	for k,v in pairs(list) do
	
		local error = false
	
		if(v.name == nil) then
			print("[Warning] D_CustomNpcModules.addTradeList - Invalid item without name found on " .. tradelist_name .. " trade list.")
			error = true
		elseif(v.sell_for == nil and v.buy_for == nil) then
			print("[Warning] D_CustomNpcModules.addTradeList - Item name " .. v.name .. " without buy or sell at " .. tradelist_name .. " trade list.")
			error = true
		end
	
		local itemtype = v.itemtype or getItemIdByName(v.name)
		
		if(not itemtype) then
			print("[Warning] D_CustomNpcModules.addTradeList - Item id not defined and not found by name " .. v.name .. " on " .. tradelist_name .. " trade list.")
		end
	
		if(not error) then
			
			-- lembrando que as fun��es no Jiddo s�o nomeadas da perspectiva do player...
			-- mas por se tratar de um NPC, vamos inverter, e partir da perspectiva deste
					
			if(v.sell_for ~= nil) then
				shopModule:addBuyableItem(nil, itemtype, v.sell_for, v.subtype, v.name)
			end
			
			if(v.buy_for ~= nil) then
				shopModule:addSellableItem(nil, itemtype, v.buy_for, v.name)
			end
		end
	end
end

function D_CustomNpcModules.parseCustomParameters(keywordHandler, npcHandler)
	local trade_lists = NpcSystem.getParameter("use_trade_lists")
	if(trade_lists ~= nil) then
		local shopModule = ShopModule:new()
		npcHandler:addModule(shopModule)
		D_CustomNpcModules.parseTradeLists(shopModule, trade_lists)
	end
	
	local addon_item = NpcSystem.getParameter("call_addon_item")
	if(addon_item ~= nil) then
		local addon_func = ADDON_ITEMS[addon_item]
		addon_func(keywordHandler, npcHandler)		
	end
end

function D_CustomNpcModules.parseTradeLists(shopModule, trade_lists)

	local lists = string.explode(trade_lists, ";")
	
	for k,v in pairs(lists) do
		D_CustomNpcModules.addTradeList(shopModule, v)
	end
end
