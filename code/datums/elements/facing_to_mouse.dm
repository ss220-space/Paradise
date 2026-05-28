/datum/element/facing_to_mouse

/datum/element/facing_to_mouse/Attach(datum/target)
	if(!ismob(target) || HAS_TRAIT(target, TRAIT_FACING_TO_MOUSE))
		return ELEMENT_INCOMPATIBLE
	ADD_TRAIT(target, TRAIT_FACING_TO_MOUSE, UNIQUE_TRAIT_SOURCE(src))
	RegisterSignal(target, COMSIG_ATOM_MOUSE_ENTERED, PROC_REF(on_mouse_enter))
	return ..()


/datum/element/facing_to_mouse/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_ATOM_MOUSE_ENTERED)
	REMOVE_TRAIT(source, TRAIT_FACING_TO_MOUSE, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/datum/element/facing_to_mouse/proc/on_mouse_enter(mob/source, atom/target)
	SIGNAL_HANDLER
	var/client/mob_client = source.client
	if(!mob_client)
		return

	if(source.incapacitated())
		return

	source.face_atom(target)
