/*
/datum/map/event
	name = "Station Name"
	map_path = "_maps/map_files/event/Station/yourstation.dmm"
	Lavaland_path = "_maps/map_files/Delta/Lavaland.dmm"

	station_name = "Ingame Station name (in Russian)"
	english_station_name = "Ingame Station name (in English for Byond Hub)"
	station_short = "Ingame Station name short (in Russian)"
	dock_name = "АКН Трурль"
	company_name = "НаноТрейзен"
	company_short = "НТ"
	starsys_name = "Эпсилон Лукуста"
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

	station_name = "ИСН Туррим"
	english_station_name = "NSS Turrim"
	station_short = "Туррим"
	dock_name = "АКН Трурль"
	company_name = "НаноТрейзен"
	company_short = "НТ"
	starsys_name = "Эпсилон Лукуста"
	admin_only = TRUE

/datum/map/delta_old
	name = "Delta Legacy"
	map_path = "_maps/map_files/event/Station/delta_old.dmm"
	lavaland_path = "_maps/map_files/Delta/Lavaland.dmm"

	station_name = "ИСН Керберос"
	english_station_name = "NSS Kerberos"
	station_short = "Керберос"
	dock_name = "АКН Трурль"
	company_name = "НаноТрейзен"
	company_short = "НТ"
	starsys_name = "Эпсилон Лукуста"
	admin_only = TRUE

/datum/map/coldcolony
	name = "Malta"
	map_path = "_maps/map_files/event/Station/coldcolony.dmm"
	lavaland_path = "_maps/map_files/coldcolony/Lavaland.dmm"
	traits = list(MAIN_STATION, STATION_CONTACT, STATION_LEVEL = "Surface", REACHABLE, AI_OK, ZTRAIT_BASETURF = /turf/simulated/floor/plating/asteroid/snow/planet)

	station_name = "ШОН Мальта"
	english_station_name = "NMC Malta"
	station_short = "Мальта"
	dock_name = "АКН Трурль"
	company_name = "НаноТрейзен"
	company_short = "НТ"
	starsys_name = "Эпсилон Лукуста"
	admin_only = TRUE
