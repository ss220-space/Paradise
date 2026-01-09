GLOBAL_LIST_INIT(potentialRandomZlevels, generateMapList(filename = "config/away_mission_config.txt"))
/proc/empty_rect(low_x,low_y, hi_x,hi_y, z)
	var/timer = start_watch()
	log_debug("Emptying region: ([low_x], [low_y]) to ([hi_x], [hi_y]) on z '[z]'")
	empty_region(block(low_x, low_y, z, hi_x, hi_y, z))
	log_debug("Took [stop_watch(timer)]s")

/proc/empty_region(list/turfs)
	for(var/thing in turfs)
		var/turf/T = thing
		for(var/otherthing in T)
			qdel(otherthing)
		T.ChangeTurf(T.baseturf)

/proc/loadAwayLevel()
	if((!GLOB.potentialRandomZlevels || !length(GLOB.potentialRandomZlevels)) && !CONFIG_GET(string/override_away_mission))
		log_startup_progress_global("Mapping", "No away missions found.")
		return
	var/watch = start_watch()
	log_startup_progress_global("Mapping", "Loading away mission...")
	var/map = !CONFIG_GET(string/override_away_mission) ? pick(GLOB.potentialRandomZlevels) : CONFIG_GET(string/override_away_mission)
	if(CONFIG_GET(string/override_away_mission))
		log_startup_progress_global("Mapping", "Away mission overridden by configuration to [CONFIG_GET(string/override_away_mission)].")

	var/file = wrap_file(map)
	var/bounds = GLOB.maploader.load_map(file, 1, 1, 1, shouldCropMap = FALSE, measureOnly = TRUE)
	var/total_z = bounds[MAP_MAXZ] - bounds[MAP_MINZ] + 1
	var/map_z_level
	var/list/map_z_levels = list()
	if(total_z == 1)
		map_z_level = GLOB.space_manager.add_new_zlevel(AWAY_MISSION, linkage = UNAFFECTED, traits = list(AWAY_LEVEL, BLOCK_TELEPORT))
		map_z_levels += map_z_level
	else
		map_z_level = GLOB.space_manager.add_new_zlevel(AWAY_MISSION, linkage = UNAFFECTED, traits = list(AWAY_LEVEL, BLOCK_TELEPORT, ZTRAIT_UP))
		map_z_levels += map_z_level
		for(var/i in 2 to total_z-1)
			map_z_levels += GLOB.space_manager.add_new_zlevel(AWAY_MISSION + "([i])", linkage = UNAFFECTED, traits = list(AWAY_LEVEL, BLOCK_TELEPORT, ZTRAIT_UP, ZTRAIT_DOWN))
		map_z_levels += GLOB.space_manager.add_new_zlevel(AWAY_MISSION  + "([total_z])", linkage = UNAFFECTED, traits = list(AWAY_LEVEL, BLOCK_TELEPORT, ZTRAIT_DOWN))

	GLOB.maploader.load_map(file, z_offset = map_z_level)
	log_world("  Away mission loaded: [map]")

	for(var/level in map_z_levels)
		smooth_zlevel(level)
	log_startup_progress_global("Mapping", "Away mission loaded in [stop_watch(watch)]s.")

/proc/generateMapList(filename)
	var/list/potentialMaps = list()
	var/list/Lines = world.file2list(filename)

	if(!length(Lines))
		return
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null

		if(pos)
			name = lowertext(copytext(t, 1, pos))

		else
			name = lowertext(t)

		if(!name)
			continue

		potentialMaps.Add(t)

	return potentialMaps


/datum/milla_safe_must_sleep/late_setup_level

// Ensures that atmos and environment are set up.
/datum/milla_safe_must_sleep/late_setup_level/on_run(turf/bot_left, turf/top_right, smoothTurfs)
	var/subtimer = start_watch()
	log_debug("Setting up atmos")
	/* setup_allturfs is superfluous during server initialization because
	 * air subsystem will call subsequently call setup_allturfs with _every_
	 * turf in the world */
	if(SSair && SSair.initialized)
		SSair.setup_turfs(bot_left, top_right)
	log_debug("Unfreezing atmos.")
	set_zlevel_freeze(bot_left.z, FALSE)
	log_debug("\tTook [stop_watch(subtimer)]s")

/datum/milla_safe/freeze_z_level
	var/done = FALSE

// Ensures that atmos is frozen before loading
/datum/milla_safe/freeze_z_level/on_run(z)
	log_debug("Freezing atmos.")
	set_zlevel_freeze(z, TRUE)
	done = TRUE

