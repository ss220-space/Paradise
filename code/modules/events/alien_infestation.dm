#define ALIEN_HIGHPOP_TRIGGER 60
#define ALIEN_MIDPOP_TRIGGER 40

/datum/event/alien_infestation
	announceWhen	= 400
	var/list/playercount

/datum/event/alien_infestation/announce(false_alarm)
	if(false_alarm)
		GLOB.event_announcement.Announce("Вспышка биологической угрозы 4-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать её распространение, пока ситуация не вышла из под контроля!", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/effects/siren-spooky.ogg')

/datum/event/alien_infestation/start()
	INVOKE_ASYNC(src, PROC_REF(wrappedstart))
	// It is necessary to wrap this to avoid the event triggering repeatedly.

/datum/event/alien_infestation/proc/wrappedstart()
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	playercount = num_station_players() //grab playercount when event starts not when game starts
	if(playercount <= ALIEN_MIDPOP_TRIGGER)
		spawn_vectors(vents, 1)
		return
	if(playercount >= ALIEN_HIGHPOP_TRIGGER) //spawn with 4 if highpop
		spawn_larvas(vents, 4)
		return
	spawn_larvas(vents, 2)

#undef ALIEN_HIGHPOP_TRIGGER
#undef ALIEN_MIDPOP_TRIGGER
