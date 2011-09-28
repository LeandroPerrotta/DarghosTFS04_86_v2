BROADCAST_STATISTICS_INTERVAL = 20

BG_RET_NO_ERROR = 0
BG_RET_CLOSED = 1
BG_RET_CAN_NOT_JOIN = 2
BG_RET_PUT_IN_WAITLIST = 3
BG_RET_PUT_INSIDE = 4
BG_RET_ALREADY_IN_WAITLIST = 5
BG_RET_INFIGHT = 6

BATTLEGROUND_TEAM_NONE = 0
BATTLEGROUND_TEAM_ONE = 1
BATTLEGROUND_TEAM_TWO = 2

pvpBattleground = {

}

function pvpBattleground.onInit()
	addEvent(pvpBattleground.broadcastStatistics, 1000 * 60 * BROADCAST_STATISTICS_INTERVAL)
end

function pvpBattleground.close()
	battlegroundClose()
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] Battleground temporareamente fechada. Voltará em alguns instantes.", TALKTYPE_TYPES["channel-red"])
end

function pvpBattleground.showResult(cid, winnner)

	clear = clear or true

	local teams = { "Time A", "Time B" }
	
	local msg = "Vencedor: EMPATE!\n\n";
	
	if(winnner ~= BATTLEGROUND_TEAM_NONE) then
		msg = "Vencedor: " .. teams[winnner] .. "\n\n";
	end
	
	local data = getBattlegroundStatistics()
	
	local i = 1
	for k,v in pairs(data) do
		
		local cid = getPlayerByGUID(v.player_id)
		if(cid ~= nil) then
			
			local team = teams[doPlayerGetBattlegroundTeam(cid)]
			
			if(team == nil) then
				team = "Fora"
			end
			
			local spaces_c = 40 - string.len(getPlayerName(cid)) - string.len(team)
			
			local spaces = ""	
			for i=1, spaces_c do spaces = spaces .. " " end
					
			msg = msg .. i .. "# " .. getPlayerName(cid) .. " (" .. team .. ")".. spaces .. "" .. v.kills .. " / " .. v.deaths .. "  [" .. v.assists .. "] \n"	
			i = i + 1
		end
	end
	
	doPlayerPopupFYI(cid, msg)
end

function pvpBattleground.getInformations()
	local msg = ""
	msg = msg .. "Este é um sistema de Hardcore PvP do Darghos, e o objetivo é matar o maximo e morrer o minimo!\n"
	msg = msg .. "Ao morrer você não perderá nada e nascera na base de seu time. Dentro da Battleground os danos são mais efetivos contra inimigos (100%) e diminuidos em aliados (25%)!\n"
	msg = msg .. "De 20 em 20 minutos é exibido um relatorio para todos os jogadores online mostrando os jogadores com melhor desempenho na Battleground. Prepare-se e seja o melhor!\n"

	return msg
end

function pvpBattleground.getPlayersTeamString(team_id)
	team_id = tonumber(team_id)
	local playersTeam = getBattlegroundPlayersByTeam(team_id)
	local teams = {[1] = "Time A", [2] = "Time B"}
	local msg = "Membros do " .. teams[team_id] .. " (comando \"!bg team\"):\n"
	
	if(playersTeam == nil or #playersTeam == 0) then return msg .. "Nenhum" end
	
	local islast = false
	for k,v in pairs(playersTeam) do
		
		if(#playersTeam == k) then
			islast = true
		end
		
		local player = getPlayerByGUID(v)
		
		if(player) then
			msg = msg .. getPlayerName(player) .. " (" .. getPlayerLevel(player) .. ")"
			msg = msg .. ((islast) and ".\n" or ", ")
		end
	end
	
	return msg
end

function pvpBattleground.sendPlayerChannelMessage(cid, msg, type)

	type = (type ~= nil) and type or TALKTYPE_TYPES["channel-white"]
	doPlayerSendChannelMessage(cid, "", msg, type, CUSTOM_CHANNEL_PVP)
end

function pvpBattleground.onEnter(cid)

	if(not isPlayer(cid)) then
		return false
	end

	if(getCreatureCondition(cid, CONDITION_OUTFIT)) then
		doPlayerSendCancel(cid, "Você não pode entrar na battleground enquanto estiver sob certos efeitos magicos.")
		return false
	end

	local ret = doPlayerJoinBattleground(cid)

	if(ret == BG_RET_CLOSED) then
		doPlayerSendCancel(cid, "A battleground está temporareamente fechada.")	
		return false
	end

	if(ret == BG_RET_CAN_NOT_JOIN) then
		doPlayerSendCancel(cid, "Você abandonou uma battleground e foi marcado como desertor, e não poderá entrar em outra durante 10 minutos.")
		return false
	end	
	
	if(ret == BG_RET_ALREADY_IN_WAITLIST) then
		doPlayerSendCancel(cid, "Você já se encontra na fila para a battleground!")
		return false	
	end
	
	if(ret == BG_RET_INFIGHT) then
		doPlayerSendCancel(cid, "Você está em condição de batalha, aguarde sair a condição e tente novamente.")
		return false
	end
		
	if(ret == BG_RET_PUT_IN_WAITLIST) then
		broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") aguarda por uma battleground. Quer participar? Digite '!bg entrar'.")	
		return true
	elseif(ret == BG_RET_PUT_INSIDE) then
		lockTeleportScroll(cid)
		registerCreatureEvent(cid, "OnChangeOutfit")
	
		local teams = { [1] = "Time A", [2] = "Time B" }
		local team = teams[doPlayerGetBattlegroundTeam(cid)]
		
		registerCreatureEvent(cid, "onBattlegroundFrag")
		registerCreatureEvent(cid, "onBattlegroundEnd")
		registerCreatureEvent(cid, "onBattlegroundLeave")
		
		local msg = "Bem vindo ao sistema de Battleground do Darghos!\n"
		
		local isFirstBattleground = getPlayerStorageValue(cid, sid.FIRST_BATTLEGROUND)		
		if(isFirstBattleground == -1) then
			msg = msg .. pvpBattleground.getInformations()
			pvpBattleground.sendPlayerChannelMessage(cid, msg)
			msg = ""
			setPlayerStorageValue(cid, sid.FIRST_BATTLEGROUND, 1)	
		end
		
		msg = msg .. pvpBattleground.getPlayersTeamString(doPlayerGetBattlegroundTeam(cid))
		msg = msg .. "\nDivirta-se!"
		
		pvpBattleground.sendPlayerChannelMessage(cid, msg)
		--broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") juntou-se a batalha pelo " .. team .. ".")	
		return true
	end
	
	return false
end

function pvpBattleground.onExit(cid)

	local ret = doPlayerLeaveBattleground(cid)

	if(ret == BG_RET_NO_ERROR) then
		broadcastChannel(CUSTOM_CHANNEL_PVP, "[Battleground] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") abandonou a batalha.")		
		return true
	end
	
	return false	
end