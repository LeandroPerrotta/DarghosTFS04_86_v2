--Formulas based on formula page at http://tibia.wikia.com/wiki/Formula written at 4.06.2009 
--All these spells were written/modified by Pietia with the right formulas

SPELL_TARGET_CREATURE = 1
SPELL_TARGET_POS = 2

function getSpellTargetCreature(var)

		local target = nil

		if(var.type == SPELL_TARGET_CREATURE) then
			target = var.number
		elseif(var.type == SPELL_TARGET_POS) then
			local thing = getTopCreature(var.pos)
			if(not thing) then
				error(" Can not find the target by pos: " .. table.show(var.pos))
			end
			
			target = thing.uid
		end
		
		if(not target) then
			error(" Can not find target: " .. table.show(var))
			return false
		end	
		
		return target
end

DESINTEGRATE_UNREMOVABLE = {3058, 3059, 3060, 3061, 3062, 3063, 3064, 3065, 3066}

--Pre-made areas

--Waves
AREA_WAVE4 = {
{1, 1, 1, 1, 1},
{0, 1, 1, 1, 0},
{0, 1, 1, 1, 0},
{0, 0, 3, 0, 0}
}

AREA_SQUAREWAVE5 = {
{1, 1, 1},
{1, 1, 1},
{1, 1, 1},
{0, 1, 0},
{0, 3, 0}
}

--Diagonal waves
AREADIAGONAL_WAVE4 = {
{0, 0, 0, 0, 1, 0},
{0, 0, 0, 1, 1, 0},
{0, 0, 1, 1, 1, 0},
{0, 1, 1, 1, 1, 0},
{1, 1, 1, 1, 1, 0},
{0, 0, 0, 0, 0, 3}
}

AREADIAGONAL_SQUAREWAVE5 = {
{1, 1, 1, 0, 0},
{1, 1, 1, 0, 0},
{1, 1, 1, 0, 0},
{0, 0, 0, 1, 0},
{0, 0, 0, 0, 3}
}

--Beams
AREA_BEAM1 = {
{3}
}

AREA_BEAM5 = {
{1},
{1},
{1},
{1},
{3}
}

AREA_BEAM8 = {
{1},
{1},
{1},
{1},
{1},
{1},
{1},
{3}
}

--Diagonal Beams
AREADIAGONAL_BEAM5 = {
{1, 0, 0, 0, 0},
{0, 1, 0, 0, 0},
{0, 0, 1, 0, 0},
{0, 0, 0, 1, 0},
{0, 0, 0, 0, 3}
}

AREADIAGONAL_BEAM8 = {
{1, 0, 0, 0, 0, 0, 0, 0},
{0, 1, 0, 0, 0, 0, 0, 0},
{0, 0, 1, 0, 0, 0, 0, 0},
{0, 0, 0, 1, 0, 0, 0, 0},
{0, 0, 0, 0, 1, 0, 0, 0},
{0, 0, 0, 0, 0, 1, 0, 0},
{0, 0, 0, 0, 0, 0, 1, 0},
{0, 0, 0, 0, 0, 0, 0, 3}
}

--Circles
AREA_CIRCLE2X2 = {
{0, 1, 1, 1, 0},
{1, 1, 1, 1, 1},
{1, 1, 3, 1, 1},
{1, 1, 1, 1, 1},
{0, 1, 1, 1, 0}
}

AREA_CIRCLE3X3 = {
{0, 0, 1, 1, 1, 0, 0},
{0, 1, 1, 1, 1, 1, 0},
{1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 3, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1},
{0, 1, 1, 1, 1, 1, 0},
{0, 0, 1, 1, 1, 0, 0}
}

-- Crosses
AREA_CROSS1X1 = {
{0, 1, 0},
{1, 3, 1},
{0, 1, 0}
}

AREA_CROSS5X5 = {
{0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0},
{0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
{0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
{1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1},
{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
{0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
{0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
{0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}
}

AREA_CROSS6X6 = {
{0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0},
{0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0},
{0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0},
{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
{1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1},
{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
{0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0},
{0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0},
{0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0}
}

--Squares
AREA_SQUARE1X1 = {
{1, 1, 1},
{1, 3, 1},
{1, 1, 1}
}

-- Walls
AREA_WALLFIELD = {
{1, 1, 3, 1, 1}
}

AREADIAGONAL_WALLFIELD = {
{0, 0, 0, 0, 1},
{0, 0, 0, 1, 1},
{0, 1, 3, 1, 0},
{1, 1, 0, 0, 0},
{1, 0, 0, 0, 0},
}
