/// Multiplies the actually bled amount by this number for the purposes of turf reaction calculations.
#define EXOTIC_BLEED_MULTIPLIER 3

/// Natural bleed regeneration size (units per 2 sec)
#define BLOOD_REGENERATION 0.1

// Blood level damage constants
/// Damage for blood volume from BLOOD_VOLUME_PALE to BLOOD_VOLUM5E_SAFE
#define BLOOD_PALE_DAMAGE 1
/// Damage for blood volume from BLOOD_VOLUME_OKAY to BLOOD_VOLUME_PALE
#define BLOOD_OKAY_DAMAGE 2
/// Damage for blood volume from BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY
#define BLOOD_BAD_DAMAGE 4
/// Damage for blood volume from BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD
#define BLOOD_SURVIVE_DAMAGE 8

// Bledding calculation constants
/// Bleeding per embedded item (units per 2 sec)
#define EMBEDDED_ITEM_BLEEDING 0.2
/// Open bodypart bleeding (units per 2 sec)
#define OPEN_BODYPART_BLEEDING 0.75
/// Internal bleeding size (units per 2 sec)
#define BODYPART_INTERNAL_BLEEDING 0.5

/// Decrease bleeding size if no wounds (units per 2 sec)
#define BLEEDING_DECREASE 0.005
/// Multiplyer for bleeding calculate from bodypart value
#define BLEEDING_MODIFIER 0.45
/// Minimal brute damage for add bleeding
#define MIN_BRUTE_DAMAGE_FOR_BLEEDING 15
#define BRUTE_DAMAGE_FOR_GARANT_BLEEDING 30
/// Minimal brute damage for add bleeding
#define MIN_BURN_DAMAGE_FOR_STOP_BLEEDING 5
/// Brute damage to bleeding calculation coefficient
#define BRUTE_DAMAGE_TO_BLEEDING_MOD 0.1
/// Minimal brute damage for add bleeding
#define BURN_DAMAGE_STOP_BLEEDING_MOD 0.15
/// Heal damage to bleeding reduction calculation coefficient
#define HEAL_DAMAGE_TO_BLEEDING_MOD 0.05
/// Minimal brute damage for bodypart
#define MIN_DAMAGE_FROM_BLEEDING_MOD 1.5

#define HEAVY_BLEEDING_RATE 5

/// Suppressed bleeding modifier
#define BRUISE_PACK_SUPPRESS_BLEEDING_MOD 0.80
