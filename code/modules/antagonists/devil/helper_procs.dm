/mob/living/proc/owns_soul()
	if(!mind)
		return FALSE
		
	return mind.soulOwner == mind

/proc/devilInfo(name)
	if(GLOB.allDevils[lowertext(name)])
		return GLOB.allDevils[lowertext(name)]

	var/datum/devilinfo/devilinfo = new /datum/devilinfo(name)
	GLOB.allDevils[lowertext(name)] = devilinfo

	return devilinfo
