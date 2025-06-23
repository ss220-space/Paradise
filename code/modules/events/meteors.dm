/datum/event/meteor_wave
	startWhen		= 5
	endWhen 		= 7
	var/next_meteor = 6
	var/waves = 1

/datum/event/meteor_wave/setup()
	waves = severity * rand(1,3)

/datum/event/meteor_wave/announce(false_alarm)
	if(severity == EVENT_LEVEL_MAJOR || (false_alarm && prob(30)))
		GLOB.minor_announcement.Announce("Зафиксировано движение астероидов на встречном со станцией курсе.",
										"Метеориты",
										'sound/AI/meteors.ogg'
		)
	else
		GLOB.minor_announcement.Announce("Станция проходит через скопление астероидов.",
										"Метеориты"
		)

//meteor showers are lighter and more common,
/datum/event/meteor_wave/tick()
	if(waves && activeFor >= next_meteor)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/spawn_meteors, severity * rand(1, 2), get_meteors())
		next_meteor += rand(15, 30) / severity
		waves--
		endWhen = (waves ? next_meteor + 1 : activeFor + 15)

/datum/event/meteor_wave/end()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			GLOB.minor_announcement.Announce("Станция прошла через астероидный пояс",
											"Метеориты"
			)
		else
			GLOB.minor_announcement.Announce("Станция прошла через скопление астероидов",
											"Метеориты"
			)

/datum/event/meteor_wave/proc/get_meteors()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			return GLOB.meteors_catastrophic
		if(EVENT_LEVEL_MODERATE)
			return GLOB.meteors_threatening
		else
			return GLOB.meteors_normal
