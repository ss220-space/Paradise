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
	if(scoop_reagents)
		reagents.add_reagent_list(scoop_reagents)

/obj/effect/decal/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks))
		add_fingerprint(user)
		scoop(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ATTACK_CHAIN_PROCEED

/obj/effect/decal/proc/scoop(obj/item/I, mob/user)
	if(reagents && I.reagents && !no_scoop)
		if(!reagents.total_volume)
			to_chat(user, span_notice("There isn't enough [src] to scoop up!"))
			return
		if(I.reagents.total_volume >= I.reagents.maximum_volume)
			to_chat(user, span_notice("[I] is full!"))
			return
		to_chat(user, span_notice("You scoop [src] into [I]!"))
		reagents.trans_to(I, reagents.total_volume)
		if(!reagents.total_volume && !no_clear) // Scooped up all of it.
			qdel(src)

/obj/effect/decal/ex_act(severity, target)
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	qdel(src)

/obj/effect/decal/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(reagents)
		reagents.temperature_reagents(exposed_temperature)
	if(!(resistance_flags & FIRE_PROOF)) // Non fire proof decal or being burned by lava.
		qdel(src)

/obj/effect/decal/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc && !QDELETED(src))
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
