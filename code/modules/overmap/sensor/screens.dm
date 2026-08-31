/atom/movable/screen/overmap_sensor_fog
	name = "sensor fog"
	icon = 'icons/effects/cameravis.dmi'
	icon_state = ""
	alpha = 0
	layer = ABOVE_HUD_LAYER
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	del_on_map_removal = FALSE
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART

/atom/movable/screen/overmap_sensor_blip
	name = "sensor contact"
	icon = OVERMAP_ICON_FILE
	icon_state = "ship"
	alpha = 0
	layer = ABOVE_HUD_LAYER + 0.2
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_ICON
	del_on_map_removal = FALSE
	appearance_flags = RESET_COLOR | KEEP_APART
	var/contact_uid

/atom/movable/screen/overmap_sensor_blip/Click(location, control, params)
	if(!contact_uid)
		return ..()
	var/datum/found = locateUID(contact_uid)
	if(!istype(found, /obj/overmap))
		return ..()
	for(var/datum/tgui/open_ui as anything in usr?.tgui_open_uis)
		var/obj/machinery/computer/sensors/console = open_ui.src_object
		if(!istype(console) || console.view_mode != OVERMAP_SENSOR_KIND_SHORT)
			continue
		if(console.cam_screen?.assigned_map != assigned_map)
			continue
		if(console.try_map_click(usr, found))
			return
	return ..()

/atom/movable/screen/overmap_sensor_radar
	name = "sensor peel"
	icon = OVERMAP_SENSOR_RANGE_ICON
	icon_state = "sensor_range"
	alpha = 0
	layer = ABOVE_HUD_LAYER + 0.15
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	del_on_map_removal = FALSE
	appearance_flags = RESET_COLOR | KEEP_APART
	var/source_uid
	var/peel_at = 0

/datum/controller/subsystem/overmap/proc/relay_sensor_event(obj/overmap/source, message, kind = "info")
	if(!source || !message)
		return
	var/turf/spot = source.get_overmap_turf()
	if(!spot)
		return
	var/tone = sensor_journal_tone(kind)
	var/display_name = source.get_overmap_display_name()
	for(var/obj/overmap/entity/listener as anything in vessels)
		if(QDELETED(listener) || !listener.can_receive_sensor_log())
			continue
		if(listener.sector != source.sector)
			continue
		var/turf/here = listener.get_overmap_turf()
		if(!here || here.z != spot.z)
			continue
		if(max(abs(here.x - spot.x), abs(here.y - spot.y)) > listener.sensor_journal_range())
			continue
		listener.add_sensor_journal(message, kind, spot, display_name, tone)
