//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
#define HIDEGLOVES		(1<<0)	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESUITSTORAGE	(1<<1)	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEJUMPSUIT	(1<<2)	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESHOES		(1<<3)	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDETAIL 		(1<<4)	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEMASK		(1<<5)	//APPLIES ONLY TO HELMETS/MASKS!!
#define HIDEHEADSETS	(1<<6)	//APPLIES ONLY TO HELMETS/MASKS!! (headsets and such)
#define HIDEGLASSES		(1<<7)	//APPLIES ONLY TO HELMETS/MASKS!!
#define HIDENAME		(1<<8)	//APPLIES ONLY TO HELMETS/MASKS!! Dictates whether we appear as unknown.

// slots
#define slot_back 1
#define slot_wear_mask 2
#define slot_handcuffed 3
#define slot_l_hand 4
#define slot_r_hand 5
#define slot_belt 6
#define slot_wear_id 7
#define slot_l_ear 8
#define slot_glasses 9
#define slot_gloves 10
#define slot_head 11
#define slot_shoes 12
#define slot_wear_suit 13
#define slot_w_uniform 14
#define slot_l_store 15
#define slot_r_store 16
#define slot_s_store 17
#define slot_in_backpack 18
#define slot_legcuffed 19
#define slot_r_ear 20
#define slot_wear_pda 21
#define slot_tie 22
#define slot_collar 23
#define slot_neck 24
#define slots_amt 24

// accessory slots
#define ACCESSORY_SLOT_DECOR 1
#define ACCESSORY_SLOT_UTILITY 2
#define ACCESSORY_SLOT_ARMBAND 3

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
#define MATERIAL_CLASS_NONE     0
#define MATERIAL_CLASS_CLOTH    1
#define MATERIAL_CLASS_TECH		2
#define MATERIAL_CLASS_SOAP		3
