#include "otpch.h"
#include "darghos_pvp.h"
#include "luascript.h"
#include "game.h"
#include "creature.h"

extern Game g_game;

Battleground::Battleground()
{
	open = false;
	type = PVP_SIMPLE_BATTLEGROUND;
}

Battleground::~Battleground()
{

}

void Battleground::onClose()
{
	for(BgTeamsMap::iterator it_teams = teamsMap.begin(); it_teams != teamsMap.end(); it_teams++)
	{
		for(PlayersMap::iterator it_players = it_teams->second.players.begin(); it_players != it_teams->second.players.end(); it_players++)
		{
			playerKick(it_players->second.player, true);
		}
	}

	clearStatistics();
}

void Battleground::onInit()
{
	Thing* thing = ScriptEnviroment::getUniqueThing((uint32_t)BATTLEGROUND_LEAVE_POINT);
	if(thing)
		leave_pos = thing->getPosition();

    Bg_Team_t team_one;

    team_one.look.head = 82;
    team_one.look.body = 114;
    team_one.look.legs = 114;
    team_one.look.feet = 91;

	thing = ScriptEnviroment::getUniqueThing((uint32_t)BATTLEGROUND_TEAM_1_SPAWN);
	if(thing)
		team_one.spawn_pos = thing->getPosition();

	teamsMap.insert(std::make_pair(BATTLEGROUND_TEAM_ONE, team_one));

    Bg_Team_t team_two;

    team_two.look.head = 77;
    team_two.look.body = 94;
    team_two.look.legs = 94;
    team_two.look.feet = 79;

	thing = ScriptEnviroment::getUniqueThing((uint32_t)BATTLEGROUND_TEAM_2_SPAWN);
	if(thing)
		team_two.spawn_pos = thing->getPosition();

	teamsMap.insert(std::make_pair(BATTLEGROUND_TEAM_TWO, team_two));

    open = true;
}

Bg_Teams_t Battleground::sortTeam()
{
	if(teamsMap[BATTLEGROUND_TEAM_ONE].players.size() <  teamsMap[BATTLEGROUND_TEAM_TWO].players.size())
		return BATTLEGROUND_TEAM_ONE;
	else if(teamsMap[BATTLEGROUND_TEAM_TWO].players.size() < teamsMap[BATTLEGROUND_TEAM_ONE].players.size())
		return BATTLEGROUND_TEAM_ONE;
	else if(teamsMap[BATTLEGROUND_TEAM_TWO].players.size() == teamsMap[BATTLEGROUND_TEAM_ONE].players.size())
		return (Bg_Teams_t)random_range((uint32_t)BATTLEGROUND_TEAM_ONE, (uint32_t)BATTLEGROUND_TEAM_ONE);
}

BattlegrondRetValue Battleground::onPlayerJoin(Player* player)
{
    if(!isOpen())
        return BATTLEGROUND_CLOSED;

	time_t lastLeave;
	std::string tmpStr;
	if(player->getStorage(DARGHOS_STORAGE_LAST_BATTLEGROUND_LEAVE, tmpStr)) lastLeave = atoi(tmpStr.c_str());

	if(lastLeave + LIMIT_TARGET_FRAGS_INTERVAL > time(NULL))
		return BATTLEGROUND_CAN_NOT_LEAVE_OR_JOIN;


	Bg_Teams_t team_id = sortTeam();
	Bg_Team_t* team = &teamsMap[team_id];

	player->setBattlegroundTeam(team_id);

	Bg_PlayerInfo_t playerInfo;
	playerInfo.player = player;

	Outfit_t player_outfit = player->getCreature()->getCurrentOutfit();
	playerInfo.default_outfit = player_outfit;

	player_outfit.lookHead = team->look.head;
	player_outfit.lookBody = team->look.body;
	player_outfit.lookLegs = team->look.legs;
	player_outfit.lookFeet = team->look.feet;

	player->changeOutfit(player_outfit, false);
	g_game.internalCreatureChangeOutfit(player->getCreature(), player_outfit);

	playerInfo.masterPosition = player->getMasterPosition();
	player->setMasterPosition(team->spawn_pos);

	const Position& oldPos = player->getPosition();

	g_game.internalTeleport(player, team->spawn_pos, true);
	g_game.addMagicEffect(oldPos, MAGIC_EFFECT_TELEPORT);

	std::stringstream ss;
	ss << time(NULL);
	player->setStorage(DARGHOS_STORAGE_LAST_BATTLEGROUND_JOIN, ss.str());
	player->eraseStorage(DARGHOS_STORAGE_LAST_BATTLEGROUND_LEAVE);

	team->players.insert(std::make_pair(player->getGUID(), playerInfo));
    return BATTLEGROUND_NO_ERROR;
}

BattlegrondRetValue Battleground::playerKick(Player* player, bool force)
{

	Bg_Teams_t team_id = player->getBattlegroundTeam();
	Bg_Team_t* team = &teamsMap[team_id];
	PlayersMap::iterator it = team->players.find(player->getGUID());
	Bg_PlayerInfo_t playerInfo = it->second;

	time_t lastJoin;
	std::string tmpStr;
	if(player->getStorage(DARGHOS_STORAGE_LAST_BATTLEGROUND_JOIN, tmpStr)) lastJoin = atoi(tmpStr.c_str());

	if(!force && lastJoin + LIMIT_TARGET_FRAGS_INTERVAL > time(NULL))
		return BATTLEGROUND_CAN_NOT_LEAVE_OR_JOIN;

	player->setBattlegroundTeam(BATTLEGROUND_TEAM_NONE);

	Outfit_t outfit_default = playerInfo.default_outfit;
	player->changeOutfit(outfit_default, false);
	g_game.internalCreatureChangeOutfit(player->getCreature(), outfit_default);

	player->setMasterPosition(playerInfo.masterPosition);

	const Position& oldPos = player->getPosition();
	g_game.internalTeleport(player, leave_pos, true);
	g_game.addMagicEffect(oldPos, MAGIC_EFFECT_TELEPORT);

	std::stringstream ss;
	ss << time(NULL);
	player->setStorage(DARGHOS_STORAGE_LAST_BATTLEGROUND_LEAVE, ss.str());
	player->eraseStorage(DARGHOS_STORAGE_LAST_BATTLEGROUND_JOIN);

	team->players.erase(player->getGUID());
	deathsMap.erase(player->getGUID());
	return BATTLEGROUND_NO_ERROR;
}

void Battleground::onPlayerDeath(Player* player, DeathList deathList)
{
	Bg_Teams_t team_id = player->getBattlegroundTeam();
	Bg_DeathEntry_t deahsEntry;
	deahsEntry.date = time(NULL);

	bool validate = (deathList.size() >= 3) ? false : true;

	Player* killer = NULL;
	Player* tmp = NULL;
	for(DeathList::iterator it = deathList.begin(); it != deathList.end(); ++it)
	{
		if(it->getKillerCreature()->getPlayer())
			tmp = it->getKillerCreature()->getPlayer();
		else if(it->getKillerCreature()->getPlayerMaster())
			tmp = it->getKillerCreature()->getMaster()->getPlayer();

		if(it == deathList.begin())
		{
			if(tmp->getBattlegroundTeam() == team_id)
				return;

			if(validate && !isValidKiller(tmp->getGUID(), player->getGUID()))
				return;

			deahsEntry.lasthit = tmp->getGUID();
			killer = tmp;
			incrementPlayerKill(tmp->getGUID());
			incrementPlayerAssists(tmp->getGUID());
			storePlayerKill(tmp->getGUID(), true);
		}
		else
		{
			incrementPlayerAssists(tmp->getGUID());
			deahsEntry.assists.push_back(tmp->getGUID());
			storePlayerKill(tmp->getGUID(), false);
		}
	}

	incrementPlayerDeaths(player->getGUID());
	addDeathEntry(player->getGUID(), deahsEntry);

	bool deny = false;
	CreatureEventList bgFragEvents = killer->getCreatureEvents(CREATURE_EVENT_BG_FRAG);
	for(CreatureEventList::iterator it = bgFragEvents.begin(); it != bgFragEvents.end(); ++it)
	{
		if(!(*it)->executeBgFrag(killer, player))
			deny = true;
	}

	//if(deny)
}

bool Battleground::isValidKiller(uint32_t killer_id, uint32_t target)
{
	time_t timeLimit = time(NULL) - LIMIT_TARGET_FRAGS_INTERVAL;
	DeathsList deathsList = deathsMap[target];

	uint8_t found = 0;

	for(DeathsList::const_iterator it = deathsList.begin(); it != deathsList.end(); it++)
	{
		Bg_DeathEntry_t deathEntry = (*it);
		if(deathEntry.lasthit == killer_id && deathEntry.date > timeLimit)
			found++;
	}

	if(found >= LIMIT_TARGET_FRAGS_PER_INTERVAL)
		return false;

	if(found == 0 && deathsList.size() > 0)
	{
		deathsMap.erase(target);
	}

	return true;
}

void Battleground::addDeathEntry(uint32_t player_id, Bg_DeathEntry_t deathEntry)
{
	DeathsMap::iterator it = deathsMap.find(player_id);
	if(it == deathsMap.end())
	{
		DeathsList deathList;
		deathList.push_back(deathEntry);

		deathsMap.insert(std::make_pair(player_id, deathList));
	}
	else
	{
		deathsMap[player_id].push_back(deathEntry);
	}
}

void Battleground::incrementPlayerKill(uint32_t player_id)
{
	for(StatisticsList::iterator it = statisticsList.begin(); it != statisticsList.end(); it++)
	{
		Bg_Statistic_t playerStatistic = (*it);
		if(it->player_id == player_id)
		{
			it->kills++;
			return;
		}
	}

	Bg_Statistic_t playerStatistic;
	playerStatistic.player_id = player_id;
	playerStatistic.kills++;
	statisticsList.push_back(playerStatistic);
}

void Battleground::incrementPlayerDeaths(uint32_t player_id)
{
	for(StatisticsList::iterator it = statisticsList.begin(); it != statisticsList.end(); it++)
	{
		if(it->player_id == player_id)
		{
			it->deaths++;
			return;
		}
	}

	Bg_Statistic_t playerStatistic;
	playerStatistic.player_id = player_id;
	playerStatistic.deaths++;
	statisticsList.push_back(playerStatistic);

	storePlayerDeath(player_id);
}

void Battleground::incrementPlayerAssists(uint32_t player_id)
{
	for(StatisticsList::iterator it = statisticsList.begin(); it != statisticsList.end(); it++)
	{
		if(it->player_id == player_id)
		{
			it->assists++;
			return;
		}
	}

	Bg_Statistic_t playerStatistic;
	playerStatistic.player_id = player_id;
	playerStatistic.assists++;
	statisticsList.push_back(playerStatistic);
}

bool Battleground::storePlayerKill(uint32_t player_id, bool lasthit)
{
	Database* db = Database::getInstance();
	DBQuery query;
	query << "INSERT INTO `custom_pvp_kills` (`player_id`, `is_frag`, `date`, `type`) VALUES (" << player_id << ", " << ((lasthit) ? 1 : 0) << ", " << time(NULL) << ", " << type << ")";
	if(!db->query(query.str()))
		return false;

	return true;
}

bool Battleground::storePlayerDeath(uint32_t player_id)
{
	Database* db = Database::getInstance();
	DBQuery query;

	query << "INSERT INTO `custom_pvp_deaths` (`player_id`, `date`, `type`) VALUES (" << player_id << ", " << time(NULL) << ", " << type << ")";
	if(!db->query(query.str()))
		return false;

	return true;
}

bool Battleground::order(Bg_Statistic_t first, Bg_Statistic_t second)
{
	if(first.kills == second.kills) return (first.deaths < second.deaths) ? true : false;
	else return (first.kills > second.kills) ? true : false;
}

StatisticsList Battleground::getStatistics()
{
	statisticsList.sort(Battleground::order);
	return statisticsList;
}

PlayersMap Battleground::listPlayersOfTeam(Bg_Teams_t team)
{
	BgTeamsMap::iterator it = teamsMap.find(team);

	PlayersMap playersMap;
	if(it == teamsMap.end())
		return playersMap;

	playersMap = it->second.players;
	return playersMap;
}