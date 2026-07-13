/obj/item/flashlight/lantern/heretic
	name = "burning lantern"
	desc = "Странный фонарь, на который больно смотреть, даже когда он погашен."
	light_power = 3
	light_color = "#e8ff66"
	w_class = WEIGHT_CLASS_NORMAL
	ignore_base_color = TRUE
	heat = 2400
	color = list(
		0, 1, 0, 0,
		0, 1, 1, 0,
		0, 1.5, 0, 0,
		0, 0, 0, 0.5,
		0, -0.25, -0.25, 0,
	)
	var/list/effect_cds
	var/list/tick_counts


/obj/item/flashlight/lantern/heretic/get_ru_names()
	return alist(
		NOMINATIVE = "пылающий фонарь",
		GENITIVE = "пылающего фонаря",
		DATIVE = "пылающему фонарю",
		ACCUSATIVE = "пылающий фонарь",
		INSTRUMENTAL = "пылающим фонарём",
		PREPOSITIONAL = "пылающем фонаре",
	)


/obj/item/flashlight/lantern/heretic/set_light_on(new_value)
	. = ..()
	if(isnull(.))
		return
	var/atom/message_loc = isturf(loc) ? src : loc
	if(new_value)
		START_PROCESSING(SSobj, src)
		add_filter("lantern_pulse", 1, list("type" = "outline", "color" = "#0b8000", "size" = 1))
		apply_wibbly_filters(src)
		w_class = WEIGHT_CLASS_BULKY
		message_loc.visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] вспыхивает, отбрасывая вокруг жуткие тени."))
	else
		STOP_PROCESSING(SSobj, src)
		remove_filter("lantern_pulse")
		remove_wibbly_filters(src)
		w_class = WEIGHT_CLASS_NORMAL
		message_loc.visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] гаснет, и тени отступают."))


/obj/item/flashlight/lantern/heretic/equipped(mob/user, slot, initial)
	. = ..()
	if(!light_on)
		return
	remove_wibbly_filters(src)
	apply_wibbly_filters(src)


/obj/item/flashlight/lantern/heretic/dropped(mob/user, silent)
	. = ..()
	if(!light_on)
		return
	remove_wibbly_filters(src)
	apply_wibbly_filters(src)


/obj/item/flashlight/lantern/heretic/Destroy()
	STOP_PROCESSING(SSobj, src)
	LAZYNULL(effect_cds)
	LAZYNULL(tick_counts)
	return ..()


/obj/item/flashlight/lantern/heretic/process(seconds_per_tick)
	if(!isturf(loc) && !ismob(loc))
		return

	var/turf/scorched_turf = get_turf(src)
	scorched_turf?.hotspot_expose(heat, 5)
	effect_pulse(isturf(loc) ? src : loc)


/obj/item/flashlight/lantern/heretic/proc/effect_pulse(atom/center = src)
	var/list/affected_uids = list()
	for(var/mob/living/seer in viewers(light_range - 1, center))
		try_effect_pulse(seer, center)
		affected_uids += seer.UID()
	if(!tick_counts)
		return
	for(var/tick_uid in tick_counts - affected_uids)
		LAZYSET(tick_counts, tick_uid, LAZYACCESS(tick_counts, tick_uid) - 1)
		if(LAZYACCESS(tick_counts, tick_uid) <= 0)
			LAZYREMOVE(tick_counts, tick_uid)


/obj/item/flashlight/lantern/heretic/proc/try_effect_pulse(mob/living/seer, atom/center)
	if(prob(33))
		return
	var/seer_uid = seer.UID()
	if(LAZYACCESS(effect_cds, seer_uid) >= world.time)
		return

	var/tick_count = LAZYACCESS(tick_counts, seer_uid)
	var/seer_eye_prot = seer.check_eye_prot()
	if(seer_eye_prot > FLASH_PROTECTION_WELDER || IS_HERETIC_OR_MONSTER(seer))
		if(tick_count - 1 <= 0)
			LAZYREMOVE(tick_counts, seer_uid)
		else
			LAZYSET(tick_counts, seer_uid, tick_count - 1)
		return

	var/turf/seer_turf = get_turf(seer)
	if(!isnull(seer_turf))
		var/list/datum/light_source/other_lights = list()
		for(var/datum/lighting_corner/corner in list(seer_turf.lighting_corner_NE, seer_turf.lighting_corner_SE, seer_turf.lighting_corner_SW, seer_turf.lighting_corner_NW))
			if(!corner.affecting)
				continue
			other_lights |= corner.affecting
		var/total_power = 0
		for(var/datum/light_source/light as anything in other_lights)
			if(istype(light.source_atom, /obj/effect/dummy/lighting_obj/moblight))
				continue
			total_power += light.light_power
		seer_eye_prot += max(0, round(total_power / 3))

	LAZYSET(effect_cds, seer_uid, world.time + 5 SECONDS)
	LAZYSET(tick_counts, seer_uid, tick_count + 1)
	var/seer_stam = seer.getStaminaLoss()
	var/source_string = (src == center) ? declent_ru(GENITIVE) : "[declent_ru(GENITIVE)] в руках [center.declent_ru(GENITIVE)]"
	switch(seer_eye_prot)
		if(FLASH_PROTECTION_WELDER + 1 to INFINITY)
			to_chat(seer, span_notice("Из [source_string] вырывается яркая вспышка света."))
			return

		if(FLASH_PROTECTION_WELDER)
			to_chat(seer, span_danger("Из [source_string] вырывается яркая вспышка света, заставляя вас вздрогнуть."))
			seer.adjustOrganLoss(INTERNAL_ORGAN_EYES, 3, maximum = 30)

		if(FLASH_PROTECTION_FLASH)
			to_chat(seer, span_danger("Из [source_string] вырывается яркая вспышка света, заставляя вас вздрогнуть."))
			seer.adjustOrganLoss(INTERNAL_ORGAN_EYES, 4, maximum = 40)
			seer.AdjustEyeBlurry(2 SECONDS)
			if(tick_count > 2 && (seer_stam < 60 || (tick_count > 8 && seer_stam < 100)))
				seer.adjustStaminaLoss(10)
			if(tick_count > 3)
				seer.AdjustConfused(2 SECONDS)

		if(FLASH_PROTECTION_NONE)
			to_chat(seer, span_danger("Яркая вспышка света из [source_string] на мгновение ослепляет вас!"))
			seer.adjustOrganLoss(INTERNAL_ORGAN_EYES, 5, maximum = 40)
			seer.AdjustEyeBlind(1 SECONDS)
			seer.AdjustEyeBlurry(4 SECONDS)
			if(tick_count > 2 && (seer_stam < 60 || (tick_count > 8 && seer_stam < 100)))
				seer.adjustStaminaLoss(10)
			if(tick_count > 3)
				seer.AdjustConfused(4 SECONDS)

		if(FLASH_PROTECTION_SENSITIVE)
			to_chat(seer, span_danger("Яркая вспышка света из [source_string] ослепляет вас!"))
			seer.adjustOrganLoss(INTERNAL_ORGAN_EYES, 8, maximum = 40)
			seer.AdjustEyeBlind(2 SECONDS)
			seer.AdjustEyeBlurry(8 SECONDS)
			if(tick_count > 1 && (seer_stam < 80 || (tick_count > 6 && seer_stam < 120)))
				seer.adjustStaminaLoss(10)
			if(tick_count > 2)
				seer.AdjustConfused(tick_count > 3 ? 8 SECONDS : 4 SECONDS)

		if(-INFINITY to FLASH_PROTECTION_SENSITIVE - 1)
			to_chat(seer, span_danger("Яркая вспышка света из [source_string] ослепляет вас!"))
			seer.adjustOrganLoss(INTERNAL_ORGAN_EYES, 15, maximum = 40)
			seer.AdjustEyeBlind(4 SECONDS)
			seer.AdjustEyeBlurry(12 SECONDS)
			if(seer_stam < 80 || (tick_count > 4 && seer_stam < 120))
				seer.adjustStaminaLoss(30)
			if(tick_count > 1)
				seer.AdjustConfused(tick_count > 2 ? 12 SECONDS : 6 SECONDS)

	if(!iscarbon(seer))
		return

	var/mob/living/carbon/carbon_seer = seer
	if(tick_count > 6 && prob(66) && seer_eye_prot <= FLASH_PROTECTION_NONE && carbon_seer.is_blind())
		to_chat(carbon_seer, span_hypnophrase(pick_list(HERETIC_INFLUENCE_FILE, "hypnosis")))
		carbon_seer.AdjustHallucinate(30 SECONDS, bound_upper = 60 SECONDS)
