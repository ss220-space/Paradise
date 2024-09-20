// Disposal pipe construction
// This is the pipe that you drag around, not the attached ones.

/obj/structure/disposalconstruct
	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'icons/obj/pipes_and_stuff/not_atmos/disposal.dmi'
	icon_state = "conpipe-s"
	anchored = FALSE
	density = FALSE
	pressure_resistance = 5 * ONE_ATMOSPHERE
	level = 2
	max_integrity = 200
	set_dir_on_move = FALSE
	/// What disposals type we are representing
	var/obj/pipe_type = /obj/structure/disposalpipe/segment
	/// Disposals name we got on init from the path above
	var/pipename


/obj/structure/disposalconstruct/Initialize(mapload, pipe_define, dir = SOUTH, obj/made_from)
	. = ..()
	if(made_from)
		pipe_type = made_from.type
		setDir(made_from.dir)
	else
		if(ispath(pipe_define))
			pipe_type = pipe_define
		else if(isnum(pipe_define))
			pipe_type = define2type(pipe_define)
			if(pipe_define == PIPE_DISPOSALS_BENT)	// dirty hack, requires rewriten RPD code
				dir = turn(dir, -45)
		setDir(dir)

	pipename = initial(pipe_type.name)
	update_appearance(UPDATE_ICON_STATE)

	if(!is_pipe())
		set_density(TRUE)


/// Proc required to convert RPD / pipe dispencer defines into disposal paths
/obj/structure/disposalconstruct/proc/define2type(value)
	switch(value)
		if(PIPE_DISPOSALS_STRAIGHT, PIPE_DISPOSALS_BENT)
			return /obj/structure/disposalpipe/segment
		if(PIPE_DISPOSALS_JUNCTION_RIGHT, PIPE_DISPOSALS_JUNCTION_LEFT)
			return /obj/structure/disposalpipe/junction
		if(PIPE_DISPOSALS_Y_JUNCTION)
			return /obj/structure/disposalpipe/junction/yjunction
		if(PIPE_DISPOSALS_TRUNK)
			return /obj/structure/disposalpipe/trunk
		if(PIPE_DISPOSALS_BIN)
			return /obj/machinery/disposal
		if(PIPE_DISPOSALS_OUTLET)
			return /obj/structure/disposaloutlet
		if(PIPE_DISPOSALS_CHUTE)
			return /obj/machinery/disposal/deliveryChute
		if(PIPE_DISPOSALS_SORT_RIGHT, PIPE_DISPOSALS_SORT_LEFT)
			return /obj/structure/disposalpipe/sortjunction
		if(PIPE_DISPOSALS_MULTIZ_UP)
			return /obj/structure/disposalpipe/trunk/multiz
		if(PIPE_DISPOSALS_MULTIZ_DOWN)
			return /obj/structure/disposalpipe/trunk/multiz/down
		if(PIPE_DISPOSALS_ROTATOR)
			return /obj/structure/disposalpipe/rotator


/obj/structure/disposalconstruct/update_icon_state()
	if(pipe_type == /obj/machinery/disposal)
		// Disposal bins receive special icon treating
		icon_state = "[anchored ? "" : "con"]disposal"
		return
	icon_state = "[is_pipe() ? "con" : ""][initial(pipe_type.icon_state)]"


/// If src represents a pipe this will return all possible dirs it has.
/obj/structure/disposalconstruct/proc/get_disposal_dir()
	if(!is_pipe())
		return NONE

	if(ISDIAGONALDIR(dir)) // Bent pipes
		return dir

	var/obj/structure/disposalpipe/temp = pipe_type
	var/initialize_dirs = initial(temp.initialize_dirs)
	var/dpdir = NONE
	if(initialize_dirs != DISP_DIR_NONE)
		dpdir = dir

		if(initialize_dirs & DISP_DIR_LEFT)
			dpdir |= turn(dir, 90)
		if(initialize_dirs & DISP_DIR_RIGHT)
			dpdir |= turn(dir, -90)
		if(initialize_dirs & DISP_DIR_FLIP)
			dpdir |= REVERSE_DIR(dir)
	return dpdir


// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalconstruct/hide(intact)
	invisibility = (intact && level == 1) ? INVISIBILITY_MAXIMUM : 0	// hide if floor is intact
	update_appearance(UPDATE_ICON_STATE)


/obj/structure/disposalconstruct/examine(mob/user)
	. = ..()
	. += span_info("<b>Alt-Click</b> to rotate it, <b>Alt-Shift-Click</b> to flip it.")


// flip and rotate verbs
/obj/structure/disposalconstruct/verb/rotate_verb()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)
	rotate(usr)


/obj/structure/disposalconstruct/AltClick(mob/user)
	if(Adjacent(user))
		rotate(user)


/// Rotates construct 90 degrees counter-clockwise
/obj/structure/disposalconstruct/proc/rotate(mob/user)
	if(user && (user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)))
		to_chat(user, span_warning("You can't do that right now!"))
		return FALSE
	if(anchored)
		if(user)
			to_chat(user, span_warning("You must unfasten the [pipename] before rotating it."))
		return FALSE
	add_fingerprint(user)
	setDir(turn(dir, -90))
	update_appearance(UPDATE_ICON_STATE)
	return TRUE


/obj/structure/disposalconstruct/verb/flip_verb()
	set category = "Object"
	set name = "Flip Pipe"
	set src in view(1)
	flip(usr)


/obj/structure/disposalconstruct/AltShiftClick(mob/user)
	if(Adjacent(user))
		flip(user)


/// Flips construct 180 degrees, but also inverts it if its a pipe with defined flip_type
/obj/structure/disposalconstruct/proc/flip(mob/user)
	if(user && (user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)))
		to_chat(user, span_warning("You can't do that right now!"))
		return FALSE
	if(anchored)
		if(user)
			to_chat(user, span_warning("You must unfasten the [pipename] before flipping it."))
		return FALSE
	add_fingerprint(user)
	setDir(turn(dir, 180))
	var/obj/structure/disposalpipe/temp = pipe_type
	if(is_pipe() && initial(temp.flip_type))
		pipe_type = initial(temp.flip_type)
	update_appearance(UPDATE_ICON_STATE)
	return TRUE


/obj/structure/disposalconstruct/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	var/turf/our_turf = loc
	if(!isturf(our_turf))
		return .
	if(our_turf.intact)
		to_chat(user, span_warning("You can only [anchored ? "detach" : "attach"] the [pipename] if the floor plating is removed."))
		return FALSE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return .
	var/ispipe = is_pipe() // Indicates if we should change the level of this pipe
	if(anchored)
		set_anchored(FALSE)
		to_chat(user, "You detach the [pipename] from the underfloor.")
	else
		if(!ispipe && iswallturf(our_turf))
			to_chat(user, span_warning("You can't build [pipename] on walls, only disposal pipes!"))
			return .

		if(ispipe)
			var/dpdir = get_disposal_dir()
			for(var/obj/structure/disposalpipe/pipe in our_turf)
				var/pdir = pipe.dpdir
				if(istype(pipe, /obj/structure/disposalpipe/broken))
					pdir = pipe.dir
				if(pdir & dpdir)
					if(istype(pipe, /obj/structure/disposalpipe/broken))
						qdel(pipe)
					else
						to_chat(user, span_warning("There is already a disposal pipe at that location!"))
						return TRUE

		else // Disposal or outlet
			if(!(locate(/obj/structure/disposalpipe/trunk) in our_turf))
				to_chat(user, span_warning("The [pipename] requires a trunk underneath it in order to work!"))
				return .

		set_anchored(TRUE)
		to_chat(user, "You attach the [pipename] to the underfloor.")
	update_appearance(UPDATE_ICON_STATE)


/obj/structure/disposalconstruct/welder_act(mob/living/user, obj/item/I)
	. = TRUE
	var/turf/our_turf = loc
	if(!isturf(our_turf))
		return .
	if(our_turf.intact)
		to_chat(user, span_warning("You can only [anchored ? "detach" : "attach"] the [pipename] if the floor plating is removed."))
		return .
	if(!anchored)
		to_chat(user, span_warning("You need to attach [pipename] to the plating first!"))
		return .
	var/ispipe = is_pipe()
	if(!ispipe && ((locate(/obj/machinery/disposal) in our_turf) || (locate(/obj/structure/disposaloutlet) in our_turf)))
		to_chat(user, span_warning("A disposals machine already exists here!"))
		return .
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || !anchored)
		return .
	if(!ispipe && ((locate(/obj/machinery/disposal) in our_turf) || (locate(/obj/structure/disposaloutlet) in our_turf)))
		return .
	to_chat(user, "The [pipename] has been welded in place!")
	var/obj/disposals = new pipe_type(loc, src)
	transfer_fingerprints_to(disposals)
	qdel(src)


/obj/structure/disposalconstruct/rpd_act(mob/user, obj/item/rpd/our_rpd)
	. = TRUE
	if(our_rpd.mode == RPD_ROTATE_MODE)
		rotate()
	else if(our_rpd.mode == RPD_FLIP_MODE)
		flip()
	else if(our_rpd.mode == RPD_DELETE_MODE)
		our_rpd.delete_single_pipe(user, src)
	else
		return ..()


/obj/structure/disposalconstruct/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.) || !is_pipe())
		return .
	if(anchored)
		level = 1
		layer = initial(pipe_type.layer)	// Extra layer handling
	else
		level = 2
		layer = initial(layer)


/// Checks whether we represent a pipe, depending on path in pipe_type variable
/obj/structure/disposalconstruct/proc/is_pipe()
	return ispath(pipe_type, /obj/structure/disposalpipe)

