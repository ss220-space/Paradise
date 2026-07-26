/// Interval between particle propagation steps, in deciseconds.
#define PARTICLE_PROPAGATE_INTERVAL 1
/// Fraction of the particle's energy applied as damage when it strikes a blob.
#define PARTICLE_BLOB_DAMAGE_RATIO 0.6

/obj/effect/accelerated_particle
	name = "accelerated particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/engines_and_power/particle_accelerator.dmi'
	icon_state = "particle"
	/// Maximum number of tiles the particle will travel before despawning.
	var/movement_range = 11
	/// Energy contributed to whatever the particle hits (singularity, generator, blob).
	var/energy = 10

/obj/effect/accelerated_particle/weak
	movement_range = 9
	energy = 5

/obj/effect/accelerated_particle/strong
	movement_range = 16
	energy = 15

/obj/effect/accelerated_particle/powerful
	movement_range = 21
	energy = 50

/obj/effect/accelerated_particle/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(propagate)), PARTICLE_PROPAGATE_INTERVAL)
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
		SSradiation.irradiate(living_thing)
		return
	if(istype(thing, /obj/machinery/the_singularitygen))
		var/obj/machinery/the_singularitygen/singularitygen = thing
		singularitygen.energy += energy
		return
	if(istype(thing, /obj/structure/blob))
		var/obj/structure/blob/blob = thing
		blob.take_damage(energy * PARTICLE_BLOB_DAMAGE_RATIO)

/obj/effect/accelerated_particle/Bump(obj/singularity/bumped_singulo)
	. = ..()
	if(. || (!istype(bumped_singulo) && !istype(bumped_singulo, /obj/energy_ball)))
		return .
	bumped_singulo.energy += energy
	energy = 0

/obj/effect/accelerated_particle/singularity_act()
	return

/obj/effect/accelerated_particle/ex_act(severity, target)
	qdel(src)

/obj/effect/accelerated_particle/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/accelerated_particle/proc/propagate()
	addtimer(CALLBACK(src, PROC_REF(propagate)), PARTICLE_PROPAGATE_INTERVAL)
	if(step(src, dir))
		return
	var/turf/next_turf = get_step(src, dir)
	if(next_turf)
		forceMove(next_turf)

#undef PARTICLE_PROPAGATE_INTERVAL
#undef PARTICLE_BLOB_DAMAGE_RATIO
