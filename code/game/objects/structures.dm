/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	max_integrity = 300
	pull_push_speed_modifier = 1.2
	var/climbable
	/// Determines if a structure adds the TRAIT_TURF_COVERED to its turf.
	var/creates_cover = FALSE
	var/mob/living/climber
	var/broken = FALSE
	/// Amount of timer ticks that an extinguished structure has been lit up
	var/light_process = 0
	var/extinguish_timer_id

/obj/structure/New()
	..()
	if(smooth)
		if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
			queue_smooth(src)
			queue_smooth_neighbors(src)
		icon_state = ""
	if(climbable)
		verbs += /obj/structure/proc/climb_on
	if(SSticker)
		GLOB.cameranet.updateVisibility(src)

/obj/structure/Initialize(mapload)
	if(!armor)
		armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	if(creates_cover && isturf(loc))
		ADD_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/obj/structure/Destroy()
	if(climbable)
		structure_gone(src)
	if(SSticker)
		GLOB.cameranet.updateVisibility(src)
	if(smooth)
		var/turf/T = get_turf(src)
		spawn(0)
			queue_smooth_neighbors(T)
	if(creates_cover && isturf(loc))
		REMOVE_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/Move()
	var/atom/old = loc
	if(!..())
		return FALSE

	if(climbable)
		structure_gone(old)

	if(creates_cover)
		if(isturf(old))
			REMOVE_TRAIT(old, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
		if(isturf(loc))
			ADD_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
	return TRUE

/obj/structure/has_prints()
	return TRUE

/obj/structure/attack_hand(mob/living/user)
	if(has_prints() && Adjacent(user))
		add_fingerprint(user)
	return ..()

/obj/structure/attackby(obj/item/P, mob/user, params)
	if(has_prints() && Adjacent(user) && !(istype(P, /obj/item/detective_scanner)))
		add_fingerprint(user)
	return ..()

/obj/structure/proc/climb_on()

	set name = "Climb structure"
	set desc = "Climbs onto a structure."
	set category = null
	set src in oview(1)

	do_climb(usr)

/obj/structure/proc/animate_jumping_off(mob/living/user)
	if(!user.flying && user.mob_has_gravity())
		var/delay = user.movement_delay()/4
		sleep(delay)
		animate(user, pixel_z = initial(user.pixel_z), time = 3, easing = BACK_EASING|EASE_IN)

/obj/structure/proc/animate_climb(mob/living/user)
	if(!istype(user))
		return
	if(!user.checkpass(PASSTABLE) && !user.flying && user.mob_size > MOB_SIZE_SMALL)
		var/delay = user.movement_delay()/2
		sleep(delay)
		animate(user, pixel_z = 16, time = 1, easing = LINEAR_EASING)
		if(user.floating)
			user.float(TRUE)

/obj/structure/Uncrossed(atom/movable/mover)
	. = ..()
	if(!istype(mover, /mob/living))
		return
	if(climbable)
		var/turf/T = get_turf(mover)
		var/obj/structure/other_structure = locate(/obj/structure) in T
		if(!other_structure?.climbable)
			animate_jumping_off(mover)

/obj/structure/MouseDrop_T(atom/movable/dropping, mob/user, params)
	. = ..()
	if(!. && dropping == user)
		do_climb(user)
		return TRUE

/obj/structure/proc/density_check()
	for(var/obj/O in orange(0, src))
		if(O.density && !istype(O, /obj/machinery/door/window)) //Ignores windoors, as those already block climbing, otherwise a windoor on the opposite side of a table would prevent climbing.
			return O
	var/turf/T = get_turf(src)
	if(T.density)
		return T
	return null

/obj/structure/proc/climb_check(mob/living/user)
	if(user.mob_size == MOB_SIZE_SMALL)
		return FALSE
	if(user.flying)
		return FALSE
	if(!can_touch(user) || !climbable)
		return FALSE
	var/blocking_object = density_check()
	if(blocking_object)
		to_chat(user, span_warning("You cannot climb [src], as it is blocked by \a [blocking_object]!"))
		return FALSE
	var/turf/T = src.loc
	if(!T || !istype(T))
		return FALSE

	return TRUE

/obj/structure/proc/do_climb(mob/living/user)
	if(!climb_check(user))
		return FALSE

	user.visible_message(span_warning("[user] starts climbing onto \the [src]!"))
	climber = user
	if(!do_after(user, 50, target = src))
		climber = null
		return FALSE

	if(!can_touch(user) || !climbable)
		climber = null
		return FALSE

	user.loc = get_turf(src)
	animate_climb(user)

	if(get_turf(user) == get_turf(src))
		user.visible_message(span_warning("[user] climbs onto \the [src]!"))

	clumse_stuff(climber)
	climber = null

	return TRUE

/obj/structure/proc/clumse_stuff(var/mob/living/user)
	if(!user)
		return
	var/slopchance = 80 //default for all human-sized livings
	var/max_throws_count = 15 //for lag prevention
	var/force_mult = 0.1 //коэффицент уменьшения урона при сбрасывании предмета

	switch(user.mob_size)
		if(MOB_SIZE_LARGE) slopchance = 100
		if(MOB_SIZE_SMALL) slopchance = 20
		if(MOB_SIZE_TINY) slopchance = 10

	if(/datum/dna/gene/disability/clumsy in user.active_genes)
		slopchance += 20
	if(user.mind?.miming)
		slopchance -= 30

	slopchance = clamp(slopchance, 1, 100)

	var/list/thrownatoms = list()

	for(var/turf/T in range(0, src)) //Preventing from rotating stuff in an inventory
		for(var/atom/movable/AM in T)
			if(!AM.anchored && !isliving(AM))
				if(prob(slopchance))
					thrownatoms += AM
					if(thrownatoms.len >= max_throws_count)
						break

	var/atom/throwtarget
	for(var/obj/item/AM in thrownatoms)
		AM.force *= force_mult
		AM.throwforce *= force_mult //no killing using shards :lul:
		throwtarget = get_edge_target_turf(user, get_dir(src, get_step_away(AM, src)))
		AM.throw_at(target = throwtarget, range = 1, speed = 1)
		AM.pixel_x = rand(-6, 6)
		AM.pixel_y = rand(0, 10)
		AM.force /= force_mult
		AM.throwforce /= force_mult

/obj/structure/proc/get_fall_damage(mob/living/L)
	if(prob(25))

		var/damage = rand(15,30)
		var/mob/living/carbon/human/H = L
		if(!istype(H))
			to_chat(H, span_warning("You land heavily!"))
			L.adjustBruteLoss(damage)
			return

		var/obj/item/organ/external/affecting

		switch(pick(list("ankle","wrist","head","knee","elbow")))
			if("ankle")
				affecting = H.get_organ(pick(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
			if("knee")
				affecting = H.get_organ(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
			if("wrist")
				affecting = H.get_organ(pick(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
			if("elbow")
				affecting = H.get_organ(pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			if("head")
				affecting = H.get_organ(BODY_ZONE_HEAD)

		if(affecting)
			to_chat(L, span_warning("You land heavily on your [affecting.name]!"))
			affecting.receive_damage(damage, 0)
			if(affecting.parent)
				affecting.parent.add_autopsy_data("Misadventure", damage)
		else
			to_chat(H, span_warning("You land heavily!"))
			H.adjustBruteLoss(damage)

		H.UpdateDamageIcon()

/obj/structure/proc/structure_gone(atom/location)
	for(var/mob/living/carbon/human/H in get_turf(location))
		H.pixel_z = initial(H.pixel_z)
		if(H.lying || H.mob_size <= MOB_SIZE_SMALL)
			continue
		to_chat(H, span_warning("You stop feeling \the [src] beneath your feet."))
		if(H.m_intent == MOVE_INTENT_WALK)
			H.Weaken(3 SECONDS)
		if(H.m_intent == MOVE_INTENT_RUN)
			H.Weaken(10 SECONDS)
			get_fall_damage(H)

/obj/structure/proc/structure_shaken()

	for(var/mob/living/M in get_turf(src))

		if(M.lying)
			continue //No spamming this on people.

		M.Weaken(10 SECONDS)
		to_chat(M, span_warning("You topple as \the [src] moves under you!"))

		get_fall_damage(M)

	return

/obj/structure/proc/can_touch(mob/living/user)
	if(!istype(user))
		return FALSE
	if(!Adjacent(user))
		return FALSE
	if(user.restrained() || user.buckled)
		to_chat(user, span_notice("You need your hands and legs free for this."))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(issilicon(user))
		to_chat(user, span_notice("You need hands for this."))
		return FALSE
	return TRUE

/obj/structure/examine(mob/user)
	. = ..()
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			. += span_warning("It's on fire!")
		if(broken)
			. += span_notice("It appears to be broken.")
		var/examine_status = examine_status(user)
		if(examine_status)
			. += examine_status
	if(climbable)
		. += span_info("You can <b>Click-Drag</b> someone to [src] to put them on the structure after a short delay.")

/obj/structure/proc/examine_status(mob/user) //An overridable proc, mostly for falsewalls.
	var/healthpercent = (obj_integrity/max_integrity) * 100
	switch(healthpercent)
		if(50 to 99)
			. += "It looks slightly damaged."
		if(25 to 50)
			. += "It appears heavily damaged."
		if(0 to 25)
			if(!broken)
				. += span_warning("It's falling apart!")

/obj/structure/proc/prevents_buckled_mobs_attacking()
	return FALSE


/obj/structure/extinguish_light(force = FALSE)
	if(light_range)
		light_power = 0
		light_range = 0
		update_light()
		name = "dimmed [name]"
		desc = "Something shadowy moves to cover the object. Perhaps shining a light will force it to clear?"
		extinguish_timer_id = addtimer(CALLBACK(src, PROC_REF(extinguish_light_check)), 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_LOOP|TIMER_DELETE_ME|TIMER_STOPPABLE)


/obj/structure/proc/extinguish_light_check()
	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return
	if(source_turf.get_lumcount() > 0.2)
		light_process++
		if(light_process > 3)
			reset_light()
		return
	light_process = 0


/obj/structure/proc/reset_light()
	light_process = 0
	light_power = initial(light_power)
	light_range = initial(light_range)
	update_light()
	name = initial(name)
	desc = initial(desc)
	deltimer(extinguish_timer_id)

