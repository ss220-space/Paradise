#define ALL ~0 //For convenience.
#define NONE 0

/* Directions */
///All the cardinal direction bitflags.
#define ALL_CARDINALS (NORTH|SOUTH|EAST|WEST)

//FLAGS BITMASK
#define STOPSPRESSUREDMAGE 		(1<<0)		// This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_FLAG_BACK) if you see it anywhere To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.
#define NOBLUDGEON  			(1<<1)		// when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define AIRTIGHT				(1<<2)		// mask allows internals
#define HANDSLOW        		(1<<3)		// If an item has this flag, it will slow you to carry it
#define CONDUCT					(1<<4)		// conducts electricity (metal etc.)
#define ABSTRACT				(1<<5)		// for all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way
#define ON_BORDER				(1<<6)		// item has priority to check when entering or leaving
#define PREVENT_CLICK_UNDER		(1<<7)
#define NODECONSTRUCT			(1<<8)

#define EARBANGPROTECT			(1<<9)

#define NOSLIP					(1<<10) 	//prevents from slipping on wet floors, in space etc

#define NOPICKUP				(1<<11)		// This flags makes it so an item cannot be picked in hands

#define HEADBANGPROTECT			(1<<12)

#define BLOCK_GAS_SMOKE_EFFECT	(1<<13)	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY!
#define THICKMATERIAL 			(1<<13)	//prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body. (NOTE: flag shared with BLOCK_GAS_SMOKE_EFFECT)

#define DROPDEL					(1<<14)	// When dropped, it calls qdel on itself

#define NO_PIXEL_RANDOM_DROP	(1<<15)	// If dropped, it wont have a randomized pixel_x/pixel_y

#define BLOCK_CAPSAICIN			(1<<16)	// Prevents from passing capsaicin onto human

#define NOSHARPENING			(1<<17) // Prevents from sharpening item with whetstone

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


/* Secondary atom flags, for the flags_2 var, denoted with a _2 */

#define SLOWS_WHILE_IN_HAND_2	(1<<0)
#define NO_EMP_WIRES_2			(1<<1)
#define HOLOGRAM_2				(1<<2)
#define FROZEN_2				(1<<3)
#define STATIONLOVING_2			(1<<4)
#define INFORM_ADMINS_ON_RELOCATE_2	(1<<5)
#define BANG_PROTECT_2			(1<<6)

// An item worn in the ear slot with HEALS_EARS will heal your ears each
// Life() tick, even if normally your ears would be too damaged to heal.
#define HEALS_EARS_2			(1<<7)

// A mob with OMNITONGUE has no restriction in the ability to speak
// languages that they know. So even if they wouldn't normally be able to
// through mob or tongue restrictions, this flag allows them to ignore
// those restrictions.
#define OMNITONGUE_2			(1<<8)

// TESLA_IGNORE grants immunity from being targeted by tesla-style electricity
#define TESLA_IGNORE_2			(1<<9)

// Stops you from putting things like an RCD or other items into an ORM or protolathe for materials.
#define NO_MAT_REDEMPTION_2		(1<<10)

// LAVA_PROTECT used on the flags_2 variable for both SUIT and HEAD items, and stops lava damage. Must be present in both to stop lava damage.
#define LAVA_PROTECT_2			(1<<11)

#define OVERLAY_QUEUED_2		(1<<12)

#define CHECK_RICOCHET_2		(1<<13)

#define BLOCKS_LIGHT_2			16384

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

