function onStartup()

	cleanFreeHouseOwners()
	spoofPlayers()
	Dungeons.onServerStart()
	summonLordVankyner()	
	summonDemonOak()
	summonInquisitionBoss()
	
	summonDynamicNpcs()
	
	local sendPlayerToTemple = getGlobalStorageValue(gid.SEND_PLAYERS_TO_TEMPLE)
	
	setGlobalStorageValue(gid.START_SERVER_WEEKDAY, os.date("*t").wday)
	setGlobalStorageValue(gid.EVENT_MINI_GAME_STATE, -1)
	
	if(sendPlayerToTemple == 1) then
		db.executeQuery("UPDATE `players` SET `posx` = '0', `posy` = '0', `posz` = '0';")
		db.executeQuery("UPDATE `player_storage` SET `value` = -1 WHERE `key` = " .. sid.IS_ON_TRAINING_ISLAND .. ";")
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
	
	-- resetando storages diarios
	db.executeQuery("UPDATE `player_storage` SET `value` = -1 WHERE `key` = '" .. sid.WEBSITE_POLL_NOTIFY .. "'")	
	luaGlobal.truncate()
	return true
end

function summonDynamicNpcs()

	local npcs = {
		{file = "global.rashid", startUid = uid.NPC_RASHID_START, endUid = uid.NPC_RASHID_END}
	}
	
	for k,v in pairs(npcs) do
		local uid = math.random(v.startUid, v.endUid)
		local pos = getThingPosition(uid)
		doCreateNpc(v.file, pos)
	end
end

function cleanFreeHouseOwners()

	local result = db.getResult("SELECT `houses`.`id` FROM `houses` LEFT JOIN `players` `p` ON `houses`.`owner` = `p`.`id` LEFT JOIN `accounts` `a` ON `a`.`id` = `p`.`account_id` WHERE `a`.`premdays` = '0' AND `houses`.`world_id` = " .. getConfigValue("worldId") .. ";");
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

function dbManutention()

	local oldCustomItemsStartRange = 13332
	local oldCustomItemsEndRange = 13352
	local newStartRange = 12669
	
	db.executeQuery("UPDATE `player_items` SET `itemtype` = " .. newStartRange .. " + (`itemtype` - " .. oldCustomItemsStartRange .. ") WHERE `itemtype` >= " .. oldCustomItemsStartRange .. " AND `itemtype` <= " .. oldCustomItemsEndRange .. ";")
	db.executeQuery("UPDATE `player_depotitems` SET `itemtype` = " .. newStartRange .. " + (`itemtype` - " .. oldCustomItemsStartRange .. ") WHERE `itemtype` >= " .. oldCustomItemsStartRange .. " AND `itemtype` <= " .. oldCustomItemsEndRange .. ";")
	db.executeQuery("UPDATE `tile_items` SET `itemtype` = " .. newStartRange .. " + (`itemtype` - " .. oldCustomItemsStartRange .. ") WHERE `itemtype` >= " .. oldCustomItemsStartRange .. " AND `itemtype` <= " .. oldCustomItemsEndRange .. ";")
end