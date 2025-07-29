/mob/living/simple_animal/hostile/retaliate/clown
	name = "clown"
	desc = "Житель планеты клоунов."
	ru_names = list(
		NOMINATIVE = "клоун",
		GENITIVE = "клоуна",
		DATIVE = "клоуну",
		ACCUSATIVE = "клоуна",
		INSTRUMENTAL = "клоуном",
		PREPOSITIONAL = "клоуне"
	)
	gender = MALE
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "тычет в"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "бьёт"
	speak = list("ХОНК!", "Хонк!", "Добро пожаловать на планету клоунов!")
	emote_see = list("хонкает")
	speak_chance = 1
	a_intent = INTENT_HARM
	maxHealth = 75
	health = 75
	speed = 0
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "атакует"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 0
	environment_smash = 0
	unsuitable_atmos_damage = 10
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/retaliate/clown/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 270, \
		maxbodytemp = 370, \
		heat_damage = 15, \
		cold_damage = 10, \
	)

/mob/living/simple_animal/hostile/retaliate/clown/goblin
	name = "clown goblin"
	desc = "Крошечные ходячие маска и клоунские башмачки. Так и хочется расквасить им нос!"
	ru_names = list(
		NOMINATIVE = "клоун-гоблин",
		GENITIVE = "клоуна-гоблина",
		DATIVE = "клоуну-гоблину",
		ACCUSATIVE = "клоуна-гоблина",
		INSTRUMENTAL = "клоуном-гоблином",
		PREPOSITIONAL = "клоуне-гоблине"
	)
	icon = 'icons/mob/animal.dmi'
	icon_state = "clowngoblin"
	icon_living = "clowngoblin"
	icon_dead = null
	response_help = "хонкает"
	speak = list("ХОНК!")
	speak_emote = list("пищит")
	emote_see = list("хонкает")
	maxHealth = 100
	health = 100

	speed = -1
	turns_per_move = 1

	del_on_death = TRUE
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/item/clothing/shoes/clown_shoes)

	holder_type = /obj/item/holder/clowngoblin

/mob/living/simple_animal/hostile/retaliate/clown/goblin/cluwne
	name = "cluwne goblin"
	desc = "Крошечное воплощение страдания и зла. Уничтожьте его, пока оно не добралось до вашей семьи."
	ru_names = list(
		NOMINATIVE = "неуклюжий гоблин",
		GENITIVE = "неуклюжего гоблина",
		DATIVE = "неуклюжему гоблину",
		ACCUSATIVE = "неуклюжего гоблина",
		INSTRUMENTAL = "неуклюжим гоблином",
		PREPOSITIONAL = "неуклюжем гоблине"
	)
	icon_state = "cluwnegoblin"
	icon_living = "cluwnegoblin"
	response_help = "henks the"
	speak = list("ХЕ-ХЕНК!")
	speak_emote = list("злобно пищит")
	emote_see = list("хе-хенкает")
	maxHealth = 150
	health = 150
	harm_intent_damage = 15
	melee_damage_lower = 17
	melee_damage_upper = 20
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	move_to_delay = 2

	loot = list(/obj/item/clothing/mask/false_cluwne_mask, /obj/item/clothing/shoes/clown_shoes/false_cluwne_shoes) // We'd rather not give them ACTUAL cluwne stuff you know?

/mob/living/simple_animal/hostile/retaliate/clown/goblin/cluwne/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
		maxbodytemp = INFINITY, \
	)

