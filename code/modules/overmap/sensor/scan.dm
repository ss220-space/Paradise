/obj/machinery/computer/sensors/proc/scan_subject(obj/overmap/target)
	var/obj/overmap/feature/hazard/asteroid/taipan_cover/cover = target
	if(istype(cover) && !QDELETED(cover.mask_host))
		return cover.mask_host
	return target

/obj/machinery/computer/sensors/proc/count_living(obj/overmap/entity/target)
	. = 0
	if(!istype(target))
		return
	if(target.shuttle)
		for(var/area/place as anything in target.shuttle.shuttle_areas)
			for(var/mob/living/body in place)
				if(body.stat == DEAD)
					continue
				.++
		return
	if(!target.dock_host?.area_root)
		return
	for(var/area/place as anything in target.dock_host.host_areas())
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
	if(QDELETED(scanning_target))
		scan_error = "Цель сканирования потеряна."
		return
	scan_error = null
	var/obj/overmap/subject = scan_subject(scanning_target)
	var/obj/overmap/entity/ship = subject
	var/size_x = 0
	var/size_y = 0
	if(istype(ship) && ship.shuttle)
		size_x = ship.shuttle.width
		size_y = ship.shuttle.height
	scan_info = scan_finished ? build_scan_info(subject, size_x, size_y) : null
	if(scan_info && scanning_target != subject)
		scan_info["name"] = scanning_target.get_overmap_display_name()

/obj/machinery/computer/sensors/proc/start_short_scan(obj/overmap/target)
	if(view_mode != OVERMAP_SENSOR_KIND_SHORT || !can_run() || !vessel.short_sensors_on || QDELETED(target) || target == vessel || !vessel.can_short_scan(target))
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
	var/obj/overmap/entity/scanned = scan_subject(target)
	if(!known && istype(scanned) && (scanned.shuttle || scanned.dock_host?.area_root))
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
		update_scan_info()
		SStgui.update_uis(src)
		return TRUE
	addtimer(CALLBACK(src, PROC_REF(complete_short_scan)), OVERMAP_SENSOR_SCAN_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)
	update_scan_info()
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/sensors/proc/complete_short_scan()
	if(!scanning || scan_finished || !scanning_target || QDELETED(scanning_target))
		return

	if(!can_run() || !vessel.short_sensors_on || !vessel.can_short_scan(scanning_target))
		scanning = FALSE
		scan_error = "Цель вышла из зоны сканирования."
		scan_info = null
		SStgui.update_uis(src)
		return
	var/list/cluster = list()
	var/obj/overmap/feature/hazard/point = scanning_target
	if(istype(point) && point.sector)
		cluster = overmap_hazard_cluster_of(point.sector, point)
	if(length(cluster))
		vessel.identify_short_many(cluster)
	else
		vessel.identify_short(scanning_target)
	scan_finished = TRUE
	update_scan_info()
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

/proc/overmap_write_dump_paper(obj/item/paper/sheet, list/uids, source_name)
	if(!sheet)
		return null
	sheet.overmap_scan_dump = uids?.Copy() || list()
	sheet.name = "дамп сенсоров"
	var/obj/machinery/computer/sensors/format_host = locate() in GLOB.sensor_computers
	if(format_host)
		sheet.info = format_host.format_sensor_dump_cipher(sheet.overmap_scan_dump, source_name)
	else
		sheet.info = "NT-OS SENSOR ARCHIVE<br>BLOCKS: [length(sheet.overmap_scan_dump)]"
	sheet.updateinfolinks()
	sheet.update_icon()
	return sheet

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
	if(!user || !clicked || view_mode != OVERMAP_SENSOR_KIND_SHORT)
		return FALSE
	if(!vessel?.short_sensors_on || !vessel.has_working_sensor(OVERMAP_SENSOR_KIND_SHORT))
		return FALSE
	var/obj/overmap/target
	if(istype(clicked, /obj/overmap))
		target = clicked
	else
		var/turf/spot = get_turf(clicked)
		if(!spot)
			return FALSE
		for(var/obj/overmap/candidate in spot)
			if(candidate == vessel)
				continue
			if(vessel.can_short_scan(candidate))
				target = candidate
				break
			if(!target)
				target = candidate
		if(!target)
			for(var/obj/overmap/candidate as anything in vessel.sector?.objects)
				if(candidate == vessel || candidate.get_overmap_turf() != spot)
					continue
				if(vessel.can_short_scan(candidate))
					target = candidate
					break
				if(!target)
					target = candidate
	if(!target || target == vessel)
		return FALSE
	if(!start_short_scan(target))
		return FALSE
	SStgui.update_uis(src)
	return TRUE
