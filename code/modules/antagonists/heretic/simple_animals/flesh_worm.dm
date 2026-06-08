/// Armsy starts to look a bit funky if he's shorter than this
#define MINIMUM_ARMSY_LENGTH 2

// What if we took a linked list... But made it a mob?
/// The "Terror of the Night" / Armsy, a large worm made of multiple bodyparts that occupies multiple tiles
/mob/living/simple_animal/hostile/heretic_summon/armsy
	name = "Лорд Ночи"
	real_name = "Повелитель Распада"
	desc = "Мерзость, созданная из десятков отрубленных и изуродованных конечностей, цепляющихся друг за друга."
	gender = MALE
	icon_state = "armsy_start"
	icon_living = "armsy_start"
	base_icon_state = "armsy"
	maxHealth = 500
	health = 500
	melee_damage_lower = 30
	melee_damage_upper = 50
	obj_damage = 200
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	sentience_type = SENTIENCE_BOSS
	//mob_biotypes = MOB_ORGANIC|MOB_SPECIAL
	///Previous segment in the chain, we hold onto this purely to keep track of how long we currently are and to attach new growth to the back_tg
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/back_tg
	///How many arms do we have to eat to expand?
	var/stacks_to_grow = 5
	///Currently eaten arms
	var/current_stacks = 0


/mob/living/simple_animal/hostile/heretic_summon/armsy/get_ru_names()
	return list(
		NOMINATIVE = "Лорд Ночи",
		GENITIVE = "Лорда Ночи",
		DATIVE = "Лорду Ночи",
		ACCUSATIVE = "Лорда Ночи",
		INSTRUMENTAL = "Лордом Ночи",
		PREPOSITIONAL = "Лорде Ночи",
	)


/*
 * Arguments
 * * spawn_bodyparts - whether we spawn additional armsy bodies until we reach length.
 * * worm_length - the length of the worm we're creating. Below 2 doesn't work very well.
 */
/mob/living/simple_animal/hostile/heretic_summon/armsy/Initialize(mapload, spawn_bodyparts = TRUE, worm_length = 6)
	. = ..()
	AddElement(/datum/element/wall_smasher, ENVIRONMENT_SMASH_RWALLS)
	AddComponent(\
		/datum/component/amputating_limbs,\
		surgery_time = 0 SECONDS,\
		surgery_verb = "tears",\
		minimum_stat = CONSCIOUS,\
		snip_chance = 10,\
		target_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM),\
	)
	AddComponent(\
		/datum/component/blood_walk, \
		target_dir_change = TRUE,\
	)

	if(!spawn_bodyparts)
		return

	build_tail(worm_length)


// We are a vessel of otherworldly destruction, we bring our gravity with us
/mob/living/simple_animal/hostile/heretic_summon/armsy/mob_negates_gravity()
	return TRUE


/mob/living/simple_animal/hostile/heretic_summon/armsy/can_be_pulled(user, force)
	return FALSE // The component does this but not on the head. We don't want the head to be pulled either.


/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/build_tail(worm_length)
	worm_length = max(worm_length, MINIMUM_ARMSY_LENGTH)
	// Sets the hp of the head to be exactly the (length * hp), so the head is de facto the hardest to destroy.
	maxHealth = worm_length * maxHealth
	health = maxHealth

	AddComponent(/datum/component/mob_chain, vary_icon_state = TRUE) // We're the front

	var/mob/living/simple_animal/hostile/heretic_summon/armsy/prev = src
	for(var/i in 1 to worm_length)
		prev = new_segment(behind = prev)

	update_appearance(UPDATE_ICON_STATE)


/// Grows a new segment behind the passed mob
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/new_segment(mob/living/simple_animal/hostile/heretic_summon/armsy/behind)
	var/mob/living/segment = new type(drop_location(), FALSE)
	segment.AddComponent(/datum/component/mob_chain, front = behind, vary_icon_state = TRUE)
	behind.register_behind(segment)
	toggle_ai(AI_OFF)
	can_have_ai = FALSE
	shouldwakeup = FALSE
	return segment


/// Record that we got another guy on our ass
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/register_behind(mob/living/tail)
	if(!isnull(back_tg)) // Shouldn't happen but just in case
		UnregisterSignal(back_tg, COMSIG_QDELETING)

	back_tg = tail
	update_appearance(UPDATE_ICON_STATE)
	if(isnull(back_tg))
		return

	RegisterSignal(back_tg, COMSIG_QDELETING, PROC_REF(tail_deleted))


/// When our tail is gone stop holding a reference to it
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/tail_deleted()
	SIGNAL_HANDLER
	register_behind(null)

/mob/living/simple_animal/hostile/heretic_summon/armsy/AttackingTarget()
	if(!istype(target, /obj/item/organ/external/arm))
		return ..()

	visible_message(span_warning("[src] devours [target]!"))
	playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
	qdel(target)
	on_arm_eaten()


/*
 * Handle healing our chain.
 * Eating arms off the ground heals us, and if we eat enough arms while above a certain health threshold we get longer!
 */
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/on_arm_eaten()
	if(!isnull(back_tg))
		back_tg.on_arm_eaten()
		return

	adjustBruteLoss(-maxHealth * 0.5, FALSE)
	adjustFireLoss(-maxHealth * 0.5, FALSE)

	if(health < maxHealth * 0.8)
		return

	current_stacks++
	if(current_stacks < stacks_to_grow)
		return

	visible_message(span_boldwarning("[src] flexes and expands!"))
	current_stacks = 0
	new_segment(behind = src)


/*
 * Recursively get the length of our chain.
 */
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/get_length()
	. = 1
	if(isnull(back_tg))
		return

	. += back_tg.get_length()

#undef MINIMUM_ARMSY_LENGTH
