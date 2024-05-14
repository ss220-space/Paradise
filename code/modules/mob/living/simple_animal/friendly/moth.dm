/mob/living/simple_animal/moth
	name = "моль"
	desc = "Смотря на эту моль становится понятно куда пропали шубы перевозимые СССП."
	icon = 'icons/mob/animal.dmi'
	icon_state = "moth"
	icon_living = "moth"
	icon_dead = "moth_dead"
	turns_per_move = 1
	speak = list("Furrr.","Uhh.", "Hurrr.")
	emote_see = list("flutters")
	response_help = "shoos"
	response_disarm = "brushes aside"
	response_harm = "squashes"
	speak_chance = 0
	maxHealth = 15
	health = 15
	nightvision = 100
	friendly = "nudges"
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat = 1)
	gold_core_spawnable = FRIENDLY_SPAWN
	holder_type = /obj/item/holder/moth
	tts_seed = "Tychus"


/mob/living/simple_animal/moth/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)


/mob/living/simple_animal/mothroach
	name = "mothroach"
	desc = "Мотылёк. Обожает светочи."
	icon = 'icons/mob/pets.dmi'
	icon_state = "mothroach"
	icon_living = "mothroach"
	icon_dead = "mothroach_dead"
	icon_resting = "mothroach_sleep"
	speak = list("Furrr.","Uhh.", "Hurrr.")
	speak_chance = 0
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	faction = list("neutral")
	maxHealth = 15
	health = 15
	nightvision = 30
	turns_per_move = 10
	emote_see = list("flutters")
	response_help = "shoos"
	response_disarm = "brushes aside"
	response_harm = "squashes"
	friendly = "nudges"
	density = FALSE
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_BAREFOOT
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat = 1)
	holder_type = /obj/item/holder/mothroach
	tts_seed = "Tychus"
