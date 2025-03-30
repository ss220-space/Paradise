/datum/weather/xeno_storm
	name = "Ксено-буря"

	telegraph_duration = 2 SECONDS
	telegraph_message = null

	weather_message = null
	weather_duration_lower = 30 SECONDS
	weather_duration_upper = 1 MINUTES

	end_message = null
	end_duration = 10 SECONDS

	area_type = /area
	protected_areas = list(/area/space, /area/crew_quarters/sleep)
	target_trait = STATION_LEVEL

	immunity_type = TRAIT_WEATHER_IMMUNE

	self_fire = TRUE
	var/vents_per_tick = 15
	var/list/affected_vents_list = list()


/datum/weather/xeno_storm/telegraph()
	. = ..()
	status_alarm(TRUE)
	GLOB.event_announcement.Announce("Зафиксирована сигнатура Императрицы Ксеноморфов на борту станции [station_name()]. Запущено глубокое сканирование.", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/effects/siren-spooky.ogg')

	if(!.)
		return

	for(var/obj/vent as anything in GLOB.all_vent_pumps)
		var/area = get_area(vent)
		if(area in impacted_areas)
			affected_vents_list[vent] = TRUE


/datum/weather/xeno_storm/fire()
	if(!affected_vents_list.len)
		return
	var/list/vents = list()
	for(var/i = 1; i < vents_per_tick; i++)
		var/obj/machinery/atmospherics/unary/vent_pump/vent = pick(affected_vents_list)
		vent.set_welded(TRUE)
		new/obj/structure/alien/weeds/node(get_turf(vent))
		vents += vent
	affected_vents_list -= vents


/datum/weather/xeno_storm/end()
	if(..())
		return
	if(!SSticker || !SSticker.mode)
		return
	status_alarm(FALSE)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_XENO_STORM_ENDED)

/datum/weather/xeno_storm/proc/status_alarm(active)
	if(active)
		post_status(STATUS_DISPLAY_ALERT, "bio")
	else
		post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
