local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)        end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)        end
function onCreatureSay(cid, type, msg)        npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                npcHandler:onThink()                end

REQUIRED_POINTS = 20

function process(cid, message, keywords, parameters, node)
	
	local npcHandler = parameters.npcHandler
	local talkState = parameters.talk_state
	
    if(not npcHandler:isFocused(cid)) then
        return false
    end

	if(talkState == 1) then
		local active = (getPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_ACTIVE) == 1) and true or false
		
		if(active) then
			local points = getPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_POINTS)
					
			if(points >= REQUIRED_POINTS) then
				npcHandler:say("Vejo que concluiu a sua tarefa! Agora Quendor conta com um guerreiro um pouco mais preparado para enfrentar seus desafios! Tome a sua recompensa! Retorne amanha se desejar continuar o preparo!", cid)
				
				setPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_LAST, getWeekday())
				setPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_ACTIVE, -1)
				setPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_POINTS, -1)
				
				local totalExp = getPlayerExperience(cid)
				local expAdd = math.floor(totalExp * 0.02)
				doPlayerAddExperience(cid, expAdd)
				local moneyAdd = rand(90000, 320000)
				doPlayerAddMoney(cid, moneyAdd)
				
				doPlayerSendTextMessage(self.cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você adquiriu " .. expAdd .. " pontos de expêriencia e " .. moneyAdd .. " gold coins por concluir a tarefa.")
			else
				npcHandler:say("Você ainda não atingiu os 20 pontos! Não demore a completar sua missão! Quendor precisa de bravos guerreiros!", cid)
				npcHandler:resetNpc()
			end	
		else
			npcHandler:say("Ordon espera que os soldados estejam sempre preparados para defender Quendor de seus inimigos. Por isso ele ordena que os guerreiros que treinarem diariamente na Battleground sejam recompensados. Você quer iniciar este treinamento?", cid)
		end
	elseif(talkState == 2) then
	    local dailyStatus = getPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_LAST)
	    
	    if(dailyStatus ~= -1 and getWeekday() == dailyStatus) then
	    	npcHandler:say("Você já concluiu o seu treinamento por hoje, você somente pode fazer-lo novamente amanha! Até lá!", cid)
	    	npcHandler:resetNpc()
    	else
    		npcHandler:say("A tarefa que lhe solicito é a seguinte: Vá para o campo de batalhas, o Battleground, e ganhe pontos, os pontos serão obtidos quando você derrota um jogador que não seja muito mais fraco que você, para cada vez que você for derrotado também irá perder um ponto! Você precisará atingir 20 pontos. E então, a aceita?", cid)
	    end
    elseif(talkState == 3) then
		
		npcHandler:say("Perfeito, retorne quando a tiver concluido, estarei o aguardando!", cid)
		setPlayerStorageValue(cid, sid.DAILY_BATTLEGROUND_ACTIVE, 1)
    	npcHandler:resetNpc()		
    end
    
    return true
end

local node1 = keywordHandler:addKeyword({'task', 'mission', 'tarefa', 'missão', 'missao'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 1})
    local node2 = node1:addChildKeyword({'yes', 'sim'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 2})
    node2:addChildKeyword({'yes', 'sim'}, process, {npcHandler = npcHandler, onlyFocus = true, talk_state = 3})   
    node2:addChildKeyword({'no', 'não', 'não'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Volte quando estiver preparado para seu treinamento.', reset = true})
    
    node1:addChildKeyword({'no', 'não', 'não'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Volte quando estiver preparado para seu treinamento.', reset = true})


npcHandler:addModule(FocusModule:new())
