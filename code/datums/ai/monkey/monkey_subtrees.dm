/datum/ai_planning_subtree/monkey_tree/SelectBehaviors(datum/ai_controller/monkey/controller, delta_time)
	var/mob/living/living_pawn = controller.pawn

	if(SHOULD_RESIST(living_pawn) && SPT_PROB(MONKEY_RESIST_PROB, delta_time))
		controller.queue_behavior(/datum/ai_behavior/resist) //BRO IM ON FUCKING FIRE BRO
		return SUBTREE_RETURN_FINISH_PLANNING //IM NOT DOING ANYTHING ELSE BUT EXTUINGISH MYSELF, GOOD GOD HAVE MERCY.

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

///monkey combat subtree.
/datum/ai_planning_subtree/monkey_combat/SelectBehaviors(datum/ai_controller/monkey/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	var/list/enemies = controller.blackboard[BB_MONKEY_ENEMIES]

	if((HAS_TRAIT(controller.pawn, TRAIT_PACIFISM)) || (!length(enemies) && !controller.blackboard[BB_MONKEY_AGGRESSIVE])) //Pacifist, or we have no enemies and we're not pissed
		return

	if(!controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET])
		controller.queue_behavior(/datum/ai_behavior/monkey_set_combat_target, BB_MONKEY_CURRENT_ATTACK_TARGET, BB_MONKEY_ENEMIES)
		return

	var/mob/living/selected_enemy = controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET]

	if(QDELETED(selected_enemy))
		return

	if(!selected_enemy.stat) //He's up, get him!
		if(living_pawn.health < MONKEY_FLEE_HEALTH) //Time to skeddadle
			controller.queue_behavior(/datum/ai_behavior/monkey_flee)
			return

		if(controller.TryFindWeapon()) //Getting a weapon is higher priority if im not fleeing.
			return

		if(controller.blackboard[BB_MONKEY_RECRUIT_COOLDOWN] < world.time)
			controller.queue_behavior(/datum/ai_behavior/recruit_monkeys, BB_MONKEY_CURRENT_ATTACK_TARGET)
			return

		controller.queue_behavior(/datum/ai_behavior/battle_screech/monkey)
		controller.queue_behavior(/datum/ai_behavior/monkey_attack_mob, BB_MONKEY_CURRENT_ATTACK_TARGET)
		return
	//by this point we have a target but they're down, let's try dumpstering this loser

	controller.queue_behavior(/datum/ai_behavior/disposal_mob, BB_MONKEY_CURRENT_ATTACK_TARGET, BB_MONKEY_TARGET_DISPOSAL)
	return
