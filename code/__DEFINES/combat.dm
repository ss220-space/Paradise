//Damage things	//TODO: merge these down to reduce on defines
//Way to waste perfectly good damagetype names (BRUTE) on this... If you were really worried about case sensitivity, you could have just used lowertext(damagetype) in the proc...
#define BRUTE		"brute"
#define BURN		"fire"
#define TOX			"tox"
#define OXY			"oxy"
#define CLONE		"clone"
#define STAMINA 	"stamina"
#define BRAIN		"brain"

//damage flags
#define MELEE 		"melee"
#define BULLET 		"bullet"
#define LASER 		"laser"
#define ENERGY 		"energy"
#define BOMB 		"bomb"
#define BIO 		"bio"
#define RAD 		"rad"
#define FIRE 		"fire"
#define ACID 		"acid"
#define MAGIC		"magic"

/// All armors
#define ARMOR_LIST_ALL(...) list(ACID, BIO, BOMB, BULLET, ENERGY, FIRE, LASER, MAGIC, MELEE, RAD)

#define STUN		"stun"
#define WEAKEN		"weaken"
#define STAMCRIT	"stamcrit"
#define KNOCKDOWN	"knockdown"
#define PARALYZE	"paralize"
#define SLEEP		"sleep"
#define IMMOBILIZE	"immobilize"
#define IRRADIATE	"irradiate"
#define STUTTER		"stutter"
#define SLUR		"slur"
#define EYE_BLUR	"eye_blur"
#define DROWSY		"drowsy"
#define JITTER		"jitter"

//I hate adding defines like this but I'd much rather deal with bitflags than lists and string searches
#define BRUTELOSS (1<<0)
#define FIRELOSS (1<<1)
#define TOXLOSS (1<<2)
#define OXYLOSS (1<<3)
#define SHAME (1<<4)
#define OBLITERATION (1<<5)

//Bitflags defining which status effects could be or are inflicted on a mob
#define CANSTUN (1<<0)
#define CANWEAKEN (1<<1)
#define CANSTAMCRIT (1<<2)
#define CANKNOCKDOWN (1<<3)
#define CANPARALYSE (1<<4)
#define CANPUSH	 (1<<5)
#define PASSEMOTES (1<<6)      //Mob has a cortical borer or holders inside of it that need to see emotes.
#define IGNORESLOWDOWN (1<<7)
#define IGNORE_SPEED_CHANGES (1<<8)

//Health Defines
#define HEALTH_THRESHOLD_CRIT 0
#define HEALTH_THRESHOLD_DEAD -100

/// Maximum amount of staminaloss, living mob can have.
#define MAX_STAMINA_LOSS 120

//Grab levels
#define GRAB_PASSIVE 0
#define GRAB_AGGRESSIVE 1
#define GRAB_NECK 2
#define GRAB_KILL 3

#define MARTIAL_GRAB_AGGRESSIVE "martial_grab_aggressive"
#define MARTIAL_GRAB_NECK "martial_grab_neck"
#define MARTIAL_GRAB_KILL "martial_grab_kill"

//Grab breakout odds
#define GRAB_RESIST_CHANCE_AGGRESSIVE 60
#define GRAB_RESIST_CHANCE_NECK 20
#define GRAB_RESIST_CHANCE_KILL 5
///Time to upgrade aggressive/neck grab to the next level.
#define GRAB_UPGRADE_TIME (4 SECONDS)

//Attack types for checking shields/hit reactions

#define ITEM_ATTACK						(1 << 0)
#define UNARMED_ATTACK					(1 << 1)
#define PROJECTILE_ATTACK				(1 << 2)
#define THROWN_PROJECTILE_ATTACK		(1 << 3)
#define LEAP_ATTACK						(1 << 4)
#define MELEE_ATTACKS					(ITEM_ATTACK | THROWN_PROJECTILE_ATTACK | UNARMED_ATTACK | LEAP_ATTACK)

//attack visual effects
#define ATTACK_EFFECT_PUNCH		"punch"
#define ATTACK_EFFECT_KICK		"kick"
#define ATTACK_EFFECT_SMASH		"smash"
#define ATTACK_EFFECT_CLAW		"claw"
#define ATTACK_EFFECT_DISARM	"disarm"
#define ATTACK_EFFECT_BITE		"bite"
#define ATTACK_EFFECT_MECHFIRE	"mech_fire"
#define ATTACK_EFFECT_MECHTOXIN	"mech_toxin"
#define ATTACK_EFFECT_BOOP		"boop" //Honk
//NOTE: INTENT_HOTKEY_* defines are not actual intents!
//they are here to support hotkeys
#define INTENT_HOTKEY_LEFT  "left"
#define INTENT_HOTKEY_RIGHT "right"

//Embedded objects
#define EMBEDDED_PAIN_CHANCE 					15	//Chance for embedded objects to cause pain (damage user)
#define EMBEDDED_ITEM_FALLOUT 					5	//Chance for embedded object to fall out (causing pain but removing the object)
#define EMBED_CHANCE							45	//Chance for an object to embed into somebody when thrown (if it's sharp)
#define EMBEDDED_PAIN_MULTIPLIER				2	//Coefficient of multiplication for the damage the item does while embedded (this*item.w_class)
#define EMBEDDED_FALL_PAIN_MULTIPLIER			5	//Coefficient of multiplication for the damage the item does when it falls out (this*item.w_class)
#define EMBEDDED_IMPACT_PAIN_MULTIPLIER			4	//Coefficient of multiplication for the damage the item does when it first embeds (this*item.w_class)
#define EMBED_THROWSPEED_THRESHOLD				4	//The minimum value of an item's throw_speed for it to embed (Unless it has embedded_ignore_throwspeed_threshold set to 1)
#define EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER 8	//Coefficient of multiplication for the damage the item does when removed without a surgery (this*item.w_class)
#define EMBEDDED_UNSAFE_REMOVAL_TIME			30	//A Time in ticks, total removal time = (this*item.w_class)

// Body Part Zones
#define BODY_ZONE_HEAD		"head"
#define BODY_ZONE_CHEST		"chest"
#define BODY_ZONE_L_ARM		"l_arm"
#define BODY_ZONE_R_ARM		"r_arm"
#define BODY_ZONE_L_LEG		"l_leg"
#define BODY_ZONE_R_LEG		"r_leg"
#define BODY_ZONE_TAIL		"tail"
#define BODY_ZONE_WING		"wing"

#define BODY_ZONE_PRECISE_EYES		"eyes"
#define BODY_ZONE_PRECISE_MOUTH		"mouth"
#define BODY_ZONE_PRECISE_GROIN		"groin"
#define BODY_ZONE_PRECISE_L_HAND	"l_hand"
#define BODY_ZONE_PRECISE_R_HAND	"r_hand"
#define BODY_ZONE_PRECISE_L_FOOT	"l_foot"
#define BODY_ZONE_PRECISE_R_FOOT	"r_foot"


//We will round to this value in damage calculations.
#define DAMAGE_PRECISION 0.1

//Gun Stuff
#define SAWN_INTACT  0
#define SAWN_OFF     1

#define WEAPON_DUAL_WIELD 0
#define WEAPON_LIGHT 1
#define WEAPON_MEDIUM 2
#define WEAPON_HEAVY 3

#define EXPLODE_NONE 0				//Don't even ask me why we need this.
#define EXPLODE_DEVASTATE 1
#define EXPLODE_HEAVY 2
#define EXPLODE_LIGHT 3

#define EMP_HEAVY 1
#define EMP_LIGHT 2

// Return values used in item/melee/baton/baton_attack.
/// Does a normal item attack.
#define BATON_DO_NORMAL_ATTACK 1
/// The attack has been stopped. Either because the user was clumsy or the attack was blocked.
#define BATON_ATTACK_DONE 2
/// The baton attack is still going. baton_effect() is called.
#define BATON_ATTACKING 3

/*
* converts life cycle values into deciseconds. try and avoid usage of this.
* this is needed as many functions for stun durations used to output cycles as values, but we now track stun times in deciseconds.
*/
#define STATUS_EFFECT_CONSTANT * 20


/// Projectile reflectability defines
#define REFLECTABILITY_NEVER 0
#define REFLECTABILITY_PHYSICAL 1
#define REFLECTABILITY_ENERGY 2


//Autofire component
/// Compatible firemode is in the gun. Wait until it's held in the user hands.
#define AUTOFIRE_STAT_IDLE (1<<0)
/// Gun is active and in the user hands. Wait until user does a valid click.
#define AUTOFIRE_STAT_ALERT	(1<<1)
/// Gun is shooting.
#define AUTOFIRE_STAT_FIRING (1<<2)

#define COMSIG_AUTOFIRE_ONMOUSEDOWN "autofire_onmousedown"
	#define COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS (1<<0)
#define COMSIG_AUTOFIRE_SHOT "autofire_shot"
	#define COMPONENT_AUTOFIRE_SHOT_SUCCESS (1<<0)

#define HELP_SLASH "Help"
#define DISARM_SLASH "Disarm"
#define GRAB_SLASH "Grab"
#define HARM_SLASH "Harm"

#define COMBO_STEPS "steps"
#define COMBO_PROC "proc"


// core bitflags
#define ATTACK_CHAIN_PROCEED (1<<2)	// intentionally not started with (1<<0) or 1, since 1 is equal to TRUE
#define ATTACK_CHAIN_BLOCKED (1<<3)	// and we want to check validity of the core bitflags, returned by the attack chain procs
// optional bitflags
#define ATTACK_CHAIN_SUCCESS (1<<0)
#define ATTACK_CHAIN_NO_AFTERATTACK (1<<1)
// bitflag combinations
#define ATTACK_CHAIN_PROCEED_SUCCESS (ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_SUCCESS)
#define ATTACK_CHAIN_BLOCKED_ALL (ATTACK_CHAIN_BLOCKED|ATTACK_CHAIN_NO_AFTERATTACK)
#define ATTACK_CHAIN_CORE_RETURN_BITFLAGS (ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_BLOCKED)
/// Helper to check whether attack chain result was blocked
#define ATTACK_CHAIN_CANCEL_CHECK(bitflags) ((bitflags) & ATTACK_CHAIN_BLOCKED)
/// Helper to check whether attack chain result wasn't blocked and was successful
#define ATTACK_CHAIN_SUCCESS_CHECK(bitflags) ((!ATTACK_CHAIN_CANCEL_CHECK(bitflags) && ((bitflags) & ATTACK_CHAIN_SUCCESS)))

