/*
/datum/map/event
	name = "Station Name"
	map_path = "_maps/map_files/event/Station/yourstation.dmm"
	Lavaland_path = "_maps/map_files/delta/Lavaland.dmm"

	station_name = "Ingame Station name"
	station_short = "Ingame Station name short"
	dock_name = "NAV Trurl"
	company_name = "Nanotrasen"
	company_short = "NT"
	starsys_name = "Epsilon Eridani"
	webmap_url = "Optional"
	admin_only = TRUE
*/

/datum/map/delta_multi_z
	name = "Delta"
	map_path = "_maps/map_files/event/Station/delta_z.dmm"
	lavaland_path = "_maps/map_files/Delta/Lavaland.dmm"

	traits = list(
		list(STATION_LEVEL = "Second Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP),
		list(MAIN_STATION,STATION_LEVEL = "Main Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
	)

	station_name  = "NSS Kerberos"
	station_short = "Kerberos"
	dock_name     = "NAV Trurl"
	company_name  = "Nanotrasen"
	company_short = "NT"
	starsys_name  = "Epsilon Eridani"
	webmap_url = "https://affectedarc07.github.io/SS13WebMap/SS220Paradise/Delta/"
	admin_only = TRUE
