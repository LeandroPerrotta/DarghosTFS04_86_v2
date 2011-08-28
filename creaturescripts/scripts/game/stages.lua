function onAdvance(cid, type, oldlevel, newlevel)
		
	if(type == LEVEL_EXPERIENCE) then
	
		setRateStage(cid, newlevel)
	else
		setSkillStageOnAdvance(cid, type, newlevel)
	end		
	
	if(canReceivePremiumTest(cid, newlevel)) then
		addPremiumTest(cid)
	end
	
	return LUA_TRUE
end