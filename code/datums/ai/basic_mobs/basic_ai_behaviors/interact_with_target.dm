///behavior for general interactions with any targets
/datum/ai_behavior/interact_with_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	///should we be clearing the target after the fact?
	var/clear_target = TRUE
	///should our combat mode be off during interaction?
	var/combat_mode = TRUE

/datum/ai_behavior/interact_with_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	controller.current_movement_target =  controller.blackboard[target_key]

/datum/ai_behavior/interact_with_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target) || !pre_interact(controller, target))
		finish_action(controller, FALSE, target_key)
	if(isitem(target))
		var/obj/item/item_target = target
		item_target.melee_attack_chain(pawn, pawn)
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/interact_with_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(clear_target || !succeeded)
		controller.clear_blackboard_key(target_key)

/datum/ai_behavior/interact_with_target/proc/pre_interact(datum/ai_controller/controller, target)
	return TRUE
