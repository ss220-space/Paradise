/datum/weather/snow_storm
	name = "snow storm"
	desc = "Harsh snowstorms roam the topside of this arctic planet, burying any area unfortunate enough to be in its path."
	probability = 99

	telegraph_message = span_warning("Drifting particles of snow begin to dust the surrounding area...")
	telegraph_duration = 40 SECONDS
	telegraph_overlay = "light_snow"

	weather_message = span_userdanger("<i>Harsh winds pick up as dense snow begins to fall from the sky! Seek shelter!</i>")
	weather_overlay = "snow_storm"
	weather_duration_lower = 60 SECONDS
	weather_duration_upper = 120 SECONDS

	end_duration = 10 SECONDS
	end_message = span_boldannounce("The snowfall dies down, it should be safe to go outside again.")
	end_overlay = "light_snow"

	area_type = /area/vision_change_area/awaymission/evil_santa_storm
	target_trait = AWAY_LEVEL

	immunity_type = "snow"

	var/list/inside_areas = list()
	var/list/outside_areas = list()
	var/datum/looping_sound/active_outside_ashstorm/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_ashstorm/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_ashstorm/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_ashstorm/sound_wi = new(list(), FALSE, TRUE)

/datum/weather/snow_storm/proc/update_eligible_areas()
	var/list/eligible_areas = list()
	for(var/z in impacted_z_levels)
		eligible_areas += GLOB.space_manager.areas_in_z["[z]"]

	for(var/i in 1 to eligible_areas.len)
		var/area/place = eligible_areas[i]
		if(place.outdoors)
			outside_areas |= place
		else
			inside_areas |= place
		CHECK_TICK

/datum/weather/snow_storm/proc/update_audio()
	switch(stage)
		if(STARTUP_STAGE)
			sound_wo.start(outside_areas)
			sound_wi.start(inside_areas)

		if(MAIN_STAGE)
			sound_wo.stop(outside_areas, TRUE)
			sound_wi.stop(inside_areas, TRUE)

			sound_ao.start(outside_areas)
			sound_ai.start(inside_areas)

		if(WIND_DOWN_STAGE)
			sound_ao.stop(outside_areas, TRUE)
			sound_ai.stop(inside_areas, TRUE)

			sound_wo.start(outside_areas)
			sound_wi.start(inside_areas)

		if(END_STAGE)
			sound_wo.stop(outside_areas, TRUE)
			sound_wi.stop(inside_areas, TRUE)

/datum/weather/snow_storm/telegraph()
	. = ..()
	if(.)
		update_eligible_areas()
		update_audio()

/datum/weather/snow_storm/wind_down()
	. = ..()
	update_audio()

/datum/weather/snow_storm/end()
	. = ..()
	update_audio()

/datum/weather/snow_storm/proc/is_snow_immune(atom/L)
	while(L && !isturf(L))
		if(ismecha(L)) //Mechs are immune
			return TRUE
		if(isvampirecoffin(L))
			return TRUE
		if (istype(L, /mob/living/silicon))
			return TRUE /// Borgs are protected and so their brains
		L = L.loc //Matryoshka check
	return FALSE //RIP you

/datum/weather/snow_storm/weather_act(mob/living/L)
	if(is_snow_immune(L))
		return

	var/temp_drop = -rand(10, 25)
	var/freeze_chance = 35

	if(ishuman(L))
		var/mob/living/carbon/human/target = L
		var/cold_protection = 2 - target.get_cold_protection()
		temp_drop *= cold_protection
		freeze_chance *= cold_protection

	else if(istype(L, /mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/target = L
		var/cold_protection = 2 - target.host?.get_cold_protection()
		temp_drop *= cold_protection
		freeze_chance *= cold_protection

	L.adjust_bodytemperature(temp_drop)

	if(L.bodytemperature <= TCMB && prob(freeze_chance))
		L.apply_status_effect(/datum/status_effect/freon)
