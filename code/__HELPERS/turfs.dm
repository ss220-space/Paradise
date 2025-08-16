///Returns a random turf on the station
/proc/get_random_station_turf()
	var/list/turfs = get_area_turfs(pick(SSmapping.existing_station_areas))
	if(length(turfs))
		return pick(turfs)

///Returns a random turf on the station, excludes dense turfs (like walls) and areas that have valid_territory set to FALSE
/proc/get_safe_random_station_turf(list/areas_to_pick_from = SSmapping.existing_station_areas)
	for(var/i in 1 to 5)
		var/list/turf_list = get_area_turfs(pick(areas_to_pick_from))
		var/turf/target
		while (turf_list.len && !target)
			var/I = rand(1, turf_list.len)
			var/turf/checked_turf = turf_list[I]
			var/area/turf_area = get_area(checked_turf)
			if(!checked_turf.density && (turf_area.valid_territory) && !isgroundlessturf(checked_turf))
				var/clear = TRUE
				for(var/obj/checked_object in checked_turf)
					if(checked_object.density)
						clear = FALSE
						break
				if(clear)
					target = checked_turf
			if(!target)
				turf_list.Cut(I, I + 1)
		if(target)
			return target

/**
 * Lets the turf this atom's *ICON* appears to inhabit
 * it takes into account:
 * Pixel_x/y
 * Matrix x/y
 * NOTE: if your atom has non-standard bounds then this proc
 * will handle it, but:
 * if the bounds are even, then there are an even amount of "middle" turfs, the one to the EAST, NORTH, or BOTH is picked
 * this may seem bad, but you're at least as close to the center of the atom as possible, better than byond's default loc being all the way off)
 * if the bounds are odd, the true middle turf of the atom is returned
 */
/proc/get_turf_pixel(atom/checked_atom)
	var/turf/atom_turf = get_turf(checked_atom) //use checked_atom's turfs, as its coords are the same as checked_atom's AND checked_atom's coords are lost if it is inside another atom
	if(!atom_turf)
		return null
	if(checked_atom.flags & IGNORE_TURF_PIXEL_OFFSET)
		return atom_turf

	var/list/offsets = get_visual_offset(checked_atom)
	return pixel_offset_turf(atom_turf, offsets)

/**
 * Returns how visually "off" the atom is from its source turf as a list of x, y (in pixel steps)
 * it takes into account:
 * Pixel_x/y
 * Matrix x/y
 * Icon width/height
 */
/proc/get_visual_offset(atom/checked_atom)
	//Find checked_atom's matrix so we can use its X/Y pixel shifts
	var/matrix/atom_matrix = matrix(checked_atom.transform)

	var/pixel_x_offset = checked_atom.pixel_x + checked_atom.pixel_w + atom_matrix.get_x_shift()
	var/pixel_y_offset = checked_atom.pixel_y + checked_atom.pixel_z + atom_matrix.get_y_shift()

	//Irregular objects
	var/list/icon_dimensions = get_icon_dimensions(checked_atom.icon)
	var/checked_atom_icon_height = icon_dimensions["height"]
	var/checked_atom_icon_width = icon_dimensions["width"]
	if(checked_atom_icon_height != ICON_SIZE_Y || checked_atom_icon_width != ICON_SIZE_X)
		pixel_x_offset += ((checked_atom_icon_width / ICON_SIZE_X) - 1) * (ICON_SIZE_X * 0.5)
		pixel_y_offset += ((checked_atom_icon_height / ICON_SIZE_Y) - 1) * (ICON_SIZE_Y * 0.5)

	return list(pixel_x_offset, pixel_y_offset)

/**
 * Takes a turf, and a list of x and y pixel offsets and returns the turf that the offset position best lands in
 */
/proc/pixel_offset_turf(turf/offset_from, list/offsets)
	//DY and DX
	var/rough_x = round(round(offsets[1], ICON_SIZE_X) / ICON_SIZE_X)
	var/rough_y = round(round(offsets[2], ICON_SIZE_Y) / ICON_SIZE_Y)

	var/final_x = clamp(offset_from.x + rough_x, 1, world.maxx)
	var/final_y = clamp(offset_from.y + rough_y, 1, world.maxy)

	if(final_x || final_y)
		return locate(final_x, final_y, offset_from.z)
	return offset_from
