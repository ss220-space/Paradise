/proc/overmap_open_sensor_console(mob/user)
	if(!user)
		return
	for(var/datum/tgui/open_ui as anything in user.tgui_open_uis)
		if(istype(open_ui.src_object, /obj/machinery/computer/sensors))
			return open_ui.src_object

/obj/machinery/computer/sensors
	name = "sensor control console"
	desc = "Управление сканерами судна. Нужен соответствующий массив: дальний, ближний или оба."
	icon_keyboard = "tech_key"
	icon_screen = "cameras"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/sensors
	var/obj/overmap/entity/vessel
	var/view_mode = OVERMAP_SENSOR_KIND_LONG
	var/turf/last_map_turf
	var/scanning = FALSE
	var/obj/overmap/scanning_target
	var/selected_uid
	var/scan_error
	var/list/scan_info
	var/scan_started_at = 0
	var/scan_finished = FALSE
	var/can_print = TRUE

	var/can_dump = TRUE
	var/obj/item/paper/dump_paper
	var/datum/looping_sound/overmap_sensor_peel/peel_loop

	var/list/alert_enabled

/obj/machinery/computer/sensors/get_ru_names()
	return alist(
		NOMINATIVE = "консоль сенсоров",
		GENITIVE = "консоли сенсоров",
		DATIVE = "консоли сенсоров",
		ACCUSATIVE = "консоль сенсоров",
		INSTRUMENTAL = "консолью сенсоров",
		PREPOSITIONAL = "консоли сенсоров",
	)

/obj/machinery/computer/sensors/Initialize(mapload)
	. = ..()
	GLOB.sensor_computers += src
	peel_loop = new(src, FALSE)
	alert_enabled = list(
		"appear" = TRUE,
		"disappear" = TRUE,
		"scan" = TRUE,
		"scanned_by" = TRUE,
		"ping" = TRUE,
		"distress" = TRUE,
		"iff" = TRUE,
		"dock" = TRUE,
	)
	if(SSovermap?.initialized)
		link_vessel()

/obj/machinery/computer/sensors/Destroy()
	GLOB.sensor_computers -= src
	if(vessel)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.unregister_sensor(src)
	vessel = null
	if(dump_paper)
		dump_paper.forceMove(get_turf(src))
		dump_paper = null
	QDEL_NULL(peel_loop)
	return ..()

/obj/machinery/computer/sensors/proc/link_vessel()
	var/obj/overmap/entity/resolved = SSovermap?.resolve_vessel(src)
	if(!resolved)
		return
	if(vessel && vessel != resolved)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.unregister_sensor(src)
	resolved.register_sensor(src)
	RegisterSignal(resolved, COMSIG_OVERMAP_MOVED, PROC_REF(on_overmap_moved), override = TRUE)
	RegisterSignal(resolved, COMSIG_OVERMAP_DISPLAY_CHANGED, PROC_REF(on_overmap_display_changed), override = TRUE)
	if(!resolved.has_working_sensor(view_mode))
		if(resolved.has_working_sensor(OVERMAP_SENSOR_KIND_LONG))
			view_mode = OVERMAP_SENSOR_KIND_LONG
		else if(resolved.has_working_sensor(OVERMAP_SENSOR_KIND_SHORT))
			view_mode = OVERMAP_SENSOR_KIND_SHORT
	update_scan_info()

/obj/machinery/computer/sensors/proc/on_overmap_moved()
	SIGNAL_HANDLER
	update_scan_info()

/obj/machinery/computer/sensors/proc/on_overmap_display_changed()
	SIGNAL_HANDLER
	update_scan_info(TRUE)
	SStgui.update_uis(src)

/obj/machinery/computer/sensors/proc/extra_view()
	return view_mode == OVERMAP_SENSOR_KIND_LONG ? max(OVERMAP_SENSOR_LONG_VIEW, vessel?.signal_view_range() || 0) : OVERMAP_SENSOR_SHORT_VIEW

/obj/machinery/computer/sensors/proc/can_run()
	if(stat & (NOPOWER|BROKEN) || !vessel)
		return FALSE
	if(!vessel.has_working_sensor(view_mode))
		return FALSE
	if(view_mode == OVERMAP_SENSOR_KIND_LONG)
		return vessel.has_working_sensor(OVERMAP_SENSOR_KIND_LONG)
	return TRUE

/obj/machinery/computer/sensors/proc/detects_contact(obj/overmap/overmap_object)
	return vessel && vessel.object_visibility(overmap_object, vessel.get_overmap_turf(), vessel.sensor_reach_cells()) > 0

/obj/machinery/computer/sensors/proc/update_scan_info(force = FALSE)
	last_map_turf = vessel?.get_overmap_turf()
	if(scanning)
		show_scan_view()
