// Made by PiroMage (https://github.com/PiroMage)

/datum/map/Nova
	name = "Nova"
	map_path = "_maps/map_files/nova/nova.dmm"
	lavaland_path = "_maps/map_files/nova/Lavaland.dmm"
	traits = list(
	list(MAIN_STATION, STATION_LEVEL = "First Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_UP),
	list(STATION_LEVEL = "Second Floor", STATION_CONTACT, REACHABLE, AI_OK, ZTRAIT_DOWN, ZTRAIT_BASETURF = /turf/simulated/openspace),
	)
	space_ruins_levels = 0
	station_name  = "NSS Nova"
	station_short = "Nova"
	dock_name     = "NAV Trurl"
	company_name  = "Nanotrasen"
	company_short = "NT"
	starsys_name  = "Epsilon Eridani"
	webmap_url = "https://webmap.affectedarc07.co.uk/maps/ss1984/celestation/"
