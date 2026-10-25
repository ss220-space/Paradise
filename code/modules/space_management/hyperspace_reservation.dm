/datum/turf_reservation/transit/overmap
	turf_type = /turf/space
	var/list/pod_inner_bounds

/datum/turf_reservation/transit/overmap/prepare_reserved_turfs(list/tiles)
	for(var/turf/space/spot as anything in tiles)
		prepare_space(spot)
		CHECK_TICK
	var/datum/milla_safe/prepare_hyperspace/atmos = new
	atmos.invoke_async(tiles.Copy())

/datum/turf_reservation/transit/overmap/proc/prepare_space(turf/space/spot)
	spot.name = "hyperspace"
	spot.icon_state = "space"
	spot.blocks_air = FALSE
	spot.turf_flags |= NOJAUNT

/datum/turf_reservation/transit/overmap/proc/contains_pod_interior(turf/spot)
	return pod_inner_bounds && spot.x >= pod_inner_bounds[1] && spot.y >= pod_inner_bounds[2] && spot.x <= pod_inner_bounds[3] && spot.y <= pod_inner_bounds[4]

/datum/turf_reservation/transit/overmap/proc/entered_space(turf/space/spot, atom/movable/arrived)
	if(arrived.loc != spot || !arrived.simulated || isobserver(arrived) || istype(arrived, /obj/docking_port) || contains_pod_interior(spot))
		return
	if(isspacepod(arrived))
		var/obj/spacepod/craft = arrived
		if(craft.overmap_vessel?.overmap_pod?.is_in_own_pocket())
			return
	dump_in_space(arrived)

/datum/turf_reservation/transit/overmap/Release()
	for(var/turf/space/spot as anything in reserved_turfs)
		if(length(spot.contents))
			for(var/atom/movable/thing as anything in spot.contents.Copy())
				if(thing.simulated && !isobserver(thing) && !istype(thing, /obj/docking_port))
					dump_in_space(thing)
		spot.name = initial(spot.name)
		spot.turf_flags &= ~NOJAUNT
	return ..()

/proc/overmap_hyperspace_reservation(turf/spot)
	RETURN_TYPE(/datum/turf_reservation/transit/overmap)
	if(!isspaceturf(spot) || !(spot.turf_flags & RESERVATION_TURF))
		return null
	var/datum/turf_reservation/transit/overmap/reservation = SSmapping.used_turfs[spot]
	return istype(reservation) ? reservation : null

/proc/is_hyperspace_turf(turf/spot)
	return istype(spot, /turf/space/transit) || !!overmap_hyperspace_reservation(spot)

/datum/milla_safe/prepare_hyperspace/on_run(list/tiles)
	for(var/turf/space/spot as anything in tiles)
		if(!overmap_hyperspace_reservation(spot))
			continue
		set_tile_atmos(spot, atmos_mode = ATMOS_MODE_SPACE, innate_heat_capacity = spot.heat_capacity, temperature = spot.temperature)
		var/list/connectivity = spot.private_unsafe_recalculate_atmos_connectivity()
		set_tile_airtight(spot, connectivity[1])
		reset_superconductivity(spot)
		reduce_superconductivity(spot, connectivity[2])
