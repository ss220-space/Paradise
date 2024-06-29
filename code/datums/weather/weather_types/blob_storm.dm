//Radiation storms occur when the station passes through an irradiated area, and irradiate anyone not standing in protected areas (maintenance, emergency storage, etc.)
/datum/weather/blob_storm
	name = "blob storm"
	desc = "Плотное облако из мельчайших спор блоба, проникающих через любую одежду."

	telegraph_duration = 2 SECONDS
	telegraph_message = "<span class='danger'>Вы замечаете мелкие частицы в воздухе</span>"

	weather_message = "<span class='userdanger'><i>Вы ощущаете поток неизвестных мелких частиц, которые проникают сквозь любую одежду. Спасти вас может только чудо.</i></span>"
	weather_overlay = "ash_storm"
	weather_duration_lower = 30 SECONDS
	weather_duration_upper = 1 MINUTES
	weather_color = COLOR_PALE_GREEN_GRAY
	weather_sound = 'sound/magic/mutate.ogg'

	end_duration = 10 SECONDS
	end_message = "<span class='notice'>Поток частиц осел.</span>"

	area_type = /area
	protected_areas = list(/area/space, /area/crew_quarters/sleep)
	target_trait = STATION_LEVEL

	immunity_type = "bio"

/datum/weather/blob_storm/telegraph()
	..()
	status_alarm(TRUE)
	GLOB.event_announcement.Announce("Биологической угроза пятого уровня достигла критической массы на борту [station_name()]. Выброс спор и массовое заражение неизбежно.",
									"ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/AI/outbreak5.ogg')


/datum/weather/blob_storm/weather_act(mob/living/L)
	var/resist = L.getarmor(null, immunity_type)
	if(L.mind && L.mind.special_role != SPECIAL_ROLE_BLOB)
		if(prob(50))
			return
		if(!prob(max(0, min(100, 110 - resist))))
			return
		if(!SSticker || !SSticker.mode)
			return
		var/datum/antagonist/blob_infected/blob_datum = new
		blob_datum.add_to_mode = FALSE
		blob_datum.time_to_burst_h = TIME_TO_BURST_MOUSE_H
		blob_datum.time_to_burst_l = TIME_TO_BURST_MOUSE_L
		L.mind.add_antag_datum(blob_datum)


/datum/weather/blob_storm/end()
	if(..())
		return
	if(!SSticker || !SSticker.mode)
		return
	status_alarm(FALSE)
	if(GLOB.security_level != SEC_LEVEL_DELTA && !SSticker.mode.blob_end_sterted)
		SSticker.mode.start_blob_win()

/datum/weather/blob_storm/proc/status_alarm(active)	//Makes the status displays show the radiation warning for those who missed the announcement.
	if(active)
		post_status(STATUS_DISPLAY_ALERT, "bio")
	else
		post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)

/datum/weather/blob_storm/start()
	if(stage >= MAIN_STAGE)
		return
	stage = MAIN_STAGE
	if(GLOB.security_level == SEC_LEVEL_DELTA)
		for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
			if(bomb && bomb.timing && is_station_level(bomb.z))
				INVOKE_ASYNC(bomb, /obj/machinery/nuclearbomb/proc/explode)
	update_areas()
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && (mob_turf.z in impacted_z_levels))
			if(weather_message && isliving(M))
				to_chat(M, weather_message)
			if(weather_sound)
				SEND_SOUND(M, sound(weather_sound))
	addtimer(CALLBACK(src, PROC_REF(wind_down)), weather_duration)

/datum/weather/blob_storm/can_weather_act(mob/living/L)
	if(!L.weather_immunities)
		return FALSE
	return ..()
