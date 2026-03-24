#define MEAT (1<<0)
#define VEGETABLES (1<<1)
#define RAW (1<<2)
#define JUNKFOOD (1<<3)
#define GRAIN (1<<4)
#define FRUIT (1<<5)
#define DAIRY (1<<6)
#define FRIED (1<<7)
#define ALCOHOL (1<<8)
#define SUGAR (1<<9)
#define GROSS (1<<10)
#define TOXIC (1<<11)
#define PINEAPPLE (1<<12)
#define BREAKFAST (1<<13)
#define CLOTH (1<<14)
#define NUTS (1<<15)
#define SEAFOOD (1<<16)
#define ORANGES (1<<17)
#define BUGS (1<<18)
#define GORE (1<<19)
#define STONE (1<<20)

DEFINE_BITFIELD(foodtypes, list(
	"MEAT" = MEAT,
	"VEGETABLES" = VEGETABLES,
	"RAW" = RAW,
	"JUNKFOOD" = JUNKFOOD,
	"GRAIN" = GRAIN,
	"FRUIT" = FRUIT,
	"DAIRY" = DAIRY,
	"FRIED" = FRIED,
	"ALCOHOL" = ALCOHOL,
	"SUGAR" = SUGAR,
	"GROSS" = GROSS,
	"TOXIC" = TOXIC,
	"PINEAPPLE" = PINEAPPLE,
	"BREAKFAST" = BREAKFAST,
	"CLOTH" = CLOTH,
	"NUTS" = NUTS,
	"SEAFOOD" = SEAFOOD,
	"ORANGES" = ORANGES,
	"BUGS" = BUGS,
	"GORE" = GORE,
	"STONE" = STONE,
))

/// A list of food type names, in order of their flags
#define FOOD_FLAGS list( \
	"MEAT", \
	"VEGETABLES", \
	"RAW", \
	"JUNKFOOD", \
	"GRAIN", \
	"FRUIT", \
	"DAIRY", \
	"FRIED", \
	"ALCOHOL", \
	"SUGAR", \
	"GROSS", \
	"TOXIC", \
	"PINEAPPLE", \
	"BREAKFAST", \
	"CLOTH", \
	"NUTS", \
	"SEAFOOD", \
	"ORANGES", \
	"BUGS", \
	"GORE", \
	"STONE", \
)

/// IC meaning (more or less) for food flags
#define FOOD_FLAGS_IC list( \
	"Meat", \
	"Vegetables", \
	"Raw food", \
	"Junk food", \
	"Grain", \
	"Fruits", \
	"Dairy products", \
	"Fried food", \
	"Alcohol", \
	"Sugary food", \
	"Gross food", \
	"Toxic food", \
	"Pineapples", \
	"Breakfast food", \
	"Clothing", \
	"Nuts", \
	"Seafood", \
	"Oranges", \
	"Bugs", \
	"Gore", \
	"Rocks", \
)

/// Food types assigned to all podperson organs
#define PODPERSON_ORGAN_FOODTYPES (VEGETABLES | RAW | GORE)

#define DRINK_REVOLTING 1
#define DRINK_NICE 2
#define DRINK_GOOD 3
#define DRINK_VERYGOOD 4
#define DRINK_FANTASTIC 5

#define FOOD_AMAZING 6

#define FOOD_QUALITY_NORMAL 1
#define FOOD_QUALITY_NICE 2
#define FOOD_QUALITY_GOOD 3
#define FOOD_QUALITY_VERYGOOD 4
#define FOOD_QUALITY_FANTASTIC 5
#define FOOD_QUALITY_AMAZING 6
#define FOOD_QUALITY_TOP 7

#define FOOD_COMPLEXITY_0 0
#define FOOD_COMPLEXITY_1 1
#define FOOD_COMPLEXITY_2 2
#define FOOD_COMPLEXITY_3 3
#define FOOD_COMPLEXITY_4 4
#define FOOD_COMPLEXITY_5 5

/// Labels for food quality
GLOBAL_ALIST_INIT(food_quality_description, alist(
	FOOD_QUALITY_NORMAL = "okay",
	FOOD_QUALITY_NICE = "nice",
	FOOD_QUALITY_GOOD = "good",
	FOOD_QUALITY_VERYGOOD = "very good",
	FOOD_QUALITY_FANTASTIC = "fantastic",
	FOOD_QUALITY_AMAZING = "amazing",
	FOOD_QUALITY_TOP = "godlike",
))

/// Weighted lists of crafted food buffs randomly given according to crafting_complexity unless the food has a specific buff
/** TODO
GLOBAL_ALIST_INIT(food_buffs, alist(
	FOOD_COMPLEXITY_1 = list(
		/datum/status_effect/food/haste = 1,
	),
	FOOD_COMPLEXITY_2 = list(
		/datum/status_effect/food/haste = 1,
	),
	FOOD_COMPLEXITY_3 = list(
		/datum/status_effect/food/haste = 1,
	),
	FOOD_COMPLEXITY_4 = list(
		/datum/status_effect/food/haste = 1,
	),
	FOOD_COMPLEXITY_5 = list(
		/datum/status_effect/food/haste = 1,
	),
))
*/

/// Food quality change according to species diet
#define DISLIKED_FOOD_QUALITY_CHANGE -2
#define LIKED_FOOD_QUALITY_CHANGE 2
/// Threshold for food to give a toxic reaction
#define TOXIC_FOOD_QUALITY_THRESHOLD -8
/// Food is dangerous to consume
#define FOOD_QUALITY_DANGEROUS -100

/// Food is "in a container", not in a code sense, but in a literal sense (canned foods)
#define FOOD_IN_CONTAINER (1<<0)
/// Finger food can be eaten while walking / running around
#define FOOD_FINGER_FOOD (1<<1)
/// Examining this edible won't show infos on food types, bites and remote tasting etc.
#define FOOD_NO_EXAMINE (1<<2)
/// This food item doesn't track bitecounts, use responsibly.
#define FOOD_NO_BITECOUNT (1<<3)

DEFINE_BITFIELD(food_flags, list(
	"FOOD_FINGER_FOOD" = FOOD_FINGER_FOOD,
	"FOOD_IN_CONTAINER" = FOOD_IN_CONTAINER,
	"FOOD_NO_EXAMINE" = FOOD_NO_EXAMINE,
	"FOOD_NO_BITECOUNT" = FOOD_NO_BITECOUNT,
))

///Define for return value of the after_eat callback that will call OnConsume if it hasn't already.
#define FOOD_AFTER_EAT_CONSUME_ANYWAY 2

#define STOP_SERVING_BREAKFAST (15 MINUTES)

#define FOOD_MEAT_HUMAN 50
#define FOOD_MEAT_MUTANT 100
#define FOOD_MEAT_MUTANT_RARE 200

#define IS_EDIBLE(O) (O.GetComponent(/datum/component/edible))

///Food trash flags
#define FOOD_TRASH_POPABLE (1<<0)
#define FOOD_TRASH_OPENABLE (1<<1)

///Food preference enums
#define FOOD_LIKED 1
#define FOOD_DISLIKED 2
#define FOOD_TOXIC 3
#define FOOD_ALLERGIC 4

/// Time spent deep frying an item after which it becomes fried.
#define FRYING_TIME_FRIED (15 SECONDS)
/// Time spent deep frying an item after which it becomes fried to perfection.
#define FRYING_TIME_PERFECT (50 SECONDS)
/// Time spent deep frying an item after which it becomes burnt.
#define FRYING_TIME_BURNT (85 SECONDS)
/// Time spent deep frying an item after which it starts smelling bad.
#define FRYING_TIME_WARNING (120 SECONDS)

#define BLACKBOX_LOG_FOOD_MADE(food) SSblackbox.record_feedback("tally", "food_made", 1, food)

/// Point water boils at
#define WATER_BOILING_POINT (T0C + 100)
/// Point at which soups begin to burn at
#define SOUP_BURN_TEMP 540

/// Serving size of soup. Plus or minus five units.
#define SOUP_SERVING_SIZE 25

/// How much milk is needed to make butter on a reagent grinder
#define MILK_TO_BUTTER_COEFF 25

/// How much material one slab of meat usually contains
#define MEATSLAB_MATERIAL_AMOUNT SHEET_MATERIAL_AMOUNT * 4
/// How many cutlets or meatballs one slab gives when processed
#define MEATSLAB_PROCESSED_AMOUNT 3
/// This should be 1/3 of the amount found in a slab (a portion will be lost when rounding but it's negligible)
#define MEATDISH_MATERIAL_AMOUNT (MEATSLAB_MATERIAL_AMOUNT / MEATSLAB_PROCESSED_AMOUNT)
