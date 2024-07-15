/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/engines_and_power/particle_accelerator.dmi'
	icon_state = "particle"
	anchored = TRUE
	density = FALSE
	var/movement_range = 16
	var/energy = 10

/obj/effect/accelerated_particle/weak
	energy = 5

/obj/effect/accelerated_particle/strong
	energy = 15

/obj/effect/accelerated_particle/powerful
	movement_range = 21
	energy = 50


/obj/effect/accelerated_particle/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(propagate)), 1)
	RegisterSignal(src, COMSIG_ATOM_ENTERING, PROC_REF(on_entering))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	QDEL_IN(src, movement_range)


/obj/effect/accelerated_particle/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	try_irradiate(arrived)


/obj/effect/accelerated_particle/proc/on_entering(datum/source, atom/destination, atom/oldloc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isturf(destination))
		return

	for(var/atom/movable/movable as anything in (destination.contents - src))
		try_irradiate(movable)


/obj/effect/accelerated_particle/proc/try_irradiate(atom/movable/thing)
	if(isliving(thing))
		var/mob/living/living_thing = thing
		living_thing.apply_effect((energy * 6), IRRADIATE, 0)
	else if(istype(thing, /obj/machinery/the_singularitygen))
		var/obj/machinery/the_singularitygen/singularitygen = thing
		singularitygen.energy += energy
	else if(istype(thing, /obj/structure/blob))
		var/obj/structure/blob/blob = thing
		blob.take_damage(energy * 0.6)


/obj/effect/accelerated_particle/Bump(obj/singularity/bumped_singulo)
	. = ..()
	if(. || !istype(bumped_singulo))
		return .
	bumped_singulo.energy += energy


/obj/effect/accelerated_particle/ex_act(severity)
	qdel(src)


/obj/effect/accelerated_particle/singularity_pull()
	return


/obj/effect/accelerated_particle/proc/propagate()
	addtimer(CALLBACK(src, PROC_REF(propagate)), 1)
	if(!step(src,dir))
		forceMove(get_step(src, dir))

