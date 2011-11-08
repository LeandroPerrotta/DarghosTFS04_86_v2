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
				npcHandler:say("Voc� alterou a sua habilidade de entrar em combate a muito pouco tempo! Voc� deve aguardar por mais " .. leftDays .. " dias para uma nova mudan�a!", cid)
			else
				npcHandler:say("Em mais algumas horas voc� poder� alterar a sua habilidade de entrar em combate!", cid)
			end
			
			npcHandler:resetNpc(cid)		
			return false
		else
		
			local debuffExpMsg = nil
		
			if(lastChangePvp ~= -1) then
				debuffExpMsg = "VOC� TAMB�M RECEBERA 50% MENOS EXPERIENCIA PELOS PROXIMOS " .. darghos_change_pvp_days_cooldown .. " DIAS!"
			end
		
			if(doPlayerIsPvpEnable(cid)) then
				npcHandler:say("Voc� ATUALMENTE est� com o seu PVP ATIVO! Ao DESATIVAR O PVP voc� N�O PODERA ATACAR OU SER ATACADO POR QUALQUER JOGADOR, exepto quando voc� estiver participando de uma guild war, arena ou battleground.", cid)
				npcHandler:say("PRESTE MUITA ATEN��O!! AO FAZER ESTA MUDAN�A VOC� N�O PODER� ATIVAR NOVAMENTE O SEU PVP DE NENHUMA FORMA PELOS PROXIMOS " .. darghos_change_pvp_days_cooldown .. " DIAS!", cid)
				
				if(debuffExpMsg ~= nil) then
					npcHandler:say(debuffExpMsg, cid)
				end
				
				npcHandler:say("VOC� TAMB�M SER� LEVADO PARA QUENDOR QUE PASSAR� A SER A SUA CIDADE!", cid)
				npcHandler:say("VOC� TEM CERTEZA QUE DESEJA DESATIVAR O SEU PVP???", cid)
			else
				npcHandler:say("Voc� ATUALMENTE est� com o seu PVP DESATIVO! Ao ATIVAR O PVP voc� PODER� ATACAR, MATAR, SER ATACADO E AT� MORTO POR OUTROS JOGADORES QUE TAMB�M ESTEJAM COM PVP ATIVO!!!", cid)
				npcHandler:say("PRESTE MUITA ATEN��O!! AO FAZER ESTA MUDAN�A VOC� N�O PODER� DESATIVAR NOVAMENTE O SEU PVP DE NENHUMA FORMA PELOS PROXIMOS " .. darghos_change_pvp_days_cooldown .. " DIAS!", cid)
				
				if(debuffExpMsg ~= nil) then
					npcHandler:say(debuffExpMsg, cid)
				end
				
				npcHandler:say("VOC� TAMB�M SER� LEVADO PARA QUENDOR QUE PASSAR� A SER A SUA CIDADE!", cid)
				npcHandler:say("VOC� TEM CERTEZA QUE DESEJA ATIVAR O SEU PVP???", cid)
			end
    	end
    elseif(talkState == 2) then
    	npcHandler:say("N�O ESTOU SEGURO QUE VOC� QUER REALMENTE ISTO!! LEMBRE-SE!! VOC� N�O PODER� MUDAR NOVAMENTE SEU PVP NOS PROXIMOS " .. darghos_change_pvp_days_cooldown .. " DIAS!!! TEM CERTEZA??? DIGITE {tenho certeza}!!", cid)
    	npcHandler:say("!!! E SUA ULTIMA CHANCE !!!", cid)
    elseif(talkState == 3) then
    	if(doPlayerIsPvpEnable(cid)) then
    		npcHandler:say("EST� FEITO!! Seu PvP agora est� DESATIVADO!! Espero que n�o se arrependa de sua decis�o...", cid)
    		doPlayerDisablePvp(cid)
    	else
    		npcHandler:say("EST� FEITO!! Seu PvP agora est� ATIVO!! Espero que n�o se arrependa de sua decis�o...", cid)
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

keywordHandler:addKeyword({'bless', 'ben��o', 'bencao'}, D_CustomNpcModules.offerBlessing, {npcHandler = npcHandler, onlyFocus = true, ispvp = true, baseCost = 2000, levelCost = 200, startLevel = 30, endLevel = 270})
keywordHandler:addKeyword({'job', 'trabalho', 'ajudar'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Eu ajudo os novatos que passam por aqui. Eu tamb�m sou autorizado a aben�oar com a {twist of fate}, a ben��o para o {pvp}.'})
local node = keywordHandler:addKeyword({'pvp'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Foi me concedido pelos Deuses o poder de desligar ou ligar a sua habilidade de entrar em combate com outros jogadores. Voc� gostaria de fazer est� mudan�a?'})
	local node1 = node:addChildKeyword({'yes', 'sim'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 1})
	node:addChildKeyword({"nao", "n�o", "no"}, StdModule.say, {npcHandler = npcHandler, reset = true, onlyFocus = true, text = 'Volte se desejar fazer est� mudan�a!'})
		local node2 = node1:addChildKeyword({'yes', 'sim'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 2})
		node1:addChildKeyword({"nao", "n�o", "no"}, StdModule.say, {npcHandler = npcHandler, reset = true, onlyFocus = true, text = 'Volte se desejar fazer est� mudan�a!'})	
			node2:addChildKeyword({'tenho certeza'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 3})
			node2:addChildKeyword({"nao", "n�o", "no"}, StdModule.say, {npcHandler = npcHandler, reset = true, onlyFocus = true, text = 'Que bom que desistiu! Eu sabia que voc� n�o estava certo que realmente queria isto!!'})	
--local node1 = keywordHandler:addKeyword({'twist of fate'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Sorry, but the bless twist of fate are unavailable for now. Wait some time and back again.'})


npcHandler:addModule(FocusModule:new())
