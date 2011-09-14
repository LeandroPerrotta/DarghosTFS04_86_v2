local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)


function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onCreatureSay(cid, type, msg) 		npcHandler:onCreatureSay(cid, type, msg) 	end
function onThink() 							npcHandler:onThink() 						end

local node1 = keywordHandler:addKeyword({'twist of fate', 'pvp bless'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Saiba que a ben��o do PvP (twist of fate) n�o ir� reduzir a penalidade quando voc� morre como as ben��es normais, mas ao invez disto, ir� previnir que voc� perca as proprias ben��es normais quando voc� for derrotado por outro jogador (ap�nas jogadores!). Voc� quer receber esta prote��o pelo sacrificio de 2000 moedas de ouro mais 100 moedas adicionais por cada level entre o 30 e 120?'})
	node1:addChildKeyword({'yes', 'sim'}, D_CustomNpcModules.pvpBless, {npcHandler = npcHandler, baseCost = 2000, levelCost = 100, startLevel = 30, endLevel = 120})
	node1:addChildKeyword({'no', 'n�o', 'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Posso lhe ajudar em algo mais?'})

--local node1 = keywordHandler:addKeyword({'twist of fate'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Sorry, but the bless twist of fate are unavailable for now. Wait some time and back again.'})


npcHandler:addModule(FocusModule:new())
