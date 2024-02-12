#define WEATHER_ALERT_CLEAR 0
#define WEATHER_ALERT_INCOMING 1
#define WEATHER_ALERT_IMMINENT_OR_ACTIVE 2

/***********************Mining radio**********************/
/obj/item/radio/weather_monitor
	name = "mining weather radio"
	icon = 'icons/obj/miningradio.dmi'
	icon_state = "miningradio"
	desc = "A weather radio designed for use in inhospitable environments. Gives audible warnings when storms approach. Has access to cargo channel."
	freqlock = TRUE
	luminosity = 1
	light_power = 1
	light_range = 1.6
	/// Currently displayed warning level
	var/warning_level = WEATHER_ALERT_CLEAR
	/// Whether the incoming weather is actually going to harm you
	var/is_weather_dangerous = TRUE
	/// Overlay added when things are alright
	var/state_normal = "weatherwarning"
	/// Overlay added when you should start looking for shelter
	var/state_warning = "urgentwarning"
	/// Overlay added when you are in danger
	var/state_danger = "direwarning"

/obj/item/radio/weather_monitor/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	set_frequency(SUP_FREQ)
	update_light_color()
	update_icon(UPDATE_OVERLAYS)

/obj/item/radio/weather_monitor/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/obj/item/radio/weather_monitor/process()
	var/previous_level = warning_level
	var/previous_danger = is_weather_dangerous
	set_current_alert_level()
	if(previous_level == warning_level && previous_danger == is_weather_dangerous)
		return // No change
	atom_say(get_warning_message())
	update_icon(UPDATE_OVERLAYS)
	update_light_color()

/obj/item/radio/weather_monitor/update_overlays()
	. = ..()
	switch(warning_level)
		if(WEATHER_ALERT_CLEAR)
			. += state_normal
		if(WEATHER_ALERT_INCOMING)
			. += state_warning
		if(WEATHER_ALERT_IMMINENT_OR_ACTIVE)
			. += is_weather_dangerous ? state_danger : state_warning

/obj/item/radio/weather_monitor/proc/update_light_color()
	switch(warning_level)
		if(WEATHER_ALERT_CLEAR)
			light_color = LIGHT_COLOR_GREEN
		if(WEATHER_ALERT_INCOMING)
			light_color = LIGHT_COLOR_YELLOW
		if(WEATHER_ALERT_IMMINENT_OR_ACTIVE)
			light_color = LIGHT_COLOR_PURE_RED
	update_light()

/obj/item/radio/weather_monitor/proc/get_warning_message() //damn tts
	if(!is_weather_dangerous)
		return "Приближающаяся буря не представляет угрозы."
	switch(warning_level)
		if(WEATHER_ALERT_CLEAR)
			return "Буря закончилась. Текущая погода не представляет угрозы."
		if(WEATHER_ALERT_INCOMING)
			return "Приближается буря. Приступите к поиску убежища."
		if(WEATHER_ALERT_IMMINENT_OR_ACTIVE)
			return "Буря неизбежна. Немедленно найдите убежище."
	return "Ошибка в просчёте погоды. Пожалуйста сообщите об ошибке в службу поддержки НТ."

/obj/item/radio/weather_monitor/proc/time_till_storm()
	var/list/mining_z_levels = levels_by_trait(ORE_LEVEL)
	if(!length(mining_z_levels))
		return // No problems if there are no mining z levels

	for(var/datum/weather/check_weather as anything in SSweather.processing)
		if(!check_weather.barometer_predictable || check_weather.stage == WIND_DOWN_STAGE || check_weather.stage == END_STAGE)
			continue
		for (var/mining_level in mining_z_levels)
			if(mining_level in check_weather.impacted_z_levels)
				warning_level = WEATHER_ALERT_IMMINENT_OR_ACTIVE
				return 0

	var/time_until_next = INFINITY
	for(var/mining_level in mining_z_levels)
		if(is_mining_level(mining_level))
			var/next_time = SSweather.next_hit_by_zlevel["[mining_level]"] - world.time
			if(next_time && next_time < time_until_next)
				time_until_next = next_time
	return time_until_next

/obj/item/radio/weather_monitor/proc/set_current_alert_level()
	var/time_until_next = time_till_storm()
	if(isnull(time_until_next))
		return // No problems if there are no mining z levels
	if(time_until_next >= 1 MINUTES)
		warning_level = WEATHER_ALERT_CLEAR
		return
	if(time_until_next >= 10 SECONDS)
		warning_level = WEATHER_ALERT_INCOMING
		return
	// Weather is here, now we need to figure out if it is dangerous
	warning_level = WEATHER_ALERT_IMMINENT_OR_ACTIVE

	for(var/datum/weather/check_weather as anything in SSweather.processing)
		if(!check_weather.barometer_predictable || check_weather.stage == WIND_DOWN_STAGE || check_weather.stage == END_STAGE)
			continue
		var/list/mining_z_level = levels_by_trait(ORE_LEVEL)
		for(var/mining_level in mining_z_level)
			if(mining_level in check_weather.impacted_z_levels)
				is_weather_dangerous = !check_weather.aesthetic
				return

#undef WEATHER_ALERT_CLEAR
#undef WEATHER_ALERT_INCOMING
#undef WEATHER_ALERT_IMMINENT_OR_ACTIVE
