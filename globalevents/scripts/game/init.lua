function onStartup()

	cleanFreeHouseOwners()
	spoofPlayers()
	Dungeons.onServerStart()
	summonLordVankyner()	
	summonDemonOak()
	
	local sendPlayerToTemple = getGlobalStorageValue(gid.SEND_PLAYERS_TO_TEMPLE)
	
	setGlobalStorageValue(gid.START_SERVER_WEEKDAY, os.date("*t").wday)
	setGlobalStorageValue(gid.EVENT_MINI_GAME_STATE, -1)
	
	if(sendPlayerToTemple == 1) then
		db.executeQuery("UPDATE `players` SET `posx` = '0', `posy` = '0', `posz` = '0';")
		setGlobalStorageValue(gid.SEND_PLAYERS_TO_TEMPLE, 0)
		print("[onStartup] Sending players to temple.")
	end	
	
	local runDbManutention = getGlobalStorageValue(gid.DB_MANUTENTION_STARTUP)
	
	if(runDbManutention == 1) then
		setGlobalStorageValue(gid.DB_MANUTENTION_STARTUP, 0)
		print("Runing db manutention...")		
		dbManutention()
	end
	
	db.executeQuery("UPDATE `players` SET `afk` = 0 WHERE `world_id` = " .. getConfigValue('worldId') .. " AND `afk` > 0;")
	addEvent(autoBroadcast, 1000 * 60 * 30)
	
	luaGlobal.truncate()
	return true
end

function cleanFreeHouseOwners()

	local result = db.getResult("SELECT `houses`.`id` FROM `houses` LEFT JOIN `players` `p` ON `houses`.`owner` = `p`.`id` LEFT JOIN `accounts` `a` ON `a`.`id` = `p`.`account_id` WHERE `a`.`premdays` = '0'");
	if(result:getID() ~= -1) then
		local cleanedHouses = 0
		
		repeat
			local hid = result:getDataInt("id")
			setHouseOwner(hid, 0, true)
			cleanedHouses = cleanedHouses + 1
		until not(result:next())
		result:free()
		
		print("[onStartup] " .. cleanedHouses .. " houses pertencentes a free accounts agora estão disponiveis.")
	end
end

function autoBroadcast()

	local messages = {
		"<Novo Sistema> Você gosta de pvp? duelos? Então não deixe de conhecer o novo PvP Arena. Para saber mais acesse: www.darghos.com.br/?ref=darghopedia.pvp_arenas",
		"Confira os novos preços das Contas Premium! Ter acesso as todas vantagens e beneficios nunca esteve tão barato: www.darghos.com.br"
	}
	
	local random = math.random(1, #messages)
	
	doBroadcastMessage(messages[random], MESSAGE_TYPES["blue"])
	addEvent(autoBroadcast, 1000 * 60 * 60)
end

function dbManutention()

	local oldCustomItemsStartRange = 13332
	local oldCustomItemsEndRange = 13352
	local newStartRange = 12669
	
	db.executeQuery("UPDATE `player_items` SET `itemtype` = " .. newStartRange .. " + (`itemtype` - " .. oldCustomItemsStartRange .. ") WHERE `itemtype` >= " .. oldCustomItemsStartRange .. " AND `itemtype` <= " .. oldCustomItemsEndRange .. ";")
	db.executeQuery("UPDATE `player_depotitems` SET `itemtype` = " .. newStartRange .. " + (`itemtype` - " .. oldCustomItemsStartRange .. ") WHERE `itemtype` >= " .. oldCustomItemsStartRange .. " AND `itemtype` <= " .. oldCustomItemsEndRange .. ";")
	db.executeQuery("UPDATE `tile_items` SET `itemtype` = " .. newStartRange .. " + (`itemtype` - " .. oldCustomItemsStartRange .. ") WHERE `itemtype` >= " .. oldCustomItemsStartRange .. " AND `itemtype` <= " .. oldCustomItemsEndRange .. ";")
end