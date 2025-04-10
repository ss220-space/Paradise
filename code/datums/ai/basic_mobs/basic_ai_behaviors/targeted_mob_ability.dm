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
	var/result = ability.cast(target)
	if(result)
		finish_action(controller, TRUE, target_key)
	finish_action(controller, FALSE, target_key)

/datum/ai_behavior/targeted_mob_ability/proc/get_ability_to_use(datum/ai_controller/controller, ability_key)
	return controller.blackboard[ability_key]
