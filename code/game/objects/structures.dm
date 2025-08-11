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
		armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	if(creates_cover && isturf(loc))
		ADD_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/obj/structure/Destroy(force)
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
	if(user.has_status_effect(STATUS_EFFECT_LEANING))
		return FALSE
	var/blocking_object = density_check(user)
	if(blocking_object)
		to_chat(user, span_warning("Вы не можете забраться на [declent_ru(ACCUSATIVE)] - путь блокирует [blocking_object]!"))
		return FALSE

	var/turf/T = src.loc
	if(!T || !istype(T))
		return FALSE

	user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] начина[pluralize_ru(user.gender,"ет","ют")] забираться на [declent_ru(ACCUSATIVE)]!"))
	climber = user
	if(!do_after(user, 5 SECONDS, src))
		climber = null
		return FALSE

	if(!can_touch(user) || !climbable)
		climber = null
		return FALSE

	user.forceMove(get_turf(src))
	if(get_turf(user) == get_turf(src))
		user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] забира[pluralize_ru(user.gender,"ет","ют")]ся на [declent_ru(ACCUSATIVE)]!"))

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

	for(var/mob/living/mob in get_turf(src))

		if(mob.body_position == LYING_DOWN)
			continue //No spamming this on people.

		mob.Weaken(10 SECONDS)
		to_chat(mob, span_warning("Вы теряете равновесие, когда [declent_ru(NOMINATIVE)] двигается под вами!"))

		if(prob(25))

			var/damage = rand(15,30)
			var/mob/living/carbon/human/human = mob
			if(!istype(human))
				to_chat(mob, span_warning("Вы тяжело приземляетесь!"))
				mob.adjustBruteLoss(damage)
				continue

			var/obj/item/organ/external/affecting

			switch(pick(list("ankle","wrist","head","knee","elbow")))
				if("ankle")
					affecting = human.get_organ(pick(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
				if("knee")
					affecting = human.get_organ(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
				if("wrist")
					affecting = human.get_organ(pick(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
				if("elbow")
					affecting = human.get_organ(pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
				if("head")
					affecting = human.get_organ(BODY_ZONE_HEAD)

			if(affecting)
				to_chat(human, span_warning("Вы тяжело приземляетесь на [GLOB.body_zone[affecting.limb_zone][ACCUSATIVE]]!"))
				human.apply_damage(damage, def_zone = affecting)
				if(affecting?.parent)
					affecting.parent.add_autopsy_data("Misadventure", damage)
			else
				to_chat(human, span_warning("Вы тяжело приземляетесь!"))
				human.adjustBruteLoss(damage)

			human.UpdateDamageIcon()
	return TRUE

/obj/structure/proc/can_touch(mob/living/user)
	if(!istype(user))
		return FALSE
	if(!Adjacent(user))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || user.buckled)
		to_chat(user, span_notice("Для этого нужны свободные руки и ноги."))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(issilicon(user))
		to_chat(user, span_notice("Для этого нужны свободные руки."))
		return FALSE
	return TRUE

/obj/structure/proc/get_climb_text()
	return span_notice("Вы можете нажать [span_bold("ЛКМ и перетащить")] себя на [declent_ru(GENITIVE)], чтобы после небольшой задержки взобраться на [genderize_ru(gender, "него", "неё", "него", "них")].")

/obj/structure/examine(mob/user)
	. = ..()
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			. += span_warning("Оно горит!")
		if(broken)
			. += span_notice("Кажется, оно сломанно.")
		var/examine_status = examine_status(user)
		if(examine_status)
			. += examine_status
	if(climbable)
		. += get_climb_text()

/obj/structure/proc/examine_status(mob/user) //An overridable proc, mostly for falsewalls.
	var/healthpercent = (obj_integrity/max_integrity) * 100
	switch(healthpercent)
		if(50 to 99)
			. += span_notice("Выглядит слегка повреждённым.")
		if(25 to 50)
			. += span_notice("Кажется сильно повреждённым.")
		if(0 to 25)
			if(!broken)
				. += span_warning("Оно разваливается на части!")

/obj/structure/proc/prevents_buckled_mobs_attacking()
	return FALSE

/obj/structure/zap_act(power, zap_flags)
	if(zap_flags & ZAP_OBJ_DAMAGE)
		take_damage(power * 5e-4, BURN, ENERGY)
	power -= power * 5e-4 //walls take a lot out of ya
	. = ..()

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
