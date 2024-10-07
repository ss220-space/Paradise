#define STAIR_TERMINATOR_AUTOMATIC 0
#define STAIR_TERMINATOR_NO 1
#define STAIR_TERMINATOR_YES 2

// dir determines the direction of travel to go upwards
// stairs require /turf/simulated/openspace as the tile above them to work, unless your stairs have 'force_open_above' set to TRUE
// multiple stair objects can be chained together; the Z level transition will happen on the final stair object in the chain

/obj/structure/stairs
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	anchored = TRUE
	move_resist = INFINITY

	var/force_open_above = FALSE // replaces the turf above this stair obj with /turf/simulated/openspace
	var/terminator_mode = STAIR_TERMINATOR_AUTOMATIC
	var/turf/listeningTo

/obj/structure/stairs/wood
	icon_state = "stairs_wood"

/obj/structure/stairs/Initialize(mapload)
	if(force_open_above)
		force_open_above()
		build_signal_listener()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

	return ..()

/obj/structure/stairs/Destroy()
	listeningTo = null
	return ..()

/obj/structure/stairs/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE) //Look this should never happen but...
	. = ..()
	if(force_open_above)
		build_signal_listener()

/obj/structure/stairs/proc/on_exit(datum/source, atom/movable/leaving, atom/newloc)
	SIGNAL_HANDLER

	if(leaving == src)
		return //Let's not block ourselves.
	var/direction = get_dir_multiz(src, newloc)

	if(!isobserver(leaving) && isTerminator() && direction == dir)
		leaving.set_currently_z_moving(CURRENTLY_Z_ASCENDING)
		INVOKE_ASYNC(src, PROC_REF(stair_ascend), leaving)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/stairs/Cross(atom/movable/crossed_atom, border_dir)
	if(isTerminator() && (border_dir == dir))
		return FALSE
	return ..()

/obj/structure/stairs/proc/stair_ascend(atom/movable/climber)
	var/turf/checking = get_step_multiz(get_turf(src), UP)
	if(!istype(checking))
		return
	// I'm only interested in if the pass is unobstructed, not if the mob will actually make it
	if(!climber.can_z_move(UP, get_turf(src), checking, z_move_flags = ZMOVE_ALLOW_BUCKLED))
		return
	var/turf/target = get_step_multiz(get_turf(src), (dir|UP))
	if(istype(target) && !climber.can_z_move(DOWN, target, z_move_flags = ZMOVE_FALL_FLAGS)) //Don't throw them into a tile that will just dump them back down.
		climber.zMove(target = target, z_move_flags = ZMOVE_STAIRS_FLAGS)
		/// Moves anything that's being dragged by src or anything buckled to it to the stairs turf.
		climber.pulling?.move_from_pull(climber, loc, climber.glide_size)
		for(var/mob/living/buckled as anything in climber.buckled_mobs)
			buckled.pulling?.move_from_pull(buckled, loc, buckled.glide_size)


/obj/structure/stairs/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, force_open_above))
		return
	if(!var_value)
		if(listeningTo)
			UnregisterSignal(listeningTo, COMSIG_TURF_MULTIZ_NEW)
			listeningTo = null
	else
		build_signal_listener()
		force_open_above()

/obj/structure/stairs/proc/build_signal_listener()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_TURF_MULTIZ_NEW)
	var/turf/simulated/openspace/T = get_step_multiz(get_turf(src), UP)
	RegisterSignal(T, COMSIG_TURF_MULTIZ_NEW, PROC_REF(on_multiz_new))
	listeningTo = T

/obj/structure/stairs/proc/force_open_above()
	var/turf/simulated/openspace/T = get_step_multiz(get_turf(src), UP)
	if(T && !istype(T))
		T.ChangeTurf(/turf/simulated/openspace)

/obj/structure/stairs/proc/on_multiz_new(turf/source, dir)
	SIGNAL_HANDLER

	if(dir == UP)
		var/turf/simulated/openspace/T = get_step_multiz(get_turf(src), UP)
		if(T && !istype(T))
			T.ChangeTurf(/turf/simulated/openspace)

/obj/structure/stairs/intercept_zImpact(list/falling_movables, levels = 1)
	. = ..()
	if(levels == 1 && isTerminator()) // Stairs won't save you from a steep fall.
		. |= FALL_INTERCEPTED | FALL_NO_MESSAGE | FALL_RETAIN_PULL

/obj/structure/stairs/proc/isTerminator() //If this is the last stair in a chain and should move mobs up
	if(terminator_mode != STAIR_TERMINATOR_AUTOMATIC)
		return (terminator_mode == STAIR_TERMINATOR_YES)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	var/turf/them = get_step(T, dir)
	if(!them)
		return FALSE
	for(var/obj/structure/stairs/S in them)
		if(S.dir == dir)
			return FALSE
	return TRUE

/obj/structure/stairs_frame
	name = "stairs frame"
	desc = "Everything you need to call something a staircase, aside from the stuff you actually step on."
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs_frame"
	density = FALSE
	anchored = FALSE
	/// What type of stack will this drop on deconstruction?
	var/frame_stack = /obj/item/stack/rods
	/// How much of frame_stack should this drop on deconstruction?
	var/frame_stack_amount = 10

/obj/structure/stairs_frame/wood
	name = "wooden stairs frame"
	desc = "Everything you need to build a staircase, minus the actual stairs, this one is made of wood."
	frame_stack = /obj/item/stack/sheet/wood

/obj/structure/stairs_frame/AltClick(mob/user)
	if(!Adjacent(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(anchored)
		to_chat(user, "It is fastened to the floor!")
		return
	add_fingerprint(usr)
	setDir(turn(dir, 90))


/obj/structure/stairs_frame/examine(mob/living/carbon/human/user)
	. = ..()
	if(anchored)
		. += span_notice("The frame is anchored and can be made into proper stairs with 10 sheets of material.")
	else
		. += span_notice("The frame will need to be secured with a wrench before it can be completed.")

/obj/structure/stairs_frame/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user, span_notice("You start securing stairs frame."))
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return TRUE
	if(anchored)
		set_anchored(FALSE)
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		return TRUE
	set_anchored(TRUE)
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	return TRUE

/obj/structure/stairs_frame/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user, span_notice("You start disassembling [src]..."))
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return TRUE
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	deconstruct(TRUE)
	return TRUE

/obj/structure/stairs_frame/deconstruct(disassembled = TRUE)
	new frame_stack(get_turf(src), frame_stack_amount)
	qdel(src)


/obj/structure/stairs_frame/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	var/is_metal = istype(I, /obj/item/stack/sheet/metal)
	if(is_metal || istype(I, /obj/item/stack/sheet/wood))
		add_fingerprint(user)
		var/obj/item/stack/sheet/sheet = I
		if(!anchored)
			to_chat(user, span_warning("You should secure the frame first!"))
			return ATTACK_CHAIN_PROCEED
		if(sheet.get_amount() < 10)
			to_chat(user, span_warning("You need at least ten [sheet.name] to do this!"))
			return ATTACK_CHAIN_PROCEED
		if(locate(/obj/structure/stairs) in loc)
			to_chat(user, span_warning("There's already stairs built here!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You start to add the [sheet.name] to [src]..."))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		if(!do_after(user, 10 SECONDS, src, category = DA_CAT_TOOL) || (locate(/obj/structure/stairs) in loc) || QDELETED(sheet) || !sheet.use(10))
			return ATTACK_CHAIN_PROCEED
		var/obj/structure/stairs/new_stairs
		if(is_metal)
			new_stairs = new /obj/structure/stairs(loc)
		else
			new_stairs = new /obj/structure/stairs/wood(loc)
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		transfer_fingerprints_to(new_stairs)
		new_stairs.add_fingerprint(user)
		new_stairs.setDir(dir)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


#undef STAIR_TERMINATOR_AUTOMATIC
#undef STAIR_TERMINATOR_NO
#undef STAIR_TERMINATOR_YES
