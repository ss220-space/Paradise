/obj/machinery/computer/helm
	name = "helm control console"
	desc = "Навигация корабля: карта системы, курс, автопилот."
	icon_keyboard = "teleport_key"
	icon_screen = "comm"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/helm
	var/obj/overmap/entity/vessel
	var/extra_view = OVERMAP_HELM_VIEW
	var/map_zoom = 2
	var/list/viewers = list()
	var/atom/movable/screen/map_view/camera/cam_screen
	var/datum/overmap_map_view/map_camera
	var/turf/last_map_turf

	var/list/waypoints = list()

	var/list/preset_waypoints = list()
	var/obj/machinery/computer/camera_advanced/shuttle_docker/overmap/dock_picker
	var/atom/movable/screen/overmap_nav_blip/nav_blip
	var/atom/movable/screen/overmap_self_ghost/self_ghost
	var/list/atom/movable/screen/overmap_sensor_blip/sensor_blips
	var/list/atom/movable/screen/overmap_sensor_radar/radar_blips
	var/image/inspect_nav_image
	var/image/inspect_self_ghost
	var/list/image/inspect_contact_images
	var/list/image/inspect_radar_images
	var/list/inspect_radar_peel_at
	var/map_view_min_x
	var/map_view_min_y
	var/helm_tab = "flight"
	var/list/atom/movable/screen/overmap_dock_ghost/dock_preview_ghosts

/obj/machinery/computer/helm/get_ru_names()
	return alist(
		NOMINATIVE = "консоль управления кораблём",
		GENITIVE = "консоли управления кораблём",
		DATIVE = "консоли управления кораблём",
		ACCUSATIVE = "консоль управления кораблём",
		INSTRUMENTAL = "консолью управления кораблём",
		PREPOSITIONAL = "консоли управления кораблём",
	)

/obj/machinery/computer/helm/Initialize(mapload)
	. = ..()
	GLOB.helm_computers += src
	var/map_name = "overmap_helm_[src.UID()]_map"
	cam_screen = new
	cam_screen.generate_view(map_name)
	map_camera = new(cam_screen)
	nav_blip = new
	nav_blip.assigned_map = map_name
	nav_blip.del_on_map_removal = FALSE
	self_ghost = new
	self_ghost.assigned_map = map_name
	self_ghost.del_on_map_removal = FALSE
	sensor_blips = list()
	radar_blips = list()
	inspect_contact_images = list()
	inspect_radar_images = list()
	inspect_radar_peel_at = list()
	dock_picker = new(src)
	if(SSovermap?.initialized)
		link_vessel()

/obj/machinery/computer/helm/Destroy()
	GLOB.helm_computers -= src
	for(var/mob/viewer as anything in viewers)
		unlook(viewer)
	if(vessel)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.helms -= src
	vessel = null
	QDEL_NULL(map_camera)
	QDEL_NULL(dock_picker)
	QDEL_NULL(cam_screen)
	QDEL_NULL(nav_blip)
	QDEL_NULL(self_ghost)
	QDEL_LIST(sensor_blips)
	QDEL_LIST(radar_blips)
	inspect_nav_image = null
	inspect_self_ghost = null
	clear_inspect_sensor_images()
	clear_dock_preview_ghosts()
	return ..()

/obj/machinery/computer/helm/proc/link_vessel()
	var/obj/overmap/entity/resolved = SSovermap?.resolve_vessel(src)
	if(!resolved)
		return
	if(vessel && vessel != resolved)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_DISPLAY_CHANGED))
		vessel.helms -= src
	vessel = resolved
	resolved.helms |= src
	RegisterSignal(resolved, COMSIG_OVERMAP_MOVED, PROC_REF(on_overmap_moved), override = TRUE)
	RegisterSignal(resolved, COMSIG_OVERMAP_NOTICE, PROC_REF(on_overmap_notice), override = TRUE)
	RegisterSignal(resolved, COMSIG_OVERMAP_DISPLAY_CHANGED, PROC_REF(on_overmap_display_changed), override = TRUE)
	update_map_view()

/obj/machinery/computer/helm/proc/on_overmap_moved()
	SIGNAL_HANDLER
	on_vessel_loc_changed()

/obj/machinery/computer/helm/proc/on_overmap_notice(datum/source, text)
	SIGNAL_HANDLER
	if(text)
		atom_say(text)

/obj/machinery/computer/helm/proc/on_overmap_display_changed()
	SIGNAL_HANDLER
	update_map_view(TRUE)
	SStgui.update_uis(src)
	if(length(viewers))
		refresh_inspect_positions()
		sync_inspect_camera_pixels()

/obj/machinery/computer/helm/proc/map_view_range()
	. = extra_view
	if(vessel?.has_working_sensor(OVERMAP_SENSOR_KIND_LONG) || vessel?.sees_any_foreign_peel())
		. = max(., OVERMAP_SENSOR_LONG_VIEW)
	if(vessel?.has_working_sensor(OVERMAP_SENSOR_KIND_SHORT) && vessel.short_sensors_on)
		. = max(., OVERMAP_SENSOR_SHORT_VIEW)
	. = max(., vessel?.signal_view_range() || 0)

/obj/machinery/computer/helm/proc/update_map_view(force = FALSE)
	if(!map_camera)
		return
	if(helm_tab == "dock")
		update_dock_preview()
		return
	clear_dock_preview_ghosts()
	if(!vessel?.sector || vessel.is_overmap_jammed())
		map_camera.clear()
		last_map_turf = null
		map_zoom = OVERMAP_HELM_MAP_PX / (15 * world.icon_size)
		if(vessel?.is_overmap_jammed())
			update_self_ghost()
			update_sensor_ghosts()
			update_nav_marker()
		return
	var/view_range = map_view_range()
	map_camera.refresh(vessel, view_range, force)
	map_zoom = map_camera.fit_zoom(OVERMAP_HELM_MAP_PX, OVERMAP_HELM_MAP_PX)
	last_map_turf = map_camera.last_center
	map_view_min_x = map_camera.map_view_min_x
	map_view_min_y = map_camera.map_view_min_y
	update_self_ghost()
	update_sensor_ghosts()
	update_nav_marker()

/obj/machinery/computer/helm/proc/hide_overmap_overlays()
	if(nav_blip)
		nav_blip.screen_loc = null
		nav_blip.alpha = 0
	if(self_ghost)
		self_ghost.screen_loc = null
		self_ghost.alpha = 0
	for(var/atom/movable/screen/overmap_sensor_blip/blip as anything in sensor_blips)
		overmap_hide_blip(blip)
	for(var/atom/movable/screen/overmap_sensor_radar/radar as anything in radar_blips)
		overmap_hide_blip(radar)

/obj/machinery/computer/helm/proc/clear_dock_preview_ghosts()
	for(var/atom/movable/screen/overmap_dock_ghost/ghost as anything in dock_preview_ghosts)
		overmap_hide_blip(ghost)
		qdel(ghost)
	dock_preview_ghosts = null

/obj/machinery/computer/helm/proc/update_dock_preview()
	hide_overmap_overlays()
	if(!map_camera || !cam_screen)
		return
	var/obj/docking_port/stationary/pad
	if(vessel?.selected_dock_id)
		pad = SSshuttle.getDock(vessel.selected_dock_id)
		if(istype(pad, /obj/docking_port/stationary/transit))
			pad = null
	if(!pad)
		pad = vessel?.get_selected_pad()
	if(!pad || !vessel?.shuttle || !pad.z)
		clear_dock_preview_ghosts()
		map_camera.clear()
		map_zoom = OVERMAP_HELM_MAP_PX / (15 * world.icon_size)
		return
	var/list/pairs = vessel.shuttle.overmap_move_pairs(pad)
	var/list/hull_new = pairs[2]
	var/min_x = pad.x
	var/min_y = pad.y
	var/max_x = pad.x
	var/max_y = pad.y
	for(var/turf/newT as anything in hull_new)
		if(!newT)
			continue
		min_x = min(min_x, newT.x)
		min_y = min(min_y, newT.y)
		max_x = max(max_x, newT.x)
		max_y = max(max_y, newT.y)
	min_x = max(1, min_x - 1)
	min_y = max(1, min_y - 1)
	max_x = min(world.maxx, max_x + 1)
	max_y = min(world.maxy, max_y + 1)
	var/size_x = max_x - min_x + 1
	var/size_y = max_y - min_y + 1
	var/tiles = max(size_x, size_y, 5)
	map_zoom = OVERMAP_HELM_MAP_PX / (tiles * world.icon_size)
	var/list/visible = block(locate(min_x, min_y, pad.z), locate(min_x + tiles - 1, min_y + tiles - 1, pad.z))
	cam_screen.show_camera(visible, tiles, tiles)
	map_view_min_x = min_x
	map_view_min_y = min_y
	map_camera.last_center = locate(min_x + round((tiles - 1) / 2), min_y + round((tiles - 1) / 2), pad.z)
	map_camera.last_size_x = tiles
	map_camera.last_size_y = tiles
	clear_dock_preview_ghosts()
	dock_preview_ghosts = list()
	for(var/turf/spot as anything in hull_new)
		if(!spot)
			continue
		var/atom/movable/screen/overmap_dock_ghost/ghost = new
		ghost.assigned_map = cam_screen.assigned_map
		ghost.del_on_map_removal = FALSE
		ghost.icon_state = vessel.shuttle.overmap_dest_tile_blocked(spot, pad) ? "red" : "green"
		ghost.set_position(spot.x - min_x + 1, spot.y - min_y + 1)
		dock_preview_ghosts += ghost
	overmap_register_map_screens(dock_preview_ghosts, cam_screen.assigned_map, open_uis)

/obj/machinery/computer/helm/proc/open_custom_dock_picker(mob/user)
	if(!vessel?.shuttle)
		to_chat(user, span_warning("Нет физического шаттла."))
		return FALSE
	if(!dock_picker)
		to_chat(user, span_warning("Камера посадки недоступна."))
		return FALSE
	var/obj/overmap/entity/host = vessel.get_dock_host()
	if(!host)
		to_chat(user, span_warning("Кастомную точку можно ставить только на клетке объекта с физической зоной посадки (станция, руина и т.д.)."))
		return FALSE
	if(host && !host.dock_host?.allow_custom_landing)
		to_chat(user, span_warning("Кастомная посадка здесь отключена. Используйте посадочный маяк."))
		return FALSE
	SStgui.close_uis(src)
	dock_picker.bind_landing_host(host)
	dock_picker.shuttleId = vessel.shuttle.id
	dock_picker.shuttlePortId = "[vessel.shuttle.id]_overmap_custom_[host.UID()]"
	dock_picker.shuttlePortName = "Кастомная точка ([host.name])"
	dock_picker.shuttle_port = vessel.shuttle
	dock_picker.my_port = vessel.get_custom_dock(host)
	dock_picker.stat &= ~NOPOWER
	dock_picker.attack_hand(user)
	return TRUE
