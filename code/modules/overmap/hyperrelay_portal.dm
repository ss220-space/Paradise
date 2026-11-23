/obj/effect/overmap_warp_portal
	name = "варп-портал"
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	color = COLOR_BLUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE
	var/obj/overmap/entity/hyperrelay/relay
	var/hull_x
	var/hull_y
	var/enabled = FALSE
	var/capture_depth = 2
	var/capture_radius = 3
	var/capture_duration = 2 SECONDS

/obj/effect/overmap_warp_portal/Initialize(mapload, obj/overmap/entity/hyperrelay/owner, cell_x, cell_y)
	. = ..()
	if(!istype(owner))
		return INITIALIZE_HINT_QDEL
	relay = owner
	hull_x = cell_x
	hull_y = cell_y
	set_enabled(relay.enabled)

/obj/effect/overmap_warp_portal/Destroy()
	relay?.warp_portals -= src
	relay = null
	return ..()

/obj/effect/overmap_warp_portal/proc/set_enabled(new_enabled)
	enabled = !!new_enabled && !QDELETED(relay)
	alpha = enabled ? 255 : 0

/obj/effect/overmap_warp_portal/proc/is_active()
	return enabled && !QDELETED(relay) && relay.enabled && relay.template_loaded && !QDELETED(relay.paired) && relay.paired.sector

/obj/effect/overmap_warp_portal/proc/world_position()
	return relay.hull_to_world(hull_x, hull_y)

/datum/overmap_sector/proc/relay_search_bounds()
	var/list/bounds = list()
	for(var/obj/overmap/entity/hyperrelay/relay in objects)
		if(!relay.enabled || !relay.template_loaded || QDELETED(relay) || QDELETED(relay.paired) || !relay.paired.sector)
			continue
		var/reach = 0
		for(var/obj/effect/overmap_warp_portal/portal as anything in relay.warp_portals)
			if(portal.enabled)
				var/local_x = abs(portal.hull_x - relay.hull_center_x) + portal.capture_radius
				var/local_y = abs(portal.hull_y - portal.capture_depth - relay.hull_center_y)
				reach = max(reach, local_x + local_y + 1)
		if(reach)
			bounds[relay] = list(relay.get_world_x(), relay.get_world_y(), reach)
	return bounds

/datum/overmap_sector/proc/crossed_relay_portal(list/bounds_by_sector, from_x, from_y, to_x, to_y, obj/overmap/entity/vessel)
	if(from_x == to_x && from_y == to_y)
		return null
	var/list/bounds = bounds_by_sector[src]
	if(!bounds)
		bounds = relay_search_bounds()
		bounds_by_sector[src] = bounds
	for(var/obj/overmap/entity/hyperrelay/relay as anything in bounds)
		var/list/region = bounds[relay]
		var/origin_x = region[1]
		var/origin_y = region[2]
		var/reach = region[3]
		if(max(from_x, to_x) < origin_x - reach || min(from_x, to_x) > origin_x + reach || max(from_y, to_y) < origin_y - reach || min(from_y, to_y) > origin_y + reach)
			continue
		if(vessel && !vessel.can_enter_relay(relay))
			continue
		var/facing = relay.get_facing()
		var/list/previous = relay.world_to_hull(from_x, from_y, origin_x, origin_y, facing)
		var/list/current = relay.world_to_hull(to_x, to_y, origin_x, origin_y, facing)
		var/delta_y = current[2] - previous[2]
		if(delta_y <= 0)
			continue
		var/delta_x = current[1] - previous[1]
		var/list/impact
		for(var/obj/effect/overmap_warp_portal/portal as anything in relay.warp_portals)
			var/threshold = portal.hull_y - portal.capture_depth
			if(!portal.enabled || previous[2] > threshold || current[2] < threshold)
				continue
			var/fraction = (threshold - previous[2]) / delta_y
			if(abs(previous[1] + delta_x * fraction - portal.hull_x) > portal.capture_radius)
				continue
			if(vessel && !impact)
				impact = vessel.find_impact(relay)
			if(!impact || impact[1] >= fraction)
				return portal
	return null

/obj/overmap/entity/proc/can_enter_relay(obj/overmap/entity/hyperrelay/relay)
	if(atmosphere)
		return FALSE
	return movable && isturf(loc) && sector == relay?.sector && !QDELETED(relay?.paired) \
		&& !is_jumping() && !is_overmap_jammed() && !docked_ship && !length(docked_guests) \
		&& !docking_approach?.aligning && !is_physically_docked() \
		&& (status == OVERMAP_STATUS_OVERMAP || status == OVERMAP_STATUS_TRANSIT)

/obj/overmap/entity/hyperrelay/proc/relay_exit_position(obj/overmap/entity/vessel)
	var/reach = hull_radius + (vessel?.hull_radius || 0) + 8
	var/heading = get_facing()
	return list(get_world_x() - sin(heading) * reach, get_world_y() - cos(heading) * reach)

/datum/controller/subsystem/overmap/proc/process_hyperrelay_portals(elapsed)
	var/list/bounds_by_sector = list()
	for(var/obj/overmap/entity/vessel as anything in vessels)
		if(QDELETED(vessel))
			continue
		if(vessel.relay_capture)
			vessel.relay_capture.process_capture()
			continue
		if(!vessel.movable || !vessel.sector || isnull(vessel.last_world_x) || vessel.relay_arrival_cooldown > world.time || vessel.is_jumping())
			continue
		var/obj/effect/overmap_warp_portal/portal = vessel.sector.crossed_relay_portal(bounds_by_sector, vessel.last_world_x, vessel.last_world_y, vessel.get_world_x(), vessel.get_world_y(), vessel)
		if(portal)
			vessel.relay_capture = new /datum/overmap_relay_capture(vessel, portal)
	process_relay_drifters(bounds_by_sector)

/datum/controller/subsystem/overmap/proc/process_relay_drifters(list/bounds_by_sector)
	for(var/atom/movable/thing as anything in relay_drifter_captures)
		var/datum/overmap_relay_drifter_capture/capture = relay_drifter_captures[thing]
		capture.process_capture()
	var/has_active_portal = FALSE
	for(var/obj/overmap/entity/hyperrelay/relay in GLOB.overmap_virtual_structures)
		if(relay.enabled && relay.template_loaded)
			has_active_portal = TRUE
			break
	if(!has_active_portal)
		relay_drifter_positions.Cut()
		return
	var/list/positions = list()
	for(var/datum/overmap_bubble/space as anything in bubbles)
		for(var/atom/movable/thing as anything in space.drifters)
			if(QDELETED(thing) || thing.anchored || !isturf(thing.loc) || relay_drifter_captures[thing])
				continue
			var/list/point = space.to_world(thing.x, thing.y)
			point.len = 3
			point[3] = space.sector
			positions[thing] = point
			var/list/previous = relay_drifter_positions[thing]
			if(!previous || previous[3] != space.sector)
				continue
			var/obj/effect/overmap_warp_portal/portal = space.sector?.crossed_relay_portal(bounds_by_sector, previous[1], previous[2], point[1], point[2])
			if(portal)
				new /datum/overmap_relay_drifter_capture(thing, portal, space, point)
	relay_drifter_positions = positions
