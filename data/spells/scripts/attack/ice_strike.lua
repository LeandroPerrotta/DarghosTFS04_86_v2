local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ICEATTACK)

local distanceCombat = createCombatObject()
setCombatParam(distanceCombat, COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
setCombatParam(distanceCombat, COMBAT_PARAM_EFFECT, CONST_ME_ICEATTACK)
setCombatParam(distanceCombat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_SMALLICE)

function onGetFormulaValues(cid, level, maglevel)
	local min, max = getMinMaxClassicFormula(level, maglevel, 1.8, 3.3)
	return -min, -max
end	

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onGetFormulaValues(cid, level, maglevel)
	local min, max = getMinMaxClassicFormula(level, maglevel, 1.8, 3.3)
	return -min, -max
end	

setCombatCallback(distanceCombat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)
	if(variantToNumber(var) ~= 0) then
		return doCombat(cid, distanceCombat, var)
	end
	return doCombat(cid, combat, var)
end
