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
	var/atom/target = target_weakref?.resolve()

	if(lizard.is_eating || lizard.is_retreating)
		return

	if(target && !QDELETED(target))
		if(get_dist(lizard, target) <= MAX_ATTACK_DISTANCE)
			controller.queue_behavior(/datum/ai_behavior/lizard_attack)
			return SUBTREE_RETURN_FINISH_PLANNING // Focus on combat
		else if(get_dist(lizard, target) <= MAX_ATTACK_DISTANCE * 2)
			// Move toward target - handled by ai_movement
			controller.current_movement_target = target
			controller.queue_behavior(/datum/ai_behavior/lizard_attack)
			return SUBTREE_RETURN_FINISH_PLANNING
		else
			// Target too far, forget about it
			controller.blackboard[BB_LIZARD_TARGET] = null
			target = null

	// No active target, search for one
	if(!target)
		var/list/potential_targets = lizard.ListTargets()
		var/mob/living/found_target
		for(var/atom/targ in potential_targets)
			if(isliving(targ) && lizard.CanAttack(targ))
				found_target = targ
				break

		if(found_target)
			var/mob/living/living_target = found_target
			controller.blackboard[BB_LIZARD_TARGET] = WEAKREF(living_target)
			lizard.GiveTarget(living_target)
			controller.queue_behavior(/datum/ai_behavior/lizard_retaliate)
			return SUBTREE_RETURN_FINISH_PLANNING

// MARK: Hunt food subtree - finds and moves toward food
/datum/ai_planning_subtree/giant_lizard_hunt_food


/datum/ai_planning_subtree/giant_lizard_hunt_food/SelectBehaviors(datum/ai_controller/giant_lizard/controller, delta_time)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	if(!isliving(lizard) || lizard.stat == DEAD || lizard.client)
		return
	if(lizard.is_eating || lizard.is_retreating)
		return

	var/obj/item/reagent_containers/food/snacks/current_food = controller.blackboard[BB_LIZARD_FOOD_TARGET]

	// Check if current food is still valid
	if(current_food && QDELETED(current_food))
		controller.blackboard[BB_LIZARD_FOOD_TARGET] = null
		current_food = null

	if(current_food && (current_food in view(6, lizard)))
		if(lizard.Adjacent(current_food))
			controller.queue_behavior(/datum/ai_behavior/lizard_eat_food)
		return

	// Search for new food
	if(COOLDOWN_FINISHED(lizard, food_cooldown))
		for(var/obj/item/reagent_containers/food/snacks/food in view(FOOD_SEARCH_RANGE, lizard))
			var/is_meat = locate(/datum/reagent/consumable/nutriment/protein) in food.reagents.reagent_list
			if(is_meat || is_type_in_list(food, lizard.food_type))
				controller.blackboard[BB_LIZARD_FOOD_TARGET] = food
				lizard.food_target = food
				controller.queue_behavior(/datum/ai_behavior/lizard_eat_food)
				return

// MARK: Idle subtree - handles resting, retreating, growling at intruders
/datum/ai_planning_subtree/giant_lizard_idle


/datum/ai_planning_subtree/giant_lizard_idle/SelectBehaviors(datum/ai_controller/giant_lizard/controller, delta_time)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = controller.pawn
	if(!isliving(lizard) || lizard.stat == DEAD || lizard.client)
		return
	if(lizard.is_retreating || lizard.is_eating)
		return
	if(controller.blackboard[BB_LIZARD_AGGRESSION] > 0)
		return // Combat mode takes priority

	// Growl or investigate intruders
	for(var/mob/living/carbon/intruder in view(GROWL_DISTANCE + 2, lizard))
		if((intruder.faction && length(intruder.faction) && (lizard.faction[1] in intruder.faction)) || intruder.stat != CONSCIOUS || ismonkey(intruder))
			continue
		if(intruder.alpha > 200 && isturf(intruder.loc))
			controller.queue_behavior(/datum/ai_behavior/lizard_growl)
			return

	// Handle retreat state sync
	if(lizard.is_retreating)
		controller.blackboard[BB_LIZARD_IS_RETREATING] = TRUE
	else if(controller.blackboard[BB_LIZARD_IS_RETREATING])
		controller.blackboard[BB_LIZARD_IS_RETREATING] = FALSE
