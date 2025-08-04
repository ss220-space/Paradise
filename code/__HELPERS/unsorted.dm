/proc/get_client_by_ckey(ckey)
	if(cmptext(copytext(ckey, 1, 2),"@"))
		ckey = findStealthKey(ckey)
	return GLOB.directory[ckey]

/proc/findStealthKey(txt)
	if(txt)
		for(var/P in GLOB.stealthminID)
			if(GLOB.stealthminID[P] == txt)
				return P

/proc/DuplicateObject(obj/original, perfectcopy = FALSE , sameloc = FALSE, atom/newloc = null)
	if(!original)
		return null

	var/obj/obj = null

	if(sameloc)
		obj = new original.type(original.loc)
	else
		obj = new original.type(newloc)

	if(perfectcopy)
		if(obj)
			var/static/list/forbidden_vars = list("type", "loc", "locs", "vars", "parent", "parent_type", "verbs", "ckey", "key", "power_supply", "contents", "reagents", "stat", "x", "y", "z", "group", "comp_lookup", "datum_components")

			for(var/V in original.vars - forbidden_vars)
				if(istype(original.vars[V],/list))
					var/list/list = original.vars[V]
					obj.vars[V] = list.Copy()
				else if(isdatum(original.vars[V]))
					continue // This would reference the original's object, that will break when it is used or deleted.
				else
					obj.vars[V] = original.vars[V]
	if(istype(obj))
		obj.update_icon()
	return obj

/proc/view_or_range(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = view(distance,center)
		if("range")
			. = range(distance,center)
	return

/proc/get_mob_with_client_list()
	var/list/mobs = list()
	for(var/mob/M in GLOB.mob_list)
		if(M.client)
			mobs += M
	return mobs





/// For objects that should embed, but make no sense being is_sharp or is_pointed() e.g: rods
GLOBAL_LIST_INIT(can_embed_types, typecacheof(list(
	/obj/item/stack/rods,
	/obj/item/pipe
)))

/proc/can_embed(obj/item/weapon)
	if(is_sharp(weapon))
		return TRUE
	if(is_pointed(weapon))
		return TRUE
	if(is_type_in_typecache(weapon, GLOB.can_embed_types))
		return TRUE

/// Whether or not the given item counts as sharp in terms of dealing damage
/proc/is_sharp(obj/item/item)
	if(!istype(item))
		return FALSE
	if(item.sharp)
		return TRUE
	return FALSE










/proc/reverse_direction(dir)
	switch(dir)
		if(NORTH)
			return SOUTH
		if(NORTHEAST)
			return SOUTHWEST
		if(EAST)
			return WEST
		if(SOUTHEAST)
			return NORTHWEST
		if(SOUTH)
			return NORTH
		if(SOUTHWEST)
			return NORTHEAST
		if(WEST)
			return EAST
		if(NORTHWEST)
			return SOUTHEAST
		if(UP)
			return DOWN
		if(DOWN)
			return UP



/// Checks if that loc and dir has a item on the wall
GLOBAL_LIST_INIT(wall_items, typecacheof(list(/obj/machinery/power/apc, /obj/machinery/alarm,
	/obj/item/radio/intercom, /obj/structure/extinguisher_cabinet, /obj/structure/reagent_dispensers/peppertank,
	/obj/machinery/status_display, /obj/machinery/requests_console, /obj/machinery/light_switch, /obj/structure/sign,
	/obj/machinery/newscaster, /obj/machinery/firealarm, /obj/structure/noticeboard, /obj/machinery/door_control,
	/obj/machinery/computer/security/telescreen, /obj/machinery/embedded_controller/radio/airlock,
	/obj/item/storage/secure/safe, /obj/machinery/door_timer, /obj/machinery/flasher, /obj/machinery/keycard_auth,
	/obj/structure/mirror, /obj/structure/closet/fireaxecabinet, /obj/machinery/computer/security/telescreen/entertainment,
	/obj/structure/sign)))

/proc/gotwallitem(loc, dir)
	for(var/obj/O in loc)
		if(is_type_in_typecache(O, GLOB.wall_items))
			//Direction works sometimes
			if(O.dir == dir)
				return 1

			//Some stuff doesn't use dir properly, so we need to check pixel instead
			switch(dir)
				if(SOUTH)
					if(O.pixel_y > 10)
						return 1
				if(NORTH)
					if(O.pixel_y < -10)
						return 1
				if(WEST)
					if(O.pixel_x > 10)
						return 1
				if(EAST)
					if(O.pixel_x < -10)
						return 1

	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in get_step(loc, dir))
		if(is_type_in_typecache(O, GLOB.wall_items))
			if(abs(O.pixel_x) <= 10 && abs(O.pixel_y) <= 10)
				return 1
	return 0





/proc/urange_multiz(dist=0, atom/center=usr, orange=0, areas=0)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()
	var/list/stations_z = levels_by_trait(STATION_LEVEL)
	var/min_z = max(center.z - dist, stations_z[1])
	var/max_z = min(center.z + dist, stations_z[length(stations_z)])
	var/list/turfs = RANGE_TURFS_MULTIZ(dist, center, min_z, max_z)
	if(orange)
		turfs -= get_turf(center)
	. = list()
	for(var/V in turfs)
		var/turf/T = V
		. += T
		. += T.contents
		if(areas)
			. |= T.loc

/proc/is_there_multiz()
	return SSmapping?.map_datum?.traits?.len > 1




/proc/IsFrozen(atom/A)
	if(A in GLOB.frozen_atom_list)
		return TRUE
	return FALSE
