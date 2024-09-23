//NOTE: Breathing happens once EVERY OTHER TICK.
#define HUMAN_MAX_OXYLOSS 5 //Defines how much oxyloss humans can get per tick. A tile with no air at all (such as space) applies this value, otherwise it's a percentage of it.

#define HEAT_DAMAGE_LEVEL_1 2 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 3 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 5 //Amount of damage applied when your body temperature passes the 1000K point

#define COLD_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when your body temperature just passes the 260.15k safety point
#define COLD_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when your body temperature passes the 200K point
#define COLD_DAMAGE_LEVEL_3 3 //Amount of damage applied when your body temperature passes the 120K point

//Note that gas heat damage is only applied once every FOUR ticks.
#define HEAT_GAS_DAMAGE_LEVEL_1 2 //Amount of damage applied when the current breath's temperature just passes the 360.15k safety point
#define HEAT_GAS_DAMAGE_LEVEL_2 4 //Amount of damage applied when the current breath's temperature passes the 400K point
#define HEAT_GAS_DAMAGE_LEVEL_3 8 //Amount of damage applied when the current breath's temperature passes the 1000K point

#define COLD_GAS_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when the current breath's temperature just passes the 260.15k safety point
#define COLD_GAS_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when the current breath's temperature passes the 200K point
#define COLD_GAS_DAMAGE_LEVEL_3 3 //Amount of damage applied when the current breath's temperature passes the 120K point

/// Used to calculate threshold to vomit
#define REQUIRED_VOMIT_TOXLOSS   45
#define REQUIRED_VOMIT_NUTRITION 20
/// Vomit defines
#define VOMIT_NUTRITION_LOSS     10
#define VOMIT_STUN_TIME          (8 SECONDS)
#define VOMIT_BLOOD_LOSS         0
#define VOMIT_DISTANCE           0
/// When reached - we'll apply status effect which will force carbon to vomit
#define VOMIT_THRESHOLD_REACHED(carbon) (carbon.getToxLoss() > REQUIRED_VOMIT_TOXLOSS && carbon.nutrition > REQUIRED_VOMIT_NUTRITION)
