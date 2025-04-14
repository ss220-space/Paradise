/datum/ai_behavior/battle_screech/monkey
	screeches = list("roar","screech")

/datum/ai_behavior/monkey_equip
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/monkey_equip/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/monkey_equip/finish_action(datum/ai_controller/controller, success)
	. = ..()

	if(!success) //Don't try again on this item if we failed
		controller.set_blackboard_key_assoc(BB_MONKEY_BLACKLISTITEMS, controller.blackboard[BB_MONKEY_PICKUPTARGET], TRUE)

	controller.clear_blackboard_key(BB_MONKEY_PICKUPTARGET)

/// Equips an item on the monkey
/// Returns TRUE if it works out, FALSE otherwise
/datum/ai_behavior/monkey_equip/proc/equip_item(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	var/obj/item/target = controller.blackboard[BB_MONKEY_PICKUPTARGET]
	var/best_force = controller.blackboard[BB_MONKEY_BEST_FORCE_FOUND]

	if(!isturf(living_pawn.loc))
		finish_action(controller, FALSE)
		return

	if(!target)
		finish_action(controller, FALSE)
		return

	if(target.anchored) //Can't pick it up, so stop trying.
		finish_action(controller, FALSE)
		return

	// Strong weapon
	else if(target.force > best_force)
		living_pawn.drop_all_held_items()
		living_pawn.put_in_hands(target)
		controller.set_blackboard_key(BB_MONKEY_BEST_FORCE_FOUND, target.force)
		finish_action(controller, TRUE)
		return

	else if(target.slot_flags) //Clothing == top priority
		living_pawn.drop_item_ground(target, TRUE)
		living_pawn.update_icons()
		if(!living_pawn.equip_to_appropriate_slot(target))
			finish_action(controller, FALSE)
			return //Already wearing something, in the future this should probably replace the current item but the code didn't actually do that, and I dont want to support it right now.
		finish_action(controller, TRUE)
		return

	// EVERYTHING ELSE
	else if(living_pawn.get_item_by_slot(ITEM_SLOT_HAND_LEFT) || living_pawn.get_item_by_slot(ITEM_SLOT_HAND_RIGHT))
		living_pawn.put_in_hands(target)
		finish_action(controller, TRUE)
		return

	finish_action(controller, FALSE)

/datum/ai_behavior/monkey_equip/ground
	required_distance = 0

/datum/ai_behavior/monkey_equip/ground/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	equip_item(controller)

/datum/ai_behavior/monkey_equip/pickpocket

/datum/ai_behavior/monkey_equip/pickpocket/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	if(controller.blackboard[BB_MONKEY_PICKPOCKETING]) //We are pickpocketing, don't do ANYTHING!!!!
		return

	INVOKE_ASYNC(src, PROC_REF(attempt_pickpocket), controller)

/datum/ai_behavior/monkey_equip/pickpocket/proc/attempt_pickpocket(datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[BB_MONKEY_PICKUPTARGET]

	var/mob/living/victim = target.loc
	var/mob/living/living_pawn = controller.pawn

	if(!istype(victim))
		finish_action(controller, FALSE)
		return

	victim.visible_message(span_warning("[living_pawn] пытается взять [target.declent_ru(ACCUSATIVE)] у [victim]!"),
			span_danger("[living_pawn] пытается взять [target.declent_ru(ACCUSATIVE)]!")
	)

	controller.set_blackboard_key(BB_MONKEY_PICKPOCKETING, TRUE)

	var/success = FALSE

	if(do_after(living_pawn, MONKEY_ITEM_SNATCH_DELAY, victim) && target && living_pawn.Adjacent(victim))
		for(var/obj/item/I in list(victim.get_active_hand(), victim.get_inactive_hand()))
			if(I == target)
				victim.visible_message(span_danger("[living_pawn] ворует [target.declent_ru(ACCUSATIVE)] у [victim]!"),
					span_userdanger("[living_pawn] своровала [target.declent_ru(ACCUSATIVE)]!")
				)
				if(victim.temporarily_remove_item_from_inventory(target))
					if(!QDELETED(target))
						target.forceMove(living_pawn.drop_location())
						equip_item(controller)
						success = TRUE
						break
				else
					victim.visible_message(span_danger("[living_pawn] пыта[pluralize_ru(living_pawn.gender,"ется","ются")] украсть [target.declent_ru(ACCUSATIVE)] у [victim], но провалива[pluralize_ru(living_pawn.gender,"ется","ются")]!"),
						span_userdanger("[living_pawn] пыта[pluralize_ru(living_pawn.gender,"ется","ются")] украсть [target.declent_ru(ACCUSATIVE)]!")
					)

	finish_action(controller, success) //We either fucked up or got the item.

/datum/ai_behavior/monkey_equip/pickpocket/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.set_blackboard_key(BB_MONKEY_PICKPOCKETING, FALSE)
	controller.clear_blackboard_key(BB_MONKEY_PICKUPTARGET)

/datum/ai_behavior/monkey_flee

/datum/ai_behavior/monkey_flee/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()

	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.health >= MONKEY_FLEE_HEALTH)
		finish_action(controller, TRUE) //we're back in bussiness

	var/mob/living/target = null

	// flee from anyone who attacked us and we didn't beat down
	for(var/mob/living/L in view(living_pawn, MONKEY_FLEE_VISION))
		if(controller.blackboard[BB_MONKEY_ENEMIES][L] && L.stat == CONSCIOUS)
			target = L
			break

	if(target)
		SSmove_manager.move_away(living_pawn, target, max_dist = MONKEY_ENEMY_VISION, delay = 5)
	else
		finish_action(controller, TRUE)

/datum/ai_behavior/monkey_attack_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/monkey_attack_mob/setup(datum/ai_controller/controller, target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[target_key])

/datum/ai_behavior/monkey_attack_mob/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()

	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])

	if(QDELETED(target) || !strategy.can_attack(living_pawn, target)) //Target == owned
		finish_action(controller, TRUE)

	// check if target has a weapon
	var/holding_weapon
	for(var/obj/item/potential_weapon in list(target.get_active_hand(), target.get_inactive_hand()))
		if(!(potential_weapon.item_flags & ABSTRACT))
			holding_weapon = potential_weapon
			break

	var/attack_results = monkey_attack(controller, target, seconds_per_tick, holding_weapon && SPT_PROB(MONKEY_ATTACK_DISARM_PROB, seconds_per_tick), holding_weapon)

	if(!attack_results || controller.blackboard[BB_MONKEY_AGGRESSIVE])
		return

	//check if we can de-aggro on the enemy...
	var/hatred_value = controller.blackboard[BB_MONKEY_ENEMIES][target]

	if(isnull(hatred_value))
		hatred_value = 1
		controller.set_blackboard_key_assoc(BB_MONKEY_ENEMIES, target, hatred_value)

	if(!SPT_PROB(MONKEY_HATRED_REDUCTION_PROB, seconds_per_tick))
		return

	//we decrease our hatred value to them by 1
	hatred_value--
	if(hatred_value <= 0)
		controller.remove_thing_from_blackboard_key(BB_MONKEY_ENEMIES, target)
		finish_action(controller, TRUE)

	controller.set_blackboard_key_assoc(BB_MONKEY_ENEMIES, target, hatred_value)
	return

/datum/ai_behavior/monkey_attack_mob/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(BB_MONKEY_CURRENT_ATTACK_TARGET)

/// attack using a held weapon otherwise bite the enemy, then if we are angry there is a chance we might calm down a little
/datum/ai_behavior/monkey_attack_mob/proc/monkey_attack(datum/ai_controller/controller, mob/living/target, seconds_per_tick, disarm, holding_weapon)

	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.next_move > world.time)
		return FALSE

	living_pawn.changeNext_move(CLICK_CD_MELEE) //We play fair

	var/obj/item/weapon = locate(/obj/item) in list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand())

	living_pawn.face_atom(target)

	living_pawn.a_intent = INTENT_HARM

	if(isnull(controller.blackboard[BB_MONKEY_GUN_WORKED]))
		controller.set_blackboard_key(BB_MONKEY_GUN_WORKED, TRUE)

	// attack with weapon if we have one
	if(living_pawn.Adjacent(target, weapon))
		if(weapon)
			weapon.melee_attack_chain(living_pawn, target)
			return TRUE
		else
			if(disarm)
				living_pawn.a_intent = INTENT_DISARM
				living_pawn.UnarmedAttack(target)
				living_pawn.a_intent = INTENT_HARM
				return TRUE
			else
				living_pawn.UnarmedAttack(target)
				return TRUE
	else if(weapon)
		var/atom/real_target = target
		if(prob(40)) // Artificial miss
			real_target = pick(oview(2, target))
		controller.set_blackboard_key(BB_MONKEY_GUN_WORKED, TRUE) // We reset their memory of the gun being 'broken' if they accomplish some other attack
		var/obj/item/gun/gun = locate() in list(living_pawn.get_active_hand(), living_pawn.get_inactive_hand())
		var/can_shoot = gun?.can_shoot() || FALSE
		if(gun && controller.blackboard[BB_MONKEY_GUN_WORKED] && prob(95))
			// We attempt to attack even if we can't shoot so we get the effects of pulling the trigger
			gun.afterattack(real_target, living_pawn, FALSE)
			controller.set_blackboard_key(BB_MONKEY_GUN_WORKED, can_shoot ? TRUE : prob(80)) // Only 20% likely to notice it didn't work
			if(can_shoot)
				controller.set_blackboard_key(BB_MONKEY_GUN_NEURONS_ACTIVATED, TRUE)
			return TRUE
		else
			living_pawn.throw_item(real_target)
			controller.set_blackboard_key(BB_MONKEY_GUN_WORKED, TRUE) // 'worked'
			return TRUE

/datum/ai_behavior/disposal_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM //performs to increase frustration

/datum/ai_behavior/disposal_mob/setup(datum/ai_controller/controller, attack_target_key, disposal_target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[attack_target_key])

/datum/ai_behavior/disposal_mob/finish_action(datum/ai_controller/controller, succeeded, attack_target_key, disposal_target_key)
	. = ..()
	controller.clear_blackboard_key(attack_target_key) //Reset attack target
	controller.set_blackboard_key(BB_MONKEY_DISPOSING, FALSE) //No longer disposing
	controller.clear_blackboard_key(disposal_target_key) //No target disposal

/datum/ai_behavior/disposal_mob/perform(seconds_per_tick, datum/ai_controller/controller, attack_target_key, disposal_target_key)
	. = ..()

	if(controller.blackboard[BB_MONKEY_DISPOSING]) //We are disposing, don't do ANYTHING!!!!
		return

	var/mob/living/target = controller.blackboard[attack_target_key]
	var/mob/living/living_pawn = controller.pawn

	set_movement_target(controller, target)

	if(!target)
		finish_action(controller, FALSE)

	if(target.pulledby != living_pawn && !HAS_AI_CONTROLLER_TYPE(target.pulledby, /datum/ai_controller/monkey)) //Dont steal from my fellow monkeys.
		if(living_pawn.Adjacent(target) && isturf(target.loc))
			target.grabbedby(living_pawn)
		return //Do the rest next turn

	var/obj/machinery/disposal/disposal = controller.blackboard[disposal_target_key]
	set_movement_target(controller, disposal)

	if(living_pawn.Adjacent(disposal))
		INVOKE_ASYNC(src, PROC_REF(try_disposal_mob), controller, attack_target_key, disposal_target_key) //put him in!
	else //This means we might be getting pissed!
		return

/datum/ai_behavior/disposal_mob/proc/try_disposal_mob(datum/ai_controller/controller, attack_target_key, disposal_target_key)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/target = controller.blackboard[attack_target_key]
	var/obj/machinery/disposal/disposal = controller.blackboard[disposal_target_key]

	controller.blackboard[BB_MONKEY_DISPOSING] = TRUE

	if(target && disposal?.monkey_stuff_mob(target, living_pawn))
		disposal.flush()
	finish_action(controller, TRUE, attack_target_key, disposal_target_key)

/datum/ai_behavior/recruit_monkeys/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()

	controller.set_blackboard_key(BB_MONKEY_RECRUIT_COOLDOWN, world.time + MONKEY_RECRUIT_COOLDOWN)
	var/mob/living/living_pawn = controller.pawn

	for(var/mob/living/nearby_monkey in view(living_pawn, MONKEY_ENEMY_VISION))
		if(!HAS_AI_CONTROLLER_TYPE(nearby_monkey, /datum/ai_controller/monkey))
			continue

		if(!SPT_PROB(MONKEY_RECRUIT_PROB, seconds_per_tick))
			continue

		// Recruited a monkey to our side
		controller.set_blackboard_key(BB_MONKEY_RECRUIT_COOLDOWN, world.time + MONKEY_RECRUIT_COOLDOWN)
		// Other monkeys now also hate the guy we're currently targeting
		nearby_monkey.ai_controller.add_blackboard_key_assoc(BB_MONKEY_ENEMIES, controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET], MONKEY_RECRUIT_HATED_AMOUNT)
	finish_action(controller, TRUE)

/datum/ai_behavior/monkey_set_combat_target/perform(seconds_per_tick, datum/ai_controller/controller, set_key, enemies_key)
	var/list/enemies = controller.blackboard[enemies_key]
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
	if(!length(valids))
		finish_action(controller, FALSE)

	controller.set_blackboard_key(set_key, pick_weight_classic(valids))
	finish_action(controller, TRUE)
