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

#define CATAPULT_GRAVSLING 	1
#define CATAPULT_GRAVPUSH	2

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
