local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)                  npcHandler:onCreatureAppear(cid)                        end
function onCreatureDisappear(cid)               npcHandler:onCreatureDisappear(cid)                     end
function onCreatureSay(cid, type, msg)          npcHandler:onCreatureSay(cid, type, msg)                end
function onThink()                              npcHandler:onThink()                                    end

function saySpecialPermission(cid, message, keywords, parameters, node)

	local npcHandler = parameters.npcHandler
	local talkState = parameters.talk_state

    if(not npcHandler:isFocused(cid)) then
        return false
    end 
    
    local lastChangePvp = getPlayerStorageValue(cid, sid.LAST_CHANGE_PVP)
    
     if(talkState == 1) then 	
        	if(lastChangePvp ~= -1 and lastChangePvp + (darghos_change_pvp_days_cooldown * 60 * 60 * 24) > os.time()) then
    	
	    		local leftDays = math.floor(((lastChangePvp + (darghos_change_pvp_days_cooldown * 60 * 60 * 24)) - os.time()) / 60 / 60 / 24)
	    	
	    		if(leftDays > 0 and leftDays < darghos_change_pvp_days_cooldown - darghos_change_pvp_premdays_cooldown) then
    				npcHandler:say("Eu posso lhe conceder a permiss�o de uma unica mudan�a de PvP mais curta, que pode ser feita a cada 10 dias, assim voc� poder� imediatamente trocar seu PvP com os funcionarios dos templos, e mais! Voc� gostaria de obter esta permiss�o?", cid)
					node:addChildKeyword({'sim', 'yes'}, saySpecialPermission, {npcHandler = npcHandler, onlyFocus = true, talk_state = 2})
					node:addChildKeyword({'n�o', 'nao', 'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Tudo bem, volte se mudar de ideia!', reset = true})
					return true
				else
					npcHandler:say("Eu posso lhe conceder a permiss�o de uma unica mudan�a de PvP mais curta, que pode ser feita a cada 10 dias, por�m ainda n�o se passaram 10 dias desde a sua ultima mudan�a... ", cid)
				end
			else
				npcHandler:say("Ora! Voc� est� livre para fazer uma nova mudan�a de PvP, voc� n�o precisa de minha permiss�o especial!", cid)
			end
	 elseif(talkState == 2) then
	 	npcHandler:say("Saiba que est� permiss�o tem um grande custo! Para obter-la voc� precisar� sacrificar " .. darghos_change_pvp_premdays_cost .. " dias de sua Conta Premium, voc� tem certeza que quer isto mesmo??", cid)
     	node:addChildKeyword({'sim', 'yes'}, saySpecialPermission, {npcHandler = npcHandler, onlyFocus = true, talk_state = 3})
     	node:addChildKeyword({'n�o', 'nao', 'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Uhmm, prefere pensar melhor? Me procure se mudar de ideia', reset = true})
     	return true
	 elseif(talkState == 3) then
	 	if(isPremium(cid) and getPlayerPremiumDays(cid) >= darghos_change_pvp_premdays_cost) then
		 	npcHandler:say("VOC� TEM CERTEZA DISTO? VOC� DESEJA PERDER " .. darghos_change_pvp_premdays_cost .. " DIAS DE SUA CONTA PREMIUM EM TROCA DE MINHA PERMISS�O ESPECIAL DE MUDAN�A DE PVP??", cid)
	     	node:addChildKeyword({'sim', 'yes'}, saySpecialPermission, {npcHandler = npcHandler, onlyFocus = true, talk_state = 4})
	     	node:addChildKeyword({'n�o', 'nao', 'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Eu sabia que n�o estava completamente certo disto!!', reset = true})
	     	return true     	
     	else
     		npcHandler:say("Desculpe, voc� n�o possui os " .. darghos_change_pvp_premdays_cost .. " dias de Conta Premium necess�rios para este sacrificio...", cid)
     	end
 	 elseif(talkState == 4) then
 	 	setPlayerStorageValue(cid, sid.CHANGE_PVP_PERMISSION, 1)
 	 	doPlayerAddPremiumDays(cid, -darghos_change_pvp_premdays_cost)
 	 	changeLog.onBuySpecialPermission(cid)
	 	npcHandler:say("FEITO! Voc� abriu m�o de " .. darghos_change_pvp_premdays_cost .. " dias de sua conta premium em troca de minha permiss�o especial! Agora voc� pode falar com o funcion�rio do templo e ele n�o ir� negar seu pedido de mudan�a de PvP!!", cid)
     end

	npcHandler:resetNpc(cid)		
	return true 
end

function sayPunishment(cid, message, keywords, parameters, node)
	local npcHandler = parameters.npcHandler
	local talkState = parameters.talk_state

    if(not npcHandler:isFocused(cid)) then
        return false
    end 
    
    local changePvpDebuffExpire = getPlayerStorageValue(cid, sid.CHANGE_PVP_EXP_DEBUFF)
    
    if(changePvpDebuffExpire == nil or changePvpDebuffExpire < os.time()) then
    	npcHandler:say("Voc� n�o est� sob o efeito desta penalidade!", cid)
    	npcHandler:resetNpc(cid)		
    	return false
    end
    
    if(not isPremium(cid)) then
     	npcHandler:say("Isto so � permitido a jogadores com uma conta premium...", cid)
    	npcHandler:resetNpc(cid)		
    	return false       
    end
    
    if(getPlayerPremiumDays(cid) < darghos_remove_change_pvp_debuff_cost) then
     	npcHandler:say("Para a remo��o desta penalidade voc� precisar� sacrificar " .. darghos_remove_change_pvp_debuff_cost .. " dias de sua conta premium, na qual voc� n�o possui!", cid)
    	npcHandler:resetNpc(cid)		
    	return false   
    end
    
    doPlayerAddPremiumDays(cid, -darghos_remove_change_pvp_debuff_cost)
    setPlayerStorageValue(cid, sid.CHANGE_PVP_EXP_DEBUFF, 0)
    setStageType(cid, SKILL__LEVEL)
    changeLog.onCleanExpDebuff(cid)
    npcHandler:say("Esta feito! Voc� n�o esta mais sob o efeito da penalidade de redu��o de experiencia ganha!", cid)
    return true
end

keywordHandler:addKeyword({'permiss�o especial', 'permissao especial'}, saySpecialPermission, {npcHandler = npcHandler, onlyFocus = true, talk_state = 1})

local node4 = keywordHandler:addKeyword({'puni��o', 'punicao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Ap�s uma mudan�a de PvP voc� fica sob o efeito da puni��o que reduz a experiencia obtida em 50%. Com os poderes concedidos a mim eu posso remover este efeito, POREM AO CUSTO DE ' .. darghos_remove_change_pvp_debuff_cost .. ' DIAS DE SUA CONTA PREMIUM! Voc� gostaria?'})
				node4:addChildKeyword({'sim', 'yes'}, sayPunishment, {npcHandler = npcHandler, onlyFocus = true})
				node4:addChildKeyword({'n�o', 'nao', 'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = "Ok, em que mais posso lhe ajudar?", reset = true})

local node5 = keywordHandler:addKeyword({'promotion'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can promote you for 20000 gold coins. Do you want me to promote you?'})
        node5:addChildKeyword({'yes'}, StdModule.promotePlayer, {npcHandler = npcHandler, premium = true, cost = 20000, level = 20, promotion = 1, text = 'Congratulations! You are now promoted.'})
        node5:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Alright then, come back when you are ready.', reset = true})

keywordHandler:addKeyword({'ajuda', 'ajudar'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'A jogadores que j� tiverem atingido level 20 e possuirem uma Conta Premium eu posso conceder a {promo��o}! Tamb�m foi me dado alguns poderes especiais para auxiliar jogadores pacificos ou agressivos que mudaram o {pvp}.'})
keywordHandler:addKeyword({'pvp'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Se voc� tiver mudado o seu PvP e tiver se arrependido, eu posso lhe conceder a {permiss�o especial}, com ela, os funcionarios dos templos n�o ir�o recusar uma nova mudan�a de pvp. Apos uma mudan�a os jogadores ficam sob efeito de {puni��o}, que eu tamb�m posso cancelar.'})

npcHandler:addModule(FocusModule:new())