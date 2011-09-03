#ifndef __DARGHOS_PVP__
#define __DARGHOS_PVP__

#include "player.h"
#include "creature.h"

typedef std::vector<Player*> PlayerVector;

struct BattlegroundTeamLook
{
    uint8_t head, body, legs, feet;
};

struct BattlegroundTeam {
    PlayerVector players;
    BattlegroundTeamLook look;
    Position spawn_pos;
};

typedef std::map<uint16_t, BattlegroundTeam> BattlegroundTeamMap;

class Game;

class Battleground
{
    public:
        Battleground();
		virtual ~Battleground();
        bool onPlayerJoin(Player* player);
        void setState(bool state){ open = state; }
        bool isOpen(){ return open; }
		bool addTeam(const Position spawn_pos, BattlegroundTeamLook look);

    private:
        bool open;
        BattlegroundTeamMap teams;
};

#endif

