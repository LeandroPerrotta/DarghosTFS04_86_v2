-----------
-- BOATS
-----------

boatDestiny = {
	pvpChangedList = {}
}

function boatDestiny.addQuendor(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'quendor'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to quendor for 110 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = false, level = 0, cost = 110, destination = BOAT_DESTINY_QUENDOR })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addAracura(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'aracura'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to aracura for 160 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 160, destination = BOAT_DESTINY_ARACURA, pvpEnabledOnly = true})
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addAaragon(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'aaragon'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to aaragon for 130 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 130, destination = BOAT_DESTINY_AARAGON })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addSalazart(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'salazart'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to salazart for 130 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 130, destination = BOAT_DESTINY_SALAZART })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addNorthrend(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'northrend'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to northrend for 240 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 240, destination = BOAT_DESTINY_NORTHREND })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addKashmir(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'kashmir'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to kashmir for 150 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 150, destination = BOAT_DESTINY_KASHMIR })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addThaun(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'thaun'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to island of thaun for 110 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, level = 0, cost = 110, destination = BOAT_DESTINY_THAUN })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addTrainers(keywordHandler, npcHandler, module)

	module = (module == nil) and D_CustomNpcModules.travelTrainingIsland or module

	local travelNode = keywordHandler:addKeyword({'trainers'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to sail to island of trainers for 190 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = false, level = 0, cost = 40, destination = BOAT_DESTINY_TRAINERS, entering = true })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addSeaSerpentArea(keywordHandler, npcHandler, module)

	module = (module == nil) and StdModule.travel or module

	local travelNode = keywordHandler:addKeyword({'sea serpent', 'sea serpent area'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to be taken to sea serpent area for 800 gold coins?'})
	travelNode:addChildKeyword({'yes'}, module, {npcHandler = npcHandler, premium = true, cost = 800, destination = BOAT_DESTINY_SEA_SERPENT_AREA })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function boatDestiny.addIslandOfPeace(keywordHandler, npcHandler)

	local function onAsk(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if(npcHandler == nil) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
			return false
		end
	
		if(not npcHandler:isFocused(cid)) then
			return false
		end	
		
		if(doPlayerIsPvpEnable(cid)) then
			npcHandler:say('Desculpe, mas você está com o seu pvp ativo... Somente jogadores que estejam com o pvp desativo podem viajar para Island of Peace!', cid)
			npcHandler:resetNpc(cid)
			return false
		end
		
		npcHandler:say('Você gostaria de pagar 200 moedas de ouro pela passagem de volta a tranquilidade de Island of Peace?', cid)
		return true
	end
	
	local function onAccept(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if(npcHandler == nil) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
			return false
		end
	
		if(not npcHandler:isFocused(cid)) then
			return false
		end	
		
		if(not doPlayerRemoveMoney(cid, parameters.cost)) then
			npcHandler:say('Oh, infelizmente você não possui o dinheiro necessario para embarcar...', cid)
			npcHandler:resetNpc(cid)
			return true
		end	
		
		npcHandler:say('Seja bem vindo de volta a Island of Peace caro ' .. getPlayerName(cid) .. '!', cid)
		doTeleportThing(cid, parameters.destination, false)
		doSendMagicEffect(parameters.destination, CONST_ME_TELEPORT)		
		return true
	end

	local travelNode = keywordHandler:addKeyword({'island of peace', 'isle of peace'}, onAsk, {npcHandler = npcHandler, onlyFocus = true})
	travelNode:addChildKeyword({'yes', 'sim'}, onAccept, {npcHandler = npcHandler, cost = 200, destination = BOAT_DESTINY_ISLAND_OF_PEACE })
	travelNode:addChildKeyword({'no', 'não', 'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Mas que pena... Mas tenha um bom dia!!'})
end

function boatDestiny.addQuendorFromIslandOfPeace(keywordHandler, npcHandler)

	local function onAsk(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if(npcHandler == nil) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
			return false
		end
	
		if(not npcHandler:isFocused(cid)) then
			return false
		end	
		
		local leaveFromIslandOfPeace = getPlayerStorageValue(cid, sid.LEAVE_FROM_ISLAND_OF_PEACE)
		
		if(leaveFromIslandOfPeace == -1) then
			if(getConfigInfo("worldId") == WORLD_ORDON) then
				npcHandler:say('Vejo que você nunca viajou para Quendor, este barco pode levar-lo para lá, por ser sua primeira viagem, não lhe será cobrado nada, porém saiba que fora de Island of Peace você poderá ativar ou desativar <...>', cid)
				npcHandler:say('a habilidade de entrar em combate com outros jogadores, isto é, seu pvp. Inicialmente o seu pvp está desativado, caso você deseje o ativar converse com o NPC\'s que ficam no templo de todas cidades. <...>', cid)
				npcHandler:say('Saiba também que somente é permitido voltar para Island of Peace jogadores que estiverem com seu pvp desativado, se você o ativar-lo, não poderá voltar. <...>', cid)			
				npcHandler:say('E então, deseja mesmo embarcar para Quendor?', cid)
			else
				npcHandler:say('Quendor é uma maravilhosa cidade! Mais saiba que por lá e por todo o resto do mundo do Darghos o seu PvP e de todos outras é sempre ativo, assim você poderá  <...>', cid)
				npcHandler:say('atacar e ser atacado por outras pessoas... Também esteja ciente que uma vez abandonando esta ilha você se tornará cidadão de Quendor não será mais possivel retornar <...>', cid)
				npcHandler:say('E então, deseja mesmo embarcar para Quendor?', cid)				
			end
			return true
		end		
		
		npcHandler:say('Você gostaria de pagar 200 moedas de ouro para viajar para Quendor?', cid)
		return true
	end
	
	local function onAccept(cid, message, keywords, parameters, node)
		local npcHandler = parameters.npcHandler
		if(npcHandler == nil) then
			print('[Warning - ' .. getCreatureName(getNpcId()) .. '] NpcSystem:', 'StdModule.travel - Call without any npcHandler instance.')
			return false
		end
	
		if(not npcHandler:isFocused(cid)) then
			return false
		end	
		
		local leaveFromIslandOfPeace = getPlayerStorageValue(cid, sid.LEAVE_FROM_ISLAND_OF_PEACE)
		
		if(isInArray({0, 1}, leaveFromIslandOfPeace) and not doPlayerRemoveMoney(cid, parameters.cost)) then
			npcHandler:say('Oh, infelizmente você não possui o dinheiro necessario para embarcar...', cid)
			npcHandler:resetNpc(cid)
			return true
		end	
		
		if(leaveFromIslandOfPeace == -1) then
			npcHandler:say('Seja bem vindo a Quendor caro ' .. getPlayerName(cid) .. '! Para chegar na cidade, siga para o sul e tenha cuidado com as criatura!', cid)		
			setPlayerStorageValue(cid, sid.LEAVE_FROM_ISLAND_OF_PEACE, 1)
		else		
			npcHandler:say('Seja bem vindo de volta a Quendor caro ' .. getPlayerName(cid) .. '!', cid)
		end
		
		if(getConfigInfo("worldId") == WORLD_AARAGON) then
			doPlayerSetTown(cid, towns.QUENDOR)
			doPlayerEnablePvp(cid)
			setStageOnChangePvp(cid)
		end
		
		doTeleportThing(cid, parameters.destination, false)
		doSendMagicEffect(parameters.destination, CONST_ME_TELEPORT)		
		return true
	end

	local travelNode = keywordHandler:addKeyword({'quendor'}, onAsk, {npcHandler = npcHandler, onlyFocus = true})
	travelNode:addChildKeyword({'yes', 'sim'}, onAccept, {npcHandler = npcHandler, cost = 200, destination = BOAT_DESTINY_QUENDOR })
	travelNode:addChildKeyword({'no', 'não', 'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Mas que pena... Mas tenha um bom dia!!'})
end

-----------
-- CARPETS
-----------

carpetDestiny = {}

function carpetDestiny.addAaragon(keywordHandler, npcHandler)

	local travelNode = keywordHandler:addKeyword({'aaragon'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to fly in my magic carpet to Aaragon for 60 gold coins?'})
	travelNode:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = true, level = 0, cost = 60, destination = CARPET_DESTINY_AARAGON })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function carpetDestiny.addHills(keywordHandler, npcHandler)

	local travelNode = keywordHandler:addKeyword({'hills'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to fly in my magic carpet to Hills for 60 gold coins?'})
	travelNode:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = true, level = 0, cost = 60, destination = CARPET_DESTINY_HILLS })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function carpetDestiny.addSalazart(keywordHandler, npcHandler)

	local travelNode = keywordHandler:addKeyword({'salazart'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to fly in my magic carpet to Salazart for 40 gold coins?'})
	travelNode:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = true, level = 0, cost = 40, destination = CARPET_DESTINY_SALAZART })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

-----------
-- TRAINS
-----------

trainDestiny = {}

function trainDestiny.addQuendor(keywordHandler, npcHandler)

	local travelNode = keywordHandler:addKeyword({'quendor'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to board in this train to Quendor for 330 gold coins?'})
	travelNode:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = true, level = 0, cost = 330, destination = TRAIN_DESTINY_QUENDOR })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

function trainDestiny.addThorn(keywordHandler, npcHandler)

	local travelNode = keywordHandler:addKeyword({'thorn'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to board in this train to Quendor for 270 gold coins?'})
	travelNode:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = true, level = 0, cost = 270, destination = TRAIN_DESTINY_THORN })
	travelNode:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Then stay here!'})
end

