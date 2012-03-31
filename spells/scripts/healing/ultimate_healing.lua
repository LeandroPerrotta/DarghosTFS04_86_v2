local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, FALSE)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

function onGetFormulaValues(cid, level, maglevel)
	local min, max = getMinMaxClassicFormula(level, maglevel, 12.5, 16.2, 250, 300)
	return min, max
end

setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)

	local manaCost = 160
	
	if(doPlayerIsInBattleground(cid)) then
		manaCost = math.floor(getCreatureMaxMana(cid) * 0.22)
	end
	
    if(getCreatureMana(cid) < manaCost) then
            doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTENOUGHMANA)
            doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
            return false
    end
    
    doCreatureAddMana(cid, -manaCost, false)
    doPlayerAddSpentMana(cid, manaCost)

	return doCombat(cid, combat, var)
end
