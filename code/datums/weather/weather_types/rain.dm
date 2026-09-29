/datum/weather/rain
	name = "rain"
	desc = "Мягкий дождь омывает поверхность планеты, создавая умиротворяющую атмосферу."

	telegraph_message = span_notice_alt("Небо темнеет, первые капли дождя начинают падать...")
	telegraph_overlay = "light_rain"

	weather_message = span_notice_alt("<i>Дождь льёт как из ведра. Приятное журчание воды наполняет воздух.</i>")
	weather_overlay = "rain"
	weather_duration_lower = 60 SECONDS
	weather_duration_upper = 180 SECONDS

	end_message = span_notice_alt("Дождь заканчивается. Последние капли падают на землю.")
	end_overlay = "light_rain"
	weather_color = COLOR_PALE_BLUE_GRAY

	area_type = /area/planetoid
	target_trait = ZTRAIT_RAIN
	protected_areas = list(
		/area/planetoid/caves,
		/area/planetoid/lazarus,
		/area/planetoid/escape,
	)

	probability = 50
	lightning_chance = 5

	barometer_predictable = TRUE

	var/list/weak_sounds = list()
	var/list/strong_sounds = list()
	var/wetness_counter = 0
	var/soak_interval = 10

/datum/weather/rain/proc/update_eligible_areas()
	var/list/eligible_areas = list()
	for(var/z in impacted_z_levels)
		eligible_areas += SSmapping.areas_in_z["[z]"]

	for(var/i in 1 to length(eligible_areas))
		var/area/place = eligible_areas[i]
		if(is_area_shuttle(place))
			continue
		if(place.outdoors)
			weak_sounds[place] = /datum/looping_sound/weak_outside_rain
			strong_sounds[place] = /datum/looping_sound/active_outside_rain
		else
			weak_sounds[place] = /datum/looping_sound/weak_inside_rain
			strong_sounds[place] = /datum/looping_sound/active_inside_rain

/datum/weather/rain/proc/update_audio(next_stage)
	switch(next_stage)
		if(STARTUP_STAGE)
			GLOB.rain_sounds += weak_sounds

		if(MAIN_STAGE)
			GLOB.rain_sounds -= weak_sounds
			GLOB.rain_sounds += strong_sounds

		if(WIND_DOWN_STAGE)
			GLOB.rain_sounds -= strong_sounds
			GLOB.rain_sounds += weak_sounds

		if(END_STAGE)
			GLOB.rain_sounds -= weak_sounds

/datum/weather/rain/telegraph()
	if(stage == STARTUP_STAGE)
		return TRUE
	update_eligible_areas()
	update_audio(STARTUP_STAGE)
	. = ..()
	if(!.)
		update_audio(END_STAGE)
		SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_END(type), src)

/datum/weather/rain/start()
	update_audio(MAIN_STAGE)
	. = ..()

/datum/weather/rain/wind_down()
	update_audio(WIND_DOWN_STAGE)
	. = ..()

/datum/weather/rain/end()
	update_audio(END_STAGE)
	. = ..()

/datum/weather/rain/fire()
	wetness_counter++

/datum/weather/rain/weather_act(mob/living/target)
	if(!iscarbon(target) || (wetness_counter % soak_interval))
		return

	var/mob/living/carbon/carbon_target = target
	carbon_target.water_act(15, T20C, src)

/datum/weather/rain/drizzle
	name = "drizzle"
	desc = "Проходящий дождь задевает планету краем, оставляя лишь лёгкую морось."

	weather_message = span_notice_alt("<i>Морось тихо шепчет по крышам. Похоже, дождь обошёл вас стороной...</i>")
	weather_overlay = "light_rain"

	end_message = span_notice_alt("Морось прекращается. Небо снова проясняется.")
	end_overlay = "light_rain"

	aesthetic = TRUE

	probability = 10

/datum/weather/rain/drizzle/update_audio(next_stage)
	switch(next_stage)
		if(STARTUP_STAGE, WIND_DOWN_STAGE)
			GLOB.rain_sounds += weak_sounds

		if(MAIN_STAGE)
			GLOB.rain_sounds -= strong_sounds
			GLOB.rain_sounds += weak_sounds

		if(END_STAGE)
			GLOB.rain_sounds -= weak_sounds

/datum/weather/rain/acid
	name = "acid rain"
	desc = "Кислотный дождь пропитывает поверхность планеты едкой жидкостью."
	telegraph_message = span_boldwarning_alt("Небо наливается болезненно-зелёным оттенком. Воздух обжигает горло — немедленно найдите укрытие!")
	weather_message = span_userdanger_alt("<i>Кислотный дождь разъедает кожу! Под крышу!</i>")
	end_message = span_boldannounceic_alt("Кислотный ливень стихает. Можно выходить...")
	weather_color = COLOR_PALE_GREEN_GRAY
	probability = 40
	var/burn_per_second = 1
	var/acid_reagent_dose = 0.2

/datum/weather/rain/acid/weather_act(mob/living/target)
	if(target.stat == DEAD)
		return
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/human_target = target
	if(human_target.head && human_target.wear_suit)
		return
	var/static/list/acid_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	for(var/zone in acid_zones)
		human_target.apply_damage((1 - min(human_target.getarmor(zone, ACID), 100) / 100) * (burn_per_second / length(acid_zones)), BURN, zone)

	if(human_target.reagents)
		var/acid_multiplier = (1 - min(human_target.getarmor(BODY_ZONE_CHEST, ACID), 100) / 100)
		human_target.reagents.add_reagent(/datum/reagent/acid, acid_reagent_dose * acid_multiplier)
