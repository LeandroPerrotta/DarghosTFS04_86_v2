local statues = { true, true }
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
	statues[statue_id] = (statues[statue_id]) and false or true
	
	if(not statues[1] and not statues[2]) then
		doTransformItem(uid.KOSHEI_STAIR, ITEM_STAIR)
		event = addEvent(restartState, 1000 * 60, true)
		
		local hasDefeatKoshei = (getPlayerStorageValue(cid, sid.KILL_KOSHEI) == 1) and true or false
		
		if(not kosheiSummoned and not hasDefeatKoshei) then
			local pos = getThingPos(uid.KOSHEI_POS)
			local koshei = doSummonCreature("Koshei the Deathless")
			addCreatureEvent(koshei, "monsterDeath")
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

function restartState(statues)
	statues = statues or false
	
	doTransformItem(uid.KOSHEI_STAIR, ITEM_GROUND)
	
	if(statues) then
		doTransformItem(uid.KOSHEI_STATUE_1, getThing(KOSHEI_STATUE_1).itemid - 1)
		doTransformItem(uid.KOSHEI_STATUE_1, getThing(KOSHEI_STATUE_2).itemid - 1)
	end
	
	event = nil
end

function onUseKosheiAmulet(cid, item, fromPosition, itemEx, toPosition)

	local isKosheiCorpse = getItemAttribute(itemEx.uid, "kosheiCorpse")
	
	if(isKosheiCorpse) then
		setGlobalStorageValue(gid.KOSHEI_DEATH, 1)
		doRemoveItem(itemEx.uid)
		doRemoveItem(item.uid)
		kosheiSummoned = false
		setPlayerStorageValue(cid, sid.KILL_KOSHEI, 1)
	end
	
	return true
end