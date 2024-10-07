/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	max_integrity = 300
	pass_flags_self = PASSSTRUCTURE
	pull_push_slowdown = 1.3
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


/obj/structure/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/atom/old_loc = loc
	. = ..()
	if(!.)
		return .

	if(creates_cover)
		if(isturf(old_loc))
			REMOVE_TRAIT(old_loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
		if(isturf(loc))
			ADD_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))


/obj/structure/has_prints()
	return TRUE

/obj/structure/attack_hand(mob/living/user)
	if(has_prints() && Adjacent(user))
		add_fingerprint(user)
	return ..()


/obj/structure/attackby(obj/item/I, mob/user, params)
	if(has_prints() && !(istype(I, /obj/item/detective_scanner)))
		add_fingerprint(user)
	return ..()


/obj/structure/proc/climb_on()

	set name = "Climb structure"
	set desc = "Climbs onto a structure."
	set src in oview(1)

	do_climb(usr)

/obj/structure/MouseDrop_T(atom/movable/dropping, mob/user, params)
	. = ..()
	if(!. && dropping == user)
		do_climb(user)
		return TRUE


/obj/structure/proc/density_check(mob/living/user)
	var/turf/source_turf = get_turf(src)
	if(source_turf.density)
		return source_turf
	var/border_dir = get_dir(src, user)
	for(var/obj/check in (source_turf.contents - src))
		if(check.density)
			if((check.flags & ON_BORDER) && user.loc != loc && border_dir != check.dir)
				continue
			return check
	return null

/obj/structure/proc/do_climb(mob/living/user)
	if(!can_touch(user) || !climbable)
		return FALSE
	var/blocking_object = density_check(user)
	if(blocking_object)
		to_chat(user, "<span class='warning'>You cannot climb [src], as it is blocked by \a [blocking_object]!</span>")
		return FALSE

	var/turf/T = src.loc
	if(!T || !istype(T))
		return FALSE

	user.visible_message("<span class='warning'>[user] starts climbing onto \the [src]!</span>")
	climber = user
	if(!do_after(user, 5 SECONDS, src))
		climber = null
		return FALSE

	if(!can_touch(user) || !climbable)
		climber = null
		return FALSE

	user.forceMove(get_turf(src))
	if(get_turf(user) == get_turf(src))
		user.visible_message("<span class='warning'>[user] climbs onto \the [src]!</span>")

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

	if(LAZYIN(user.active_genes, /datum/dna/gene/disability/clumsy))
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


/obj/structure/proc/structure_shaken()

	for(var/mob/living/M in get_turf(src))

		if(M.body_position == LYING_DOWN)
			return //No spamming this on people.

		M.Weaken(10 SECONDS)
		to_chat(M, "<span class='warning'>You topple as \the [src] moves under you!</span>")

		if(prob(25))

			var/damage = rand(15,30)
			var/mob/living/carbon/human/H = M
			if(!istype(H))
				to_chat(H, "<span class='warning'>You land heavily!</span>")
				M.adjustBruteLoss(damage)
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
				to_chat(M, "<span class='warning'>You land heavily on your [affecting.name]!</span>")
				H.apply_damage(damage, def_zone = affecting)
				if(affecting?.parent)
					affecting.parent.add_autopsy_data("Misadventure", damage)
			else
				to_chat(H, "<span class='warning'>You land heavily!</span>")
				H.adjustBruteLoss(damage)

			H.UpdateDamageIcon()
	return

/obj/structure/proc/can_touch(mob/living/user)
	if(!istype(user))
		return FALSE
	if(!Adjacent(user))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || user.buckled)
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
			. += "<span class='warning'>It's on fire!</span>"
		if(broken)
			. += "<span class='notice'>It appears to be broken.</span>"
		var/examine_status = examine_status(user)
		if(examine_status)
			. += examine_status
	if(climbable)
		. += "<span class='info'>You can <b>Click-Drag</b> someone to [src] to put them on the table after a short delay.</span>"

/obj/structure/proc/examine_status(mob/user) //An overridable proc, mostly for falsewalls.
	var/healthpercent = (obj_integrity/max_integrity) * 100
	switch(healthpercent)
		if(50 to 99)
			. += "It looks slightly damaged."
		if(25 to 50)
			. += "It appears heavily damaged."
		if(0 to 25)
			if(!broken)
				. += "<span class='warning'>It's falling apart!</span>"

/obj/structure/proc/prevents_buckled_mobs_attacking()
	return FALSE


/obj/structure/extinguish_light(force = FALSE)
	if(light_on)
		set_light_on(FALSE)
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
	set_light_on(TRUE)
	name = initial(name)
	desc = initial(desc)
	deltimer(extinguish_timer_id)

