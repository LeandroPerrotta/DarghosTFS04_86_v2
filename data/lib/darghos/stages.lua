STAGES_EXPERIENCE = 1
STAGES_EXP_PROTECTED = 2
STAGES_SKILLS = 3
STAGES_MAGIC = 4

SKILL_STAGE_MAGES = 2
SKILL_STAGE_NON_LOGOUT_PLAYERS = SKILL_STAGE_MAGES

stages = {
	[STAGES_EXPERIENCE] = {
		[WORLD_ORDON] = {
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
		[WORLD_AARAGON] = {
			{end_level = 39, multipler = 20}, 
			{start_level = 40, end_level = 79, multipler = 15}, 
			{start_level = 80, end_level = 99, multipler = 10}, 
			{start_level = 100, end_level = 119, multipler = 8}, 
			{start_level = 120, end_level = 139, multipler = 6}, 
			{start_level = 140, end_level = 159, multipler = 4}, 
			{start_level = 160, end_level = 179, multipler = 3}, 
			{start_level = 180, end_level = 199, multipler = 2},
			{start_level = 200, end_level = 239, multipler = 1.5},
			{start_level = 240, multipler = 1}		
		}
	},
	
	[STAGES_SKILLS] = {
		[WORLD_ORDON] = {
			{end_level = 79, multipler = 80}, 
			{start_level = 80, end_level = 89, multipler = 50}, 
			{start_level = 90, end_level = 99, multipler = 25}, 
			{start_level = 100, end_level = 109, multipler = 10}, 
			{start_level = 110, multipler = 5}
		},
		[WORLD_AARAGON] = {
			{end_level = 79, multipler = 80}, 
			{start_level = 80, end_level = 89, multipler = 50}, 
			{start_level = 90, end_level = 99, multipler = 25}, 
			{start_level = 100, end_level = 114, multipler = 10}, 
			{start_level = 115, end_level = 119, multipler = 8},
			{start_level = 120, end_level = 124, multipler = 6},
			{start_level = 125, end_level = 129, multipler = 4},
			{start_level = 130, multipler = 2}			
		}
	},
	
	[STAGES_MAGIC] = {
		[WORLD_ORDON] = {
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
		},
		[WORLD_AARAGON] = {
			mage = {
				{end_level = 39, multipler = 15}, 
				{start_level = 40, end_level = 49, multipler = 10}, 
				{start_level = 50, end_level = 59, multipler = 8}, 
				{start_level = 60, end_level = 64, multipler = 6}, 
				{start_level = 65, end_level = 69, multipler = 4}, 
				{start_level = 70, end_level = 74, multipler = 3}, 
				{start_level = 75, end_level = 84, multipler = 2}, 
				{start_level = 85, multipler = 1}		
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
	},
	
	[STAGES_EXP_PROTECTED] = {
		{end_level = 39, multipler = 20}, 
		{start_level = 40, end_level = 79, multipler = 15}, 
		{start_level = 80, multipler = 1},
	},	
}

function getPlayerMultiple(cid, stagetype, skilltype)

	local _stages = stages[stagetype][getConfigValue("worldId")]
	
	if(not doPlayerIsPvpEnable(cid) and darghos_use_protected_stages and stagetype == STAGES_EXPERIENCE) then
		_stages = stages[STAGES_EXP_PROTECTED]
	end
	
	if(stagetype == STAGES_MAGIC) then
		if(isSorcerer(cid) or isDruid(cid)) then
			_stages = _stages.mage
		elseif(isPaladin(cid)) then
			_stages = _stages.paladin
		elseif(isKnight(cid)) then
			_stages = _stages.knight
		end
	end
	
	if(stagetype == STAGES_SKILLS and (isSorcerer(cid) or isDruid(cid))) then
		return SKILL_STAGE_MAGES
	end
	
	local skipedNames = {"Little Mystyk", "Boltada Maligna"}
	if(isInArray({STAGES_SKILLS, STAGES_MAGIC}, stagetype) and getPlayerGroupId(cid) == GROUPS_PLAYER_BOT and not isInArray(skipedNames, getPlayerName(cid))) then
		return SKILL_STAGE_NON_LOGOUT_PLAYERS
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
		
		local expSpecialBonus = 0
		
		local lastKillDarkGeneral = getStorage(gid.LAST_KILL_DARK_GENERAL)
		
		
		if(lastKillDarkGeneral > 0 and time() < lastKillDarkGeneral + (darghos_kill_dark_general_exp_bonus_days * 60 * 60 * 24)) then
			local endEvent = os.date("*t", lastKillDarkGeneral + (darghos_kill_dark_general_exp_bonus_days * 60 * 60 * 24))
			local now = os.date("*t")
			if(now.day <= endEvent.day) then
				expSpecialBonus = expSpecialBonus + (round(darghos_kill_dark_general_exp_bonus_percent / 100, 2))
			end
		end	
		
		local expSpecialBonusEnd = getPlayerStorageValue(cid, sid.EXP_MOD_ESPECIAL_END)
		 if(expSpecialBonusEnd ~= -1  and os.time() <= expSpecialBonusEnd) then
		 	expSpecialBonus = expSpecialBonus + (getPlayerStorageValue(cid, sid.EXP_MOD_ESPECIAL) > 0) and round(getPlayerStorageValue(cid, sid.EXP_MOD_ESPECIAL) / 100, 2) or 1
		 end
		 
		 expSpecialBonus = expSpecialBonus + 1
	
		setExperienceRate(cid, multiple * darghos_exp_multipler * changePvpDebuff * expSpecialBonus)
	elseif(isStagedSkill(skilltype, true)) then
		setSkillRate(cid, skilltype, multiple)
	else
		print("changeStage() | Unknown skilltype " .. skilltype .. " when change the stage for " .. getPlayerName(cid) .. " by " .. multiple .. "x.")
	end
end

function reloadExpStages(cid)
	changeStage(cid, SKILL__LEVEL, getPlayerMultiple(cid, STAGES_EXPERIENCE))
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

function setStageOnChangePvp(cid)
	reloadExpStages(cid)
end