//Foxxy
/mob/living/simple_animal/pet/dog/fox
	name = "fox"
	desc = "Это простая рыжая лиса."
	gender = FEMALE
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	icon_resting = "fox_rest"
	speak = list("Тяф-тяф", "Фыр-фыр-фр-фр-фыыр", "Кхи-кхихи-хихи!", "А-у-у-у-у!", "Фыр-рыр")
	speak_emote = list("хихикает", "лает", "рявкает")
	emote_hear = list("хихикает", "лает", "рявкает")
	emote_see = list("трясёт головой", "дрожит")
	tts_seed = "Jaina"
	yelp_sound = 'sound/creatures/fox_yelp.ogg' //Used on death.
	speak_chance = 1
	turns_per_move = 5
	nightvision = 6
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 3)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "пинает"
	holder_type = /obj/item/holder/fox
	collar_type = "fox"

/mob/living/simple_animal/pet/dog/fox/get_ru_names()
	return list(
		NOMINATIVE = "лиса",
		GENITIVE = "лисы",
		DATIVE = "лисе",
		ACCUSATIVE = "лису",
		INSTRUMENTAL = "лисой",
		PREPOSITIONAL = "лисе"
	)

/mob/living/simple_animal/pet/dog/fox/update_icons()
	if(stat == DEAD)
		icon_state = icon_dead
		if(collar_type)
			collar_type = "[initial(collar_type)]_dead"
		regenerate_icons()
		return
	if(resting || body_position == LYING_DOWN)
		icon_state = icon_resting
		if(collar_type)
			collar_type = "[initial(collar_type)]_rest"
		regenerate_icons()
		return
	icon_state = icon_living
	if(collar_type)
		collar_type = "[initial(collar_type)]"
	regenerate_icons()

/mob/living/simple_animal/pet/dog/fox/forest
	name = "forest fox"
	desc = "Лесная дикая лисица. Может укусить."
	gender = FEMALE
	icon_state = "fox_forest"
	icon_living = "fox_forest"
	icon_dead = "fox_forest_dead"
	icon_resting = "fox_forest_rest"
	melee_damage_type = BRUTE
	melee_damage_lower = 6
	melee_damage_upper = 12

/mob/living/simple_animal/pet/dog/fox/forest/get_ru_names()
	return list(
		NOMINATIVE = "дикая лиса",
		GENITIVE = "дикой лисы",
		DATIVE = "дикой лисе",
		ACCUSATIVE = "дикую лису",
		INSTRUMENTAL = "дикой лисой",
		PREPOSITIONAL = "дикой лисе"
	)

/mob/living/simple_animal/pet/dog/fox/forest/winter
	weather_immunities = list(TRAIT_SNOWSTORM_IMMUNE)

/mob/living/simple_animal/pet/dog/fox/forest/winter/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

//Captain fox
/mob/living/simple_animal/pet/dog/fox/Renault
	name = "Renault"
	desc = "Ренальд, молодой лис в самом рассвете сил. Несёт верную службу капитану."
	gender = MALE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	tts_seed = "Barney"

/mob/living/simple_animal/pet/dog/fox/Renault/get_ru_names()
	return list(
		NOMINATIVE = "ренальд",
		GENITIVE = "ренальда",
		DATIVE = "ренальду",
		ACCUSATIVE = "ренальда",
		INSTRUMENTAL = "ренальдом",
		PREPOSITIONAL = "ренальде"
	)

//Syndi fox
/mob/living/simple_animal/pet/dog/fox/Syndifox
	name = "Syndifox"
	desc = "Синдилис, очень уважаемый маскот Синдиката."
	icon_state = "Syndifox"
	icon_living = "Syndifox"
	icon_dead = "Syndifox_dead"
	icon_resting = "Syndifox_rest"
	faction = list("syndicate")
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	tts_seed = "Barney"
	melee_damage_lower = 10
	melee_damage_upper = 20

/mob/living/simple_animal/pet/dog/fox/Syndifox/get_ru_names()
	return list(
		NOMINATIVE = "Синдилис",
		GENITIVE = "Синдилиса",
		DATIVE = "Синдилису",
		ACCUSATIVE = "Синдилиса",
		INSTRUMENTAL = "Синдилисом",
		PREPOSITIONAL = "Синдилисе"
	)

/mob/living/simple_animal/pet/dog/fox/SyndiFox/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/pet/dog/fox/Syndifox/Initialize(mapload)
	. = ..()
	add_language(LANGUAGE_GALACTIC_COMMON)
	ADD_TRAIT(src, TRAIT_NO_BREATH, INNATE_TRAIT)


//Central Command Fox
/mob/living/simple_animal/pet/dog/fox/alisa
	name = "Alisa"
	desc = "Алиса, любимый питомец любого Офицера Специальных Операций."
	gender = FEMALE
	icon_state = "alisa"
	icon_living = "alisa"
	icon_dead = "alisa_dead"
	icon_resting = "alisa_rest"
	faction = list("nanotrasen")
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	melee_damage_lower = 10
	melee_damage_upper = 20

/mob/living/simple_animal/pet/dog/fox/alisa/get_ru_names()
	return list(
		NOMINATIVE = "Алиса",
		GENITIVE = "Алисы",
		DATIVE = "Алисе",
		ACCUSATIVE = "Алису",
		INSTRUMENTAL = "Алисой",
		PREPOSITIONAL = "Алисе"
	)

/mob/living/simple_animal/pet/dog/fox/alisa/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/pet/dog/fox/alisa/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_BREATH, INNATE_TRAIT)


/mob/living/simple_animal/pet/dog/fox/fennec
	name = "фенек"
	desc = "Миниатюрная лисичка с ооочень большими ушами."
	gender = MALE
	icon_state = "fennec"
	icon_living = "fennec"
	icon_dead = "fennec_dead"
	icon_resting = "fennec_rest"
	nightvision = 10
	holder_type = /obj/item/holder/fennec
	tts_seed = "Riffleman"

/mob/living/simple_animal/pet/dog/fox/fennec/get_ru_names()
	return list(
		NOMINATIVE = "фенек",
		GENITIVE = "фенека",
		DATIVE = "фенеку",
		ACCUSATIVE = "фенека",
		INSTRUMENTAL = "фенеком",
		PREPOSITIONAL = "фенеке"
	)
