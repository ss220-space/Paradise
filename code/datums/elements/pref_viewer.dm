/datum/element/pref_viewer
    element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
    var/list/preferences_to_show

/datum/element/pref_viewer/Destroy(force)
    LAZYNULL(preferences_to_show)

    return ..()

/datum/element/pref_viewer/Attach(
	mob/target,
	list/preferences_to_show
	)
	. = ..()
	
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE

	src.preferences_to_show = preferences_to_show
	RegisterSignal(target, COMSIG_MOB_RUN_EXAMINATE, PROC_REF(on_examine))

/datum/element/pref_viewer/Detach(mob/target)
	. = ..()

	UnregisterSignal(target, COMSIG_MOB_RUN_EXAMINATE)

/datum/element/pref_viewer/proc/on_examine(mob/source, mob/target, list/result)
    SIGNAL_HANDLER

    if(!istype(target) || !target.client || !target.GetComponent(/datum/component/pref_holder))
        return

    INVOKE_ASYNC(src, PROC_REF(modify_examine), target, result)

/datum/element/pref_viewer/proc/modify_examine(mob/target, list/result)
	var/datum/component/pref_holder/holder = target.GetComponent(/datum/component/pref_holder)

	for(var/datum/preference_info/info as anything in holder.preferences)
		if(!is_type_in_list(info, preferences_to_show))
			continue

		LAZYADD(result, info.get_examine_text())
