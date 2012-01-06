function onSay(cid, words, param)

	local _access = getPlayerAccess(cid)

	if(param == "") then
	
		local msg = "O uso deste comando requer um ou mais parametros. Exemplos:\n"
		msg = msg .. "!bg sobre, !bg info, !bg help -> Exibe informações sobre o sistema de Battlegrounds.\n"
	
		if(_access >= access.COMMUNITY_MANAGER) then
			msg = msg .. "!bg team team_id -> Exibe as informações de um time (1 ou 2).\n"
			msg = msg .. "!bg close -> Expulsa todos jogadores na battleground e a fecha.\n"
			msg = msg .. "!bg open -> Permite que jogadores entrem na battleground.\n"
			msg = msg .. "!bg ban [name, type, reason] -> Aplica uma banição a um determinado jogador (ou sua conta).\n"
			--msg = msg .. "!bg unban [name, type] -> Remove uma banição ao jogador (ou sua conta).\n"
		else
			msg = msg .. "!bg entrar, !bg join, !bg enter -> Entra em uma battleground (se disponivel) ou coloca na fila de espera.\n"
			msg = msg .. "!bg stats -> Exibe as estatisticas da partida.*\n"
			msg = msg .. "!bg team -> Exibe os membros de seu time.*\n"
			msg = msg .. "!bg afk [nick] -> Denúncia um jogador de seu time que esteja inativo.*\n"
			msg = msg .. "!bg spells -> Exibe as magias extra disponiveis na Battleground"	
		end
	
		msg = msg .. "\n * = Requer estar dentro de uma partida."	
	
		pvpBattleground.sendPlayerChannelMessage(cid, msg)
		return TRUE
	end
	
	local explode = string.explode(param, " ", 1)
	
	option = explode[1]
	param = explode[2] or nil
	
	msg = ""
	
	if(isInArray({"info", "sobre", "help"}, option)) then	
		doShowTextDialog(cid, 2390, pvpBattleground.getInformations())
	elseif(isInArray({"entrar", "join", "enter"}, option)) then		
		pvpBattleground.onEnter(cid)
		return true
	elseif(option == "afk") then
		local pid = getPlayerByNameWildcard(param)
		local error = false
		
		if(not doPlayerIsInBattleground(cid) and _access < access.COMMUNITY_MANAGER) then
			msg = msg .. "Para usar o comando \"!bg afk\" É preciso estar dentro de uma Battleground."
			error = true
		end		
		
		if(not error and not pid) then
			msg = msg .. "Nenhum jogador " .. param .. " encontrado."
			error = true
		end
		
		if(not error) then
			pvpBattleground.onReportIdle(cid, pid)
		end			
	elseif(option == "team") then
	
		local team = nil 
		local error = false
		
		if(not doPlayerIsInBattleground(cid) and _access < access.COMMUNITY_MANAGER) then
			msg = msg .. "Para usar o comando \"!bg team\" É preciso estar dentro de uma Battleground."
			error = true
		end
		
		if not error then
			team = getPlayerBattlegroundTeam(cid)
		end
	
		if(_access >= access.COMMUNITY_MANAGER and isInArray({1, 2}, param)) then
			error = false
			team = param
		end
		
		if(not error) then
			msg = msg .. pvpBattleground.getPlayersTeamString(team)
		end
	elseif(option == "close" and _access >= access.COMMUNITY_MANAGER) then
		msg = msg .. "Battleground fechada."
		pvpBattleground.close()
	elseif(option == "open" and _access >= access.COMMUNITY_MANAGER) then
		msg = msg .. "Battleground aberta."
		battlegroundOpen()	
	elseif(option == "ban" and _access >= access.COMMUNITY_MANAGER) then
		
		local error = false
		param = string.explode(param, ",")
		
		if(#param ~= 3) then
			error = true
			msg = "Formato invalido, certifique de digitar o comando corretamente."
		end
		
		local target, typeStr, reason = getPlayerGUIDByName(string.trim(param[1])), string.trim(param[2]), string.trim(param[3])
		if(not target) then
			error = true
			msg = msg .. "Nenhum jogador de nome " .. param[1] " encontrado."
		end
		
		local banTypes = {
			{
				{"a", "acc", "account"}, BATTLEGROUND_BAN_TYPE_ACCOUNT
			},
			{
				{"p", "player"}, BATTLEGROUND_BAN_TYPE_PLAYER
			}
		}
		
		local banType = nil
		
		if(not error) then		
			for k,v in pairs(banTypes) do
				if(isInArray(v[1], typeStr)) then
					banType = v[2]
				end
			end
			
			if(not banType) then
				error = true
				msg = "Tipo de banição (" .. typeStr .. ") incorreto."
			end	
		end
		
		if(not error) then
			pvpBattleground.addPlayerBan(getPlayerAccountIdByName(param[1]), target, banType, reason, cid)
			msg = msg .. "O jogador " .. param[1] .. " foi punido com sucesso!"
		end
		
	elseif(option == "stats") then

		local error = false
		
		if(not doPlayerIsInBattleground(cid)) then
			msg = msg .. "Para usar o comando \"!bg stats\" É preciso estar dentro de uma Battleground."
			error = true
		end		
		
		if(not error) then
			pvpBattleground.showStatistics(cid)
		end		
	elseif(option == "spells") then
		doShowTextDialog(cid, 2390, pvpBattleground.getSpellsInfo(cid))
		
	--elseif(option == "statsall" and _access >= access.COMMUNITY_MANAGER) then	
		--pvpBattleground.broadcastStatistics(false)
		--return true		
	--[[
	elseif(option == "kick" and _access >= access.COMMUNITY_MANAGER) then	
		local pid = getPlayerByNameWildcard(param)
		
		if(pid == nil or not doPlayerIsInBattleground(pid)) then
			msg = msg .. "Jogador inexistente ou n?o se encontra na battleground."
			error = true		
		end
		
		pvpBattleground.broadcastStatistics(false)
		return true		
	--]]
	end
	
	if(msg ~= nil and msg ~= "") then
		pvpBattleground.sendPlayerChannelMessage(cid, msg)
	end
	
	return true
end
