/obj/structure/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/obj/fence.dmi'
	icon_state = "railing"
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW|PASSFENCE
	obj_flags = BLOCKS_CONSTRUCTION_DIR
	climbable = TRUE
	layer = ABOVE_MOB_LAYER
	var/currently_climbed = FALSE
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


/obj/structure/railing/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	if(. || mover.throwing || isprojectile(mover))
		return TRUE
	var/mob/mob_mover = mover
	if(istype(mob_mover) && mob_mover.flying)
		return TRUE
	if(border_dir == dir)
		return !density
	return TRUE


/obj/structure/railing/CanPathfindPass(obj/item/card/id/ID, to_dir, caller, no_id = FALSE)
	if(!(to_dir & dir))
		return TRUE
	return ..()


/obj/structure/railing/CanExit(atom/movable/mover, moving_direction)
	. = ..()
	if(!density)
		return TRUE
	if(checkpass(mover, PASSFENCE))
		return TRUE
	if(mover.throwing)
		return TRUE
	if(isprojectile(mover))
		return TRUE
	var/mob/mob_mover = mover
	if(istype(mob_mover) && mob_mover.flying)
		return TRUE
	if(mover.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return TRUE
	if(currently_climbed)
		return TRUE
	if(dir == moving_direction)
		return FALSE


/obj/structure/railing/do_climb(mob/living/user)
	var/initial_mob_loc = get_turf(user)
	. = ..()
	if(.)
		currently_climbed = TRUE
		if(initial_mob_loc != get_turf(src)) // If we are on the railing, we want to move in the same dir as the railing. Otherwise we get put on the railing
			currently_climbed = FALSE
			return
		user.Move(get_step(user, dir), TRUE)
		currently_climbed = FALSE

/obj/structure/railing/proc/can_be_rotated(mob/user)
	if(anchored)
		to_chat(user, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE

	var/target_dir = turn(dir, -45)
	if(!valid_build_direction(loc, target_dir))	//Expanded to include rails, as well!
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
