/// Lazy assoc list in format Key(hole UID) - List(mobs)
GLOBAL_LIST_EMPTY(bingles_by_hole)

/// Typecache list of things not allowed in bingle holes
GLOBAL_LIST_INIT(bingle_hole_blacklist, typecacheof(list(
	/mob/living/simple_animal/hostile/bingle,
	/obj/effect,
	/obj/projectile,
	/obj/structure/bingle_hole,
	/obj/structure/bingle_pit_overlay,
	/obj/item/disk/nuclear, // No log spam
	)
))

/// Assoc list of stack objects and their respective gain limits
GLOBAL_LIST_INIT(bingle_hole_stack_limit, list(
	/obj/item/stack/cable_coil = 3, // Gets really weird when there are toolboxes with 90 cable coils
	/obj/item/stack/spacecash = 2, // If someone decides to feed the pit with money, that would be funny
	/obj/item/stack/spacechips = 4, // Basically just rarer cash
))

/// Max possible size of bingle hole via item consumption
#define BINGLE_PIT_MAX_SIZE 40
/// Goal size of bingle hole
#define BINGLE_PIT_SIZE_GOAL 40
/// At what size do we announce to the station about bingles
#define ANNOUNCE_BINGLE_PIT_SIZE 3
/// At what size do we send nuclear codes
#define NUCLEAR_CODE_BINGLE_PIT_SIZE 25

/// How much time is given at BINGLE_PIT_SIZE_GOAL for crew to kill the hole until it wins
#define BINGLE_PIT_WIN_DELAY 1 MINUTES
/// How often do we grow the pit while the win delay is active
#define BINGLE_PIT_WIN_GROW_COOLDOWN 2 SECONDS
/// To what size do we grow the hole after win while the cinematic plays
#define BINGLE_PIT_AFTER_WIN_SIZE 200

/// By how much do we multiply maxHealth variable on evolve
#define BINGLE_EVOLVE_HEALTH_MULTIPLIER 1.5
/// By how much do we multiply obj_damage variable on evolve
#define BINGLE_EVOLVE_OBJ_DAMAGE_MULTIPLIER 2

/// How often based on item_value_consumed do we grow the pit
#define BINGLE_PIT_GROW_VALUE 100
/// How many more items do we need per size increase for grow
#define BINGLE_PIT_ON_GROW_INCREASE_VALUE 2
/// By how much do we increase the health of the bingle pit on growth
#define BINGLE_PIT_GROW_INTEGRITY_INCREASE 25

/// How often based on item_value_consumed do we spawn a bingle
#define BINGLE_SPAWN_VALUE 50
/// At what item_value_consumed do bingles become evolved
#define BINGLE_EVOLVE_VALUE 500

/// How much the pit should heal from living mobs
#define BINGLE_PIT_LIVING_HEAL 25
/// How much the pit should heal from carbon mobs with mind
#define BINGLE_PIT_PLAYER_HEAL 50
// How much the pit should heal from consuming an item
#define BINGLE_PIT_OBJECT_CONSUME_HEAL 2

/// How much does the pit gain from living mobs
#define BINGLE_PIT_LIVING_VALUE 25
/// How much we gain from eating singularities
#define BINGLE_PIT_SINGULARITY_VALUE 200
/// How much we gain from any object (multiplied by stack amount)
#define BINGLE_PIT_DEFAULT_OBJECT_GAIN_VALUE 1
/// Limit of value gained from stack items
#define BINGLE_PIT_STACK_GAIN_LIMIT 30
/// Maximum amount of resources we can gain from an object's contents
#define BINGLE_PIT_OBJECT_CONTENTS_VALUE_LIMIT 100

/// How much extra defense we get on each successful hole merge
#define BINGLE_PIT_MERGE_ARMOR_INCREASE 15
/// Maximum of armor value we can get from hole merging
#define BINGLE_PIT_MERGE_ARMOR_CAP 75
