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
                npcHandler:say('Eu compro uma grande variedade de armas e equipamentos por um bom preço! Mas somente negocio com jogadores que disponham de uma Conta Premium...', cid)
                return false		
		end

        if(pvpBattleground.getPlayerRating(cid) < 500) then
                npcHandler:say('Eu compro uma grande variedade de armas e equipamentos por um bom preço! Mas somente negocio com bravos guerreiros! Para comprovar seu valor faça vença algumas Battlegrounds ({!bg entrar}) até atingir 500 pontos de classificação e terei prazer em negociar com você!', cid)
                return false
        else
                return true
        end
end
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setMessage(MESSAGE_GREET, 'Olá |PLAYERNAME|. O que você tem para {trocar} comigo hoje?')

npcHandler:addModule(FocusModule:new())