local statues = { 1, 1 }
local ITEM_STAIR = 4835
local ITEM_GROUND = 407
local ITEM_KOSHEI_AMULET = 8266
local event = nil
local kosheiSummoned = false

function onUse(cid, item, fromPosition, itemEx, toPosition)
	
	if(item.itemid == ITEM_KOSHEI_AMULET) then
		return onUseKosheiAmulet(cid, item, fromPosition, itemEx, toPosition)
	end
	
	local statue_id = (uid.KOSHEI_STATUE_2 - item.uid) + 1
	local now = statues[statue_id]
	local new = (now == 1) and 0 or 1
	statues[statue_id] = new
	print(table.show(statues))
	
	local ret = getBooleanFromString(statues[statue_id])
	
	if(ret) then
		doTransformItem(item.uid, item.itemid + 1)
	else
		doTransformItem(item.uid, item.itemid - 1)
	end
	
	local statue1, statue2 = getBooleanFromString(statues[1]), getBooleanFromString(statues[2])
	
	if(not statue1 and not statue2) then
		doTransformItem(uid.KOSHEI_STAIR, ITEM_STAIR)
		event = addEvent(restartState, 1000 * 60, true)
		
		local hasDefeatKoshei = (getPlayerStorageValue(cid, sid.KILL_KOSHEI) == 1) and true or false
		
		if(not kosheiSummoned and not hasDefeatKoshei) then
			local pos = getThingPos(uid.KOSHEI_POS)
			local koshei = doSummonCreature("Koshei the Deathless", pos)
			registerCreatureEvent(koshei, "monsterDeath")
			kosheiSummoned = true
		end
	else
		if(event ~= nil) then
			stopEvent(event)
			event = nil
		end
		restartState()
	end
	
	return true
end

function restartState(restartStatues)

	restartStatues = restartStatues or false
	
	doTransformItem(uid.KOSHEI_STAIR, ITEM_GROUND)
	
	if(restartStatues) then
		statues = { 1, 1 }
		doTransformItem(uid.KOSHEI_STATUE_1, getThing(uid.KOSHEI_STATUE_1).itemid + 1)
		doTransformItem(uid.KOSHEI_STATUE_2, getThing(uid.KOSHEI_STATUE_2).itemid + 1)
	end
	
	event = nil
end

function onUseKosheiAmulet(cid, item, fromPosition, itemEx, toPosition)

	local kosheiDeathDate = getItemAttribute(itemEx.uid, "kosheiDeathDate")
		
	if(kosheiDeathDate and kosheiDeathDate + 4 <= os.time()) then
		setGlobalStorageValue(gid.KOSHEI_DEATH, 1)
		doSendAnimatedText(getThingPos(itemEx.uid), "Arrrrggghhh! Este verme descobriu minha fraqueza!! Eu ainda retornarei!!", COLOR_ORANGE)
		doRemoveItem(itemEx.uid)
		doRemoveItem(item.uid)
		kosheiSummoned = false
		setPlayerStorageValue(cid, sid.KILL_KOSHEI, 1)
	end
	
	return true
end