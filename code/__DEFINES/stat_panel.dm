//HEY!: This must be the same as constants.js in /tgui/packages/tgui-panel/stat

#define STAT_TEXT 0
#define STAT_BUTTON 1
#define STAT_ATOM 2
#define STAT_DIVIDER 3
#define STAT_VERB 4	//Similar to button, but multiple on 1 line
#define STAT_BLANK 5

#define STAT_SLOW_UPDATE 4	//Once every 4 seconds
#define STAT_MEDIUM_UPDATE 2	//Once every 2 seconds
#define STAT_FAST_UPDATE 1	//Once every 1 seconds

// Categories for verbs

#define STAT_OOC "OOC"
#define STAT_IC "Character"
#define STAT_DEBUG_BASE "Debug"
#define STAT_DEBUG_UTILITY "Debug.Utility"
#define STAT_DEBUG_UI "Debug.UI"
#define STAT_DEBUG_MC "Debug.MC"
#define STAT_DEBUG_ATMOS "Debug.Atmospherics"
#define STAT_DEBUG_BOMB "Debug.Explosions"
#define STAT_DEBUG_MULTIZ "Debug.MultiZ"
#define STAT_DEBUG_DYNAMIC "Debug.Dynamic"
#define STAT_DEBUG_STRESS "Debug.Performance"
#define STAT_DEBUG_PERFORMANCE "Debug.Performance"
#define STAT_DEBUG_ATOMS "Debug.Atoms"
#define STAT_DEBUG_MOBS "Debug.Mobs"
#define STAT_DEBUG_PROC "Debug.Procs"
#define STAT_DEBUG_MAPPING "Debug.Mapping"
#define STAT_MENTPR "Mentor"
#define STAT_ADMIN_BASE "Admin"
#define STAT_ANNOUNCE "Admin.Announce"
#define STAT_EVENTS "Admin.Events"
#define STAT_EVENTS_BATTLE_ROYALE "Admin.Events.Battle Royale"
#define STAT_INVESTIGATE "Admin.Investigate"
#define STAT_ADMIN_UTILITY "Admin.Utility"
#define STAT_ROUND "Admin.Round"
#define STAT_ROUND_TIME "Admin.Round.Time Management"
#define STAT_SERVER "Admin.Server"
#define STAT_DEVELOPER "Admin.Development"
#define STAT_ADMIN_PUNISHMENT "Admin.Action"
#define STAT_ADMIN_FUN "Admin.Action"
#define STAT_ADMIN_PERMISSIONS "Admin.Permissions"
#define STAT_GHOST "Ghost"
#define STAT_SANDBOX "Sandbox"

#define STAT_BLOB "Blob"
#define STAT_SWARMER "Swarmer"
#define STAT_PREFERENCES "Preferences"
#define STAT_AI "AI"
#define STAT_AI_MALF "AI.Malfunction"

// (This one is seperate since it cannot be changed and is instead just applied internally regardless of set category)
#define STAT_OBJECT "Object"
