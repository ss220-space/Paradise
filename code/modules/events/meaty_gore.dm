/datum/event/meteor_wave/gore/announce()
	GLOB.minor_announcement.announce("Неизвестный биологический мусор был обнаружен рядом с [station_name()], пожалуйста, будьте наготове.",
									"Обломки."
	)

/datum/event/meteor_wave/gore/setup()
	waves = 3


/datum/event/meteor_wave/gore/tick()
	if(waves && activeFor >= next_meteor)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/spawn_meteors, rand(5, 8), GLOB.meteors_gore)
		next_meteor += rand(15, 30)
		waves--
		endWhen = (waves ? next_meteor + 1 : activeFor + 15)


/datum/event/meteor_wave/gore/end()
	GLOB.minor_announcement.announce("Станция прошла через обломки.",
									"Обломки."
	)
