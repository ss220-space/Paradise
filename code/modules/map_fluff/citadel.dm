/datum/map/citadel
	name = "Citadel"
	map_path = "_maps/map_files/citadel/citadel.dmm"
	// lavaland_path = "_maps/map_files/citadel/Lavaland.dmm"

	station_name = "Сторожевая башня Цитадель"
	english_station_name = "Citadel Watchtower"
	station_short = "Цитадель"
	dock_name = "Лороведы работайте"
	company_name = "\"Нанотрейзен\""
	company_short = "НТ"
	starsys_name = "Лороведы работайте"

	traits = list(
		list(MAIN_STATION, STATION_LEVEL = "First Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP),
		list(STATION_LEVEL = "Second Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Third Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Fourth Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
	)
	space_ruins_levels = 0
