/obj/structure/musician/drumkit
	name = "space drum kit"
	desc = "This is a space drum kit. It's a sound that can rock anyone."

	icon = 'icons/obj/musician.dmi'
	icon_state = "drumkit"
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	buckle_lying = 0
	allowed_instrument_ids = "drumkit"

/obj/structure/musician/drumkit/Initialize(mapload)
	. = ..()
	handle_layer()
	handle_offsets()

/obj/structure/musician/drumkit/Move(NewLoc, Dir = 0, movetime)
	. = ..()
	handle_layer()
	handle_offsets()

/obj/structure/musician/drumkit/attack_hand(mob/user)
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

/obj/structure/musician/drumkit/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 40)
	unbuckle_all_mobs()

//APPEARANCE
/obj/structure/musician/drumkit/proc/handle_layer()
	if(dir != NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/musician/drumkit/proc/handle_offsets()
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
/obj/structure/musician/drumkit/is_user_buckle_possible(mob/living/target, mob/user, check_loc = TRUE)
	if(!anchored)
		to_chat(user, span_warning("The musical instrument needs to be anchored to the floor!"))
		return FALSE
	return ..()


/obj/structure/musician/drumkit/post_buckle_mob(mob/living/target)
	handle_offsets()


/obj/structure/musician/drumkit/post_unbuckle_mob(mob/living/target)
	song.stop_playing()
	SStgui.close_uis(src)
	target.pixel_x = 0
	target.pixel_y = 0


/obj/structure/musician/drumkit/examine(mob/user)
	. = ..()
	if(!anchored)
		. += span_info("You can <b>Alt-Click</b> [src] to rotate it.")

/obj/structure/musician/drumkit/AltClick(mob/living/user)
	rotate(user)


/obj/structure/musician/drumkit/proc/rotate(mob/living/user)
	if(user)
		if(isobserver(user))
			if(!CONFIG_GET(flag/ghost_interaction))
				return FALSE
		else if(!isliving(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
			return FALSE

	if(anchored)
		if(user)
			to_chat(user, span_warning("The musical instrument is anchored to the floor!"))
		return FALSE

	setDir(turn(dir, 90))
	handle_layer()
	handle_offsets()
	return TRUE
