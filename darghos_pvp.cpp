#ifdef __DARGHOS_PVP_SYSTEM__

#include "otpch.h"
#include "darghos_pvp.h"
#include "luascript.h"
#include "game.h"
#include "creature.h"
#include "globalevent.h"

#define MIN_BATTLEGROUND_TEAM_SIZE 6
#define BATTLEGROUND_WIN_POINTS 50
#define BATTLEGROUND_END 1000 * 60 * 15

extern Game g_game;
extern GlobalEvents* g_globalEvents;

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
			kickPlayer(g_game.getPlayerByID(it_players->first), true);
		}
	}

	clearStatistics();
}

void Battleground::onInit()
{
	teamSize = MIN_BATTLEGROUND_TEAM_SIZE;
	winPoints = BATTLEGROUND_WIN_POINTS;
	duration = BATTLEGROUND_END;

    Bg_Team_t team_one;

	team_one.points = 0;

    team_one.look.head = 82;
    team_one.look.body = 114;
    team_one.look.legs = 114;
    team_one.look.feet = 91;

	Thing* thing = ScriptEnviroment::getUniqueThing((uint32_t)BATTLEGROUND_TEAM_1_SPAWN);
	if(thing)
		team_one.spawn_pos = thing->getPosition();

	teamsMap.insert(std::make_pair(BATTLEGROUND_TEAM_ONE, team_one));

    Bg_Team_t team_two;

	team_two.points = 0;

    team_two.look.head = 77;
    team_two.look.body = 94;
    team_two.look.legs = 94;
    team_two.look.feet = 79;

	thing = ScriptEnviroment::getUniqueThing((uint32_t)BATTLEGROUND_TEAM_2_SPAWN);
	if(thing)
		team_two.spawn_pos = thing->getPosition();

	teamsMap.insert(std::make_pair(BATTLEGROUND_TEAM_TWO, team_two));

    open = true;
	status = BUILDING_TEAMS;
}

void Battleground::removeWaitlistPlayer(Player* player)
{
	Bg_Waitlist_t::iterator it = std::find(waitlist.begin(), waitlist.end(), player);
	if(it != waitlist.end())
		waitlist.erase(it);
}

bool Battleground::playerIsInWaitlist(Player* player)
{
	for(Bg_Waitlist_t::iterator it = waitlist.begin(); it != waitlist.end(); it++)
	{
		if((*it) == player)
		{
			return true;
		}
	}

	return false;
}

Bg_PlayerInfo_t* Battleground::findPlayerInfo(Player* player)
{
	for(BgTeamsMap::iterator it = teamsMap.begin(); it != teamsMap.end(); it++)
	{
		PlayersMap::iterator pit = it->second.players.find(player->getID());
		if(pit != it->second.players.end())
			return &pit->second;
	}

	return NULL;
}

Bg_Teams_t Battleground::findTeamIdByPlayer(Player* player)
{
	for(BgTeamsMap::iterator it = teamsMap.begin(); it != teamsMap.end(); it++)
	{
		PlayersMap::iterator pit = it->second.players.find(player->getID());
		if(pit != it->second.players.end())
			return it->first;
	}

	return BATTLEGROUND_TEAM_NONE;
}

Bg_Team_t* Battleground::findPlayerTeam(Player* player)
{
	for(BgTeamsMap::iterator it = teamsMap.begin(); it != teamsMap.end(); it++)
	{
		if(it->first == player->getBattlegroundTeam())
			return &it->second;
	}
}

void Battleground::finish()
{
	if(teamsMap[BATTLEGROUND_TEAM_ONE].points > teamsMap[BATTLEGROUND_TEAM_TWO].points)
		finish(BATTLEGROUND_TEAM_ONE);
	else if(teamsMap[BATTLEGROUND_TEAM_ONE].points < teamsMap[BATTLEGROUND_TEAM_TWO].points)
		finish(BATTLEGROUND_TEAM_TWO);
	else
		finish(BATTLEGROUND_TEAM_NONE); //empate? raro...
}

void Battleground::finish(Bg_Teams_t teamWinner)
{
	for(BgTeamsMap::iterator it = teamsMap.begin(); it != teamsMap.end(); it++)
	{		
		for(PlayersMap::iterator it_players = it->second.players.begin(); it_players != it->second.players.end(); it_players++)
		{
			bool isWinner = false;

			Player* player = g_game.getPlayerByID(it_players->first);
			if(!player)
				continue;

			if(player->getBattlegroundTeam() == teamWinner)
				isWinner  = true;

			player->setPause(true);
			player->sendPvpChannelMessage("Você será levado ao lugar em que estava em 5 segundos...");

			Scheduler::getInstance().addEvent(createSchedulerTask(1000 * 5,
				boost::bind(&Battleground::kickPlayer, this, player, true)));

			time_t timeInBg = time(NULL) - it_players->second.join_in;
			time_t bgDuration = time(NULL) - lastInit;

			CreatureEventList bgFragEvents = player->getCreatureEvents(CREATURE_EVENT_BG_END);
			for(CreatureEventList::iterator it = bgFragEvents.begin(); it != bgFragEvents.end(); ++it)
			{
				(*it)->executeBgEnd(player, isWinner, timeInBg, bgDuration);
			}
		}
	}

	Scheduler::getInstance().stopEvent(endEvent);
	g_globalEvents->execute(GLOBALEVENT_BATTLEGROUND_END);

	BattlegroundFinishBy finishBy = (teamsMap[teamWinner].points == winPoints) ? BattlegroundFinishByPoints : BattlegroundFinishByTime;
	storeFinish(time(NULL), finishBy, teamsMap[BATTLEGROUND_TEAM_ONE].points, teamsMap[BATTLEGROUND_TEAM_TWO].points);

	clearStatistics();
	teamsMap[BATTLEGROUND_TEAM_ONE].points = 0;
	teamsMap[BATTLEGROUND_TEAM_TWO].points = 0;

	status = BUILDING_TEAMS;
	buildTeams();
}

bool Battleground::buildTeams()
{
	if(waitlist.size() < teamSize * 2)
		return false;

	if(status == STARTED || status == PREPARING)
		return false;

	waitlist.sort(Battleground::orderWaitlistByLevel);

	Bg_Teams_t team;
	Bg_Waitlist_t _tempList;

	uint16_t i = 1;
	for(Bg_Waitlist_t::iterator it = waitlist.begin(); it != waitlist.end(); it++, i++)
	{
		_tempList.push_back((*it));

		if(i == teamSize * 2)
			break;
	}

	if(_tempList.size() < teamSize * 2)
		return false;

	i = 1;
	for(Bg_Waitlist_t::iterator it = _tempList.begin(); it != _tempList.end(); it++, i++)
	{
		team = ((i & 1) == 1) ? BATTLEGROUND_TEAM_ONE : BATTLEGROUND_TEAM_TWO;

		putInTeam((*it), team);
		Scheduler::getInstance().addEvent(createSchedulerTask(1000 * 4,
			boost::bind(&Battleground::callPlayer, this, (*it))));

		removeWaitlistPlayer((*it));
	}

	status = PREPARING;
	g_globalEvents->execute(GLOBALEVENT_BATTLEGROUND_PREPARE);

	Scheduler::getInstance().addEvent(createSchedulerTask((1000 * 60 * 2) + (1000 * 5),
		boost::bind(&Battleground::start, this)));
	return true;
}

void Battleground::callPlayer(Player* player)
{
	if(!player)
		return;

	player->sendPvpChannelMessage("A battleground está pronta para iniciar! Você tem 2 minutos para digitar o comando \"!bg entrar\" para ser enviado a batalha! Boa sorte bravo guerreiro!", SPEAK_CHANNEL_O);
	player->sendFYIBox("A battleground está pronta para iniciar! Você tem 2 minutos para digitar o comando \"!bg entrar\" para ser enviado a batalha!\n\n Boa sorte bravo guerreiro!");
}

void Battleground::start()
{
	uint32_t notJoin = 0;

	lastInit = time(NULL);
	storeNew();

	for(BgTeamsMap::iterator it = teamsMap.begin(); it != teamsMap.end(); it++)
	{		
		for(PlayersMap::iterator it_players = it->second.players.begin(); it_players != it->second.players.end(); it_players++)
		{
			Player* player = g_game.getPlayerByID(it_players->first);
			if(!it_players->second.areInside)
			{								
				if(player)
					player->sendPvpChannelMessage("Você não apareceu na battleground no tempo esperado... Você ainda pode participar da batalha digitando \"!bg entrar\" novamente.");
				
				it->second.players.erase(it_players->first);
				notJoin++;
				continue;
			}

			if(player)
				storePlayerJoin(player->getGUID(), player->getBattlegroundTeam());

			it_players->second.join_in = time(NULL);
		}
	}

	status = STARTED;
	GlobalEventMap events = g_globalEvents->getEventMap(GLOBALEVENT_BATTLEGROUND_START);
	for(GlobalEventMap::iterator it = events.begin(); it != events.end(); ++it)
		it->second->executeOnBattlegroundStart(notJoin);

	endEvent = Scheduler::getInstance().addEvent(createSchedulerTask(duration,
		boost::bind(&Battleground::finish, this)));
}

Bg_Teams_t Battleground::sortTeam()
{
	if(teamsMap[BATTLEGROUND_TEAM_ONE].players.size() <  teamsMap[BATTLEGROUND_TEAM_TWO].players.size())
		return BATTLEGROUND_TEAM_ONE;
	else if(teamsMap[BATTLEGROUND_TEAM_TWO].players.size() < teamsMap[BATTLEGROUND_TEAM_ONE].players.size())
		return BATTLEGROUND_TEAM_TWO;
	else
		return (Bg_Teams_t)random_range((uint32_t)BATTLEGROUND_TEAM_ONE, (uint32_t)BATTLEGROUND_TEAM_TWO);
}

void Battleground::putInTeam(Player* player, Bg_Teams_t team_id)
{
	Bg_Team_t* team = &teamsMap[team_id];

	Bg_PlayerInfo_t playerInfo;
	playerInfo.areInside = false;

	team->players.insert(std::make_pair(player->getID(), playerInfo));
}

void Battleground::putInside(Player* player)
{
	Bg_Teams_t team_id = findTeamIdByPlayer(player);

	if(!team_id || team_id == BATTLEGROUND_TEAM_NONE)
		return;

	Bg_PlayerInfo_t* playerInfo = findPlayerInfo(player);

	if(!playerInfo)
		return;

	Bg_Team_t* team = &teamsMap[team_id];
	player->setBattlegroundTeam(team_id);

	Outfit_t player_outfit = player->getCreature()->getCurrentOutfit();
	playerInfo->default_outfit = player_outfit;

	player_outfit.lookHead = team->look.head;
	player_outfit.lookBody = team->look.body;
	player_outfit.lookLegs = team->look.legs;
	player_outfit.lookFeet = team->look.feet;

	player->changeOutfit(player_outfit, false);
	g_game.internalCreatureChangeOutfit(player->getCreature(), player_outfit);

	playerInfo->masterPosition = player->getMasterPosition();
	player->setMasterPosition(team->spawn_pos);

	const Position& oldPos = player->getPosition();
	playerInfo->oldPosition = oldPos;
	playerInfo->join_in = time(NULL);

	if(playerIsInWaitlist(player))
		removeWaitlistPlayer(player);

	g_game.internalTeleport(player, team->spawn_pos, true);
	g_game.addMagicEffect(oldPos, MAGIC_EFFECT_TELEPORT);

	Bg_Statistic_t statistic;
	statistic.player_id = player->getID();
	playerInfo->statistics = statistic;
	statisticsList.push_back(&playerInfo->statistics);

	playerInfo->areInside = true;

	if(status == STARTED)
		storePlayerJoin(player->getGUID(), team_id);
}

BattlegrondRetValue Battleground::onPlayerJoin(Player* player)
{
    if(!isOpen())
        return BATTLEGROUND_CLOSED;

	if(player->isBattlegroundDeserter())
		return BATTLEGROUND_CAN_NOT_JOIN;

	if(status == BUILDING_TEAMS)
	{
		if(playerIsInWaitlist(player))
			return BATTLEGROUND_ALREADY_IN_WAITLIST;

		waitlist.push_back(player);	
		buildTeams();

		return BATTLEGROUND_PUT_IN_WAITLIST;
	}
	else if(status == STARTED || status == PREPARING)
	{
		if(!player->isInBattleground())
		{
			Bg_Teams_t team_id = findTeamIdByPlayer(player);

			if(!team_id)
			{
				//se a bg já estiver cheia ele é colocado na fila para a proxima bg
				if(teamsMap[BATTLEGROUND_TEAM_ONE].players.size() == teamSize && teamsMap[BATTLEGROUND_TEAM_TWO].players.size() == teamSize)
				{
					if(playerIsInWaitlist(player))
						return BATTLEGROUND_ALREADY_IN_WAITLIST;

					waitlist.push_back(player);	
					return BATTLEGROUND_PUT_IN_WAITLIST;
				}

				//senão, (alguem saiu) ele é colocado na bg
				if(player->hasCondition(CONDITION_INFIGHT))
				{
					return BATTLEGROUND_INFIGHT;
				}

				team_id = sortTeam();

				putInTeam(player, team_id);
				putInside(player);
				return BATTLEGROUND_PUT_DIRECTLY;
			}
			//o jogador estava na fila, portanto já esta em um time, somente necessario o teleportar para dentro...
			else
			{
				if(player->hasCondition(CONDITION_INFIGHT))
				{
					return BATTLEGROUND_INFIGHT;
				}

				putInside(player);
				return BATTLEGROUND_PUT_INSIDE;
			}			
		}
		else
		{
			player->sendPvpChannelMessage("Você já está dentro da battleground!");
		}
	}

    return BATTLEGROUND_NO_ERROR;
}

BattlegrondRetValue Battleground::kickPlayer(Player* player, bool force)
{
	if(!player)
	{
		return BATTLEGROUND_NO_ERROR;
	}

	Bg_Teams_t team_id = player->getBattlegroundTeam();
	Bg_Team_t* team = &teamsMap[team_id];
	PlayersMap::iterator it = team->players.find(player->getID());

	if(it != team->players.end())
	{
		Bg_PlayerInfo_t playerInfo = it->second;

		if(status == STARTED && !force)
		{
			std::stringstream ss;
			ss << (time(NULL) + 60 * 10);
			player->setStorage(DARGHOS_STORAGE_BATTLEGROUND_DESERTER_UNTIL, ss.str());
			storePlayerDeserter(player->getID());
		}

		player->setBattlegroundTeam(BATTLEGROUND_TEAM_NONE);

		Outfit_t outfit_default = playerInfo.default_outfit;

		player->changeOutfit(outfit_default, false);
		g_game.internalCreatureChangeOutfit(player->getCreature(), outfit_default);

		player->setMasterPosition(playerInfo.masterPosition);

		g_game.internalTeleport(player, playerInfo.oldPosition, true);
		g_game.addMagicEffect(playerInfo.oldPosition, MAGIC_EFFECT_TELEPORT);

		statisticsList.remove(&playerInfo.statistics);

		team->players.erase(player->getID());
		deathsMap.erase(player->getID());
	}
	else
	{
		g_game.internalTeleport(player, player->getMasterPosition(), true);
		g_game.addMagicEffect(player->getMasterPosition(), MAGIC_EFFECT_TELEPORT);

		std::clog << "[Possible Crash] Player " << player->getName() << " leaving from battleground that are not inside." << std::endl;
	}

	if(player->isPause())
		player->setPause(false);

	CreatureEventList bgFragEvents = player->getCreatureEvents(CREATURE_EVENT_BG_LEAVE);
	for(CreatureEventList::iterator it = bgFragEvents.begin(); it != bgFragEvents.end(); ++it)
	{
		(*it)->executeBgLeave(player);
	}

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

		Bg_PlayerInfo_t* playerInfo = findPlayerInfo(tmp);

		if(it == deathList.begin())
		{
			if(tmp->getBattlegroundTeam() == team_id)
				return;

			if(validate && !isValidKiller(tmp->getID(), player->getID()))
				return;

			deahsEntry.lasthit = tmp->getID();
			killer = tmp;

			incrementPlayerKill(playerInfo);
			incrementPlayerAssists(playerInfo);
			storePlayerKill(tmp->getID(), true);
		}
		else
		{
			incrementPlayerAssists(playerInfo);
			deahsEntry.assists.push_back(tmp->getID());
			storePlayerKill(tmp->getID(), false);
		}
	}

	if(killer)
	{
		Bg_Team_t* team = findPlayerTeam(killer);
		team->points++;

		Bg_PlayerInfo_t* playerInfo = findPlayerInfo(player);

		incrementPlayerDeaths(playerInfo);
		addDeathEntry(player->getID(), deahsEntry);

		CreatureEventList bgFragEvents = killer->getCreatureEvents(CREATURE_EVENT_BG_FRAG);
		for(CreatureEventList::iterator it = bgFragEvents.begin(); it != bgFragEvents.end(); ++it)
		{
			(*it)->executeBgFrag(killer, player);
		}

		if(team->points >= winPoints)
			Scheduler::getInstance().addEvent(createSchedulerTask(1000,
				boost::bind(&Battleground::finish, this, killer->getBattlegroundTeam())));
	}
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

void Battleground::incrementPlayerKill(Bg_PlayerInfo_t* playerInfo)
{
	playerInfo->statistics.kills++;
}

void Battleground::incrementPlayerDeaths(Bg_PlayerInfo_t* playerInfo)
{
	playerInfo->statistics.deaths++;
	storePlayerDeath(playerInfo->statistics.player_id);
}

void Battleground::incrementPlayerAssists(Bg_PlayerInfo_t* playerInfo)
{
	playerInfo->statistics.assists++;
}

bool Battleground::storePlayerKill(uint32_t player_id, bool lasthit)
{
	Database* db = Database::getInstance();
	DBQuery query;

	Player* player = g_game.getPlayerByID(player_id);
	if(!player)
		return false;

	query << "INSERT INTO `custom_pvp_kills` (`player_id`, `is_frag`, `date`, `type`, `ref_id`) VALUES (" << player->getGUID() << ", " << ((lasthit) ? 1 : 0) << ", " << time(NULL) << ", " << type << ", " << lastID << ")";
	if(!db->query(query.str()))
		return false;

	return true;
}

bool Battleground::storePlayerDeath(uint32_t player_id)
{
	Database* db = Database::getInstance();
	DBQuery query;

	Player* player = g_game.getPlayerByID(player_id);
	if(!player)
		return false;

	query << "INSERT INTO `custom_pvp_deaths` (`player_id`, `date`, `type`, `ref_id`) VALUES (" << player->getGUID() << ", " << time(NULL) << ", " << type << ", " << lastID << ")";
	if(!db->query(query.str()))
		return false;

	return true;
}

bool Battleground::storeNew()
{
	Database* db = Database::getInstance();
	DBQuery query;

	query << "INSERT INTO `battlegrounds` (`begin`) VALUES (" << lastInit << ")";
	if(!db->query(query.str()))
		return false;

	lastID = db->getLastInsertId();

	return true;
}

bool Battleground::storeFinish(time_t end, uint32_t finishBy, uint32_t team1_points, uint32_t team2_points)
{
	Database* db = Database::getInstance();
	DBQuery query;

	query << "UPDATE `battlegrounds` SET `end` = " << end << ", `finishBy` = " << finishBy << ", `team1_points` = " << team1_points << ", team2_points = " << team2_points << " WHERE `id` = " << lastID;
	if(!db->query(query.str()))
		return false;

	return true;
}

bool Battleground::storePlayerJoin(uint32_t player_id, Bg_Teams_t team_id)
{
	Database* db = Database::getInstance();
	DBQuery query;

	query << "INSERT INTO `battleground_teamplayers` (`player_id`, `battleground_id`, `team_id`, `deserter`) VALUES (" << player_id << ", " << lastID << ", " << team_id << ", 0)";
	if(!db->query(query.str()))
		return false;

	return true;
}

bool Battleground::storePlayerDeserter(uint32_t player_id)
{
	Database* db = Database::getInstance();
	DBQuery query;

	Player* player = g_game.getPlayerByID(player_id);
	if(!player)
		return false;

	query << "UPDATE `battleground_teamplayers` SET `deserter` = 1 WHERE `player_id` = " << player->getGUID() << " AND `battleground_id` = " << lastID;
	if(!db->query(query.str()))
		return false;

	return true;
}

StatisticsList Battleground::getStatistics()
{
	statisticsList.sort(Battleground::orderStatisticsListByPerformance);
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

bool Battleground::orderWaitlistByLevel(Player* first, Player* second)
{
	return first->getLevel() > second->getLevel();
}

#endif