/**
 * This proc gets a list of all "points of interest" (poi's) that can be used by admins to track valuable mobs or atoms (such as the nuke disk).
 * @param mobs_only if set to TRUE it won't include locations to the returned list
 * @param skip_mindless if set to TRUE it will skip mindless mobs
 * @param force_include_bots if set to TRUE it will include bots even if skip_mindless is set to TRUE
 * @param force_include_cameras if set to TRUE it will include camera eyes even if skip_mindless is set to TRUE
 * @return returns a list with the found points of interest
 */
/proc/getpois(mobs_only = FALSE, skip_mindless = FALSE, force_include_bots = FALSE, force_include_cameras = FALSE)
	var/list/sorted_mobs = sort_mobs()
	var/list/used_names = list()
	var/list/points_of_interest = list()
	var/list/name_counts = list()

	for(var/mob/mob_instance in sorted_mobs)
		if(skip_mindless && (!mob_instance.mind && !mob_instance.ckey))
			if(!(force_include_bots && isbot(mob_instance)) && !(force_include_cameras && istype(mob_instance, /mob/camera)))
				continue
		if(mob_instance.client && mob_instance.client.holder && mob_instance.client.holder.fakekey) //stealthmins
			continue
		var/mob_name = mob_instance.name
		if(mob_name in used_names)
			name_counts[mob_name]++
			mob_name = "[mob_name] ([name_counts[mob_name]])"
		else
			used_names.Add(mob_name)
			name_counts[mob_name] = 1
		if(mob_instance.real_name && mob_instance.real_name != mob_instance.name)
			mob_name += " \[[mob_instance.real_name]\]"
		if(mob_instance.stat == DEAD)
			if(istype(mob_instance, /mob/dead/observer/))
				mob_name += " \[ghost\]"
			else
				mob_name += " \[dead\]"
		points_of_interest[mob_name] = mob_instance

	if(!mobs_only)
		for(var/atom/atom_instance in GLOB.poi_list)
			if(!atom_instance || !atom_instance.loc)
				continue
			var/atom_name = atom_instance.name
			if(used_names.Find(atom_name))
				name_counts[atom_name]++
				atom_name = "[atom_name] ([name_counts[atom_name]])"
			else
				used_names.Add(atom_name)
				name_counts[atom_name] = 1
			points_of_interest[atom_name] = atom_instance

	return points_of_interest

/// Returns a list of all observer mobs in the player list
/proc/get_observers()
	var/list/observer_list = list()
	for(var/mob/dead/observer/observer_mob in GLOB.player_list) // for every observer with a client
		observer_list += observer_mob

	return observer_list

/**
 * This is just so you can stop an orbit.
 * orbit() can run without it (swap orbiting for A) but then you can never stop it and that's just silly.
 *
 * Arguments:
 * * A - atom to orbit
 * * radius - range to orbit at, radius of the circle formed by orbiting
 * * clockwise - whether you orbit clockwise or anti clockwise
 * * rotation_speed - how fast to rotate
 * * rotation_segments - the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
 * * pre_rotation - Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
 * * lockinorbit - Forces src to always be on A's turf, otherwise the orbit cancels when src gets too far away (eg: ghosts)
 */
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
