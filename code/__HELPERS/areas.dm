/**
 * Detects a room of connected turfs starting from an origin point
 * Returns an associative list of turf|dirs pairs where dirs are connected turfs in the same space
 *
 * Arguments:
 * * origin_turf - The starting turf for room detection
 * * break_types - Typecache of turf/area types that will break detection if found
 * * max_room_size - Maximum number of turfs to include in the room (default: INFINITY)
 */
/proc/detect_room(turf/origin_turf, list/break_types = list(), max_room_size = INFINITY)
	if(origin_turf.blocks_air)
		return list(origin_turf)

	var/list/room_turfs = list()
	var/list/checked_turfs = list()
	var/list/turfs_to_process = list(origin_turf)

	while(length(turfs_to_process))
		var/turf/current_turf = turfs_to_process[1]
		turfs_to_process.Cut(1, 2)
		var/checked_directions = checked_turfs[current_turf]

		for(var/direction in GLOB.alldirs)
			if(length(room_turfs) > max_room_size)
				return room_turfs

			if(checked_directions & direction)
				continue

			var/turf/adjacent_turf = get_step(current_turf, direction)
			if(!adjacent_turf)
				continue

			checked_turfs[current_turf] |= direction
			checked_turfs[adjacent_turf] |= REVERSE_DIR(direction)
			room_turfs[current_turf] |= direction
			room_turfs[adjacent_turf] |= REVERSE_DIR(direction)

			if(break_types[adjacent_turf.type] || break_types[adjacent_turf.loc.type])
				return FALSE

			var/static/list/cardinal_directions = list("[NORTH]" = TRUE, "[EAST]" = TRUE, "[SOUTH]" = TRUE, "[WEST]" = TRUE)
			if(!cardinal_directions["[direction]"] || adjacent_turf.blocks_air || !current_turf.CanAtmosPass(adjacent_turf))
				continue

			turfs_to_process += adjacent_turf

	return room_turfs

#define BLUEPRINTS_MAX_ROOM_SIZE 300

/proc/create_area(mob/creator, new_area_type = /area)
	// Passed into the above proc as list/break_if_found
	var/static/list/area_or_turf_fail_types = typecacheof(list(
		/turf/space,
		/area/shuttle,
	))
	// Ignore these areas and dont let people expand them. They can expand into them though
	var/static/list/blacklisted_areas = typecacheof(list(
		/area/space,
	))

	var/error = ""
	var/list/turfs = detect_room(get_turf(creator), area_or_turf_fail_types, BLUEPRINTS_MAX_ROOM_SIZE * 2)
	var/turf_count = length(turfs)
	if(!turf_count)
		error = "The new area must be completely airtight and not a part of a shuttle."
	else if(turf_count > BLUEPRINTS_MAX_ROOM_SIZE)
		error = "The room you're in is too big. It is [turf_count >= BLUEPRINTS_MAX_ROOM_SIZE * 2 ? "more than 100" : ((turf_count / BLUEPRINTS_MAX_ROOM_SIZE) - 1) * 100]% larger than allowed."
	if(error)
		to_chat(creator, span_warning(error))
		return

	var/list/apc_map = list()
	var/list/areas = list("New Area" = new_area_type)
	for(var/i in 1 to turf_count)
		var/turf/the_turf = turfs[i]
		var/area/place = get_area(the_turf)
		if(blacklisted_areas[place.type])
			continue
		if(!isnull(place.apc))
			apc_map[place.name] = place.apc
		if(!LAZYLEN(the_turf.atmos_adjacent_turfs)) // No expanding areas on blocked turfs
			continue
		if(length(apc_map) > 1) // When merging 2 or more areas make sure we arent merging their apc into 1 area
			to_chat(creator, span_warning("Multiple APC's detected in the vicinity. only 1 is allowed."))
			return
		areas[place.name] = place

	var/area_choice = tgui_input_list(creator, "Choose an area to expand or make a new area", "Area Expansion", areas)
	if(isnull(area_choice))
		to_chat(creator, span_warning("No choice selected. The area remains undefined."))
		return
	area_choice = areas[area_choice]

	var/area/newA
	var/area/oldA = get_area(get_turf(creator))
	if(!isarea(area_choice))
		var/str = tgui_input_text(usr, "New area name:", "Blueprint Editing", max_length = MAX_NAME_LEN, encode = FALSE)
		if(!str)
			return
		newA = new area_choice
		newA.name = str
		newA.power_equip = FALSE
		newA.power_light = FALSE
		newA.power_environ = FALSE
		newA.always_unpowered = FALSE
		newA.valid_territory = FALSE
		newA.has_gravity = oldA.has_gravity
	else
		newA = area_choice

	//we haven't done anything. let's get outta here
	if(newA == oldA)
		to_chat(creator, span_warning("Selected choice is same as the area your standing in. No area changes were requested."))
		return

	/**
	 * A list of all machinery tied to an area along with the area itself. key=area name,value=list(area,list of machinery)
	 * we use this to keep track of what areas are affected by the blueprints & what machinery of these areas needs to be reconfigured accordingly
	 */
	var/list/area/affected_areas = list()
	for(var/turf/the_turf as anything in turfs)
		var/area/old_area = the_turf.loc
		LISTASSERTLEN(old_area.turfs_to_uncontain_by_zlevel, the_turf.z, list())
		LISTASSERTLEN(newA.turfs_by_zlevel, the_turf.z, list())
		old_area.turfs_to_uncontain_by_zlevel[the_turf.z] += the_turf
		newA.turfs_by_zlevel[the_turf.z] += the_turf

		//keep rack of all areas affected by turf changes
		affected_areas[old_area.name] = old_area

		//move the turf to its new area and unregister it from the old one
		the_turf.change_area(old_area, newA)

	newA.reg_in_areas_in_z()

	//convert map to list
	var/list/area/area_list = list()
	for(var/area_name in affected_areas)
		area_list += affected_areas[area_name]
	//SEND_GLOBAL_SIGNAL(COMSIG_AREA_CREATED, newA, area_list, creator)
	to_chat(creator, span_notice("You have created a new area, named [newA.name]. It is now weather proof, and constructing an APC will allow it to be powered."))
	add_game_logs("created a new area ([newA.name]): [AREACOORD(creator)] (previously \"[sanitize(oldA.name)]\")", creator)

	//purge old areas that had all their turfs merged into the new one i.e. old empty areas. also recompute fire doors
	for(var/i in 1 to length(area_list))
		var/area/merged_area = area_list[i]

		//recompute fire doors affecting areas
		for(var/obj/machinery/door/firedoor/firedoor as anything in merged_area.firedoors)
			firedoor.CalculateAffectingAreas()

		//no more turfs in this area. Time to clean up
		if(!(locate(/turf) in merged_area.contents))
			qdel(merged_area)

	return TRUE

#undef BLUEPRINTS_MAX_ROOM_SIZE

/proc/require_area_resort()
	GLOB.sortedAreas = null

/// Returns a sorted version of GLOB.areas, by name
/proc/get_sorted_areas()
	if(!GLOB.sortedAreas)
		GLOB.sortedAreas = sortTim(GLOB.areas.Copy(), /proc/cmp_name_asc)
	return GLOB.sortedAreas

/// Simple datum for storing coordinates.
/datum/coords
	var/x_pos = null
	var/y_pos = null
	var/z_pos = null

// MARK: TODO: REF
/area/proc/copy_contents_to(area/A , platingRequired = FALSE, perfect_copy = TRUE)
	//Takes: Area. Optional: If it should copy to areas that don't have plating
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//	   Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src)
		return FALSE

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for(var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x)
			src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y)
			src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for(var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x)
			trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y)
			trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/toupdate = new/list()

	var/copiedobjs = list()

	moving:
		for(var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for(var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)
					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					if(platingRequired)
						if(isspaceturf(B))
							continue moving
					var/turf/X = new T.type(B)
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					for(var/obj/O in T)
						copiedobjs += DuplicateObject(O, perfect_copy, newloc = X)

					for(var/mob/M in T)
						if(!M.move_on_shuttle)
							continue
						copiedobjs += DuplicateObject(M, perfect_copy, newloc = X)

					for(var/V in T.vars)
						if(!(V in list("type","loc","locs","vars", "parent", "parent_type","verbs","ckey","key","x","y","z","destination_z", "destination_x", "destination_y","contents", "luminosity", "group")))
							X.vars[V] = T.vars[V]

					toupdate += X

					refined_src -= T
					refined_trg -= B
					continue moving

	if(length(toupdate))
		for(var/turf/simulated/T1 in toupdate)
			T1.CalculateAdjacentTurfs()
			SSair.add_to_active(T1,1)

	return copiedobjs

///Takes: Area type as text string or as typepath OR an instance of the area.
///Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(areatype, target_z = 0, subtypes=FALSE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null
	// Pull out the areas
	var/list/areas_to_pull = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/area/area_to_check as anything in GLOB.areas)
			if(!cache[area_to_check.type])
				continue
			areas_to_pull += area_to_check
	else
		for(var/area/area_to_check as anything in GLOB.areas)
			if(area_to_check.type != areatype)
				continue
			areas_to_pull += area_to_check

	// Now their turfs
	var/list/turfs = list()
	for(var/area/pull_from as anything in areas_to_pull)

		if(target_z != 0)
			turfs += pull_from.get_turfs_by_zlevel(target_z)
			continue

		for(var/list/zlevel_turfs as anything in pull_from.get_zlevel_turf_lists())
			turfs += zlevel_turfs

	return turfs

///Takes: Area type as text string or as typepath OR an instance of the area.
///Returns: A list of all areas of that type in the world.
/proc/get_areas(areatype, subtypes=TRUE)
	if(!areatype)
		return null
	if(istext(areatype))
		areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/areas = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/area/area_to_check as anything in GLOB.areas)
			if(cache[area_to_check.type])
				areas += area_to_check
	else
		for(var/area/area_to_check as anything in GLOB.areas)
			if(area_to_check.type == areatype)
				areas += area_to_check
	return areas
