/datum/map/coldcolony
	name = "Malta"
	map_path = "_maps/map_files/event/Station/coldcolony.dmm"
	lavaland_path = "_maps/map_files/coldcolony/Lavaland.dmm"
	traits = list(MAIN_STATION, STATION_CONTACT, STATION_LEVEL = "Surface", REACHABLE, AI_OK, ZTRAIT_SNOWSTORM, ZTRAIT_BASETURF = /turf/simulated/floor/plating/asteroid/snow/planet)

	station_name = "ШОН Мальта"
	english_station_name = "NMC Malta"
	station_short = "Мальта"
	dock_name = "АКН Трурль"
	company_name = "\"Нанотрейзен\""
	company_short = "НТ"
	starsys_name = "Эпсилон Лукуста"
	admin_only = TRUE

/datum/map/delta_desert_event
	name = "Delta"
	map_path = "_maps/map_files/Delta/delta.dmm"
	lavaland_path = "_maps/map_files/event/EVENT_DESERT_PLANET.dmm"

	station_name = "ИСН Керберос"
	english_station_name = "NSS Kerberos"
	station_short = "Керберос"
	dock_name = "АКН Трурль"
	company_name = "\"Нанотрейзен\""
	company_short = "НТ"
	starsys_name = "Эпсилон Лукуста"
	webmap_url = "https://webmap.affectedarc07.co.uk/maps/ss1984/deltastation/"
	admin_only = TRUE
	forced_mode = /datum/game_mode/desert_event
	disables = DESERT_PLANET_SPAWN | DISABLE_LAVALAND | DISABLE_AWAY_MISSIONS | DISABLE_SPACE_RUINS | DISABLE_TAIPAN
