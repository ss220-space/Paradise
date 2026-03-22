/obj/effect/decal/cleanable
	abstract_type = /obj/effect/decal/cleanable
	var/list/random_icon_states = list()
	var/bloodiness = 0 //0-100, amount of blood in this decal, used for making footprints and affecting the alpha of bloody footprints
	var/mergeable_decal = TRUE //when two of these are on a same tile or do we need to merge them into just one?
	layer = CLEANABLES_LAYER

/obj/effect/decal/cleanable/Initialize(mapload)
	. = ..()
	if(length(random_icon_states))
		icon_state = pick(random_icon_states)
		base_icon_state = icon_state

	if(isturf(loc))
		var/my_type = src.type
		for(var/obj/effect/decal/cleanable/other in loc)
			if(other != src && other.type == my_type && !QDELETED(other) && replace_decal(other))
				return INITIALIZE_HINT_QDEL

	if(smooth)
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

	var/turf/our_turf = get_turf(src)
	if(our_turf && is_station_level(our_turf.z))
		SSblackbox.record_feedback("tally", "station_mess_created", 1, name)

/obj/effect/decal/cleanable/Destroy()
	var/turf/our_turf = get_turf(src)
	if(our_turf && is_station_level(our_turf.z))
		SSblackbox.record_feedback("tally", "station_mess_destroyed", 1, name)

	if(smooth)
		QUEUE_SMOOTH_NEIGHBORS(src)

	return ..()

/// Check if we should give up in favor of the pre-existing decal
/obj/effect/decal/cleanable/proc/replace_decal(obj/effect/decal/cleanable/other)
	if(mergeable_decal)
		return TRUE

/obj/effect/decal/cleanable/proc/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/is_cleanable()
	return TRUE

