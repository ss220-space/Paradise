//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	max_integrity = 120
	var/image/nest_overlay
	comfort = 0
	obj_flags = NODECONSTRUCT
	var/ghost_timer

/obj/structure/bed/nest/Initialize(mapload)
	. = ..()
	nest_overlay = image('icons/mob/alien.dmi', "nestoverlay", layer=MOB_LAYER - 0.2)


/obj/structure/bed/nest/Destroy()
	playsound(get_turf(src), 'sound/creatures/alien/xeno_resin_break.ogg', 80, TRUE)
	. = ..()


/obj/structure/bed/nest/has_prints()
	return FALSE


/obj/structure/bed/nest/user_buckle_mob(mob/living/target, mob/living/user, check_loc = TRUE)
	if(!isliving(target) || target.buckled || !in_range(src, user) || target.loc != loc || user.incapacitated())
		return FALSE

	if(target.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		to_chat(user, span_noticealien("[target]'s linkage with the hive prevents you from securing them into [src]."))
		return FALSE

	if(!user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		to_chat(user, span_noticealien("Your lack of linkage to the hive prevents you from buckling [target] into [src]."))
		return FALSE

	if(has_buckled_mobs())
		unbuckle_all_mobs()

	. = buckle_mob(target)
	if(.)
		target.visible_message(
			span_notice("[user] secretes a thick vile goo, securing [target] into [src]!"),
			span_userdanger("[user] drenches you in a foul-smelling resin, trapping you in [src]!"),
			span_italics("You hear squelching..."),
		)
		if(isalien(user))
			ghost_timer = addtimer(CALLBACK(src, PROC_REF(ghost_check)), 15 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)


/obj/structure/bed/nest/user_unbuckle_mob(mob/living/target, mob/living/user)
	if(user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		return unbuckle_mob(target)

	if(target != user)
		target.visible_message(
			span_notice("[user] pulls [target] free from the sticky nest!"),
			span_notice("[user.name] pulls you free from the gelatinous resin."),
			span_italics("You hear squelching..."),
		)
	else
		target.visible_message(
			span_warning("[target] struggles to break free from the gelatinous resin!"),
			span_warning("You struggle to break free from the gelatinous resin... (Stay still for two minutes.)"),
			span_italics("You hear squelching..."),
		)
		if(!do_after(target, 2 MINUTES, src))
			if(target?.buckled)
				to_chat(target, span_warning("You fail to escape [src]!"))
			return
		if(!target.buckled)
			return
		target.visible_message(
			span_warning("[target] breaks free from the gelatinous resin!"),
			span_notice("You break free from the gelatinous resin!"),
			span_italics("You hear squelching..."),
		)

	return unbuckle_mob(target)


/obj/structure/bed/nest/proc/ghost_check()
	if(!length(buckled_mobs))
		return
	for(var/mob/living/carbon/human/buckled_mob in buckled_mobs)
		var/obj/item/clothing/mask/facehugger/hugger_mask = buckled_mob.wear_mask
		if(istype(hugger_mask) && !hugger_mask.sterile && (locate(/obj/item/organ/internal/body_egg/alien_embryo) in buckled_mob.internal_organs))
			buckled_mob.throw_alert(ALERT_GHOST_NEST, /obj/screen/alert/ghost)
			to_chat(buckled_mob, span_ghostalert("You may now ghost, you keep respawnability in this state. You will be alerted when you're removed from the nest."))


/obj/structure/bed/nest/post_buckle_mob(mob/living/target)
	ADD_TRAIT(target, TRAIT_HANDS_BLOCKED, type)
	target.pixel_y = 0
	target.pixel_x = initial(target.pixel_x) + 2
	target.layer = BELOW_MOB_LAYER
	add_overlay(nest_overlay)


/obj/structure/bed/nest/post_unbuckle_mob(mob/living/target)
	REMOVE_TRAIT(target, TRAIT_HANDS_BLOCKED, type)
	target.pixel_x = target.get_standard_pixel_x_offset(target.lying_angle)
	target.pixel_y = target.get_standard_pixel_y_offset(target.lying_angle)
	target.layer = initial(target.layer)
	cut_overlay(nest_overlay)
	deltimer(ghost_timer)
	target.clear_alert(ALERT_GHOST_NEST)
	target.notify_ghost_cloning("You have been unbuckled from an alien nest! Click that alert to re-enter your body.", source = src)


/obj/structure/bed/nest/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/bed/nest/attack_alien(mob/living/carbon/alien/user)
	if(user.a_intent != INTENT_HARM)
		return attack_hand(user)
	else
		return ..()

/obj/structure/bed/nest/prevents_buckled_mobs_attacking()
	return TRUE
