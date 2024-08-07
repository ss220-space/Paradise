//Remapped by SAAD (https://github.com/SAADf603) special for SS1984
// Original map made by S34NW (https://github.com/S34NW)

/datum/map/celestation
	name = "Celestation"
	map_path = "_maps/map_files/celestation/celestation.dmm"
	lavaland_path = "_maps/map_files/celestation/Lavaland.dmm"
	traits = list(
	list(MAIN_STATION, STATION_LEVEL = "Basement Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP),
	list(STATION_LEVEL = "Main Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
	list(STATION_LEVEL = "Second Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace)
	)
	space_ruins_levels = 0
	station_name  = "NSS Selestion"
	station_short = "Selestia"
	dock_name     = "NAV Trurl"
	company_name  = "Nanotrasen"
	company_short = "NT"
	starsys_name  = "Epsilon Eridani"
	webmap_url = "https://webmap.affectedarc07.co.uk/maps/ss1984/celestation/"
