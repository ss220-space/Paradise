/// Returns the src and all recursive contents as a list.
/atom/proc/get_all_contents(ignore_flags)
	. = list(src)
	var/idx = 0
	while(idx < length(.))
		var/atom/checked_atom = .[++idx]
		if(checked_atom.flags & ignore_flags)
			continue
		. += checked_atom.contents

/// Same as get_all_contents(), but returns a list of atoms of the passed type
/atom/proc/get_all_contents_type(type)
	var/list/processing_list = list(src)
	. = list()
	while(length(processing_list))
		var/atom/checked_atom = processing_list[1]
		processing_list.Cut(1, 2)
		processing_list += checked_atom.contents
		if(istype(checked_atom, type))
			. += checked_atom

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
 * 	Proc that returns if selected loc, or atom is within boundaries of playable area. (non-transitional space)
 */
/proc/is_location_within_transition_boundaries(atom/loc)
	return (loc.x > TRANSITION_BORDER_WEST) \
	&& (loc.x < TRANSITION_BORDER_EAST) \
	&& (loc.y > TRANSITION_BORDER_SOUTH) \
	&& (loc.y < TRANSITION_BORDER_NORTH)

/// Returns an x and y value require to reverse the transformations made to center an oversized icon
/atom/proc/get_oversized_icon_offsets()
	if (pixel_x == 0 && pixel_y == 0)
		return list("x" = 0, "y" = 0)
	var/list/icon_dimensions = get_icon_dimensions(icon)
	var/icon_width = icon_dimensions["width"]
	var/icon_height = icon_dimensions["height"]
	return list(
		"x" = icon_width > world.icon_size && pixel_x != 0 ? (icon_width - world.icon_size) * 0.5 : 0,
		"y" = icon_height > world.icon_size && pixel_y != 0 ? (icon_height - world.icon_size) * 0.5 : 0,
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

/// Returns a list of all locations (except the area) the movable is within.
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
	AddElement(/datum/element/debris, null, -40, 8, 0.7)

/// Returns a chosen path that is the closest to a list of matches
/proc/pick_closest_path(value, list/matches = get_fancy_list_of_atom_types())
	if(value == FALSE) //nothing should be calling us with a number, so this is safe
		value = tgui_input_text(usr, "Enter type to find (blank for all, cancel to cancel)", "Search for type", encode = FALSE)
		if(isnull(value))
			return
	value = trim(value)

	var/random = FALSE
	if(findtext(value, "?"))
		value = replacetext(value, "?", "")
		random = TRUE

	if(!isnull(value) && value != "")
		matches = filter_fancy_list(matches, value)

	if(matches.len == 0)
		return

	var/chosen
	if(matches.len == 1)
		chosen = matches[1]
	else if(random)
		chosen = pick(matches) || null
	else
		chosen = tgui_input_list(usr, "Select a type", "Pick Type", sort_list(matches),  matches[1])
	if(!chosen)
		return
	chosen = matches[chosen]
	return chosen

/// Returns the closest atom of a specific type in a list from a source
/proc/get_closest_atom(type, list/atom_list, source)
	var/closest_atom
	var/closest_distance
	for(var/atom in atom_list)
		if(!istype(atom, type))
			continue
		var/distance = get_dist(source, atom)
		if(!closest_atom)
			closest_distance = distance
			closest_atom = atom
		else
			if(closest_distance > distance)
				closest_distance = distance
				closest_atom = atom
	return closest_atom

/// Returns the atom type in the specified loc
/proc/get(atom/loc, type)
	while(loc)
		if(istype(loc, type))
			return loc
		loc = loc.loc
	return null

/// A do nothing proc
/proc/pass(...)
	return

/// Similar function to range(), but with no limitations on the distance; will search spiralling outwards from the center
/proc/spiral_range(dist = 0, center = usr, orange = FALSE)
	var/list/atom_list = list()
	var/turf/t_center = get_turf(center)
	if(!t_center)
		return list()

	if(!orange)
		atom_list += t_center
		atom_list += t_center.contents

	if(!dist)
		return atom_list


	var/turf/checked_turf
	var/y
	var/x
	var/c_dist = 1

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x + c_dist)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y - c_dist to y)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x - c_dist to x)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y + c_dist)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents
		c_dist++

	return atom_list

/// Ultra range (no limitations on distance, faster than range for distances > 8); including areas drastically decreases performance
/proc/urange(dist = 0, atom/center = usr, orange = FALSE, areas = FALSE)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/list/turfs = RANGE_TURFS(dist, center)
	if(orange)
		turfs -= get_turf(center)
	. = list()
	for(var/turf/checked_turf as anything in turfs)
		. += checked_turf
		. += checked_turf.contents
		if(areas)
			. |= checked_turf.loc

/// Forces the atom to take a step in a random direction
/proc/random_step(atom/movable/moving_atom, steps, chance)
	var/initial_chance = chance
	while(steps > 0)
		if(prob(chance))
			step(moving_atom, pick(GLOB.alldirs))
		chance = max(chance - (initial_chance / steps), 0)
		steps--

/// Get the cardinal direction between two atoms
/proc/get_cardinal_dir(atom/start, atom/end)
	var/dx = abs(end.x - start.x)
	var/dy = abs(end.y - start.y)
	return get_dir(start, end) & (rand() * (dx+dy) < dy ? 3 : 12)

/// Step-towards method of determining whether one atom can see another. Similar to viewers()
/// note: this is a line of sight algorithm, view() does not do any sort of raycasting and cannot be emulated by it accurately
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

/**
 * Compare source's dir, the clockwise dir of source and the anticlockwise dir of source
 * To the opposite dir of the dir returned by get_dir(target,source)
 * If one of them is a match, then source is facing target
 */
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

/// Get the direction of startObj relative to endObj.
/// Return values: To the right, 1. Below, 2. To the left, 3. Above, 4. Not found adjacent in cardinal directions, 0.
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

/// Same as the thing below just for density and without support for atoms.
/proc/can_line(atom/source, atom/target, length = 5)
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 0

	while(current != target_turf)
		if(steps > length)
			return FALSE
		if(!current)
			return FALSE
		if(current.density)
			return FALSE
		current = get_step_towards(current, target_turf)
		steps++
	return TRUE

/// Returns 1 if the chain up to the area contains the given typepath 0 otherwise.
/atom/proc/is_found_within(typepath)
	var/atom/A = src
	while(A.loc)
		if(istype(A.loc, typepath))
			return 1
		A = A.loc
	return 0

/// Will return the contents of an atom recursivly to a depth of 'searchDepth'
/atom/proc/GetAllContents(searchDepth = 5)
	var/list/toReturn = list()

	for(var/atom/part in contents)
		toReturn += part
		if(part.contents.len && searchDepth)
			toReturn += part.GetAllContents(searchDepth - 1)

	return toReturn

/// Searches contents of the atom and returns the sum of all w_class of obj/item within
/atom/proc/GetTotalContentsWeight(searchDepth = 5)
	var/weight = 0
	var/list/content = GetAllContents(searchDepth)
	for(var/obj/item/I in content)
		weight += I.w_class
	return weight
