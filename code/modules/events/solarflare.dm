/datum/event/solar_flare
	startWhen = 2
	endWhen = 3
	announceWhen = 1

/datum/event/solar_flare/announce()
	GLOB.minor_announcement.announce("Солнечная вспышка зафиксирована на встречном со станцией курсе.",
									ANNOUNCE_SOLAR_FLARE_RU,
									'sound/AI/flare.ogg'
	)

/datum/event/solar_flare/start()
	SSweather.run_weather(/datum/weather/solar_flare)
