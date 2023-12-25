/datum/weather/snow_storm
	name = "snow storm"
	desc = "Harsh snowstorms roam the topside of this arctic planet, burying any area unfortunate enough to be in its path."
	probability = 99

	telegraph_message = "<span class='warning'>Drifting particles of snow begin to dust the surrounding area..</span>"
	telegraph_duration = 300
	telegraph_overlay = "light_snow"

	weather_message = "<span class='userdanger'><i>Harsh winds pick up as dense snow begins to fall from the sky! Seek shelter!</i></span>"
	weather_overlay = "snow_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1200

	end_duration = 100
	end_message = "<span class='boldannounce'>The snowfall dies down, it should be safe to go outside again.</span>"
	end_overlay = "light_snow"

	area_type = /area/awaymission/evil_santa_storm
	target_trait = AWAY_LEVEL

	immunity_type = "snow"
	next_hit_time = 600

	//barometer_predictable = TRUE

	var/datum/looping_sound/active_outside_ashstorm/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_ashstorm/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_ashstorm/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_ashstorm/sound_wi = new(list(), FALSE, TRUE)

/datum/weather/snow_storm/proc/update_eligible_areas()
	var/list/inside_areas = list()
	var/list/outside_areas = list()
	var/list/eligible_areas = list()
	for(var/z in impacted_z_levels)
		eligible_areas += GLOB.space_manager.areas_in_z["[z]"]

	for(var/i in 1 to eligible_areas.len)
		var/area/place = eligible_areas[i]
		if(place.outdoors)
			outside_areas += place
		else
			inside_areas += place
		CHECK_TICK

	sound_ao.output_atoms = outside_areas
	sound_ai.output_atoms = inside_areas
	sound_wo.output_atoms = outside_areas
	sound_wi.output_atoms = inside_areas

	sound_wo.start()
	sound_wi.start()

/datum/weather/snow_storm/proc/update_audio()
	switch(stage)
		if(STARTUP_STAGE)
			sound_wo.start()
			sound_wi.start()

		if(MAIN_STAGE)
			sound_wo.stop()
			sound_wi.stop()

			sound_ao.start()
			sound_ai.start()

		if(WIND_DOWN_STAGE)
			sound_ao.stop()
			sound_ai.stop()

			sound_wo.start()
			sound_wi.start()

		if(END_STAGE)
			sound_wo.stop()
			sound_wi.stop()

/datum/weather/snow_storm/telegraph()
	. = ..()
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
		if(ishuman(L)) //Are you immune?
			var/mob/living/carbon/human/target = L
			if(target.get_thermal_protection() >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
				return TRUE
		if(istype(L, /mob/living/simple_animal/borer))
			var/mob/living/simple_animal/borer/target = L
			if(target.host?.get_thermal_protection() >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
				return TRUE
		if (istype(L, /mob/living/silicon))
			return TRUE /// Borgs are protected and so their brains
		L = L.loc //Matryoshka check
	return FALSE //RIP you

/datum/weather/snow_storm/weather_act(mob/living/L)
	if(is_snow_immune(L))
		return
	L.adjust_bodytemperature(-rand(5, 15))
