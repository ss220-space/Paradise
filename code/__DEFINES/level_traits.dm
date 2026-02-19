#define is_level_reachable(z) check_level_trait(z, REACHABLE)

GLOBAL_LIST_EMPTY(station_levels_cache)
// Used to prevent z from being re-evaluated
GLOBAL_VAR(station_level_z_scratch)
// Called a lot, somewhat slow, so has its own cache
#define is_station_level(z_level) \
	( \
		(z_level) && ( \
		( \
			/* The right hand side of this guarantees that we'll have the space to fill later on, while also not failing the condition */ \
			(GLOB.station_levels_cache.len < (GLOB.station_level_z_scratch = (z_level)) && (GLOB.station_levels_cache.len = GLOB.station_level_z_scratch)) \
			|| isnull(GLOB.station_levels_cache[GLOB.station_level_z_scratch]) \
		) \
			? (GLOB.station_levels_cache[GLOB.station_level_z_scratch] = !!check_level_trait(GLOB.station_level_z_scratch, STATION_LEVEL)) \
			: GLOB.station_levels_cache[GLOB.station_level_z_scratch] \
		) \
	)
#define is_station_contact(z) check_level_trait(z, STATION_CONTACT)

#define is_teleport_allowed(z) !check_level_trait(z, BLOCK_TELEPORT)

#define is_admin_level(z) check_level_trait(z, ADMIN_LEVEL)

#define is_reserved_level(z) check_level_trait(z, RESERVED_LEVEL)

#define is_away_level(z) check_level_trait(z, AWAY_LEVEL)

#define is_mining_level(z) check_level_trait(z, ORE_LEVEL)

#define is_ai_allowed(z) check_level_trait(z, AI_OK)

#define level_blocks_magic(z) check_level_trait(z, IMPEDES_MAGIC)

#define level_boosts_signal(z) check_level_trait(z, BOOSTS_SIGNAL)

#define is_explorable_space(z) check_level_trait(z, SPAWN_RUINS)

#define is_taipan(z) check_level_trait(z, TAIPAN)

#define is_multi_z_level(z) (SSmapping.level_trait(z, ZTRAIT_UP) || SSmapping.level_trait(z, ZTRAIT_DOWN))
