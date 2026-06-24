/// These effects can be added to anything to hold particles, which is useful because Byond only allows a single particle per atom.
/obj/effect/abstract/particle_holder_tgmc
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER
	vis_flags = VIS_INHERIT_PLANE
	invisibility = INVISIBILITY_NONE
	appearance_flags = KEEP_APART | TILE_BOUND
	plane = GRAVITY_PULSE_PLANE
	/// Typepath of the last location we're in, if it's different when moved then we need to update vis contents.
	var/last_attached_location_type
	/// The main item we're attached to at the moment, particle holders hold particles for something.
	var/datum/weakref/weak_attached
	/// Besides the item we're also sometimes attached to other stuff! (items held emitting particles on a mob).
	var/datum/weakref/weak_additional

/obj/effect/abstract/particle_holder_tgmc/Initialize(mapload, particle_path = null)
	. = ..()
	if(!loc)
		stack_trace("particle holder tgmc was created with no loc!")
		return INITIALIZE_HINT_QDEL
	if(ismovable(loc))
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(loc, COMSIG_QDELETING, PROC_REF(on_qdel))
	weak_attached = WEAKREF(loc)
	particles = new particle_path
	update_visual_contents(loc)

/obj/effect/abstract/particle_holder_tgmc/Destroy(force)
	var/atom/movable/attached = weak_attached.resolve()
	var/atom/movable/additional_attached
	if(weak_additional)
		additional_attached = weak_additional.resolve()
	if(attached)
		attached.vis_contents -= src
		UnregisterSignal(loc, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	if(additional_attached)
		additional_attached.vis_contents -= src
	QDEL_NULL(particles)
	return ..()

/// Signal called when parent is moved.
/obj/effect/abstract/particle_holder_tgmc/proc/on_move(atom/movable/attached, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(attached.loc.type != last_attached_location_type)
		update_visual_contents(attached)

/// Signal called when parent is deleted.
/obj/effect/abstract/particle_holder_tgmc/proc/on_qdel(atom/movable/attached, force)
	SIGNAL_HANDLER
	attached.vis_contents -= src
	qdel(src) // Our parent is gone and we need to be as well.

/// Logic proc for particle holders, aka where they move.
/// Subtypes of particle holders can override this for particles that should always be turf level or do special things when repositioning.
/// This base subtype has some logic for items, as the loc of items becomes mobs very often hiding the particles.
/obj/effect/abstract/particle_holder_tgmc/proc/update_visual_contents(atom/movable/attached_to)
	// Remove old.
	if(weak_additional)
		var/atom/movable/resolved_location = weak_additional.resolve()
		if(resolved_location)
			resolved_location.vis_contents -= src

	// Add new.
	if(isitem(attached_to) && ismob(attached_to.loc)) // Special case we want to also be emitting from the mob.
		var/mob/particle_mob = attached_to.loc
		last_attached_location_type = attached_to.loc
		weak_additional = WEAKREF(particle_mob)
		particle_mob.vis_contents += src

	// Readd to ourselves.
	attached_to.vis_contents |= src

/obj/effect/abstract/particle_holder_tgmc/reset_transform
	appearance_flags = KEEP_APART | TILE_BOUND | RESET_TRANSFORM
