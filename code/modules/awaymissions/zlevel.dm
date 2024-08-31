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
	if(!GLOB.potentialRandomZlevels || !GLOB.potentialRandomZlevels.len)
		log_startup_progress_global("Mapping", "No away missions found.")
		return
	var/watch = start_watch()
	log_startup_progress_global("Mapping", "Loading away mission...")
	var/map = pick(GLOB.potentialRandomZlevels)
	var/file = wrap_file(map)
	var/bounds = GLOB.maploader.load_map(file, 1, 1, 1, shouldCropMap = FALSE, measureOnly = TRUE)
	var/total_z = bounds[MAP_MAXZ] - bounds[MAP_MINZ] + 1
	var/map_z_level
	if(total_z == 1)
		map_z_level = GLOB.space_manager.add_new_zlevel(AWAY_MISSION, linkage = UNAFFECTED, traits = list(AWAY_LEVEL, BLOCK_TELEPORT, HAS_WEATHER))
	else
		map_z_level = GLOB.space_manager.add_new_zlevel(AWAY_MISSION, linkage = UNAFFECTED, traits = list(AWAY_LEVEL, BLOCK_TELEPORT, HAS_WEATHER, ZTRAIT_UP))
		for(var/i in 2 to total_z-1)
			GLOB.space_manager.add_new_zlevel(AWAY_MISSION + "([i])", linkage = UNAFFECTED, traits = list(AWAY_LEVEL, BLOCK_TELEPORT, HAS_WEATHER, ZTRAIT_UP, ZTRAIT_DOWN))
		GLOB.space_manager.add_new_zlevel(AWAY_MISSION  + "([total_z])", linkage = UNAFFECTED, traits = list(AWAY_LEVEL, BLOCK_TELEPORT, HAS_WEATHER, ZTRAIT_DOWN))

	GLOB.maploader.load_map(file, z_offset = map_z_level)
	log_world("  Away mission loaded: [map]")

	for(var/obj/effect/landmark/awaystart/thing in GLOB.landmarks_list)
		GLOB.awaydestinations.Add(thing)

	log_startup_progress_global("Mapping", "Away mission loaded in [stop_watch(watch)]s.")


/proc/generateMapList(filename)
	var/list/potentialMaps = list()
	var/list/Lines = file2list(filename)

	if(!Lines.len)
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


/datum/map_template/ruin/proc/try_to_place(z, allowed_areas)
	var/sanity = PLACEMENT_TRIES
	while(sanity > 0)
		sanity--
		var/width_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(width / 2)
		var/height_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(height / 2)
		var/turf/central_turf = locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z)
		var/valid = TRUE

		for(var/turf/check in get_affected_turfs(central_turf,1))
			var/area/new_area = get_area(check)
			if(!(istype(new_area, allowed_areas)) || check.flags & NO_RUINS)
				valid = FALSE
				break

		if(!valid)
			continue

		log_world("Ruin \"[name]\" placed at ([central_turf.x], [central_turf.y], [central_turf.z])")

		for(var/i in get_affected_turfs(central_turf, 1))
			var/turf/T = i
			for(var/obj/structure/spawner/nest in T)
				qdel(nest)
			for(var/mob/living/simple_animal/monster in T)
				qdel(monster)
			for(var/obj/structure/flora/ash/plant in T)
				qdel(plant)

		load(central_turf,centered = TRUE)
		loaded++

		for(var/turf/T in get_affected_turfs(central_turf, 1))
			T.flags |= NO_RUINS

		new /obj/effect/landmark/ruin(central_turf, src)
		return TRUE
	return FALSE
