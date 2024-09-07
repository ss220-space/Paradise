//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
//Make sure to update check_obscured_slots() if you add more.
//These first five are only used in exterior suits
#define HIDEGLOVES (1<<0)
#define HIDESUITSTORAGE (1<<1)
#define HIDEJUMPSUIT (1<<2)
#define HIDESHOES (1<<3)
#define HIDETAIL (1<<4)
//These next eight are only used in masks and headgear.
#define HIDENECK (1<<5)
#define HIDEMASK (1<<6)
#define HIDEHEADSETS (1<<7)
#define HIDEGLASSES (1<<8)
#define HIDENAME (1<<9)
#define HIDEHAIR (1<<10)
#define HIDEHEADHAIR (1<<11)
#define HIDEFACIALHAIR (1<<12)


// ITEM INVENTORY SLOT BITMASKS
// Update "ITEM_SLOT_X_STRING" below, if you change slots here
/// Left hand slot
#define ITEM_SLOT_HAND_LEFT (1<<0)
/// Right hand slot
#define ITEM_SLOT_HAND_RIGHT (1<<1)
/// Both hands
#define ITEM_SLOT_HANDS (ITEM_SLOT_HAND_LEFT|ITEM_SLOT_HAND_RIGHT)
/// Left pocket slot
#define ITEM_SLOT_POCKET_LEFT (1<<2)
/// Right pocket slot
#define ITEM_SLOT_POCKET_RIGHT (1<<3)
/// Both pockets
#define ITEM_SLOT_POCKETS (ITEM_SLOT_POCKET_LEFT|ITEM_SLOT_POCKET_RIGHT)
/// Left ear slot (radios, earmuffs)
#define ITEM_SLOT_EAR_LEFT (1<<4)
/// Right ear slot (radios, earmuffs)
#define ITEM_SLOT_EAR_RIGHT (1<<5)
/// Both ears
#define ITEM_SLOT_EARS (ITEM_SLOT_EAR_LEFT|ITEM_SLOT_EAR_RIGHT)
/// Belt slot
#define ITEM_SLOT_BELT (1<<6)
/// Back slot
#define ITEM_SLOT_BACK (1<<7)
/// Suit slot (armors, costumes, space suits, etc.)
#define ITEM_SLOT_CLOTH_OUTER (1<<8)
/// Jumpsuit slot
#define ITEM_SLOT_CLOTH_INNER (1<<9)
/// Glove slot
#define ITEM_SLOT_GLOVES (1<<10)
/// Glasses slot
#define ITEM_SLOT_EYES (1<<11)
/// Mask slot
#define ITEM_SLOT_MASK (1<<12)
/// Head slot (helmets, hats, etc.)
#define ITEM_SLOT_HEAD (1<<13)
/// Shoe slot
#define ITEM_SLOT_FEET (1<<14)
/// ID slot
#define ITEM_SLOT_ID (1<<15)
/// PDA slot
#define ITEM_SLOT_PDA (1<<16)
/// Neck slot (ties, bedsheets, scarves)
#define ITEM_SLOT_NECK (1<<17)
/// Suit storage slot
#define ITEM_SLOT_SUITSTORE (1<<18)
/// Handcuff slot
#define ITEM_SLOT_HANDCUFFED (1<<19)
/// Legcuff slot (bolas, beartraps)
#define ITEM_SLOT_LEGCUFFED (1<<20)
/// Inside of a character's backpack
#define ITEM_SLOT_BACKPACK (1<<21)
/// Accessory slot. Tries to place item on jumpsuit
#define ITEM_SLOT_ACCESSORY (1<<22)

/// Total amount of slots. Keep this up to date!
#define SLOT_HUD_AMOUNT 23

// Additional flags used with slot_flags_2 variable
/// Allows items with a w_class of WEIGHT_CLASS_NORMAL or WEIGHT_CLASS_BULKY to fit in pockets
#define ITEM_FLAG_POCKET_LARGE (1<<0)
/// Denies items with a w_class of WEIGHT_CLASS_TINY or WEIGHT_CLASS_SMALL to fit in pockets
#define ITEM_FLAG_POCKET_DENY (1<<1)
/// Indicated that item needs two ears to wear, also creates dummy item in other ear slot
#define ITEM_FLAG_TWOEARS (1<<2)

// accessory slots
#define ACCESSORY_SLOT_DECOR (1<<0)
#define ACCESSORY_SLOT_UTILITY (1<<1)
#define ACCESSORY_SLOT_ARMBAND (1<<2)

//Cant seem to find a mob bitflags area other than the powers one

// bitflags for clothing parts
#define HEAD			(1<<0)
#define UPPER_TORSO		(1<<1)
#define LOWER_TORSO		(1<<2)
#define LEG_LEFT		(1<<3)
#define LEG_RIGHT		(1<<4)
#define LEGS			(LEG_LEFT|LEG_RIGHT)
#define FOOT_LEFT		(1<<5)
#define FOOT_RIGHT		(1<<6)
#define FEET			(FOOT_LEFT|FOOT_RIGHT)
#define ARM_LEFT		(1<<7)
#define ARM_RIGHT		(1<<8)
#define ARMS			(ARM_LEFT|ARM_RIGHT)
#define HAND_LEFT		(1<<9)
#define HAND_RIGHT		(1<<10)
#define HANDS			(HAND_LEFT|HAND_RIGHT)
#define FULL_BODY		(HEAD|UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS)
#define TAIL			(1<<12)
#define WING			(1<<13)

// bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection()
// The values here should add up to 1.
// Hands and feet have 2.5%, arms and legs 7.5%, each of the torso parts has 15% and the head has 30%
#define THERMAL_PROTECTION_HEAD			0.3
#define THERMAL_PROTECTION_UPPER_TORSO	0.15
#define THERMAL_PROTECTION_LOWER_TORSO	0.15
#define THERMAL_PROTECTION_LEG_LEFT		0.075
#define THERMAL_PROTECTION_LEG_RIGHT	0.075
#define THERMAL_PROTECTION_FOOT_LEFT	0.025
#define THERMAL_PROTECTION_FOOT_RIGHT	0.025
#define THERMAL_PROTECTION_ARM_LEFT		0.075
#define THERMAL_PROTECTION_ARM_RIGHT	0.075
#define THERMAL_PROTECTION_HAND_LEFT	0.025
#define THERMAL_PROTECTION_HAND_RIGHT	0.025

//flags for covering body parts
#define GLASSESCOVERSEYES	(1<<0)
#define MASKCOVERSEYES		(1<<1)		// get rid of some of the other mess in these flags
#define HEADCOVERSEYES		(1<<2)		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH		(1<<3)		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH		(1<<4)

// Suit sensor levels
#define SUIT_SENSOR_OFF 0
#define SUIT_SENSOR_BINARY 1
#define SUIT_SENSOR_VITAL 2
#define SUIT_SENSOR_TRACKING 3

//flags for muzzle speech blocking
#define MUZZLE_MUTE_NONE 0 // Does not mute you.
#define MUZZLE_MUTE_MUFFLE 1 // Muffles everything you say "MHHPHHMMM!!!
#define MUZZLE_MUTE_ALL 2 // Completely mutes you.

//MATERIAL CLASS FOR RACE EAT
#define MATERIAL_CLASS_NONE     (1<<0)
#define MATERIAL_CLASS_CLOTH    (1<<1)
#define MATERIAL_CLASS_TECH		(1<<2)
#define MATERIAL_CLASS_SOAP		(1<<3)


//These defines used in sprites, keep in touch with "Slot defines" above if needed
#define ITEM_SLOT_EAR_LEFT_STRING "left_ear"
#define ITEM_SLOT_EAR_RIGHT_STRING "right_ear"
#define ITEM_SLOT_BELT_STRING "belt"
#define ITEM_SLOT_BACK_STRING "back"
#define ITEM_SLOT_CLOTH_OUTER_STRING "suit"
#define ITEM_SLOT_CLOTH_INNER_STRING "uniform"
#define ITEM_SLOT_GLOVES_STRING "gloves"
#define ITEM_SLOT_EYES_STRING "glasses"
#define ITEM_SLOT_MASK_STRING "mask"
#define ITEM_SLOT_HEAD_STRING "head"
#define ITEM_SLOT_FEET_STRING "shoes"
#define ITEM_SLOT_ID_STRING "wear_id"
#define ITEM_SLOT_NECK_STRING "neck"
#define ITEM_SLOT_SUITSTORE_STRING "suit_store"
#define ITEM_SLOT_HANDCUFFED_STRING "handcuff"
#define ITEM_SLOT_LEGCUFFED_STRING "legcuffs"
#define ITEM_SLOT_ACCESSORY_STRING "accessory"
#define ITEM_SLOT_COLLAR_STRING "collar"

//Default icons to use to render clothes
#define DEFAULT_ICON_LEFT_EAR 'icons/mob/clothing/ears.dmi'
#define DEFAULT_ICON_RIGHT_EAR 'icons/mob/clothing/ears.dmi'
#define DEFAULT_ICON_BELT 'icons/mob/clothing/belt.dmi'
#define DEFAULT_ICON_BACK 'icons/mob/clothing/back.dmi'
#define DEFAULT_ICON_OUTER_SUIT 'icons/mob/clothing/suit.dmi'
#define DEFAULT_ICON_JUMPSUIT 'icons/mob/clothing/uniform.dmi'
#define DEFAULT_ICON_GLOVES 'icons/mob/clothing/hands.dmi'
#define DEFAULT_ICON_GLASSES 'icons/mob/clothing/eyes.dmi'
#define DEFAULT_ICON_WEAR_MASK 'icons/mob/clothing/mask.dmi'
#define DEFAULT_ICON_HEAD 'icons/mob/clothing/head.dmi'
#define DEFAULT_ICON_HANDCUFFED 'icons/mob/mob.dmi'
#define DEFAULT_ICON_SHOES 'icons/mob/clothing/feet.dmi'
#define DEFAULT_ICON_WEAR_ID 'icons/mob/mob.dmi'
#define DEFAULT_ICON_NECK 'icons/mob/clothing/neck.dmi'
#define DEFAULT_ICON_SUITSTORE 'icons/mob/clothing/belt_mirror.dmi'
#define DEFAULT_ICON_LEGCUFFED 'icons/mob/mob.dmi'
#define DEFAULT_ICON_ACCESSORY 'icons/mob/clothing/ties.dmi'
#define DEFAULT_ICON_COLLAR 'icons/mob/clothing/collar.dmi'

/// Wrapper for adding clothing based traits
#define ADD_CLOTHING_TRAIT(mob, cloth, trait) ADD_TRAIT(mob, trait, "[CLOTHING_TRAIT]_[UID(cloth)]")
/// Wrapper for removing clothing based traits
#define REMOVE_CLOTHING_TRAIT(mob, cloth, trait) REMOVE_TRAIT(mob, trait, "[CLOTHING_TRAIT]_[UID(cloth)]")

