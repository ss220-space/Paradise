/datum/event/solar_flare
	startWhen = 2
	endWhen = 3
	announceWhen = 1

/datum/event/solar_flare/announce()
	GLOB.minor_announcement.announce(
		message = "Солнечная вспышка зафиксирована на встречном со станцией курсе.",
		new_title = ANNOUNCE_SOLAR_FLARE_RU,
		new_sound = 'sound/AI/flare.ogg'
	)

/datum/event/solar_flare/start()
	SSweather.run_weather(/datum/weather/solar_flare)
