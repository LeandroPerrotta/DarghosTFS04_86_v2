leversCount = 1

local INTERVAL_TO_RESET = 0.1
local STONE_ID = 1304

local leversState_T = {

	[1] = uid.POI_LEVER_1,
	[2] = uid.POI_LEVER_2,
	[3] = uid.POI_LEVER_3,
	[4] = uid.POI_LEVER_4,
	[5] = uid.POI_LEVER_5,
	[6] = uid.POI_LEVER_6,
	[7] = uid.POI_LEVER_7,
	[8] = uid.POI_LEVER_8,
	[9] = uid.POI_LEVER_9,
	[10] = uid.POI_LEVER_10,
	[11] = uid.POI_LEVER_11,
	[12] = uid.POI_LEVER_12,
	[13] = uid.POI_LEVER_13,
	[14] = uid.POI_LEVER_14,
	[15] = uid.POI_LEVER_15,
	[16] = uid.POI_LEVER_MAIN

}

local function resetLevers()

	local pos_stone_1 = getThingPosition(uid.POI_STONE_1)
	local pos_stone_2 = getThingPosition(uid.POI_STONE_2)

	pos_stone_1.stackpos = 1
	pos_stone_2.stackpos = 1
	
	for k,v in pairs(leversState_T) do
	
		local leverPos = getThingPosition(v)
		leverPos.stackpos = 1
		
		local lever = getTileThingByPos(leverPos)
		
		if((lever ~= nil) and (lever.itemid == 1946)) then
			doTransformItem(lever.uid, 1945)
		end
		
	end	
	
	leversCount = 1
	
	doCreateItem(STONE_ID, 1, pos_stone_1)
	doCreateItem(STONE_ID, 1, pos_stone_2)
	doTransformItem(uid.POI_LEVER_MAIN, 1945)
	
end

local function finishLevers()

	local pos_stone_1 = getThingPosition(uid.POI_STONE_1)
	local pos_stone_2 = getThingPosition(uid.POI_STONE_2)

	pos_stone_1.stackpos = 1
	pos_stone_2.stackpos = 1
	
	local stone_1 = getTileThingByPos(pos_stone_1)
	local stone_2 = getTileThingByPos(pos_stone_2)
	
	
	if(stone_1 ~= nil and stone_2 ~= nil) then
		doRemoveItem(stone_1.uid, 1)
		doRemoveItem(stone_2.uid, 1)
		addEvent(resetLevers, INTERVAL_TO_RESET * 60 * 1000)
	end
	
end


function onUse(cid, item, fromPosition, itemEx, toPosition)

	
	if(item.itemid == 1945) then
		
		if(leversState_T[leversCount] == item.uid) then
			
			if((item.uid == uid.POI_LEVER_MAIN) and (leversCount == 16)) then
				finishLevers()	
			else
				leversCount = leversCount + 1
				doPlayerSendCancel(cid, "Alavanca ativada com sucesso! Restam mais " .. 15 - (leversCount - 1) .. " alavanca (s)!")
			end
			
		else
			return true
		end
		
	else
		if(leversState_T[leversCount - 1] == item.uid) then
			leversCount = leversCount - 1
		else
			return true
		end
	end

end

