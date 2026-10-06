/datum/map/lazarus
	name = "lazarus"
	map_path = "_maps/map_files/lazarus/lazarus.dmm"
	lavaland_path = "_maps/map_files/lazarus/Lavaland.dmm"
	linkage = SELFLOOPING

	station_name = "НКН Лазарь"
	english_station_name = "NSC Lazarus"
	station_short = "Лазарь"
	dock_name = "АКН Трурль"
	company_name = "\"Нанотрейзен\""
	company_short = "НТ"
	starsys_name = "Эпсилон Лукуста"

	admin_only = TRUE

	traits = list(
		list(MAIN_STATION, STATION_LEVEL = "Surface", ZTRAIT_RAIN, ZTRAIT_BASETURF = /turf/simulated/floor/planetoid/desert),
	)
