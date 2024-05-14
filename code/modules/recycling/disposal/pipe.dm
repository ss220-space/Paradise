// Disposal pipes

/obj/structure/disposalpipe
	icon = 'icons/obj/pipes_and_stuff/not_atmos/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = TRUE
	density = FALSE
	on_blueprints = TRUE
	level = 1			// underfloor only
	var/dpdir = 0		// bitmask of pipe directions
	dir = 0				// dir will contain dominant direction for junction pipes
	var/health = 10 	// health points 0-10
	max_integrity = 200
	armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 30)
	damage_deflection = 10
	plane = FLOOR_PLANE
	layer = DISPOSAL_PIPE_LAYER				// slightly lower than wires and other pipes
	/// The last time a sound was played from this
	var/last_sound

	// new pipe, set the icon_state as on map
/obj/structure/disposalpipe/Initialize(mapload)
	. = ..()
	base_icon_state = icon_state


// pipe is deleted
// ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	for(var/obj/structure/disposalholder/H in contents)
		H.active = 0
		var/turf/T = loc
		if(T.density)
			// deleting pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.forceMove(T)
				AM.pipe_eject(0)
			qdel(H)
			..()
			return

		// otherwise, do normal expel from turf
		expel(H, T, 0)
	return ..()

/obj/structure/disposalpipe/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

// returns the direction of the next pipe object, given the entrance dir
// by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(var/fromdir)
	return dpdir & (~turn(fromdir, 180))

// transfer the holder through this pipe segment
// overriden for special behaviour
//
/obj/structure/disposalpipe/proc/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		if(T.is_blocked_turf())
			H.forceMove(loc)
		else
			H.forceMove(T)
		return null

	return P


// update the icon_state to reflect hidden status
/obj/structure/disposalpipe/proc/update()
	var/turf/T = get_turf(src)
	hide(T.intact && !isspaceturf(T) && !T.transparent_floor)	// space never hides pipes
	update_icon(UPDATE_ICON_STATE)


// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalpipe/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0	// hide if floor is intact
	update_icon()

// update actual icon_state depending on visibility
// if invisible, append "f" to icon_state to show faded version
// this will be revealed if a T-scanner is used
// if visible, use regular icon_state
/obj/structure/disposalpipe/update_icon_state()
	if(invisibility)
		icon_state = "[base_icon_state]f"
	else
		icon_state = base_icon_state


// expel the held objects into a turf
// called when there is a break in the pipe
//

/obj/structure/disposalpipe/proc/expel(obj/structure/disposalholder/H, turf/T, direction)

	if(!T)
		return

	var/turf/target

	if(T.density)		// dense ouput turf, so stop holder
		H.active = FALSE
		H.forceMove(src)
		return

	if(T.intact && isfloorturf(T)) //intact floor, pop the tile
		var/turf/simulated/floor/F = T
		F.remove_tile(null, TRUE, TRUE)

	if(direction)		// direction is specified
		if(isspaceturf(T)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else						// otherwise limit to 10 tiles
			target = get_ranged_target_turf(T, direction, 10)

		if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
			playsound(src, 'sound/machines/hiss.ogg', 50, FALSE, 0)
			last_sound = world.time

		if(H)
			for(var/atom/movable/AM in H)
				AM.forceMove(T)
				AM.pipe_eject(direction)
				SEND_SIGNAL(AM, COMSIG_MOVABLE_EXIT_DISPOSALS)
				addtimer(CALLBACK(AM, TYPE_PROC_REF(/atom/movable, throw_at), target, 100, 1), 0.1 SECONDS, TIMER_DELETE_ME)
			H.vent_gas(T)
			qdel(H)

	else	// no specified direction, so throw in random direction

		if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
			playsound(src, 'sound/machines/hiss.ogg', 50, 0, FALSE)
			last_sound = world.time
		if(H)
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

				AM.forceMove(T)
				AM.pipe_eject(0)
				SEND_SIGNAL(AM, COMSIG_MOVABLE_EXIT_DISPOSALS)
				addtimer(CALLBACK(AM, TYPE_PROC_REF(/atom/movable, throw_at), target, 5, 1), 0.1 SECONDS, TIMER_DELETE_ME)

			H.vent_gas(T)	// all gas vent to turf
			qdel(H)


// call to break the pipe
// will expel any holder inside at the time
// then delete the pipe
// remains : set to leave broken pipe pieces in place
/obj/structure/disposalpipe/proc/broken(remains = 0)
	if(remains)
		for(var/D in GLOB.cardinal)
			if(D & dpdir)
				var/obj/structure/disposalpipe/broken/P = new(src.loc)
				P.setDir(D)

	invisibility = INVISIBILITY_ABSTRACT	// make invisible (since we won't delete the pipe immediately)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		// holder was present
		H.active = FALSE
		var/turf/T = src.loc
		if(T.density)
			// broken pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case
			for(var/atom/movable/AM in H)
				AM.forceMove(T)
				AM.pipe_eject(NONE)
			qdel(H)
			return

		// otherwise, do normal expel from turf
		if(H)
			expel(H, T, NONE)

	QDEL_IN(src, 0.2 SECONDS)	// delete pipe after delay to ensure expel proc finished


// pipe affected by explosion
/obj/structure/disposalpipe/ex_act(severity)
	switch(severity)
		if(1)
			broken(0)
		if(2)
			health -= rand(5, 15)
			healthcheck()
		if(3)
			health -= rand(0, 15)
			healthcheck()

// test health for brokenness
/obj/structure/disposalpipe/proc/healthcheck()
	if(health < -2)
		broken(0)
	else if(health<1)
		broken(1)
	return

//attack by item
//weldingtool: unfasten and convert to obj/disposalconstruct

/obj/structure/disposalpipe/attackby(var/obj/item/I, var/mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact || (T.transparent_floor == TURF_TRANSPARENT))
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return 		// prevent interaction with T-scanner revealed pipes and pipes under glass
	add_fingerprint(user)


/obj/structure/disposalpipe/welder_act(mob/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(!I.tool_use_check(user, 0))
		return
	if(T.transparent_floor == TURF_TRANSPARENT)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return
	WELDER_SLICING_SUCCESS_MESSAGE
	var/obj/structure/disposalconstruct/C = new (get_turf(src))
	switch(base_icon_state)
		if("pipe-s")
			C.ptype = PIPE_DISPOSALS_STRAIGHT
		if("pipe-c")
			C.ptype = PIPE_DISPOSALS_BENT
		if("pipe-j1")
			C.ptype = PIPE_DISPOSALS_JUNCTION_RIGHT
		if("pipe-j2")
			C.ptype = PIPE_DISPOSALS_JUNCTION_LEFT
		if("pipe-y")
			C.ptype = PIPE_DISPOSALS_Y_JUNCTION
		if("pipe-t")
			C.ptype = PIPE_DISPOSALS_TRUNK
		if("pipe-j1s")
			C.ptype = PIPE_DISPOSALS_SORT_RIGHT
		if("pipe-j2s")
			C.ptype = PIPE_DISPOSALS_SORT_LEFT
	src.transfer_fingerprints_to(C)
	C.dir = dir
	C.set_density(FALSE)
	C.set_anchored(TRUE)
	C.update()

	qdel(src)

// *** TEST verb
//client/verb/dispstop()
//	for(var/obj/structure/disposalholder/H in world)
//		H.active = 0

// a straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

/obj/structure/disposalpipe/segment/Initialize(mapload)
	. = ..()
	if(icon_state == "pipe-s")
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)
	update()



//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

/obj/structure/disposalpipe/junction/Initialize(mapload)
	. = ..()
	if(icon_state == "pipe-j1")
		dpdir = dir | turn(dir, -90) | turn(dir,180)
	else if(icon_state == "pipe-j2")
		dpdir = dir | turn(dir, 90) | turn(dir,180)
	else // pipe-y
		dpdir = dir | turn(dir,90) | turn(dir, -90)
	update()


	// next direction to move
	// if coming in from secondary dirs, then next is primary dir
	// if coming in from primary dir, then next is equal chance of other dirs

/obj/structure/disposalpipe/junction/nextdir(fromdir)
	var/flipdir = turn(fromdir, 180)
	if(flipdir != dir)	// came from secondary dir
		return dir		// so exit through primary
	else				// came from primary
						// so need to choose either secondary exit
		var/mask = ..(fromdir)

		// find a bit which is set
		var/setbit = 0
		if(mask & NORTH)
			setbit = NORTH
		else if(mask & SOUTH)
			setbit = SOUTH
		else if(mask & EAST)
			setbit = EAST
		else
			setbit = WEST

		if(prob(50))	// 50% chance to choose the found bit or the other one
			return setbit
		else
			return mask & (~setbit)

//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/Initialize(mapload)
	. = ..()
	dpdir = dir
	addtimer(CALLBACK(src, PROC_REF(getlinked)), 0) // This has a delay of 0, but wont actually start until the MC is done
	update()


/obj/structure/disposalpipe/trunk/Destroy()
	if(istype(linked, /obj/structure/disposaloutlet))
		var/obj/structure/disposaloutlet/O = linked
		O.expel(animation = 0)
	else if(istype(linked, /obj/machinery/disposal))
		var/obj/machinery/disposal/D = linked
		if(D.trunk == src)
			D.go_out()
			D.trunk = null
	remove_trunk_links()
	return ..()

/obj/structure/disposalpipe/trunk/proc/getlinked()
	var/turf/T = get_turf(src)
	var/obj/machinery/disposal/D = locate() in T
	if(D)
		nicely_link_to_other_stuff(D)
		return
	var/obj/structure/disposaloutlet/O = locate() in T
	if(O)
		nicely_link_to_other_stuff(O)

/obj/structure/disposalpipe/trunk/proc/remove_trunk_links() //disposals is well-coded
	if(!linked)
		return
	else if(istype(linked, /obj/machinery/disposal)) //jk lol
		var/obj/machinery/disposal/D = linked
		D.trunk = null
	else if(istype(linked, /obj/structure/disposaloutlet)) //God fucking damn it
		var/obj/structure/disposaloutlet/D = linked
		D.linkedtrunk = null
	linked = null

/obj/structure/disposalpipe/trunk/proc/nicely_link_to_other_stuff(obj/O)
	remove_trunk_links() //Breaks the connections between this trunk and the linked machinery so we don't get sent to nullspace or some shit like that
	if(istype(O, /obj/machinery/disposal))
		var/obj/machinery/disposal/D = O
		linked = D
		D.trunk = src
	else if(istype(O, /obj/structure/disposaloutlet))
		var/obj/structure/disposaloutlet/D = O
		linked = D
		D.linkedtrunk = src

	// Override attackby so we disallow trunkremoval when somethings ontop
/obj/structure/disposalpipe/trunk/attackby(var/obj/item/I, var/mob/user, params)
	add_fingerprint(user)

	//Disposal bins or chutes
	//Disposal constructors
	var/obj/structure/disposalconstruct/C = locate() in src.loc
	if(C && C.anchored)
		return

	var/turf/T = src.loc
	if(T.intact || (T.transparent_floor == TURF_TRANSPARENT))
		return		// prevent interaction with T-scanner revealed pipes

	// would transfer to next pipe segment, but we are in a trunk
	// if not entering from disposal bin,
	// transfer to linked object (outlet or bin)

/obj/structure/disposalpipe/trunk/transfer(obj/structure/disposalholder/H)
	if(!H)
		return
	if(H.dir == DOWN)		// we just entered from a disposer
		return ..()		// so do base transfer proc
	// otherwise, go to the linked object
	if(!linked)
		expel(H, loc, FALSE)	// expel at turf
	else if(istype(linked, /obj/structure/disposaloutlet))
		var/obj/structure/disposaloutlet/DO = linked
		for(var/atom/movable/AM in H)
			AM.forceMove(DO)
		qdel(H)
		H.vent_gas(loc)
		DO.expel()
	else if(istype(linked, /obj/machinery/disposal))
		var/obj/machinery/disposal/D = linked
		H.forceMove(D)
		D.expel(H)	// expel at disposal
	else //just in case
		expel(H, loc, FALSE)
	// nextdir

/obj/structure/disposalpipe/trunk/nextdir(fromdir)
	if(fromdir == DOWN)
		return dir
	return NONE

// a broken pipe
/obj/structure/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = NONE		// broken pipes have dpdir=0 so they're not found as 'real' pipes
					// i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

/obj/structure/disposalpipe/broken/Initialize(mapload)
	. = ..()
	update()


/obj/structure/disposalpipe/broken/welder_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, 0, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You remove [src]!</span>")
		I.play_tool_sound(src, I.tool_volume)
		qdel(src)
		return TRUE
