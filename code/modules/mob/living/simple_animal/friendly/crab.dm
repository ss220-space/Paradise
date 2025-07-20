//Look Sir, free crabs!
/mob/living/simple_animal/crab
	name = "crab"
	desc = "Небольшое ракообразное с твёрдым панцирем. Похоже, что ему нравится шляться без дела."
	ru_names = list(
		NOMINATIVE = "краб",
		GENITIVE = "краба",
		DATIVE = "крабу",
		ACCUSATIVE = "краба",
		INSTRUMENTAL = "крабом",
		PREPOSITIONAL = "крабе"
	)
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("щёлкает")
	emote_hear = list("цокает клешнями")
	emote_see = list("клацает клешнями")
	death_sound = 'sound/creatures/crack_death2.ogg'
	speak_chance = 1
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 1)
	response_help  = "гладит"
	response_disarm = "отталкивает"
	response_harm   = "топчет"
	stop_automated_movement = 1
	friendly = "щипает"
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	can_hide = TRUE
	pass_door_while_hidden = TRUE
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	tts_seed = "Riki"
	holder_type = /obj/item/holder/crab
	mob_size = MOB_SIZE_SMALL


/mob/living/simple_animal/crab/royal
	name = "royal crab"
	desc = "Величественный королевский краб."
	ru_names = list(
		NOMINATIVE = "королевский краб",
		GENITIVE = "королевского краба",
		DATIVE = "королевскому крабу",
		ACCUSATIVE = "королевского краба",
		INSTRUMENTAL = "королевским крабом",
		PREPOSITIONAL = "королевском крабе"
	)
	icon_state = "royalcrab"
	icon_living = "royalcrab"
	icon_dead = "royalcrab_dead"
	response_help  = "с уважением гладит"
	response_disarm = "с уважением отталкивает"
	response_harm   = "топчет без уважения"
	health = 50
	maxHealth = 50
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 3)


//COFFEE! SQUEEEEEEEEE!
/mob/living/simple_animal/crab/Coffee
	name = "Coffee"
	real_name = "Коффи"
	desc = "Любитель потягать топливные баки и штангу. Коффи? Кофе?"
	ru_names = list(
		NOMINATIVE = "Коффи",
		GENITIVE = "Коффи",
		DATIVE = "Коффи",
		ACCUSATIVE = "Коффи",
		INSTRUMENTAL = "Коффи",
		PREPOSITIONAL = "Коффи"
	)
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

// Billy Crabbington, MASTER OF THE GYM

/mob/living/simple_animal/crab/billy
	name = "Billy Crabington"
	real_name = "Билли Крабингтон"
	desc = "Босс качалки в этом и всех ближайших секторах, известен также как мастер глубоководных подземелий. \
			От долгого нахождения в обществе суровых мужчин научился говорить несколько фраз."
	ru_names = list(
		NOMINATIVE = "Билли Крабингтон",
		GENITIVE = "Билли Крабингтона",
		DATIVE = "Билли Крабингтону",
		ACCUSATIVE = "Билли Крабингтона",
		INSTRUMENTAL = "Билли Крабингтоном",
		PREPOSITIONAL = "Билли Крабингтоне"
	)
	speak = list("ААААРГХ!", "О, йес сэр!", "Шёл бы ты, кожевник")
	emote_hear = list("клацает по своему блестящему панцирю")
	emote_see = list("играет панцирем")
	response_harm   = "шлёпает"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/crab/evil
	name = "evil crab"
	real_name = "Злой краб"
	desc = "Жуткий, да? Похоже, он что-то замышляет..."
	ru_names = list(
		NOMINATIVE = "злой краб",
		GENITIVE = "злого краба",
		DATIVE = "злому крабу",
		ACCUSATIVE = "злого краба",
		INSTRUMENTAL = "злым крабом",
		PREPOSITIONAL = "злом крабе"
	)
	icon_state = "evilcrab"
	icon_living = "evilcrab"
	icon_dead = "evilcrab_dead"
	response_help = "гладит"
	response_disarm = "отталкивает"
	response_harm = "топчет"
	gold_core_spawnable = HOSTILE_SPAWN
	holder_type = /obj/item/holder/evilcrab
