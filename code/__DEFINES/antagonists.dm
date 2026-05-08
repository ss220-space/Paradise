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
