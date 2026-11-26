/*
 * Giant Lizard AI Planning Subtrees
 */

// MARK: Combat subtree - handles hunting and attacking targets
/datum/ai_planning_subtree/giant_lizard_combat

/datum/ai_planning_subtree/giant_lizard_combat/SelectBehaviors(datum/ai_controller/giant_lizard/controller, delta_time)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	if(!isliving(lizard) || lizard.stat == DEAD || lizard.client)
		return

	// If we have a target, try to attack it
	var/datum/weakref/target_weakref = controller.blackboard[BB_LIZARD_TARGET]
	var/mob/living/target = target_weakref?.resolve()

	if(lizard.is_eating || lizard.is_retreating || lizard.body_position == LYING_DOWN)
		return

	if(target && !QDELETED(target))
		if(target.stat == DEAD)
			controller.blackboard[BB_LIZARD_TARGET] = null
			target = null
			return
		// Pounce on nearby target if available (pounce range is 5)
		if(get_dist(lizard, target) <= 5 && !lizard.is_pouncing && COOLDOWN_FINISHED(lizard, pounce_cooldown))
			controller.queue_behavior(/datum/ai_behavior/lizard_pounce)
			return SUBTREE_RETURN_FINISH_PLANNING
		if(get_dist(lizard, target) <= GIANT_LIZARD_RETALIATE_DISTANCE)
			controller.queue_behavior(/datum/ai_behavior/lizard_attack)
			return SUBTREE_RETURN_FINISH_PLANNING // Focus on combat
		else if(get_dist(lizard, target) <= GIANT_LIZARD_MAX_ATTACK_DISTANCE * 2)
			// Move toward target - handled by ai_movement via lizard_attack/setup
			controller.queue_behavior(/datum/ai_behavior/lizard_attack)
			return SUBTREE_RETURN_FINISH_PLANNING
		else
			// Target too far, forget about it
			controller.blackboard[BB_LIZARD_TARGET] = null
			target = null

	// No active target: check intruders in retaliate distance
	if(!target)
		for(var/mob/living/carbon/intruder in view(GIANT_LIZARD_RETALIATE_DISTANCE, lizard))
			if(ismonkey(intruder) || intruder.stat != CONSCIOUS || intruder.alpha <= 200 || intruder.stat == DEAD)
				continue
			if(lizard.faction_check_mob(intruder))
				continue
			controller.blackboard[BB_LIZARD_TARGET] = WEAKREF(intruder)
			lizard.GiveTarget(intruder)
			controller.queue_behavior(/datum/ai_behavior/lizard_attack)
			return SUBTREE_RETURN_FINISH_PLANNING

// MARK: Hunt food subtree - finds and moves toward food
/datum/ai_planning_subtree/giant_lizard_hunt_food


/datum/ai_planning_subtree/giant_lizard_hunt_food/SelectBehaviors(datum/ai_controller/giant_lizard/controller, delta_time)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	if(!isliving(lizard) || lizard.stat == DEAD || lizard.client)
		return
	if(lizard.is_eating || lizard.is_retreating || lizard.body_position == LYING_DOWN)
		return

	var/obj/item/reagent_containers/food/snacks/current_food = controller.blackboard[BB_LIZARD_FOOD_TARGET]

	// Check if current food is still valid
	if(current_food && QDELETED(current_food))
		controller.blackboard[BB_LIZARD_FOOD_TARGET] = null
		current_food = null

	if(current_food && (current_food in view(6, lizard)))
		controller.queue_behavior(/datum/ai_behavior/lizard_eat_food)
		return SUBTREE_RETURN_FINISH_PLANNING

	// Search for new food
	if(COOLDOWN_FINISHED(lizard, food_cooldown))
		for(var/obj/item/reagent_containers/food/snacks/food in view(GIANT_LIZARD_FOOD_SEARCH_RANGE, lizard))
			var/is_meat = locate(/datum/reagent/consumable/nutriment/protein) in food.reagents.reagent_list
			if(is_meat || is_type_in_list(food, lizard.food_type))
				controller.blackboard[BB_LIZARD_FOOD_TARGET] = food
				lizard.food_target = food
				controller.queue_behavior(/datum/ai_behavior/lizard_eat_food)
				return SUBTREE_RETURN_FINISH_PLANNING

// MARK: Idle subtree - handles resting, retreating, growling at intruders
/datum/ai_planning_subtree/giant_lizard_idle


/datum/ai_planning_subtree/giant_lizard_idle/SelectBehaviors(datum/ai_controller/giant_lizard/controller, delta_time)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	if(!isliving(lizard) || lizard.stat == DEAD || lizard.client)
		return
	if(lizard.is_retreating || lizard.is_eating || lizard.body_position == LYING_DOWN)
		return
	// Growl at intruders in growl distance
	for(var/mob/living/carbon/intruder in view(GIANT_LIZARD_GROWL_DISTANCE, lizard))
		if(ismonkey(intruder) || intruder.stat != CONSCIOUS || intruder.alpha <= 200)
			continue
		if(lizard.faction_check_mob(intruder))
			continue
		controller.queue_behavior(/datum/ai_behavior/lizard_growl)
		return
