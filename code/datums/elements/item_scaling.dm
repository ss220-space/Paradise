/**
 * Element for scaling item appearances in the overworld vs inventory/storage.
 *
 * Ported from /tg/station for the oversized (64x64) painting canvases. It shrinks the item's
 * sprite while it sits on a turf and restores it (to storage_scaling) once picked up or stored,
 * so a 36x24 / 45x27 canvas doesn't sprawl across multiple tiles on the floor.
 *
 * Paradise adaptation: master220 has no ADD_KEEP_TOGETHER trait macro, so we just OR in the raw
 * KEEP_TOGETHER appearance flag on attach (idempotent — the canvas already sets it) to keep
 * overlays scaling together with the base sprite.
 */
/datum/element/item_scaling
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Scaling value when the attached item is in the overworld (on a turf).
	var/overworld_scaling
	/// Scaling value when the attached item is in a storage component or inventory slot.
	var/storage_scaling


/datum/element/item_scaling/Attach(atom/target, overworld_scaling, storage_scaling)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	// Initial scaling set to overworld_scaling when item is spawned.
	scale(target, overworld_scaling)

	src.overworld_scaling = overworld_scaling
	src.storage_scaling = storage_scaling

	// Make sure overlays also inherit the scaling.
	target.appearance_flags |= KEEP_TOGETHER

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(scale_by_loc))


/datum/element/item_scaling/Detach(atom/target)
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	return ..()


/// Scales the attached item's transform matrix by `scaling`.
/datum/element/item_scaling/proc/scale(datum/source, scaling)
	var/atom/scalable_object = source
	var/matrix/M = matrix()
	scalable_object.transform = M.Scale(scaling)


/// On move, pick the scaling that matches the new location (turf = overworld, else storage/inhand).
/datum/element/item_scaling/proc/scale_by_loc(atom/scale)
	SIGNAL_HANDLER
	if(isturf(scale.loc))
		scale(scale, overworld_scaling)
	else
		scale(scale, storage_scaling)
