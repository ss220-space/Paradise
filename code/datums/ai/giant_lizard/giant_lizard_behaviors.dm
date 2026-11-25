/*
 * Giant Lizard AI Behaviors
 */

// MARK: Growl behavior - emit a warning growl
/datum/ai_behavior/lizard_growl
	action_cooldown = 2 SECONDS

/datum/ai_behavior/lizard_growl/perform(delta_time, datum/ai_controller/giant_lizard/controller)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	if(!isliving(lizard) || lizard.stat == DEAD)
		finish_action(controller, FALSE)
		return
	var/atom/target = controller.blackboard[BB_LIZARD_TARGET]?.resolve()
	if(target && !QDELETED(target))
		lizard.growl(target)
	else
		lizard.growl()
	finish_action(controller, TRUE)

// MARK: Hunt food behavior - move toward and eat food
/datum/ai_behavior/lizard_eat_food
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 5 SECONDS

/datum/ai_behavior/lizard_eat_food/setup(datum/ai_controller/giant_lizard/controller)
	controller.current_movement_target = controller.blackboard[BB_LIZARD_FOOD_TARGET]
	return TRUE

/datum/ai_behavior/lizard_eat_food/perform(delta_time, datum/ai_controller/giant_lizard/controller)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	var/obj/item/reagent_containers/food/snacks/food = controller.blackboard[BB_LIZARD_FOOD_TARGET]
	if(!isliving(lizard) || lizard.stat == DEAD)
		finish_action(controller, FALSE)
		return
	if(QDELETED(food) || !(food in view(6, lizard)))
		finish_action(controller, FALSE)
		return
	if(lizard.Adjacent(food))
		INVOKE_ASYNC(lizard, TYPE_PROC_REF(/mob/living/simple_animal/hostile/giant_lizard, handle_food), food)
		finish_action(controller, TRUE)
	else if(get_dist(lizard, food) > 10)
		finish_action(controller, FALSE)
		return

// MARK: Attack target behavior - simple melee attack
/datum/ai_behavior/lizard_attack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/lizard_attack/setup(datum/ai_controller/giant_lizard/controller)
	var/atom/target = controller.blackboard[BB_LIZARD_TARGET]?.resolve()
	if(!target || QDELETED(target))
		return FALSE
	controller.current_movement_target = target
	return TRUE

/datum/ai_behavior/lizard_attack/perform(delta_time, datum/ai_controller/giant_lizard/controller)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	var/mob/living/target = controller.blackboard[BB_LIZARD_TARGET]?.resolve()
	if(!isliving(lizard) || lizard.stat == DEAD || !target || QDELETED(target) || target.stat == DEAD)
		finish_action(controller, FALSE)
		return
	if(lizard.Adjacent(target))
		lizard.AttackingTarget(target)
		finish_action(controller, TRUE)
		return
	// Target at intermediate distance: let ai_movement keep moving toward it
	// Do NOT call finish_action(FALSE) — that stops movement immediately
	return

// MARK: Pounce behavior - leap at target
/datum/ai_behavior/lizard_pounce
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 5
	action_cooldown = 10 SECONDS

/datum/ai_behavior/lizard_pounce/setup(datum/ai_controller/giant_lizard/controller)
	var/atom/target = controller.blackboard[BB_LIZARD_TARGET]?.resolve()
	if(!target || QDELETED(target))
		return FALSE
	controller.current_movement_target = target
	return TRUE

/datum/ai_behavior/lizard_pounce/perform(delta_time, datum/ai_controller/giant_lizard/controller)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	var/mob/living/target = controller.blackboard[BB_LIZARD_TARGET]?.resolve()
	if(!isliving(lizard) || lizard.stat == DEAD || !target || QDELETED(target) || target.stat == DEAD)
		finish_action(controller, FALSE)
		return
	if(!COOLDOWN_FINISHED(lizard, pounce_cooldown))
		finish_action(controller, FALSE)
		return
	if(get_dist(lizard, target) <= 5)
		lizard.pounce(target)
	finish_action(controller, TRUE)

// MARK: Pack alert behavior - received signal from another lizard
/datum/ai_behavior/lizard_pack_alert
	action_cooldown = 1 SECONDS

/datum/ai_behavior/lizard_pack_alert/perform(delta_time, datum/ai_controller/giant_lizard/controller)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	if(!isliving(lizard) || lizard.stat == DEAD || lizard.client)
		finish_action(controller, FALSE)
		return
	// Find nearest non-faction, conscious target
	var/mob/living/carbon/new_target
	for(var/mob/living/carbon/possible in view(10, lizard))
		if(possible.stat != CONSCIOUS || possible.alpha <= 200)
			continue
		if(lizard.faction_check_mob(possible))
			continue
		new_target = possible
		break
	if(new_target)
		controller.blackboard[BB_LIZARD_TARGET] = WEAKREF(new_target)
		lizard.GiveTarget(new_target)
		controller.queue_behavior(/datum/ai_behavior/lizard_attack)
	finish_action(controller, TRUE)


