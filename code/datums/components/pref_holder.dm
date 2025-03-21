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
		pref.deactivate(mob)
        
	var/list/prefs

	for(var/datum/preference_info/pref as anything in GLOB.preferences_info)
		var/datum/preference_toggle/toggle = pref.get_preference_toggle()

		if(!toggle || !is_active_toggle(toggle))
			continue

		if(!pref.activate(mob))
			continue

		LAZYADD(prefs, new pref.type)

	return prefs

/datum/component/pref_holder/proc/is_active_toggle(datum/preference_toggle/toggle)
	var/mob/mob = parent
	
	switch(toggle.preftoggle_toggle)
		if(PREFTOGGLE_TOGGLE1)
			. = HASBIT(mob.client.prefs.toggles, toggle.preftoggle_bitflag)

		if(PREFTOGGLE_TOGGLE2)
			. = HASBIT(mob.client.prefs.toggles2, toggle.preftoggle_bitflag)

		if(PREFTOGGLE_TOGGLE3)
			. = HASBIT(mob.client.prefs.toggles3, toggle.preftoggle_bitflag)
			
		if(PREFTOGGLE_SOUND)
			. = HASBIT(mob.client.prefs.sound, toggle.preftoggle_bitflag)
