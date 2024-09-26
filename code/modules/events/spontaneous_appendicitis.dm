/datum/event/spontaneous_appendicitis/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
		if(!H.client)
			continue
		var/datum/disease/appendicitis/D = new
		if(D.Contract(H))
			break
