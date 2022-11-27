/mob/living/carbon/human/human_training
	var/obj/training_master/training_master

/mob/living/carbon/human/human_training/Initialize(mapload, datum/species/new_species)
	training_master = new(find_place_for_room(), src)
	. = ..()

/mob/living/carbon/human/human_training/Logout()
	var/mob/new_player/NP = new()
	GLOB.non_respawnable_keys -= ckey
	NP.ckey = ckey
	training_master.destroy_room()
	qdel(src)
	. = ..()

/mob/living/carbon/human/human_training/proc/find_place_for_room()
	var/place
	for(var/x = 1, x <= world.maxx - 11, x += 11)
		if (place)
			break
		for(var/y = world.maxy, y >= 6, y -= 6)
			var/turf/turf = get_turf(locate(x, y, 1))
			if (istype(turf, /turf/space))
				place = locate(x, y, 1)
				break
	return place
