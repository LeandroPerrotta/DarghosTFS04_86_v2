function onCastSpell(cid, var)
	
	local general = getCreatureByName("dark general")
	
	if(not general) then
		return true
	end
	
	if(getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(general)) <= 7) then
		local heal = math.random(6750, 12500)
		doCreatureAddHealth(general, heal, CONST_ME_MAGIC_BLUE, COLOR_BLUE)
		doCreatureSay(cid, "Protejam o General a todo custo!", TALKTYPE_MONSTER_YELL)
	end
	
	return true
end
