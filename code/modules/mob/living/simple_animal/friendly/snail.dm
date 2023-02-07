/mob/living/simple_animal/snail
	name = "space snail"
	desc = "Маленькая космо-улиточка со своим космо-домиком. Прочная, тихая и медленная."
	icon_state = "snail"
	icon_living = "snail"
	icon_dead = "snail-dead"
	tts_seed = "Ladyvashj"
	health = 100
	maxHealth = 100
	speed = 10
	attacktext = "толкает"
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	ventcrawler = 2
	density = 0
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gender = NEUTER
	can_hide = 1
	butcher_results = list(/obj/item/reagent_containers/food/snacks/salmonmeat/snailmeat = 1, /obj/item/stack/ore/tranquillite = 1)
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	stop_automated_movement_when_pulled = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("slime", "neutral")


/mob/living/simple_animal/snail/Process_Spacemove(var/movement_dir = 0)
	return 1

/mob/living/simple_animal/turtle
	name = "yeeslow"
	desc = "Большая космочерепаха. Прочная, тихая и медленная. Но почему она склизкая?"
	icon = 'icons/mob/animal.dmi'
	icon_state = "yeeslow"
	icon_living = "yeeslow"
	icon_dead = "yeeslow-dead"
	icon_resting = "yeeslow_scared"
	tts_seed = "Ladyvashj"
	health = 500
	maxHealth = 500
	speed = 20
	attacktext = "толкает"
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	ventcrawler = 0
	density = 1
	pass_flags = PASSTABLE | PASSGRILLE
	status_flags = CANPARALYSE | CANPUSH
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/reagent_containers/food/snacks/salmonmeat/turtlemeat = 10, /obj/item/stack/ore/tranquillite = 5)
	footstep_type = FOOTSTEP_MOB_SLIME
