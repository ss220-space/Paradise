/**
 * # Targeted Mob Ability
 * Attempts to use a mob's cooldown ability on a target
 */
/datum/ai_behavior/targeted_mob_ability

/datum/ai_behavior/targeted_mob_ability/perform(seconds_per_tick, datum/ai_controller/controller, ability_key, target_key)
	var/obj/effect/proc_holder/spell/ability = get_ability_to_use(controller, ability_key)
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(ability) || QDELETED(target))
		finish_action(controller, FALSE, target_key)
	var/mob/pawn = controller.pawn
	pawn.face_atom(target)
	var/result = ability.InterceptClickOn(pawn, null, target)
	if(result)
		finish_action(controller, TRUE, target_key)
	finish_action(controller, FALSE, target_key)

/datum/ai_behavior/targeted_mob_ability/proc/get_ability_to_use(datum/ai_controller/controller, ability_key)
	return controller.blackboard[ability_key]

/datum/ai_behavior/targeted_mob_ability/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		controller.clear_blackboard_key(target_key)
		return
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.stat >= UNCONSCIOUS)
		controller.clear_blackboard_key(target_key)
