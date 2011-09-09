function onSay(cid, words, param, channel)

	if(wordsIsSpell(words)) then
		return true
	end

	if(channel == CHANNEL_HELP) then
		return help.onSay(cid, words, param, channel)
	elseif(channel == CUSTOM_CHANNEL_PVP) then
		return pvp.onSay(cid, words, param, channel)
	end
end

pvp = {}

local OUT_BATTLEGROUND_INTERVAL = 60 * 2 -- segundos
local IN_BATTLEGROUND_INTERVAL = 15

function pvp.onSay(cid, words, param, channel)
	
	local lastMessage = getPlayerStorageValue(cid, sid.LAST_PVP_CHANNEL_MESSAGE)
	local isInBattleground = doPlayerIsInBattleground(cid)
	
	if(getPlayerAccess(cid) == ACCESS_PLAYER and lastMessage ~= STORAGE_NULL) then
		if(isInBattleground and lastMessage + IN_BATTLEGROUND_INTERVAL >= os.time()) then
			doPlayerSendCancel(cid, "So é permitido enviar uma mensagem neste canal a cada 15 segundos.")
			return true			
		elseif(not isInBattleground and lastMessage + OUT_BATTLEGROUND_INTERVAL >= os.time()) then
			doPlayerSendCancel(cid, "So é permitido enviar uma mensagem neste canal a cada 2 minutos para jogadores fora da battleground.")
			return true						
		end	
	end
	
	setPlayerStorageValue(cid, sid.LAST_PVP_CHANNEL_MESSAGE, os.time())
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