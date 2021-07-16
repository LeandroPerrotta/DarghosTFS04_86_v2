pvpEngine = {
	--_singleton = nil
}

pvpEngine.scenariosList = {
}

function pvpEngine.init()

	-- capture the flag
	local scenario = pvpScenario:new(SCENARIO_TYPE_CAPTURE_THE_FLAG)
	
	scenario.addQueue(queue:new(100, 15)) -- 10 players each teams of lv 100+
	scenario.addQueue(queue:new(50, 15)) -- 15 players each teams of lv 50+
	scenario.addQueue(queue:new(0, 15)) -- 15 players each teams of lower levels
	
	pvpEngine.registerScenario(scenario)
	
	pvpEngine.run()
end

function pvpEngine.registerScenario(scenario)

	table.insert(pvpEngine.scenariosList, scenario)
end

function pvpEngine.run()

	for k,v in pairs(pvpEngine.scenariosList) do
	
		local scenario = v		
		scenario.run()
	end
end