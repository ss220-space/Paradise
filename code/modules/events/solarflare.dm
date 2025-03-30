/datum/event/solar_flare
	startWhen = 2
	endWhen = 3
	announceWhen = 1

/datum/event/solar_flare/announce()
	GLOB.event_announcement.Announce("Ожидайте важное сообщение от нашего сотрудника.", "ВНИМАНИЕ: СОЛНЕЧНАЯ ВСПЫШКА.", 'sound/announcer/solar_flare.ogg')

/datum/event/solar_flare/start()
	SSweather.run_weather(/datum/weather/solar_flare)
