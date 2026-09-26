SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	dependencies = list(
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/mapping,
	)
	wait = 1
	ss_flags = SS_TICKER

	/// List of lighting sources queued for update.
	var/static/list/sources_queue = list()
	/// List of lighting corners queued for update.
	var/static/list/corners_queue = list()
	/// List of lighting objects queued for update.
	var/static/list/objects_queue = list()
	/// Snapshot of sources_queue currently being processed this fire() cycle.
	var/static/list/current_sources = list()

/datum/controller/subsystem/lighting/get_stat_details()
	return "Sources:[length(sources_queue)]|Corners:[length(corners_queue)]|Objects:[length(objects_queue)]"

/datum/controller/subsystem/lighting/get_metrics()
	. = ..()
	var/list/custom_data = list()
	custom_data["sources_queue"] = length(sources_queue)
	custom_data["corners_queue"] = length(corners_queue)
	custom_data["objects_queue"] = length(objects_queue)
	.["custom"] = custom_data

/datum/controller/subsystem/lighting/Initialize()
	if(!initialized)
		create_all_lighting_objects()
		initialized = TRUE

	fire(FALSE, TRUE)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/lighting/proc/create_all_lighting_objects()
	for(var/area/area as anything in GLOB.areas)
		if(!area.static_lighting)
			continue
		for(var/list/zlevel_turfs as anything in area.get_zlevel_turf_lists())
			for(var/turf/area_turf as anything in zlevel_turfs)
				if(area_turf.space_lit)
					continue
				new /atom/movable/lighting_object(null, area_turf)
			CHECK_TICK
		CHECK_TICK

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK

	if(!resumed)
		current_sources = sources_queue
		sources_queue = list()

	// UPDATE SOURCE QUEUE
	var/i = 0
	// something something cache locally for sonic speed
	var/list/queue = current_sources
	while(i < length(queue)) //we don't use for loop here because i cannot be changed during an iteration
		i += 1

		var/datum/light_source/source = queue[i]
		source.update_corners()
		if(!QDELETED(source))
			source.needs_update = LIGHTING_NO_UPDATE
		else
			i -= 1 // update_corners() has removed `source` from the list, move back so we don't overflow or skip the next element

		// We unroll TICK_CHECK here so we can clear out the queue to ensure any removals/additions when sleeping don't fuck us
		if(init_tick_checks)
			if(!TICK_CHECK)
				continue
			queue.Cut(1, i + 1)
			i = 0
			stoplag()
		else if(MC_TICK_CHECK)
			break
	if(i)
		queue.Cut(1, i + 1)
		i = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	// UPDATE CORNERS QUEUE
	queue = corners_queue
	while(i < length(queue)) //we don't use for loop here because i cannot be changed during an iteration
		i += 1

		var/datum/lighting_corner/corner = queue[i]
		corner.needs_update = FALSE //update_objects() can call qdel if the corner is storing no data
		corner.update_objects()

		// We unroll TICK_CHECK here so we can clear out the queue to ensure any removals/additions when sleeping don't fuck us
		if(init_tick_checks)
			if(!TICK_CHECK)
				continue
			queue.Cut(1, i + 1)
			i = 0
			stoplag()
		else if(MC_TICK_CHECK)
			break
	if(i)
		queue.Cut(1, i + 1)
		i = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	// UPDATE OBJECTS QUEUE
	queue = objects_queue
	while(i < length(queue)) //we don't use for loop here because i cannot be changed during an iteration
		i += 1

		var/atom/movable/lighting_object/object = queue[i]
		if(QDELETED(object))
			continue
		object.update()
		object.needs_update = FALSE

		// We unroll TICK_CHECK here so we can clear out the queue to ensure any removals/additions when sleeping don't fuck us
		if(init_tick_checks)
			if(!TICK_CHECK)
				continue
			queue.Cut(1, i + 1)
			i = 0
			stoplag()
		else if(MC_TICK_CHECK)
			break
	if(i)
		queue.Cut(1, i + 1)

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	return ..()

/// Takes a list of turfs in, and sets up static lighting for them as needed.
/// Exactly what it says on the tin.
/datum/controller/subsystem/lighting/proc/setup_static_lighting_if_needed(list/turfs)
	for(var/turf/unlit as anything in turfs)
		if(unlit.space_lit)
			continue
		var/area/loc_area = unlit.loc
		if(loc_area.static_lighting)
			unlit.lighting_build_overlay()
