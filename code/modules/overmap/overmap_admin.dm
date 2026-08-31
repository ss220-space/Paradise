// УДАЛИТЬ УДАЛИТЬ  УДАЛИТЬ УДАЛИТЬ  УДАЛИТЬ УДАЛИТЬ  УДАЛИТЬ УДАЛИТЬ  УДАЛИТЬ УДАЛИТЬ  УДАЛИТЬ УДАЛИТЬ  УДАЛИТЬ УДАЛИТЬ  УДАЛИТЬ УДАЛИТЬ  УДАЛИТЬ УДАЛИТЬ ХУЙ ХУЙ ХУЙ

ADMIN_VERB(spawn_overmap_test_kit, R_ADMIN|R_DEBUG|R_SPAWN, "Spawn Overmap Test Kit", "Спавнит руль, консоль двигателей и infinite-двигатель у ног.", ADMIN_CATEGORY_DEBUG)
	var/turf/here = get_turf(user.mob)
	if(!here)
		return
	new /obj/machinery/computer/helm(here)
	new /obj/machinery/computer/engines(get_step(here, EAST) || here)
	new /obj/machinery/ship_engine/infinite(get_step(here, WEST) || here)
	new /obj/machinery/transponder(get_step(here, SOUTH) || here)
	new /obj/machinery/computer/sensors(get_step(here, NORTH) || here)
	new /obj/machinery/sensor_array/long_range(get_step(here, NORTHEAST) || here)
	new /obj/machinery/sensor_array/short_range(get_step(here, NORTHWEST) || here)
	to_chat(user, span_notice("Overmap test kit spawned."), confidential = TRUE)
	log_admin("[key_name(user)] spawned an overmap test kit at [COORD(here)]")
	BLACKBOX_LOG_ADMIN_VERB("Spawn Overmap Test Kit")

ADMIN_VERB(spawn_overmap_warp_portal, R_ADMIN|R_EVENT, "Spawn Overmap Warp Portal", "Создаёт сектор-назначение (если нет) и портал на текущей клетке станции.", ADMIN_CATEGORY_EVENTS)
	if(!SSovermap?.local_sector || !SSovermap.station_entity)
		to_chat(user, span_warning("Overmap не инициализирован."), confidential = TRUE)
		return
	var/sector_id = tgui_input_text(user, "ID целевого сектора", "Warp portal", "centcom")
	if(!sector_id)
		return
	var/sector_name = tgui_input_text(user, "Имя сектора", "Warp portal", "CentCom")
	if(!sector_name)
		return
	var/datum/overmap_sector/target = SSovermap.sectors[sector_id]
	if(!target)
		target = SSovermap.create_sector(sector_id, sector_name, OVERMAP_DEFAULT_SIZE, OVERMAP_ACCESS_CENTCOM)
	var/obj/overmap/portal/portal = SSovermap.spawn_portal(SSovermap.local_sector, sector_id, "Warp: [sector_name]", OVERMAP_VESSEL_WARP)
	if(!portal)
		to_chat(user, span_warning("Не удалось создать портал."), confidential = TRUE)
		return
	to_chat(user, span_notice("Портал '[portal.name]' в секторе [sector_id] на [portal.x]:[portal.y]. Нужен флаг WARP на судне."), confidential = TRUE)
	log_admin("[key_name(user)] spawned overmap portal [portal.name] -> [sector_id]")
	BLACKBOX_LOG_ADMIN_VERB("Spawn Overmap Warp Portal")
