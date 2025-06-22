//////////////////The Monster

/mob/living/simple_animal/imp
	name = "imp"
	real_name = "imp"
	ru_names = list(
		NOMINATIVE = "бес",
		GENITIVE = "беса",
		DATIVE = "бесу",
		ACCUSATIVE = "беса",
		INSTRUMENTAL = "бесом",
		PREPOSITIONAL = "бесе"
	)
	desc = "Большое, грозное существо, покрытое бронированной черной чешуей."
	unique_name = TRUE
	speak_emote = list("cackles")
	emote_hear = list("cackles","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "imp"
	icon_living = "imp"
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/misc/demon_attack1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("hell")
	attacktext = "неистово терзает"
	maxHealth = 200
	health = 200
	healable = 0
	environment_smash = 1
	obj_damage = 40
	melee_damage_lower = 10
	melee_damage_upper = 15
	nightvision = 8
	fire_damage = 0
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	del_on_death = TRUE
	deathmessage = "кричит в агонии, превращаясь в сернистый дым."
	death_sound = 'sound/misc/demon_dies.ogg'
	tts_seed = "demon"

/mob/living/simple_animal/imp/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 250, \
		maxbodytemp = INFINITY, \
	)

/mob/living/simple_animal/imp/Initialize(mapload)
	. = ..()
	add_movespeed_modifier(/datum/movespeed_modifier/imp_boost)
	ADD_TRAIT(src, TRAIT_HEALS_FROM_HELL_RIFTS, INNATE_TRAIT)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/imp_boost), 6 SECONDS)

/mob/living/simple_animal/imp/death(gibbed)
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
	smoke.effect_type = /obj/effect/particle_effect/fluid/smoke/bad/hell
	smoke.set_up(range = 2, location = get_turf(src))
	. = ..()
	smoke.start()

/mob/living/simple_animal/imp/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay)
	return FALSE


/datum/antagonist/imp
	name = "Бес"
	antag_menu_name = "Бес"
	roundend_category = "devil"
	job_rank = ROLE_DEVIL
	special_role = SPECIAL_ROLE_IMP
	show_in_roundend = FALSE
	russian_wiki_name = "Торговец_душ"


/datum/antagonist/imp/give_objectives()
	add_objective(/datum/objective/imp)

/datum/antagonist/imp/greet()
	var/list/messages = list()
	messages += span_big("<b>Вы – Бес!</b>")
	messages += "<b>Вы низший ранг в иерархии ада.</b>"
	messages += "<b>Хотя вы не обязаны помогать, возможно, помогая высокопоставленному дьяволу, вы сможете получить повышение.</b>"
	messages += "<b>Вы не способны преднамеренно причинить вред дьяволу или любой другой адской сущности</b>"
	return messages

/datum/antagonist/imp/from_soul/greet()
	var/list/messages = ..()
	messages += span_warning("<b>Вы не помните ничего о своей человеческой жизни.</b>")
	return messages

/datum/antagonist/imp/demon
	name = "Демон"
	antag_menu_name = "Демон ада"
	russian_wiki_name = "Демон_резни"

/datum/antagonist/imp/demon/greet()
	var/list/messages = list()
	messages += span_big("<b>Вы – Демон!</b>")
	messages += "<b>Вы выше по рангу, чем бесы, но вы все еще можете получить повышение.</b>"
	messages += "<b>Хотя вы не обязаны помогать, возможно, помогая высокопоставленному дьяволу, вы сможете получить повышение.</b>"
	messages += "<b>Вы не способны преднамеренно причинить вред дьяволу или любой другой адской сущности</b>"
	messages += span_warning("<b>Вы не помните ничего о своей человечкской жизни.</b>")
	return messages

/datum/antagonist/imp/demon/shadow
	russian_wiki_name = "Теневой_демон"
