function onSay(cid, words, param, channel)

	if(wordsIsSpell(words .. " " .. param)) then
		return false
	end

	if(channel == CHANNEL_HELP) then
		return help.onSay(cid, words, param, channel)
	elseif(channel == CUSTOM_CHANNEL_PVP) then
		return pvp.onSay(cid, words, param, channel)
	end
end

pvp = {}

function pvp.onSay(cid, words, param, channel)
	
	if(getPlayerAccess(cid) == ACCESS_PLAYER) then
		if(pvpBattleground.playerSpeakTeam(cid, words .. " " .. param)) then
			return true			
		else
			doPlayerSendCancel(cid, "Não é permitido a jogadores fora da battleground enviarem mensagens por este canal.")
			return true
		end	
	end

	return false
end

help = {}

local HELP_EXHAUSTED = 15 -- segundos

function help.onSay(cid, words, param, channel)
	
	local banExpires = getPlayerStorageValue(cid, sid.BANNED_IN_HELP)
	local lastMessage = getPlayerStorageValue(cid, sid.LAST_HELP_MESSAGE)
	
	if(getPlayerAccess(cid) == ACCESS_PLAYER and lastMessage ~= STORAGE_NULL and lastMessage + HELP_EXHAUSTED >= os.time()) then
		doPlayerSendCancel(cid, "So é permitido enviar uma mensagem neste canal a cada 15 segundos.")
		return true	
	end
	
	if(banExpires ~= STORAGE_NULL and banExpires >= os.time()) then
		doPlayerSendCancel(cid, "Você foi proibido de enviar mensagens no help channel até " .. os.date("%d/%m/%Y - %X", banExpires) .. " devido uma conduta inaceitavel recente.")
		return true
	else
		setPlayerStorageValue(cid, sid.LAST_HELP_MESSAGE, os.time())
	end

	return false
end