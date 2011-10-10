local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TARGETCASTERORTOPMOST, true)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

local condition = createConditionObject(CONDITION_PARALYZE)
setConditionParam(condition, CONDITION_PARAM_TICKS, 20000)
setConditionFormula(condition, -0.80, 0, -0.80, 0)
setCombatCondition(combat, condition)

function onCastSpell(cid, var)
        if(not doCombat(cid, combat, var)) then
                return false
        end

        doSendMagicEffect(getThingPosition(cid), CONST_ME_MAGIC_GREEN)
        return true
end