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
