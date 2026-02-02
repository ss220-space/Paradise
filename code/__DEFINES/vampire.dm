#define SUBCLASS_HEMOMANCER /datum/vampire_subclass/hemomancer
#define SUBCLASS_GARGANTUA /datum/vampire_subclass/gargantua
#define SUBCLASS_UMBRAE /datum/vampire_subclass/umbrae
#define SUBCLASS_DANTALION /datum/vampire_subclass/dantalion
#define SUBCLASS_BESTIA /datum/vampire_subclass/bestia
#define SUBCLASS_ANCIENT /datum/vampire_subclass/ancient

/// Base time for bestia sucking cycle, improves with trophies
#define BESTIA_SUCK_RATE (3 SECONDS)

/// The amount of blood a vampire can drain from a person.
#define BLOOD_DRAIN_LIMIT 100
/// The number of people you need to suck to become full powered.
#define FULLPOWER_DRAINED_REQUIREMENT 8
/// The amount of blood you need to suck to get full power.
#define FULLPOWER_BLOODTOTAL_REQUIREMENT 800

/// The maximum amount a vampire can be nullified naturally.
#define VAMPIRE_NULLIFICATION_CAP 120
/// The point of nullification where vampires can no longer use abilities.
#define VAMPIRE_COMPLETE_NULLIFICATION 100

/// Nulifiaction like the new vampires
#define NEW_NULLIFICATION 1
/// Nulifiaction like the goon vampires
#define OLD_NULLIFICATION 2

/// Total blood required for a special subclass action
#define REQ_BLOOD_FOR_SUBCLASS_ACT 300

/// Amount of total blood required for BOTH vampires to have for successful diablerie act
#define DIABLERIE_REQUIRED_BLOOD_TOTAL 150
/// Maximum diablerie level vampire can have
#define DIABLERIE_COUNT_MAX 4
/// Cooldown duration reduction applied to all vampire spells per diablerie level, max is 0.2, which is 20% CDR
#define DIABLERIE_COOLDOWN_REDUCTION 0.05
