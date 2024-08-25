// Disposal pipes

/obj/structure/disposalpipe
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	icon = 'icons/obj/pipes_and_stuff/not_atmos/disposal.dmi'
	anchored = TRUE
	density = FALSE
	dir = NONE // dir will contain dominant direction for junction pipes
	max_integrity = 200
	on_blueprints = TRUE
	plane = GAME_PLANE
	layer = DISPOSAL_PIPE_LAYER // slightly lower than wires and other pipes
	level = 1	// underfloor only
	damage_deflection = 10
	set_dir_on_move = FALSE
	armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 90, ACID = 30)
	/// Hardness points, used in explosion interactions
	var/hardness = 15
	/// Bitflags of pipe directions added on init, see \code\_DEFINES\pipe_construction.dm
	var/initialize_dirs = NONE
	/// Bitmask of pipe directions
	var/dpdir = NONE
	/// If set, the pipe is flippable and becomes this type when flipped
	var/flip_type
	COOLDOWN_DECLARE(eject_effects_cd)


/obj/structure/disposalpipe/Initialize(mapload, obj/structure/disposalconstruct/made_from)
	. = ..()

	if(made_from)
		setDir(made_from.dir)

	if(ISDIAGONALDIR(dir)) // Bent pipes already have all the dirs set
		initialize_dirs = NONE

	if(initialize_dirs != DISP_DIR_NONE)
		dpdir = dir

		if(initialize_dirs & DISP_DIR_LEFT)
			dpdir |= turn(dir, 90)
		if(initialize_dirs & DISP_DIR_RIGHT)
			dpdir |= turn(dir, -90)
		if(initialize_dirs & DISP_DIR_FLIP)
			dpdir |= REVERSE_DIR(dir)

	update()


/obj/structure/disposalpipe/Destroy()
	spew_forth()
	return ..()


/**
 * Expells the pipe's contents.
 *
 * This proc checks through src's contents for holder objects,
 * and then tells each one to empty onto the tile. Called when
 * the pipe is deconstructed or someone struggles out.
 */
/obj/structure/disposalpipe/proc/spew_forth()
	var/turf/our_turf = get_turf(src)
	for(var/obj/structure/disposalholder/holder in contents)
		holder.active = FALSE
		expel(holder, our_turf)


// returns the direction of the next pipe object, given the entrance dir
// by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(obj/structure/disposalholder/holder)
	return dpdir & (~REVERSE_DIR(holder.dir))


// transfer the holder through this pipe segment
// overridden for special behaviour
/obj/structure/disposalpipe/proc/transfer(obj/structure/disposalholder/holder)
	return transfer_to_dir(holder, nextdir(holder))


/obj/structure/disposalpipe/proc/transfer_to_dir(obj/structure/disposalholder/holder, nextdir)
	holder.setDir(nextdir)
	var/turf/holder_next_loc = holder.nextloc()
	var/obj/structure/disposalpipe/pipe = holder.findpipe(holder_next_loc)

	if(!pipe) // if there wasn't a pipe, then they'll be expelled.
		return
	// find other holder in next loc, if inactive merge it with current
	var/obj/structure/disposalholder/holder2 = locate() in pipe
	if(holder2 && !holder2.active)
		if(holder2.hasmob) //If it's stopped and there's a mob, add to the pile
			holder2.merge(holder)
			return
		holder.merge(holder2)//Otherwise, we push it along through.
	holder.forceMove(pipe)
	return pipe


// expel the held objects into a turf
// called when there is a break in the pipe
/obj/structure/disposalpipe/proc/expel(obj/structure/disposalholder/holder, turf/expel_to, direction)
	if(!expel_to)
		expel_to = get_turf(src)
	var/turf/target
	var/eject_range = 5
	var/turf/simulated/floor/floorturf

	if(isfloorturf(expel_to))
		floorturf = expel_to
		if(floorturf.intact)	// pop the tile if present
			floorturf.remove_tile(null, TRUE, TRUE)

	if(direction) // direction is specified
		if(isspaceturf(expel_to)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(expel_to, direction)
		else // otherwise limit to 10 tiles
			target = get_ranged_target_turf(expel_to, direction, 10)

		eject_range = 10

	else if(floorturf)
		target = get_offset_target_turf(expel_to, rand(5)-rand(5), rand(5)-rand(5))

	if(COOLDOWN_FINISHED(src, eject_effects_cd))
		COOLDOWN_START(src, eject_effects_cd, DISPOSAL_SOUND_COOLDOWN)
		playsound(src, 'sound/machines/hiss.ogg', 50, FALSE)
	pipe_eject(holder, direction, TRUE, target, eject_range)
	holder.vent_gas(expel_to)
	qdel(holder)


/obj/structure/disposalpipe/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()


// update the icon_state to reflect hidden status
/obj/structure/disposalpipe/proc/update()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	if(our_turf.transparent_floor)
		SET_PLANE_IMPLICIT(src, FLOOR_PLANE)
	else
		SET_PLANE_IMPLICIT(src, GAME_PLANE)
	hide(our_turf.intact)	// space never hides pipes


// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalpipe/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0	// hide if floor is intact
	update_icon(UPDATE_ICON_STATE)


// update actual icon_state depending on visibility
// if invisible, append "f" to icon_state to show faded version
// this will be revealed if a T-scanner is used
// if visible, use regular icon_state
/obj/structure/disposalpipe/update_icon_state()
	if(invisibility)
		icon_state = "[base_icon_state]f"
	else
		icon_state = base_icon_state


// pipe affected by explosion
/obj/structure/disposalpipe/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(disassembled = FALSE)
		if(EXPLODE_HEAVY)
			adjust_hardness(-(rand(5, 15)))
		if(EXPLODE_LIGHT)
			adjust_hardness(-(rand(0, 15)))


/obj/structure/disposalpipe/proc/adjust_hardness(value)
	hardness = clamp(round(hardness + value), 0, initial(hardness))
	switch(hardness)
		if(0 to 2)
			deconstruct(disassembled = FALSE)
		if(3)
			deconstruct()


//attack by item
//weldingtool: unfasten and convert to obj/disposalconstruct

/obj/structure/disposalpipe/attackby(obj/item/I, mob/user, params)
	var/turf/our_turf = loc
	if(isturf(our_turf) && (our_turf.intact || (our_turf.transparent_floor == TURF_TRANSPARENT)))
		to_chat(user, span_warning("You cannot interact with something that's under the floor!"))
		return ATTACK_CHAIN_BLOCKED_ALL	// prevent interaction with T-scanner revealed pipes and pipes under glass
	return ..()


/obj/structure/disposalpipe/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return .
	var/turf/our_turf = loc
	if(isturf(our_turf) && (our_turf.intact || (our_turf.transparent_floor == TURF_TRANSPARENT)))
		to_chat(user, span_warning("You can't interact with something that's under the floor!"))
		return .
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return .
	WELDER_SLICING_SUCCESS_MESSAGE
	deconstruct()


/obj/structure/disposalpipe/deconstruct(disassembled = TRUE)
	if(disassembled)
		var/obj/structure/disposalconstruct/construct = new(loc, null, null, src)
		construct.set_anchored(TRUE)
		transfer_fingerprints_to(construct)
	else
		var/turf/location = get_turf(src)
		for(var/dir in GLOB.cardinal)
			if(dir & dpdir)
				var/obj/structure/disposalpipe/broken/pipe = new(location)
				pipe.setDir(dir)
	spew_forth()
	return ..()


// a straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"
	base_icon_state = "pipe-s"
	initialize_dirs = DISP_DIR_FLIP


//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	name = "disposal junction pipe"
	icon_state = "pipe-j1"
	base_icon_state = "pipe-j1"
	initialize_dirs = DISP_DIR_RIGHT|DISP_DIR_FLIP
	flip_type = /obj/structure/disposalpipe/junction/reversed


// next direction to move
// if coming in from secondary dirs, then next is primary dir
// if coming in from primary dir, then next is equal chance of other dirs
/obj/structure/disposalpipe/junction/nextdir(obj/structure/disposalholder/holder)
	var/flipdir = REVERSE_DIR(holder.dir)
	if(flipdir != dir) // came from secondary dir, so exit through primary
		return dir

	else // came from primary, so need to choose a secondary exit
		var/mask = dpdir & (~dir) // get a mask of secondary dirs

		// find one secondary dir in mask
		var/secdir = NONE
		for(var/c_dir in GLOB.cardinal)
			if(c_dir & mask)
				secdir = c_dir
				break

		if(prob(50)) // 50% chance to choose the found secondary dir
			return secdir
		else // or the other one
			return mask & (~secdir)


/obj/structure/disposalpipe/junction/reversed
	icon_state = "pipe-j2"
	base_icon_state = "pipe-j2"
	initialize_dirs = DISP_DIR_LEFT|DISP_DIR_FLIP
	flip_type = /obj/structure/disposalpipe/junction


/obj/structure/disposalpipe/junction/yjunction
	name = "disposal Y-junction pipe"
	icon_state = "pipe-y"
	base_icon_state = "pipe-y"
	initialize_dirs = DISP_DIR_LEFT|DISP_DIR_RIGHT
	flip_type = null


//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	name = "disposal trunk"
	icon_state = "pipe-t"
	base_icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet


/obj/structure/disposalpipe/trunk/Initialize(mapload)
	. = ..()
	getlinked()


/obj/structure/disposalpipe/trunk/Destroy()
	null_linked_refs()
	linked = null
	return ..()


/obj/structure/disposalpipe/trunk/proc/set_linked(obj/to_link)
	null_linked_refs()
	linked = to_link


/obj/structure/disposalpipe/trunk/proc/getlinked()
	null_linked_refs()
	linked = null
	var/turf/our_turf = get_turf(src)
	var/obj/machinery/disposal/disposal = locate() in our_turf
	if(disposal)
		set_linked(disposal)
	var/obj/structure/disposaloutlet/outlet = locate() in our_turf
	if(outlet)
		set_linked(outlet)


/obj/structure/disposalpipe/trunk/proc/null_linked_refs() //disposals is well-coded
	if(!linked)
		return
	if(istype(linked, /obj/machinery/disposal))
		var/obj/machinery/disposal/disposal = linked
		disposal.trunk = null
	else if(istype(linked, /obj/structure/disposaloutlet))
		var/obj/structure/disposaloutlet/outlet = linked
		outlet.trunk = null


// Override attackby so we disallow trunkremoval when somethings ontop
/obj/structure/disposalpipe/trunk/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(!isturf(loc))
		return ..()

	//Disposal bins or chutes
	//Disposal constructors
	var/obj/structure/disposalconstruct/construct = locate() in loc
	if(construct?.anchored)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


// would transfer to next pipe segment, but we are in a trunk
// if not entering from disposal bin,
// transfer to linked object (outlet or bin)
/obj/structure/disposalpipe/trunk/transfer(obj/structure/disposalholder/holder)
	if(holder.dir == DOWN) // we just entered from a disposer
		return ..() // so do base transfer proc
	// otherwise, go to the linked object
	if(linked)
		var/obj/structure/disposaloutlet/outlet = linked
		if(istype(outlet))
			outlet.expel(holder) // expel at outlet
		else
			var/obj/machinery/disposal/disposal = linked
			disposal.expel(holder) // expel at disposal

	// Returning null without expelling holder makes the holder expell itself
	return null


/obj/structure/disposalpipe/trunk/nextdir(obj/structure/disposalholder/holder)
	if(holder.dir == DOWN)
		return dir
	return NONE


/obj/structure/disposalpipe/rotator
	name = "disposal rotator pipe"
	icon_state = "pipe-r1"
	base_icon_state = "pipe-r1"
	initialize_dirs = DISP_DIR_LEFT|DISP_DIR_RIGHT|DISP_DIR_FLIP
	flip_type = /obj/structure/disposalpipe/rotator/reversed
	/// In what direction the atom travels.
	var/direction_angle = -90


/obj/structure/disposalpipe/rotator/nextdir(obj/structure/disposalholder/holder)
	return turn(holder.dir, direction_angle)


/obj/structure/disposalpipe/rotator/reversed
	icon_state = "pipe-r2"
	base_icon_state = "pipe-r2"
	flip_type = /obj/structure/disposalpipe/rotator
	direction_angle = 90


// a broken pipe
/obj/structure/disposalpipe/broken
	name = "broken disposal pipe"
	desc = "A broken piece of disposal pipe."
	icon_state = "pipe-b"
	base_icon_state = "pipe-b"
	initialize_dirs = DISP_DIR_NONE	// broken pipes always have dpdir = NONE so they're not found as 'real' pipes


/obj/structure/disposalpipe/broken/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("You remove [src]!"))
	qdel(src)

