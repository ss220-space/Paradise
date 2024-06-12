/datum/event/ion_typhoon
	var/ninja_ckey = ""


/datum/event/ion_typhoon/New(datum/event_meta/EM, mob/living/carbon/human/cause)
	if(isninja(cause))
		ninja_ckey = "[cause.ckey]"
		EM = new /datum/event_meta(EVENT_LEVEL_MAJOR, "Ninja hacking (ckey: [ninja_ckey]).", src.type)
	..()


/datum/event/ion_typhoon/start()
	var/datum/event_meta/meta_info = ninja_ckey ? new(EVENT_LEVEL_MAJOR, "Ninja hacking (ckey: [ninja_ckey]).", src.type) : null
	new /datum/event/ion_storm(EM = meta_info, botEmagChance = 0, announceEvent = 0)
	for(var/i in 1 to 2)
		meta_info = ninja_ckey ? new(EVENT_LEVEL_MAJOR, "Ninja hacking (ckey: [ninja_ckey]).", src.type) : null
		new /datum/event/ion_storm(EM = meta_info, botEmagChance = 0, announceEvent = -1)

