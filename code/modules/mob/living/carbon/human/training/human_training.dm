/mob/living/carbon/human/human_training
	var/obj/training_master/training_master

/mob/living/carbon/human/human_training/Initialize(mapload, datum/species/new_species)
	training_master = new(locate(20, world.maxy - 20, 1), src)
	. = ..()
