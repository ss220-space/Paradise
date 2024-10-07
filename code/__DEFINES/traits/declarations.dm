// This file contains all of the "static" define strings that tie to a trait.

/*
Remember to update _globalvars/traits.dm if you're adding/removing/renaming traits.
*/

//atom traits
/// Trait used to prevent an atom from component radiation emission (see radioactivity.dm)
#define TRAIT_BLOCK_RADIATION "block_radiation"
/// Is this atom being actively shocked? Used to prevent repeated shocks.
#define TRAIT_BEING_SHOCKED "being_shocked"

/// Weather immunities, also protect mobs inside them.
#define TRAIT_LAVA_IMMUNE "lava_immune" //Used by lava turfs and The Floor Is Lava.
#define TRAIT_ASHSTORM_IMMUNE "ashstorm_immune"
#define TRAIT_SNOWSTORM_IMMUNE "snowstorm_immune"
#define TRAIT_RADSTORM_IMMUNE "radstorm_immune"
#define TRAIT_SOLARFLARE_IMMUNE "solarflare_immune"
#define TRAIT_BLOBSTORM_IMMUNE "blobstorm_immune"
#define TRAIT_WEATHER_IMMUNE "weather_immune" //Immune to ALL weather effects.

//atom/movable traits
/// Buckling yourself to objects with this trait won't immobilize you
#define TRAIT_NO_IMMOBILIZE "no_immobilize"
///Chasms will be safe to cross if there is something with this trait on it
#define TRAIT_CHASM_STOPPER "chasm_stopper"
/// `do_teleport` will not allow this atom to teleport
#define TRAIT_NO_TELEPORT "no-teleport"
#define TRAIT_SILENT_FOOTSTEPS "silent_footsteps"

//turf traits
/// Prevent mobs on the turf from being affected by anything below that turf, such as a pulse demon going under it. Added by a /obj/structure with creates_cover set to TRUE
#define TRAIT_TURF_COVERED "turf_covered"
///Turf slowdown will be ignored when this trait is added to a turf.
#define TRAIT_TURF_IGNORE_SLOWDOWN "turf_ignore_slowdown"
///Mobs won't slip on a wet turf while it has this trait
#define TRAIT_TURF_IGNORE_SLIPPERY "turf_ignore_slippery"
///Chasms will be safe to cross while they've this trait.
#define TRAIT_CHASM_STOPPED "chasm_stopped"
///Lava will be safe to cross while it has this trait.
#define TRAIT_LAVA_STOPPED "lava_stopped"

//mob traits
#define TRAIT_GODMODE "godmode"
#define TRAIT_PACIFISM "pacifism"
#define TRAIT_WATERBREATH "waterbreathing"
#define TRAIT_BLOODCRAWL "bloodcrawl"
#define TRAIT_BLOODCRAWL_EAT "bloodcrawl_eat"
#define TRAIT_JESTER "jester"
#define TRAIT_ELITE_CHALLENGER "elite_challenger"
#define TRAIT_MUTE "mute"
#define TRAIT_DEAF "deaf"
#define TRAIT_SECDEATH "secdeath"
#define TRAIT_AI_UNTRACKABLE "AI_untrackable"
#define TRAIT_FAKEDEATH "fakedeath"	//Makes the owner appear as dead to most forms of medical examination
#define TRAIT_XENO_HOST "xeno_host"	//Tracks whether we're gonna be a baby alien's mummy.
#define TRAIT_LEGION_TUMOUR "legion_tumour" //used in huds for special icon
/// Are we immune to shocks?
#define TRAIT_SHOCKIMMUNE "shock_immunity"
/// Are we immune to specifically tesla / SM shocks?
#define TRAIT_TESLA_SHOCKIMMUNE "tesla_shock_immunity"
/// Means that you can't use weapons with normal trigger guards.
#define TRAIT_NO_GUNS "no_guns"
#define TRAIT_FORCE_DOORS "force_doors"
#define TRAIT_EMOTE_MUTE "emote_mute"
#define TRAIT_IGNORESLOWDOWN "ignoreslow"
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"
#define TRAIT_STRONG_GRABBER "strong_grabber"
#define TRAIT_PUSHIMMUNE "push_immunity"
#define TRAIT_FLATTENED	"flattened"

/// Not a genetic obesity but just a mob who overate
#define	TRAIT_FAT "trait_fat"
#define TRAIT_HUSK "husk"
#define TRAIT_SKELETON "skeleton"
#define TRAIT_NO_CLONE "no_clone"

/// "Magic" trait that blocks the mob from moving or interacting with anything. Used for transient stuff like mob transformations or incorporality in special cases.
/// Will block movement, `Life()` (!!!), and other stuff based on the mob.
#define TRAIT_NO_TRANSFORM "block_transformations"
/// This mob heals from ash tendril
#define TRAIT_HEALS_FROM_ASH_TENDRIL "heals_from_ash_tendril"
/// This mob heals from carp rifts.
#define TRAIT_HEALS_FROM_CARP_RIFTS "heals_from_carp_rifts"
/// This mob heals from cult pylons.
#define TRAIT_HEALS_FROM_CULT_PYLONS "heals_from_cult_pylons"
/// This mob heals from holy pylons.
#define TRAIT_HEALS_FROM_HOLY_PYLONS "heals_from_holy_pylons"
#define TRAIT_LASEREYES "laser_eyes"	//traits that should be properly converted to genetic mutations one day
/// Forces the user to stay unconscious.
#define TRAIT_KNOCKEDOUT "knockedout"
/// Prevents almost all actions, formely know as Stunned.
#define TRAIT_INCAPACITATED "incapacitated"
/// Prevents voluntary movement.
#define TRAIT_IMMOBILIZED "immobilized"
/// Prevents voluntary standing or staying up on its own.
#define TRAIT_FLOORED "floored"
/// Forces user to stay standing
#define TRAIT_FORCED_STANDING "forcedstanding"
/// Prevents usage of manipulation appendages (picking, holding or using items, manipulating storage).
#define TRAIT_HANDS_BLOCKED "handsblocked"
/// Inability to access UI hud elements. Turned into a trait from [MOBILITY_UI] to be able to track sources.
#define TRAIT_UI_BLOCKED "uiblocked"
/// Inability to pull things. Turned into a trait from [MOBILITY_PULL] to be able to track sources.
#define TRAIT_PULL_BLOCKED "pullblocked"
/// Abstract condition that prevents movement if being pulled and might be resisted against. Handcuffs and straight jackets, basically.
#define TRAIT_RESTRAINED "restrained"

/// Anti Dual-baton cooldown bypass exploit.
#define TRAIT_IWASBATONED "iwasbatoned"

/// Stops the mob from slipping on water, or banana peels, or pretty much anything that doesn't have [SLIP_IGNORE_NO_SLIP_WATER] set
#define TRAIT_NO_SLIP_WATER "noslip_water"
/// Stops the mob from slipping on permafrost ice (not any other ice) (but anything with [SLIDE_ICE] set)
#define TRAIT_NO_SLIP_ICE "noslip_ice"
/// Stop the mob from sliding around from being slipped, but not the slip part.
/// DOES NOT include ice slips.
#define TRAIT_NO_SLIP_SLIDE "noslip_slide"
/// Stops all slipping and sliding from ocurring
#define TRAIT_NO_SLIP_ALL "noslip_all"
/// Give us unsafe_unwrenching protection
#define TRAIT_GUSTPROTECTION "gustprotection"
/// This mob can strip other mobs.
#define TRAIT_CAN_STRIP "can_strip"


/// Unlinks gliding from movement speed, meaning that there will be a delay between movements rather than a single move movement between tiles
#define TRAIT_NO_GLIDE "no_glide"

/// Apply this to make a mob not dense, and remove it when you want it to no longer make them undense, other sorces of undesity will still apply. Always define a unique source when adding a new instance of this!
#define TRAIT_UNDENSE "undense"
/// Holocigar trait to make a mob BADASS
#define TRAIT_BADASS "trait_badass"

/* Traits for ventcrawling.
 * Both give access to ventcrawling, but *_NUDE requires the user to be
 * wearing no clothes and holding no items. If both present, *_ALWAYS
 * takes precedence.
 */
#define TRAIT_VENTCRAWLER_ALWAYS "ventcrawler_always"
#define TRAIT_VENTCRAWLER_NUDE "ventcrawler_nude"
/// Overrides above traits to allow aliens to use their pockets
#define TRAIT_VENTCRAWLER_ALIEN "ventcrawler_alien"
/// If this trait is present all equipped items will be checked for ventcrawling possibilities.
/// Takes precedence over all traits above
#define TRAIT_VENTCRAWLER_ITEM_BASED "ventcrawler_item"

/// Negates our gravity, letting us move normally on floors in 0-g
#define TRAIT_NEGATES_GRAVITY "negates_gravity"
/// We are ignoring gravity
#define TRAIT_IGNORING_GRAVITY "ignores_gravity"
/// We have some form of forced gravity acting on us
#define TRAIT_FORCED_GRAVITY "forced_gravity"

//***** ITEM TRAITS *****//
#define TRAIT_CMAGGED "cmagged"
/// The items needs two hands to be carried
#define TRAIT_NEEDS_TWO_HANDS "needstwohands"
/// Properly wielded two handed item
#define TRAIT_WIELDED "wielded"
/// A transforming item that is actively extended / transformed
#define TRAIT_TRANSFORM_ACTIVE "active_transform"
/// A surgical tool; when in hand in help intent (and with a surgery in progress) won't attack the user
#define TRAIT_SURGICAL "surgical_tool"
/// An advanced surgical tool. If a surgical tool has this flag, it will be able to automatically repeat steps until they succeed.
#define TRAIT_ADVANCED_SURGICAL "advanced_surgical"
/// This trait makes it so that an item literally cannot be removed at all, or at least that's how it should be. Only deleted.
#define TRAIT_NODROP "nodrop"


///Movement type traits for movables. See elements/movetype_handler.dm
#define TRAIT_MOVE_GROUND "move_ground"
#define TRAIT_MOVE_FLYING "move_flying"
#define TRAIT_MOVE_VENTCRAWLING "move_ventcrawling"
#define TRAIT_MOVE_FLOATING "move_floating"
#define TRAIT_MOVE_PHASING "move_phasing"
#define TRAIT_MOVE_UPSIDE_DOWN "move_upside_down"
/// Disables the floating animation. See above.
#define TRAIT_NO_FLOATING_ANIM "no-floating-animation"

// old mutation traits
#define	TRAIT_TELEKINESIS "telekinesis"
#define TRAIT_RESIST_COLD "cold_resistance"
#define TRAIT_RESIST_HEAT "heat_resistance"
#define TRAIT_XRAY "xray"
#define TRAIT_HULK "hulk"
#define TRAIT_CLUMSY "clumsy"
#define TRAIT_OBESITY "obesity"
#define TRAIT_NO_BREATH "no_breath"
#define TRAIT_WINGDINGS "wingdings"
#define TRAIT_NO_FINGERPRINTS "no_fingerprints"
#define TRAIT_DWARF "dwarf"
#define TRAIT_GENE_STRONG "gene_strong"
#define TRAIT_GENE_WEAK "gene_weak"
#define TRAIT_SOBER "sober"
#define TRAIT_PSY_RESIST "psy_resist"	// block remoteview
#define TRAIT_OPEN_MIND "open_mind"	// allows to remote view this mob
#define TRAIT_EMPATHY "empathy"	// allows to see when someone reads your mind
#define TRAIT_COMIC "comic_sans"
#define TRAIT_NEARSIGHTED "nearsighted"
#define TRAIT_BLIND "blind"
#define TRAIT_COLORBLIND "colorblind"

// old species traits
/// This human mob doesn't bleed
#define TRAIT_NO_BLOOD "no_blood"
/// This human mob will only regenerate blood through the transfusion
#define TRAIT_NO_BLOOD_RESTORE "no_blood_restore"
/// This human mob has non-blood reagent in their veins
#define TRAIT_EXOTIC_BLOOD "exotic_blood"
/// This human mob has lips
#define TRAIT_HAS_LIPS "has_lips"
/// This human mob can passively regenerate small amount of brute and burn damage (0.1, 0.1)
#define TRAIT_HAS_REGENERATION "has_regeneration"
/// This human mob acts like it has no DNA, but it actually has
/// Its dumb I know, we should switch to biotypes already
#define TRAIT_NO_DNA "no_dna"
/// This human cannot be scanned via cloning machine, also stops replica pod cloning
/// Actually it applies the same trait to the human's brain
#define TRAIT_NO_SCAN "no_scan"
/// This human mob will not visually and vocally react to the damage consequences
/// Also allows surgeries without anesthetics
#define TRAIT_NO_PAIN "no_pain"
/// This human mob will not feedback user about the damage done via HUD alerts
#define TRAIT_NO_PAIN_HUD "no_pain_hud"
/// Another biotype thing
#define TRAIT_PLANT_ORIGIN "plant_origin"
/// Another damn biotype
#define TRAIT_NO_INTORGANS "no_internal_organs"
/// This mob is completely immune to the radiation damage and effects
#define TRAIT_RADIMMUNE "rad_immunity"
/// This mob is completely immune to viruses and diseases, unless they ignore us
#define TRAIT_VIRUSIMMUNE "virus_immunity"
/// This human mob will not show its species on examine
#define TRAIT_NO_SPECIES_EXAMINE "no_examine"
/// This human mob will never become fat, does not affect genetic obesity
#define TRAIT_NO_FAT "no_fat"
/// This human mob's internal organs will not accumulate germs
#define TRAIT_NO_GERMS "no_germs"
/// This human mob's internal organs will not decay after death
#define TRAIT_NO_DECAY "no_decay"
/// This human mob will not be affected by piercing, such as caltrops, prickles, needles etc.
#define TRAIT_PIERCEIMMUNE "pierce_immunity"
/// This human mob will not be affected by embedding of the thrown items
#define TRAIT_EMBEDIMMUNE "embed_immunity"
/// This human mob will never suffer from the malnutrition
#define TRAIT_NO_HUNGER "no_hunger"
/// This human mob can repats surgeris attempts indefinitely
#define TRAIT_MASTER_SURGEON "master_surgeon"
/// Prohibits the installation of robotic limbs, cybernetic organs, augments
#define TRAIT_NO_ROBOPARTS "no_roboparts"
/// Prohibits the injection of all the biochips, except mindslave and mindshield
#define TRAIT_NO_BIOCHIPS "no_biochips"
/// Prohibits the installation of cybernetic implants
#define TRAIT_NO_CYBERIMPLANTS "no_cyberimplants"
/// Prohibits the installation of the limbs, which do not belong to our species
#define TRAIT_SPECIES_LIMBS "only_species_limbs"

