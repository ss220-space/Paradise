//Captain fox
/mob/living/basic/pet/fox/Renault
	name = "Renault"
	desc = "Ренальд, молодой лис в самом рассвете сил. Несёт верную службу капитану."
	gender = MALE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	tts_seed = "Barney"

/mob/living/basic/pet/fox/Renault/get_ru_names()
	return list(
		NOMINATIVE = "ренальд",
		GENITIVE = "ренальда",
		DATIVE = "ренальду",
		ACCUSATIVE = "ренальда",
		INSTRUMENTAL = "ренальдом",
		PREPOSITIONAL = "ренальде",
	)

//Syndi fox
/mob/living/basic/pet/fox/Syndifox
	name = "Syndifox"
	desc = "Синдилис, очень уважаемый маскот \"Синдиката\"."
	icon_state = "Syndifox"
	icon_living = "Syndifox"
	icon_dead = "Syndifox_dead"
	faction = list("syndicate")
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	tts_seed = "Barney"
	melee_damage_lower = 10
	melee_damage_upper = 20
	minimum_survivable_temperature = 0

/mob/living/basic/pet/fox/Syndifox/get_ru_names()
	return list(
		NOMINATIVE = "Синдилис",
		GENITIVE = "Синдилиса",
		DATIVE = "Синдилису",
		ACCUSATIVE = "Синдилиса",
		INSTRUMENTAL = "Синдилисом",
		PREPOSITIONAL = "Синдилисе",
	)

/mob/living/basic/pet/fox/Syndifox/Initialize(mapload)
	. = ..()
	add_language(LANGUAGE_GALACTIC_COMMON)
	ADD_TRAIT(src, TRAIT_NO_BREATH, INNATE_TRAIT)

//Central Command Fox
/mob/living/basic/pet/fox/alisa
	name = "Alisa"
	desc = "Алиса, любимый питомец любого Офицера Специальных Операций."
	icon_state = "alisa"
	icon_living = "alisa"
	icon_dead = "alisa_dead"
	faction = list("nanotrasen")
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	melee_damage_lower = 10
	melee_damage_upper = 20
	minimum_survivable_temperature = 0

/mob/living/basic/pet/fox/alisa/get_ru_names()
	return list(
		NOMINATIVE = "Алиса",
		GENITIVE = "Алисы",
		DATIVE = "Алисе",
		ACCUSATIVE = "Алису",
		INSTRUMENTAL = "Алисой",
		PREPOSITIONAL = "Алисе",
	)

/mob/living/basic/pet/fox/alisa/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_BREATH, INNATE_TRAIT)

/mob/living/basic/pet/fox/fennec
	name = "фенек"
	desc = "Миниатюрная лисичка с ооочень большими ушами."
	gender = MALE
	icon_state = "fennec"
	icon_living = "fennec"
	icon_dead = "fennec_dead"
	nightvision = 10
	holder_type = /obj/item/holder/fennec
	tts_seed = "Riffleman"

/mob/living/basic/pet/fox/fennec/get_ru_names()
	return list(
		NOMINATIVE = "фенек",
		GENITIVE = "фенека",
		DATIVE = "фенеку",
		ACCUSATIVE = "фенека",
		INSTRUMENTAL = "фенеком",
		PREPOSITIONAL = "фенеке",
	)

/mob/living/basic/pet/fox/fennec/Fenya
	name = "Fenya"
	desc = "Миниатюрная лисичка c важным видом и очень большими ушами. Был пойман во время разливания огромного мороженого по формочкам и теперь магистрат держит его при себе и следит за ним. Похоже, ему даже нравится быть частью правосудия."
	resting = TRUE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/pet/fox/fennec/Fenya/get_ru_names()
	return list(
		NOMINATIVE = "Феня",
		GENITIVE = "Фени",
		DATIVE = "Фене",
		ACCUSATIVE = "Феню",
		INSTRUMENTAL = "Феней",
		PREPOSITIONAL = "Фене",
	)

