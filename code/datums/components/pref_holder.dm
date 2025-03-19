/datum/component/pref_holder
    var/list/preferences

/datum/component/pref_holder/Destroy(force)
    LAZYNULL(preferences)

    return ..()

/datum/component/pref_holder/Initialize(list/preferences)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	src.preferences = preferences || forge_preferences()

/datum/component/pref_holder/RegisterWithParent()
    RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(handle_transfer))

/datum/component/pref_holder/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_LOGIN)

	for(var/datum/preference_info/pref as anything in preferences)
		pref.deactivate(parent)

/datum/component/pref_holder/proc/handle_transfer(mob/source)
    SIGNAL_HANDLER

    preferences = forge_preferences()

/datum/component/pref_holder/proc/forge_preferences()
	var/mob/mob = parent

	if(!mob.client)
		return

	for(var/datum/preference_info/pref as anything in preferences) // deactivate current
		pref.deactivate(parent)
        
	var/list/prefs

	for(var/datum/preference_info/pref as anything in GLOB.preferences_info)
		var/datum/preference_toggle/toggle = pref.get_preference_toggle()

		if(!toggle)
			continue

		if(!HASBIT(mob.client.prefs.toggles, toggle.preftoggle_bitflag) \
        && !HASBIT(mob.client.prefs.toggles2, toggle.preftoggle_bitflag)
        )   
			continue

		if(!pref.activate(parent))
			continue

		LAZYADD(prefs, new pref.type)

	return prefs
