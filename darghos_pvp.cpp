#include "otpch.h"
#include "darghos_pvp.h"
#include "luascript.h"
#include "game.h"
#include "creature.h"

extern Game g_game;

Battleground::Battleground()
{
	open = false;
}

Battleground::~Battleground()
{

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

bool Battleground::onPlayerJoin(Player* player)
{
    if(!isOpen())
        return false;

	Bg_Teams_t team_id = (teamsMap[BATTLEGROUND_TEAM_ONE].players.size() > teamsMap[BATTLEGROUND_TEAM_TWO].players.size()) ? BATTLEGROUND_TEAM_TWO : BATTLEGROUND_TEAM_ONE;
	Bg_Team_t team = teamsMap[team_id];

	player->setBattlegroundTeam(team_id);

	Bg_PlayerInfo_t playerInfo;
	playerInfo.player = player;
	playerInfo.join_in = time(NULL);

	Outfit_t player_outfit = player->getCreature()->getCurrentOutfit();
	playerInfo.default_outfit = player_outfit;

	player_outfit.lookHead = team.look.head;
	player_outfit.lookBody = team.look.body;
	player_outfit.lookLegs = team.look.legs;
	player_outfit.lookFeet = team.look.feet;

	player->changeOutfit(player_outfit, false);
	g_game.internalCreatureChangeOutfit(player->getCreature(), player_outfit);

	playerInfo.masterPosition = player->getMasterPosition();
	player->setMasterPosition(team.spawn_pos);

	const Position& oldPos = player->getPosition();

	g_game.internalTeleport(player, team.spawn_pos, true);
	g_game.addMagicEffect(oldPos, MAGIC_EFFECT_TELEPORT);

	addPlayer(player->getGUID(), playerInfo, team_id);
    return true;
}

bool Battleground::playerKick(Player* player)
{

	Bg_Teams_t team_id = player->getBattlegroundTeam();
	Bg_Team_t team = teamsMap[team_id];
	Bg_PlayerInfo_t playerInfo = team.players[player->getGUID()];

	if((playerInfo.join_in + PLAYER_LEAVE_TIME_LIMIT) > time(NULL))
		return false;

	player->setBattlegroundTeam(BATTLEGROUND_TEAM_NONE);

	Outfit_t outfit_default = playerInfo.default_outfit;
	player->changeOutfit(outfit_default, false);
	g_game.internalCreatureChangeOutfit(player->getCreature(), outfit_default);

	player->setMasterPosition(playerInfo.masterPosition);

	const Position& oldPos = player->getPosition();
	g_game.internalTeleport(player, leave_pos, true);
	g_game.addMagicEffect(oldPos, MAGIC_EFFECT_TELEPORT);

	removePlayer(player->getGUID(), team_id);

	return true;
}

void Battleground::onPlayerDeath(Player* player, DeathList deathList)
{
	Bg_Teams_t team_id = player->getBattlegroundTeam();
	Bg_DeathEntry_t deahsEntry;
	deahsEntry.date = time(NULL);

	bool validate = (deathList.size() >= 3) ? false : true;

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
			g_game.addAnimatedText(tmp->getPosition(), COLOR_DARKRED, "FRAG!");
		}
		else
		{
			deahsEntry.assists.push_back(tmp->getGUID());
		}
	}

	addDeathEntry(player->getGUID(), deahsEntry);
}

bool Battleground::isValidKiller(uint32_t killer_id, uint32_t target)
{
	time_t timeLimit = time(NULL) - (60 * 5);
	DeathsList deathsList = deathsMap[target];

	uint8_t found = 0;

	for(DeathsList::const_iterator it = deathsList.begin(); it != deathsList.end(); it++)
	{
		Bg_DeathEntry_t deathEntry = (*it);
		if(deathEntry.lasthit == killer_id && deathEntry.date > timeLimit)
			found++;
	}

	if(found >= LIMIT_FRAGS_SAME_TARGET)
		return false;

	return true;
}

void Battleground::addDeathEntry(uint32_t player_id, Bg_DeathEntry_t deathEntry)
{
	std::map<uint32_t, DeathsList>::iterator it;
	it = deathsMap.find(player_id);
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