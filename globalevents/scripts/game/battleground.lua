function onBattlegroundStart()

	local wallsUidStart, wallsUidEnd = 20502, 20509
	local ITEM_GATE = 10652
	
	for i = wallsUidStart, wallsUidEnd do
		local thing = getTileItemById(getThingPos(i), ITEM_GATE)
		doRemoveItem(thing.uid)
	end
	
	return true
end

function onBattlegroundEnd()

	local wallsUidStart, wallsUidEnd = 20502, 20509
	local ITEM_GATE = 10652
	
	for i = wallsUidStart, wallsUidEnd do
		local pos = getThingPos(i)
		doCreateItem(ITEM_GATE, pos)
	end
	
	return true
end