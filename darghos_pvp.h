#ifndef __DARGHOS_PVP__
#define __DARGHOS_PVP__

#include "player.h"
#include "luascript.h"
#include "creature.h"

typedef std::vector<Player*> PlayerVector;

struct BattlegroundTeamLook
{
	BattlegroundTeamLook()
	{
		head, body, legs, feet = 0;
	}

    uint8_t head, body, legs, feet;
};

struct BattlegroundTeam {
    PlayerVector players;
    BattlegroundTeamLook look;
    Position spawn_pos;
};

typedef std::map<uint16_t, BattlegroundTeam> BattlegroundTeamMap;


class Battleground;
class Battleground : public LuaInterface
{
    public:
        Battleground();
        bool onPlayerJoin(Player* player);
        void setState(bool state){ open = state; }
        bool isOpen(){ return open; }

    private:
        bool open;
        BattlegroundTeamMap teams;
};

#endif

