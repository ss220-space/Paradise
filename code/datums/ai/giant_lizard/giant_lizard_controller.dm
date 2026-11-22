/*
 * Giant Lizard AI Controller
 * Ported from CMSS13 giant_lizard.dm
 * Now using modern ai_controller system
 */

/datum/ai_controller/giant_lizard
	blackboard = list(
		BB_LIZARD_TARGET = null,
		BB_LIZARD_FOOD_TARGET = null,
		BB_LIZARD_IS_RETREATING = FALSE,
		BB_LIZARD_AGGRESSION = 0,
		BB_LIZARD_RETREAT_ATTEMPTS = 0,
		BB_LIZARD_PACK_ALERT_COOLDOWN = 0
	)

	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(
		/datum/ai_planning_subtree/giant_lizard_combat,
		/datum/ai_planning_subtree/giant_lizard_hunt_food,
		/datum/ai_planning_subtree/giant_lizard_idle
	)

	COOLDOWN_DECLARE(pack_alert_cooldown)

/datum/ai_controller/giant_lizard/New(atom/new_pawn)
	. = ..()
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(new_pawn, COMSIG_MOB_DEATH, PROC_REF(on_death))
	RegisterSignal(new_pawn, COMSIG_LIVING_IGNITED, PROC_REF(on_burn_start))

/datum/ai_controller/giant_lizard/Destroy(force, ...)
	UnregisterSignal(pawn, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_MOB_DEATH, COMSIG_LIVING_IGNITED))
	return ..()

/datum/ai_controller/giant_lizard/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	return ..()

/datum/ai_controller/giant_lizard/process(delta_time)
	if(ismob(pawn))
		var/mob/living/living_pawn = pawn
		movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..()

/// Called when someone attacks this lizard with hand
/datum/ai_controller/giant_lizard/proc/on_attack_hand(datum/source, mob/living/user, params)
	SIGNAL_HANDLER
	if(user.a_intent == INTENT_HARM && !is_dead())
		adjust_aggression(5)
		queue_behavior(/datum/ai_behavior/lizard_growl)
		queue_behavior(/datum/ai_behavior/lizard_retaliate)

/// Called when this lizard takes damage
/datum/ai_controller/giant_lizard/proc/on_hurt(datum/source, damage_amount, damage_type, damage_flag, attacked_by)
	SIGNAL_HANDLER
	adjust_aggression(3)

/// Called when this lizard catches fire
/datum/ai_controller/giant_lizard/proc/on_burn_start(datum/source)
	SIGNAL_HANDLER
	adjust_aggression(10)
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = pawn
	if(isliving(lizard))
		lizard.flee_from_fire()

/// Called when this lizard dies
/datum/ai_controller/giant_lizard/proc/on_death(mob/living/dead_lizard)
	SIGNAL_HANDLER
	blackboard[BB_LIZARD_TARGET] = null
	blackboard[BB_LIZARD_FOOD_TARGET] = null
	blackboard[BB_LIZARD_IS_RETREATING] = FALSE
	blackboard[BB_LIZARD_AGGRESSION] = 0
	blackboard[BB_LIZARD_RETREAT_ATTEMPTS] = 0

/// Increase aggression level in blackboard
/datum/ai_controller/giant_lizard/proc/adjust_aggression(amount)
	blackboard[BB_LIZARD_AGGRESSION] = clamp(blackboard[BB_LIZARD_AGGRESSION] + amount, 0, 30)

/// Returns TRUE if the pawn is alive and conscious
/datum/ai_controller/giant_lizard/proc/is_dead()
	if(!isliving(pawn))
		return TRUE
	var/mob/living/living_pawn = pawn
	return living_pawn.stat == DEAD

/// Alert nearby pack members to join combat
/datum/ai_controller/giant_lizard/proc/alert_pack()
	if(COOLDOWN_FINISHED(src, pack_alert_cooldown))
		COOLDOWN_START(src, pack_alert_cooldown, PACK_ALERT_COOLDOWN_TIME)
		var/list/all_alive = GLOB.giant_lizards_alive
		for(var/mob/living/simple_animal/hostile/giant_lizard/pack_member as anything in all_alive)
			if(pack_member == src || pack_member.client || pack_member.stat == DEAD)
				continue
			if(get_dist(src, pack_member) <= 7 && !pack_member.is_retreating)
				pack_member.ai_controller?.queue_behavior(/datum/ai_behavior/lizard_pack_alert)
