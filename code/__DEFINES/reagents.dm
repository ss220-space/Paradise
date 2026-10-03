#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REAGENT_OVERDOSE_EFFECT 1
#define REAGENT_OVERDOSE_FLAGS 2
#define REAGENT_EVAPARATION_RATIO 0.3

//Methods to interact with reagents in the holder
/// Makes it possible to add reagents through droppers and syringes.
#define INJECTABLE (1<<0)
/// Makes it possible to remove reagents through syringes.
#define DRAWABLE (1<<1)
/// Makes it possible to add reagents through any reagent container.
#define REFILLABLE (1<<2)
/// Makes it possible to remove reagents through any reagent container.
#define DRAINABLE (1<<3)
/// Allows items to be dunked into this container for transfering reagents. Used in conjunction with the dunkable component.
#define DUNKABLE (1<<4)

#define TRANSPARENT (1<<5) // Used on containers which you want to be able to see the reagents off.
#define AMOUNT_VISIBLE (1<<6) // For non-transparent containers that still have the general amount of reagents in them visible.

//Special properties
///If the holder is a sealed container - Used if you don't want reagent contents boiling out (plasma, specifically, in which case it only bursts out when at ignition temperatures)
#define SEALED_CONTAINER (1<<10)
/// Prevents splashing for open reagent containers
#define NO_SPLASH (1<<11)
// Is an open container for all intents and purposes.
#define OPENCONTAINER (REFILLABLE | DRAINABLE | TRANSPARENT)

#define REAGENT_TOUCH 1
#define REAGENT_INGEST 2

#define GRENADE_EMPTY 0
#define GRENADE_WIRED 1
#define GRENADE_READY 2

/// Water temperature
#define COLD_WATER_TEMPERATURE 283.15 // 10 degrees celsius
