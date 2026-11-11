/obj/effect/overmap_warp_portal
	name = "варп-портал"
	desc = "TEMP123TEMP"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
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

/obj/effect/overmap_warp_portal/proc/catches(obj/overmap/entity/vessel)
	if(!is_active() || !vessel.can_enter_relay(relay) || vessel.relay_arrival_cooldown > world.time || isnull(vessel.last_world_x))
		return FALSE
	var/fraction = crossing_fraction(vessel.last_world_x, vessel.last_world_y, vessel.get_world_x(), vessel.get_world_y())
	if(isnull(fraction))
		return FALSE
	var/list/impact = vessel.find_impact(relay)
	return !impact || impact[1] >= fraction

/obj/effect/overmap_warp_portal/proc/crossing_fraction(from_x, from_y, to_x, to_y)
	var/list/previous = relay.world_to_hull(from_x, from_y)
	var/list/current = relay.world_to_hull(to_x, to_y)
	var/threshold = hull_y - capture_depth
	if(previous[2] > threshold || current[2] < threshold || current[2] <= previous[2])
		return null
	var/fraction = (threshold - previous[2]) / (current[2] - previous[2])
	var/crossing_x = previous[1] + (current[1] - previous[1]) * fraction
	return abs(crossing_x - hull_x) <= capture_radius ? fraction : null

/obj/overmap/entity/proc/can_enter_relay(obj/overmap/entity/hyperrelay/relay)
	return movable && isturf(loc) && sector == relay?.sector && !QDELETED(relay?.paired) \
		&& !is_jumping() && !is_overmap_jammed() && !docked_ship && !length(docked_guests) \
		&& !docking_approach?.aligning && !is_physically_docked() \
		&& (status == OVERMAP_STATUS_OVERMAP || status == OVERMAP_STATUS_TRANSIT)

/obj/overmap/entity/hyperrelay/proc/relay_exit_position(obj/overmap/entity/vessel)
	var/reach = hull_radius + (vessel?.hull_radius || 0) + 8
	var/heading = get_facing()
	return list(get_world_x() - sin(heading) * reach, get_world_y() - cos(heading) * reach)

/datum/controller/subsystem/overmap/proc/process_hyperrelay_portals(elapsed)
	for(var/obj/overmap/entity/vessel as anything in vessels)
		if(QDELETED(vessel))
			continue
		if(vessel.relay_capture)
			vessel.relay_capture.process_capture()
			continue
		if(!vessel.movable || !vessel.sector || vessel.is_jumping())
			continue
		for(var/obj/overmap/entity/hyperrelay/relay in vessel.sector.objects)
			if(!relay.enabled || !relay.template_loaded)
				continue
			for(var/obj/effect/overmap_warp_portal/portal as anything in relay.warp_portals)
				if(portal.catches(vessel))
					vessel.relay_capture = new /datum/overmap_relay_capture(vessel, portal)
					break
			if(vessel.relay_capture)
				break
	process_relay_drifters()

/datum/controller/subsystem/overmap/proc/process_relay_drifters()
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
			positions[thing] = list(point[1], point[2], space.sector)
			var/list/previous = relay_drifter_positions[thing]
			if(!previous || previous[3] != space.sector)
				continue
			for(var/obj/overmap/entity/hyperrelay/relay in space.sector?.objects)
				for(var/obj/effect/overmap_warp_portal/portal as anything in relay.warp_portals)
					if(portal.is_active() && !isnull(portal.crossing_fraction(previous[1], previous[2], point[1], point[2])))
						new /datum/overmap_relay_drifter_capture(thing, portal, space, point)
						break
				if(relay_drifter_captures[thing])
					break
	relay_drifter_positions = positions
