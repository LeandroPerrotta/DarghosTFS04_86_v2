function onLeaveChannel(cid, channel, users)

	if(channel == CUSTOM_CHANNEL_PVP) then
		doPlayerSendCancel(cid, "N�o � permitido fechar este canal.")
		return false
	end
	
	return true
end