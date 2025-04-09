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
