function onAdvance(cid, type, oldlevel, newlevel)
		
	setStageOnAdvance(cid, type)
	
	if(type == SKILL__LEVEL and canReceivePremiumTest(cid, newlevel)) then
		addPremiumTest(cid)
	end
	
	return LUA_TRUE
end