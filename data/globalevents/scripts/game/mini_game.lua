function onTime(time)

	local date = os.date("*t")
	
	local eventDays = { WEEKDAY.SUNDAY, WEEKDAY.TUESDAY }
	
	if(not isInArray(eventDays, date.wday)) then
		return true
	end

	local message = "O evento semanal Warmaster Game esta para começar em 10 minutos."
	doBroadcastMessage(message, MESSAGE_TYPES["blue"])
	
	addEvent(eventStart, 1000 * 60 *  10)
	
	return true
end

function eventStart()

	setGlobalStorageValue(gid.EVENT_MINI_GAME_STATE, EVENT_STATE_INIT)
	
	local message = "O evento Warmaster Game foi iniciado!"
	doBroadcastMessage(message, MESSAGE_TYPES["blue"])	
	
	local boss_pos = getThingPosition(uid.MINI_GAME_BOSS)
	local boss = doSummonCreature("boss", boss_pos)	
	
	registerCreatureEvent(boss, "minigameOnBossDeath")
	
	local stone_poss = getThingPosition(uid.MINI_GAME_STONE)
	doSummonCreature("stone", stone_poss)
end