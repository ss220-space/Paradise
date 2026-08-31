/obj/machinery/computer/sensors/proc/collect_scan_turfs(obj/overmap/entity/target)
	. = list()
	if(!target?.shuttle)
		return
	var/min_x = INFINITY
	var/min_y = INFINITY
	var/max_x = 0
	var/max_y = 0
	var/scan_z
	var/list/hull = list()
	for(var/area/place as anything in target.shuttle.shuttle_areas)
		for(var/turf/hull_turf in place)
			if(!scan_z)
				scan_z = hull_turf.z
			min_x = min(min_x, hull_turf.x)
			min_y = min(min_y, hull_turf.y)
			max_x = max(max_x, hull_turf.x)
			max_y = max(max_y, hull_turf.y)
			hull += hull_turf
	if(!scan_z || !length(hull))
		return
	min_x = max(1, min_x - OVERMAP_SENSOR_SCAN_PAD)
	min_y = max(1, min_y - OVERMAP_SENSOR_SCAN_PAD)
	max_x = min(world.maxx, max_x + OVERMAP_SENSOR_SCAN_PAD)
	max_y = min(world.maxy, max_y + OVERMAP_SENSOR_SCAN_PAD)
	var/size_x = max_x - min_x + 1
	var/size_y = max_y - min_y + 1
	if(size_x >= OVERMAP_SENSOR_SCAN_MAX_SIZE || size_y >= OVERMAP_SENSOR_SCAN_MAX_SIZE)
		return
	return list(
		"turfs" = block(locate(min_x, min_y, scan_z), locate(max_x, max_y, scan_z)),
		"size_x" = size_x,
		"size_y" = size_y,
		"min_x" = min_x,
		"min_y" = min_y,
		"max_x" = max_x,
		"max_y" = max_y,
	)

/obj/machinery/computer/sensors/proc/scan_turf_is_interior(turf/spot, obj/overmap/entity/target)
	if(!spot || !target?.shuttle?.shuttle_areas?[spot.loc])
		return FALSE
	for(var/direction in GLOB.cardinal)
		var/turf/neighbor = get_step(spot, direction)
		if(!neighbor || is_space_or_openspace(neighbor))
			return FALSE
	return TRUE

/obj/machinery/computer/sensors/proc/update_scan_hull_fog()
	var/obj/overmap/entity/target = scanning_target
	if(!scanning || !istype(target) || !scan_min_x || !scan_min_y)
		hide_sensor_fog()
		return
	var/list/interior = list()
	for(var/area/place as anything in target.shuttle?.shuttle_areas)
		for(var/turf/hull_turf in place)
			if(scan_turf_is_interior(hull_turf, target))
				interior += hull_turf
	fog_cells = overmap_ensure_fog(fog_cells, length(interior), cam_screen?.assigned_map, open_uis)
	var/index = 1
	for(var/turf/hidden as anything in interior)
		var/atom/movable/screen/overmap_sensor_fog/cell = fog_cells[index]
		cell.assigned_map = cam_screen.assigned_map
		cell.alpha = 255
		cell.set_position(hidden.x - scan_min_x + 1, hidden.y - scan_min_y + 1)
		index++
	for(var/left in index to length(fog_cells))
		overmap_hide_blip(fog_cells[left])
	overmap_register_map_screens(fog_cells, cam_screen.assigned_map, open_uis)

/obj/machinery/computer/sensors/proc/count_living(obj/overmap/entity/target)
	. = 0
	if(!target?.shuttle)
		return
	for(var/area/place as anything in target.shuttle.shuttle_areas)
		for(var/mob/living/body in place)
			if(body.stat == DEAD)
				continue
			.++

/obj/machinery/computer/sensors/proc/build_scan_info(obj/overmap/target, size_x, size_y)
	var/obj/overmap/entity/ship = target
	var/engines_ready = 0
	var/engines_total = 0
	var/living = 0
	var/transponder = FALSE
	if(istype(ship))
		engines_total = length(ship.engines)
		for(var/obj/machinery/ship_engine/engine as anything in ship.engines)
			if(engine.can_burn())
				engines_ready++
		living = count_living(ship)
		transponder = ship.is_overmap_visible()
	return list(
		"name" = target.get_overmap_display_name(),
		"kind" = target.overmap_kind,
		"mass" = target.get_scan_mass(),
		"living" = living,
		"engines" = engines_total,
		"engines_ready" = engines_ready,
		"speed" = round(OVERMAP_DISPLAY_SPEED(target.get_speed()), 0.01),
		"heading" = target.get_heading_angle(),
		"transponder" = transponder,
		"size_x" = size_x,
		"size_y" = size_y,
		"has_hull" = size_x && size_y,
	)

/obj/machinery/computer/sensors/proc/show_scan_view()
	if(!scanning_target || QDELETED(scanning_target))
		scan_error = "Цель сканирования потеряна."
		cam_screen.show_camera_static()
		return
	scan_error = null
	var/size_x = 0
	var/size_y = 0
	var/obj/overmap/entity/ship = scanning_target
	if(istype(ship))
		var/list/profile = collect_scan_turfs(ship)
		if(length(profile))
			size_x = profile["size_x"]
			size_y = profile["size_y"]
			scan_min_x = profile["min_x"]
			scan_min_y = profile["min_y"]
			scan_max_x = profile["max_x"]
			scan_max_y = profile["max_y"]
			map_zoom = OVERMAP_SENSOR_SCAN_VIEW_PX / (max(size_x, size_y) * world.icon_size)
			cam_screen.show_camera(profile["turfs"], size_x, size_y)
			update_scan_hull_fog()
		else
			cam_screen.show_camera_static()
			hide_sensor_fog()
	else
		cam_screen.show_camera_static()
		hide_sensor_fog()
	if(scan_finished)
		scan_info = build_scan_info(scanning_target, size_x, size_y)
	else
		scan_info = null

/obj/machinery/computer/sensors/proc/start_short_scan(obj/overmap/target)
	if(view_mode != OVERMAP_SENSOR_KIND_SHORT || !vessel?.has_working_sensor(OVERMAP_SENSOR_KIND_SHORT) || !vessel.short_sensors_on)
		return FALSE
	if(!target || QDELETED(target) || target == vessel)
		return FALSE
	if(!vessel.can_short_scan(target))
		return FALSE
	scanning = TRUE
	scanning_target = target
	selected_uid = target.UID()
	scan_error = null
	scan_info = null
	var/known = vessel.short_knows(target)
	scan_finished = known
	scan_started_at = known ? (world.time - OVERMAP_SENSOR_SCAN_TIME) : world.time
	var/scan_name = known ? target.get_overmap_display_name() : OVERMAP_UNKNOWN_NAME
	if(!known)
		vessel.add_sensor_journal("Сканирование: [scan_name]", "scan", target.get_overmap_turf(), scan_name)
	var/obj/overmap/entity/scanned = target
	if(!known && istype(scanned) && length(collect_scan_turfs(scanned)))
		scanned.play_being_scanned()
		if(scanned.has_working_sensor(OVERMAP_SENSOR_KIND_SHORT) || scanned.has_working_sensor(OVERMAP_SENSOR_KIND_LONG))
			scanned.add_sensor_journal(
				"Нас сканирует: [vessel.get_overmap_display_name()]",
				"scanned_by",
				vessel.get_overmap_turf(),
				vessel.get_overmap_display_name(),
				"bad",
			)
	if(known)
		update_map_view()
		SStgui.update_uis(src)
		return TRUE
	addtimer(CALLBACK(src, PROC_REF(complete_short_scan)), OVERMAP_SENSOR_SCAN_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)
	update_map_view()
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/sensors/proc/complete_short_scan()
	if(!scanning || scan_finished || !scanning_target || QDELETED(scanning_target))
		return
	vessel.identify_short(scanning_target)
	scan_finished = TRUE
	update_map_view()
	SStgui.update_uis(src)

/obj/machinery/computer/sensors/proc/print_scan_report()
	if(!can_print || !scan_finished || !scan_info)
		return FALSE
	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
	var/obj/item/paper/report = new(loc)
	var/scan_name = scan_info["name"]
	report.name = "Отчёт сенсора — [scan_name]"
	report.info = "<center><b>Отчёт ближнего сканера</b></center><br>"
	report.info += "<b>Время:</b> [station_time_timestamp()]<br><br>"
	report.info += "<b>Объект:</b> [scan_name]<br>"
	report.info += "<b>Тип:</b> [scan_info["kind"]]<br>"
	report.info += "<b>Масса:</b> [scan_info["mass"]] т<br>"
	report.info += "<b>Живые сигнатуры:</b> [scan_info["living"]]<br>"
	report.info += "<b>Двигатели:</b> [scan_info["engines_ready"]]/[scan_info["engines"]]<br>"
	report.info += "<b>Скорость:</b> [scan_info["speed"]]<br>"
	report.info += "<b>Курс:</b> [scan_info["heading"]]°<br>"
	report.info += "<b>Транспондер:</b> [scan_info["transponder"] ? "активен" : "молчит"]<br>"
	if(scan_info["has_hull"])
		report.info += "<b>Габарит корпуса:</b> [scan_info["size_x"]]×[scan_info["size_y"]]<br>"
	report.updateinfolinks()
	report.update_icon()
	return TRUE

/obj/machinery/computer/sensors/proc/insert_dump_paper(obj/item/paper/sheet, mob/user)
	if(!can_dump)
		return FALSE
	if(!istype(sheet) || istype(sheet, /obj/item/paper_bundle))
		return FALSE
	if(dump_paper)
		to_chat(user, span_warning("В сканере уже есть [dump_paper.declent_ru(NOMINATIVE)]. Сначала достаньте листок."))
		return FALSE
	if(!user.drop_transfer_item_to_loc(sheet, src))
		return FALSE
	dump_paper = sheet
	playsound(get_turf(src), 'sound/machines/click.ogg', 30, TRUE)
	var/atom/host = isspacepod(loc) ? loc : src
	to_chat(user, span_notice("Вы вставляете [sheet.declent_ru(ACCUSATIVE)] в сканер [host.declent_ru(GENITIVE)]."))
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/sensors/proc/eject_dump_paper(mob/user)
	if(!dump_paper)
		return FALSE
	var/obj/item/paper/sheet = dump_paper
	dump_paper = null
	if(user)
		user.put_in_hands(sheet, ignore_anim = FALSE)
		if(sheet.loc != user)
			sheet.forceMove(get_turf(user))
	else
		sheet.forceMove(get_turf(src))
	to_chat(user, span_notice("Вы достаёте [sheet.declent_ru(ACCUSATIVE)] из сканера."))
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/sensors/proc/format_sensor_dump_cipher(list/uids, source_name)
	var/count = length(uids)
	var/list/lines = list(
		"<center><b>NT-OS SENSOR ARCHIVE</b></center>",
		"<i>CODEC: MASS-SHADE / FAILSAFE</i><br>",
		"SRC: [html_encode(source_name || "UNKNOWN")]<br>",
		"BLOCKS: [count]<br>",
		"STAMP: [station_time_timestamp()]<br>",
		"<hr><tt>",
	)
	var/rows = max(count, 6)
	for(var/i in 1 to rows)
		var/piece = (i <= length(uids)) ? uids[i] : i
		var/raw = md5("[source_name]-[i]-[piece]-[world.time]")
		lines += "[copytext(raw, 1, 9)] [copytext(raw, 9, 17)] [copytext(raw, 17, 25)] [copytext(raw, 25, 33)]<br>"
	lines += "</tt><hr>"
	lines += "<i>Используйте в консоли сенсоров для загрузки известных сигнатур.</i>"
	return jointext(lines, "")

/obj/machinery/computer/sensors/proc/write_sensor_dump(mob/user)
	if(!can_dump || !dump_paper || !vessel)
		return FALSE
	var/list/payload = vessel.export_short_dump()
	dump_paper.overmap_scan_dump = payload.Copy()
	dump_paper.name = "дамп сенсоров"
	dump_paper.info = format_sensor_dump_cipher(payload, vessel.get_overmap_display_name())
	dump_paper.updateinfolinks()
	dump_paper.update_icon()
	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
	to_chat(user, span_notice("Принтер выгружает дамп ([length(payload)] записей) на листок."))
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/sensors/proc/load_sensor_dump(mob/user)
	if(!can_dump || !dump_paper || !vessel)
		return FALSE
	if(!length(dump_paper.overmap_scan_dump))
		return FALSE
	var/added = vessel.import_short_dump(dump_paper.overmap_scan_dump.Copy(), dump_paper.name)
	playsound(loc, 'sound/machines/ping.ogg', 40, FALSE)
	if(added)
		to_chat(user, span_notice("Дамп принят. Новых контактов: [added]."))
	else
		to_chat(user, span_notice("Дамп уже известен этой консоли. Новых контактов нет."))
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/sensors/proc/try_map_click(mob/user, atom/clicked)
