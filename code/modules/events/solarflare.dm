/datum/event/solar_flare
	startWhen = 2
	endWhen = 3
	announceWhen = 1

/datum/event/solar_flare/announce()
	GLOB.event_announcement.Announce("Солнечная вспышка зафиксирована на встречном со станцией курсе.", "ВНИМАНИЕ: СОЛНЕЧНАЯ ВСПЫШКА", 'sound/AI/alert/voybluealert.ogg')

/datum/event/solar_flare/start()
	SSweather.run_weather(/datum/weather/solar_flare)
