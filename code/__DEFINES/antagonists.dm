#define NUKESCALINGMODIFIER 6
#define NUKERS_COUNT 5

// Heretic path defines.
#define PATH_START "Start Path"
#define PATH_SIDE "Side Path"
#define PATH_ASH "Ash Path"
#define PATH_RUST "Rust Path"
#define PATH_FLESH "Flesh Path"
#define PATH_VOID "Void Path"
#define PATH_BLADE "Blade Path"
#define PATH_COSMIC "Cosmic Path"
#define PATH_LOCK "Lock Path"
#define PATH_MOON "Moon Path"

//Heretic knowledge tree defines
#define HKT_NEXT "next"
#define HKT_BAN "ban"
#define HKT_DEPTH "depth"
#define HKT_ROUTE "route"
#define HKT_UI_BGR "ui_bgr"


/// Defines are used in /proc/has_living_heart() to report if the heretic has no heart period, no living heart, or has a living heart.
#define HERETIC_NO_HEART_ORGAN -1
#define HERETIC_NO_LIVING_HEART 0
#define HERETIC_HAS_LIVING_HEART 1

/// A define used in ritual priority for heretics.
#define MAX_KNOWLEDGE_PRIORITY 100

#define FACTION_HERETIC "heretic"
#define FACTION_HOSTILE "hostile"

/// Checks if the passed mob can become a heretic ghoul.
/// - Must be a human (type, not species)
/// - Skeletons cannot be husked (they are snowflaked instead of having a trait)
/// - Monkeys are monkeys, not quite human (balance reasons)
#define IS_VALID_GHOUL_MOB(mob) (ishuman(mob) && !isskeleton(mob) && !ismonkey(mob))

/// JSON string file for all of our heretic influence flavors
#define HERETIC_INFLUENCE_FILE "heretic_influences.json"

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
