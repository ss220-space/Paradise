// MARK: decal
/obj/effect/decal
	name = "decal"
	plane = FLOOR_PLANE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// If it has this, don't let it be scooped up.
	var/no_scoop = FALSE
	/// If it has this, don't delete it when its' scooped up.
	var/no_clear = FALSE
	var/list/scoop_reagents = null

/obj/effect/decal/Initialize(mapload)
	. = ..()
	create_reagents(100)

	if(!scoop_reagents)
		return

	reagents.add_reagent_list(scoop_reagents)

/obj/effect/decal/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/reagent_containers/glass) && !istype(item, /obj/item/reagent_containers/food/drinks))
		return ATTACK_CHAIN_PROCEED

	add_fingerprint(user)
	scoop(item, user)
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/effect/decal/proc/scoop(obj/item/item, mob/user)
	if(!reagents || !item.reagents || no_scoop)
		return

	if(!reagents.total_volume)
		to_chat(user, span_notice("There isn't enough [src] to scoop up!"))
		return

	if(item.reagents.total_volume >= item.reagents.maximum_volume)
		to_chat(user, span_notice("[item] is full!"))
		return

	to_chat(user, span_notice("You scoop [src] into [item]!"))
	reagents.trans_to(item, reagents.total_volume)

	if(!reagents.total_volume && !no_clear)
		qdel(src)

/obj/effect/decal/ex_act(severity, target)
	if(reagents)
		for(var/datum/reagent/reagent in reagents.reagent_list)
			reagent.on_ex_act()
	qdel(src)

/obj/effect/decal/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(reagents)
		reagents.temperature_reagents(exposed_temperature)
	if(!(resistance_flags & FIRE_PROOF)) // Non fire proof decal or being burned by lava.
		qdel(src)

/obj/effect/decal/blob_act(obj/structure/blob/blob)
	if(blob?.loc == loc && !QDELETED(src))
		qdel(src)

// MARK: turf_decal
/obj/effect/turf_decal
	icon = 'icons/turf/decals.dmi'
	icon_state = "warningline"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE

// This is with the intent of optimizing mapload
// See spawners for more details since we use the same pattern
// Basically rather then creating and deleting ourselves, why not just do the bare minimum?
/obj/effect/turf_decal/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(flags & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags |= INITIALIZED

	var/turf/turf = loc
	if(!istype(turf)) //you know this will happen somehow
		CRASH("Turf decal initialized in an object/nullspace")
	turf.AddElement(/datum/element/decal, icon, icon_state, dir, null, layer, alpha, color, FALSE, null)
	return INITIALIZE_HINT_QDEL

/obj/effect/turf_decal/Destroy(force)
	SHOULD_CALL_PARENT(FALSE)

	// Intentionally used over moveToNullspace(), which calls doMove(), which fires
	// off an enormous amount of procs, signals, etc, that this temporary effect object
	// never needs or affects.
	loc = null
	return QDEL_HINT_QUEUE
