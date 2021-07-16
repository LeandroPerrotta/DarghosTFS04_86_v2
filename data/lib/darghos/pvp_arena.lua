local STATE_WAITING, STATE_STARTING, STATE_RUNNING, STATE_PAUSED = 1, 2, 3, 4
local TEAM_ONE, TEAM_TWO = 1, 2

local ITEM_GATE = 9532

local ARENA_STAGES = {
	{ from = 1, to = 19 },
	{ from = 20, to = 39 },
	{ from = 40, to = 59 },
	{ from = 60, to = 79 },
	{ from = 80, to = 99 },
	{ from = 100, to = 139 },
	{ from = 140, to = 179 },
	{ from = 180, to = nil },
}

--- Private vars
pvpArena = {
	teams = nil,
	state = STATE_WAITING,
	bcMsg = 0
}

-- Cria uma nova instancia de um scenario PvP
function pvpArena:new()

	local obj = {}
	
	obj.teams = {nil}
	setmetatable(obj, self)
	self.__index = self
	return obj
end

----------------------
-- TEAMS HANDLER -----
----------------------
function pvpArena:updateTeams()
	if(#self.teams == 0) then
		luaGlobal.unsetVar("pvp_teams")
		return
	end

	luaGlobal.setVar("pvp_teams", self.teams)
end

function pvpArena:importTeams()
	local v = luaGlobal.getVar("pvp_teams")
	
	if(v == nil) then
		 v = {}
	end
	
	self.teams = v
end

function pvpArena:addToTeam(team, cid)
	self:importTeams()
	
	if(self.teams[team] == nil) then
		self.teams[team] = {}
	end
	
	local t = {cid = cid, ready = false}
	table.insert(self.teams[team], t)
	self:updateTeams()
end

function pvpArena:getTeams()
	self:importTeams()
	return self.teams
end

function pvpArena:clearTeams()
	self.teams = {}
	self:updateTeams()
end

function pvpArena:getPlayerReady(cid)

	local player = self:findPlayer(cid)

	if(player == nil) then
		return nil
	end
	
	return player.ready
end

function pvpArena:getPlayerTeam(cid)

	local team = nil
	for tk,tv in pairs(self:getTeams()) do	
		team = tk
		
		for pk,pv in pairs(tv) do	
			if(pv.cid == cid) then
				return team
			end	
		end
	end
	
	return nil
end

function pvpArena:findPlayer(cid)

	for tk,tv in pairs(self:getTeams()) do	
		for pk,pv in pairs(tv) do	
			if(pv.cid == cid) then
				return pv
			end	
		end
	end
	
	return nil
end

function pvpArena:removePlayer(cid)

	local team, key = nil, nil
	local teams = self:getTeams()

	for tk,tv in pairs(teams) do	
		team = tk
		for pk,pv in pairs(tv) do	
			if(pv.cid == cid) then
				key = pk
			end	
		end
	end
	
	teams[team][key] = nil
	self:updateTeams()
end

function pvpArena:setPlayerIsReady(player)
	player.ready = true
	self:updateTeams()
end

function pvpArena:getPlayerOldPos(player)
	return player.oldPos
end

function pvpArena:setPlayerOldPos(player, pos)
	player.oldPos = pos
	self:updateTeams()
end

function pvpArena:setAllPlayersDoubleDamage()
	for tk,tv in pairs(self:getTeams()) do	
		for pk,pv in pairs(tv) do	
			doPlayerSetDoubleDamage(pv.cid)
		end
	end
end

----------------------
-- STATE HANDLER -----
----------------------

function pvpArena:updateState()
	luaGlobal.setVar("pvp_state", self.state)
end

function pvpArena:importState()
	local v = luaGlobal.getVar("pvp_state")
	
	if(v == nil) then
		v = STATE_WAITING
	end	
	
	self.state = v
end

function pvpArena:getState()
	self:importState()
	return self.state
end

function pvpArena:setState(state)
	self.state = state
	self:updateState()
end

-------------------------
-- FUNCTIONS SECTOR -----
-------------------------

function pvpArena:addPlayer(cid, inFirst)

	inFirst = inFirst or false

	if(getGameState() == GAMESTATE_CLOSING or self:getState() == STATE_PAUSED) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "A arena está desativada por enquanto, tente novamente mais tarde.")
		return			
	end

	if(hasCondition(cid, CONDITION_INFIGHT)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você está em condição de combate. Fique alguns instantes sem entrar em combate e tente novamente.")
		return
	end	

	if(getPlayerTown(cid) == getTownIdByName("Island of Peace")) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Jogadores que moram em Island of Peace são muito passivos para participarem de sanguinarias batalhas de Arena.")
		return		
	end

	pvpQueue.load()
	
	if(pvpQueue.getPlayerPosByCid(cid) ~= nil) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você ja está na fila para participar de alguma arena, continue aguardando...")
		return	
	end

	if(not inFirst) then
		pvpQueue.insert(cid)
	else
		pvpQueue.insert(cid, 1)
	end
	
	registerCreatureEvent(cid, "pvpArena_onLogout")
	
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Arena] " .. getPlayerName(cid).. " (" .. getPlayerLevel(cid) .. ") junto-se a fila para um desafio de Arena 1x1. Quer tentar derrotar-lo? Digite \"!arena join\"!")
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você se juntou a fila para um duelo de arena. Agora você deve aguardar até que apareça algum adversário, isto pode levar de alguns segundos a vários minutos.")
	pvpArena.log(T_LOG_ALL, "pvpArena:addPlayer", "Jogador engressou na fila", {name=getCreatureName(cid)})
	self:prepareGame()
end

function pvpArena:finishGame(winner)

	local log = {pvpended = "false"}

	if(winner ~= nil) then
		log.pvpended = "true"
		luaGlobal.setVar("pvp_ended", true)
	end

	local teams = self:getTeams()
	
	log.teams = teams
	
	local looser = nil
		
	for tk, tv in pairs(teams) do
		local team = tv
	
		for pk, pv in pairs(team) do
			local tmp_player = pv
			doPlayerRemoveDoubleDamage(tmp_player.cid)			
			
			if(winner ~= nil) then
				if(tmp_player.cid == winner) then		
					log.winner = getCreatureName(tmp_player.cid)
					self:teleportPlayerOut(tmp_player)
					unregisterCreatureEvent(tmp_player.cid, "pvpArena_onKill")
					doPlayerSendTextMessage(tmp_player.cid, MESSAGE_STATUS_CONSOLE_BLUE, "Parabens! É um verdadeiro vencedor! Você será levado ao local aonde estava em alguns instantes...")	
				else
					looser = tmp_player.cid
					self:teleportPlayerOut(tmp_player)
					unregisterCreatureEvent(tmp_player.cid, "pvpArena_onKill")
					doPlayerSendTextMessage(tmp_player.cid, MESSAGE_STATUS_CONSOLE_BLUE, "Mas que pena, não foi desta vez! Você será levado ao local aonde estava em alguns instantes...")					
				end
			else
				log.winner = "none"
				self:teleportPlayerOut(tmp_player)
				unregisterCreatureEvent(tmp_player.cid, "pvpArena_onKill")
				doPlayerSendTextMessage(tmp_player.cid, MESSAGE_STATUS_CONSOLE_BLUE, "A batalha foi encerrada! Como o resultado persistiu durante 5 minutos é declarado empate!")			
			end
		end
	end
	
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Arena] " .. getPlayerName(winner) .. " (" .. getPlayerLevel(winner) .. ") derrotou " .. getPlayerName(looser) .. " (" .. getPlayerLevel(looser) .. ") e foi o VENCEDOR da Arena 1x1!", TALKTYPE_TYPES["channel-orange"])
	pvpArena.log(T_LOG_ALL, "pvpArena:finishGame", "Arena finalizada.", log)
end

function pvpArena:buildTeams()

	for k,v in pairs(pvpQueue.getQueue()) do
	
		local player = v
		local player_level = getPlayerLevel(player)
		
		local opponentLevelRange = self:getOpponentLevelRange(player_level)
		local opponent = self:findOpponent(opponentLevelRange)
		
		if(player ~= opponent and opponent ~= nil) then
			self:addToTeam(TEAM_ONE, player)
			self:addToTeam(TEAM_TWO, opponent)

			pvpQueue.removePlayerByCid(player)
			pvpQueue.removePlayerByCid(opponent)
			
			pvpArena.log(T_LOG_ALL, "pvpArena:buildTeams", "Novo time para arena disponivel.", {player = getCreatureName(player), opponent = getCreatureName(opponent)})
			
			return true		
		end
	end	
	
	return false
end

function pvpArena:findOpponent(level_range)
	
	for k,v in pairs(pvpQueue.getQueue()) do
	
		local player = v
		local player_level = getPlayerLevel(player)
		
		if(level_range.to == nil and player_level > level_range.from) then
			return player
		elseif(player_level >= level_range.from and player_level <= level_range.to) then
			return player
		end
	end		
	
	return nil
end

function pvpArena:getOpponentLevelRange(level)

	for k,v in pairs(ARENA_STAGES) do
		
		if(v.to == nil or level <= v.to) then
			return v
		end
	end
end

function pvpArena:prepareGame()

	pvpQueue.load()

	if(pvpQueue.size() < 2 or self:getState() ~= STATE_WAITING or not self:buildTeams()) then
		return
	end

	self:setState(STATE_STARTING)
	
	self:addGates()
	self:broadcastMessage()
	addEvent(pvpArena.callBroadcastMessage, 1000 * 30, self)
	addEvent(pvpArena.callBroadcastMessage, 1000 * 45, self)
	addEvent(pvpArena.callBroadcastMessage, 1000 * 55, self)
	addEvent(pvpArena.callRun, 1000 * 60, self)
end

function pvpArena:onPlayerLogout(cid)

	pvpQueue.load()
	
	if(pvpQueue.getPlayerPosByCid(cid) ~= nil) then
		pvpQueue.removePlayerByCid(cid)
		return	
	end
end

function pvpArena:onPlayerReady(cid)

	local player = self:findPlayer(cid)
	
	if(player == nil) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você ainda não foi chamado para uma arena, por favor, continue aguardando se já estiver em uma fila e se não estiver e deseja participar de uma arena digite '!arena join' e aguarde.")
		return
	end	
	
	if(hasCondition(cid, CONDITION_INFIGHT)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você está em condição de combate. Fique alguns instantes sem entrar em combate e tente novamente.")
		return
	end	
	
	if(self:getPlayerReady(cid)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você ja está na arena! A batalha começará em poucos instantes, aguarde!")
		return	
	end
	
	if(getGameState() == GAMESTATE_CLOSING) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "A arena está desativada por enquanto, tente novamente mais tarde.")
		return			
	end
	
	local onIsland = (getPlayerStorageValue(cid, sid.IS_ON_TRAINING_ISLAND) == 1) and true or false
	
	if(onIsland) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Para entrar na Arena você deve sair da ilha de treinamento.")
		return
	end		
	
	player = self:findPlayer(cid)
	self:setPlayerIsReady(player)
	
	local dest = {}
	local playerTeam = self:getPlayerTeam(cid)
	
	if(playerTeam == TEAM_ONE) then
		dest = getThingPos(uid.ARENA_TEAM_ONE_RESPAWN)
	elseif(playerTeam == TEAM_TWO) then
		dest = getThingPos(uid.ARENA_TEAM_TWO_RESPAWN)
	else
		print("pvpArena:setPlayerReady -> Não foi possivel localizar o time do jogador.")
		return
	end
	
	player = self:findPlayer(cid)
	self:setPlayerOldPos(player, getCreaturePosition(cid))

	doTeleportThing(cid, dest)
	lockTeleportScroll(cid)
	registerCreatureEvent(cid, "pvpArena_onKill")
	unregisterCreatureEvent(cid, "pvpArena_onLogout")
	pvpArena.log(T_LOG_ALL, "pvpArena:onPlayerReady", "Jogador está preparado para a arena.", {player = getCreatureName(cid)})
end

function pvpArena:teleportPlayerOut(player, instant)

	instant = (instant ~= nil) and instant or false
	
	unregisterCreatureEvent(player.cid, "pvpArena_onKill")
	unlockTeleportScroll(player.cid)
	doCreatureAddHealth(player.cid, getCreatureMaxHealth(player.cid) - getCreatureHealth(player.cid))
	
	if(not instant) then
		addEvent(doTeleportThing, 1000, player.cid, player.oldPos)
	else
		doTeleportThing(player.cid, player.oldPos)
	end
end

function pvpArena:run()

	self:removeGates()	
	
	local teams = self:getTeams()
	local team_one, team_two = teams[TEAM_ONE], teams[TEAM_TWO]

	if(not team_one[1].ready and team_two[1].ready) then
		-- o segundo jogador estava pronto, enquanto o primeiro não...
		doPlayerSendTextMessage(team_one[1].cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você não compareceu a batalha... Assim ela foi cancelada.")
		
		local temp_cid = team_two[1].cid
		doPlayerSendTextMessage(temp_cid, MESSAGE_STATUS_CONSOLE_BLUE, "O seu adversário não compareceu a batalha... Aguarde outro adversário.")
		self:teleportPlayerOut(team_two[1])
		
		self:clearTeams()
		self:addPlayer(temp_cid, true)
		
		self:setState(STATE_WAITING)
		self.bcMsg = 0
		
		pvpArena.log(T_LOG_ALL, "pvpArena:run", "Jogador faltou a arena.", {player = getCreatureName(team_one[1].cid)})
		return false
	end
	
	if(team_one[1].ready and not team_two[1].ready) then
		-- o primeiro jogador estava pronto, enquanto o segundo não...
		doPlayerSendTextMessage(team_two[1].cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você não compareceu a batalha... Assim ela foi cancelada.")
		
		local temp_cid = team_one[1].cid
		doPlayerSendTextMessage(temp_cid, MESSAGE_STATUS_CONSOLE_BLUE, "O seu adversário não compareceu a batalha... Aguarde outro adversário.")		
		self:teleportPlayerOut(team_one[1])
		
		self:clearTeams()
		self:addPlayer(temp_cid, true)		
		
		self:setState(STATE_WAITING)
		self.bcMsg = 0		
		
		pvpArena.log(T_LOG_ALL, "pvpArena:run", "Jogador faltou a arena.", {player = getCreatureName(team_two[1].cid)})
		return false
	end

	if(not team_one[1].ready and not team_two[1].ready) then
		-- nenhum dos dois jogadores estavam prontos...
		doPlayerSendTextMessage(team_one[1].cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você não compareceu a batalha... Assim ela foi cancelada.")
		doPlayerSendTextMessage(team_two[1].cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você não compareceu a batalha... Assim ela foi cancelada.")
		self:clearTeams()
		
		self:setState(STATE_WAITING)
		self.bcMsg = 0		
		
		pvpArena.log(T_LOG_ALL, "pvpArena:run", "Jogador faltou a arena.", {player = getCreatureName(team_two[1].cid), opponent = getCreatureName(team_one[1].cid)})
		return false
	end	
	
	luaGlobal.unsetVar("pvp_ended")
	self:setAllPlayersDoubleDamage()
	self:setState(STATE_RUNNING)
	self:broadcastMessage()
	
	addEvent(pvpArena.eventTimeRunningOut, 1000 * 60 * 4, self)
	pvpArena.log(T_LOG_ALL, "pvpArena:run", "Arena iniciou.")
	broadcastChannel(CUSTOM_CHANNEL_PVP, "[Arena] Foi iniciado um duelo 1x1 entre " .. getPlayerName(team_one[1].cid) .. " (" .. getPlayerLevel(team_one[1].cid) .. ") vs " .. getPlayerName(team_two[1].cid) .. " (" .. getPlayerLevel(team_two[1].cid) .. ") na Arena!")
	
	return true
end

function pvpArena:addGates()

	pvpArena.log(T_LOG_ALL, "pvpArena:addGates", "Adicionados portões.")

	local teamOneGates = uid.ARENA_TEAM_ONE_WALLS
	
	for k,v in pairs(teamOneGates) do
		local pos = getThingPos(v)
		doCreateItem(ITEM_GATE, pos)
	end
	
	local teamTwoGates = uid.ARENA_TEAM_TWO_WALLS
	
	for k,v in pairs(teamTwoGates) do
		local pos = getThingPos(v)
		doCreateItem(ITEM_GATE, pos)
	end	
end

function pvpArena:removeGates()

	pvpArena.log(T_LOG_ALL, "pvpArena:addGates", "Removidos portões.")

	local teamOneGates = uid.ARENA_TEAM_ONE_WALLS
	
	for k,v in pairs(teamOneGates) do
		local thing = getTileItemById(getThingPos(v), ITEM_GATE)
		doRemoveItem(thing.uid)
	end
	
	local teamTwoGates = uid.ARENA_TEAM_TWO_WALLS
	
	for k,v in pairs(teamTwoGates) do
		local thing = getTileItemById(getThingPos(v), ITEM_GATE)
		doRemoveItem(thing.uid)
	end	
end

function pvpArena:broadcastTeams(text, mustBeReady)

	for tk,tv in pairs(self:getTeams()) do	
		for pk,pv in pairs(tv) do
			if(not mustBeReady or (mustBeReady and pv.ready)) then
				local cid = pv.cid
				doPlayerSendTextMessage(pv.cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
			end			
		end
	end
end

function pvpArena:broadcastMessage()
	
	local text = nil
	local mustBeReady = true
	
	if(self.bcMsg >= 0 and self.bcMsg < 4) then	
		if(self.bcMsg == 0) then
			text = "Você agora está liberado para participar da arena. A batalha iniciará em 60 segundos, digite '!arena ready' quando estiver pronto para ser levado para a arena! Boa sorte!"
			mustBeReady = false
		elseif(self.bcMsg == 1) then
			text = "A batalha irá começar em 30 segundos."
		elseif(self.bcMsg == 2) then
			text = "A batalha irá começar em 15 segundos."		
		elseif(self.bcMsg == 3) then
			text = "A batalha irá começar em 5 segundos."		
		end
		
		self.bcMsg = self.bcMsg + 1
	else
		text = "A batalha foi iniciada. Se em 5 minutos não houver um vencedor será proclamado empate. Boa sorte!"	
		self.bcMsg = 0	
	end

	self:broadcastTeams(text, mustBeReady)
end

-------------------------
-- EVENT CALLERS 	-----
-- isso é um hack!! -----
-------------------------

function pvpArena.callRun(instance)
	instance:run()
end

function pvpArena.callBroadcastMessage(instance)
	instance:broadcastMessage()
end

function pvpArena.eventTimeRunningOut(instance)

	local value = luaGlobal.getVar("pvp_ended")
	
	if(value ~= nil and value) then
		pvpArena.eventTimeOut(instance)
		return
	end

	local text = "Restam 1 minuto para o fim da partida..."
	instance:broadcastTeams(text, true)
	
	addEvent(pvpArena.eventTimeOut, 1000 * 60, instance)
end

function pvpArena.eventTimeOut(instance)
	
	local value = luaGlobal.getVar("pvp_ended")
	
	if(value == nil or not value) then
		instance:finishGame()
	end	

	instance:clearTeams()
	instance:setState(STATE_WAITING)
	instance:prepareGame()	
end

function pvpArena.log(type, caller, string, params)
	local out = os.date("%X") .. " | [" .. type .. "] " .. caller .. " | " .. string
	
	if(params ~= nil) then
		out = out .. " | Params:"
		
		local json = require("json")
		out = out .. json.encode(params)
	end
	
	local printTypes = { T_LOG_ALL }
	
	if(isInArray(printTypes, type) == TRUE or printTypes[1] == T_LOG_ALL) then
	
		local date = os.date("*t")
		local fileStr = date.day .. "-" .. date.month .. ".log"
		local patch = getConfigValue("logsDirectory") .. "arenas/"
		local file = io.open(patch .. fileStr, "a+")
		
		file:write(out .. "\n")
		file:close()
		
		--debugPrint(out)
	end
end
-------------------------
-- SINGLETON INSTANCE ---
-------------------------
instancePvpArena = pvpArena:new()