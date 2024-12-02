/datum/component/pref_viewer
    var/list/preferences_to_show = list()

/datum/component/pref_viewer/Destroy(force)
    LAZYNULL(preferences_to_show)

    return ..()

/datum/component/pref_viewer/Initialize(    
	list/preferences_to_show
)
    if(!ismob(parent))
        return COMPONENT_INCOMPATIBLE

    src.preferences_to_show = preferences_to_show

/datum/component/pref_viewer/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_RUN_EXAMINATE, PROC_REF(on_examine))

/datum/component/pref_viewer/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_RUN_EXAMINATE)

/datum/component/pref_viewer/proc/on_examine(mob/target, list/result)
    SIGNAL_HANDLER

    if(!istype(target) || !target.client)
        return

    for(var/datum/preference_toggle/pref as anything in target.client.prefs.toggled_preferences)
        if(!LAZYIN(preferences_to_show, pref))
            continue

        LAZYADD(result, pref::examine_text)

    return