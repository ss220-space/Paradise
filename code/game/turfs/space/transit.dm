/turf/space/transit
	name = "\proper hyperspace"
	icon_state = "black_arrow"
	baseturf = /turf/space/transit
	turf_flags = NOJAUNT

/turf/space/transit/north
	dir = NORTH

/turf/space/transit/east
	dir = EAST

/turf/space/transit/south

/turf/space/transit/west
	dir = WEST

/turf/space/transit/pod
	dir = SOUTH

/turf/space/transit/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TURF_RESERVATION_RELEASED, PROC_REF(launch_contents))

/turf/space/transit/Destroy()
	//Signals are NOT removed from turfs upon replacement, and we get replaced ALOT, so unregister our signal
	UnregisterSignal(src, list(COMSIG_TURF_RESERVATION_RELEASED))

	return ..()

/turf/space/transit/attackby(obj/item/I, mob/user, params)
	//Overwrite because we dont want people building rods in space.
	return ATTACK_CHAIN_BLOCKED_ALL

///Get rid of all our contents, called when our reservation is released (which in our case means the shuttle arrived)
/turf/space/transit/proc/launch_contents(datum/turf_reservation/reservation)
	SIGNAL_HANDLER

	for(var/atom/movable/movable in contents)
		dump_in_space(movable)

/turf/space/transit/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!arrived)
		return
	if(!arrived.simulated || istype(arrived, /obj/docking_port))
		return //this was fucking hilarious, the docking ports were getting thrown to random Z-levels
	if(isobserver(arrived))
		return
	if(istype(src, /turf/space/transit/pod))
		return
	if(isspacepod(arrived))
		var/obj/spacepod/craft = arrived
		if(craft.overmap_vessel?.overmap_pod?.is_in_own_pocket())
			return
	dump_in_space(arrived)

/proc/dump_in_space(atom/movable/dumpee)
	var/turf/origin = get_turf(dumpee)
	if(istype(origin, /turf/space/transit))
		if(isspacepod(dumpee))
			var/obj/spacepod/craft = dumpee
			if(craft.overmap_vessel?.overmap_pod?.enter_hyperspace())
				return
		var/datum/turf_reservation/reservation = SSmapping.used_turfs[origin]
		var/obj/docking_port/mobile/shuttle = get_shuttle_for_transit_reservation(reservation)
		var/turf/shuttle_turf = shuttle && get_turf(shuttle)
		if(shuttle_turf && !istype(shuttle_turf, /turf/space/transit))
			dump_near_shuttle_in_real_space(dumpee, shuttle)
			return
		if(hyperspace_too_close_to_border(origin))
			delete_lost_in_hyperspace(dumpee)
			return
		expose_to_hyperspace(dumpee)
		return

	dump_to_linked_space_edge(dumpee)

/proc/hyperspace_reservation_bounds(datum/turf_reservation/reservation)
	if(!reservation || !length(reservation.bottom_left_turfs) || !length(reservation.top_right_turfs))
		return null
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	var/turf/top_right = reservation.top_right_turfs[1]
	return list(bottom_left.x, bottom_left.y, top_right.x, top_right.y)

/proc/hyperspace_too_close_to_border(turf/spot)
	if(!istype(spot, /turf/space/transit))
		return FALSE
	var/datum/turf_reservation/reservation = SSmapping.used_turfs[spot]
	var/list/bounds = hyperspace_reservation_bounds(reservation)
	if(!bounds)
		return FALSE
	var/edge = min(spot.x - bounds[1], spot.y - bounds[2], bounds[3] - spot.x, bounds[4] - spot.y)
	return edge <= OVERMAP_HYPERSPACE_BORDER_KILL

/proc/delete_lost_in_hyperspace(atom/movable/thing)
	if(QDELETED(thing))
		return
	for(var/mob/living/victim in thing.get_all_contents())
		if(victim.ckey || victim.client)
			to_chat(victim, span_userdanger(span_reallybig("Вы потерялись в гиперпространстве.")))
			victim.ghostize(FALSE)
	qdel(thing)

/proc/nearest_real_space_turf(turf/origin)
	if(!origin)
		return null
	if(isspaceturf(origin) && !istype(origin, /turf/space/transit))
		return origin
	for(var/range_out in 1 to 24)
		for(var/turf/candidate in range(range_out, origin))
			if(isspaceturf(candidate) && !istype(candidate, /turf/space/transit))
				return candidate
	return null

/proc/get_shuttle_for_transit_reservation(datum/turf_reservation/reservation)
	if(!reservation)
		return null
	for(var/obj/docking_port/stationary/transit/pad as anything in SSshuttle.transit)
		if(pad.reserved_area == reservation)
			return pad.owner
	return null

/proc/expose_to_hyperspace(atom/movable/dumpee)
	if(HAS_TRAIT(dumpee, TRAIT_HYPERSPACE_DRIFT))
		return
	ADD_TRAIT(dumpee, TRAIT_HYPERSPACE_DRIFT, "hyperspace_turf")
	addtimer(TRAIT_CALLBACK_REMOVE(dumpee, TRAIT_HYPERSPACE_DRIFT, "hyperspace_turf"), 3 SECONDS)
	dumpee.newtonian_move(dumpee.dir || pick(GLOB.alldirs))

/proc/dump_near_shuttle_in_real_space(atom/movable/dumpee, obj/docking_port/mobile/shuttle)
	var/turf/origin = get_turf(shuttle)
	if(!origin)
		dump_to_linked_space_edge(dumpee)
		return
	for(var/i in 1 to 24)
		var/turf/candidate = locate(
			clamp(origin.x + rand(-16, 16), TRANSITIONEDGE + 1, world.maxx - TRANSITIONEDGE - 1),
			clamp(origin.y + rand(-16, 16), TRANSITIONEDGE + 1, world.maxy - TRANSITIONEDGE - 1),
			origin.z,
		)
		if(isspaceturf(candidate) && !istype(candidate, /turf/space/transit))
			dumpee.forceMove(candidate)
			dumpee.newtonian_move(dumpee.dir)
			return
	dump_to_linked_space_edge(dumpee, origin.z)

/proc/dump_to_linked_space_edge(atom/movable/dumpee, forced_z)
	var/max = world.maxx - TRANSITIONEDGE
	var/min = 1 + TRANSITIONEDGE
	var/_x
	var/_y
	switch(dumpee.dir)
		if(SOUTH)
			_x = rand(min, max)
			_y = max
		if(WEST)
			_x = max
			_y = rand(min, max)
		if(EAST)
			_x = min
			_y = rand(min, max)
		else
			_x = rand(min, max)
			_y = min
	var/target_z = forced_z
	if(!target_z)
		var/list/levels_available = get_all_linked_levels_zpos()
		if(!length(levels_available))
			return
		target_z = pick(levels_available)
	var/turf/T = locate(_x, _y, target_z)
	if(!T)
		return
	dumpee.forceMove(T)
	dumpee.newtonian_move(dumpee.dir)

/turf/space/transit/rpd_act(mob/user, obj/item/rpd/our_rpd, mode)
	return

/turf/space/transit/rcd_act()
	return RCD_NO_ACT

/turf/space/transit/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/turf/space/transit/update_icon_state()
	var/p = 9
	var/angle = 0
	var/state = 1
	switch(dir)
		if(NORTH)
			angle = 180
			state = ((-p*x+y) % 15) + 1
			if(state < 1)
				state += 15
		if(EAST)
			angle = 90
			state = ((x+p*y) % 15) + 1
		if(WEST)
			angle = -90
			state = ((x-p*y) % 15) + 1
			if(state < 1)
				state += 15
		else
			state =	((p*x+y) % 15) + 1

	icon_state = "speedspace_ns_[state]"
	transform = turn(matrix(), angle)

/turf/space/transit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = icon
	underlay_appearance.icon_state = icon_state
	underlay_appearance.transform = transform
	return TRUE
