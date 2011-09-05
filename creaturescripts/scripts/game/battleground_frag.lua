function onBattlegroundFrag(cid, target)
	doSendAnimatedText(getPlayerPosition(cid), "FRAG!", TEXTCOLOR_DARKRED)
	
	local teams = { [1] = "Time A", [2] = "Time B" }
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") matou " .. getPlayerName(target) .. " (" .. getPlayerLevel(target) .. ") pelo " .. teams[doPlayerGetBattlegroundTeam(cid)] .. "!")
end