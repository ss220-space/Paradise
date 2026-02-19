/**
 * Check atmos pipes are not routed under unary devices such as vents and scrubbers.
 */
/datum/map_per_tile_test/pipe_vent_checker
	var/list/pipe_roots = list(
		/obj/machinery/atmospherics/pipe/manifold/hidden/supply,
		/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers
	)
	var/list/unary_roots = list(
		/obj/machinery/atmospherics/unary
	)

/datum/map_per_tile_test/pipe_vent_checker/CheckTile(turf/T)
	var/has_pipe = FALSE
	var/has_unary = FALSE

	for(var/pipe_root in pipe_roots)
		if(locate(pipe_root) in T.contents)
			has_pipe = TRUE

	if(locate(/obj/machinery/atmospherics/unary) in T.contents)
		has_unary = TRUE

	if(has_pipe && has_unary)
		Fail(T, "pipe on same tile as vent or scrubber")

/**
 * Check that only one cable node exists on a tile.
 */
/datum/map_per_tile_test/cable_node_checker

/datum/map_per_tile_test/cable_node_checker/CheckTile(turf/T)
	var/center_nodes = 0

	for(var/obj/structure/cable/cable in T.contents)
		if(cable.d1 == 0 || cable.d2 == 0)
			center_nodes++

	if(center_nodes > 1)
		Fail(T, "tile has multiple center cable nodes")

/datum/map_per_tile_test/nearspace_checker
	var/allowed_turfs = list(
		/turf/space,
		/turf/simulated/floor/plating/airless,
		/turf/simulated/floor/plasteel/airless,
		/turf/simulated/wall,
	)

/datum/map_per_tile_test/nearspace_checker/New()
	..()
	allowed_turfs = typecacheof(allowed_turfs)

/datum/map_per_tile_test/nearspace_checker/CheckTile(turf/T)
	if(T.loc.type == /area/space/nearstation && !is_type_in_list(T, allowed_turfs))
		Fail(T, "nearspace area contains a non-space turf: [T], ([T.type])")

/datum/map_per_tile_test/cable_adjacency_checker

/datum/map_per_tile_test/cable_adjacency_checker/CheckTile(turf/T)
	for(var/obj/structure/cable/cable in T.contents)
		check_direction(T, cable.d1, "d1")
		check_direction(T, cable.d2, "d2")

/datum/map_per_tile_test/cable_adjacency_checker/proc/check_direction(origin_turf, direction, report_name)
	if(!direction) // cable direction = 0, which means its a node
		return TRUE
	var/turf/potential_cable_turf = get_step(origin_turf, direction)
	var/reversed_direction = REVERSE_DIR(direction)
	for(var/obj/structure/cable/other_cable in potential_cable_turf.contents)
		if(reversed_direction == other_cable.d1 || reversed_direction == other_cable.d2)
			return TRUE

	Fail(origin_turf, "tile has an unconnected cable ([report_name] connection: [uppertext(dir2text(direction))]).")
	return FALSE

/**
 * Check to ensure that APCs have a cable node on their tile.
 */
/datum/map_per_tile_test/apc_cable_node_checker

/datum/map_per_tile_test/apc_cable_node_checker/CheckTile(turf/T)
	var/missing_node = TRUE
	var/obj/machinery/power/apc/apc = locate(/obj/machinery/power/apc) in T.contents
	if(apc)
		for(var/obj/structure/cable/cable in T.contents)
			if(cable.d1 == 0 || cable.d2 == 0)
				missing_node = FALSE

		if(missing_node)
			Fail(T, "tile has an APC bump but no center cable node")

/**
 * Check to ensure pipe trunks exist under disposals devices.
 */
/datum/map_per_tile_test/disposal_with_trunk_checker

/datum/map_per_tile_test/disposal_with_trunk_checker/CheckTile(turf/T)
	var/obj/machinery/disposal/disposal = locate(/obj/machinery/disposal) in T.contents
	if(disposal)
		if(!locate(/obj/structure/disposalpipe/trunk) in T.contents)
			Fail(T, "tile has disposal unit/chute but no pipe trunk")

/**
 * Check for certain objects that should never be over space turfs.
 */
/datum/map_per_tile_test/invalid_objs_over_space_checker
	var/list/invalid_types = list(
		/obj/machinery/door/airlock
	)

/datum/map_per_tile_test/invalid_objs_over_space_checker/CheckTile(turf/T)
	for(var/invalid_type in invalid_types)
		if(isspaceturf(T) && locate(invalid_type) in T.contents)
			Fail(T, "space turf contains at least one invalid object of type [invalid_type]")

/**
 * Check that structures in space are always in near-station space.
 */
/datum/map_per_tile_test/structures_in_farspace_checker

/datum/map_per_tile_test/structures_in_farspace_checker/CheckTile(turf/T)
	if(T.loc.type == /area/space && locate(/obj/structure) in T.contents)
		Fail(T, "tile contains at least one structure found in non-near space area")

/**
 * Check that multi-z structures aren't placed in non-multi-z place.
 */
/datum/map_per_tile_test/invalid_multiz_objects_checker
	var/list/invalid_types = list(
		/obj/structure/disposalpipe/trunk/multiz,
		/obj/structure/disposalpipe/trunk/multiz/down,
		/obj/structure/cable/multiz,
		/obj/machinery/atmospherics/pipe/multiz,
		// obj/structure/ladder, if it wasn't being used by jacob I guess
		/obj/structure/stairs
	)

/datum/map_per_tile_test/invalid_multiz_objects_checker/CheckTile(turf/T)
	if(!GET_TURF_ABOVE(T) && !GET_TURF_BELOW(T))
		for(var/invalid_type in invalid_types)
			if(locate(invalid_type) in T.contents)
				Fail(T, "Non-multi-z turf contains at least one multi-z object of type [invalid_type]")

/datum/map_per_tile_test/missing_pipe_connection

/datum/map_per_tile_test/missing_pipe_connection/CheckTile(turf/T)
	var/obj/machinery/atmospherics/pipe/simple/pipe = locate() in T.contents
	if(isnull(pipe))
		return
	if(!pipe.node1 && !pipe.node2)
		Fail(T, "[pipe] ([pipe.type]) missing both nodes.")
		return
	if(istype(pipe, /obj/machinery/atmospherics/pipe/simple/heat_exchanging) && (pipe.node1 || pipe.node2))
		return // H/E pipes only need one end, because they don't always become full loops
	if(!pipe.node1)
		Fail(T, "[pipe] ([pipe.type]) missing node1. ([uppertext(dir2text(pipe.initialize_directions & ~(get_dir(pipe, pipe.node2))))])")
	if(!pipe.node2)
		Fail(T, "[pipe] ([pipe.type]) missing node2. ([uppertext(dir2text(pipe.initialize_directions & ~(get_dir(pipe, pipe.node1))))])")

/datum/map_per_tile_test/unary_device_connection

/datum/map_per_tile_test/unary_device_connection/CheckTile(turf/T)
	var/obj/machinery/atmospherics/unary/unary_device = locate() in T.contents
	if(isnull(unary_device))
		return
	if(!unary_device.node)
		Fail(T, "[unary_device] ([unary_device.type]) missing node. ([uppertext(dir2text(unary_device.dir))])")
