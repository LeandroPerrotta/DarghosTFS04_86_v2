#ifndef __DARGHOS_PVP__
#define __DARGHOS_PVP__

#include "player.h"
#include "darghos_const.h"

#define LIMIT_TARGET_FRAGS_INTERVAL 60
#define LIMIT_TARGET_FRAGS_PER_INTERVAL 1

struct Bg_Statistic_t
{
	Bg_Statistic_t(){ player_id = kills = assists = deaths = 0; }
	uint32_t player_id, kills, assists, deaths;
};

typedef std::list<uint32_t> AssistsList;
typedef std::list<Bg_Statistic_t> StatisticsList;

struct Bg_DeathEntry_t
{
	uint32_t lasthit;
	time_t date;
	AssistsList assists;
};

typedef std::list<Bg_DeathEntry_t> DeathsList;
typedef std::map<uint32_t, DeathsList> DeathsMap;

struct Bg_PlayerInfo_t
{
	Player* player;
	Outfit_t default_outfit;
	Position masterPosition;
	uint16_t kills, assists, deaths;
};

struct Bg_TeamLook_t
{
    uint8_t head, body, legs, feet;
};

typedef std::map<uint32_t, Bg_PlayerInfo_t> PlayersMap;

struct Bg_Team_t {
    PlayersMap players;
    Bg_TeamLook_t look;
    Position spawn_pos;
};

typedef std::map<Bg_Teams_t, Bg_Team_t> BgTeamsMap;

class Game;

class Battleground
{
    public:
        Battleground();
		virtual ~Battleground();

		void onInit();

		void setOpen(){ open = true; }
		void setClosed() { open = false; onClose(); }
        bool isOpen(){ return open; }	
		void onClose();

        BattlegrondRetValue onPlayerJoin(Player* player);
		BattlegrondRetValue playerKick(Player* player, bool force = false);
		void onPlayerDeath(Player* killer, DeathList deathList);
		PlayersMap listPlayersOfTeam(Bg_Teams_t team);
       
		StatisticsList getStatistics();
		void clearStatistics(){ statisticsList.clear(); }

    private:
        bool open;
		DarghosPvpTypes type;
        BgTeamsMap teamsMap;
		DeathsMap deathsMap;
		StatisticsList statisticsList;
		Position leave_pos;

		void addDeathEntry(uint32_t player_id, Bg_DeathEntry_t deathEntry);
		bool isValidKiller(uint32_t killer_id, uint32_t target);

		void incrementPlayerKill(uint32_t player_id);
		void incrementPlayerDeaths(uint32_t player_id);
		void incrementPlayerAssists(uint32_t player_id);

		bool storePlayerKill(uint32_t player_id, bool lasthit);
		bool storePlayerDeath(uint32_t player_id);

		static bool order(Bg_Statistic_t first, Bg_Statistic_t second);
};

#endif