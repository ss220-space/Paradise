/datum/map/fast_load
	name = "fast load"
	map_path = "_maps/map_files/debug/fast_load.dmm"
	linkage = SELFLOOPING

	station_name = "ИСН Быстрогруз"
	english_station_name = "NSS Fastload"
	station_short = "Быстрогруз"
	dock_name = "АКН Быстрогруз"
	company_name = "1984"
	company_short = "1984"
	starsys_name = "Дебагия"
	admin_only = TRUE

/datum/map/fast_load_multiz
	name = "fast load multiz"
	map_path = "_maps/map_files/debug/fast_load_multiz.dmm"
	linkage = SELFLOOPING

	station_name = "ИСН Быстрогруз (Multi Z)"
	english_station_name = "NSS Fastload (Multi Z)"
	station_short = "Быстрогруз multiz"
	dock_name = "АКН Быстрогруз MultiZ"
	company_name = "1984"
	company_short = "1984"
	starsys_name = "Дебагия"
	admin_only = TRUE

	traits = list(
		list(MAIN_STATION, STATION_LEVEL = "First Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP),
		list(STATION_LEVEL = "Second Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_DOWN, ZTRAIT_UP, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Third Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
	)
