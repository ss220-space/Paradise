/datum/component/pref_viewer
    var/list/preferences_to_show

/datum/component/pref_viewer/Destroy(force)
    LAZYNULL(preferences_to_show)

    return ..()

/datum/component/pref_viewer/Initialize(    
	list/preferences_to_show
)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	for(var/datum/preference_info/pref as anything in preferences_to_show)
		LAZYADD(src.preferences_to_show, new pref)

/datum/component/pref_viewer/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_RUN_EXAMINATE, PROC_REF(on_examine))

/datum/component/pref_viewer/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_RUN_EXAMINATE)

/datum/component/pref_viewer/proc/on_examine(mob/source, mob/target, list/result)
    SIGNAL_HANDLER

    if(!istype(target) || !target.client)
        return

    INVOKE_ASYNC(src, PROC_REF(modify_examine), target, result)

/datum/component/pref_viewer/proc/modify_examine(mob/target, list/result)
	for(var/datum/preference_info/pref as anything in preferences_to_show)
		var/datum/preference_toggle/toggle = pref.get_preference_toggle()
		
		if(!HASBIT(target.client.prefs.toggles, toggle.preftoggle_bitflag) \
        && !HASBIT(target.client.prefs.toggles2, toggle.preftoggle_bitflag)
        )
			continue

		LAZYADD(result, pref.get_examine_text())
