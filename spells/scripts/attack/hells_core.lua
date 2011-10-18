local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)

local playerDebbufs = {}

function onGetFormulaValues(cid, level, maglevel)
	local min = ((level/5)+(maglevel*7))
	local max = ((level/5)+(maglevel*14))
	
	if(doPlayerIsInBattleground(cid)) then
		if(playerDebbufs[cid] == nil) then
			playerDebbufs[cid]["percent"] = 70
			playerDebbufs[cid]["end"] = os.time() + 3	
		else	
			if(os.time() < playerDebbufs[cid]["end"]) then
				min = min * (playerDebbufs[cid]["percent"] / 100)
				max = max * (playerDebbufs[cid]["percent"] / 100)
				
				if(playerDebbufs[cid]["percent"] == 70) then
					playerDebbufs[cid]["percent"] = 50
				end
				
				playerDebbufs[cid]["end"] = os.time() + 3
			else
				playerDebbufs[cid]["percent"] = 70
				playerDebbufs[cid]["end"] = os.time() + 3	
			end
		end
	end
	
	return -min, -max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local area = createCombatArea(AREA_CROSS5X5)
setCombatArea(combat, area)

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
