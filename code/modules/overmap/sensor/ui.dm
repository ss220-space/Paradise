/obj/machinery/computer/sensors/proc/resolve_scan_target()
	if(selected_uid)
		var/datum/found = locateUID(selected_uid)
		if(istype(found, /obj/overmap) && vessel?.can_short_scan(found))
			return found

/obj/machinery/computer/sensors/proc/sync_peel_loop()
	if(!peel_loop)
		return
	if(vessel?.long_sensors_on && !(stat & (NOPOWER|BROKEN)))
		if(!peel_loop.timer_id)
			peel_loop.start(src)
	else
		peel_loop.stop()

/obj/machinery/computer/sensors/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	if(..())
		return TRUE
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/sensors/attackby(obj/item/item, mob/living/user, params)
	if(can_dump && istype(item, /obj/item/paper) && !istype(item, /obj/item/paper_bundle))
		insert_dump_paper(item, user)
		return
	return ..()

/obj/machinery/computer/sensors/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/sensors/ui_interact(mob/user, datum/tgui/ui = null)
	if(!user.client)
		return
	user.set_machine(src)
	link_vessel()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapSensors", name)
		ui.open()
		cam_screen.display_to(user, ui.window)
		if(ui.window)
			RegisterSignal(ui.window, COMSIG_TGUI_WINDOW_VISIBLE, PROC_REF(on_sensor_window_visible), override = TRUE)
	else if(ui.window)
		cam_screen.display_to(user, ui.window)
	update_map_view()
	register_sensor_map_overlays()

/obj/machinery/computer/sensors/proc/on_sensor_window_visible(datum/tgui_window/window, client/show_to)
	SIGNAL_HANDLER
	update_map_view(TRUE)
	register_sensor_map_overlays()

/obj/machinery/computer/sensors/ui_close(mob/user)
	. = ..()
	cam_screen?.hide_from(user)
	if(user.machine == src)
		user.unset_machine()

/obj/machinery/computer/sensors/ui_status(mob/user, datum/ui_state/state)
	if(stat & (NOPOWER|BROKEN))
		return UI_CLOSE
	if(user.incapacitated())
		return UI_CLOSE
	if(!user.Adjacent(src) && !user.has_unlimited_silicon_privilege)
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/computer/sensors/proc/play_sensor_alert(kind)
	if(!kind || (stat & (NOPOWER|BROKEN)))
		return
	switch(kind)
		if("iff_lost")
			kind = "iff"
		if("undock", "dock_fail", "recall")
			kind = "dock"
	if(!alert_enabled || !alert_enabled[kind])
		return
	var/soundfile = OVERMAP_SENSOR_ALERT_SOUND
	switch(kind)
		if("distress")
			soundfile = OVERMAP_SENSOR_DISTRESS_SOUND
		if("appear")
			soundfile = OVERMAP_SENSOR_NEWCONTACT_SOUND
		if("disappear")
			soundfile = OVERMAP_SENSOR_LOST_SOUND
	playsound(src, soundfile, 30, FALSE)

/obj/machinery/computer/sensors/ui_data(mob/user)
	var/list/data = list()
	data["linked"] = !!vessel
	data["mapRef"] = cam_screen?.assigned_map
	data["view_mode"] = view_mode
	data["has_long"] = vessel?.has_working_sensor(OVERMAP_SENSOR_KIND_LONG)
	data["has_short"] = vessel?.has_working_sensor(OVERMAP_SENSOR_KIND_SHORT)
	data["long_range"] = view_mode == OVERMAP_SENSOR_KIND_LONG
	data["active"] = view_mode == OVERMAP_SENSOR_KIND_LONG ? !!vessel?.long_sensors_on : !!vessel?.short_sensors_on
	data["can_run"] = can_run()
	data["scanning"] = scanning
	data["scan_error"] = scan_error
	data["scan"] = scan_info
	data["scan_done"] = scan_finished
	data["can_print"] = can_print
	data["can_dump"] = can_dump
	data["dump_loaded"] = !!dump_paper
	data["dump_name"] = dump_paper?.name
	data["dump_has_data"] = !!length(dump_paper?.overmap_scan_dump)
	data["dump_count"] = length(dump_paper?.overmap_scan_dump)
	data["known_count"] = length(vessel?.sensor_pack?.short_identified)
	data["scan_progress"] = 0
	if(scanning)
		if(scan_finished)
			data["scan_progress"] = 1
		else
			data["scan_progress"] = clamp((world.time - scan_started_at) / OVERMAP_SENSOR_SCAN_TIME, 0, 1)
	data["selected"] = selected_uid
	data["map_zoom"] = map_zoom
	data["map_revision"] = map_revision
	data["map_jammed"] = !!vessel?.is_overmap_jammed()
	data["journal"] = vessel?.sensor_journal || list()
	var/list/alerts = list()
	alerts += list(list("id" = "appear", "label" = "Контакт", "on" = !!alert_enabled["appear"]))
	alerts += list(list("id" = "disappear", "label" = "Пропажа", "on" = !!alert_enabled["disappear"]))
	alerts += list(list("id" = "scan", "label" = "Скан", "on" = !!alert_enabled["scan"]))
	alerts += list(list("id" = "scanned_by", "label" = "Нас сканируют", "on" = !!alert_enabled["scanned_by"]))
	alerts += list(list("id" = "ping", "label" = "Пинг", "on" = !!alert_enabled["ping"]))
	alerts += list(list("id" = "distress", "label" = "Авария", "on" = !!alert_enabled["distress"]))
	alerts += list(list("id" = "iff", "label" = "Транспондер", "on" = !!alert_enabled["iff"]))
	alerts += list(list("id" = "dock", "label" = "Стыковка", "on" = !!alert_enabled["dock"]))
	data["alerts"] = alerts
	var/list/contacts = list()
	if(vessel && can_run() && !scanning && vessel.sector)
		for(var/obj/overmap/overmap_object as anything in vessel.sector.objects)
			if(!detects_contact(overmap_object))
				continue
			var/turf/there = overmap_object.get_overmap_turf()
			if(!there)
				continue
			var/short_mode = view_mode == OVERMAP_SENSOR_KIND_SHORT
			var/identified = vessel.display_identified(overmap_object, short_mode)
			var/obj/overmap/entity/scan_contact = overmap_object
			contacts += list(list(
				"ref" = overmap_object.UID(),
				"name" = identified ? overmap_object.get_overmap_display_name() : OVERMAP_UNKNOWN_NAME,
				"kind" = identified ? overmap_object.overmap_kind : "unknown",
				"x" = vessel.sector.coord_x(there),
				"y" = vessel.sector.coord_y(there),
				"is_self" = overmap_object == vessel,
				"stealth" = !identified,
				"speed" = round(OVERMAP_DISPLAY_SPEED(overmap_object.get_speed()), 0.01),
				"heading" = overmap_object.get_heading_angle(),
				"nested" = !isturf(overmap_object.loc),
				"distress" = istype(scan_contact) && scan_contact.identity_distress,
				"can_scan" = short_mode && vessel.can_short_scan(overmap_object),
			))
	data["contacts"] = contacts
	if(vessel)
		var/turf/here = vessel.get_overmap_turf()
		data["vessel_name"] = vessel.get_overmap_display_name()
		data["x"] = vessel.sector && here ? vessel.sector.coord_x(here) : here?.x
		data["y"] = vessel.sector && here ? vessel.sector.coord_y(here) : here?.y
		data["sector_name"] = vessel.sector?.name
	return data

/obj/machinery/computer/sensors/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return TRUE
	switch(action)
		if("relink")
			link_vessel()
			. = TRUE
		if("toggle_alert")
			var/alert_id = params["id"]
			if(alert_id in alert_enabled)
				alert_enabled[alert_id] = !alert_enabled[alert_id]
			. = TRUE
		if("set_mode")
			var/new_mode = params["mode"]
			if(new_mode != OVERMAP_SENSOR_KIND_LONG && new_mode != OVERMAP_SENSOR_KIND_SHORT)
				return TRUE
			if(!vessel?.has_working_sensor(new_mode))
				return TRUE
			view_mode = new_mode
			scanning = FALSE
			scanning_target = null
			scan_finished = FALSE
			scan_info = null
			map_revision++
			update_map_view(TRUE)
			. = TRUE
		if("toggle")
			if(view_mode == OVERMAP_SENSOR_KIND_LONG)
				if(!vessel?.has_working_sensor(OVERMAP_SENSOR_KIND_LONG))
					return TRUE
				vessel.set_long_sensors(!vessel.long_sensors_on)
			else
				if(!vessel?.has_working_sensor(OVERMAP_SENSOR_KIND_SHORT))
					return TRUE
				vessel.set_short_sensors(!vessel.short_sensors_on)
				if(!vessel.short_sensors_on)
					scanning = FALSE
					scanning_target = null
					scan_finished = FALSE
			update_map_view()
			. = TRUE
		if("select")
			selected_uid = params["ref"]
			. = TRUE
		if("scan")
			if(params["ref"])
				selected_uid = params["ref"]
			var/obj/overmap/target = resolve_scan_target()
			if(!start_short_scan(target))
				to_chat(usr, span_warning("Нет цели в зоне сканирования."))
			. = TRUE
		if("print_scan")
			if(!print_scan_report())
				to_chat(usr, span_warning("Нет готового отчёта."))
			. = TRUE
		if("dump_write")
			if(!write_sensor_dump(usr))
				to_chat(usr, span_warning("Сначала вставьте листок бумаги в консоль."))
			. = TRUE
		if("dump_load")
			if(!load_sensor_dump(usr))
				to_chat(usr, span_warning("На листке нет дампа сенсоров."))
			. = TRUE
		if("dump_eject")
			eject_dump_paper(usr)
			. = TRUE
		if("close_scan")
			scanning = FALSE
			scanning_target = null
			scan_error = null
			scan_info = null
			scan_finished = FALSE
			map_revision++
			scan_started_at = 0
			scan_min_x = 0
			scan_min_y = 0
			hide_sensor_fog()
			update_map_view(TRUE)
			. = TRUE

/obj/machinery/computer/sensors/process()
	sync_peel_loop()
	if(..())
		if(scanning && !scan_finished && (world.time >= scan_started_at + OVERMAP_SENSOR_SCAN_TIME))
			complete_short_scan()
		if(vessel && !scanning)
			var/turf/here = vessel.get_overmap_turf()
			if(here != last_map_turf)
				update_map_view()
		SStgui.update_uis(src)

/obj/machinery/computer/sensors/power_change(forced = FALSE)
	. = ..()
	sync_peel_loop()
	update_map_view()

/obj/machinery/computer/sensors/long_range
	view_mode = OVERMAP_SENSOR_KIND_LONG

/obj/machinery/computer/sensors/short_range
	view_mode = OVERMAP_SENSOR_KIND_SHORT

/obj/machinery/computer/sensors/short_range/pod
	name = "pod sensors"
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	density = FALSE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	can_print = FALSE

/obj/machinery/computer/sensors/short_range/pod/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER

/obj/machinery/computer/sensors/short_range/pod/powered(chan)
	return TRUE

/obj/machinery/computer/sensors/short_range/pod/link_vessel()
	var/obj/spacepod/craft = loc
	if(!isspacepod(craft) || !craft.overmap_vessel)
		return
	if(vessel && vessel != craft.overmap_vessel)
		vessel.unregister_sensor(src)
	vessel = craft.overmap_vessel
	vessel.register_sensor(src)
	view_mode = OVERMAP_SENSOR_KIND_SHORT
	update_map_view()

/obj/machinery/computer/sensors/short_range/pod/ui_status(mob/user, datum/ui_state/state)
	if(!overmap_pod_user_ok(user, loc))
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/computer/sensors/short_range/pod/ui_interact(mob/user, datum/tgui/ui = null)
	if(!vessel)
		link_vessel()
	return ..()
