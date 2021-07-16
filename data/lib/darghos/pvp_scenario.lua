SCENARIO_SEWER, SCENARIO_OPEN_ARENA, SCENARIO_HELL = 1, 2, 3
SCENARIO_ID_MIN, SCENARIO_ID_MAX = SCENARIO_SEWER, SCENARIO_HELL

SCENARIO_STATUS_FREE, SCENARIO_STATUS_BUSY = 1, 2

SCENARIO_STATUS_VAR = "scenarioState_"
SCENARIO_TEAMS_VAR = "scenarioTeam_"

--[[
	scenario team struct:

	teams = {
		//team 1
		[1] = {
			//key is the cid!!
			[1000] = { death = false },
			[1001] = { death = true }
		},
		//team 2
		[2] = {
			[1002] = { death = false },
			[1003] = { death = false }
		}
	}
--]]

pvpScenarios = {

	[SCENARIO_SEWER] = {
		maxTeamSize = ARENA_1X1
	},
	
	[SCENARIO_OPEN_ARENA] = {
		minTeamSize = ARENA_2X2,
		maxTeamSize = ARENA_5X5
	},
	
	[SCENARIO_HELL] = {
		minTeamSize = ARENA_2X2,
		maxTeamSize = ARENA_5X5
	}
}

function getScenarioState(scenario)
	if(scenario >= SCENARIO_ID_MIN and scenario <= SCENARIO_ID_MAX) then
		return getGlobalValue(SCENARIO_STATUS_VAR .. scenario)
	end
	
	return nil
end

function setScenarioState(scenario, state)
	local state = state or nil

	if(scenario >= SCENARIO_ID_MIN and scenario <= SCENARIO_ID_MAX) then
		if(state == nil) then
			clearGlobalValue(SCENARIO_STATUS_VAR .. scenario)
		else
			setGlobalValue(SCENARIO_STATUS_VAR .. scenario, state)
		end
		
		return
	end
end

function getScenarioTeams(scenario)
	if(scenario >= SCENARIO_ID_MIN and scenario <= SCENARIO_ID_MAX) then
		return getGlobalValue(SCENARIO_TEAMS_VAR .. scenario)
	end
	
	return nil
end

function setScenarioTeams(scenario, team)
	local team = state or nil

	if(scenario >= SCENARIO_ID_MIN and scenario <= SCENARIO_ID_MAX) then
		if(team == nil) then
			clearGlobalValue(SCENARIO_TEAMS_VAR .. scenario)
		else
			setGlobalValue(SCENARIO_TEAMS_VAR .. scenario, team)
		end
		
		return
	end
end