/mob/living/basic/cockroach
	name = "cockroach"
	desc = "Эта станция просто кишит вредителями."
	ru_names = list(
		NOMINATIVE = "таракан",
		GENITIVE = "таракана",
		DATIVE = "таракану",
		ACCUSATIVE = "таракана",
		INSTRUMENTAL = "тараканом",
		PREPOSITIONAL = "таракане"
	)
	icon_state = "cockroach"
	icon_dead = "cockroach" //Make this work
	density = FALSE
	//mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	mob_size = MOB_SIZE_TINY
	health = 1
	maxHealth = 1
	speed = 1.25
	gold_core_spawnable = FRIENDLY_SPAWN
	pass_flags = PASSTABLE | PASSMOB
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	verb_say = "щебечет"
	verb_ask = "щебечет с любопытством"
	verb_exclaim = "громко щебечет"
	verb_yell = "громко щебечет"
	response_disarm_continuous = "прогоняет"
	response_disarm_simple = "прогнали"
	response_harm_continuous = "давит"
	response_harm_simple = "раздавливаете"
	speak_emote = list("щебечет")
	layer = BELOW_MOB_LAYER //when you stomp on it and he lives, it looks kinda bad
	basic_mob_flags = DEL_ON_DEATH
	faction = list("hostile")
	affects_by_temperature = FALSE

	ai_controller = /datum/ai_controller/basic_controller/cockroach

/mob/living/basic/cockroach/Initialize()
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/effect/decal/cleanable/insectguts))
	AddComponent(/datum/component/squashable, squash_chance = 30, squash_damage = 1)

/mob/living/basic/cockroach/death(gibbed)
	if(SSticker?.mode?.explosion_in_progress) //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.
		return
	..()

/mob/living/basic/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return FALSE

/datum/ai_controller/basic_controller/cockroach
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cockroach,
		/datum/ai_planning_subtree/find_and_hunt_target/cockroach,
	)

/obj/projectile/glockroachbullet
	damage = 8
	damage_type = BRUTE

/obj/item/ammo_casing/caseless/glockroach
	name = "0.9mm bullet casing"
	desc = "A... 0.9mm bullet casing? What?"
	projectile_type = /obj/projectile/glockroachbullet

/mob/living/basic/cockroach/glockroach
	name = "glockroach"
	ru_names = list(
		NOMINATIVE = "таракан с пушкой",
		GENITIVE = "таракана с пушкой",
		DATIVE = "таракану с пушкой",
		ACCUSATIVE = "таракана с пушкой",
		INSTRUMENTAL = "тараканом с пушкой",
		PREPOSITIONAL = "таракане с пушкой"
	)
	desc = "КТО, ЧЁРТ ВОЗЬМИ, ДАЛ ТАРАКАНУ ПИСТОЛЕТ?"
	icon_state = "glockroach"
	obj_damage = 5
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("hostile")
	ai_controller = /datum/ai_controller/basic_controller/cockroach/glockroach

/mob/living/basic/cockroach/glockroach/Initialize()
	. = ..()
	AddElement(/datum/element/ranged_attacks, /obj/item/ammo_casing/caseless/glockroach, 'sound/weapons/gunshots/gunshot3.ogg')

/datum/ai_controller/basic_controller/cockroach/glockroach
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cockroach,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/glockroach, //If we are attacking someone, this will prevent us from hunting
		/datum/ai_planning_subtree/find_and_hunt_target
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/glockroach
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/glockroach

/datum/ai_behavior/basic_ranged_attack/glockroach //Slightly slower, as this is being made in feature freeze ;)
	action_cooldown = 1 SECONDS

/mob/living/basic/cockroach/hauberoach
	name = "hauberoach"
	desc = "Погодите, этот таракан носит на голове небольшую реплику остроконечного шлема Прусской армии образца 19 века? Это.. это плохо?"
	ru_names = list(
		NOMINATIVE = "таракан-солдат",
		GENITIVE = "таракана-солдата",
		DATIVE = "таракану-солдату",
		ACCUSATIVE = "таракана-солдата",
		INSTRUMENTAL = "тараканом-солдатом",
		PREPOSITIONAL = "таракане-солдате"
	)
	icon_state = "hauberoach"
	attack_verb_continuous = "тыкает своим шлемом"
	attack_verb_simple = "тыкаете своим шлемом"
	melee_damage = 5
	obj_damage = 8
	gold_core_spawnable = HOSTILE_SPAWN
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("hostile")
	ai_controller = /datum/ai_controller/basic_controller/cockroach/hauberoach

/mob/living/basic/cockroach/hauberoach/Initialize()
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = 10, max_damage = 15, flags = (CALTROP_BYPASS_SHOES))
	AddComponent( \
		/datum/component/squashable, \
		squash_chance = 100, \
		squash_damage = 1, \
		squash_flags = SQUASHED_SHOULD_BE_GIBBED, \
		squash_callback = TYPE_PROC_REF(/mob/living/basic/cockroach/hauberoach, on_squish), \
	)

///Proc used to override the squashing behavior of the normal cockroach.
/mob/living/basic/cockroach/hauberoach/proc/on_squish(mob/living/cockroach, mob/living/living_target)
	if(!istype(living_target))
		return FALSE //We failed to run the invoke. Might be because we're a structure. Let the squashable element handle it then!
	if(!HAS_TRAIT(living_target, TRAIT_PIERCEIMMUNE))
		living_target.visible_message(span_danger("[living_target] наступает на шип [declent_ru(ACCUSATIVE)]!"), span_userdanger("Вы наступили на шип [declent_ru(ACCUSATIVE)]!"))
		return TRUE
	living_target.visible_message(span_notice("[living_target] раздавливает [declent_ru(ACCUSATIVE)], даже не замечая его шипы."), span_notice("Вы раздавливаете [declent_ru(ACCUSATIVE)], даже не замечая его шипов."))
	return FALSE

/datum/ai_controller/basic_controller/cockroach/hauberoach
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cockroach,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,  //If we are attacking someone, this will prevent us from hunting
		/datum/ai_planning_subtree/find_and_hunt_target/cockroach,
	)


