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














/atom/proc/GetTypeInAllContents(typepath)
	var/list/processing_list = list(src)
	var/list/processed = list()

	var/atom/found = null

	while(processing_list.len && found==null)
		var/atom/A = processing_list[1]
		if(istype(A, typepath))
			found = A

		processing_list -= A

		for(var/atom/a in A)
			if(!(a in processed))
				processing_list |= a

		processed |= A

	return found



/proc/get_random_colour(var/simple, var/lower, var/upper)
	var/colour
	if(simple)
		colour = pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))
	else
		for(var/i=1;i<=3;i++)
			var/temp_col = "[num2hex(rand(lower, upper), 2)]"
			if(length(temp_col )<2)
				temp_col  = "0[temp_col]"
			colour += temp_col
	return colour

/proc/get_distant_turf(var/turf/T,var/direction,var/distance)
	if(!T || !direction || !distance)	return

	var/dest_x = T.x
	var/dest_y = T.y
	var/dest_z = T.z

	if(direction & NORTH)
		dest_y = min(world.maxy, dest_y+distance)
	if(direction & SOUTH)
		dest_y = max(0, dest_y-distance)
	if(direction & EAST)
		dest_x = min(world.maxy, dest_x+distance)
	if(direction & WEST)
		dest_x = max(0, dest_x-distance)

	return locate(dest_x,dest_y,dest_z)



/proc/IsValidSrc(A)
	if(isdatum(A))
		var/datum/D = A
		return !QDELETED(D)
	if(isclient(A))
		return TRUE
	return FALSE











//Get the dir to the RIGHT of dir if they were on a clock
//NORTH --> NORTHEAST
/proc/get_clockwise_dir(dir) // Del this shit
	. = angle2dir(dir2angle(dir)+45)

//Get the dir to the LEFT of dir if they were on a clock
//NORTH --> NORTHWEST
/proc/get_anticlockwise_dir(dir) // Del this shit
	. = angle2dir(dir2angle(dir)-45)



//This is just so you can stop an orbit.
//orbit() can run without it (swap orbiting for A)
//but then you can never stop it and that's just silly.
/atom/movable/var/atom/orbiting = null
/atom/movable/var/cached_transform = null
//A: atom to orbit
//radius: range to orbit at, radius of the circle formed by orbiting
//clockwise: whether you orbit clockwise or anti clockwise
//rotation_speed: how fast to rotate
//rotation_segments: the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
//pre_rotation: Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
//lockinorbit: Forces src to always be on A's turf, otherwise the orbit cancels when src gets too far away (eg: ghosts)

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lockinorbit = FALSE, forceMove = FALSE)
	if(!istype(A))
		return

	if(orbiting)
		stop_orbit()

	orbiting = A
	LAZYOR(A.orbiters, src)
	SEND_SIGNAL(orbiting, COMSIG_ATOM_ORBIT_BEGIN, src)
	if(ismob(A))
		var/mob/M = A
		M.ghost_orbiting += 1
	var/matrix/initial_transform = matrix(transform)
	cached_transform = initial_transform
	var/lastloc = loc

	//Head first!
	if(pre_rotation)
		var/matrix/M = matrix(transform)
		var/pre_rot = 90
		if(!clockwise)
			pre_rot = -90
		M.Turn(pre_rot)
		transform = M

	var/matrix/shift = matrix(transform)
	shift.Translate(0,radius)
	transform = shift

	SpinAnimation(rotation_speed, -1, clockwise, rotation_segments, parallel = FALSE)

	while(orbiting && orbiting == A && A.loc)
		var/targetloc = get_turf(A)
		if(!targetloc || (!lockinorbit && loc != lastloc && loc != targetloc))
			break
		if(forceMove)
			forceMove(targetloc)
		else
			loc = targetloc
		lastloc = loc
		var/atom/movable/B = A
		if(istype(B))
			glide_size = B.glide_size
		sleep(0.6)

	if(orbiting == A) //make sure we haven't started orbiting something else.
		stop_orbit()


/atom/movable/proc/stop_orbit()
	if(ismob(orbiting))
		var/mob/M = orbiting
		M.ghost_orbiting -= 1

	SEND_SIGNAL(orbiting, COMSIG_ATOM_ORBIT_STOP, src)
	LAZYREMOVE(orbiting.orbiters, src)
	orbiting = null
	transform = cached_transform
	SpinAnimation(0, 0, parallel = FALSE)
	// После, потому что сначало надо занулить orbiting дабы худ показался ЧИСТЫЙ
	SEND_SIGNAL(src, COMSIG_ORBITER_ORBIT_STOP)


//Centers an image.
//Requires:
//The Image
//The x dimension of the icon file used in the image
//The y dimension of the icon file used in the image
// eg: center_image(I, 32,32)
// eg2: center_image(I, 96,96)
/proc/center_image(image/I, x_dimension = 0, y_dimension = 0)
	if(!I)
		return

	if(!x_dimension || !y_dimension)
		return

	//Get out of here, punk ass kids calling procs needlessly
	if((x_dimension == world.icon_size) && (y_dimension == world.icon_size))
		return I

	//Offset the image so that it's bottom left corner is shifted this many pixels
	//This makes it infinitely easier to draw larger inhands/images larger than world.iconsize
	//but still use them in game
	var/x_offset = -((x_dimension/world.icon_size)-1)*(world.icon_size*0.5)
	var/y_offset = -((y_dimension/world.icon_size)-1)*(world.icon_size*0.5)

	//Correct values under world.icon_size
	if(x_dimension < world.icon_size)
		x_offset *= -1
	if(y_dimension < world.icon_size)
		y_offset *= -1

	I.pixel_x = x_offset
	I.pixel_y = y_offset

	return I





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


/proc/screen_loc2turf(scr_loc, turf/origin)
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	tX = max(1, min(world.maxx, origin.x + (text2num(tX) - (world.view + 1))))
	tY = max(1, min(world.maxy, origin.y + (text2num(tY) - (world.view + 1))))
	return locate(tX, tY, tZ)





//Key thing that stops lag. Cornerstone of performance in ss13, Just sitting here, in unsorted.dm.

//Increases delay as the server gets more overloaded,
//as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta-1,1)), 1)

//returns the number of ticks slept
/proc/stoplag(initial_delay)
	if (!Master || Master.init_stage_completed < INITSTAGE_MAX)
		sleep(world.tick_lag)
		return 1
	if(!initial_delay)
		initial_delay = world.tick_lag
	. = 0
	var/i = DS2TICKS(initial_delay)
	do
		. += CEILING(i*DELTA_CALC, 1)
		sleep(i*world.tick_lag*DELTA_CALC)
		i *= 2
	while(TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))

#undef DELTA_CALC

/*
 * This proc gets a list of all "points of interest" (poi's) that can be used by admins to track valuable mobs or atoms (such as the nuke disk).
 * @param mobs_only if set to TRUE it won't include locations to the returned list
 * @param skip_mindless if set to TRUE it will skip mindless mobs
 * @param force_include_bots if set to TRUE it will include bots even if skip_mindless is set to TRUE
 * @param force_include_cameras if set to TRUE it will include camera eyes even if skip_mindless is set to TRUE
 * @return returns a list with the found points of interest
*/
/proc/getpois(mobs_only = FALSE, skip_mindless = FALSE, force_include_bots = FALSE, force_include_cameras = FALSE)
	var/list/mobs = sortmobs()
	var/list/names = list()
	var/list/pois = list()
	var/list/namecounts = list()

	for(var/mob/M in mobs)
		if(skip_mindless && (!M.mind && !M.ckey))
			if(!(force_include_bots && isbot(M)) && !(force_include_cameras && istype(M, /mob/camera)))
				continue
		if(M.client && M.client.holder && M.client.holder.fakekey) //stealthmins
			continue
		var/name = M.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if(M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if(M.stat == DEAD)
			if(istype(M, /mob/dead/observer/))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		pois[name] = M

	if(!mobs_only)
		for(var/atom/A in GLOB.poi_list)
			if(!A || !A.loc)
				continue
			var/name = A.name
			if(names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			pois[name] = A

	return pois

/proc/get_observers()
	var/list/ghosts = list()
	for(var/mob/dead/observer/M in GLOB.player_list) // for every observer with a client
		ghosts += M

	return ghosts

/proc/flash_color(mob_or_client, flash_color=COLOR_CULT_RED, flash_time=20)
	var/client/C
	if(istype(mob_or_client, /mob))
		var/mob/M = mob_or_client
		if(M.client)
			C = M.client
		else
			return
	else if(isclient(mob_or_client))
		C = mob_or_client

	if(!istype(C))
		return

	C.color = flash_color
	spawn(0)
		animate(C, color = initial(C.color), time = flash_time)

#define RANDOM_COLOUR (rgb(rand(0,255),rand(0,255),rand(0,255)))

/proc/make_bit_triplet()
	var/list/num_sample  = list(1, 2, 3, 4, 5, 6, 7, 8, 9)
	var/result = 0
	for(var/i = 0, i < 3, i++)
		var/num = pick(num_sample)
		num_sample -= num
		result += (1 << num)
	return result

/proc/pixel_shift_dir(var/dir, var/amount_x = 32, var/amount_y = 32) //Returns a list with pixel_shift values that will shift an object's icon one tile in the direction passed.
	amount_x = min(max(0, amount_x), 32) //No less than 0, no greater than 32.
	amount_y = min(max(0, amount_x), 32)
	var/list/shift = list("x" = 0, "y" = 0)
	switch(dir)
		if(NORTH)
			shift["y"] = amount_y
		if(SOUTH)
			shift["y"] = -amount_y
		if(EAST)
			shift["x"] = amount_x
		if(WEST)
			shift["x"] = -amount_x
		if(NORTHEAST)
			shift = list("x" = amount_x, "y" = amount_y)
		if(NORTHWEST)
			shift = list("x" = -amount_x, "y" = amount_y)
		if(SOUTHEAST)
			shift = list("x" = amount_x, "y" = -amount_y)
		if(SOUTHWEST)
			shift = list("x" = -amount_x, "y" = -amount_y)

	return shift

/**
  * Returns a list of atoms in a location of a given type. Can be refined to look for pixel-shift.
  *
  * Arguments:
  * * loc - The atom to look in.
  * * type - The type to look for.
  * * check_shift - If true, will exclude atoms whose pixel_x/pixel_y do not match shift_x/shift_y.
  * * shift_x - If check_shift is true, atoms whose pixel_x is different to this will be excluded.
  * * shift_y - If check_shift is true, atoms whose pixel_y is different to this will be excluded.
  */
/proc/get_atoms_of_type(atom/loc, type, check_shift = FALSE, shift_x = 0, shift_y = 0)
	. = list()
	if(!loc)
		return
	for(var/atom/A as anything in loc)
		if(!istype(A, type))
			continue
		if(check_shift && !(A.pixel_x == shift_x && A.pixel_y == shift_y))
			continue
		. += A


/atom/proc/Shake(pixelshiftx = 15, pixelshifty = 15, duration = 250)
	var/initialpixelx = pixel_x
	var/initialpixely = pixel_y
	var/shiftx = rand(-pixelshiftx,pixelshiftx)
	var/shifty = rand(-pixelshifty,pixelshifty)
	animate(src, pixel_x = pixel_x + shiftx, pixel_y = pixel_y + shifty, time = 0.2, loop = duration)
	pixel_x = initialpixelx
	pixel_y = initialpixely





/proc/params2turf(scr_loc, turf/origin, client/C)
	if(!scr_loc)
		return null
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	var/list/actual_view = getviewsize(C ? C.view : world.view)
	tX = clamp(origin.x + text2num(tX) - round(actual_view[1] / 2) - 1, 1, world.maxx)
	tY = clamp(origin.y + text2num(tY) - round(actual_view[2] / 2) - 1, 1, world.maxy)
	return locate(tX, tY, tZ)

/proc/CallAsync(datum/source, proctype, list/arguments)
	set waitfor = FALSE
	return call(source, proctype)(arglist(arguments))

/proc/IsFrozen(atom/A)
	if(A in GLOB.frozen_atom_list)
		return TRUE
	return FALSE

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


/**
  * Returns the clean name of an audio channel.
  *
  * Arguments:
  * * channel - The channel number.
  */
/proc/get_channel_name(channel)
	switch(channel)
		if(CHANNEL_GENERAL)
			return "Основные звуки"
		if(CHANNEL_LOBBYMUSIC)
			return "Музыка в лобби"
		if(CHANNEL_ADMIN)
			return "Админские MIDI"
		if(CHANNEL_VOX)
			return "Оповещения ИИ"
		if(CHANNEL_JUKEBOX)
			return "Танцевальные машины"
		if(CHANNEL_HEARTBEAT)
			return "Сердцебиение"
		if(CHANNEL_BUZZ)
			return "Белый шум"
		if(CHANNEL_AMBIENCE)
			return "Эмбиент"
		if(CHANNEL_TTS_LOCAL)
			return "TTS рядом"
		if(CHANNEL_TTS_RADIO)
			return "TTS в радиосвязи"
		if(CHANNEL_RADIO_NOISE)
			return "Звуки радиосвязи"
		if(CHANNEL_INTERACTION_SOUNDS)
			return "Звуки взаимодействия с предметами"
		if(CHANNEL_BOSS_MUSIC)
			return "Музыка боссов"

/proc/get_compass_dir(atom/start, atom/end) //get_dir() only considers an object to be north/south/east/west if there is zero deviation. This uses rounding instead. // Ported from CM-SS13
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
		if (22.5 to 67.5)
			return NORTHEAST
		if (112.5 to 157.5)
			return SOUTHEAST
		if (202.5 to 247.5)
			return SOUTHWEST
		if (292.5 to 337.5)
			return NORTHWEST
		if (0 to 22.5)
			return NORTH
		if (67.5 to 112.5)
			return EAST
		if (157.5 to 202.5)
			return SOUTH
		if (247.5 to 292.5)
			return WEST
		else
			return NORTH




// Among other things, used by flamethrower and boiler spray to calculate if flame/spray can pass through.
// Returns an atom for specific effects (primarily flames and acid spray) that damage things upon contact
//
// This is a copy-and-paste of the Enter() proc for turfs with tweaks related to the applications
// of LinkBlocked
/proc/LinkBlocked(atom/movable/mover, turf/start_turf, turf/target_turf, list/atom/forget)
	if (!mover)
		return null

	/// the actual dir between the start and target turf
	var/fdir = get_dir(start_turf, target_turf)
	if (!fdir)
		return null

	var/fd1 = fdir & (fdir-1)
	var/fd2 = fdir - fd1

	/// The direction that mover's path is being blocked by
	var/blocking_dir = 0

	var/obstacle
	var/turf/T
	var/atom/A

	var/datum/can_pass_info/pass = new(mover, no_id = FALSE)

	blocking_dir |= start_turf.CanAStarPass(fdir, pass)
	for (obstacle in start_turf) //First, check objects to block exit
		if (mover == obstacle || (obstacle in forget))
			continue
		if (!isstructure(obstacle) && !ismob(obstacle) && !isvehicle(obstacle))
			continue
		A = obstacle
		blocking_dir |= A.CanAStarPass(fdir, pass)
		if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
			return A

	// Check for atoms in adjacent turf EAST/WEST
	if (fd1 && fd1 != fdir)
		T = get_step(start_turf, fd1)
		if (T.CanAStarPass(fd2, pass) || T.CanAStarPass(fd1, pass))
			blocking_dir |= fd1
			if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
				return T
		for (obstacle in T)
			if(obstacle in forget)
				continue
			if (!isstructure(obstacle) && !ismob(obstacle) && !isvehicle(obstacle))
				continue
			A = obstacle
			if (A.CanAStarPass(fd2, pass) || A.CanAStarPass(fd1, pass))
				blocking_dir |= fd1
				if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
					return A
				break

	// Check for atoms in adjacent turf NORTH/SOUTH
	if (fd2 && fd2 != fdir)
		T = get_step(start_turf, fd2)
		if (T.CanAStarPass(fd1, pass) || T.CanAStarPass(fd2, pass))
			blocking_dir |= fd2
			if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
				return T
		for (obstacle in T)
			if(obstacle in forget)
				continue
			if (!isstructure(obstacle) && !ismob(obstacle) && !isvehicle(obstacle))
				continue
			A = obstacle
			if (A.CanAStarPass(fd1, pass) || A.CanAStarPass(fd2, pass))
				blocking_dir |= fd2
				if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
					return A
				break

	// Check the turf itself
	blocking_dir |= target_turf.CanAStarPass(fdir, pass)
	if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
		return target_turf
	for (obstacle in target_turf) // Finally, check atoms in the target turf
		if(obstacle in forget)
			continue
		if (!isstructure(obstacle) && !ismob(obstacle) && !isvehicle(obstacle))
			continue
		A = obstacle
		blocking_dir |= A.CanAStarPass(fdir, pass)
		if((fd1 && blocking_dir == fd1) || (fd2 && blocking_dir == fd2))
			return A
		if((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
			return A

	return null // Nothing found to block the link of mover from start_turf to target_turf
