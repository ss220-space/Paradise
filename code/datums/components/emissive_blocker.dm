/datum/component/emissive_blocker
	/// Stores either the mutable_appearance or a list of them
	var/stored_blocker


/datum/component/emissive_blocker/Initialize()
	update_generic_block()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(update_generic_block))


/datum/component/emissive_blocker/Destroy()
	stored_blocker = null
	return ..()


/// Updates the generic blocker when the icon_state is changed
/datum/component/emissive_blocker/proc/update_generic_block(datum/source)
	var/atom/movable/movable = parent
	if(!movable.blocks_emissive && stored_blocker)
		movable.cut_overlay(stored_blocker)
		stored_blocker = null
		return
	if(!movable.blocks_emissive)
		return
	var/mutable_appearance/gen_emissive_blocker = emissive_blocker(movable.icon, movable.icon_state, alpha = movable.alpha, appearance_flags = movable.appearance_flags)
	gen_emissive_blocker.dir = movable.dir
	if(gen_emissive_blocker != stored_blocker)
		movable.cut_overlay(stored_blocker)
		stored_blocker = gen_emissive_blocker
		movable.add_overlay(stored_blocker)

