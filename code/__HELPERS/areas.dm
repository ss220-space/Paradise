#define BLUEPRINTS_MAX_ROOM_SIZE 300

// Gets an atmos isolated contained space
// Returns an associative list of turf|dirs pairs
// The dirs are connected turfs in the same space
// break_if_found is a typecache of turf/area types to return false if found
// Please keep this proc type agnostic. If you need to restrict it do it elsewhere or add an arg.
/proc/detect_room(turf/origin, list/break_if_found = list(), max_size = INFINITY)
	if(origin.blocks_air)
		return list(origin)

	. = list()
	var/list/checked_turfs = list()
	var/list/found_turfs = list(origin)
	while(length(found_turfs))
		var/turf/sourceT = found_turfs[1]
		found_turfs.Cut(1, 2)
		var/dir_flags = checked_turfs[sourceT]
		for(var/dir in GLOB.alldirs)
			if(length(.) > max_size)
				return
			if(dir_flags & dir) // This means we've checked this dir before, probably from the other turf
				continue
			var/turf/checkT = get_step(sourceT, dir)
			if(!checkT)
				continue
			checked_turfs[sourceT] |= dir
			checked_turfs[checkT] |= REVERSE_DIR(dir)
			.[sourceT] |= dir
			.[checkT] |= REVERSE_DIR(dir)
			if(break_if_found[checkT.type] || break_if_found[checkT.loc.type])
				return FALSE
			var/static/list/cardinal_cache = list("[NORTH]" = TRUE, "[EAST]" = TRUE, "[SOUTH]" = TRUE, "[WEST]" = TRUE)
			if(!cardinal_cache["[dir]"] || checkT.blocks_air || !sourceT.CanAtmosPass(checkT))
				continue
			found_turfs += checkT // Since checkT is connected, add it to the list to be processed


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
	var/area/affected_areas = list()
	for(var/turf/the_turf as anything in turfs)
		var/area/old_area = the_turf.loc

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

