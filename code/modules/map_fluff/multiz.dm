/datum/map/multiz
	name = "Multiz"
	map_path = "_maps/map_files/debug/multiz_test.dmm"
	lavaland_path = "_maps/map_files/generic/Lavaland.dmm"
	admin_only = TRUE
	traits = list(
		list(MAIN_STATION, STATION_LEVEL = "Main Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP),
		list(STATION_LEVEL = "Second Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Third Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace)
	)
	linkage = SELFLOOPING
	space_ruins_levels = 3

	station_name  = "Multiz Debug Station"
	station_short = "Multiz"
	dock_name     = "THE multiz"
	company_name  = "BadMan"
	company_short = "BM"
	starsys_name  = "Dull Star"
