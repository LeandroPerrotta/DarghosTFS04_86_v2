STAGES_EXPERIENCE = 1
--STAGES_EXP_SECURE = 2
STAGES_SKILLS = 3
STAGES_MAGIC = 4

stages = {
	[STAGES_EXPERIENCE] = {
		{end_level = 99, multipler = 100}, 
		{start_level = 100, end_level = 119, multipler = 50}, 
		{start_level = 120, end_level = 139, multipler = 25}, 
		{start_level = 140, end_level = 159, multipler = 15}, 
		{start_level = 160, end_level = 179, multipler = 10}, 
		{start_level = 180, end_level = 199, multipler = 8}, 
		{start_level = 200, end_level = 219, multipler = 6}, 
		{start_level = 220, end_level = 239, multipler = 5},
        {start_level = 240, end_level = 279, multipler = 4},
        {start_level = 280, end_level = 319, multipler = 3},
        {start_level = 320, end_level = 359, multipler = 2.5},
        {start_level = 360, end_level = 399, multipler = 2},
        {start_level = 400, end_level = 439, multipler = 1.5},
        {start_level = 440, multipler = 1}		
	},
	
	--[[
	[STAGES_EXP_SECURE] = {
		{end_level = 49, multipler = 50}, 
		{start_level = 50, end_level = 79, multipler = 25}, 
		{start_level = 80, multipler = 1}, 				
	},
	--]]
	
	[STAGES_SKILLS] = {
		{end_level = 79, multipler = 80}, 
		{start_level = 80, end_level = 89, multipler = 50}, 
		{start_level = 90, end_level = 99, multipler = 25}, 
		{start_level = 100, end_level = 109, multipler = 10}, 
		{start_level = 110, multipler = 5}		
	},
	
	[STAGES_MAGIC] = {
		mage = {
			{end_level = 59, multipler = 15}, 
			{start_level = 60, end_level = 79, multipler = 10}, 
			{start_level = 80, end_level = 89, multipler = 5}, 
			{start_level = 90, end_level = 95, multipler = 3}, 
			{start_level = 96, multipler = 1}		
		},
		paladin = {
			{end_level = 29, multipler = 15}, 
			{start_level = 30, end_level = 31, multipler = 7}, 
			{start_level = 32, multipler = 3}			
		},
		knight = {
			{end_level = 9, multipler = 15}, 
			{start_level = 10, end_level = 11, multipler = 7}, 
			{start_level = 12, multipler = 3}			
		}
	}
}

function getPlayerMultiple(cid, stagetype, skilltype)

	local _stages = stages[stagetype]
	
	if(stagetype == STAGES_MAGIC) then
		if(isSorcerer(cid) or isDruid(cid)) then
			_stages = _stages.mage
		elseif(isPaladin(cid)) then
			_stages = _stages.paladin
		elseif(isKnight(cid)) then
			_stages = _stages.knight
		end
	end		
	
	for k,v in pairs(_stages) do
	
		local attribute = getPlayerLevel(cid)
		
		if(stagetype == STAGES_MAGIC) then
			attribute = getPlayerMagLevel(cid, true)
		elseif(stagetype == STAGES_SKILLS) then
			attribute = getPlayerSkillLevel(cid, skilltype)
		end
	
		local start_level = v.start_level or 0
		local lastStage = (v.end_level == nil) and true or false
		
		if(lastStage and attribute >= start_level) then
			return v.multipler
		end
		
		if(not lastStage) then
			if(attribute >= start_level and attribute <= v.end_level) then
				return v.multipler
			end
		end
	end
	
	return 0
end

function isStagedSkill(skilltype, includeMagic)
	includeMagic = includeMagic or false 
	
	local skills = {SKILL_CLUB, SKILL_SWORD, SKILL_AXE, SKILL_DISTANCE, SKILL_SHIELD}
	
	if(includeMagic) then
		table.insert(skills, SKILL__MAGLEVEL)
	end

	return isInArray(skills, skilltype)
end

function changeStage(cid, skilltype, multiple)

	if(skilltype == SKILL__LEVEL) then
		local changePvpDebuffExpire = getPlayerStorageValue(cid, sid.CHANGE_PVP_EXP_DEBUFF)		
		local changePvpDebuff = 1
		
		if(changePvpDebuffExpire ~= nil and os.time() < changePvpDebuffExpire)  then
			changePvpDebuff = round(darghos_change_pvp_debuff_percent / 100, 2)
		end
		
		local expSpecialBonus = 1
		local expSpecialBonusEnd = getPlayerStorageValue(cid, sid.EXP_MOD_ESPECIAL_END)
		 if(expSpecialBonusEnd ~= -1  and os.time() <= expSpecialBonusEnd) then
		 	expSpecialBonus = (getPlayerStorageValue(cid, sid.EXP_MOD_ESPECIAL) > 0) and round(getPlayerStorageValue(cid, sid.EXP_MOD_ESPECIAL) / 100, 2) or 0
		 end
	
		setExperienceRate(cid, multiple * darghos_exp_multipler * changePvpDebuff * expSpecialBonus)
	elseif(isStagedSkill(skilltype, true)) then
		setSkillRate(cid, skilltype, multiple)
	else
		print("changeStage() | Unknown skilltype " .. skilltype .. " when change the stage for " .. getPlayerName(cid) .. " by " .. multiple .. "x.")
	end
end

function setStagesOnLogin(cid)

	changeStage(cid, SKILL__LEVEL, getPlayerMultiple(cid, STAGES_EXPERIENCE))
	changeStage(cid, SKILL__MAGLEVEL, getPlayerMultiple(cid, STAGES_MAGIC))
	
	for i = SKILL_CLUB, SKILL_SHIELD do
		changeStage(cid, i, getPlayerMultiple(cid, STAGES_SKILLS, i))
	end	
end

function setStageType(cid, skilltype) setStageOnAdvance(cid, skilltype) end
function setStageOnAdvance(cid, skilltype)

	if(isStagedSkill(skilltype)) then
		changeStage(cid, skilltype, getPlayerMultiple(cid, STAGES_SKILLS, skilltype))
	elseif(skilltype == SKILL__MAGLEVEL) then
		changeStage(cid, SKILL__MAGLEVEL, getPlayerMultiple(cid, STAGES_MAGIC))
	elseif(skilltype == SKILL__LEVEL) then
		changeStage(cid, SKILL__LEVEL, getPlayerMultiple(cid, STAGES_EXPERIENCE))
	end
end