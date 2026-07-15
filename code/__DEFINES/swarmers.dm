// === SWARMER SPAWNING ===
/// How often based on organic resources do we spawn a swarmer
#define SWARMER_SPAWN_VALUE 50
/// How often based on organic resources do we spawn a mega-swarmer
/// Ideally divisable by SWARMER_SPAWN_VALUE
#define MEGA_SWARMER_SPAWN_VALUE 1200

// === SWARMER CLASSES & SWAPPING ===
/// How many metallic resources are required to swap to this class (Note: Swapping from non-basic swarmer costs twice less)
#define GENERALIST_SWAP_COST 20
#define ROVER_SWAP_COST 18
#define COMBAT_SWAP_COST 30
/// If there are no builders, the swap cost is zero
#define BUILDER_SWAP_COST 20

// === TIMING & DELAYS ===
/// Worst swarmer deconstruction speed modifier
#define SLOW_SWARMER_DISMANTLE_DELAY 15 SECONDS
/// Average swarmer deconstruction speed modifier
#define NORMAL_SWARMER_DISMANTLE_DELAY 8 SECONDS
/// Best swarmer deconstruction speed modifier
#define FAST_SWARMER_DISMANTLE_DELAY 3 SECONDS

/// Smallest build delay
#define SWARMER_FAST_BUILD_DELAY 2 SECONDS
/// Average build delay
#define SWARMER_NORMAL_BUILD_DELAY 5 SECONDS
/// Biggest build delay
#define SWARMER_SLOW_BUILD_DELAY 10 SECONDS

/// How long does it take for a combat swarmer to switch modes
#define SWARMER_MODE_SWITCH_DELAY 1.5 SECONDS

/// How long does it take for a swarmer to teleport through hubs (Note: Rovers take twice less time)
#define SWARMER_TELEPORT_DELAY(swarmer) (is_roverswarmer(swarmer) ? 4 SECONDS : 8 SECONDS)

// === PROJECTILE COOLDOWNS ===
/// Cooldown of default swarmer projectile (used by /mob/living/simple_animal/hostile/swarmer/generalist&combat)
#define SWARMER_NORMAL_PROJECTILE_COOLDOWN 1 SECONDS
/// Cooldown of double swarmer projectile (used by /mob/living/simple_animal/hostile/swarmer/combat)
#define SWARMER_DOUBLE_PROJECTILE_COOLDOWN 2 SECONDS
/// Cooldown of strong swarmer projectile (used by /mob/living/simple_animal/hostile/swarmer/combat)
#define SWARMER_STRONG_PROJECTILE_COOLDOWN 2.5 SECONDS
/// Cooldown of sabotage swarmer projectile (used by /mob/living/simple_animal/hostile/swarmer/combat)
#define SWARMER_SABOTAGE_PROJECTILE_COOLDOWN 3 SECONDS
/// Cooldown of mega swarmer projectile (used by /mob/living/simple_animal/hostile/swarmer/mega)
#define SWARMER_MINIGUN_PROJECTILE_COOLDOWN 1.5 SECONDS

// === STRUCTURE COSTS ===
/// How many metallic resources does it cost to make a barricade
#define SWARMER_BLOCKADE_COST 7
/// How many metallic resources does it cost to make a trap
#define SWARMER_TRAP_COST 3
/// How many metallic resources does it cost to make a transport hub
#define SWARMER_HUB_COST 15
/// How many metallic resources does it cost to make an organic processer
#define SWARMER_PROCESSER_COST 20
/// How many metallic resources does it cost to make an organic analyzer
#define SWARMER_ANALYZER_COST 20
/// How many metallic resources does it cost to make a repair station
#define SWARMER_REPAIR_STATION_COST 10
/// How many metallic resources does it cost to make a resource storage
#define SWARMER_STORAGE_COST 10
/// How many metallic resources does it cost to make a rapid fire turret
#define SWARMER_RAPID_TURRET_COST 20
/// How many metallic resources does it cost to make a sniper turret
#define SWARMER_SNIPER_TURRET_COST 25
/// How many metallic resources does it cost to make an ACP turret
#define SWARMER_ACP_COST 25

// === REPAIR RELATED ===
/// How long does it take for swarmer to repair something (Builder swarmers take twice less time)
#define SWARMER_REPAIR_DELAY(swarmer) (is_builderswarmer(swarmer) ? 0.5 SECONDS : 1 SECONDS)
/// How much swarmer related stuff gets repaired by (Builder swarmer repair twice more)
#define SWARMER_REPAIR_AMOUNT(swarmer) (is_builderswarmer(swarmer) ? 30 : 15)
/// How many metallic resources does it cost for swarmer to repair something
#define SWARMER_REPAIR_COST 0.5

/// How long does it take to enter a repair station
#define SWARMER_REPAIR_STATION_DELAY 2 SECONDS
/// How much a swarmer gets healed by while being in a repair station per tick
#define SWARMER_REPAIR_STATION_HEAL 5

// === ORGANIC PROCESSING ===
/// How long does it take for a swarmer to send anything to a processer
#define SWARMER_SEND_ORGANIC_DELAY 2 SECONDS

/// How many organic items an organic processer can process at a time
#define SWARMER_ORGANIC_ITEM_PROCESS_LIMIT 5
/// How long does it take to process one organic item in organic processer
#define SWARMER_ORGANIC_ITEM_PROCESS_DELAY 10 SECONDS
/// How many organic resources we gain on item processing
#define SWARMER_ORGANIC_ITEM_PROCESS_GAIN (rand(5, 10))

// === ORGANIC ANALYZER ===
/// How long does it take for a swarmer to send anything to an analyzer
#define SWARMER_SEND_ANALYZER_DELAY 4 SECONDS

/// How much time does it take for an organic analyzer to finish (non-carbon mobs take less time)
#define SWARMER_ANALYZE_DELAY(target) (iscarbon(target) ? 45 SECONDS : 15 SECONDS)

/// How many organic resources we get on teleporting if we failed the analyze
#define SWARMER_ANALYZE_TELEPORT_GAIN (rand(10, 20))
/// How many organic resources we get on analyzing a carbon mob
#define SWARMER_ANALYZE_CARBON_GAIN (rand(60, 80))
/// How many organic resources we get on analyzing a hostile mob (/mob/living/simple_animal/hostile)
#define SWARMER_ANALYZE_HOSTILE_GAIN (rand(20, 40))
/// How many organic resources we get on analyzing a living mob (/mob/living)
#define SWARMER_ANALYZE_LIVING_GAIN (rand(10, 20))
/// How many metallic resources we get on analyzing a carbon machine
#define SWARMER_ANALYZE_MACHINE_GAIN (rand(30, 50))
/// How many metallic resources we get on removing a robotic organ on analyzing
#define SWARMER_ANALYZE_ROBOTIC_ORGAN_GAIN 10

/// How many bodyparts or organs we take on machine analyze finish
#define SWARMER_ANALYZE_FINISH_MACHINE_TAKE 2
/// What is the chance to remove a bodypart or organ on non-machine analyze
#define SWARMER_ANALYZE_ORGAN_REMOVE_CHANCE 20

// === RESOURCE STORAGE ===
/// Metal gather modifier increase/decrease on storage init/destroy
#define SWARMER_STORAGE_MODIFIER 0.2
/// Metal gather modifier limit
#define SWARMER_STORAGE_MODIFIER_LIMIT 3

// === TURRETS ===
/// Rapid turret cooldown
#define SWARMER_RAPID_TURRET_COOLDOWN 1.5 SECONDS
/// Sniper turret cooldown
#define SWARMER_SNIPER_TURRET_COOLDOWN 2.5 SECONDS
/// ACP turret cooldown
#define SWARMER_ACP_COOLDOWN 6 SECONDS

// === ACP TURRET SPECIFICS ===
/// ACP turret stamina damage (gets scaled)
#define SWARMER_ACP_DAMAGE 15
/// ACP turret range
#define SWARMER_ACP_RANGE 3
/// ACP turret damage modifier on range decrease (as in less range from target -> more damage multiplier)
#define SWARMER_ACP_RANGE_DAMAGE_MODIFIER 2
/// ACP turret slowed chance (gets scaled)
#define SWARMER_ACP_SLOWED_CHANCE 60
/// ACP turret slowed duration (gets scaled up to 2x)
#define SWARMER_ACP_SLOWED_DURATION 2 SECONDS
/// ACP turret slowed multiplier (doesn't scale)
#define SWARMER_ACP_SLOWED_MULTIPLIER 2
/// ACP turret metabolize disable duration
#define SWARMER_ACP_DISABLE_METABOLIZATION_DURATION 10 SECONDS

// === EMP EFFECTS ===
/// How much swarmers and swarmer structures get damaged on emp
#define SWARMER_EMP_DAMAGE 25
/// For how long do swarmer structures get disabled for on emp_act
#define SWARMER_STRUCTURE_EMP_DURATION 10 SECONDS

// === DAMAGE EFFECTS ===
/// For how long do swarmers disable stamina healing
#define SWARMER_DISABLE_STAMINAREGEN_DURATION 1 SECONDS

// === MEGA SWARMER ===
/// How many projectiles mega-swarmer shoots at once
#define SWARMER_MEGA_RAPID 6
/// Chance of reflecting projectiles for mega-swarmer
#define SWARMER_MEGA_REFLECT_CHANCE 50
/// Range of mega swarmer ACP attack
#define SWARMER_MEGA_ACP_RANGE 5

// === CORE MOVE ===
/// How long does it take to move core
#define SWARMER_CORE_MOVE_DELAY 25 SECONDS
/// How many metallic resources are required to move core
#define SWARMER_CORE_MOVE_COST 100
/// How long does it take for initial forcefield on core spawn to disappear
#define SWARMER_CORE_START_FORCEFIELD_DURATION 15 SECONDS
/// How long does it take for forcefield on core move to disappear
#define SWARMER_CORE_MOVE_FORCEFIELD_DURATION 5 SECONDS

// === SWARMER TRAP ===
/// How much staminadamage does a trap deal
#define SWARMER_TRAP_DAMAGE 40
/// Trap knockdown time
#define SWARMER_TRAP_KNOCKDOWN 4 SECONDS
/// Trap weaken time
#define SWARMER_TRAP_WEAKEN 2 SECONDS

// === SWARMER ACT RETURN VALUES ===
/// Value returned if an atom can be swarmer_act'ed
#define SWARMER_ACT_POSSIBLE (1<<0)
/// Value returned if an atom can't be swarmer_act'ed
#define SWARMER_ACT_IMPOSSIBLE (1<<1)

/// Bitflag combinaton for possible swarmer_act, means we should damage the atom
#define SWARMER_ACT_POSSIBLE_ACTION_DAMAGE (1<<2)
/// Bitflag combination for possible swarmer_act, means we should slowly dismantle the atom
#define SWARMER_ACT_POSSIBLE_ACTION_DISMANTLE (1<<3)
/// Bitflag combination for possible swarmer_act, means we should immediately consume the atom (and gain something)
#define SWARMER_ACT_POSSIBLE_ACTION_CONSUME (1<<4)
/// Bitflag combination for possible swarmer_act, means we should immediately delete the atom
#define SWARMER_ACT_POSSIBLE_ACTION_DESTROY (1<<5)

/// Bitflag combinaton for impossible swarmer_act, means the act was failed since atom is needed for energy
#define SWARMER_ACT_IMPOSSIBLE_REASON_ENERGY (1<<2)
/// Bitflag combinaton for impossible swarmer_act, means the act was failed since atom is important for stuff to live
#define SWARMER_ACT_IMPOSSIBLE_REASON_LIVING (1<<3)
/// Bitflag combinaton for impossible swarmer_act, means the act was failed since atom is important for atmos to work correctly
#define SWARMER_ACT_IMPOSSIBLE_REASON_ATMOS (1<<4)
/// Bitflag combinaton for impossible swarmer_act, means the act was failed since atom is created by swarmers
#define SWARMER_ACT_IMPOSSIBLE_REASON_TEAM (1<<5)
/// Bitflag combination for impossible swarmer_act, means the act's default behaviour is overridden
#define SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE (1<<6)
/// Bitflag combination for impossible swarmer_act, means the act's default behaviour is ignored, and we just attack
#define SWARMER_ACT_IMPOSSIBLE_REASON_DEFAULT (1<<7)
