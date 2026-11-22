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
	lizard.growl(controller.blackboard[BB_LIZARD_TARGET])
	finish_action(controller, TRUE)

// MARK: Retaliate behavior - move toward target and attack
/datum/ai_behavior/lizard_retaliate
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1
	action_cooldown = 3 SECONDS

/datum/ai_behavior/lizard_retaliate/setup(datum/ai_controller/giant_lizard/controller)
	controller.current_movement_target = controller.blackboard[BB_LIZARD_TARGET]
	return TRUE

/datum/ai_behavior/lizard_retaliate/perform(delta_time, datum/ai_controller/giant_lizard/controller)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	var/atom/target = controller.blackboard[BB_LIZARD_TARGET]
	if(!isliving(lizard) || lizard.stat == DEAD || !target || QDELETED(target))
		finish_action(controller, FALSE)
		return
	if(lizard.Adjacent(target))
		lizard.AttackingTarget(target)
		finish_action(controller, TRUE)
	else if(get_dist(lizard, target) > MAX_ATTACK_DISTANCE * 2)
		finish_action(controller, FALSE)
		return
	// Movement is handled by the controller's ai_movement

// MARK: Hunt food behavior - move toward and eat food
/datum/ai_behavior/lizard_eat_food
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1
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
		lizard.handle_food(food)
		finish_action(controller, TRUE)
	else if(get_dist(lizard, food) > 10)
		finish_action(controller, FALSE)
		return

// MARK: Attack target behavior - simple melee attack
/datum/ai_behavior/lizard_attack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 1
	action_cooldown = CLICK_CD_MELEE

/datum/ai_behavior/lizard_attack/setup(datum/ai_controller/giant_lizard/controller)
	controller.current_movement_target = controller.blackboard[BB_LIZARD_TARGET]
	return TRUE

/datum/ai_behavior/lizard_attack/perform(delta_time, datum/ai_controller/giant_lizard/controller)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	var/atom/target = controller.blackboard[BB_LIZARD_TARGET]
	if(!isliving(lizard) || lizard.stat == DEAD || !target || QDELETED(target))
		finish_action(controller, FALSE)
		return
	if(lizard.Adjacent(target))
		lizard.AttackingTarget(target)
		finish_action(controller, TRUE)
	else if(get_dist(lizard, target) > MAX_ATTACK_DISTANCE * 2)
		finish_action(controller, FALSE)
		return

// MARK: Pounce behavior - leap at target
/datum/ai_behavior/lizard_pounce
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1
	action_cooldown = 10 SECONDS

/datum/ai_behavior/lizard_pounce/setup(datum/ai_controller/giant_lizard/controller)
	controller.current_movement_target = controller.blackboard[BB_LIZARD_TARGET]
	return TRUE

/datum/ai_behavior/lizard_pounce/perform(delta_time, datum/ai_controller/giant_lizard/controller)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	var/atom/target = controller.blackboard[BB_LIZARD_TARGET]
	if(!isliving(lizard) || lizard.stat == DEAD || !target || QDELETED(target))
		finish_action(controller, FALSE)
		return
	if(!COOLDOWN_FINISHED(lizard, pounce_cooldown))
		return
	if(get_dist(lizard, target) <= 8 && (prob(75) || get_dist(lizard, target) <= 5))
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
	// Find nearest non-faction target
	var/mob/living/carbon/new_target = locate(/mob/living/carbon) in view(10, lizard)
	if(new_target)
		lizard.ai_controller?.blackboard[BB_LIZARD_TARGET] = WEAKREF(new_target)
		lizard.GiveTarget(new_target)
		lizard.Retaliate()
	finish_action(controller, TRUE)

// MARK: Death emote behavior
/datum/ai_behavior/lizard_death_emote
	action_cooldown = 0.1 SECONDS

/datum/ai_behavior/lizard_death_emote/perform(delta_time, datum/ai_controller/giant_lizard/controller)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	if(isliving(lizard) && lizard.stat != DEAD)
		finish_action(controller, FALSE)
		return
	finish_action(controller, TRUE)
