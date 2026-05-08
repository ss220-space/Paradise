#define NUKESCALINGMODIFIER 6
#define NUKERS_COUNT 5

/// How long till a spessman should come back after being captured and sent to the holding facility (which some antags use)
#define COME_BACK_FROM_CAPTURE_TIME 6 MINUTES

// Various abductor equipment modes.
#define VEST_STEALTH 1
#define VEST_COMBAT 2

#define GIZMO_SCAN 1
#define GIZMO_MARK 2

#define MIND_DEVICE_MESSAGE 1
#define MIND_DEVICE_CONTROL 2

/// Time before changeling can revive himself.
#define LING_FAKEDEATH_TIME 60 SECONDS
/// The lowest value of genetic_damage [/datum/antagonist/changeling/process()] can take it to while dead.
#define LING_DEAD_GENETIC_DAMAGE_HEAL_CAP 50
/// The amount of recent spoken lines to gain on absorbing a mob
#define LING_ABSORB_RECENT_SPEECH 8
/// Denotes that this power is free and should be given to all changelings by default.
#define CHANGELING_INNATE_POWER "changeling_innate_power"
/// Denotes that this power can only be obtained by purchasing it.
#define CHANGELING_PURCHASABLE_POWER "changeling_purchasable_power"
/// Denotes that this power can not be obtained normally. Primarily used for base types such as [/datum/action/changeling/weapon].
#define CHANGELING_UNOBTAINABLE_POWER "changeling_unobtainable_power"

//All objective types. They were used in /code/datums/mind.dm.
#define OBJ_TYPE_ASSASSINATE "assassinate"
#define OBJ_TYPE_SUPERMATTER_CASCADE "supermatter cascade"
#define OBJ_TYPE_PREVENT_FROM_ESCAPE "prevent from escape"
#define OBJ_TYPE_PAIN_HUNTER "pain hunter"
#define OBJ_TYPE_STEAL_BRAIN "steal brain"
#define OBJ_TYPE_PROTECT "protect"
#define OBJ_TYPE_ESCAPE "escape"
#define OBJ_TYPE_SURVIVE "survive"
#define OBJ_TYPE_DIE "die"
#define OBJ_TYPE_STEAL "steal"
#define OBJ_TYPE_THIEF_HARD "thief hard"
#define OBJ_TYPE_THIEF_MEDIUM "thief medium"
#define OBJ_TYPE_THIEF_COLLECT "thief collect"
#define OBJ_TYPE_THIEF_PET "thief pet"
#define OBJ_TYPE_THIEF_STRUCTURE "thief structure"
#define OBJ_TYPE_DOWNLOAD "download"
#define OBJ_TYPE_NUCLEAR "nuclear"
#define OBJ_TYPE_CAPTURE "capture"
#define OBJ_TYPE_BLOOD "blood"
#define OBJ_TYPE_ABSORB "absorb"
#define OBJ_TYPE_DESTROY "destroy"
#define OBJ_TYPE_IDENTITY_THEFT "identity theft"
#define OBJ_TYPE_HIJACK "hijack"
#define OBJ_TYPE_KILL_ALL_HUMANS "kill all humans"
#define OBJ_TYPE_GET_MONEY "get money"
#define OBJ_TYPE_FIND_AND_SCAN "find and scan"
#define OBJ_TYPE_SET_UP "set up"
#define OBJ_TYPE_RESEARCH_CORRUPT "research corrupt"
#define OBJ_TYPE_AI_CORRUPT "ai corrupt"
#define OBJ_TYPE_PLANT_EXPLOSIVE "plant explosive"
#define OBJ_TYPE_CYBORG_HIJACK "cyborg hijack"
#define OBJ_TYPE_CUSTOM "custom"
