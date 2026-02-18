/proc/milla_init_z(z)
	return RUSTLIB_CALL(milla_initialize, z)

/proc/set_tile_atmos(turf/T, airtight_north, airtight_east, airtight_south, airtight_west, atmos_mode, environment_id, oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, hydrogen, water_vapor, temperature, innate_heat_capacity, hotspot_temperature, hotspot_volume)
	return RUSTLIB_CALL(milla_set_tile, T, airtight_north, airtight_east, airtight_south, airtight_west, atmos_mode, environment_id, oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, hydrogen, water_vapor, temperature, innate_heat_capacity, hotspot_temperature, hotspot_volume)

#define get_tile_atmos(T, L) RUSTLIB_CALL(milla_get_tile, T, L)

#define spawn_milla_tick_thread(...) RUSTLIB_CALL(milla_spawn_tick_thread)

#define get_milla_tick_time(...) RUSTLIB_CALL(milla_get_tick_time)

#define get_interesting_atmos_tiles(...) RUSTLIB_CALL(milla_get_interesting_tiles)


#define get_tracked_pressure_tiles(...) RUSTLIB_CALL(milla_get_tracked_pressure_tiles)

/proc/reduce_superconductivity(turf/T, list/superconductivity)
	var/north = superconductivity[1]
	var/east = superconductivity[2]
	var/south = superconductivity[3]
	var/west = superconductivity[4]

	return RUSTLIB_CALL(milla_reduce_superconductivity, T, north, east, south, west)

/proc/reset_superconductivity(turf/T)
	return RUSTLIB_CALL(milla_reset_superconductivity, T)

/proc/set_tile_airtight(turf/T, list/airtight)
	var/north = airtight[1]
	var/east = airtight[2]
	var/south = airtight[3]
	var/west = airtight[4]

	return RUSTLIB_CALL(milla_set_tile_airtight, T, north, east, south, west)

/proc/create_hotspot(turf/T, hotspot_temperature, hotspot_volume)
	return RUSTLIB_CALL(milla_create_hotspot, T, hotspot_temperature, hotspot_volume)

/proc/track_pressure_tiles(atom/A, radius)
	var/turf/T = get_turf(A)
	if(istype(T))
		return RUSTLIB_CALL(milla_track_pressure_tiles, T, radius)

#define get_random_interesting_tile(...) RUSTLIB_CALL(milla_get_random_interesting_tile)

/proc/create_environment(oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, hydrogen, water_vapor, temperature)
	return RUSTLIB_CALL(milla_create_environment, oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, hydrogen, water_vapor, temperature)

/proc/milla_load_turfs(turf/low_corner, turf/high_corner)
	ASSERT(istype(low_corner))
	ASSERT(istype(high_corner))
	return RUSTLIB_CALL(milla_load_turfs, "milla_data", low_corner, high_corner)

/proc/set_zlevel_freeze(z, bool_frozen)
	return RUSTLIB_CALL(milla_set_zlevel_frozen, z, bool_frozen)

#define milla_reset(...) RUSTLIB_CALL(milla_reset)
