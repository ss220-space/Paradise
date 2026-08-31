/proc/overmap_register_map_screens(list/screens, map_name, list/open_uis)
	if(!map_name)
		return
	for(var/atom/movable/screen/piece as anything in screens)
		if(!piece)
			continue
		piece.assigned_map = map_name
		for(var/datum/tgui/open_ui as anything in open_uis)
			if(open_ui.user?.client)
				open_ui.user.client.register_map_obj(piece)

/proc/overmap_ensure_blips(list/blips, needed, map_name, list/open_uis)
	if(!blips)
		blips = list()
	while(length(blips) < needed)
		var/atom/movable/screen/overmap_sensor_blip/blip = new
		blip.assigned_map = map_name
		blip.del_on_map_removal = FALSE
		blips += blip
	overmap_register_map_screens(blips, map_name, open_uis)
	return blips

/proc/overmap_ensure_fog(list/cells, needed, map_name, list/open_uis)
	if(!cells)
		cells = list()
	while(length(cells) < needed)
		var/atom/movable/screen/overmap_sensor_fog/cell = new
		cell.assigned_map = map_name
		cell.del_on_map_removal = FALSE
		cells += cell
	overmap_register_map_screens(cells, map_name, open_uis)
	return cells

/proc/overmap_hide_blip(atom/movable/screen/piece)
	if(!piece)
		return
	animate(piece)
	piece.alpha = 0
	piece.screen_loc = null
	piece.overlays.Cut()
	piece.transform = matrix()
	if(istype(piece, /atom/movable/screen/overmap_sensor_blip))
		var/atom/movable/screen/overmap_sensor_blip/blip = piece
		blip.contact_uid = null
	else if(istype(piece, /atom/movable/screen/overmap_sensor_radar))
		var/atom/movable/screen/overmap_sensor_radar/radar = piece
		radar.source_uid = null
		radar.peel_at = 0

/proc/overmap_play_peel_blip(atom/movable/screen/overmap_sensor_blip/blip, peak_alpha = 255)
	if(!blip || !blip.contact_uid)
		return
	overmap_play_peel_appearance(blip, peak_alpha)

/proc/overmap_play_peel_appearance(atom/target, peak_alpha = 255)
	if(!target)
		return
	animate(target, alpha = peak_alpha, time = OVERMAP_SENSOR_PEEL_IN, easing = LINEAR_EASING)
	animate(alpha = peak_alpha, time = OVERMAP_SENSOR_PEEL_HOLD)
	animate(alpha = 0, time = OVERMAP_SENSOR_PEEL_OUT, easing = LINEAR_EASING)

/proc/overmap_play_radar_animate(atom/movable/screen/overmap_sensor_radar/radar, peel_at, view_range)
	if(!radar || !peel_at)
		return
	if(radar.peel_at == peel_at)
		return
	radar.peel_at = peel_at
	radar.alpha = 255
	radar.transform = matrix()
	var/matrix/scale = matrix()
	scale.Scale(view_range * 2.6)
	animate(radar, transform = scale, alpha = 0, time = max(OVERMAP_SENSOR_TIME_DELAY * view_range, 1), easing = SINE_EASING)

/proc/overmap_style_sensor_contact(atom/appearance_holder, obj/overmap/entity/vessel, obj/overmap/overmap_object, apply_alpha = TRUE, force_unknown = FALSE)
	var/via_signal = vessel?.display_identified(overmap_object, force_unknown)
	appearance_holder.overlays.Cut()
	if(via_signal)
		appearance_holder.icon = overmap_object.icon || OVERMAP_ICON_FILE
		appearance_holder.icon_state = overmap_object.icon_state
		appearance_holder.color = overmap_object.color
		appearance_holder.dir = overmap_object.dir
		appearance_holder.transform = overmap_object.transform
		appearance_holder.overlays += overmap_object.overlays
	else
		appearance_holder.icon = OVERMAP_ICON_FILE
		appearance_holder.icon_state = "ship"
		appearance_holder.color = "#fffffe"
		appearance_holder.dir = SOUTH
		appearance_holder.transform = matrix()
	if(apply_alpha)
		appearance_holder.alpha = vessel ? vessel.contact_map_alpha(overmap_object) : 255

/proc/overmap_paint_sensor_ghosts(obj/overmap/entity/vessel, list/blips, map_name, min_x, min_y, view_range, list/open_uis, force_unknown = FALSE)
	if(!vessel || !map_name || !min_x || !min_y)
		for(var/atom/movable/screen/overmap_sensor_blip/blip as anything in blips)
			overmap_hide_blip(blip)
		return blips
	var/list/shown = list()
	var/turf/here = vessel.get_overmap_turf()
	if(here && vessel.sector)
		for(var/obj/overmap/overmap_object as anything in vessel.sector.objects)
			if(!overmap_object.shows_overmap_map_signature())
				continue
			if(overmap_object.visible_without_scanner && !overmap_object.icon)
				continue
			if(!vessel.senses_object(overmap_object) && !vessel.sees_foreign_peel(overmap_object))
				continue
			var/turf/there = overmap_object.get_overmap_turf()
			if(!there || there.z != here.z)
				continue
			if(max(abs(here.x - there.x), abs(here.y - there.y)) > view_range)
				continue
			shown += overmap_object
	var/list/old_by_uid = list()
	var/list/pool = list()
	for(var/atom/movable/screen/overmap_sensor_blip/blip as anything in blips)
		if(blip.contact_uid)
			old_by_uid[blip.contact_uid] = blip
		else
			pool += blip
	var/list/new_blips = list()
	for(var/obj/overmap/overmap_object as anything in shown)
		var/uid = overmap_object.UID()
		var/atom/movable/screen/overmap_sensor_blip/blip = old_by_uid[uid]
		if(blip)
			old_by_uid -= uid
		else if(length(pool))
			blip = pool[1]
			pool.Cut(1, 2)
		else
			blip = new
			blip.del_on_map_removal = FALSE
		var/reused = (blip.contact_uid == uid)
		var/steady = vessel.contact_is_steady(overmap_object)
		var/identified = vessel.display_identified(overmap_object, force_unknown)
		if(!reused || steady || identified)
			overmap_style_sensor_contact(blip, vessel, overmap_object, steady, force_unknown)
		if(steady)
			blip.alpha = vessel.contact_map_alpha(overmap_object)
		else if(!reused)
			blip.alpha = 0
		blip.contact_uid = uid
		blip.assigned_map = map_name
		var/turf/there = overmap_object.get_overmap_turf()
		blip.set_position(there.x - min_x + 1, there.y - min_y + 1, overmap_object.pixel_x, overmap_object.pixel_y)
		new_blips += blip
	for(var/leftover_uid in old_by_uid)
		overmap_hide_blip(old_by_uid[leftover_uid])
		new_blips += old_by_uid[leftover_uid]
	for(var/atom/movable/screen/overmap_sensor_blip/spare as anything in pool)
		overmap_hide_blip(spare)
		new_blips += spare
	overmap_register_map_screens(new_blips, map_name, open_uis)
	return new_blips

/proc/overmap_ensure_radars(list/radars, needed, map_name, list/open_uis)
	if(!radars)
		radars = list()
	while(length(radars) < needed)
		var/atom/movable/screen/overmap_sensor_radar/radar = new
		radar.assigned_map = map_name
		radar.del_on_map_removal = FALSE
		radars += radar
	overmap_register_map_screens(radars, map_name, open_uis)
	return radars

/proc/overmap_radar_progress(obj/overmap/entity/source)
	if(!source?.sensor_peel_at)
		return null
	var/elapsed = world.time - source.sensor_peel_at
	var/duration = max(OVERMAP_SENSOR_TIME_DELAY * OVERMAP_SENSOR_LONG_VIEW, 1)
	if(elapsed < 0 || elapsed > duration)
		return null
	return elapsed / duration

/proc/overmap_paint_sensor_radars(obj/overmap/entity/vessel, list/radars, map_name, min_x, min_y, view_range, list/open_uis, include_local_short = FALSE)
	if(!vessel || !map_name || !min_x || !min_y)
		for(var/atom/movable/screen/overmap_sensor_radar/radar as anything in radars)
			overmap_hide_blip(radar)
		return radars
	var/list/shown = list()
	var/local_short = include_local_short && vessel.short_sensors_on && vessel.short_peel_at && !vessel.is_sensor_peeling()
	var/turf/here = vessel.get_overmap_turf()
	if(here && vessel.sector)
		if(vessel.is_sensor_peeling() || local_short)
			shown += vessel
		for(var/obj/overmap/other as anything in vessel.sector.objects)
			var/obj/overmap/entity/contact = other
			if(!istype(contact) || contact == vessel)
				continue
			if(!contact.is_sensor_peeling() || !vessel.sees_foreign_peel(contact))
				continue
			var/turf/there = contact.get_overmap_turf()
			if(!there || there.z != here.z)
				continue
			if(max(abs(here.x - there.x), abs(here.y - there.y)) > view_range)
				continue
			shown += contact
	var/list/old_by_uid = list()
	var/list/pool = list()
	for(var/atom/movable/screen/overmap_sensor_radar/radar as anything in radars)
		if(radar.source_uid)
			old_by_uid[radar.source_uid] = radar
		else
			pool += radar
	var/list/new_radars = list()
	for(var/obj/overmap/entity/source as anything in shown)
		var/uid = source.UID()
		var/atom/movable/screen/overmap_sensor_radar/radar = old_by_uid[uid]
		if(radar)
			old_by_uid -= uid
		else if(length(pool))
			radar = pool[1]
			pool.Cut(1, 2)
		else
			radar = new
			radar.del_on_map_removal = FALSE
		var/turf/there = source.get_overmap_turf()
		radar.assigned_map = map_name
		radar.icon = OVERMAP_SENSOR_RANGE_ICON
		radar.icon_state = "sensor_range"
		radar.color = "#5ad1ff"
		radar.source_uid = uid
		radar.set_position(there.x - min_x + 1, there.y - min_y + 1, source.pixel_x, source.pixel_y)
		if(source == vessel && local_short)
			overmap_play_radar_animate(radar, source.short_peel_at, OVERMAP_SENSOR_SHORT_VIEW)
		else
			overmap_play_radar_animate(radar, source.sensor_peel_at, OVERMAP_SENSOR_LONG_VIEW)
		new_radars += radar
	for(var/leftover_uid in old_by_uid)
		overmap_hide_blip(old_by_uid[leftover_uid])
		new_radars += old_by_uid[leftover_uid]
	for(var/atom/movable/screen/overmap_sensor_radar/spare as anything in pool)
		overmap_hide_blip(spare)
		new_radars += spare
	overmap_register_map_screens(new_radars, map_name, open_uis)
	return new_radars
