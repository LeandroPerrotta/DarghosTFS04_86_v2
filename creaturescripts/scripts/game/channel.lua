function onLeaveChannel(cid, channel, users)

	if(channel == CUSTOM_CHANNEL_PVP) then
		doPlayerSendCancel(cid, "N�o � permitido fechar este canal.")
		addEvent(doPlayerOpenChannel, 150, cid, CUSTOM_CHANNEL_PVP)
		return true
	end
	
	return true
end