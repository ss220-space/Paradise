//The effects of weather occur across an entire z-level. For instance, lavaland has periodic ash storms that scorch most unprotected creatures.

/datum/weather
	var/name = "space wind"
	var/desc = "Heavy gusts of wind blanket the area, periodically knocking down anyone caught in the open."

	var/telegraph_message = span_warning("The wind begins to pick up.") //The message displayed in chat to foreshadow the weather's beginning
	var/telegraph_duration = 30 SECONDS //In deciseconds, how long from the beginning of the telegraph until the weather begins
	var/telegraph_sound //The sound file played to everyone on an affected z-level
	var/telegraph_overlay //The overlay applied to all tiles on the z-level

	var/weather_message = span_userdanger("The wind begins to blow ferociously!") //Displayed in chat once the weather begins in earnest
	var/weather_duration = 120 SECONDS //In deciseconds, how long the weather lasts once it begins
	var/weather_duration_lower = 120 SECONDS //See above - this is the lowest possible duration
	var/weather_duration_upper = 150 SECONDS //See above - this is the highest possible duration
	var/weather_sound
	var/weather_overlay
	var/weather_color = null

	var/end_message = span_danger("The wind relents its assault.") //Displayed once the wather is over
	var/end_duration = 30 SECONDS //In deciseconds, how long the "wind-down" graphic will appear before vanishing entirely
	var/end_sound
	var/end_overlay

	var/area_type = /area/space //Types of area to affect
	var/list/impacted_areas = list() //Areas to be affected by the weather, calculated when the weather begins
	var/list/protected_areas = list()//Areas that are protected and excluded from the affected areas.
	var/impacted_z_levels // The list of z-levels that this weather is actively affecting

	var/overlay_layer = AREA_LAYER //Since it's above everything else, this is the layer used by default. TURF_LAYER is below mobs and walls if you need to use that.
	var/overlay_plane = AREA_PLANE
	var/aesthetic = FALSE //If the weather has no purpose other than looks
	/// Used by mobs (or movables containing mobs, such as enviro bags) to prevent them from being affected by the weather.
	var/immunity_type

	/// List of all overlays to apply to our turfs
	var/list/overlay_cache

	var/stage = END_STAGE //The stage of the weather, from 1-4

	// These are read by the weather subsystem and used to determine when and where to run the weather.
	var/probability = 0 // Weight amongst other eligible weather. If zero, will never happen randomly.
	var/target_trait = STATION_LEVEL // The z-level trait to affect when run randomly or when not overridden.

	var/barometer_predictable = FALSE
	var/next_hit_time = 0 //For barometers to know when the next storm will hit

/datum/weather/New(z_levels)
	..()
	impacted_z_levels = z_levels

/datum/weather/proc/generate_area_list()
	var/list/affectareas = list()
	for(var/V in get_areas(area_type))
		affectareas += V
	for(var/V in protected_areas)
		affectareas -= get_areas(V)
	for(var/V in affectareas)
		var/area/A = V
		if(A.z in impacted_z_levels)
			impacted_areas |= A
		CHECK_TICK

/datum/weather/proc/telegraph()
	if(stage == STARTUP_STAGE)
		return TRUE	// If weather already active, don't need to mark it as invalid. More at `/datum/controller/subsystem/weather/fire()`
	generate_area_list()
	if(!impacted_areas.len)
		return FALSE
	stage = STARTUP_STAGE
	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	START_PROCESSING(SSweather, src)
	update_areas()
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && (mob_turf.z in impacted_z_levels))
			if(telegraph_message)
				to_chat(M, telegraph_message)
			if(telegraph_sound)
				SEND_SOUND(M, sound(telegraph_sound))
	addtimer(CALLBACK(src, PROC_REF(start)), telegraph_duration)
	return TRUE

/datum/weather/proc/start()
	if(stage >= MAIN_STAGE)
		return
	stage = MAIN_STAGE
	update_areas()
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && (mob_turf.z in impacted_z_levels))
			if(weather_message)
				to_chat(M, weather_message)
			if(weather_sound)
				SEND_SOUND(M, sound(weather_sound))
	addtimer(CALLBACK(src, PROC_REF(wind_down)), weather_duration)

/datum/weather/proc/wind_down()
	if(stage >= WIND_DOWN_STAGE)
		return
	stage = WIND_DOWN_STAGE
	update_areas()
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && (mob_turf.z in impacted_z_levels))
			if(end_message)
				to_chat(M, end_message)
			if(end_sound)
				SEND_SOUND(M, sound(end_sound))
	addtimer(CALLBACK(src, PROC_REF(end)), end_duration)

/datum/weather/proc/end()
	if(stage == END_STAGE)
		return TRUE
	stage = END_STAGE
	STOP_PROCESSING(SSweather, src)
	update_areas()


/// Can this weather impact a mob?
/datum/weather/proc/can_weather_act(mob/living/mob_to_check)
	var/turf/mob_turf = get_turf(mob_to_check)
	if(!mob_turf)
		return FALSE

	if(!(mob_turf.z in impacted_z_levels))
		return FALSE

	if((immunity_type && HAS_TRAIT(mob_to_check, immunity_type)) || HAS_TRAIT(mob_to_check, TRAIT_WEATHER_IMMUNE))
		return FALSE

	var/atom/loc_to_check = mob_to_check.loc
	while(loc_to_check != mob_turf)
		if((immunity_type && HAS_TRAIT(loc_to_check, immunity_type)) || HAS_TRAIT(loc_to_check, TRAIT_WEATHER_IMMUNE))
			return FALSE
		loc_to_check = loc_to_check.loc

	if(!(get_area(mob_to_check) in impacted_areas))
		return FALSE

	return TRUE


/datum/weather/proc/weather_act(mob/living/target) //What effect does this weather have on the hapless mob?
	return


/datum/weather/proc/update_areas()
	var/list/new_overlay_cache = generate_overlay_cache()
	for(var/area/impacted as anything in impacted_areas)
		if(length(overlay_cache))
			impacted.overlays -= overlay_cache
		if(length(new_overlay_cache))
			impacted.overlays += new_overlay_cache

	overlay_cache = new_overlay_cache

/// Returns a list of visual offset -> overlays to use
/datum/weather/proc/generate_overlay_cache()
	// We're ending, so no overlays at all
	if(stage == END_STAGE)
		return list()

	var/weather_state = ""
	switch(stage)
		if(STARTUP_STAGE)
			weather_state = telegraph_overlay
		if(MAIN_STAGE)
			weather_state = weather_overlay
		if(WIND_DOWN_STAGE)
			weather_state = end_overlay

	// Use all possible offsets
	// Yes this is a bit annoying, but it's too slow to calculate and store these from turfs, and it shouldn't (I hope) look weird
	var/list/gen_overlay_cache = list()
	for(var/offset in 0 to SSmapping.max_plane_offset)
		var/mutable_appearance/weather_overlay = mutable_appearance('icons/effects/weather_effects.dmi', weather_state, overlay_layer, plane = overlay_plane, offset_const = offset)
		weather_overlay.color = weather_color
		gen_overlay_cache += weather_overlay

	return gen_overlay_cache
