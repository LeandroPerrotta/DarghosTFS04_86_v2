#ifdef __DARGHOS_PVP_SYSTEM__
#ifndef __DARGHOS_PVP__
#define __DARGHOS_PVP__

#include "player.h"
#include "darghos_const.h"

#define LIMIT_TARGET_FRAGS_INTERVAL 60
#define LIMIT_TARGET_FRAGS_PER_INTERVAL 1
#define PVP_CHANNEL_ID 10

typedef std::list<Player*> Bg_Waitlist_t;

struct Bg_Statistic_t
{
	Bg_Statistic_t(){ 
		player_id = kills = assists = deaths = 0; 
	}

	uint32_t player_id, kills, assists, deaths;
};

typedef std::list<uint32_t> AssistsList;
typedef std::list<Bg_Statistic_t*> StatisticsList;

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
	time_t join_in;
	Outfit_t default_outfit;
	Position masterPosition;
	Position oldPosition;
	bool areInside;
	Bg_Statistic_t statistics;
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
	uint32_t points;
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

		bool buildTeams();
		Bg_Teams_t sortTeam();

		BgTeamsMap getTeams(){ return teamsMap; }
		void finish(Bg_Teams_t teamWinner);
		void finish();

		uint32_t getWaitlistSize(){ return waitlist.size(); }

        BattlegrondRetValue onPlayerJoin(Player* player);
		BattlegrondRetValue kickPlayer(Player* player, bool force = false);
		void onPlayerDeath(Player* killer, DeathList deathList);
		PlayersMap listPlayersOfTeam(Bg_Teams_t team);
		Bg_PlayerInfo_t* findPlayerInfo(Player* player);
		Bg_Teams_t findTeamIdByPlayer(Player* player);
		Bg_Team_t* findPlayerTeam(Player* player);
		void putInTeam(Player* player, Bg_Teams_t team_id);
		void putInside(Player* player);
		void start();
		bool playerIsInWaitlist(Player* player);
		void removeWaitlistPlayer(Player* player);
		void setTeamSize(uint32_t size){ teamSize = size; }
		void setWinPoints(uint32_t points){ winPoints = points; }
		void setDuration(uint32_t seconds){ duration = (seconds * 1000); }
       
		StatisticsList getStatistics();
		void clearStatistics(){ statisticsList.clear(); }
		
		static bool orderStatisticsListByPerformance(Bg_Statistic_t* first, Bg_Statistic_t* second) {
			if(first->kills == second->kills) return (first->deaths < second->deaths) ? true : false;
			else return (first->kills > second->kills) ? true : false;		
		}

		static bool orderWaitlistByLevel(Player* first, Player* second);		

    private:
        bool open;
		DarghosPvpTypes type;
		BattlegroundStatus status;
        BgTeamsMap teamsMap;
		DeathsMap deathsMap;
		StatisticsList statisticsList;
		time_t lastInit;
		Bg_Waitlist_t waitlist;
		uint32_t lastID;
		uint32_t teamSize;
		uint32_t winPoints;
		uint32_t duration;

		uint32_t endEvent;

		void callPlayer(Player* player);

		void addDeathEntry(uint32_t player_id, Bg_DeathEntry_t deathEntry);
		bool isValidKiller(uint32_t killer_id, uint32_t target);

		void incrementPlayerKill(Bg_PlayerInfo_t* playerInfo);
		void incrementPlayerDeaths(Bg_PlayerInfo_t* playerInfo);
		void incrementPlayerAssists(Bg_PlayerInfo_t* playerInfo);

		bool storeNew();
		bool storeFinish(time_t end, uint32_t finishBy, uint32_t team1_points, uint32_t team2_points);
		bool storePlayerJoin(uint32_t player_id, Bg_Teams_t team_id);
		bool storePlayerDeserter(uint32_t player_id);

		bool storePlayerKill(uint32_t player_id, bool lasthit);
		bool storePlayerDeath(uint32_t player_id);
};

#endif
#endif