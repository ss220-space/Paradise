/datum/event/meteor_wave/goreop/announce()
	var/meteor_declaration = "Метеоритные оперативники заявили о своем намерении полностью уничтожить [station_name()] своими собственными телами. Осмелится ли экипаж остановить их?"
	GLOB.major_announcement.announce(meteor_declaration,
									ANNOUNCE_DECLAREWAR_RU,
									'sound/effects/siren.ogg'
	)

/datum/event/meteor_wave/goreop/setup()
	waves = 3


/datum/event/meteor_wave/goreop/tick()
	if(waves && activeFor >= next_meteor)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/spawn_meteors, 5, GLOB.meteors_ops)
		next_meteor += rand(15, 30)
		waves--
		endWhen = (waves ? next_meteor + 1 : activeFor + 15)



/datum/event/meteor_wave/goreop/end()
	GLOB.minor_announcement.announce("Все метеориты мертвы. Безоговорочная победа станции.",
									ANNOUNCE_METEOR_RU
	)
