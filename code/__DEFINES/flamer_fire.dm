/*
////FLAMER STUFF////
Burn level = How much damage do we want to deal? Simple
Burn time = How long do we want our flames to last?
Fire Variant = Markers for special fire types that behave outside of chemfire constraints. Comment general notes.
*/

#define BURN_LEVEL_TIER_1 10
#define BURN_LEVEL_TIER_2 15
#define BURN_LEVEL_TIER_3 20
#define BURN_LEVEL_TIER_4 25
#define BURN_LEVEL_TIER_5 30
#define BURN_LEVEL_TIER_6 35
#define BURN_LEVEL_TIER_7 40
#define BURN_LEVEL_TIER_8 45
#define BURN_LEVEL_TIER_9 50

#define BURN_TIME_INSTANT 1
#define BURN_TIME_TIER_1 10
#define BURN_TIME_TIER_2 20
#define BURN_TIME_TIER_3 30
#define BURN_TIME_TIER_4 40
#define BURN_TIME_TIER_5 50

#define BURN_TIME_DEVIL 5

///Default fire behavior: No associated values.
#define FIRE_VARIANT_DEFAULT 0
///"Type B" Armor Shredding Greenfire: Burn Time T5, Burn Level T2, Slows on Tile, Increased Tile Damage, Easier Extinguishing.
#define FIRE_VARIANT_TYPE_B 1
// Lowers burn damage to humans
#define HUMAN_BURN_DIVIDER 5

// Flamer fire shapes
#define FLAMESHAPE_NONE "none"
#define FLAMESHAPE_DEFAULT "default"
#define FLAMESHAPE_STAR "star"
#define FLAMESHAPE_MINORSTAR "minorstar"
#define FLAMESHAPE_IRREGULAR "irregular"
#define FLAMESHAPE_TRIANGLE "triangle"
#define FLAMESHAPE_LINE "line"

#define FIRE_DAMAGE_PER_LEVEL 3
#define FIRE_DAMAGE_PER_LEVEL_MOB 1.5

#define IGNITE_FAILED 0
#define IGNITE_ON_FIRE (1<<0)
#define IGNITE_IGNITED (1<<1)

#define FLAME_REAGENT_USE_AMOUNT 1


#define SLOWDOWN_AMT_GREENFIRE 1.5
