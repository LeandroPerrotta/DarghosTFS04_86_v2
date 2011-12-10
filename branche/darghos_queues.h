#ifdef __DARGHOS_CUSTOM__
#ifndef __DARGHOS_QUEUES__
#define __DARGHOS_QUEUES__

#include "player.h"
#include "darghos_dungeons.h"

class Queues
{
    public:
        Queues();
        ~Queues();

#ifdef __DARGHOS_DUNGEONS_SYSTEM__
        bool pushDungeon(DungeonID id, Queue* queue);
        bool popDungeon(DungeonID id);
        Queue* findDungeon(DungeonID id);
#endif

    protected:

    private:

#ifdef __DARGHOS_DUNGEONS_SYSTEM__
        Queue* randomDungeonQueue;

        //specific
        typedef std::map<DungeonID, Queue*> DungeonQueueMap;
        DungeonQueueMap dungeonQueues;
#endif

        //Queue* randomBattlegroundQueue;

        //typedef std::map<BattlegroundID, Queue*> BattlegroundQueueMap;
        //BattlegroundQueueMap battlegroundQueues;
}

struct PlayerSlot_t
{
    Player* player;
    Role_t role;
}

class QueueSlot
{
    public:
        QueueSlot(SlotRoleTemplate_t roleTemplate = SLOT_TEMPLATE_NONE);
        ~QueueSlot;

    private:
        typedef std::list<PlayerSlot_t*> PlayerSlotList_t
        PlayerSlotList_t playersList;

        SlotTemplateRule_t roleTemplate;
}

class Queue
{
    public:
        Queue();
        ~Queue();

        bool pushSlot(QueueSlot* queueSlot);
        bool pushPlayer(Player* player, Role_t role = ROLE_NONE);
        bool groupIsValid(PlayerVector* vec);

    protected:

    private:
        typedef std::list<QueueSlot*> SlotList_t;
        SlotList_t slots;
}

#endif
#endif
