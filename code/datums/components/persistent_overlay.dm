#define DEFAULT_DUPE_ID "default_dupe_ID"

/datum/component/persistent_overlay
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/dupe_id = DEFAULT_DUPE_ID
	var/mutable_appearance/persistent_overlay


/datum/component/persistent_overlay/Initialize(persistent_overlay, dupe_id = DEFAULT_DUPE_ID, timer)
	if(!isatom(parent) || !istext(dupe_id) || dupe_id == DEFAULT_DUPE_ID)
		return COMPONENT_INCOMPATIBLE

	var/all_persistent = parent.datum_components?[/datum/component/persistent_overlay]
	if(all_persistent)
		if(!islist(all_persistent))
			all_persistent = list(all_persistent)
		for(var/datum/component/persistent_overlay/existing as anything in all_persistent)
			if(existing.dupe_id == dupe_id)
				qdel(existing)

	src.dupe_id = dupe_id
	src.persistent_overlay = persistent_overlay
	if(!isnull(timer))
		QDEL_IN(src, timer)


/datum/component/persistent_overlay/Destroy()
	persistent_overlay = null
	return ..()


/datum/component/persistent_overlay/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	var/atom/atom_parent = parent
	atom_parent.update_icon()


/datum/component/persistent_overlay/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_QDELETING, COMSIG_ATOM_UPDATE_OVERLAYS)
	var/atom/atom_parent = parent
	atom_parent.update_icon()


/datum/component/persistent_overlay/proc/on_update_overlays(datum/source, list/overlays)
	SIGNAL_HANDLER
	overlays += persistent_overlay


#undef DEFAULT_DUPE_ID

