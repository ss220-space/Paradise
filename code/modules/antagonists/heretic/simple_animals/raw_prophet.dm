/**
 * A funny little rolling guy who is great at scouting.
 * It can see through walls, jaunt, and create a psychic network to report its findings.
 * It can blind people to make a getaway, but also get stronger if it attacks the same target consecutively.
 */
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet
	name = "Пророк Сырости"
	real_name = "Пророк Сырости"
	desc = "Мерзость, сшитая из нескольких отрубленных рук и глаза."
	gender = MALE
	icon_state = "raw_prophet"
	icon_living = "raw_prophet"
	status_flags = CANPUSH
	melee_damage_lower = 5
	melee_damage_upper = 10
	maxHealth = 90
	health = 90
	sight = SEE_MOBS|SEE_OBJS|SEE_TURFS
	/// List of innate abilities we have to add.
	var/static/list/innate_spells = list(
		/obj/effect/proc_holder/spell/ethereal_jaunt/ash/long = null,
		/obj/effect/proc_holder/spell/remotetalk/eldritch = null,
		/obj/effect/proc_holder/spell/view_range/expand_sight = null,
	)


/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/get_ru_names()
	return list(
		NOMINATIVE = "Пророк Сырости",
		GENITIVE = "Пророка Сырости",
		DATIVE = "Пророку Сырости",
		ACCUSATIVE = "Пророка Сырости",
		INSTRUMENTAL = "Пророком Сырости",
		PREPOSITIONAL = "Пророке Сырости",
	)


/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wheel)
	var/static/list/body_parts = list(/obj/effect/gibspawner/human, /obj/item/organ/external/arm, /obj/item/organ/internal/eyes)
	AddElement(/datum/element/death_drops, body_parts)
	AddComponent(/datum/component/focused_attacker)
	var/on_link_message = "Вы чувствуете, как что-то инородное проникает в ваше подсознание... \
		Вы слышите шепот людей где-то вдалеке, крики ужаса и приветственное гудение [declent_ru(GENITIVE)]."
	var/on_unlink_message = "Ваш разум пронзает волна боли! Вы больше не чувствуете [declent_ru(GENITIVE)]!"
	AddComponent( \
		/datum/component/mind_linker/active_linking, \
		network_name = "Связь Мансуса", \
		chat_color = "#568b00", \
		post_unlink_callback = CALLBACK(src, PROC_REF(after_unlink)), \
		speech_action_background_icon_state = "bg_heretic", \
		speech_action_overlay_state = "bg_heretic_border", \
		linker_spell_path = /obj/effect/proc_holder/spell/pointed/manse_link, \
		link_message = on_link_message, \
		unlink_message = on_unlink_message, \
	)

	for(var/path in get_innate_spells())
		AddSpell(new path)


/// Returns a list of abilities that we should add.
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/proc/get_innate_spells()
	var/list/returnable_list = innate_spells.Copy()
	returnable_list += list(/obj/effect/proc_holder/spell/pointed/blind/eldritch = BB_TARGETED_ACTION)
	return returnable_list


/*
 * Callback for the mind_linker component.
 * Stuns people who are ejected from the network.
 */
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/proc/after_unlink(mob/living/unlinked_mob)
	if(QDELETED(unlinked_mob) || unlinked_mob.stat == DEAD)
		return

	INVOKE_ASYNC(unlinked_mob, TYPE_PROC_REF(/mob, emote), "scream")
	unlinked_mob.AdjustParalysis(0.5 SECONDS) //micro stun


/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/AttackingTarget()
	SpinAnimation(speed = 5, loops = 1)
	if(target == src)
		return

	return ..()


/// Variant raw prophet used by eldritch transformation with more base attack power
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/ascended
	melee_damage_lower = 15
	melee_damage_upper = 20


/// NPC variant with a less bullshit ability
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/ruins
	ai_controller = /datum/ai_controller/basic_controller/raw_prophet


/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/ruins/get_innate_spells()
	var/list/returnable_list = innate_spells.Copy()
	returnable_list += list(/obj/effect/proc_holder/spell/watchers_look/heretic = BB_TARGETED_ACTION)
	return returnable_list


/// Walk and attack people, blind them when we can
/datum/ai_controller/basic_controller/raw_prophet
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
