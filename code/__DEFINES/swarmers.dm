/// Assoc list containing all action types that are given based on type on init
GLOBAL_LIST_INIT(swarmer_actions_by_type, list(
	// Starting swarmer
	/mob/living/simple_animal/hostile/swarmer/basic = list(
		/datum/action/innate/hide/swarmer, // Until someone refactors the way hide action is handled
		),
	// Generalist swarmer
	/mob/living/simple_animal/hostile/swarmer/generalist = list(
		/datum/action/cooldown/swarmer/build/barricade,
		/datum/action/cooldown/swarmer/build/trap,
		/datum/action/cooldown/swarmer/build/rapid_turret,
		),
	// Rover swarmer
	/mob/living/simple_animal/hostile/swarmer/rover = list(
		/datum/action/innate/hide/swarmer, // Until someone refactors the way hide action is handled
		/datum/action/cooldown/swarmer/build/trap,
		/datum/action/cooldown/swarmer/build/transport_hub,
		),
	// Combat swarmer
	/mob/living/simple_animal/hostile/swarmer/combat = list(
		/datum/action/cooldown/swarmer/build/barricade,
		),
	// Builder swarmer
	/mob/living/simple_animal/hostile/swarmer/builder = list(
		/datum/action/cooldown/swarmer/build/processer,
		/datum/action/cooldown/swarmer/build/analyzer,
		/datum/action/cooldown/swarmer/build/repair_station,
		/datum/action/cooldown/swarmer/build/storage,
		/datum/action/cooldown/swarmer/build/rapid_turret,
		/datum/action/cooldown/swarmer/build/sniper_turret,
		/datum/action/cooldown/swarmer/build/acp_turret,
		/datum/action/cooldown/swarmer/move_core,
		),
	// Mega swarmer
	/mob/living/simple_animal/hostile/swarmer/mega = list(
		/datum/action/cooldown/swarmer/build/nanobot_fabricator,
		),
	))

/// List containing all swarmers mobs.
GLOBAL_LIST_EMPTY(swarmers)

// MARK: Swarmer spawn values
/// How often based on organic resources do we spawn a swarmer
#define SWARMER_SPAWN_VALUE 50
/// How often based on organic resources do we spawn a mega-swarmer
/// Ideally divisable by SWARMER_SPAWN_VALUE
#define MEGA_SWARMER_SPAWN_VALUE 1200


// MARK: Swarmer delays
/// Worst swarmer deconstruction speed modifier
#define SLOW_SWARMER_DISMANTLE_DELAY 8 SECONDS
/// Average swarmer deconstruction speed modifier
#define NORMAL_SWARMER_DISMANTLE_DELAY 5 SECONDS
/// Best swarmer deconstruction speed modifier
#define FAST_SWARMER_DISMANTLE_DELAY 2 SECONDS
/// Smallest build delay
#define SWARMER_FAST_BUILD_DELAY 2 SECONDS
/// Average build delay
#define SWARMER_NORMAL_BUILD_DELAY 5 SECONDS
/// Biggest build delay
#define SWARMER_SLOW_BUILD_DELAY 10 SECONDS
/// How long does it take for a swarmer to teleport through hubs (Note: Rovers take twice less time)
#define SWARMER_TELEPORT_DELAY(swarmer) (is_roverswarmer(swarmer) ? 4 SECONDS : 8 SECONDS)
/// How long does it take for swarmer to repair something (Builder swarmers take twice less time)
#define SWARMER_REPAIR_DELAY(swarmer) (is_builderswarmer(swarmer) ? 0.5 SECONDS : 1 SECONDS)
/// How much swarmer related stuff gets repaired by (Builder swarmer repair twice more)
#define SWARMER_REPAIR_AMOUNT(swarmer) (is_builderswarmer(swarmer) ? 30 : 15)
/// How long does it take for a swarmer to send anything to a processer
#define SWARMER_SEND_ORGANIC_DELAY 2 SECONDS
/// How long does it take for a swarmer to send anything to an analyzer
#define SWARMER_SEND_ANALYZER_DELAY 4 SECONDS


// MARK: Ability costs
/// How many metallic resources does it cost for swarmer to repair something
#define SWARMER_REPAIR_COST 1


// MARK: Swarmer EMP effects
/// How much swarmers and swarmer structures get damaged on emp
#define SWARMER_EMP_DAMAGE 25
/// For how long do swarmer structures get disabled for on emp_act
#define SWARMER_STRUCTURE_EMP_DURATION 10 SECONDS


// MARK: Swarmer act return bitflags
/// Value returned if an atom can be swarmer_act'ed
#define SWARMER_ACT_POSSIBLE (1<<0)
/// Value returned if an atom can't be swarmer_act'ed
#define SWARMER_ACT_IMPOSSIBLE (1<<1)
/// Value returned if an atom has default behaviour on right click
/// For it to work correctly, an atom must have attack_swarmer_secondary proc
/// always return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
#define SWARMER_ACT_RIGHT_CLICK_DEFAULT (1<<2)

/// Bitflag combinaton for possible swarmer_act, means we should damage the atom
#define SWARMER_ACT_POSSIBLE_ACTION_DAMAGE (1<<3)
/// Bitflag combination for possible swarmer_act, means we should slowly dismantle the atom
#define SWARMER_ACT_POSSIBLE_ACTION_DISMANTLE (1<<4)
/// Bitflag combination for possible swarmer_act, means we should immediately consume the atom (and gain something)
#define SWARMER_ACT_POSSIBLE_ACTION_CONSUME (1<<5)
/// Bitflag combination for possible swarmer_act, means we should immediately delete the atom
#define SWARMER_ACT_POSSIBLE_ACTION_DESTROY (1<<6)

/// Bitflag combinaton for impossible swarmer_act, means the act was failed since atom is needed for energy
#define SWARMER_ACT_IMPOSSIBLE_REASON_ENERGY (1<<3)
/// Bitflag combinaton for impossible swarmer_act, means the act was failed since atom is important for stuff to live
#define SWARMER_ACT_IMPOSSIBLE_REASON_LIVING (1<<4)
/// Bitflag combinaton for impossible swarmer_act, means the act was failed since atom is important for atmos to work correctly
#define SWARMER_ACT_IMPOSSIBLE_REASON_ATMOS (1<<5)
/// Bitflag combinaton for impossible swarmer_act, means the act was failed since atom is created by swarmers
#define SWARMER_ACT_IMPOSSIBLE_REASON_TEAM (1<<6)
/// Bitflag combination for impossible swarmer_act, means the act's default behaviour is overridden
#define SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE (1<<7)
/// Bitflag combination for impossible swarmer_act, means the act's default behaviour is ignored, and we just attack
#define SWARMER_ACT_IMPOSSIBLE_REASON_DEFAULT (1<<8)
