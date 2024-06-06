SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = INIT_ORDER_MAPPING // 7
	flags = SS_NO_FIRE
	ss_id = "mapping"
	/// What map datum are we using
	var/datum/map/map_datum
	/// What map will be used next round
	var/datum/map/next_map
	/// Waht map to fallback
	var/datum/map/fallback_map = new /datum/map/delta
	///What do we have as the lavaland theme today?
	var/datum/lavaland_theme/lavaland_theme
	///List of areas that exist on the station this shift
	var/list/existing_station_areas
	///list of lists, inner lists are of the form: list("up or down link direction" = TRUE)
	var/list/multiz_levels = list()

	var/list/areas_in_z = list()
	/// List of z level (as number) -> plane offset of that z level
	/// Used to maintain the plane cube
	var/list/z_level_to_plane_offset = list()
	/// List of z level (as number) -> list of all z levels vertically connected to ours
	/// Useful for fast grouping lookups and such
	var/list/z_level_to_stack = list()
	/// List of z level (as number) -> The lowest plane offset in that z stack
	var/list/z_level_to_lowest_plane_offset = list()
	// This pair allows for easy conversion between an offset plane, and its true representation
	// Both are in the form "input plane" -> output plane(s)
	/// Assoc list of string plane values to their true, non offset representation
	var/list/plane_offset_to_true
	/// Assoc list of true string plane values to a list of all potential offset planess
	var/list/true_to_offset_planes
	/// Assoc list of string plane to the plane's offset value
	var/list/plane_to_offset
	/// List of planes that do not allow for offsetting
	var/list/plane_offset_blacklist
	/// List of render targets that do not allow for offsetting
	var/list/render_offset_blacklist
	/// List of plane masters that are of critical priority
	var/list/critical_planes
	/// The largest plane offset we've generated so far
	var/max_plane_offset = 0


// This has to be here because world/New() uses [station_name()], which looks this datum up
/datum/controller/subsystem/mapping/PreInit()
	. = ..()
	if(map_datum) // Dont do this again if we are recovering
		return
	if(fexists("data/next_map.txt"))
		var/list/lines = file2list("data/next_map.txt")
		// Check its valid
		try
			map_datum = text2path(lines[1])
			map_datum = new map_datum
		catch
			map_datum = fallback_map // Assume delta if non-existent
		fdel("data/next_map.txt") // Remove to avoid the same map existing forever
		return
	map_datum = fallback_map // Assume delta if non-existent

/datum/controller/subsystem/mapping/Shutdown()
	if(next_map) // Save map for next round
		var/F = file("data/next_map.txt")
		F << next_map.type

/datum/controller/subsystem/mapping/Initialize()
	setupPlanes()

	var/datum/lavaland_theme/lavaland_theme_type = pick(subtypesof(/datum/lavaland_theme))
	ASSERT(lavaland_theme_type)
	lavaland_theme = new lavaland_theme_type
	log_startup_progress("We're in the mood for [initial(lavaland_theme.name)] today...") //We load this first. In the event some nerd ever makes a surface map, and we don't have it in lavaland in the event lavaland is disabled.
	// Load all Z level templates
	preloadTemplates()
	// Load the station
	loadStation()

	if(!CONFIG_GET(flag/disable_lavaland))
		loadLavaland()
	if(!CONFIG_GET(flag/disable_taipan))
		loadTaipan()
	// Pick a random away mission.
	if(!CONFIG_GET(flag/disable_away_missions))
		loadAwayLevel()
	// Seed space ruins
	if(!CONFIG_GET(flag/disable_space_ruins))
		handleRuins()

	// Makes a blank space level for the sake of randomness
	GLOB.space_manager.add_new_zlevel(EMPTY_AREA, linkage = CROSSLINKED, traits = list(REACHABLE))


	// Setup the Z-level linkage
	GLOB.space_manager.do_transition_setup()
	generate_z_level_linkages(GLOB.space_manager.z_list)

	if(!CONFIG_GET(flag/disable_lavaland))
		// Spawn Lavaland ruins and rivers.
		log_startup_progress("Populating lavaland...")
		var/lavaland_setup_timer = start_watch()
		seedRuins(list(level_name_to_num(MINING)), CONFIG_GET(number/lavaland_budget), /area/lavaland/surface/outdoors/unexplored, GLOB.lava_ruins_templates)
		// Run map generation after ruin generation to prevent issues
		run_map_terrain_generation()
		if(lavaland_theme)
			lavaland_theme.setup()
		// now that the terrain is generated, including rivers, we can safely populate it with objects and mobs
		run_map_terrain_population()
		var/time_spent = stop_watch(lavaland_setup_timer)
		log_startup_progress("Successfully populated lavaland in [time_spent]s.")
		if(time_spent >= 10)
			log_startup_progress("!!!ERROR!!! Lavaland took FAR too long to generate at [time_spent] seconds. Notify maintainers immediately! !!!ERROR!!!") //In 3 testing cases so far, I have had it take far too long to generate. I am 99% sure I have fixed this issue, but never hurts to be sure
			WARNING("!!!ERROR!!! Lavaland took FAR too long to generate at [time_spent] seconds. Notify maintainers immediately! !!!ERROR!!!")
			var/loud_annoying_alarm = sound('sound/machines/engine_alert1.ogg')
			for(var/get_player_attention in GLOB.player_list)
				SEND_SOUND(get_player_attention, loud_annoying_alarm)
	else
		log_startup_progress("Skipping lavaland ruins...")

	// Now we make a list of areas for teleport locs
	// TOOD: Make these locs into lists on the SS itself, not globs

	var/list/all_areas = list()
	for(var/area/areas in world)
		all_areas += areas

	for(var/area/AR as anything in all_areas)
		if(AR.no_teleportlocs)
			continue
		if(GLOB.teleportlocs[AR.name])
			continue
		var/list/pickable_turfs = list()
		for(var/turf/turfs in AR)
			pickable_turfs += turfs
			break
		var/turf/picked = safepick(pickable_turfs)
		if(picked && is_station_level(picked.z))
			GLOB.teleportlocs[AR.name] = AR

	GLOB.teleportlocs = sortAssoc(GLOB.teleportlocs)

	for(var/area/AR as anything in all_areas)
		if(GLOB.ghostteleportlocs[AR.name])
			continue
		var/list/pickable_turfs = list()
		for(var/turf/turfs in AR)
			pickable_turfs += turfs
			break
		if(length(pickable_turfs))
			GLOB.ghostteleportlocs[AR.name] = AR

	GLOB.ghostteleportlocs = sortAssoc(GLOB.ghostteleportlocs)

	// Now we make a list of areas that exist on the station. Good for if you don't want to select areas that exist for one station but not others. Directly references
	existing_station_areas = list()
	for(var/area/AR as anything in all_areas)
		var/list/pickable_turfs = list()
		for(var/turf/turfs in AR)
			pickable_turfs += turfs
			break
		var/turf/picked = safepick(pickable_turfs)
		if(picked && is_station_level(picked.z))
			existing_station_areas += AR

	// World name
	if(config && CONFIG_GET(string/servername))
		world.name = "[CONFIG_GET(string/servername)] — [station_name()]"
	else
		world.name = station_name()

/datum/controller/subsystem/mapping/proc/setupPlanes()
	plane_offset_to_true = list()
	true_to_offset_planes = list()
	plane_to_offset = list()
	// VERY special cases for FLOAT_PLANE, so it will be treated as expected by plane management logic
	// Sorry :(
	plane_offset_to_true["[FLOAT_PLANE]"] = FLOAT_PLANE
	true_to_offset_planes["[FLOAT_PLANE]"] = list(FLOAT_PLANE)
	plane_to_offset["[FLOAT_PLANE]"] = 0
	plane_offset_blacklist = list()
	render_offset_blacklist = list()
	critical_planes = list()
	create_plane_offsets(0, 0)

// Do not confuse with seedRuins()
/datum/controller/subsystem/mapping/proc/handleRuins()
	// load in extra levels of space ruins
	var/load_zlevels_timer = start_watch()
	log_startup_progress("Creating random space levels...")
	var/num_extra_space = map_datum?.space_ruins_levels ? map_datum.space_ruins_levels : SPACE_RUINS_NUMBER
	for(var/i in 1 to num_extra_space)
		GLOB.space_manager.add_new_zlevel("Ruin Area #[i]", linkage = CROSSLINKED, traits = list(REACHABLE, SPAWN_RUINS))
	log_startup_progress("Loaded random space levels in [stop_watch(load_zlevels_timer)]s.")

	// Now spawn ruins, random budget between 20 and 30 for all zlevels combined.
	// While this may seem like a high number, the amount of ruin Z levels can be anywhere between 3 and 7.
	// Note that this budget is not split evenly accross all zlevels
	log_startup_progress("Seeding ruins...")
	var/seed_ruins_timer = start_watch()
	seedRuins(levels_by_trait(SPAWN_RUINS), rand(20, 30), /area/space, GLOB.space_ruins_templates)
	log_startup_progress("Successfully seeded ruins in [stop_watch(seed_ruins_timer)]s.")


/datum/controller/subsystem/mapping/proc/loadStation()
	if(CONFIG_GET(string/default_map) && !CONFIG_GET(string/override_map) && map_datum == fallback_map)
		var/map_datum_path = text2path(CONFIG_GET(string/default_map))
		if(map_datum_path)
			map_datum = new map_datum_path

	if(CONFIG_GET(string/override_map))
		log_startup_progress("Station map overridden by configuration to [CONFIG_GET(string/override_map)].")
		var/map_datum_path = text2path(CONFIG_GET(string/override_map))
		if(map_datum_path)
			map_datum = new map_datum_path
		else
			to_chat(world, "<span class='danger'>ERROR: The map datum specified to load is invalid. Falling back to... delta probably?</span>")

	ASSERT(map_datum.map_path)
	if(!fexists(map_datum.map_path))
		// Make a VERY OBVIOUS error
		to_chat(world, "<span class='userdanger'>ERROR: The path specified for the map to load is invalid. No station has been loaded!</span>")
		return

	var/watch = start_watch()
	log_startup_progress("Loading [map_datum.station_name]...")

	var/map_z_level
	if(map_datum.traits && map_datum.traits?.len && islist(map_datum.traits[1])) // we work with list of lists
		map_z_level = GLOB.space_manager.add_new_zlevel(MAIN_STATION, linkage = map_datum.linkage, traits = map_datum.traits[1])
		if(map_datum.traits.len > MULTIZ_WARN)
			message_admins("Loading station with over [MULTIZ_WARN] levels(It has [map_datum.traits.len]!!). May cause some issues with space levels and/or perfomance on server.")

		for(var/i in 2 to map_datum.traits.len)
			GLOB.space_manager.add_new_zlevel(MAIN_STATION + "([i])", linkage = map_datum.linkage, traits = map_datum.traits[i])
	else
		var/s_traits = map_datum.traits ? map_datum.traits : DEFAULT_STATION_TRATS
		map_z_level = GLOB.space_manager.add_new_zlevel(MAIN_STATION, linkage = map_datum.linkage, traits = s_traits)
	GLOB.maploader.load_map(wrap_file(map_datum.map_path), z_offset = map_z_level)
	log_startup_progress("Loaded [map_datum.station_name] in [stop_watch(watch)]s")

	// Save station name in the DB
	if(!SSdbcore.IsConnected())
		return
	var/datum/db_query/query_set_map = SSdbcore.NewQuery(
		"UPDATE [format_table_name("round")] SET start_datetime=NOW(), map_name=:mapname, station_name=:stationname WHERE id=:round_id",
		list("mapname" = map_datum.name, "stationname" = map_datum.station_name, "round_id" = GLOB.round_id)
	)
	query_set_map.Execute(async = FALSE) // This happens during a time of intense server lag, so should be non-async
	qdel(query_set_map)

/datum/controller/subsystem/mapping/proc/loadLavaland()
	var/watch = start_watch()
	log_startup_progress("Loading Lavaland...")
	var/trait_list = list(ORE_LEVEL, REACHABLE, STATION_CONTACT, HAS_WEATHER, AI_OK, ZTRAIT_BASETURF = /turf/simulated/floor/plating/lava/smooth/mapping_lava)
	var/lavaland_z_level = GLOB.space_manager.add_new_zlevel(MINING, linkage = UNAFFECTED, traits = trait_list)
	GLOB.maploader.load_map(file(map_datum.lavaland_path), z_offset = lavaland_z_level)
	log_startup_progress("Loaded Lavaland in [stop_watch(watch)]s")


/datum/controller/subsystem/mapping/proc/loadTaipan()
	var/watch = start_watch()
	log_startup_progress("Loading Taipan...")
	var/taipan_z_level = GLOB.space_manager.add_new_zlevel(RAMSS_TAIPAN, linkage = CROSSLINKED, traits = list(REACHABLE, TAIPAN))
	GLOB.maploader.load_map(file("_maps/map_files/generic/syndicatebase.dmm"), z_offset = taipan_z_level)
	log_startup_progress("Loaded Taipan in [stop_watch(watch)]s")

/datum/controller/subsystem/mapping/proc/seedRuins(list/z_levels = null, budget = 0, whitelist = /area/space, list/potentialRuins)
	if(!z_levels || !z_levels.len)
		WARNING("No Z levels provided - Not generating ruins")
		return

	for(var/zl in z_levels)
		var/turf/T = locate(1, 1, zl)
		if(!T)
			WARNING("Z level [zl] does not exist - Not generating ruins")
			return

	var/list/ruins = potentialRuins.Copy()

	var/list/forced_ruins = list()		//These go first on the z level associated (same random one by default)
	var/list/big_ruins = list()	// Large ruins that require a separate z level
	var/list/ruins_availible = list()	//we can try these in the current pass
	var/list/picked_ruins = list()

	//Set up the starting ruin list
	for(var/key in ruins)
		var/datum/map_template/ruin/R = ruins[key]
		if(R.cost > budget) //Why would you do that
			continue
		if(R.height >= MAX_RUIN_SIZE_VALUE || R.width >= MAX_RUIN_SIZE_VALUE)
			big_ruins[R] = -1
		if(R.always_place)
			forced_ruins[R] = -1
		if(R.unpickable)
			continue
		ruins_availible[R] = R.placement_weight

	while(budget > 0 && (length(ruins_availible) || length(forced_ruins)))
		var/datum/map_template/ruin/current_pick

		if(length(forced_ruins)) //We have something we need to load right now, so just pick it
			for(var/ruin in forced_ruins)
				current_pick = ruin
				forced_ruins -= ruin
				break
		else //Otherwise just pick random one
			current_pick = pickweight(ruins_availible)

		budget -= current_pick.cost
		if(!current_pick.allow_duplicates)
			for(var/datum/map_template/ruin/R as anything in ruins_availible)
				if(R.id == current_pick.id)
					ruins_availible -= R

		if(current_pick.never_spawn_with)
			for(var/blacklisted_type in current_pick.never_spawn_with)
				for(var/possible_exclusion in ruins_availible)
					if(istype(possible_exclusion,blacklisted_type))
						ruins_availible -= possible_exclusion

		//Update the availible list
		for(var/datum/map_template/ruin/R as anything in ruins_availible)
			if(R.cost > budget)
				ruins_availible -= R

		if(current_pick in big_ruins)
			picked_ruins.Insert(1, current_pick)
		else
			picked_ruins.Add(current_pick)

	for(var/datum/map_template/ruin/current_pick as anything in picked_ruins)
		var/failed_to_place = TRUE
		var/z_placed = 0

		if(current_pick in big_ruins)
			z_placed = pick(z_levels)
			if(current_pick.try_to_place(z_placed, whitelist))
				failed_to_place = FALSE
				z_levels -= z_placed //If there is a big ruin, there is no place for small ones here.
		else
			var/placement_tries = PLACEMENT_TRIES
			while(placement_tries > 0)
				placement_tries--
				z_placed = pick(z_levels)
				if(!current_pick.try_to_place(z_placed, whitelist))
					continue
				else
					failed_to_place = FALSE
					break

		if(failed_to_place)
			log_world("Failed to place [current_pick.name] ruin.")

	log_world("Ruin loader finished with [budget] left to spend.")

/// Generate the turfs of the area
/datum/controller/subsystem/mapping/proc/run_map_terrain_generation()
	for(var/area/A in world)
		A.RunTerrainGeneration()

/// Populate the turfs of the area
/datum/controller/subsystem/mapping/proc/run_map_terrain_population()
	for(var/area/A in world)
		A.RunTerrainPopulation()

/datum/controller/subsystem/mapping/proc/generate_z_level_linkages(z_list)
	for(var/z_level in 1 to length(z_list))
		generate_linkages_for_z_level(z_level)

/datum/controller/subsystem/mapping/proc/generate_linkages_for_z_level(z_level)
	if(!isnum(z_level) || z_level <= 0)
		return FALSE

	if(multiz_levels.len < z_level)
		multiz_levels.len = z_level

	var/z_above = check_level_trait(z_level, ZTRAIT_UP)
	var/z_below = check_level_trait(z_level, ZTRAIT_DOWN)
	if(!(z_above == TRUE || z_above == FALSE || z_above == null) || !(z_below == TRUE || z_below == FALSE || z_below == null))
		stack_trace("Warning, numeric mapping offsets are deprecated. Instead, mark z level connections by setting UP/DOWN to true if the connection is allowed")
	multiz_levels[z_level] = new /list(LARGEST_Z_LEVEL_INDEX)
	multiz_levels[z_level][Z_LEVEL_UP] = !!z_above
	multiz_levels[z_level][Z_LEVEL_DOWN] = !!z_below


/// Takes a z level datum, and tells the mapping subsystem to manage it
/// Also handles things like plane offset generation, and other things that happen on a z level to z level basis
/datum/controller/subsystem/mapping/proc/manage_z_level(datum/space_level/new_z)
	// Build our lookup lists
	var/z_value = new_z.zpos
	log_debug(z_value)
	// We are guarenteed that we'll always grow bottom up
	// Suck it jannies
	z_level_to_plane_offset.len += 1
	z_level_to_lowest_plane_offset.len += 1
	z_level_to_stack.len += 1
	// Bare minimum we have ourselves
	z_level_to_stack[z_value] = list(z_value)
	// 0's the default value, we'll update it later if required
	z_level_to_plane_offset[z_value] = 0
	z_level_to_lowest_plane_offset[z_value] = 0

	// Now we check if this plane is offset or not
	var/below_offset = check_level_trait(z_value, ZTRAIT_DOWN)
	if(below_offset)
		update_plane_tracking(new_z)

	// And finally, misc global generation

	// We'll have to update this if offsets change, because we load lowest z to highest z
	generate_lighting_appearance_by_z(z_value)

/datum/controller/subsystem/mapping/proc/update_plane_tracking(datum/space_level/update_with)
	// We're essentially going to walk down the stack of connected z levels, and set their plane offset as we go
	var/plane_offset = 0
	var/datum/space_level/current_z = update_with
	var/list/datum/space_level/levels_checked = list()

	var/list/z_stack = list()
	while(TRUE)
		var/z_level = current_z.zpos
		z_stack += z_level
		z_level_to_plane_offset[z_level] = plane_offset
		levels_checked += current_z
		if(!check_level_trait(z_level, ZTRAIT_DOWN)) // If there's nothing below, stop looking
			break
		// Otherwise, down down down we go
		current_z = GLOB.space_manager.get_zlev(z_level - 1)
		plane_offset += 1

	/// Updates the lowest offset value
	for(var/datum/space_level/level_to_update in levels_checked)
		z_level_to_lowest_plane_offset[level_to_update.zpos] = plane_offset
		z_level_to_stack[level_to_update.zpos] = z_stack

	// This can be affected by offsets, so we need to update it
	// PAIN
	for(var/i in 1 to length(GLOB.space_manager.z_list))
		generate_lighting_appearance_by_z(i)

	var/old_max = max_plane_offset
	max_plane_offset = max(max_plane_offset, plane_offset)
	if(max_plane_offset == old_max)
		return

	generate_offset_lists(old_max + 1, max_plane_offset)
	SEND_SIGNAL(src, COMSIG_PLANE_OFFSET_INCREASE, old_max, max_plane_offset)
	// Sanity check
	if(max_plane_offset > MAX_EXPECTED_Z_DEPTH)
		stack_trace("We've loaded a map deeper then the max expected z depth. Preferences won't cover visually disabling all of it!")

/// Takes an offset to generate misc lists to, and a base to start from
/// Use this to react globally to maintain parity with plane offsets
/datum/controller/subsystem/mapping/proc/generate_offset_lists(gen_from, new_offset)
	create_plane_offsets(gen_from, new_offset)
	for(var/offset in gen_from to new_offset)
		GLOB.fullbright_overlays += create_fullbright_overlay(offset)

/datum/controller/subsystem/mapping/proc/create_plane_offsets(gen_from, new_offset)
	for(var/plane_offset in gen_from to new_offset)
		for(var/atom/movable/screen/plane_master/master_type as anything in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/rendering_plate)
			var/plane_to_use = initial(master_type.plane)
			var/string_real = "[plane_to_use]"

			var/offset_plane = GET_NEW_PLANE(plane_to_use, plane_offset)
			var/string_plane = "[offset_plane]"

			if(!initial(master_type.allows_offsetting))
				plane_offset_blacklist[string_plane] = TRUE
				var/render_target = initial(master_type.render_target)
				if(!render_target)
					render_target = get_plane_master_render_base(initial(master_type.name))
				render_offset_blacklist[render_target] = TRUE
				if(plane_offset != 0)
					continue

			if(initial(master_type.critical) & PLANE_CRITICAL_DISPLAY)
				critical_planes[string_plane] = TRUE

			plane_offset_to_true[string_plane] = plane_to_use
			plane_to_offset[string_plane] = plane_offset

			if(!true_to_offset_planes[string_real])
				true_to_offset_planes[string_real] = list()

			true_to_offset_planes[string_real] |= offset_plane

/proc/generate_lighting_appearance_by_z(z_level)
	if(length(GLOB.default_lighting_underlays_by_z) < z_level)
		GLOB.default_lighting_underlays_by_z.len = z_level
	GLOB.default_lighting_underlays_by_z[z_level] = mutable_appearance(LIGHTING_ICON, "transparent_lighting_object", z_level, null, LIGHTING_PLANE, 255, RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM, offset_const = GET_Z_PLANE_OFFSET(z_level))

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
