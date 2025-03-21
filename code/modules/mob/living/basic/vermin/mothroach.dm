/mob/living/basic/mothroach
	name = "mothroach"
	desc = "Это очень милый побочный продукт скрещивания мотылей и тараканов."
	ru_names = list(
		NOMINATIVE = "мотылёк",
		GENITIVE = "мотылька",
		DATIVE = "мотыльку",
		ACCUSATIVE = "мотылька",
		INSTRUMENTAL = "мотыльком",
		PREPOSITIONAL = "мотыльке"
	)
	icon = 'icons/mob/pets.dmi'
	icon_state = "mothroach"
	icon_living = "mothroach"
	icon_dead = "mothroach_dead"
	holder_type = /obj/item/holder/mothroach
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat = 1)
	tts_seed = "Tychus"
	density = TRUE
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	gold_core_spawnable = FRIENDLY_SPAWN
	mob_size = MOB_SIZE_SMALL
	health = 25
	maxHealth = 25
	speed = 1.25
	faction = list("neutral")
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS

	verb_say = "пищит"
	verb_ask = "пищит с любопытством"
	verb_exclaim = "громко пищит"
	verb_yell = "громко пищит"
	response_disarm_continuous = "прогоняет"
	response_disarm_simple = "прогнали"
	response_harm_continuous = "ударяет"
	response_harm_simple = "ударили"
	response_help_continuous = "гладит"
	response_help_simple = "гладите"

	ai_controller = /datum/ai_controller/basic_controller/mothroach

/mob/living/basic/mothroach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, emote_message = "радостно пищит!")

/mob/living/basic/mothroach/update_resting()
	. = ..()
	if(stat == DEAD)
		return
	if(resting)
		icon_state = "[icon_living]_sleep"
	else
		icon_state = "[icon_living]"

/datum/ai_controller/basic_controller/mothroach
	blackboard = list()

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/mothroach,
		/datum/ai_planning_subtree/find_and_hunt_target/mothroach,
	)
