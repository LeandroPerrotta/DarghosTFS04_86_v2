local OUT_BATTLEGROUND_INTERVAL = 60 * 2 -- segundos
local IN_BATTLEGROUND_INTERVAL = 15

function onSay(cid, words, param, channel)
	
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
	
	setPlayerStorageValue(cid, sid.LAST_HELP_MESSAGE, os.time())
	return false
end