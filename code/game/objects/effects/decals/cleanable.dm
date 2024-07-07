/obj/effect/decal/cleanable
	anchored = TRUE
	var/list/random_icon_states = list()
	var/bloodiness = 0 //0-100, amount of blood in this decal, used for making footprints and affecting the alpha of bloody footprints
	var/mergeable_decal = TRUE //when two of these are on a same tile or do we need to merge them into just one?
	layer = CLEANABLES_LAYER


/obj/effect/decal/cleanable/Initialize(mapload)
	. = ..()
	if(loc && isturf(loc))
		for(var/obj/effect/decal/cleanable/C in loc)
			if(C != src && C.type == type && !QDELETED(C))
				if(replace_decal(C))
					qdel(src)
					return TRUE
	if(random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)


/obj/effect/decal/cleanable/Destroy()
	if(smooth)
		queue_smooth_neighbors(src)
	return ..()


/obj/effect/decal/cleanable/proc/replace_decal(obj/effect/decal/cleanable/C) // Returns true if we should give up in favor of the pre-existing decal
	if(mergeable_decal)
		return TRUE


/obj/effect/decal/cleanable/proc/can_bloodcrawl_in()
	return FALSE


/obj/effect/decal/cleanable/is_cleanable()
	return TRUE

