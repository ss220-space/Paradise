// This file contains all of the "static" define strings that tie to a trait.

/*
Remember to update _globalvars/traits.dm if you're adding/removing/renaming traits.
*/

//atom traits
/// Trait used to prevent an atom from component radiation emission (see radioactivity.dm)
#define TRAIT_BLOCK_RADIATION "block_radiation"

//turf traits
/// Prevent mobs on the turf from being affected by anything below that turf, such as a pulse demon going under it. Added by a /obj/structure with creates_cover set to TRUE
#define TRAIT_TURF_COVERED "turf_covered"
///Turf slowdown will be ignored when this trait is added to a turf.
#define TRAIT_TURF_IGNORE_SLOWDOWN "turf_ignore_slowdown"

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
#define TRAIT_SHOCKIMMUNE "shockimmune"
#define TRAIT_CHUNKYFINGERS "chunkyfingers"	//means that you can't use weapons with normal trigger guards.
#define TRAIT_FORCE_DOORS "force_doors"
#define TRAIT_EMOTE_MUTE "emote_mute"
#define TRAIT_IGNORESLOWDOWN "ignoreslow"
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"
/// This mob heals from carp rifts.
#define TRAIT_HEALS_FROM_CARP_RIFTS "heals_from_carp_rifts"
/// This mob heals from cult pylons.
#define TRAIT_HEALS_FROM_CULT_PYLONS "heals_from_cult_pylons"
/// This mob heals from holy pylons.
#define TRAIT_HEALS_FROM_HOLY_PYLONS "heals_from_holy_pylons"
#define TRAIT_LASEREYES "laser_eyes"	//traits that should be properly converted to genetic mutations one day

//item traits
#define TRAIT_CMAGGED "cmagged"
/// The items needs two hands to be carried
#define TRAIT_NEEDS_TWO_HANDS "needstwohands"
/// Properly wielded two handed item
#define TRAIT_WIELDED "wielded"

///Movement type traits for movables. See elements/movetype_handler.dm
#define TRAIT_MOVE_GROUND "move_ground"
#define TRAIT_MOVE_FLYING "move_flying"
#define TRAIT_MOVE_VENTCRAWLING "move_ventcrawling"
#define TRAIT_MOVE_FLOATING "move_floating"
#define TRAIT_MOVE_PHASING "move_phasing"
#define TRAIT_MOVE_UPSIDE_DOWN "move_upside_down"
/// Disables the floating animation. See above.
#define TRAIT_NO_FLOATING_ANIM "no-floating-animation"

