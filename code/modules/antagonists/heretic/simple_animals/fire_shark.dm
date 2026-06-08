/mob/living/simple_animal/hostile/heretic_summon/fire_shark
	name = "Огненная Акула"
	real_name = "Огненная Акула"
	desc = "Это жуткая карликовая космическая акула."
	icon_state = "fire_shark"
	icon_living = "fire_shark"
	pass_flags = PASSTABLE | PASSMOB
	//mob_biotypes = MOB_ORGANIC | MOB_BEAST | MOB_AQUATIC
	speed = -0.6
	health = 35
	maxHealth = 35
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_sound = 'sound/weapons/bite.ogg'
	//attack_vis_effect = ATTACK_EFFECT_BITE
	obj_damage = 20
	attacktext = "кусает"
	damage_coeff = list(BRUTE = 1, BURN = 0.25, TOX = 0, STAMINA = 0, OXY = 0)
	faction = list(FACTION_HERETIC)
	mob_size = MOB_SIZE_TINY
	speak_emote = list("кричит")
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles
	//initial_language_holder = /datum/language_holder/carp/hear_common


/mob/living/simple_animal/hostile/heretic_summon/fire_shark/get_ru_names()
	return list(
		NOMINATIVE = "Огненная Акула",
		GENITIVE = "Огненной Акулы",
		DATIVE = "Огненной Акуле",
		ACCUSATIVE = "Огненную Акулу",
		INSTRUMENTAL = "Огненной Акулой",
		PREPOSITIONAL = "Огненной Акуле",
	)


/mob/living/simple_animal/hostile/heretic_summon/fire_shark/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_gases, LINDA_SPAWN_TOXINS, 40)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/venomous, "phlogiston", 2/*, injection_flags = INJECT_CHECK_PENETRATE_THICK*/)
	AddComponent(/datum/component/swarming)
	AddComponent(/datum/component/regenerator, outline_colour = COLOR_DARK_RED)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	//ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)


/mob/living/simple_animal/hostile/heretic_summon/fire_shark/wild
	faction = list(FACTION_HOSTILE)
