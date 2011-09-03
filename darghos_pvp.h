#ifndef __DARGHOS_PVP__
#define __DARGHOS_PVP__

#include "player.h"

#define PLAYER_LEAVE_TIME_LIMIT 60

struct Bg_TeamLook_t
{
    uint8_t head, body, legs, feet;
};

struct Bg_PlayerInfo_t
{
	Player* player;
	time_t join_in;
	Outfit_t default_outfit;
};

struct Bg_Team_t {
    PlayersMap players;
    Bg_TeamLook_t look;
    Position spawn_pos;
};

typedef std::map<uint32_t, Bg_PlayerInfo_t> PlayersMap;
typedef std::map<Bg_Teams_t, Bg_Team_t> BgTeamsMap;

class Game;

class Battleground
{
    public:
        Battleground();
		virtual ~Battleground();
        bool onPlayerJoin(Player* player);
		bool playerKick(Player* player);
        void setState(bool state){ open = state; }
        bool isOpen(){ return open; }
		void onInit();

    private:
        bool open;
        BgTeamsMap teamsMap;
		Position leave_pos;
};

#endif

