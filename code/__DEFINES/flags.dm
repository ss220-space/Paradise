#define ALL (~0) //For convenience.
#define NONE 0

/* Directions */
///All the cardinal direction bitflags.
#define ALL_CARDINALS (NORTH|SOUTH|EAST|WEST)


// Flags for the flags var on /atom
/// Conducts electricity (metal etc.)
#define CONDUCT (1<<0)
/// Atom has priority to check when entering or leaving turfs
#define ON_BORDER (1<<1)
/// Self explanatory, prevents any clicks through ourselves
#define PREVENT_CLICK_UNDER (1<<2)
/// Сould this item be suitable as a ricochet target?
#define CHECK_RICOCHET (1<<3)
/// Whether this atom prevents light from being attached
#define BLOCKS_LIGHT (1<<4)
/// Whether this atom is only a hologram object
#define HOLOGRAM (1<<5)
/// Was this spawned by an admin? used for stat tracking stuff.
#define ADMIN_SPAWNED (1<<6)


// Update flags for [/atom/proc/update_appearance]
/// Update the atom's name
#define UPDATE_NAME (1<<0)
/// Update the atom's desc
#define UPDATE_DESC (1<<1)
/// Update the atom's icon state
#define UPDATE_ICON_STATE (1<<2)
/// Update the atom's overlays
#define UPDATE_OVERLAYS (1<<3)
/// Update the atom's icon
#define UPDATE_ICON (UPDATE_ICON_STATE|UPDATE_OVERLAYS)


//Reagent flags
#define REAGENT_NOREACT			1

//Species clothing flags
#define HAS_UNDERWEAR 	1
#define HAS_UNDERSHIRT 	2
#define HAS_SOCKS		4

//Species Body Flags
#define HAS_HEAD_ACCESSORY	(1<<0)
#define HAS_TAIL 			(1<<1)
#define TAIL_OVERLAPPED		(1<<2)
#define HAS_SKIN_TONE 		(1<<3)
#define HAS_ICON_SKIN_TONE	(1<<4)
#define HAS_SKIN_COLOR		(1<<5)
#define HAS_HEAD_MARKINGS	(1<<6)
#define HAS_BODY_MARKINGS	(1<<7)
#define HAS_TAIL_MARKINGS	(1<<8)
#define TAIL_WAGGING    	(1<<9)
#define NO_EYES				(1<<10)
#define HAS_ALT_HEADS		(1<<11)
#define HAS_WING			(1<<12)
#define HAS_BODYACC_COLOR	(1<<13)
#define BALD				(1<<14)
#define ALL_RPARTS			(1<<15)

//Pre-baked combinations of the above body flags
#define HAS_BODY_ACCESSORY (HAS_TAIL|HAS_WING)
#define HAS_MARKINGS (HAS_HEAD_MARKINGS|HAS_BODY_MARKINGS|HAS_TAIL_MARKINGS)

//Species Diet Flags
#define DIET_CARN		1
#define DIET_OMNI		2
#define DIET_HERB		4


//bitflags for door switches.
#define OPEN (1<<0)
#define IDSCAN (1<<1)
#define BOLTS (1<<2)
#define SHOCK (1<<3)
#define SAFE (1<<4)

//flags for passing things
#define PASSTABLE (1<<0)
#define PASSGLASS (1<<1)
#define PASSGRILLE (1<<2)
#define PASSBLOB (1<<3)
#define PASSMOB (1<<4)
/// Let thrown things past us. **ONLY MEANINGFUL ON pass_flags_self!**
#define LETPASSTHROW (1<<5)
#define PASSMACHINE (1<<6)
#define PASSSTRUCTURE (1<<7)
#define PASSFLAPS (1<<8)
#define PASSFENCE (1<<9)
#define PASSDOOR (1<<10)
#define PASSVEHICLE (1<<11)
#define PASSITEM (1<<12)
/// Do not intercept click attempts during Adjacent() checks. See [turf/proc/ClickCross]. **ONLY MEANINGFUL ON pass_flags_self!**
#define LETPASSCLICKS (1<<13)

#define PASSEVERYTHING (PASSTABLE|PASSGLASS|PASSGRILLE|PASSBLOB|PASSMOB|LETPASSTHROW|PASSMACHINE|PASSSTRUCTURE|PASSFLAPS|PASSFENCE|PASSDOOR|PASSVEHICLE|PASSITEM|LETPASSCLICKS)



//Movement Types
#define GROUND (1<<0)
#define FLYING (1<<1)
#define VENTCRAWLING (1<<2)
#define FLOATING (1<<3)
/// When moving, will Cross() everything, but won't stop or Bump() anything.
#define PHASING (1<<4)
/// The mob is walking on the ceiling. Or is generally just, upside down.
#define UPSIDE_DOWN (1<<5)

/// Combination flag for movetypes which, for all intents and purposes, mean the mob is not touching the ground
#define MOVETYPES_NOT_TOUCHING_GROUND (FLYING|FLOATING|UPSIDE_DOWN)


// for /datum/var/datum_flags
#define DF_USE_TAG (1<<0)
#define DF_VAR_EDITED (1<<1)
#define DF_ISPROCESSING (1<<2)

//turf-only flags
#define NOJAUNT		1
#define NO_LAVA_GEN	2 //Blocks lava rivers being generated on the turf
#define NO_RUINS 	4

//ORGAN TYPE FLAGS
#define AFFECT_ROBOTIC_ORGAN	1
#define AFFECT_ORGANIC_ORGAN	2
#define AFFECT_ALL_ORGANS		3

//Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF		(1<<0)
#define FIRE_PROOF		(1<<1) //100% immune to fire damage (but not necessarily to lava or heat)
#define FLAMMABLE		(1<<2)
#define ON_FIRE			(1<<3)
#define UNACIDABLE		(1<<4) //acid can't even appear on it, let alone melt it.
#define ACID_PROOF		(1<<5) //acid stuck on it doesn't melt it.
#define INDESTRUCTIBLE	(1<<6) //doesn't take damage
#define FREEZE_PROOF	(1<<7) //can't be frozen
#define NO_MALF_EFFECT	(1<<8) //So malf cannot blow certain things
#define NO_MOUSTACHING	(1<<9) //Saves from super hairgrowium shenanigans

#define MEAT 		(1<<0)
#define VEGETABLES 	(1<<1)
#define RAW 		(1<<2)
#define JUNKFOOD 	(1<<3)
#define GRAIN 		(1<<4)
#define FRUIT 		(1<<5)
#define DAIRY 		(1<<6)
#define FRIED 		(1<<7)
#define ALCOHOL 	(1<<8)
#define SUGAR 		(1<<9)
#define EGG 		(1<<10)
#define GROSS 		(1<<11)
#define TOXIC		(1<<12)

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))


//Mob mobility var flags
/// can move
#define MOBILITY_MOVE (1<<0)
/// can, and is, standing up
#define MOBILITY_STAND (1<<1)
/// can pickup items
#define MOBILITY_PICKUP (1<<2)
/// can hold and use items
#define MOBILITY_USE (1<<3)
/// can use interfaces like machinery
#define MOBILITY_UI (1<<4)
/// can use storage item
#define MOBILITY_STORAGE (1<<5)
/// can pull things
#define MOBILITY_PULL (1<<6)
/// can rest
#define MOBILITY_REST (1<<7)
/// can lie down
#define MOBILITY_LIEDOWN (1<<8)

#define MOBILITY_FLAGS_DEFAULT (MOBILITY_MOVE|MOBILITY_STAND|MOBILITY_PICKUP|MOBILITY_USE|MOBILITY_UI|MOBILITY_STORAGE|MOBILITY_PULL)
#define MOBILITY_FLAGS_CARBON_DEFAULT (MOBILITY_MOVE|MOBILITY_STAND|MOBILITY_PICKUP|MOBILITY_USE|MOBILITY_UI|MOBILITY_STORAGE|MOBILITY_PULL|MOBILITY_REST|MOBILITY_LIEDOWN)
#define MOBILITY_FLAGS_REST_CAPABLE_DEFAULT (MOBILITY_MOVE|MOBILITY_STAND|MOBILITY_PICKUP|MOBILITY_USE|MOBILITY_UI|MOBILITY_STORAGE|MOBILITY_PULL|MOBILITY_REST|MOBILITY_LIEDOWN)


//MINING AREA FLAGS
/// If mining tunnel generation is allowed in this area
#define CAVES_ALLOWED (1<<1)
/// If flora are allowed to spawn in this area randomly through tunnel generation
#define FLORA_ALLOWED (1<<2)
/// If mobs can be spawned by natural random generation
#define MOB_SPAWN_ALLOWED (1<<3)
/// If megafauna can be spawned by natural random generation
#define MEGAFAUNA_SPAWN_ALLOWED (1<<4)


// timed_action_flags parameter for [/proc/do_after()]
/// Can do the action even if mob moves location.
#define DA_IGNORE_USER_LOC_CHANGE (1<<0)
/// If we are checking for mob's loc change space drift will be ignored.
#define DA_IGNORE_SPACE_DRIFT (1<<1)
/// Can do the action even if the target moves location.
#define DA_IGNORE_TARGET_LOC_CHANGE (1<<2)
/// Can do the action even if the user is UNCONSCIOUS or DEAD.
#define DA_IGNORE_CONSCIOUSNESS (1<<3)
/// Can do the action even if the user is lying.
#define DA_IGNORE_LYING (1<<4)
/// Can do the action even if the user is restrained.
#define DA_IGNORE_RESTRAINED (1<<5)
/// Can do the action even if the user is incapacitated (weakened/stunned/stamcrited/paralyzed/sleeping).
#define DA_IGNORE_INCAPACITATED (1<<6)
/// Can do the action even if the item is no longer being held.
#define DA_IGNORE_HELD_ITEM (1<<7)
/// If actively held item is cyborg gripper we will not check whether its empty during the process.
#define DA_IGNORE_EMPTY_GRIPPER (1<<8)

/// All ignore flags considered as default old do_after behavior.
#define DEFAULT_DOAFTER_IGNORE (DA_IGNORE_LYING|DA_IGNORE_RESTRAINED)


//Incapacitated ignore flags for [/proc/incapacitated()]
/// If the incapacitated will ignore a mob in restraints
#define INC_IGNORE_RESTRAINED (1<<0)
/// If the incapacitated will ignore a mob being agressively grabbed
#define INC_IGNORE_GRABBED (1<<1)

