local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
D_CustomNpcModules.parseCustomParameters(keywordHandler, npcHandler)

function onCreatureAppear(cid)                          npcHandler:onCreatureAppear(cid)                        end
function onCreatureDisappear(cid)                       npcHandler:onCreatureDisappear(cid)                     end
function onCreatureSay(cid, type, msg)                  npcHandler:onCreatureSay(cid, type, msg)                end
function onThink()                                      npcHandler:onThink()                                    end
function onPlayerEndTrade(cid)                          npcHandler:onPlayerEndTrade(cid)                        end
function onPlayerCloseChannel(cid)                      npcHandler:onPlayerCloseChannel(cid)            		end

function greetCallback(cid)

		if(not isPremium(cid)) then
                npcHandler:say('Eu compro uma grande variedade de armas e equipamentos por um bom pre�o! Mas somente negocio com jogadores que disponham de uma Conta Premium...', cid)
				npcHandler:resetNpc(cid)
                return false		
		end

        if(getPlayerBattlegroundRating(cid) < 500) then
                npcHandler:say('Eu compro uma grande variedade de armas e equipamentos por um bom pre�o! Mas somente negocio com bravos guerreiros! Para comprovar seu valor ven�a algumas Battlegrounds ({!bg entrar}) at� atingir 500 pontos de classifica��o e terei prazer em negociar com voc�!', cid)
				npcHandler:resetNpc(cid)
                return false
        else
                return true
        end
end
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setMessage(MESSAGE_GREET, 'Ol� |PLAYERNAME|. O que voc� tem para {trocar} comigo hoje?')

npcHandler:addModule(FocusModule:new())