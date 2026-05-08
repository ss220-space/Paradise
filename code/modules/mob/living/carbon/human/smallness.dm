/mob/living/carbon/human/proc/is_small_pickupable()
	return HAS_TRAIT(src, TRAIT_SMALL_MOB)

/mob/living/carbon/human/proc/can_jump_on_back_of(mob/living/carbon/human/target_human)
	if(!target_human)
		return FALSE
	if(!is_small_pickupable())
		return FALSE
	if(target_human == src)
		return FALSE
	if(stat != CONSCIOUS || target_human.stat != CONSCIOUS)
		return FALSE
	if(!Adjacent(target_human))
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/try_jump_on_back(mob/living/carbon/human/target_human)
	if(!can_jump_on_back_of(target_human))
		return FALSE
	if(buckled)
		return FALSE

	visible_message(
		span_notice("[src] готовится запрыгнуть [target_human.declent_ru(PREPOSITIONAL)] на спину."),
		span_notice("Вы готовитесь запрыгнуть [target_human.declent_ru(PREPOSITIONAL)] на спину."),
	)

	if(!do_after(src, 1 SECONDS, target_human, timed_action_flags = DA_IGNORE_HELD_ITEM | DA_IGNORE_LYING, extra_checks = CALLBACK(src, PROC_REF(can_jump_on_back_of), target_human), max_interact_count = 1, cancel_on_max = TRUE))
		return TRUE
	if(!can_jump_on_back_of(target_human))
		return TRUE

	if(!target_human.buckle_mob(src, force = TRUE, check_loc = FALSE, buckle_mob_flags = RIDER_NEEDS_ARMS))
		return TRUE
	return TRUE

