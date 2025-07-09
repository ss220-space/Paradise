/datum/event/dust/meaty


/datum/event/dust/meaty/setup()
	qnty = rand(45,125)


/datum/event/dust/meaty/announce()
	if(prob(16))
		GLOB.minor_announcement.announce("Неизвестные биологические объекты были обнаружены рядом с [station_name()], пожалуйста, будьте наготове.",
										ANNOUNCE_UNID_LIFEFORMS_RU
		)
	else
		GLOB.minor_announcement.announce("На пути станции были обнаружены мясориты.",
										"Мясориты.",
										'sound/AI/meteors.ogg'
		)


/datum/event/dust/meaty/start()
	while(qnty-- > 0)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/spawn_meteors, 1, GLOB.meteors_pigs)
		if(prob(10))
			sleep(rand(1 SECONDS, 1.5 SECONDS))

