//Defines the general way a faction should act
#define FACTION_STATE_PASSIVE 0
#define FACTION_STATE_FRIENDLY 1
#define FACTION_STATE_NEUTRAL 2
#define FACTION_STATE_AGGRESSIVE 3
#define FACTION_STATE_HOSTILE 4

//Faction flags
#define FACTION_NO_REP (1 << 1)
#define FACTION_NO_MISSIONS (1 << 2)

//quest flags
#define QUEST_END_ON_COMPLETION (1 << 1)
#define QUEST_END_ON_FAILURE (1 << 2)

//Quest completion flags
#define QUEST_FAILED 0
#define QUEST_NOT_ENDED 1
#define QUEST_COMPLETED 2
