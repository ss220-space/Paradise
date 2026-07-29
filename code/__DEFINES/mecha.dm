// Mech equipment types
#define MECH_EQUIPMENT_ALL (ALL)
#define MECH_EQUIPMENT_GYGAX (1<<0)
#define MECH_EQUIPMENT_DURAND (1<<1)
#define MECH_EQUIPMENT_PHAZON (1<<2)
#define MECH_EQUIPMENT_MARAUDER (1<<3)
#define MECH_EQUIPMENT_COMBAT (MECH_EQUIPMENT_GYGAX | MECH_EQUIPMENT_DURAND | MECH_EQUIPMENT_MARAUDER | MECH_EQUIPMENT_PHAZON)
#define MECH_EQUIPMENT_RIPPLEY (1<<4)
#define MECH_EQUIPMENT_FIREFIGHTER (1<<5)
#define MECH_EQUIPMENT_CLARKE (1<<6)
#define MECH_EQUIPMENT_WORKING (MECH_EQUIPMENT_RIPPLEY | MECH_EQUIPMENT_FIREFIGHTER | MECH_EQUIPMENT_CLARKE)
#define MECH_EQUIPMENT_MEDICAL (1<<7)
#define MECH_EQUIPMENT_MAKESHIFT (1<<8)
#define MECH_EQUIPMENT_MIME (1<<9)
#define MECH_EQUIPMENT_CLOWN (1<<10)

#define MECHA_INT_FIRE (1<<0)
#define MECHA_INT_TEMP_CONTROL (1<<1)
#define MECHA_INT_SHORT_CIRCUIT (1<<2)
#define MECHA_INT_TANK_BREACH (1<<3)
#define MECHA_INT_CONTROL_LOST (1<<4)

#define MECHA_MELEE (1<<0)
#define MECHA_RANGED (1<<1)

#define MECHAMOVE_RAND (1<<0)
#define MECHAMOVE_TURN (1<<1)
#define MECHAMOVE_STEP (1<<2)

#define MECHA_FRONT_ARMOUR 1
#define MECHA_SIDE_ARMOUR 2
#define MECHA_BACK_ARMOUR 3

#define CATAPULT_GRAVSLING 1
#define CATAPULT_GRAVPUSH 2

#define FIRE_SYRINGE_MODE 0
#define ANALYZE_SYRINGE_MODE 1

// Some mechs must (at least for now) use snowflake handling of their UI elements, these defines are for that
// when changing MUST update the same-named tsx file constants
#define MECHA_SNOWFLAKE_ID_SLEEPER "sleeper_snowflake"
#define MECHA_SNOWFLAKE_ID_SYRINGE "syringe_snowflake"
#define MECHA_SNOWFLAKE_ID_MODE "mode_snowflake"
#define MECHA_SNOWFLAKE_ID_EXTINGUISHER "extinguisher_snowflake"
#define MECHA_SNOWFLAKE_ID_EJECTOR "ejector_snowflake"
#define MECHA_SNOWFLAKE_ID_OREBOX_MANAGER "orebox_manager_snowflake"
#define MECHA_SNOWFLAKE_ID_RADIO "radio_snowflake"
#define MECHA_SNOWFLAKE_ID_AIR_TANK "air_tank_snowflake"
#define MECHA_SNOWFLAKE_ID_WEAPON_BALLISTIC "ballistic_weapon_snowflake"
#define MECHA_SNOWFLAKE_ID_GENERATOR "generator_snowflake"
#define MECHA_SNOWFLAKE_ID_ORE_SCANNER "orescanner_snowflake"
#define MECHA_SNOWFLAKE_ID_CLAW "lawclaw_snowflake"
#define MECHA_SNOWFLAKE_ID_RCD "rcd_snowflake"
#define MECHA_SNOWFLAKE_ID_MULTI "multimodule_snowflake"
#define MECHA_SNOWFLAKE_ID_CAGE "cage_snowflake"
#define MECHA_SNOWFLAKE_ID_CABLE "cable_snoflake"
#define MECHA_SNOWFLAKE_ID_HOLO "holo_snowflake"
#define MECHA_SNOWFLAKE_ID_TOOLSET "toolset_snowflake"

#define MECHA_LOCKED 0
#define MECHA_SECURE_BOLTS 1
#define MECHA_LOOSE_BOLTS 2
#define MECHA_OPEN_HATCH 3
#define MECHA_UNSECURE_CELL 4

#define MODULE_SELECTABLE_NONE 0
#define MODULE_SELECTABLE_TOGGLE 1
#define MODULE_SELECTABLE_FULL 2

#define WORKING_MECH 1
#define MEDICAL_MECH 2
#define COMBAT_MECH 3

// Mech Subtypes
#define MECH_TYPE_NONE (1<<0)
#define MECH_TYPE_RIPLEY (1<<1)
#define MECH_TYPE_CLARKE (1<<2)
#define MECH_TYPE_ODYSSEUS (1<<3)
#define MECH_TYPE_GYGAX (1<<4)
#define MECH_TYPE_DURAND (1<<5)
#define MECH_TYPE_PHAZON (1<<6)
#define MECH_TYPE_HONKER (1<<7)
#define MECH_TYPE_RETICENCE (1<<8)
#define MECH_TYPE_LOCKER (1<<9)
#define MECH_TYPE_MARAUDER (1<<10)
#define MECH_TYPE_SIDEWINTER (1<<11)
#define MECH_TYPE_OLD_DURAND (1<<12)
#define MECH_TYPE_DARK_GYGAX (1<<13)

#define MECH_HAND_LEFT "в левую руку"
#define MECH_HAND_RIGHT "в правую руку"
