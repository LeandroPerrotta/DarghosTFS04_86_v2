local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)


function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onCreatureSay(cid, type, msg) 		npcHandler:onCreatureSay(cid, type, msg) 	end
function onThink() 							npcHandler:onThink() 						end

local node1 = keywordHandler:addKeyword({'twist of fate', 'pvp bless'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Saiba que a benção do PvP (twist of fate) não irá reduzir a penalidade quando você morre como as benções normais, mas ao invez disto, irá previnir que você perca as proprias benções normais quando você for derrotado por outro jogador (apénas jogadores!). Você quer receber esta proteção pelo sacrificio de 2000 moedas de ouro mais 100 moedas adicionais por cada level entre o 30 e 120?'})
	node1:addChildKeyword({'yes', 'sim'}, D_CustomNpcModules.pvpBless, {npcHandler = npcHandler, baseCost = 2000, levelCost = 100, startLevel = 30, endLevel = 120})
	node1:addChildKeyword({'no', 'não', 'nao'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Posso lhe ajudar em algo mais?'})

--local node1 = keywordHandler:addKeyword({'twist of fate'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Sorry, but the bless twist of fate are unavailable for now. Wait some time and back again.'})


npcHandler:addModule(FocusModule:new())
