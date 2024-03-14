/obj/structure/drumkit
	parent_type = /obj/structure/musician // TODO: Can't edit maps right now due to a freeze, remove and update path when it's done
	name = "space drum kit"
	desc = "This is a space drum kit. It's a sound that can rock anyone."
	
	icon = 'icons/obj/musician.dmi'
	icon_state = "drumkit"
	anchored = TRUE
	density = TRUE
	can_buckle = TRUE
	buckle_lying = FALSE
	allowed_instrument_ids = "drumkit"

/obj/structure/drumkit/unanchored
	anchored = FALSE

/obj/structure/drumkit/Initialize(mapload)
	. = ..()
	handle_layer()
	handle_offsets()

/obj/structure/drumkit/Move(NewLoc, Dir = 0, movetime)
	. = ..()
	handle_layer()
	handle_offsets()

/obj/structure/drumkit/attack_hand(mob/user)
	add_fingerprint(user)
	if(!anchored)
		to_chat(user, span_warning("The musical instrument needs to be anchored to the floor!"))
		return
	if(!has_buckled_mobs())
		to_chat(user, span_warning("You need to sit at a musical instrument."))
		return
	for(var/m in buckled_mobs)
		if(m != user)
			to_chat(user, span_warning("You need to sit at a musical instrument."))
			return
	ui_interact(user)

/obj/structure/drumkit/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 40)
	unbuckle_all_mobs()

//APPEARANCE
/obj/structure/drumkit/proc/handle_layer()
	if(dir != NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/drumkit/proc/handle_offsets()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(dir)
			switch(buckled_mob.dir)
				if(SOUTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 5
				if(WEST)
					buckled_mob.pixel_x = 3
					buckled_mob.pixel_y = 0
				if(NORTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 1
				if(EAST)
					buckled_mob.pixel_x = -2
					buckled_mob.pixel_y = 0

//BUCKLE HOOKS
/obj/structure/drumkit/unbuckle_mob(mob/living/buckled_mob, force = FALSE)
	song.stop_playing()
	SStgui.close_uis(src)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	. = ..()

/obj/structure/drumkit/user_buckle_mob(mob/living/M, mob/user)
	if(!anchored)
		to_chat(user, span_warning("The musical instrument needs to be anchored to the floor!"))
		return
	if(user.incapacitated())
		return
	for(var/atom/movable/A in get_turf(src))
		if(A.density)
			if(A != src && A != M)
				return
	M.forceMove(get_turf(src))
	..()
	handle_offsets()
	
/obj/structure/drumkit/examine(mob/user)
	. = ..()
	if(!anchored)
		. += span_info("You can <b>Alt-Click</b> [src] to rotate it.")

/obj/structure/drumkit/AltClick(mob/living/user)
	rotate(user)
	
/obj/structure/drumkit/proc/rotate(mob/living/user)
	if(anchored)
		to_chat(user, span_warning("The musical instrument is anchored to the floor!"))
		return FALSE
	if(user)
		if(isobserver(user))
			if(!CONFIG_GET(flag/ghost_interaction))
				return FALSE
		else if(!isliving(user) || user.incapacitated() || !Adjacent(user))
			return FALSE

	setDir(turn(dir, 90))
	handle_layer()
	handle_offsets()
	return TRUE