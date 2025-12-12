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
	end_message = span_boldannounceic("The snowfall dies down, it should be safe to go outside again.")
	end_overlay = "light_snow"

	area_type = /area/ruin/unpowered/coldcolony_outside
	target_trait = ZTRAIT_SNOWSTORM

	immunity_type = TRAIT_SNOWSTORM_IMMUNE

	var/list/weak_sounds = list()
	var/list/strong_sounds = list()

/datum/weather/snow_storm/proc/update_eligible_areas()
	var/list/eligible_areas = list()
	for(var/z in impacted_z_levels)
		eligible_areas += SSmapping.areas_in_z["[z]"]

	for(var/i in 1 to length(eligible_areas))
		var/area/place = eligible_areas[i]
		if(place.outdoors)
			weak_sounds[place] = /datum/looping_sound/weak_outside_ashstorm
			strong_sounds[place] = /datum/looping_sound/active_outside_ashstorm
		else
			weak_sounds[place] = /datum/looping_sound/weak_inside_ashstorm
			strong_sounds[place] = /datum/looping_sound/active_inside_ashstorm
		CHECK_TICK

/datum/weather/snow_storm/proc/update_audio()
	switch(stage)
		if(STARTUP_STAGE)
			GLOB.snowstorm_sounds += weak_sounds

		if(MAIN_STAGE)
			GLOB.snowstorm_sounds -= weak_sounds
			GLOB.snowstorm_sounds += strong_sounds

		if(WIND_DOWN_STAGE)
			GLOB.snowstorm_sounds -= strong_sounds
			GLOB.snowstorm_sounds += weak_sounds

		if(END_STAGE)
			GLOB.snowstorm_sounds -= weak_sounds

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

/datum/weather/snow_storm/weather_act(mob/living/target)
	var/temp_drop = -rand(10, 25)

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/cold_protection = 2 - human_target.get_cold_protection()
		temp_drop *= cold_protection

	else if(istype(target, /mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/borer = target
		var/cold_protection = 2 - borer.host?.get_cold_protection()
		temp_drop *= cold_protection

	target.adjust_bodytemperature(temp_drop)
