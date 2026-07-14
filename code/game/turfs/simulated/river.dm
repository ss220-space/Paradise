#define RIVER_MAX_X 200
#define RIVER_MAX_Y 200

#define RIVER_MIN_X 50
#define RIVER_MIN_Y 50

/obj/effect/landmark/river_waypoint
	name = "river waypoint"
	/// Whether the turf of this landmark has already been linked to others during river generation.
	var/connected = FALSE

/// A straightforward system for making "rivers", paths made up of a specific
/// turf type that are generated in a random path on a z-level.
/datum/river_spawner
	/// The z-level to generate the river on. There is theoretically nothing stopping
	/// this from being used across z-levels, but we're keeping things simple.
	var/target_z
	/// The initial probability that a river tile will spread to adjacent tiles.
	var/spread_prob
	/// The amount reduced from spread_prob on every spread iteration to cause falloff.
	var/spread_prob_loss
	/// The base type that makes up the river.
	var/river_turf_type = /turf/simulated/floor/lava/mapping_lava
	/// The area that the spawner is allowed to spread or detour to.
	var/whitelist_area_type = /area/lavaland/surface/outdoors
	/// The type that the spawner is allowed to spread or detour to.
	var/whitelist_turf_type = /turf/simulated/mineral
	/// The turf used when a spread of the tile stops.
	var/shoreline_turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface

/datum/river_spawner/New(target_z_, spread_prob_ = 25, spread_prob_loss_ = 11)
	target_z = target_z_
	spread_prob = spread_prob_
	spread_prob_loss = spread_prob_loss_

/// Generate a river between the bounds specified by (`min_x`, `min_y`) and
/// (`max_x`, `max_y`).
///
/// `nodes` is the number of unique points in those bounds the river will
/// connect to. Note that `nodes` says little about the resultant size of the
/// river due to its ability to detour far away from the direct path between them.

/datum/river_spawner/proc/generate(nodes = 4, min_x = RIVER_MIN_X, min_y = RIVER_MIN_Y, max_x = RIVER_MAX_X, max_y = RIVER_MAX_Y)
	var/list/river_nodes = list()
	var/num_spawned = 0
	var/list/possible_locs = block(min_x, min_y, target_z, max_x, max_y, target_z)
	while(num_spawned < nodes && length(possible_locs))
		var/turf/turf = pick(possible_locs)
		var/area/area = get_area(turf)
		if(!istype(area, whitelist_area_type) || (turf.turf_flags & NO_LAVA_GEN))
			possible_locs -= turf
		else
			river_nodes += new /obj/effect/landmark/river_waypoint(turf)
			num_spawned++

	//make some randomly pathing rivers
	for(var/area in river_nodes)
		var/obj/effect/landmark/river_waypoint/river_waypoint = area
		if(river_waypoint.z != target_z || river_waypoint.connected)
			continue
		river_waypoint.connected = TRUE
		var/turf/cur_turf = get_turf(river_waypoint)
		cur_turf.ChangeTurf(river_turf_type, after_flags = CHANGETURF_IGNORE_AIR)
		var/turf/target_turf = get_turf(pick(river_nodes - river_waypoint))
		if(!target_turf)
			break
		var/detouring = 0
		var/cur_dir = get_dir(cur_turf, target_turf)
		while(cur_turf != target_turf)
			if(detouring) //randomly snake around a bit
				if(prob(20))
					detouring = 0
					cur_dir = get_dir(cur_turf, target_turf)
			else if(prob(20))
				detouring = 1
				if(prob(50))
					cur_dir = turn(cur_dir, 45)
				else
					cur_dir = turn(cur_dir, -45)
			else
				cur_dir = get_dir(cur_turf, target_turf)

			cur_turf = get_step(cur_turf, cur_dir)
			if(cur_turf == null) //This might be the fuck up. Kill the loop if this happens
				message_admins("Encountered a null turf in river loop.")
				break
			var/area/new_area = get_area(cur_turf)
			if(!istype(new_area, whitelist_area_type) || (cur_turf.turf_flags & NO_LAVA_GEN)) //Rivers will skip ruins
				detouring = 0
				cur_dir = get_dir(cur_turf, target_turf)
				cur_turf = get_step(cur_turf, cur_dir)
				continue
			else
				var/turf/river_turf = cur_turf.ChangeTurf(river_turf_type, after_flags = CHANGETURF_IGNORE_AIR)
				if(prob(1))
					new /obj/effect/spawner/bridge(river_turf)
				spread_turf(river_turf, spread_prob, spread_prob_loss, whitelist_area_type)

	for(var/WP in river_nodes)
		qdel(WP)

/datum/river_spawner/proc/spread_turf(turf/start_turf, probability = 30, prob_loss = 25, whitelisted_area)
	if(probability <= 0)
		return
	var/list/cardinal_turfs = list()
	var/list/diagonal_turfs = list()
	for(var/F in RANGE_TURFS(1, start_turf) - start_turf)
		var/turf/turf = F
		var/area/new_area = get_area(turf)
		if(!turf || (turf.density && !istype(turf, whitelist_turf_type)) || istype(turf, /turf/simulated/floor/indestructible) || istype(turf, /turf/simulated/wall/indestructible) || (whitelisted_area && !istype(new_area, whitelisted_area)) || (turf.turf_flags & NO_LAVA_GEN))
			continue

		if(get_dir(start_turf, F) in GLOB.cardinal)
			cardinal_turfs += F
		else
			diagonal_turfs += F

	for(var/F in cardinal_turfs) //cardinal turfs are always changed but don't always spread
		var/turf/turf = F
		if(!istype(turf, start_turf.type) && turf.ChangeTurf(start_turf.type, after_flags = CHANGETURF_IGNORE_AIR) && prob(probability))
			spread_turf(turf, probability - prob_loss, prob_loss, whitelisted_area)
			if(prob(1))
				new /obj/effect/spawner/bridge(turf)

	for(var/F in diagonal_turfs) //diagonal turfs only sometimes change, but will always spread if changed
		var/turf/turf = F
		if(!istype(turf, shoreline_turf_type) && prob(probability) && turf.ChangeTurf(start_turf.type, after_flags = CHANGETURF_IGNORE_AIR))
			spread_turf(turf, probability - prob_loss, prob_loss, whitelisted_area)
		else if(istype(turf, whitelist_turf_type) && !istype(turf, start_turf.type))
			turf.ChangeTurf(shoreline_turf_type, after_flags = CHANGETURF_IGNORE_AIR)
			if(prob(1))
				new /obj/effect/spawner/bridge(turf)

#undef RIVER_MAX_X
#undef RIVER_MAX_Y

#undef RIVER_MIN_X
#undef RIVER_MIN_Y
