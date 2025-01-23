/datum/component/pref_holder
    var/list/preferences

/datum/component/pref_holder/Destroy(force)
    LAZYNULL(preferences)

    return ..()

/datum/component/pref_holder/Initialize(    
	list/preferences
)
	var/mob/mob = parent

	if(!istype(mob) || !mob.client)
		return COMPONENT_INCOMPATIBLE

	src.preferences = preferences || forge_preferences()

/datum/component/pref_holder/proc/forge_preferences()
	var/mob/mob = parent
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
