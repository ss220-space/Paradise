/datum/component/loads_avatar_gear
	var/datum/callback/load_callback
	var/datum/weakref/tracked_human_ref
	var/datum/component/connect_containers/containers_connection

/datum/component/loads_avatar_gear/Initialize(datum/callback/load_callback)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.load_callback = load_callback

/datum/component/loads_avatar_gear/Destroy(force)
	switch_tracking(null)
	load_callback = null
	return ..()

/datum/component/loads_avatar_gear/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ENTERING, PROC_REF(on_entered_loc))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERING = PROC_REF(on_entered_loc),
	)
	containers_connection = AddComponent(/datum/component/connect_containers, parent, loc_connections)

/datum/component/loads_avatar_gear/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ENTERING)
	QDEL_NULL(containers_connection)

/datum/component/loads_avatar_gear/proc/on_entered_loc(datum/source, atom/destination, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isturf(destination) && isturf(old_loc))
		return

	var/list/nested_locs = get_nested_locs(parent)
	for(var/index in length(nested_locs) to 1 step -1)
		var/atom/container = nested_locs[index]
		if(ishuman(container))
			switch_tracking(container)
			return

	switch_tracking(null)

/datum/component/loads_avatar_gear/proc/switch_tracking(mob/living/carbon/human/to_track)
	var/mob/living/carbon/human/tracked_human = tracked_human_ref?.resolve()
	if(tracked_human == to_track)
		return

	if(tracked_human)
		UnregisterSignal(tracked_human, COMSIG_BITRUNNER_STOCKING_GEAR)

	tracked_human_ref = WEAKREF(to_track)
	if(to_track)
		RegisterSignal(to_track, COMSIG_BITRUNNER_STOCKING_GEAR, PROC_REF(load_onto_avatar))

/datum/component/loads_avatar_gear/proc/load_onto_avatar(mob/living/carbon/human/pilot, mob/living/carbon/human/avatar, domain_flags)
	SIGNAL_HANDLER

	return load_callback?.Invoke(pilot, avatar, domain_flags)
