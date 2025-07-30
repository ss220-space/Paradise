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
	station_name  = "ИСН Селестион"
	station_short = "Селестиа"
	dock_name     = "АКН Трурль"
	company_name  = "НаноТрейзен"
	company_short = "НТ"
	starsys_name  = "Эпсилон Лукуста"
	webmap_url = "https://webmap.affectedarc07.co.uk/maps/ss1984/celestation/"
