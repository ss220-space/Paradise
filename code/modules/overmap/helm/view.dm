/obj/machinery/computer/helm/proc/viewing_overmap(mob/user)
	return (user in viewers) || user.remote_control == src

/obj/machinery/computer/helm/proc/look(mob/user)
	if(!vessel)
		return
	if(vessel.is_overmap_jammed())
		to_chat(user, span_warning("Связь с овермапом потеряна из‑за помех гипертранслятора."))
		return
	if(vessel.is_programmed_locked())
		to_chat(user, span_warning("Прямое управление заблокировано поставщиком."))
		return
	user.reset_perspective(vessel)
	user.remote_control = src
	user.set_machine(src)
	if(user.client)
		user.client.pixel_x = vessel.pixel_x
		user.client.pixel_y = vessel.pixel_y
		user.client.view_size.setTo(world.view)
		winset(user, "mapwindow.map", "icon-size=[world.icon_size * OVERMAP_TILE_VISUAL_SCALE]")
	viewers |= user
	update_nav_marker()
	update_inspect_sensor_ghosts()
	to_chat(user, span_notice("Подробный просмотр карты. Клик по клетке добавляет её в навигационный буфер."))

/obj/machinery/computer/helm/proc/unlook(mob/user)
	if(!user)
		return
	if(user.client)
		user.client.pixel_x = 0
		user.client.pixel_y = 0
		user.client.view_size.resetToDefault()
		winset(user, "mapwindow.map", "icon-size=0")
		if(inspect_nav_image)
			user.client.images -= inspect_nav_image
		if(inspect_self_ghost)
			user.client.images -= inspect_self_ghost
		for(var/uid in inspect_contact_images)
			user.client.images -= inspect_contact_images[uid]
		for(var/uid in inspect_radar_images)
			user.client.images -= inspect_radar_images[uid]
	if(user.remote_control == src)
		user.remote_control = null
	user.reset_perspective(null)
	viewers -= user
	if(cam_screen)
		for(var/datum/tgui/open_ui as anything in open_uis)
			if(open_ui.user == user)
				cam_screen.display_to(user, open_ui.window)
				if(nav_blip && user.client)
					nav_blip.assigned_map = cam_screen.assigned_map
					user.client.register_map_obj(nav_blip)
				if(self_ghost && user.client)
					self_ghost.assigned_map = cam_screen.assigned_map
					user.client.register_map_obj(self_ghost)
				for(var/atom/movable/screen/overmap_sensor_blip/blip as anything in sensor_blips)
					if(user.client)
						blip.assigned_map = cam_screen.assigned_map
						user.client.register_map_obj(blip)
				for(var/atom/movable/screen/overmap_sensor_radar/radar as anything in radar_blips)
					if(user.client)
						radar.assigned_map = cam_screen.assigned_map
						user.client.register_map_obj(radar)
				break
	update_map_view()

/obj/machinery/computer/helm/check_eye(mob/user)
	if((stat & (NOPOWER|BROKEN)) || !Adjacent(user) || user.incapacitated() || !vessel)
		unlook(user)

/obj/machinery/computer/helm/relaymove(mob/living/user, direction)
	if(viewing_overmap(user))
		return TRUE
	return FALSE

/obj/machinery/computer/helm/proc/register_map_overlays(mob/user)
	if(!user?.client)
		return
	if(nav_blip)
		nav_blip.assigned_map = cam_screen.assigned_map
		user.client.register_map_obj(nav_blip)
	if(self_ghost)
		self_ghost.assigned_map = cam_screen.assigned_map
		user.client.register_map_obj(self_ghost)
	for(var/atom/movable/screen/overmap_sensor_blip/blip as anything in sensor_blips)
		blip.assigned_map = cam_screen.assigned_map
		user.client.register_map_obj(blip)
	for(var/atom/movable/screen/overmap_sensor_radar/radar as anything in radar_blips)
		radar.assigned_map = cam_screen.assigned_map
		user.client.register_map_obj(radar)

/obj/machinery/computer/helm/proc/clear_inspect_sensor_images()
	for(var/uid in inspect_contact_images)
		var/image/pic = inspect_contact_images[uid]
		for(var/mob/viewer as anything in viewers)
			viewer?.client?.images -= pic
	for(var/uid in inspect_radar_images)
		var/image/ring = inspect_radar_images[uid]
		for(var/mob/viewer as anything in viewers)
			viewer?.client?.images -= ring
	inspect_contact_images = list()
	inspect_radar_images = list()
	inspect_radar_peel_at = list()

/obj/machinery/computer/helm/proc/inspect_add_image(image/pic)
	for(var/mob/viewer as anything in viewers)
		if(viewer?.client)
			viewer.client.images |= pic

/obj/machinery/computer/helm/proc/inspect_remove_image(image/pic)
	for(var/mob/viewer as anything in viewers)
		viewer?.client?.images -= pic

/obj/machinery/computer/helm/proc/ensure_inspect_contact(obj/overmap/other, play_peel = FALSE, peak_alpha = 255, restyle = FALSE)
	if(!length(viewers) || !other || !vessel)
		return
	var/turf/here = vessel.get_overmap_turf()
	var/turf/there = other.get_overmap_turf()
	if(!here || !there || there.z != here.z)
		return
	if(max(abs(here.x - there.x), abs(here.y - there.y)) > map_view_range())
		return
	var/uid = other.UID()
	var/steady = vessel.contact_is_steady(other)
	var/image/pic = inspect_contact_images[uid]
	if(!pic)
		pic = image(OVERMAP_ICON_FILE, there, "ship", ABOVE_OBJ_LAYER)
		pic.appearance_flags = RESET_COLOR | KEEP_APART
		overmap_style_sensor_contact(pic, vessel, other, FALSE)
		pic.alpha = steady ? 255 : 0
		inspect_contact_images[uid] = pic
		inspect_add_image(pic)
	else if(restyle)
		overmap_style_sensor_contact(pic, vessel, other, FALSE)
	pic.loc = there
	pic.pixel_x = other.pixel_x
	pic.pixel_y = other.pixel_y
	if(play_peel && !steady)
		overmap_play_peel_appearance(pic, peak_alpha)
	else if(steady)
		pic.alpha = 255
	return pic

/obj/machinery/computer/helm/proc/play_inspect_radar(obj/overmap/entity/source)
	if(!length(viewers) || !source)
		return
	var/turf/here = vessel?.get_overmap_turf()
	var/turf/ring_turf = source.get_overmap_turf()
	if(!here || !ring_turf || here.z != ring_turf.z)
		return
	if(max(abs(here.x - ring_turf.x), abs(here.y - ring_turf.y)) > map_view_range())
		return
	var/uid = source.UID()
	var/image/ring = inspect_radar_images[uid]
	if(!ring)
		ring = image(OVERMAP_SENSOR_RANGE_ICON, ring_turf, "sensor_range", ABOVE_OBJ_LAYER)
		ring.appearance_flags = RESET_COLOR | KEEP_APART
		ring.color = "#5ad1ff"
		inspect_radar_images[uid] = ring
		inspect_add_image(ring)
	ring.loc = ring_turf
	ring.pixel_x = source.pixel_x
	ring.pixel_y = source.pixel_y
	if(inspect_radar_peel_at[uid] == source.sensor_peel_at)
		return
	inspect_radar_peel_at[uid] = source.sensor_peel_at
	ring.alpha = 255
	ring.transform = matrix()
	var/matrix/scale = matrix()
	scale.Scale(OVERMAP_SENSOR_LONG_VIEW * 2.6)
	animate(ring, transform = scale, alpha = 0, time = max(OVERMAP_SENSOR_TIME_DELAY * OVERMAP_SENSOR_LONG_VIEW, 1), easing = SINE_EASING)

/obj/machinery/computer/helm/proc/animate_inspect_peel(obj/overmap/other, peak_alpha = 255)
	ensure_inspect_contact(other, TRUE, peak_alpha)

/obj/machinery/computer/helm/proc/sync_inspect_camera_pixels()
	if(!vessel)
		return
	for(var/mob/viewer as anything in viewers)
		if(viewer?.client)
			viewer.client.pixel_x = vessel.pixel_x
			viewer.client.pixel_y = vessel.pixel_y

/obj/machinery/computer/helm/proc/on_vessel_loc_changed()
	update_map_view()
	if(length(viewers))
		refresh_inspect_positions()

/obj/machinery/computer/helm/proc/refresh_inspect_positions()
	if(!length(viewers) || !vessel)
		return
	for(var/uid in inspect_contact_images)
		var/datum/found = locateUID(uid)
		if(!istype(found, /obj/overmap) || QDELETED(found))
			inspect_remove_image(inspect_contact_images[uid])
			inspect_contact_images -= uid
			continue
		var/obj/overmap/overmap_object = found
		var/turf/there = overmap_object.get_overmap_turf()
		var/image/pic = inspect_contact_images[uid]
		if(!there)
			inspect_remove_image(pic)
			inspect_contact_images -= uid
			continue
		pic.loc = there
		pic.pixel_x = overmap_object.pixel_x
		pic.pixel_y = overmap_object.pixel_y
	var/list/radar_keep = list()
	if(vessel.is_sensor_peeling())
		play_inspect_radar(vessel)
		radar_keep[vessel.UID()] = TRUE
	if(vessel.sector)
		for(var/obj/overmap/other as anything in vessel.sector.objects)
			var/obj/overmap/entity/contact = other
			if(!istype(contact) || contact == vessel)
				continue
			if(contact.is_sensor_peeling() && vessel.sees_foreign_peel(contact))
				play_inspect_radar(contact)
				radar_keep[contact.UID()] = TRUE
	for(var/uid in inspect_radar_images - radar_keep)
		inspect_remove_image(inspect_radar_images[uid])
		inspect_radar_images -= uid
		inspect_radar_peel_at -= uid

/obj/machinery/computer/helm/proc/update_inspect_sensor_ghosts()
	if(!length(viewers) || !vessel?.sector)
		clear_inspect_sensor_images()
		return
	var/turf/here = vessel.get_overmap_turf()
	if(!here)
		clear_inspect_sensor_images()
		return
	var/view_range = map_view_range()
	var/list/keep = list()
	for(var/obj/overmap/overmap_object as anything in vessel.sector.objects)
		if(!overmap_object.shows_overmap_map_signature())
			continue
		if(overmap_object.visible_without_scanner && !overmap_object.icon)
			continue
		if(!vessel.senses_object(overmap_object))
			continue
		var/turf/there = overmap_object.get_overmap_turf()
		if(!there || there.z != here.z)
			continue
		if(max(abs(here.x - there.x), abs(here.y - there.y)) > view_range)
			continue
		keep[overmap_object.UID()] = TRUE
		ensure_inspect_contact(overmap_object, FALSE, 255, TRUE)
	for(var/uid in inspect_contact_images - keep)
		inspect_remove_image(inspect_contact_images[uid])
		inspect_contact_images -= uid
	refresh_inspect_positions()

/obj/machinery/computer/helm/proc/update_self_ghost()
	if(inspect_self_ghost)
		for(var/mob/viewer as anything in viewers)
			viewer?.client?.images -= inspect_self_ghost
		inspect_self_ghost = null
	if(!self_ghost)
		return
	self_ghost.alpha = 0
	self_ghost.screen_loc = null

/obj/machinery/computer/helm/proc/update_sensor_ghosts(update_inspect = TRUE)
	sensor_blips = overmap_paint_sensor_ghosts(vessel, sensor_blips, cam_screen?.assigned_map, map_view_min_x, map_view_min_y, map_view_range(), open_uis)
	radar_blips = overmap_paint_sensor_radars(vessel, radar_blips, cam_screen?.assigned_map, map_view_min_x, map_view_min_y, map_view_range(), open_uis)
	if(update_inspect)
		update_inspect_sensor_ghosts()

/obj/machinery/computer/helm/proc/update_nav_marker()
	var/turf/mark
	if(vessel?.flight?.autopilot_x && vessel.flight.autopilot_y && vessel.sector)
		mark = vessel.sector.get_turf_at(vessel.flight.autopilot_x, vessel.flight.autopilot_y)
	if(inspect_nav_image)
		for(var/mob/viewer as anything in viewers)
			viewer?.client?.images -= inspect_nav_image
	if(!mark)
		if(nav_blip)
			nav_blip.alpha = 0
			nav_blip.screen_loc = null
		inspect_nav_image = null
		return
	if(nav_blip && cam_screen && map_view_min_x && map_view_min_y)
		var/view_range = map_view_range()
		var/turf/here = vessel.get_overmap_turf()
		var/in_view = here && max(abs(here.x - mark.x), abs(here.y - mark.y)) <= view_range
		if(!in_view)
			nav_blip.alpha = 0
			nav_blip.screen_loc = null
		else
			nav_blip.assigned_map = cam_screen.assigned_map
			nav_blip.icon = OVERMAP_ICON_FILE
			nav_blip.icon_state = OVERMAP_NAV_MARKER_STATE
			nav_blip.alpha = 255
			nav_blip.set_position(mark.x - map_view_min_x + 1, mark.y - map_view_min_y + 1)
			for(var/datum/tgui/open_ui as anything in open_uis)
				if(open_ui.user?.client)
					open_ui.user.client.register_map_obj(nav_blip)
	inspect_nav_image = image(OVERMAP_ICON_FILE, mark, OVERMAP_NAV_MARKER_STATE)
	inspect_nav_image.appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	inspect_nav_image.color = "#5ad1ff"
	inspect_nav_image.layer = ABOVE_OBJ_LAYER + 0.1
	for(var/mob/viewer as anything in viewers)
		if(viewer?.client)
			viewer.client.images |= inspect_nav_image

/obj/machinery/computer/helm/proc/add_waypoint(waypoint_name, waypoint_x, waypoint_y)
	if(!waypoint_name)
		waypoint_name = "Клетка [waypoint_x]-[waypoint_y]"
	waypoints.Cut()
	waypoints[waypoint_name] = list("x" = waypoint_x, "y" = waypoint_y)
	return waypoint_name

/obj/machinery/computer/helm/proc/mark_atom(mob/user, atom/target)
	if(!viewing_overmap(user) || !vessel)
		return FALSE
	var/turf/marked = get_turf(target)
	if(!istype(marked, /turf/simulated/floor/indestructible/overmap))
		return FALSE
	var/mark_x = vessel.sector ? vessel.sector.coord_x(marked) : marked.x
	var/mark_y = vessel.sector ? vessel.sector.coord_y(marked) : marked.y
	var/waypoint_name = target == marked ? "Клетка [mark_x]-[mark_y]" : target.name
	var/saved = add_waypoint(waypoint_name, mark_x, mark_y)
	vessel.set_autopilot(vessel.flight?.autopilot, mark_x, mark_y)
	update_nav_marker()
	to_chat(user, span_notice("В буфер добавлено: [saved] ([mark_x]:[mark_y])."))
	return TRUE
