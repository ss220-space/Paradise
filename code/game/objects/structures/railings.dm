/obj/structure/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/obj/fence.dmi'
	icon_state = "railing"
	density = TRUE
	anchored = TRUE
	pass_flags = LETPASSTHROW
	climbable = TRUE
	layer = ABOVE_MOB_LAYER
	var/currently_climbed = FALSE
	var/mover_dir = null
	var/buildstacktype = /obj/item/stack/rods
	var/buildstackamount = 3

/obj/structure/railing/corner //aesthetic corner sharp edges hurt oof ouch
	icon_state = "railing_corner"
	density = FALSE
	climbable = FALSE

/obj/structure/railing/attackby(obj/item/I, mob/living/user, params)
	..()

/obj/structure/railing/welder_act(mob/living/user, obj/item/I)
	if(user.intent != INTENT_HELP)
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
		return
	if(!I.tool_start_check(user, amount = 0))
		return
	to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
	if(I.use_tool(src, user, 40, volume = 50))
		obj_integrity = max_integrity
		to_chat(user, "<span class='notice'>You repair [src].</span>")

/obj/structure/railing/wirecutter_act(mob/living/user, obj/item/I)
	if(anchored)
		return
	to_chat(user, "<span class='warning'>You cut apart the railing.</span>")
	I.play_tool_sound(src, 100)
	deconstruct()
	return TRUE

/obj/structure/railing/deconstruct()
	// If we have materials, and don't have the NOCONSTRUCT flag
	if(buildstacktype && (!(flags & NODECONSTRUCT)))
		var/obj/item/stack/rods/stack = new buildstacktype(loc, buildstackamount)
		transfer_fingerprints_to(stack)
	..()

///Implements behaviour that makes it possible to unanchor the railing.
/obj/structure/railing/wrench_act(mob/living/user, obj/item/I)
	if(flags & NODECONSTRUCT)
		return
	to_chat(user, "<span class='notice'>You begin to [anchored ? "unfasten the railing from":"fasten the railing to"] the floor...</span>")
	if(I.use_tool(src, user, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "fasten the railing to":"unfasten the railing from"] the floor.</span>")
	return TRUE

/obj/structure/railing/corner/CanPass()
	return TRUE


/obj/structure/railing/corner/CanPathfindPass(obj/item/card/id/ID, to_dir, caller, no_id = FALSE)
	return TRUE


/obj/structure/railing/corner/CheckExit()
	return TRUE

/obj/structure/railing/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSFENCE))
		return TRUE
	if(istype(mover, /obj/item/projectile))
		return TRUE
	if(ismob(mover))
		var/mob/M = mover
		if(M.flying)
			return TRUE
	if(mover.throwing)
		return TRUE
	mover_dir = get_dir(loc, target)
	//Due to how the other check is done, it would always return density for ordinal directions no matter what
	if(ordinal_direction_check())
		return FALSE
	if(mover_dir != dir)
		return density
	return FALSE


/obj/structure/railing/CanPathfindPass(obj/item/card/id/ID, to_dir, caller, no_id = FALSE)
	if(to_dir == dir)
		return FALSE
	if(ordinal_direction_check(to_dir))
		return FALSE

	return TRUE


/obj/structure/railing/CheckExit(atom/movable/O, target)
	var/mob/living/M = O
	if(istype(O) && O.checkpass(PASSFENCE))
		return TRUE
	if(istype(O, /obj/item/projectile))
		return TRUE
	if(ismob(O))
		if(M.flying || M.floating)
			return TRUE
	if(O.throwing)
		return TRUE
	if(O.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return TRUE
	if(currently_climbed)
		return TRUE
	mover_dir = get_dir(O.loc, target)
	if(mover_dir == dir)
		return FALSE
	if(ordinal_direction_check())
		return FALSE
	return TRUE

// Checks if the direction the mob is trying to move towards would be blocked by a corner railing
/obj/structure/railing/proc/ordinal_direction_check()
	switch(dir)
		if(NORTHEAST)
			if(mover_dir == NORTH || mover_dir == EAST)
				return TRUE
		if(SOUTHEAST)
			if(mover_dir == SOUTH || mover_dir == EAST)
				return TRUE
		if(NORTHWEST)
			if(mover_dir == NORTH || mover_dir == WEST)
				return TRUE
		if(SOUTHWEST)
			if(mover_dir == SOUTH || mover_dir == WEST)
				return TRUE
	return FALSE

/obj/structure/railing/proc/hopping(mob/living/user)
	if(!istype(user))
		return
	var/delay = user.movement_delay()/2
	sleep(delay)
	animate(user, pixel_z = 10, time = 3, easing = CIRCULAR_EASING|EASE_OUT)
	delay = user.movement_delay()/4
	sleep(delay)
	animate(user, pixel_z = initial(user.pixel_z), time = 3, easing = CIRCULAR_EASING|EASE_OUT)
	if(user.floating)
		user.float(TRUE)

/obj/structure/railing/do_climb(mob/living/user)
	if(!climb_check(user))
		return FALSE
	
	var/initial_mob_loc = get_turf(user)

	user.visible_message("<span class='warning'>[user] starts climbing onto \the [src]!</span>")
	climber = user
	if(!do_after(user, 50, target = src))
		climber = null
		return FALSE

	if(!can_touch(user) || !climbable)
		climber = null
		return FALSE

	user.loc = get_turf(src)
	hopping(user)

	if(get_turf(user) == get_turf(src))
		user.visible_message("<span class='warning'>[user] climbs onto \the [src]!</span>")

	clumse_stuff(climber)

	climber = null

	currently_climbed = TRUE

	if(initial_mob_loc != get_turf(src)) // If we are on the railing, we want to move in the same dir as the railing. Otherwise we get put on the railing
		currently_climbed = FALSE
		return TRUE
	user.loc = get_step(user, dir)
	currently_climbed = FALSE

	return TRUE

/obj/structure/railing/proc/can_be_rotated(mob/user)
	if(anchored)
		to_chat(user, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE

	var/target_dir = turn(dir, -45)

	if(!valid_window_location(loc, target_dir)) //Expanded to include rails, as well!
		to_chat(user, "<span class='warning'>[src] cannot be rotated in that direction!</span>")
		return FALSE
	return TRUE

/obj/structure/railing/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/railing/proc/after_rotation(mob/user)
	add_fingerprint(user)

/obj/structure/railing/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	if(can_be_rotated(user))
		setDir(turn(dir, 45))

/obj/structure/railing/Initialize(mapload) //Only for mappers
	..()
	handle_layer()

/obj/structure/railing/setDir(newdir)
	..()
	handle_layer()

/obj/structure/railing/Move(newloc, direct, movetime)
	. = ..()
	handle_layer()

/obj/structure/railing/proc/handle_layer()
	if(dir == NORTH || dir == NORTHEAST || dir == NORTHWEST)
		layer = BELOW_MOB_LAYER
	else
		layer = ABOVE_MOB_LAYER

/obj/structure/railing/wooden
	name = "Wooden railing"
	desc = "Wooden railing meant to protect idiots like you from falling."
	icon = 'icons/obj/fence.dmi'
	icon_state = "railing_wood"
	resistance_flags = FLAMMABLE
	climbable = TRUE
	can_be_unanchored = 1
	flags = ON_BORDER
	buildstacktype = /obj/item/stack/sheet/wood
	buildstackamount = 5

/obj/structure/railing/wooden/handle_layer()
	if(dir == NORTH)
		layer = LOW_ITEM_LAYER
	else if(dir == SOUTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = HIGH_OBJ_LAYER

/obj/structure/railing/wooden/AltClick(mob/user)
	if(!Adjacent(user))
		return
	if(anchored)
		to_chat(user, "It is fastened to the floor!")
		return
	setDir(turn(dir, 90))
	after_rotation(user)

/obj/structure/railing/wooden/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/structure/railing/wooden/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(flags & NODECONSTRUCT)
		to_chat(user, "<span class='warning'>Try as you might, you can't figure out how to deconstruct [src].</span>")
		return
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return
	deconstruct(TRUE)

/obj/structure/railing/wooden/wirecutter_act(mob/living/user, obj/item/I)
	. = NODECONSTRUCT
	return

/obj/structure/railing/wooden/cornerr
	icon_state = "right_corner_railing_wood"

/obj/structure/railing/wooden/cornerl
	icon_state = "left_corner_railing_wood"

/obj/structure/railing/wooden/endr
	icon_state = "right_end_railing_wood"

/obj/structure/railing/wooden/endl
	icon_state = "left_end_railing_wood"
