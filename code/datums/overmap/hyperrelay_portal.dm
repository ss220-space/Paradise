/datum/overmap_relay_capture
	var/obj/overmap/entity/vessel
	var/obj/effect/overmap_warp_portal/portal
	var/started
	var/start_x
	var/start_y
	var/was_halted

/datum/overmap_relay_capture/New(obj/overmap/entity/craft, obj/effect/overmap_warp_portal/entrance)
	vessel = craft
	portal = entrance
	started = world.time
	start_x = vessel.get_world_x()
	start_y = vessel.get_world_y()
	was_halted = vessel.halted
	vessel.halted = TRUE
	vessel.speed = list(0, 0)
	vessel.flight?.set_autopilot(FALSE, manual = FALSE)
	vessel.flight?.release_pilot()
	if(vessel.flight)
		vessel.flight.angular_velocity = 0

/datum/overmap_relay_capture/Destroy()
	if(!QDELETED(vessel) && vessel.relay_capture == src)
		vessel.relay_capture = null
		vessel.halted = was_halted
	vessel = null
	portal = null
	return ..()

/datum/overmap_relay_capture/proc/process_capture()
	if(QDELETED(vessel) || QDELETED(portal) || !portal.is_active() || !vessel.can_enter_relay(portal.relay))
		qdel(src)
		return
	var/fraction = clamp((world.time - started) / max(1, portal.capture_duration), 0, 1)
	var/list/target = portal.world_position()
	var/eased = fraction * fraction
	vessel.set_world_position(start_x + (target[1] - start_x) * eased, start_y + (target[2] - start_y) * eased)
	if(fraction < 1)
		return
	var/obj/overmap/entity/craft = vessel
	var/obj/effect/overmap_warp_portal/entrance = portal
	qdel(src)
	craft.begin_hyperrelay_jump(portal = entrance)

/datum/overmap_relay_drifter_capture
	var/atom/movable/drifter
	var/obj/effect/overmap_warp_portal/portal
	var/datum/overmap_bubble/source_space
	var/turf/origin
	var/started
	var/transfer_ends = 0
	var/start_x
	var/start_y
	var/was_anchored
	var/was_phasing
	var/was_dense

/datum/overmap_relay_drifter_capture/New(atom/movable/thing, obj/effect/overmap_warp_portal/entrance, datum/overmap_bubble/space, list/position)
	drifter = thing
	portal = entrance
	source_space = space
	origin = get_turf(thing)
	started = world.time
	start_x = position[1]
	start_y = position[2]
	was_anchored = drifter.anchored
	was_phasing = drifter.movement_type & PHASING
	was_dense = drifter.density
	drifter.anchored = TRUE
	drifter.density = FALSE
	drifter.movement_type |= PHASING
	ADD_TRAIT(drifter, TRAIT_IMMOBILIZED, UID())
	if(drifter.throwing)
		qdel(drifter.throwing)
		drifter.end_throw()
	SEND_SIGNAL(drifter, COMSIG_MOVABLE_NEWTONIAN_MOVE, NONE)
	SSovermap.relay_drifter_captures[drifter] = src

/datum/overmap_relay_drifter_capture/Destroy()
	SSovermap.relay_drifter_captures -= drifter
	if(!QDELETED(drifter))
		drifter.anchored = was_anchored
		drifter.density = was_dense
		if(!was_phasing)
			drifter.movement_type &= ~PHASING
		REMOVE_TRAIT(drifter, TRAIT_IMMOBILIZED, UID())
		if(!drifter.loc && origin)
			drifter.forceMove(origin)
			if(!QDELETED(source_space))
				source_space.add_drifter(drifter)
	drifter = null
	portal = null
	source_space = null
	origin = null
	return ..()

/datum/overmap_relay_drifter_capture/proc/process_capture()
	if(QDELETED(drifter))
		qdel(src)
		return
	if(transfer_ends)
		if(world.time >= transfer_ends)
			finish_transfer()
		return
	if(QDELETED(portal) || !portal.is_active() || QDELETED(source_space))
		qdel(src)
		return
	var/fraction = clamp((world.time - started) / max(1, portal.capture_duration), 0, 1)
	var/list/target = portal.world_position()
	var/eased = fraction * fraction
	var/turf/spot = source_space.turf_at(start_x + (target[1] - start_x) * eased, start_y + (target[2] - start_y) * eased)
	if(!spot)
		qdel(src)
		return
	drifter.forceMove(spot)
	if(fraction < 1)
		return
	transfer_ends = world.time + portal.relay.hyperrelay_jump_duration(portal.relay)
	source_space.remove_drifter(drifter)
	drifter.moveToNullspace()

/datum/overmap_relay_drifter_capture/proc/finish_transfer()
	var/obj/overmap/entity/hyperrelay/destination = portal?.relay?.paired
	if(QDELETED(destination) || !destination.sector || world.time > transfer_ends + (10 SECONDS))
		qdel(src)
		return
	var/list/exit = destination.relay_exit_position()
	var/datum/overmap_bubble/space = SSovermap.local_space_at(destination.sector, exit[1], exit[2]) || SSovermap.find_bubble(destination.sector, exit[1], exit[2])
	if(!space)
		space = SSovermap.create_bubble(destination.sector, exit[1], exit[2], 0, 0)
	var/turf/spot = space?.turf_at(exit[1], exit[2])
	if(!spot)
		SSovermap.prepare_bubble_space()
		return
	drifter.forceMove(spot)
	space.add_drifter(drifter)
	qdel(src)

/datum/overmap_programmed_mission/proc/navigate_relay_portal(obj/overmap/entity/hyperrelay/relay)
	if(!relay.enabled || !length(relay.warp_portals) || !vessel.flight)
		return
	var/obj/effect/overmap_warp_portal/portal = relay.warp_portals[1]
	if(relay_route_portal != portal)
		relay_route_portal = portal
		relay_route_aligned = FALSE
	var/local_y = portal.hull_y
	if(!relay_route_aligned)
		local_y -= relay.hull_radius + vessel.hull_radius + portal.capture_depth + 8
	var/list/target = relay.hull_to_world(portal.hull_x, local_y)
	vessel.flight.cruise_speed = OVERMAP_FROM_DISPLAY(OVERMAP_PROGRAMMED_CRUISE)
	vessel.flight.navigate_world(target[1], target[2], relay.get_facing(), relay_route_aligned ? relay : null, arrival_range = 0.25, known_obstacles_only = FALSE)
