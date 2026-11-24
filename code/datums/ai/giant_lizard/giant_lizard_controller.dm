/*
 * Giant Lizard AI Controller
 * Ported from CMSS13 giant_lizard.dm
 * Now using modern ai_controller system
 */

/datum/ai_controller/giant_lizard
	blackboard = list(
		BB_LIZARD_TARGET = null,
		BB_LIZARD_FOOD_TARGET = null,
	)

	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(
		/datum/ai_planning_subtree/giant_lizard_combat,
		/datum/ai_planning_subtree/giant_lizard_hunt_food,
		/datum/ai_planning_subtree/giant_lizard_idle,
	)

	COOLDOWN_DECLARE(pack_alert_cooldown)

/datum/ai_controller/giant_lizard/New(atom/new_pawn)
	. = ..()
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(new_pawn, COMSIG_MOB_DEATH, PROC_REF(on_death))
	RegisterSignal(new_pawn, COMSIG_LIVING_IGNITED, PROC_REF(on_burn_start))
	RegisterSignal(new_pawn, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_hurt))

/datum/ai_controller/giant_lizard/Destroy(force, ...)
	UnregisterSignal(pawn, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_MOB_DEATH, COMSIG_LIVING_IGNITED, COMSIG_MOB_APPLY_DAMAGE))
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
		blackboard[BB_LIZARD_TARGET] = WEAKREF(user)
		var/mob/living/simple_animal/hostile/giant_lizard/lizard = pawn
		if(isliving(lizard))
			lizard.GiveTarget(user)
		queue_behavior(/datum/ai_behavior/lizard_growl)
		queue_behavior(/datum/ai_behavior/lizard_attack)
		alert_pack()

/// Called when this lizard takes damage
/datum/ai_controller/giant_lizard/proc/on_hurt(datum/source, damage_amount, damage_type, damage_flag, attacked_by)
	SIGNAL_HANDLER
	adjust_aggression(3)
	if(attacked_by && istype(attacked_by, /mob/living) && !is_dead())
		blackboard[BB_LIZARD_TARGET] = WEAKREF(attacked_by)
		var/mob/living/simple_animal/hostile/giant_lizard/lizard = pawn
		if(isliving(lizard))
			lizard.GiveTarget(attacked_by)
	alert_pack()

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
	CancelActions()
	blackboard[BB_LIZARD_TARGET] = null
	blackboard[BB_LIZARD_FOOD_TARGET] = null
	var/mob/living/simple_animal/hostile/giant_lizard/lizard = pawn
	if(isliving(lizard))
		lizard.GiveTarget(null)
	ai_movement.stop_moving_towards(src)

/// Aggression handled on the mob side (lizard.aggression_value); blackboard key removed.
/datum/ai_controller/giant_lizard/adjust_aggression(amount)
	return

/// Returns TRUE if the pawn is alive and conscious
/datum/ai_controller/giant_lizard/proc/is_dead()
	if(!isliving(pawn))
		return TRUE
	var/mob/living/living_pawn = pawn
	return living_pawn.stat == DEAD

/// Returns TRUE if the AI controller can actually run at the moment.
/datum/ai_controller/giant_lizard/able_to_run()
	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/// Alert nearby pack members to join combat
/datum/ai_controller/giant_lizard/alert_pack()
	if(COOLDOWN_FINISHED(src, pack_alert_cooldown))
		COOLDOWN_START(src, pack_alert_cooldown, GIANT_LIZARD_PACK_ALERT_COOLDOWN_TIME)
		var/list/all_alive = GLOB.giant_lizards_alive
		var/mob/living/simple_animal/hostile/giant_lizard/pawn_lizard = pawn
		for(var/mob/living/simple_animal/hostile/giant_lizard/pack_member as anything in all_alive)
			if(pack_member == pawn_lizard || pack_member.client || pack_member.stat == DEAD)
				continue
			if(get_dist(pawn_lizard, pack_member) <= 7 && !pack_member.is_retreating)
				pack_member.ai_controller?.queue_behavior(/datum/ai_behavior/lizard_pack_alert)
