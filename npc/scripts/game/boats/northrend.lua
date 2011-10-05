local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- OTServ event handling functions start
function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) 	npcHandler:onCreatureSay(cid, type, msg) end
function onThink() 						npcHandler:onThink() end
-- OTServ event handling functions end
    
boatDestiny.addAracura(keywordHandler, npcHandler)    
boatDestiny.addAaragon(keywordHandler, npcHandler)    
boatDestiny.addQuendor(keywordHandler, npcHandler)      
boatDestiny.addKashmir(keywordHandler, npcHandler)       
boatDestiny.addTrainers(keywordHandler, npcHandler, D_CustomNpcModules.travelTrainingIsland)
boatDestiny.addSeaSerpentArea(keywordHandler, npcHandler)
        
keywordHandler:addKeyword({'passage'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can take you to Aracura, Aaragon, Quendor, Kashmir, and Trainers also some {Hunting Places}.'})
keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I am the captain of this ship.'})
keywordHandler:addKeyword({'travel'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can take you to Aracura, Aaragon, Quendor, and Kashmir also Trainers.'})
keywordHandler:addKeyword({'hunting places', 'hunt'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can take you to the open sea, where you can found the {sea serpent} area.'})

-- Makes sure the npc reacts when you say hi, bye etc.
npcHandler:addModule(FocusModule:new())