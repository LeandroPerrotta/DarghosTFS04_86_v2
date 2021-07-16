PH_LOG_BATTLEGROUND_WIN = 1
PH_LOG_BATTLEGROUND_LOST = 2
PH_LOG_BATTLEGROUND_DRAW = 3

PH_ACH_BATTLEGROUND_RANK_VETERAN = 1
PH_ACH_BATTLEGROUND_RANK_LEGEND = 2
PH_ACH_BATTLEGROUND_INSANE_KILLER = 3
PH_ACH_BATTLEGROUND_PERFECT = 4
PH_ACH_BATTLEGROUND_RANK_BRAVE = 5

PH_TYPE_LOG = 1
PH_TYPE_ACHIEVEMENT = 2

playerHistory = {}

--[[
	LOGS HANDLER
]]--

function playerHistory.log(cid, history, params)

	if(params ~= nil) then
		local json = require("json")	
		params = json.encode(params)
	else
		params = ""
	end
	
	db.executeQuery("INSERT `player_history` (`player_id`, `history`, `type`, `date`, `params`) VALUES (" .. getPlayerGUID(cid) .. ", " .. history .. ", " .. PH_TYPE_LOG .. ", " .. os.time() .. ", '" .. params .. "');")
end

--[[
	ACHIEVEMENTS HANDLER
]]--

function playerHistory.addAchievement(cid, history)

	db.executeQuery("INSERT `player_history` (`player_id`, `history`, `type`, `date`, `params`) VALUES (" .. getPlayerGUID(cid) .. ", " .. history .. ", " .. PH_TYPE_ACHIEVEMENT .. ", " .. os.time() .. ", '');")	
	return false	
end

function playerHistory.hasAchievement(cid, history)

	local result = db.getResult("SELECT `history` FROM `player_history` WHERE `player_id` = " .. getPlayerGUID(cid) .. " AND `history` = " .. history .. " AND `type` = " .. PH_TYPE_ACHIEVEMENT .. ";")
	
	if(result:getID() ~= -1) then
		result:free()
		return true
	end	
	
	return false	
end

function playerHistory.notifyAchievement(cid, message)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, message)
end

--[[
	LOGS
]]--

function playerHistory.logBattlegroundWin(cid, rating)
	playerHistory.log(cid, PH_LOG_BATTLEGROUND_WIN, {["rating"] = rating})
end

function playerHistory.logBattlegroundLost(cid, rating)
	playerHistory.log(cid, PH_LOG_BATTLEGROUND_LOST, {["rating"] = rating})
end

function playerHistory.logBattlegroundDraw(cid, rating)
	playerHistory.log(cid, PH_LOG_BATTLEGROUND_DRAW, {["rating"] = rating})
end

--[[
	ACHIEVEMENTS
]]--

function playerHistory.achievBattlegroundRankBrave(cid)
	playerHistory.notifyAchievement(cid, "[Façanha alcançada] Rank - Bravo: Conquistou 1.000 pontos (rating) de classificação em Battlegrounds!")
	playerHistory.addAchievement(cid, PH_ACH_BATTLEGROUND_RANK_BRAVE)
end

function playerHistory.hasAchievBattlegroundRankBrave(cid)
	return playerHistory.hasAchievement(cid, PH_ACH_BATTLEGROUND_RANK_BRAVE)
end

function playerHistory.achievBattlegroundRankVeteran(cid)
	playerHistory.notifyAchievement(cid, "[Façanha alcançada] Rank - Veterano: Conquistou 1.500 pontos (rating) de classificação em Battlegrounds!")
	playerHistory.addAchievement(cid, PH_ACH_BATTLEGROUND_RANK_VETERAN)
end

function playerHistory.hasAchievBattlegroundRankVeteran(cid)
	return playerHistory.hasAchievement(cid, PH_ACH_BATTLEGROUND_RANK_VETERAN)
end

function playerHistory.achievBattlegroundRankLegend(cid)
	playerHistory.notifyAchievement(cid, "[Façanha alcançada] Rank - Lenda: Conquistou 2.000 pontos (rating) de classificação em Battlegrounds!")
	playerHistory.addAchievement(cid, PH_ACH_BATTLEGROUND_RANK_LEGEND)
end

function playerHistory.hasAchievBattlegroundRankLegend(cid)
	return playerHistory.hasAchievement(cid, PH_ACH_BATTLEGROUND_RANK_LEGEND)
end

function playerHistory.achievBattlegroundInsaneKiller(cid)
	playerHistory.notifyAchievement(cid, "[Façanha alcançada] Matador insano! Derrotou 25 oponentes sem ser derrotado nenhuma vez em Battlegrounds!")
	playerHistory.addAchievement(cid, PH_ACH_BATTLEGROUND_INSANE_KILLER)
end

function playerHistory.hasAchievBattlegroundInsaneKiller(cid)
	return playerHistory.hasAchievement(cid, PH_ACH_BATTLEGROUND_INSANE_KILLER)
end

function playerHistory.achievBattlegroundPerfect(cid)
	playerHistory.notifyAchievement(cid, "[Façanha alcançada] Efetuou a Battleground perfeita ao vencer pelo placar de 50 pontos a 0!")
	playerHistory.addAchievement(cid, PH_ACH_BATTLEGROUND_PERFECT)
end

function playerHistory.hasAchievBattlegroundPerfect(cid)
	return playerHistory.hasAchievement(cid, PH_ACH_BATTLEGROUND_PERFECT)
end