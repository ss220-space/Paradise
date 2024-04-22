/*
/datum/map/event
	name = "Station Name"
	map_path = "_maps/map_files/event/Station/yourstation.dmm"
	Lavaland_path = "_maps/map_files/Delta/Lavaland.dmm"

	station_name = "Ingame Station name"
	station_short = "Ingame Station name short"
	dock_name = "NAV Trurl"
	company_name = "Nanotrasen"
	company_short = "NT"
	starsys_name = "Epsilon Eridani"
	webmap_url = "Optional"
	admin_only = TRUE
*/

/datum/map/towerstation
	name = "Towerstation"
	map_path = "_maps/map_files/event/Station/towerstation.dmm"
	lavaland_path = "_maps/map_files/Delta/Lavaland.dmm"
	traits = list(
		list(MAIN_STATION, STATION_LEVEL = "Main Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP),
		list(STATION_LEVEL = "Second Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Third Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Fourth Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Fifth Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Sixth Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Seventh Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Eighth Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Nineth Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
		list(STATION_LEVEL = "Tenth Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace)
	)
	space_ruins_levels = 0

	station_name  = "NSS Turrim"
	station_short = "Turrim"
	dock_name     = "NAV Trurl"
	company_name  = "Nanotrasen"
	company_short = "NT"
	starsys_name  = "Epsilon Eridani "
	admin_only = TRUE
