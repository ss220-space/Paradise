/datum/element/pref_holder
    element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
    var/list/preferences

/datum/element/pref_holder/Destroy(force)
    LAZYNULL(preferences)

    return ..()

/datum/element/pref_holder/Initialize(
    mob/target,
	list/preferences
)
	. = ..()

	if(!istype(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_BODY_TRANSFER_TO, PROC_REF(on_mind_transfer))
	src.preferences = preferences || forge_preferences()

/datum/element/pref_holder/Detach(mob/target)
    . = ..()

    UnregisterSignal(target, COMSIG_BODY_TRANSFER_TO)

/datum/element/pref_holder/proc/on_mind_transfer(mob/source)
    SIGNAL_HANDLER

    preferences = forge_preferences()

/datum/element/pref_holder/proc/forge_preferences()
	var/mob/mob = parent

	if(!mob.client)
		return
        
	var/list/prefs

	for(var/datum/preference_info/pref as anything in GLOB.preferences_info)
		var/datum/preference_toggle/toggle = pref.get_preference_toggle()

		if(!toggle)
			continue

		if(!HASBIT(mob.client.prefs.toggles, toggle.preftoggle_bitflag) \
        && !HASBIT(mob.client.prefs.toggles2, toggle.preftoggle_bitflag)
        )   
			continue

		LAZYADD(prefs, new pref.type)

	return prefs
