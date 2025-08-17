/// Durable ambush mob with an EMP ability
/mob/living/simple_animal/hostile/heretic_summon/stalker
	name = "Ловец Плоти"
	real_name = "Ловец Плоти"
	desc = "Мерзость, слепленная из разрозненных человеческих останков."
	gender = MALE
	icon_state = "stalker"
	icon_living = "stalker"
	maxHealth = 300
	health = 300
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_MOBS
	ai_controller = /datum/ai_controller/basic_controller/stalker
	/// Actions to grant on spawn
	var/static/list/actions_to_add = list(
		/obj/effect/proc_holder/spell/emplosion/eldritch = BB_GENERIC_ACTION,
		/obj/effect/proc_holder/spell/ethereal_jaunt/ash = null,
		/obj/effect/proc_holder/spell/shapeshift/eldritch = BB_SHAPESHIFT_ACTION,
	)


/mob/living/simple_animal/hostile/heretic_summon/stalker/get_ru_names()
	return list(
		NOMINATIVE = "Ловец Плоти",
		GENITIVE = "Ловца Плоти",
		DATIVE = "Ловцу Плоти",
		ACCUSATIVE = "Ловца Плоти",
		INSTRUMENTAL = "Ловцом Плоти",
		PREPOSITIONAL = "Ловце Плоти",
	)


/mob/living/simple_animal/hostile/heretic_summon/stalker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_target_timer)
	for(var/path in actions_to_add)
		AddSpell(new path)


/// Changes shape and lies in wait when it has no target, uses EMP and attacks once it does
/datum/ai_controller/basic_controller/stalker
	ai_traits = CAN_ACT_IN_STASIS
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/shapechange_ambush,
		/datum/ai_planning_subtree/use_mob_ability,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
