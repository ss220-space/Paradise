/mob/living/proc/owns_soul()
	if(!mind)
		return FALSE
		
	return mind.soulOwner == mind

/mob/living/proc/return_soul()
	if(!mind)
		return

	mind.soulOwner = mind
	mind.damnation_type = 0

	var/datum/antagonist/devil/devil = mind?.has_antag_datum(/datum/antagonist/devil)
	if(!devil)
		return 
	
	devil.remove_soul(mind)

/proc/devilInfo(name)
	if(GLOB.allDevils[lowertext(name)])
		return GLOB.allDevils[lowertext(name)]

	var/datum/devilinfo/devilinfo = new /datum/devilinfo(name)
	GLOB.allDevils[lowertext(name)] = devilinfo

	return devilinfo
