function onSay(cid, words, param)

	if(param == "join") then
		instancePvpArena:addPlayer(cid)
	elseif(param == "leave") then
	elseif(param == "ready") then
		instancePvpArena:onPlayerReady(cid)
	else
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa digitar um parametro, as opções são:")
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "!pvp join -> Entra na fila para começar uma arena.")
		--doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "!pvp leave -> Abandona a fila para a arena. Se a batalha ja estiver em andamento você irá a abandonar porem contará como uma derrota.")
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "!pvp ready -> Usado após esperar na fila para te levar a arena, quando chegar a vez de sua participação.")
		doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)		
	end
		
	return TRUE
end
