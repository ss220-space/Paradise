/mob/living/simple_animal/possum
	name = "possum"
	desc = "Мелкая зверушка с планеты Земля. Каким-то образом они стали очень распространены в обитаемой части космоса."
	icon = 'icons/mob/pets.dmi'
	icon_state = "possum"
	icon_living = "possum"
	icon_dead = "possum_dead"
	icon_resting = "possum_rest"
	var/icon_harm = "possum_scream"
	response_help  = "гладит"
	response_disarm = "толкает"
	response_harm   = "пинает"
	speak = list("Шшшшш...", "Ссссс...")
	speak_emote = list("шипит", "бурчит")
	emote_hear = list("шипит", "бурчит")
	emote_see = list("трясёт головой", "гоняется за своим хвостом", "дрожит")
	tts_seed = "Clockwerk"
	faction = list("neutral")
	maxHealth = 30
	health = 30
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	blood_volume = BLOOD_VOLUME_NORMAL
	melee_damage_type = STAMINA
	melee_damage_lower = 3
	melee_damage_upper = 8
	attacktext = "кусает"
	attack_sound = 'sound/weapons/bite.ogg'
	nightvision = 5
	speak_chance = 1
	turns_per_move = 10
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 2)
	holder_type = /obj/item/holder/possum
	/// Used to change default standing icon to aggressive one
	var/was_harmed = FALSE

/mob/living/simple_animal/possum/get_ru_names()
	return list(
		NOMINATIVE = "опоссум",
		GENITIVE = "опоссума",
		DATIVE = "опоссуму",
		ACCUSATIVE = "опоссума",
		INSTRUMENTAL = "опоссумом",
		PREPOSITIONAL = "опоссуме"
	)

/mob/living/simple_animal/possum/attack_hand(mob/user)
	if(user.a_intent == INTENT_HELP)
		was_harmed = FALSE
		update_icons()
	return ..()


/mob/living/simple_animal/possum/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = ..()
	if(. && amount > 0)
		was_harmed = TRUE
		update_icons()


/mob/living/simple_animal/possum/update_icons()
	. = ..()
	if(stat == DEAD || resting || body_position == LYING_DOWN || !was_harmed)
		return
	icon_state = icon_harm


/mob/living/simple_animal/possum/Poppy
	name = "Poppy"
	desc = "Маленький работяга. Его жилетка подчеркивает его рабочие... лапы. Тот ещё трудяга. Очень не любит ассистентов в инженерном отделе. И Полли. Интересно, почему?"
	icon_state = "possum_poppy"
	icon_living = "possum_poppy"
	icon_dead = "possum_poppy_dead"
	icon_resting = "possum_poppy_rest"
	icon_harm = "possum_poppy_scream"
	holder_type = /obj/item/holder/possum/poppy
	maxHealth = 50
	health = 50

/mob/living/simple_animal/possum/Poppy/get_ru_names()
	return list(
		NOMINATIVE = "Ключик",
		GENITIVE = "Ключика",
		DATIVE = "Ключику",
		ACCUSATIVE = "Ключика",
		INSTRUMENTAL = "Ключиком",
		PREPOSITIONAL = "Ключике"
	)
