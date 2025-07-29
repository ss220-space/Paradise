/// These effects can be added to anything to hold particles, which is useful because Byond only allows a single particle per atom.
/obj/effect/abstract/particle_holder_tgmc
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER
	vis_flags = VIS_INHERIT_PLANE
	invisibility = FALSE
	/// Typepath of the last location we're in, if it's different when moved then we need to update vis contents.
	var/last_attached_location_type
	/// The main item we're attached to at the moment, particle holders hold particles for something.
	var/atom/movable/parent
	/// The mob that is holding our item.
	var/mob/holding_parent

/obj/effect/abstract/particle_holder_tgmc/Initialize(mapload, particle_path = null)
	. = ..()
	if(!loc)
		stack_trace("particle holder was created with no loc!")
		return INITIALIZE_HINT_QDEL
	parent = loc

	if(ismovable(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_qdel))

	particles = new particle_path
	update_visual_contents(parent)

/obj/effect/abstract/particle_holder_tgmc/Destroy(force)
	if(parent)
		UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	QDEL_NULL(particles)
	holding_parent = null
	parent.vis_contents -= src
	return ..()

/// Signal called when parent is moved.
/obj/effect/abstract/particle_holder_tgmc/proc/on_move(atom/movable/attached, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(parent.loc.type != last_attached_location_type)
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
	if(holding_parent && !(QDELETED(holding_parent)))
		holding_parent.vis_contents -= src

	// Add new.
	if(isitem(attached_to) && ismob(attached_to.loc)) // Special case we want to also be emitting from the mob.
		holding_parent = attached_to.loc
		last_attached_location_type = attached_to.loc
		holding_parent.vis_contents += src

	// Readd to ourselves.
	attached_to.vis_contents |= src
