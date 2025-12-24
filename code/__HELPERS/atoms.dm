/// Returns the src and all recursive contents as a list.
/atom/proc/get_all_contents(ignore_flags)
	. = list(src)
	var/idx = 0
	while(idx < length(.))
		var/atom/checked_atom = .[++idx]
		if(checked_atom.flags & ignore_flags)
			continue
		. += checked_atom.contents

/// Identical to get_all_contents but returns a list of atoms of the type passed in the argument.
/atom/proc/get_all_contents_type(type)
	var/list/processing_list = list(src)
	. = list()
	while(length(processing_list))
		var/atom/checked_atom = processing_list[1]
		processing_list.Cut(1, 2)
		processing_list += checked_atom.contents
		if(istype(checked_atom, type))
			. += checked_atom

/// Like get_all_contents_type, but uses a typecache list as argument.
/atom/proc/get_all_contents_ignoring(list/ignore_typecache)
	if(!length(ignore_typecache))
		return get_all_contents()
	var/list/processing = list(src)
	. = list()
	var/i = 0
	while(i < length(processing))
		var/atom/checked_atom = processing[++i]
		if(ignore_typecache[checked_atom.type])
			continue
		processing += checked_atom.contents
		. += checked_atom

/// Recursively searches through all contents of the atom for the first instance of a specific type.
/atom/proc/get_type_in_all_contents(target_type)
	var/list/atoms_to_process = list(src)
	var/list/processed_atoms = list()
	var/atom/found_atom

	while(length(atoms_to_process) && isnull(found_atom))
		var/atom/current_atom = atoms_to_process[1]
		if(istype(current_atom, target_type))
			found_atom = current_atom

		atoms_to_process -= current_atom

		for(var/atom/contained_atom in current_atom)
			if(!(contained_atom in processed_atoms))
				atoms_to_process |= contained_atom

		processed_atoms |= current_atom

	return found_atom

/// Returns true if the src countain the atom target
/atom/proc/contains(atom/target)
	if(!target)
		return FALSE
	for(var/atom/location = target.loc, location, location = location.loc)
		if(location == src)
			return TRUE

/// Forces atom to drop all the important items while dereferencing them from their
/// containers both ways. To be used to preserve important items before mob gib/self-gib.
/// Returns a list with all saved items.
/atom/proc/drop_ungibbable_items(atom/new_loc)
	. = list()
	var/atom/drop_loc = new_loc ? new_loc : drop_location()

	for(var/atom/movable/I in contents)
		if(!is_type_in_list(I, GLOB.ungibbable_items_types))
			if(length(I.contents))
				. += I.drop_ungibbable_items(new_loc)
			continue

		. += I

		if(isturf(I.loc))
			continue

		var/obj/item/storage/holder_storage = I.loc
		if(istype(holder_storage))
			holder_storage.remove_from_storage(I, drop_loc)
			continue

		var/mob/holder_mob = I.loc
		if(istype(holder_mob))
			holder_mob.temporarily_remove_item_from_inventory(I, force = TRUE, silent = TRUE)
			I.forceMove(drop_loc)
			continue

		for(var/var_name in vars)
			// Item may be referenced in some properties of container.
			// E.g. holsters.
			if(vars[var_name] == I)
				vars[var_name] = null
			// Item may be referenced in some list properties of container.
			// E.g. medals.
			else if(islist(vars[var_name]) && (I in vars[var_name]))
				vars[var_name] -= I

		for(var/var_name in I.vars)
			// Item may reference container in some properties.
			// E.g. medals.
			if(I.vars[var_name] == src)
				I.vars[var_name] = null

		I.forceMove(drop_loc)

/**
 * Proc that collects all atoms of passed `path` in our atom contents
 * and returns it in a list()
 */
/atom/proc/collect_all_atoms_of_type(path, list/blacklist)
	var/list/atoms = list()
	if(src in blacklist)
		return atoms
	for(var/atom/check in contents)
		if(check in blacklist)
			continue
		if(istype(check, path))
			atoms |= check
		if(length(check.contents))
			atoms |= check.collect_all_atoms_of_type(path, blacklist)
	return atoms

/**
 *	Proc that returns if selected loc, or atom is within boundaries of playable area. (non-transitional space)
 */
/proc/is_location_within_transition_boundaries(atom/loc)
	return (loc.x > TRANSITION_BORDER_WEST) \
	&& (loc.x < TRANSITION_BORDER_EAST) \
	&& (loc.y > TRANSITION_BORDER_SOUTH) \
	&& (loc.y < TRANSITION_BORDER_NORTH)

/// Returns an x and y value require to reverse the transformations made to center an oversized icon
/atom/proc/get_oversized_icon_offsets()
	if(pixel_x == 0 && pixel_y == 0)
		return list("x" = 0, "y" = 0)
	var/list/icon_dimensions = get_icon_dimensions(icon)
	var/icon_width = icon_dimensions["width"]
	var/icon_height = icon_dimensions["height"]
	return list(
		"x" = icon_width > ICON_SIZE_X && pixel_x != 0 ? (icon_width - ICON_SIZE_X) * 0.5 : 0,
		"y" = icon_height > ICON_SIZE_Y && pixel_y != 0 ? (icon_height - ICON_SIZE_Y) * 0.5 : 0,
	)

/**
 * Checks if mover is movable atom and has passed pass_flags.
 *
 * Arguments:
 * * mover - target to check.
 * * passflag - flag to check for.
 */
/proc/checkpass(atom/movable/mover, passflag)
	if(!ismovable(mover))
		return FALSE
	if(mover.pass_flags == PASSEVERYTHING)
		return TRUE
	if(!passflag)
		return FALSE
	return (mover.pass_flags & passflag)

///Returns a list of all locations (except the area) the movable is within.
/proc/get_nested_locs(atom/movable/atom_on_location, include_turf = FALSE)
	. = list()
	var/atom/location = atom_on_location.loc
	var/turf/our_turf = get_turf(atom_on_location)
	while(location && location != our_turf)
		. += location
		location = location.loc
	if(our_turf && include_turf) //At this point, only the turf is left, provided it exists.
		. += our_turf

/// Adds the debris element for projectile impacts.
/atom/proc/add_debris_element()
	return

/**
 * Among other things, used by flamethrower and boiler spray to calculate if flame/spray can pass through.
 * Returns an atom for specific effects (primarily flames and acid spray) that damage things upon contact.
 *
 * This is a copy-and-paste of the Enter() proc for turfs with tweaks related to the applications of LinkBlocked
 *
 * Arguments:
 * * mover - The atom that is attempting to move
 * * start_turf - The turf the mover is starting from
 * * target_turf - The turf the mover is trying to enter
 * * forget - List of atoms to ignore when checking for blockers
 */
/proc/LinkBlocked(atom/movable/mover, turf/start_turf, turf/target_turf, list/atom/forget)
	if(!mover)
		return null

	/// The actual direction between the start and target turf
	var/move_direction = get_dir(start_turf, target_turf)
	if(!move_direction)
		return null

	/// First direction component
	var/fd1 = move_direction & (move_direction - 1)
	/// Second direction component
	var/fd2 = move_direction - fd1

	/// The direction that mover's path is being blocked by
	var/blocking_direction = 0

	var/current_obstacle
	var/turf/adjacent_turf
	var/atom/blocking_atom

	var/datum/can_pass_info/pass_info = new(mover, no_id = FALSE)

	blocking_direction |= start_turf.CanAStarPass(move_direction, pass_info)
	for(current_obstacle in start_turf) // First, check objects to block exit
		if(mover == current_obstacle || (current_obstacle in forget))
			continue
		if(!isstructure(current_obstacle) && !ismob(current_obstacle) && !isvehicle(current_obstacle))
			continue
		blocking_atom = current_obstacle
		blocking_direction |= blocking_atom.CanAStarPass(move_direction, pass_info)
		if((!fd1 || blocking_direction & fd1) && (!fd2 || blocking_direction & fd2))
			return blocking_atom

	// Check for atoms in adjacent turf EAST/WEST
	if(fd1 && fd1 != move_direction)
		adjacent_turf = get_step(start_turf, fd1)
		if(adjacent_turf.CanAStarPass(fd2, pass_info) || adjacent_turf.CanAStarPass(fd1, pass_info))
			blocking_direction |= fd1
			if((!fd1 || blocking_direction & fd1) && (!fd2 || blocking_direction & fd2))
				return adjacent_turf
		for(current_obstacle in adjacent_turf)
			if(current_obstacle in forget)
				continue
			if(!isstructure(current_obstacle) && !ismob(current_obstacle) && !isvehicle(current_obstacle))
				continue
			blocking_atom = current_obstacle
			if(blocking_atom.CanAStarPass(fd2, pass_info) || blocking_atom.CanAStarPass(fd1, pass_info))
				blocking_direction |= fd1
				if((!fd1 || blocking_direction & fd1) && (!fd2 || blocking_direction & fd2))
					return blocking_atom
				break

	// Check for atoms in adjacent turf NORTH/SOUTH
	if(fd2 && fd2 != move_direction)
		adjacent_turf = get_step(start_turf, fd2)
		if(adjacent_turf.CanAStarPass(fd1, pass_info) || adjacent_turf.CanAStarPass(fd2, pass_info))
			blocking_direction |= fd2
			if((!fd1 || blocking_direction & fd1) && (!fd2 || blocking_direction & fd2))
				return adjacent_turf
		for(current_obstacle in adjacent_turf)
			if(current_obstacle in forget)
				continue
			if(!isstructure(current_obstacle) && !ismob(current_obstacle) && !isvehicle(current_obstacle))
				continue
			blocking_atom = current_obstacle
			if(blocking_atom.CanAStarPass(fd1, pass_info) || blocking_atom.CanAStarPass(fd2, pass_info))
				blocking_direction |= fd2
				if((!fd1 || blocking_direction & fd1) && (!fd2 || blocking_direction & fd2))
					return blocking_atom
				break

	// Check the turf itself
	blocking_direction |= target_turf.CanAStarPass(move_direction, pass_info)
	if((!fd1 || blocking_direction & fd1) && (!fd2 || blocking_direction & fd2))
		return target_turf
	for(current_obstacle in target_turf) // Finally, check atoms in the target turf
		if(current_obstacle in forget)
			continue
		if(!isstructure(current_obstacle) && !ismob(current_obstacle) && !isvehicle(current_obstacle))
			continue
		blocking_atom = current_obstacle
		blocking_direction |= blocking_atom.CanAStarPass(move_direction, pass_info)
		if((fd1 && blocking_direction == fd1) || (fd2 && blocking_direction == fd2))
			return blocking_atom
		if((!fd1 || blocking_direction & fd1) && (!fd2 || blocking_direction & fd2))
			return blocking_atom

	return null // Nothing found to block the link of mover from start_turf to target_turf

/// get_dir() only considers an object to be north/south/east/west if there is zero deviation. This uses rounding instead. Ported from CM-SS13
/proc/get_compass_dir(atom/start, atom/end)
	if(!start || !end)
		return 0
	if(!start.z || !end.z)
		return 0 //Atoms are not on turfs.

	var/dy = end.y - start.y
	var/dx = end.x - start.x
	if(!dy)
		return (dx >= 0) ? 4 : 8

	var/angle = arctan(dx / dy)
	if(dy < 0)
		angle += 180
	else if(dx < 0)
		angle += 360

	switch(angle) //diagonal directions get priority over straight directions in edge cases
		if(22.5 to 67.5)
			return NORTHEAST
		if(112.5 to 157.5)
			return SOUTHEAST
		if(202.5 to 247.5)
			return SOUTHWEST
		if(292.5 to 337.5)
			return NORTHWEST
		if(0 to 22.5)
			return NORTH
		if(67.5 to 112.5)
			return EAST
		if(157.5 to 202.5)
			return SOUTH
		if(247.5 to 292.5)
			return WEST
		else
			return NORTH

/**
 * Proc which gets all adjacent turfs to `src`, including the turf that `src` is on.
 *
 * This is similar to doing `for(var/turf/T in range(1, src))`. However it is slightly more performant.
 * Additionally, the above proc becomes more costly the more atoms there are nearby. This proc does not care about that.
 */
/atom/proc/get_all_adjacent_turfs()
	var/turf/src_turf = get_turf(src)
	var/list/_list = list(
		src_turf,
		get_step(src_turf, NORTH),
		get_step(src_turf, NORTHEAST),
		get_step(src_turf, NORTHWEST),
		get_step(src_turf, SOUTH),
		get_step(src_turf, SOUTHEAST),
		get_step(src_turf, SOUTHWEST),
		get_step(src_turf, EAST),
		get_step(src_turf, WEST)
	)
	return _list

/// Checks if an atom is currently frozen
/proc/IsFrozen(atom/target)
	if(target in GLOB.frozen_atom_list)
		return TRUE
	return FALSE

/**
 * Returns a list of atoms in a location of a given type. Can be refined to look for pixel-shift.
 *
 * Arguments:
 * * location - The atom to look in.
 * * target_type - The type to look for.
 * * check_shift - If true, will exclude atoms whose pixel_x/pixel_y do not match shift_x/shift_y.
 * * shift_x - If check_shift is true, atoms whose pixel_x is different to this will be excluded.
 * * shift_y - If check_shift is true, atoms whose pixel_y is different to this will be excluded.
 */
/proc/get_atoms_of_type(atom/location, target_type, check_shift = FALSE, shift_x = 0, shift_y = 0)
	. = list()
	if(!location)
		return
	for(var/atom/current_atom as anything in location)
		if(!istype(current_atom, target_type))
			continue
		if(check_shift && !(current_atom.pixel_x == shift_x && current_atom.pixel_y == shift_y))
			continue
		. += current_atom

/// Returns a chosen path that is the closest to a list of matches
/proc/pick_closest_path(value, list/matches = get_fancy_list_of_atom_types())
	if(value == FALSE) //nothing should be calling us with a number, so this is safe
		value = tgui_input_text(usr, "Enter type to find (blank for all, cancel to cancel)", "Search for type", encode = FALSE)
		if(isnull(value))
			return
	value = trim(value)
	if(!isnull(value) && value != "")
		matches = filter_fancy_list(matches, value)

	if(length(matches) == 0)
		return

	var/chosen
	if(length(matches) == 1)
		chosen = matches[1]
	else
		chosen = tgui_input_list(usr, "Select a type", "Pick Type", matches,  matches[1])
		if(!chosen)
			return
	chosen = matches[chosen]
	return chosen

///Returns the closest atom of a specific type in a list from a source
/proc/get_closest_atom(type, list, source)
	var/closest_atom
	var/closest_distance
	for(var/A in list)
		if(!istype(A, type))
			continue
		var/distance = get_dist(source, A)
		if(!closest_distance)
			closest_distance = distance
			closest_atom = A
		else
			if(closest_distance > distance)
				closest_distance = distance
				closest_atom = A
	return closest_atom

/**
 * Returns all objects within a multiz-level range of the center atom
 *
 * Arguments:
 * * max_distance - maximum distance in tiles (including vertical levels)
 * * center - the central atom to measure distance from
 * * exclude_center - if TRUE, excludes the center atom from results
 * * include_areas - if TRUE, includes area objects in results
 */
/proc/urange_multiz(max_distance = 0, atom/center = usr, exclude_center = FALSE, include_areas = FALSE)
	if(!max_distance)
		if(!exclude_center)
			return list(center)
		else
			return list()

	var/list/station_z_levels = levels_by_trait(STATION_LEVEL)
	var/min_z_level = max(center.z - max_distance, station_z_levels[1])
	var/max_z_level = min(center.z + max_distance, station_z_levels[length(station_z_levels)])

	var/list/found_turfs = RANGE_TURFS_MULTIZ(max_distance, center, min_z_level, max_z_level)

	if(exclude_center)
		found_turfs -= get_turf(center)

	. = list()
	for(var/turf_entry in found_turfs)
		var/turf/current_turf = turf_entry
		. += current_turf
		. += current_turf.contents
		if(include_areas)
			. |= current_turf.loc

/**
 * Returns all objects within a specified range of the center atom (no limitations on distance, faster than range for distances > 8)
 *
 * Note: including areas drastically decreases performance.
 *
 * Arguments:
 * * range_distance - maximum distance in tiles from center
 * * center - the central atom to measure distance from
 * * exclude_center - if TRUE, excludes the center atom from results
 * * include_areas - if TRUE, includes area objects in results
 */
/proc/urange(range_distance = 0, atom/center = usr, exclude_center = FALSE, include_areas = FALSE)
	if(!range_distance)
		if(!exclude_center)
			return list(center)
		else
			return list()

	var/list/turfs_in_range = RANGE_TURFS(range_distance, center)
	if(exclude_center)
		turfs_in_range -= get_turf(center)

	. = list()
	for(var/turf_entry in turfs_in_range)
		var/turf/current_turf = turf_entry
		. += current_turf
		. += current_turf.contents
		if(include_areas)
			. |= current_turf.loc

/// A do nothing proc
/proc/pass(...)
	return

/**
 * Compare source's dir, the clockwise dir of source and the anticlockwise dir of source
 * To the opposite dir of the dir returned by get_dir(target,source)
 * If one of them is a match, then source is facing target
**/
/proc/is_source_facing_target(atom/source, atom/target)
	if(!istype(source) || !istype(target))
		return FALSE
	if(isliving(source))
		var/mob/living/source_mob = source
		if(source_mob.body_position == LYING_DOWN)
			return FALSE
	var/goal_dir = get_dir(source, target)
	var/clockwise_source_dir = turn(source.dir, -45)
	var/anticlockwise_source_dir = turn(source.dir, 45)

	if(source.dir == goal_dir || clockwise_source_dir == goal_dir || anticlockwise_source_dir == goal_dir)
		return TRUE
	return FALSE

///Forces the atom to take a step in a random direction
/proc/random_step(atom/movable/moving_atom, steps, chance)
	var/initial_chance = chance
	while(steps > 0)
		if(prob(chance))
			step(moving_atom, pick(GLOB.alldirs))
		chance = max(chance - (initial_chance / steps), 0)
		steps--

/**
 * Checks for wall-mounted items at a given location and direction
 *
 * Arguments:
 * * location - The turf to check for wall items
 * * direction - The direction to check for wall items
 */
/proc/check_wall_item(turf/location, direction)
	for(var/obj/current_object in location)
		if(is_type_in_typecache(current_object, GLOB.wall_items))
			// Direction works sometimes
			if(current_object.dir == direction)
				return TRUE

			// Some stuff doesn't use dir properly, so we need to check pixel instead
			switch(direction)
				if(SOUTH)
					if(current_object.pixel_y > 10)
						return TRUE
				if(NORTH)
					if(current_object.pixel_y < -10)
						return TRUE
				if(WEST)
					if(current_object.pixel_x > 10)
						return TRUE
				if(EAST)
					if(current_object.pixel_x < -10)
						return TRUE

	// Some stuff is placed directly on the wallturf (signs)
	for(var/obj/nearby_object in get_step(location, direction))
		if(is_type_in_typecache(nearby_object, GLOB.wall_items))
			if(abs(nearby_object.pixel_x) <= 10 && abs(nearby_object.pixel_y) <= 10)
				return TRUE
	return FALSE

/// Returns the atom type in the specified loc
/proc/get(atom/loc, type)
	while(loc)
		if(istype(loc, type))
			return loc
		loc = loc.loc
	return null

/// Get the cardinal direction between two atoms
/proc/get_cardinal_dir(atom/start, atom/end)
	var/dx = abs(end.x - start.x)
	var/dy = abs(end.y - start.y)
	return get_dir(start, end) & (rand() * (dx+dy) < dy ? 3 : 12)

///Step-towards method of determining whether one atom can see another. Similar to viewers()
///note: this is a line of sight algorithm, view() does not do any sort of raycasting and cannot be emulated by it accurately
/atom/proc/can_see(atom/target, length = 5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	if(!current_turf || !target_turf)	// nullspace
		return FALSE
	if(get_dist(current_turf, target_turf) > length)
		return FALSE
	if(current_turf == target_turf)//they are on the same turf, source can see the target
		return TRUE
	var/steps = 1
	current_turf = get_step_towards(current_turf, target_turf)
	while(current_turf != target_turf)
		if(steps > length)
			return FALSE
		if(IS_OPAQUE_TURF(current_turf))
			return FALSE
		current_turf = get_step_towards(current_turf, target_turf)
		steps++
	return TRUE

/// Searches contents of the atom and returns the sum of all w_class of obj/item within
/atom/proc/GetTotalContentsWeight()
	var/weight = 0
	var/list/content = get_all_contents()
	for(var/obj/item/item in content)
		weight += item.w_class
	return weight

/**
 * Get the direction of startObj relative to endObj.
 * Return values: To the right, 1. Below, 2. To the left, 3. Above, 4. Not found adjacent in cardinal directions, 0.
 */
/proc/getRelativeDirection(atom/movable/startObj, atom/movable/endObj)
	if(endObj.x == startObj.x + 1 && endObj.y == startObj.y)
		return EAST

	if(endObj.x == startObj.x - 1 && endObj.y == startObj.y)
		return WEST

	if(endObj.y == startObj.y + 1 && endObj.x == startObj.x)
		return NORTH

	if(endObj.y == startObj.y - 1 && endObj.x == startObj.x)
		return SOUTH

	return 0

/// Checks if an atom is in a teleport-proof area or z-level
/proc/is_in_teleport_proof_area(atom/target_atom)
	if(!target_atom)
		return FALSE

	var/area/current_area = get_area(target_atom)
	if(!current_area)
		return FALSE

	if(current_area.tele_proof)
		return TRUE

	return !is_teleport_allowed(target_atom.z)

/**
 * Checks if the atom or any of its containing atoms (up to the area) are of the specified type
 *
 * Arguments:
 * * target_type - The typepath to search for in the atom's containment hierarchy
 */
/atom/proc/is_found_within(target_type)
	var/atom/current_atom = src
	while(current_atom.loc)
		if(istype(current_atom.loc, target_type))
			return TRUE
		current_atom = current_atom.loc
	return FALSE

/**
 * Checks if a straight line can be drawn from source to target without hitting dense turfs within a specified length.
 * Similar to can_line but only checks density and does not support other atoms.
 *
 * Arguments:
 * * source - The starting atom for the line check.
 * * target - The target atom to draw the line towards.
 * * max_length - The maximum allowed length of the line (default: 5).
 */
/proc/can_line(atom/source, atom/target, max_length = 5)
	var/turf/current_turf = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/step_count = 0

	while(current_turf != target_turf)
		if(step_count > max_length)
			return FALSE
		if(!current_turf)
			return FALSE
		if(current_turf.density)
			return FALSE
		current_turf = get_step_towards(current_turf, target_turf)
		step_count++

	return TRUE
