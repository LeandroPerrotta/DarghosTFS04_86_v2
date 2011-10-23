function onLogin(cid)

	--print("Custom login done!")

	--Register the kill/die event
	registerCreatureEvent(cid, "CustomPlayerDeath")
	registerCreatureEvent(cid, "CustomStages")
	registerCreatureEvent(cid, "Inquisition")
	registerCreatureEvent(cid, "CustomPlayerTarget")
	registerCreatureEvent(cid, "CustomPlayerCombat")
	registerCreatureEvent(cid, "CustomBonartesTasks")
	registerCreatureEvent(cid, "onKill")
	registerCreatureEvent(cid, "autolotgold")
	registerCreatureEvent(cid, "tradeHandler")
	registerCreatureEvent(cid, "lookItem")
	registerCreatureEvent(cid, "onMoveItem")
	
	--if(tasks.hasStartedTask(cid)) then
		registerCreatureEvent(cid, "CustomTasks")
	--end
	
	registerCreatureEvent(cid, "Hacks")
	registerCreatureEvent(cid, "GainStamina")
	registerCreatureEvent(cid, "onLeaveChannel")
	
	setStagesOnLogin(cid)
	
	playerRecord()
	runPremiumSystem(cid)
	OnKillCreatureMission(cid)
	Dungeons.onLogin(cid)
	--defineFirstItems(cid)
	restoreAddon(cid)
	onLoginNotify(cid)
	--playerAutoEat(cid)
	--customStaminaUpdate(cid)
	
	local itemShop = itemShop:new()
	itemShop:onLogin(cid)
	
	doPlayerOpenChannel(cid, CUSTOM_CHANNEL_PVP)
	
	-- premium test
	if(canReceivePremiumTest(cid, getPlayerLevel(cid))) then
		addPremiumTest(cid)
	end	
	
	-- island of peace non pvp for TFS via onLogin
	if(darghos_distro == DISTROS_TFS) then
		if(getPlayerTown(cid) == towns.ISLAND_OF_PEACE and getPlayerGroupId(cid) < GROUP_PLAYER_TUTOR) then
			doUpdateCreaturePassable(cid)
		end
	end
	
	if(not hasValidEmail(cid)) then	
		notifyValidateEmail(cid)
	end	
	
	local notifyPoll = hasPollToNotify(cid)
	if(notifyPoll) then
		local message = "Caro " .. getCreatureName(cid) ..",\n\n"
		
		message = message .. "Uma nova e importante enquete está disponivel para votação em nosso website e\n"
		message = message .. "reparamos que você ainda não votou nesta enquete. No Darghos nos fazemos enquetes\n"
		message = message .. "periodicamente e elas são uma forma dos jogadores participarem do desenvolvimento e \n"
		message = message .. "melhorias do servidor.\n\n"
		
		message = message .. "Não deixe de participar! A sua opinião é muito importante para nós e para o Darghos!\n"
		message = message .. "Para votar basta acessar acessar nosso website informado abaixo, e ir na categoria\n"
		message = message .. "'Comunidade' -> 'Enquetes' (requer login na conta).\n\n"
		
		message = message .. "www.darghos.com.br\n\n"
		
		message = message .. "Obrigado e tenha um bom jogo!"
		doPlayerPopupFYI(cid, message)		
	end
	
	if(isInArray({temp_towns.BATTLEGROUND_TEAM_1, temp_towns.BATTLEGROUND_TEAM_2}, getPlayerTown(cid))) then
		local town_id = getPlayerStorageValue(cid, sid.TEMPLE_ID)
			
		unlockChangeOutfit(cid)
		restorePlayerOutfit(cid)
		doPlayerSetTown(cid, town_id)
		doPlayerRemoveDoubleDamage(cid)	
		unlockTeleportScroll(cid)
		
		unregisterCreatureEvent(cid, "pvpBattleground_onKill")
		
		local destPos = getThingPos(uid.BATTLEGROUND_LEAVE)
		doTeleportThing(cid, destPos)
		doSendMagicEffect(destPos, CONST_ME_MAGIC_BLUE)			
	end

	if(getPlayerAccess(cid) == groups.GOD) then
		addAllOufits(cid)
	end
	
	--Give basic itens after death
	if getPlayerStorageValue(cid, sid.GIVE_ITEMS_AFTER_DEATH) == 1 then
		if getPlayerSlotItem(cid, CONST_SLOT_BACKPACK).uid == 0 then
			local item_backpack = doCreateItemEx(1988, 1) -- backpack
			
			doAddContainerItem(item_backpack, 2120, 1) -- rope
			doAddContainerItem(item_backpack, 2554, 1) -- shovel
			doAddContainerItem(item_backpack, 2666, 4) -- meat
			doAddContainerItem(item_backpack, CUSTOM_ITEMS.TELEPORT_RUNE, 1) -- teleport rune
			
			doPlayerAddItemEx(cid, item_backpack, FALSE, CONST_SLOT_BACKPACK)
		end
		setPlayerStorageValue(cid, sid.GIVE_ITEMS_AFTER_DEATH, -1)
	end			
	
	setPlayerStorageValue(cid, sid.TRAINING_SHIELD, 0)
	setPlayerStorageValue(cid, sid.TELEPORT_RUNE_STATE, STORAGE_NULL)
	setPlayerStorageValue(cid, sid.HACKS_LIGHT, LIGHT_NONE)
	setPlayerStorageValue(cid, sid.HACKS_DANCE_EVENT, STORAGE_NULL)
	setPlayerStorageValue(cid, sid.HACKS_CASTMANA, STORAGE_NULL)
	setPlayerStorageValue(cid, sid.NEXT_STAMINA_UPDATE, STORAGE_NULL)
	
	return TRUE
end

function onLoginNotify(cid)

	local today = os.date("*t").wday
	
	local msg = nil
	
	if(isInArray({WEEKDAY.SUNDAY, WEEKDAY.TUESDAY}, today)) then
		local eventState = getGlobalStorageValue(gid.EVENT_MINI_GAME_STATE)
	
		if(isInArray({EVENT_STATE_NONE, EVENT_STATE_INIT}, eventState)) then
		
			msg = (eventState == EVENT_STATE_INIT) and "Evento do dia (ABERTO!!):\n\n" or "Evento do dia:\n\n"			
			msg = msg .. "Não se esqueça que hoje é dia do evento semanal Warmaster a partir das 15:00 PM! \n\n"
			msg = msg .. "O Warmaster é um evento de PvP que acontece as terças e domingos e premia o vencedor com um ticket para o Warmaster Outfit. \n"
			msg = msg .. "A entrada do evento fica no deserto ao oeste de Quendor, em estrutura com teleports.\n"
			msg = msg .. "Dentro do evento tudo é Hardcore PvP e se você morrer você não perderá nada. O objetivo é simplesmente destruir os obstaculos e se manter vivo!\n"
			msg = msg .. "Na ultima sala existirá o boss que ao ser derrotado dropará o premio!\n"
		end
	elseif(today == WEEKDAY.MONDAY and getPlayerLevel(cid) >= 80) then
	
		msg = "Lembrete do dia:\n\n"
		msg = msg .. "Hoje é segunda-feira e o barco que faz viagens Quendor (PvP) <-> Island of Peace (Optional PvP) está disponivel caso você deseje transferir seu personagem! \n"
		msg = msg .. "Pense bem e lembre-se que só é permitida UMA unica viagem e que caso seja feita você terá de permanecer no destino escolhido ao menos até a proxima segunda-feira!\n"
	end
	
	if(msg ~= nil) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, msg)
	end
end
