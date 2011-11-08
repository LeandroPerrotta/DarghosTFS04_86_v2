local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)


function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onCreatureSay(cid, type, msg) 		npcHandler:onCreatureSay(cid, type, msg) 	end
function onThink() 							npcHandler:onThink() 						end

function process(cid, message, keywords, parameters, node)
	local npcHandler = parameters.npcHandler
	local talkState = parameters.talk_state
	
    if(not npcHandler:isFocused(cid)) then
        return false
    end 
    
    if(talkState == 1) then
    	local lastChangePvp = getPlayerStorageValue(cid, sid.LAST_CHANGE_PVP)
    	
    	if(lastChangePvp ~= -1 and lastChangePvp + (darghos_change_pvp_days_cooldown * 60 * 60 * 24) > os.time()) then
    	
    		local leftDays = math.floor(((lastChangePvp + (darghos_change_pvp_days_cooldown * 60 * 60 * 24)) - os.time()) / 60 / 60 / 24)
    	
    		if(leftDays > 0) then
				npcHandler:say("Você alterou a sua habilidade de entrar em combate a muito pouco tempo! Você deve aguardar por mais " .. leftDays .. " dias para uma nova mudança!", cid)
			else
				npcHandler:say("Em mais algumas horas você poderá alterar a sua habilidade de entrar em combate!", cid)
			end
			
			npcHandler:resetNpc(cid)		
			return false
		else
		
			local debuffExpMsg = nil
		
			if(lastChangePvp ~= -1) then
				debuffExpMsg = "VOCÊ TAMBÉM RECEBERA 50% MENOS EXPERIENCIA PELOS PROXIMOS " .. darghos_change_pvp_days_cooldown .. " DIAS!"
			end
		
			if(doPlayerIsPvpEnable(cid)) then
				npcHandler:say("Você ATUALMENTE está com o seu PVP ATIVO! Ao DESATIVAR O PVP você NÃO PODERA ATACAR OU SER ATACADO POR QUALQUER JOGADOR, exepto quando você estiver participando de uma guild war, arena ou battleground.", cid)
				npcHandler:say("PRESTE MUITA ATENÇÃO!! AO FAZER ESTA MUDANÇA VOCÊ NÃO PODERÁ ATIVAR NOVAMENTE O SEU PVP DE NENHUMA FORMA PELOS PROXIMOS " .. darghos_change_pvp_days_cooldown .. " DIAS!", cid)
				
				if(debuffExpMsg ~= nil) then
					npcHandler:say(debuffExpMsg, cid)
				end
				
				npcHandler:say("VOCÊ TAMBÉM SERÁ LEVADO PARA QUENDOR QUE PASSARÁ A SER A SUA CIDADE!", cid)
				npcHandler:say("VOCÊ TEM CERTEZA QUE DESEJA DESATIVAR O SEU PVP???", cid)
			else
				npcHandler:say("Você ATUALMENTE está com o seu PVP DESATIVO! Ao ATIVAR O PVP você PODERÁ ATACAR, MATAR, SER ATACADO E ATÉ MORTO POR OUTROS JOGADORES QUE TAMBÉM ESTEJAM COM PVP ATIVO!!!", cid)
				npcHandler:say("PRESTE MUITA ATENÇÃO!! AO FAZER ESTA MUDANÇA VOCÊ NÃO PODERÁ DESATIVAR NOVAMENTE O SEU PVP DE NENHUMA FORMA PELOS PROXIMOS " .. darghos_change_pvp_days_cooldown .. " DIAS!", cid)
				
				if(debuffExpMsg ~= nil) then
					npcHandler:say(debuffExpMsg, cid)
				end
				
				npcHandler:say("VOCÊ TAMBÉM SERÁ LEVADO PARA QUENDOR QUE PASSARÁ A SER A SUA CIDADE!", cid)
				npcHandler:say("VOCÊ TEM CERTEZA QUE DESEJA ATIVAR O SEU PVP???", cid)
			end
    	end
    elseif(talkState == 2) then
    	npcHandler:say("NÃO ESTOU SEGURO QUE VOCÊ QUER REALMENTE ISTO!! LEMBRE-SE!! VOCÊ NÃO PODERÁ MUDAR NOVAMENTE SEU PVP NOS PROXIMOS " .. darghos_change_pvp_days_cooldown .. " DIAS!!! TEM CERTEZA??? DIGITE {tenho certeza}!!", cid)
    	npcHandler:say("!!! E SUA ULTIMA CHANCE !!!", cid)
    elseif(talkState == 3) then
    	if(doPlayerIsPvpEnable(cid)) then
    		npcHandler:say("ESTÁ FEITO!! Seu PvP agora está DESATIVADO!! Espero que não se arrependa de sua decisão...", cid)
    		doPlayerDisablePvp(cid)
    	else
    		npcHandler:say("ESTÁ FEITO!! Seu PvP agora está ATIVO!! Espero que não se arrependa de sua decisão...", cid)
    		doPlayerEnablePvp(cid)			
    	end
    	
    	setPlayerStorageValue(cid, sid.LAST_CHANGE_PVP, os.time())
    	setPlayerStorageValue(cid, sid.CHANGE_PVP_EXP_DEBUFF, os.time() + (60 * 60 * 24 * darghos_change_pvp_days_cooldown)) 
    	
    	local oldpos = getPlayerPosition(cid) 	
    	doTeleportThing(cid, getTownTemplePosition(towns.QUENDOR))
    	doPlayerSetTown(cid, towns.QUENDOR)
    	doSendMagicEffect(oldpos, CONST_ME_MAGIC_BLUE)
    	
    	setStageType(cid, SKILL__LEVEL)
    	npcHandler:resetNpc(cid)
    end
    
    return true
end

keywordHandler:addKeyword({'bless', 'benção', 'bencao'}, D_CustomNpcModules.offerBlessing, {npcHandler = npcHandler, onlyFocus = true, ispvp = true, baseCost = 2000, levelCost = 200, startLevel = 30, endLevel = 270})
keywordHandler:addKeyword({'job', 'trabalho', 'ajudar'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Eu ajudo os novatos que passam por aqui. Eu também sou autorizado a abençoar com a {twist of fate}, a benção para o {pvp}.'})
local node = keywordHandler:addKeyword({'pvp'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Foi me concedido pelos Deuses o poder de desligar ou ligar a sua habilidade de entrar em combate com outros jogadores. Você gostaria de fazer está mudança?'})
	local node1 = node:addChildKeyword({'yes', 'sim'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 1})
	node:addChildKeyword({"nao", "não", "no"}, StdModule.say, {npcHandler = npcHandler, reset = true, onlyFocus = true, text = 'Volte se desejar fazer está mudança!'})
		local node2 = node1:addChildKeyword({'yes', 'sim'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 2})
		node1:addChildKeyword({"nao", "não", "no"}, StdModule.say, {npcHandler = npcHandler, reset = true, onlyFocus = true, text = 'Volte se desejar fazer está mudança!'})	
			node2:addChildKeyword({'tenho certeza'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 3})
			node2:addChildKeyword({"nao", "não", "no"}, StdModule.say, {npcHandler = npcHandler, reset = true, onlyFocus = true, text = 'Que bom que desistiu! Eu sabia que você não estava certo que realmente queria isto!!'})	
--local node1 = keywordHandler:addKeyword({'twist of fate'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Sorry, but the bless twist of fate are unavailable for now. Wait some time and back again.'})


npcHandler:addModule(FocusModule:new())
