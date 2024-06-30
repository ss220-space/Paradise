// This file contains all of the "static" define strings that tie to a trait.

/*
Remember to update _globalvars/traits.dm if you're adding/removing/renaming traits.
*/

//atom traits
/// Trait used to prevent an atom from component radiation emission (see radioactivity.dm)
#define TRAIT_BLOCK_RADIATION "block_radiation"

//atom/movable traits
/// Buckling yourself to objects with this trait won't immobilize you
#define TRAIT_NO_IMMOBILIZE "no_immobilize"

//turf traits
/// Prevent mobs on the turf from being affected by anything below that turf, such as a pulse demon going under it. Added by a /obj/structure with creates_cover set to TRUE
#define TRAIT_TURF_COVERED "turf_covered"
///Turf slowdown will be ignored when this trait is added to a turf.
#define TRAIT_TURF_IGNORE_SLOWDOWN "turf_ignore_slowdown"
///Mobs won't slip on a wet turf while it has this trait
#define TRAIT_TURF_IGNORE_SLIPPERY "turf_ignore_slippery"

//mob traits
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
#define TRAIT_SHOCKIMMUNE "shockimmune"
#define TRAIT_CHUNKYFINGERS "chunkyfingers"	//means that you can't use weapons with normal trigger guards.
#define TRAIT_FORCE_DOORS "force_doors"
#define TRAIT_EMOTE_MUTE "emote_mute"
#define TRAIT_IGNORESLOWDOWN "ignoreslow"
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"
#define TRAIT_STRONG_GRABBER "strong_grabber"
#define TRAIT_PUSHIMMUNE "push_immunity"

/// "Magic" trait that blocks the mob from moving or interacting with anything. Used for transient stuff like mob transformations or incorporality in special cases.
/// Will block movement, `Life()` (!!!), and other stuff based on the mob.
#define TRAIT_NO_TRANSFORM "block_transformations"
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

