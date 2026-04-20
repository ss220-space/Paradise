//Ash storms happen frequently on lavaland. They heavily obscure vision, and cause high fire damage to anyone caught outside.
/datum/weather/ash_storm
	name = "ash storm"
	desc = "Мощная атмосферная буря поднимает пепел с поверхности планеты, обрушивая его на землю и нанося сильные ожоги незащищённым существам."

	telegraph_message = span_boldwarning_alt("Глухой рокот нарастает вдали, превращаясь в оглушительный рёв. Горизонт застилают мрачные волны пепла. Ищите убежище!")
	telegraph_overlay = "light_ash"

	weather_message = span_userdanger_alt("<i>Раскалённый пепел обжигает кожу! Воздух наполняется гарью — прячьтесь в убежище!</i>")
	weather_duration_lower = 60 SECONDS
	weather_duration_upper = 120 SECONDS
	weather_overlay = "ash_storm"

	end_message = span_boldannounceic_alt("Буря отступила, оставив после себя лишь опалённую тишину. Можно выходить...")
	end_overlay = "light_ash"

	area_type = /area/lavaland/surface/outdoors
	target_trait = ZTRAIT_ASHSTORM

	immunity_type = TRAIT_ASHSTORM_IMMUNE

	probability = 90

	barometer_predictable = TRUE

	var/list/weak_sounds = list()
	var/list/strong_sounds = list()

/datum/weather/ash_storm/proc/is_shuttle_docked(shuttleId, dockId)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/obj/docking_port/stationary/S = M.get_docked()

	return S.id == dockId

/datum/weather/ash_storm/proc/update_eligible_areas()
	var/list/eligible_areas = list()
	for(var/z in impacted_z_levels)
		eligible_areas += SSmapping.areas_in_z["[z]"]

	for(var/i in 1 to length(eligible_areas))
		var/area/place = eligible_areas[i]
		if(istype(place, /area/shuttle)) // Don't play storm audio to shuttles that are not at lavaland
			continue
		if(place.outdoors)
			weak_sounds[place] = /datum/looping_sound/weak_outside_ashstorm
			strong_sounds[place] = /datum/looping_sound/active_outside_ashstorm
		else
			weak_sounds[place] = /datum/looping_sound/weak_inside_ashstorm
			strong_sounds[place] = /datum/looping_sound/active_inside_ashstorm

/datum/weather/ash_storm/proc/update_audio(next_stage)
	switch(next_stage)
		if(STARTUP_STAGE)
			GLOB.ash_storm_sounds += weak_sounds

		if(MAIN_STAGE)
			GLOB.ash_storm_sounds -= weak_sounds
			GLOB.ash_storm_sounds += strong_sounds

		if(WIND_DOWN_STAGE)
			GLOB.ash_storm_sounds -= strong_sounds
			GLOB.ash_storm_sounds += weak_sounds

		if(END_STAGE)
			GLOB.ash_storm_sounds -= weak_sounds

/datum/weather/ash_storm/telegraph()
	. = ..()
	if(.)
		update_eligible_areas()
		update_audio(STARTUP_STAGE)

/datum/weather/ash_storm/start()
	update_audio(MAIN_STAGE)
	. = ..()

/datum/weather/ash_storm/wind_down()
	update_audio(WIND_DOWN_STAGE)
	. = ..()

/datum/weather/ash_storm/end()
	update_audio(END_STAGE)
	. = ..()
	for(var/turf/simulated/floor/plating/asteroid/basalt/basalt as anything in GLOB.dug_up_basalt)
		if(!(basalt.loc in impacted_areas) || !(basalt.z in impacted_z_levels))
			continue
		basalt.refill_dug()

/datum/weather/ash_storm/can_weather_act(mob/living/mob_to_check)
	. = ..()
	if(!.)
		return .
	if(ishuman(mob_to_check))
		var/mob/living/carbon/human/human_mob = mob_to_check
		if(human_mob.get_main_thermal_protection() >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			return FALSE
	else if(isborer(mob_to_check))
		var/mob/living/simple_animal/borer/borer = mob_to_check
		if(borer.host?.get_main_thermal_protection() >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			return FALSE

/datum/weather/ash_storm/weather_act(mob/living/target)
	if(!target.mind && target.stat == DEAD || !ishuman(target)) //mind&stat check for optimization against dead roundstart dolls
		target.adjustFireLoss(4)
		return

	target.apply_damage((1 - target.getarmor(BODY_ZONE_HEAD, FIRE) / 100) * THERMAL_PROTECTION_HEAD * 4, BURN, BODY_ZONE_HEAD)
	target.apply_damage((1 - target.getarmor(BODY_ZONE_CHEST, FIRE) / 100) * THERMAL_PROTECTION_UPPER_TORSO * 4, BURN, BODY_ZONE_CHEST)
	target.apply_damage((1 - target.getarmor(BODY_ZONE_PRECISE_GROIN, FIRE) / 100) * THERMAL_PROTECTION_LOWER_TORSO * 4, BURN, BODY_ZONE_PRECISE_GROIN)

	target.apply_damage((1 - target.getarmor(BODY_ZONE_L_ARM, FIRE) / 100) * THERMAL_PROTECTION_ARM_LEFT * 4, BURN, BODY_ZONE_L_ARM)
	target.apply_damage((1 - target.getarmor(BODY_ZONE_PRECISE_L_HAND, FIRE) / 100) * THERMAL_PROTECTION_HAND_LEFT * 4, BURN, BODY_ZONE_PRECISE_L_HAND)
	target.apply_damage((1 - target.getarmor(BODY_ZONE_R_ARM, FIRE) / 100) * THERMAL_PROTECTION_ARM_RIGHT * 4, BURN, BODY_ZONE_R_ARM)
	target.apply_damage((1 - target.getarmor(BODY_ZONE_PRECISE_R_HAND, FIRE) / 100) * THERMAL_PROTECTION_HAND_RIGHT * 4, BURN, BODY_ZONE_PRECISE_R_HAND)

	target.apply_damage((1 - target.getarmor(BODY_ZONE_L_LEG, FIRE) / 100) * THERMAL_PROTECTION_LEG_LEFT * 4, BURN, BODY_ZONE_L_LEG)
	target.apply_damage((1 - target.getarmor(BODY_ZONE_PRECISE_L_FOOT, FIRE) / 100) * THERMAL_PROTECTION_FOOT_LEFT * 4, BURN, BODY_ZONE_PRECISE_L_FOOT)
	target.apply_damage((1 - target.getarmor(BODY_ZONE_R_LEG, FIRE) / 100) * THERMAL_PROTECTION_LEG_RIGHT * 4, BURN, BODY_ZONE_R_LEG)
	target.apply_damage((1 - target.getarmor(BODY_ZONE_PRECISE_R_FOOT, FIRE) / 100) * THERMAL_PROTECTION_FOOT_RIGHT * 4, BURN, BODY_ZONE_PRECISE_R_FOOT)

//Emberfalls are the result of an ash storm passing by close to the playable area of lavaland. They have a 10% chance to trigger in place of an ash storm.
/datum/weather/ash_storm/emberfall
	name = "emberfall"
	desc = "Проходящая пепельная буря покрывает землю безвредными угольками."

	weather_message = span_notice_alt("Мягкие угольки опадают вокруг, словно уродливый снег. Кажется, буря обошла вас стороной...")
	weather_overlay = "light_ash"

	end_message = span_notice_alt("Пеплопад ослабевает и прекращается. Ещё один слой затвердевшей сажи ложится на базальт под ногами.")
	end_sound = null

	aesthetic = TRUE

	probability = 10
