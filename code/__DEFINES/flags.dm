#define ALL ~0 //For convenience.
#define NONE 0

//FLAGS BITMASK
#define STOPSPRESSUREDMAGE 		(1<<0)		// This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_BACK) if you see it anywhere To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.
#define NODROP					(1<<1)		// This flag makes it so that an item literally cannot be removed at all, or at least that's how it should be. Only deleted.
#define NOBLUDGEON  			(1<<2)		// when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define AIRTIGHT				(1<<3)		// mask allows internals
#define HANDSLOW        		(1<<4)		// If an item has this flag, it will slow you to carry it
#define CONDUCT					(1<<5)		// conducts electricity (metal etc.)
#define ABSTRACT				(1<<6)		// for all things that are technically items but used for various different stuff, made it 128 because it could conflict with other flags other way
#define ON_BORDER				(1<<7)		// item has priority to check when entering or leaving
#define PREVENT_CLICK_UNDER		(1<<8)
#define NODECONSTRUCT			(1<<9)

#define EARBANGPROTECT			(1<<10)

#define NOSLIP					(1<<10) 	//prevents from slipping on wet floors, in space etc

#define NOPICKUP				(1<<11)		// This flags makes it so an item cannot be picked in hands

#define HEADBANGPROTECT			(1<<12)

#define BLOCK_GAS_SMOKE_EFFECT	(1<<13)	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY!
#define THICKMATERIAL 			(1<<13)	//prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body. (NOTE: flag shared with BLOCK_GAS_SMOKE_EFFECT)

#define DROPDEL					(1<<14)	// When dropped, it calls qdel on itself

#define BLOCKHEADHAIR 			(1<<15)	// temporarily removes the user's hair overlay. Leaves facial hair.
#define BLOCKFACIALHAIR			(1<<16)	// temporarily removes the user's facial hair overlay. Leaves head hair.
#define BLOCKHAIR				(1<<17)	// temporarily removes the user's hair, facial and otherwise.

#define NO_PIXEL_RANDOM_DROP	(1<<18)	// If dropped, it wont have a randomized pixel_x/pixel_y

#define BLOCK_CAPSAICIN			(1<<19)	// Prevents from passing capsaicin onto human

#define NOSHARPENING			1048576 // Prevents from sharpening item with whetstone

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


// for /datum/var/datum_flags
#define DF_USE_TAG (1<<0)
#define DF_VAR_EDITED (1<<1)
#define DF_ISPROCESSING (1<<2)

//turf-only flags
#define NOJAUNT		1
#define NO_LAVA_GEN	2 //Blocks lava rivers being generated on the turf
#define NO_RUINS 	4

//ITEM INVENTORY SLOT BITMASKS
#define SLOT_OCLOTHING	(1<<0)
#define SLOT_ICLOTHING	(1<<1)
#define SLOT_GLOVES		(1<<2)
#define SLOT_EYES		(1<<3)
#define SLOT_EARS		(1<<4)
#define SLOT_MASK		(1<<5)
#define SLOT_HEAD		(1<<6)
#define SLOT_FEET		(1<<7)
#define SLOT_ID			(1<<8)
#define SLOT_BELT		(1<<9)
#define SLOT_BACK		(1<<10)
#define SLOT_POCKET		(1<<11)		//this is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_DENYPOCKET	(1<<12)	//this is to deny items with a w_class of 2 or 1 to fit in pockets.
#define SLOT_TWOEARS	(1<<13)
#define SLOT_PDA		(1<<14)
#define SLOT_TIE		(1<<15)
#define SLOT_NECK		(1<<16)

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
