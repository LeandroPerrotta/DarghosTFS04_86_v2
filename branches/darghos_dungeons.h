#ifdef __DARGHOS_DUNGEONS_SYSTEM__
#ifndef __DARGHOS_DUNGEONS__
#define __DARGHOS_DUNGEONS__

typedef uint16_t DungeonID;
typedef uint16_t DungeonProfileID;
typedef std::map<DungeonID, Dungeon*> DungeonMap;

struct DungeonProfile
{
    DungeonProfileID id;
    uint16_t size;

    uint32_t minLevel;
    uint32_t recMinLevel;
    uint32_t recMaxLevel;
    uint32_t maxLevel;

    DungeonMap* list;
}

class Dungeons
{
    public:
        Dungeons();
        ~Dungeons();

        bool push(Dungeon* dungeon);
        bool pop(DungeonID id);
        Dungeon* find(DungeonID id);

        bool pushProfile(DungeonProfile* profile);
        bool popProfile(DungeonProfileID profile_id);
        bool useProfile(DungeonProfileID profile_id, Dungeon* dungeon);


    protected:

    private:
        DungeonMap dungeons;

        typedef std::map<DungeonProfileID, DungeonProfile*> ProfileList;
        ProfileList randomDungeons;
}

class Dungeon
{
    public:
        Dungeon();
        ~Dungeon();

        bool isFree();
        bool isEnable();

        void setSize(uint16_t size);

    protected:

    private:
        DungeonID id;
        DungeonState_t state;

        uint16_t duration;
        uint16_t size;

    friend class Dungeons:
}

#endif // __DARGHOS_DUNGEONS__
#endif
