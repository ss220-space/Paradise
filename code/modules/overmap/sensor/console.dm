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
	var/map_revision = 0
	var/atom/movable/screen/map_view/camera/cam_screen
	var/datum/overmap_map_view/map_camera
	var/turf/last_map_turf
	var/map_view_min_x
	var/map_view_min_y
	var/list/atom/movable/screen/overmap_sensor_blip/contact_blips
	var/list/atom/movable/screen/overmap_sensor_radar/radar_blips
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
	var/map_zoom = 1
	var/list/atom/movable/screen/overmap_sensor_fog/fog_cells
	var/scan_min_x
	var/scan_min_y
	var/scan_max_x
	var/scan_max_y

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
	contact_blips = list()
	radar_blips = list()
	fog_cells = list()
	peel_loop = new(src, FALSE)
	var/map_name = "overmap_sensor_[src.UID()]_map"
	cam_screen = new
	cam_screen.generate_view(map_name)
	map_camera = new(cam_screen)
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
	QDEL_LIST(contact_blips)
	QDEL_LIST(radar_blips)
	QDEL_LIST(fog_cells)
	QDEL_NULL(peel_loop)
	QDEL_NULL(map_camera)
	QDEL_NULL(cam_screen)
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
	update_map_view()

/obj/machinery/computer/sensors/proc/on_overmap_moved()
	SIGNAL_HANDLER
	update_map_view()

/obj/machinery/computer/sensors/proc/on_overmap_display_changed()
	SIGNAL_HANDLER
	update_map_view(TRUE)
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
	if(!vessel?.senses_object(overmap_object))
		return FALSE
	if(overmap_object.hidden_from_contacts && overmap_object != vessel)
		return FALSE
	var/turf/here = vessel.get_overmap_turf()
	var/turf/there = overmap_object.get_overmap_turf()
	if(!here || !there || here.z != there.z)
		return FALSE
	if(vessel.sensor_pack?.always_sees(overmap_object))
		return TRUE
	return max(abs(here.x - there.x), abs(here.y - there.y)) <= extra_view()

/obj/machinery/computer/sensors/proc/hide_sensor_fog()
	for(var/atom/movable/screen/overmap_sensor_fog/cell as anything in fog_cells)
		overmap_hide_blip(cell)

/obj/machinery/computer/sensors/proc/tile_is_sensor_revealed(abs_x, abs_y)
	var/turf/here = vessel?.get_overmap_turf()
	if(!here)
		return FALSE
	var/dist = max(abs(abs_x - here.x), abs(abs_y - here.y))
	if(!dist)
		return TRUE
	return vessel.short_sensors_on && dist <= OVERMAP_SENSOR_SHORT_VIEW

/obj/machinery/computer/sensors/proc/update_sensor_fog()
	if(scanning || view_mode != OVERMAP_SENSOR_KIND_SHORT || !can_run() || !vessel?.sector || !map_view_min_x || !map_view_min_y)
		hide_sensor_fog()
		return
	var/turf/here = vessel.get_overmap_turf()
	if(!here)
		hide_sensor_fog()
		return
	var/range = extra_view()
	var/min_x = map_view_min_x
	var/min_y = map_view_min_y
	var/max_x = min(vessel.sector.playable_max_x(), here.x + range)
	var/max_y = min(vessel.sector.playable_max_y(), here.y + range)
	var/needed = (max_x - min_x + 1) * (max_y - min_y + 1)
	fog_cells = overmap_ensure_fog(fog_cells, needed, cam_screen?.assigned_map, open_uis)
	var/index = 1
	for(var/abs_x in min_x to max_x)
		for(var/abs_y in min_y to max_y)
			var/atom/movable/screen/overmap_sensor_fog/cell = fog_cells[index]
			cell.assigned_map = cam_screen.assigned_map
			if(tile_is_sensor_revealed(abs_x, abs_y))
				overmap_hide_blip(cell)
			else
				cell.alpha = 255
				cell.set_position(abs_x - min_x + 1, abs_y - min_y + 1)
			index++
	for(var/left in index to length(fog_cells))
		overmap_hide_blip(fog_cells[left])
	overmap_register_map_screens(fog_cells, cam_screen.assigned_map, open_uis)

/obj/machinery/computer/sensors/proc/register_sensor_map_overlays()
	overmap_register_map_screens(fog_cells, cam_screen?.assigned_map, open_uis)
	overmap_register_map_screens(contact_blips, cam_screen?.assigned_map, open_uis)
	overmap_register_map_screens(radar_blips, cam_screen?.assigned_map, open_uis)

/obj/machinery/computer/sensors/proc/update_contact_blips()
	if(scanning)
		for(var/atom/movable/screen/overmap_sensor_blip/blip as anything in contact_blips)
			overmap_hide_blip(blip)
		for(var/atom/movable/screen/overmap_sensor_radar/radar as anything in radar_blips)
			overmap_hide_blip(radar)
		update_scan_hull_fog()
		return
	if(!can_run())
		for(var/atom/movable/screen/overmap_sensor_blip/blip as anything in contact_blips)
			overmap_hide_blip(blip)
		for(var/atom/movable/screen/overmap_sensor_radar/radar as anything in radar_blips)
			overmap_hide_blip(radar)
		hide_sensor_fog()
		return
	update_sensor_fog()
	contact_blips = overmap_paint_sensor_ghosts(vessel, contact_blips, cam_screen?.assigned_map, map_view_min_x, map_view_min_y, extra_view(), open_uis, view_mode == OVERMAP_SENSOR_KIND_SHORT)
	radar_blips = overmap_paint_sensor_radars(vessel, radar_blips, cam_screen?.assigned_map, map_view_min_x, map_view_min_y, extra_view(), open_uis, view_mode == OVERMAP_SENSOR_KIND_SHORT)

/obj/machinery/computer/sensors/proc/update_map_view(force = FALSE)
	if(!cam_screen)
		return
	map_zoom = view_mode == OVERMAP_SENSOR_KIND_LONG ? 1 : 2
	if(!can_run() || !vessel?.sector || vessel.is_overmap_jammed())
		map_camera?.clear()
		last_map_turf = null
		update_contact_blips()
		register_sensor_map_overlays()
		return
	if(scanning)
		show_scan_view()
		update_contact_blips()
		register_sensor_map_overlays()
		return
	if(!map_camera)
		return
	var/turf/here = vessel.get_overmap_turf()
	if(!here)
		map_camera.clear()
		update_contact_blips()
		register_sensor_map_overlays()
		return
	map_camera.refresh(vessel, extra_view(), force)
	last_map_turf = map_camera.last_center
	map_view_min_x = map_camera.map_view_min_x
	map_view_min_y = map_camera.map_view_min_y
	var/pane_px = view_mode == OVERMAP_SENSOR_KIND_LONG ? 336 : 196
	map_zoom = map_camera.fit_zoom(pane_px, pane_px)
	update_contact_blips()
