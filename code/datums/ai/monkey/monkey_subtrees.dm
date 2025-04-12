/datum/ai_planning_subtree/monkey_tree/SelectBehaviors(datum/ai_controller/monkey/controller, delta_time)
	var/mob/living/living_pawn = controller.pawn

	if(SHOULD_RESIST(living_pawn) && SPT_PROB(MONKEY_RESIST_PROB, delta_time))
		controller.queue_behavior(/datum/ai_behavior/resist) //BRO IM ON FUCKING FIRE BRO
		return SUBTREE_RETURN_FINISH_PLANNING //IM NOT DOING ANYTHING ELSE BUT EXTUINGISH MYSELF, GOOD GOD HAVE MERCY.

	var/list/enemies = controller.blackboard[BB_MONKEY_ENEMIES]

	if(HAS_TRAIT(controller.pawn, TRAIT_PACIFISM)) //Not a pacifist? lets try some combat behavior.
		return

	var/list/valids = list()
	for(var/mob/living/possible_enemy in view(MONKEY_ENEMY_VISION, controller.pawn))
		if(possible_enemy == controller.pawn)
			continue // don't target ourselves
		if(!enemies[possible_enemy]) //We don't hate this creature! But we might still attack it!
			if(!controller.blackboard[BB_MONKEY_AGGRESSIVE]) //We are not aggressive either, so we won't attack!
				continue
			if(faction_check(possible_enemy.faction, list("monkey"), exact_match = FALSE)) // do not target your team. includes monkys gorillas etc.
				continue
		// Weighted list, so the closer they are the more likely they are to be chosen as the enemy
		valids[possible_enemy] = CEILING(100 / (get_dist(controller.pawn, possible_enemy) || 1), 1)

		controller.set_blackboard_key(BB_MONKEY_CURRENT_ATTACK_TARGET, pick_weight_classic(valids))

		var/mob/living/selected_enemy = controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET]

		if(selected_enemy)
			if(!selected_enemy.stat) //He's up, get him!
				if(living_pawn.health < MONKEY_FLEE_HEALTH) //Time to skeddadle
					controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
					controller.queue_behavior(/datum/ai_behavior/monkey_flee)
					return //I'm running fuck you guys

				if(controller.TryFindWeapon()) //Getting a weapon is higher priority if im not fleeing.
					return SUBTREE_RETURN_FINISH_PLANNING

				controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
				controller.set_movement_target(selected_enemy)
				if(controller.blackboard[BB_MONKEY_RECRUIT_COOLDOWN] < world.time)
					controller.queue_behavior(/datum/ai_behavior/recruit_monkeys, BB_MONKEY_CURRENT_ATTACK_TARGET)
				controller.queue_behavior(/datum/ai_behavior/battle_screech/monkey)
				controller.queue_behavior(/datum/ai_behavior/monkey_attack_mob, BB_MONKEY_CURRENT_ATTACK_TARGET)
				return SUBTREE_RETURN_FINISH_PLANNING //Focus on this

			else //He's down, can we disposal him?
				var/obj/machinery/disposal/bodyDisposal = locate(/obj/machinery/disposal/) in view(MONKEY_ENEMY_VISION, living_pawn)
				if(bodyDisposal)
					controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
					controller.set_movement_target(controller, selected_enemy)
					controller.blackboard[BB_MONKEY_TARGET_DISPOSAL] = bodyDisposal
					controller.queue_behavior(/datum/ai_behavior/disposal_mob, BB_MONKEY_CURRENT_ATTACK_TARGET, BB_MONKEY_TARGET_DISPOSAL)
					return SUBTREE_RETURN_FINISH_PLANNING

	if(prob(20))
		controller.queue_behavior(/datum/ai_behavior/use_in_hand)

	if(world.time >= controller.blackboard[BB_MONKEY_NEXT_HUNGRY])
		var/list/food_candidates = list()
		for(var/obj/item as anything in list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand()))
			if(!item || !controller.IsEdible(item))
				continue
			food_candidates += item

		for(var/obj/item/candidate in oview(2, living_pawn))
			if(!controller.IsEdible(candidate))
				continue
			food_candidates += candidate

		if(length(food_candidates))
			var/obj/item/best_held = controller.GetBestWeapon(null, list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand()))
			for(var/obj/item/held as anything in list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand()))
				if(!held || held == best_held)
					continue
				living_pawn.drop_item_ground(held)

			controller.queue_behavior(/datum/ai_behavior/consume, pick(food_candidates))
			return

	if(prob(20))
		var/list/possible_targets = list()
		for(var/atom/thing in view(2, living_pawn))
			if(!thing.mouse_opacity)
				continue
			if(thing.IsObscured())
				continue
			possible_targets += thing
		var/atom/target = pick(possible_targets)
		if(target)
			controller.blackboard[BB_MONKEY_CURRENT_PRESS_TARGET] = target
			controller.queue_behavior(/datum/ai_behavior/use_on_object, BB_MONKEY_CURRENT_PRESS_TARGET)
			return

	if(prob(5) && (locate(/obj/item) in list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand())))
		var/list/possible_receivers = list()
		for(var/mob/living/candidate in oview(2, controller.pawn))
			possible_receivers += candidate

		if(length(possible_receivers))
			controller.blackboard[BB_MONKEY_CURRENT_GIVE_TARGET] = pick(possible_receivers)
			controller.queue_behavior(/datum/ai_behavior/give, BB_MONKEY_CURRENT_GIVE_TARGET)
			return

	controller.TryFindWeapon()
