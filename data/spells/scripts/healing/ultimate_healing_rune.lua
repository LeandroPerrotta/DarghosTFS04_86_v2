local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, FALSE)
setCombatParam(combat, COMBAT_PARAM_TARGETCASTERORTOPMOST, TRUE)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

function onGetFormulaValues(cid, level, maglevel)
	local min, max = getMinMaxClassicFormula(level, maglevel, 12.5, 16.2, 250, 300)
	return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)
	
	local target = getSpellTargetCreature(var)
	if(not target) then
		error("Invalid target: " .. table.show(var))
		return false
	end
	
	if(target ~= cid and not isDruid(cid)) then
		doPlayerSendCancel(cid, "Somente druids podem usar runas de regeneração em outros jogadores.")
		doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
		return false		
	end
	
	return doCombat(cid, combat, var)
end
