#define DEFAULT_DUPE_ID "default_dupe_ID"

/datum/component/persistent_overlay
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/dupe_id = DEFAULT_DUPE_ID
	var/mutable_appearance/persistent_overlay


/datum/component/persistent_overlay/Initialize(persistent_overlay, dupe_id = DEFAULT_DUPE_ID, timer)
	if(!isatom(parent) || !istext(dupe_id) || dupe_id == DEFAULT_DUPE_ID)
		return COMPONENT_INCOMPATIBLE

	if(parent.datum_components && parent.datum_components[/datum/component/persistent_overlay])
		var/list/all_persistent = parent.datum_components[/datum/component/persistent_overlay]
		if(!islist(all_persistent))
			all_persistent = list(all_persistent)
		for(var/datum/component/persistent_overlay/existing as anything in all_persistent)
			if(existing.dupe_id == dupe_id)
				existing.remove_persistent_overlay()

	src.dupe_id = dupe_id
	src.persistent_overlay = persistent_overlay
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(remove_persistent_overlay))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	var/atom/atom_parent = parent
	atom_parent.update_icon()
	if(!isnull(timer))
		addtimer(CALLBACK(src, PROC_REF(remove_persistent_overlay)), timer)


/datum/component/persistent_overlay/Destroy()
	persistent_overlay = null
	return ..()


/datum/component/persistent_overlay/proc/on_update_overlays(datum/source, list/overlays)
	SIGNAL_HANDLER

	overlays += persistent_overlay


/datum/component/persistent_overlay/proc/remove_persistent_overlay(datum/source)
	SIGNAL_HANDLER

	var/atom/atom_parent = parent
	UnregisterSignal(atom_parent, COMSIG_ATOM_UPDATE_OVERLAYS)
	atom_parent.update_icon()
	qdel(src)


#undef DEFAULT_DUPE_ID

