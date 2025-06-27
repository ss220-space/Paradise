/datum/weather/web_storm
	name = "Паутинная буря"
	desc = "Плотное облако из мельчайших частичек паутины, липнущих ко всему вокруг."

	telegraph_duration = 2 SECONDS
	telegraph_message = span_danger("Вы замечаете мелкие частицы паутины в воздухе.")

	weather_message = span_userdanger("<i>Вы ощущаете поток мельчайших частиц паутины, липнуших ко всему вокруг.</i>")
	weather_overlay = "web_storm"
	weather_duration_lower = 30 SECONDS
	weather_duration_upper = 1 MINUTES
	overlay_layer = MOB_LAYER
	overlay_plane = GAME_PLANE
	weather_sound = 'sound/creatures/terrorspiders/queen_shriek.ogg'

	end_duration = 10 SECONDS
	end_message = span_notice("Поток паутины прекращается.")

	area_type = /area
	protected_areas = list(/area/space, /area/crew_quarters/sleep)
	target_trait = STATION_LEVEL

	immunity_type = TRAIT_WEATHER_IMMUNE

	self_fire = TRUE
	var/turfs_per_tick = 40
	var/list/affected_turfs_list = list()


/datum/weather/web_storm/telegraph()
	. = ..()
	status_alarm(TRUE)
	GLOB.event_announcement.Announce("Зафиксирована сигнатура Императрицы Ужаса на борту станции [station_name()]. Запущено глубокое сканирование.", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/effects/siren-spooky.ogg')

	if(!.)
		return
	for(var/area/area as anything in impacted_areas)
		for(var/turf/turf in area.get_contained_turfs())
			if(is_space_or_openspace(turf) || turf.density)
				continue
			affected_turfs_list += turf

/datum/weather/web_storm/fire()
	var/list/turfs = list()
	for(var/i = 1; i < turfs_per_tick; i++)
		var/turf = pick(affected_turfs_list)
		new/obj/structure/spider/terrorweb(turf)
		turfs += turf
	affected_turfs_list -= turfs


/datum/weather/web_storm/end()
	if(..())
		return
	if(!SSticker || !SSticker.mode)
		return
	status_alarm(FALSE)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_WEB_STORM_ENDED)

/datum/weather/web_storm/proc/status_alarm(active)
	if(active)
		post_status(STATUS_DISPLAY_ALERT, "bio")
	else
		post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
