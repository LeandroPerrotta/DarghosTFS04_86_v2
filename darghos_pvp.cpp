#include "otpch.h"
#include "darghos_pvp.h"
#include "darghos_const.h"
#include "luascript.h"
#include "game.h"

extern Game g_game;

Battleground::Battleground()
{
	ScriptEnviroment* env = LuaInterface::getEnv();

    BattlegroundTeam team_one;

    team_one.look.head = 82;
    team_one.look.body = 114;
    team_one.look.legs = 114;
    team_one.look.feet = 91;

	Thing* thing = ScriptEnviroment::getUniqueThing((uint32_t)BATTLEGROUND_TEAM_1_SPAWN);
	team_one.spawn_pos = thing->getPosition();

    teams[0] = team_one;

    BattlegroundTeam team_two;

    team_two.look.head = 77;
    team_two.look.body = 94;
    team_two.look.legs = 94;
    team_two.look.feet = 79;

	thing = ScriptEnviroment::getUniqueThing(BATTLEGROUND_TEAM_2_SPAWN);
	team_two.spawn_pos = thing->getPosition();

    teams[1] = team_two;

    open = true;
}

Battleground::~Battleground()
{

}

bool Battleground::addTeam(const Position spawn_pos, BattlegroundTeamLook look)
{

}

bool Battleground::onPlayerJoin(Player* player)
{
    if(!isOpen())
        return false;

	uint8_t btid = (teams[0].players.size() > teams[1].players.size()) ? 1 : 0;
    BattlegroundTeam team = teams[btid];

	player->setBattlegroundTeam(btid);

	Outfit_t player_outfit = player->getCreature()->getCurrentOutfit();

	player_outfit.lookHead = team.look.body;
	player_outfit.lookBody = team.look.body;
	player_outfit.lookLegs = team.look.legs;
	player_outfit.lookFeet = team.look.feet;

	player->changeOutfit(player_outfit, false);

	const Position& oldPos = player->getPosition();

	g_game.internalTeleport(player, team.spawn_pos, true);
	g_game.addMagicEffect(oldPos, MAGIC_EFFECT_TELEPORT);

	team.players.push_back(player);

    return true;
}
