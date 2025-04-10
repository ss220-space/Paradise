/datum/ai_controller/basic_controller
	movement_delay = 0.4 SECONDS

/datum/ai_controller/basic_controller/TryPossessPawn(atom/new_pawn)
	if(!isbasicmob(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	var/mob/living/basic/basic_mob = new_pawn

	update_speed(basic_mob)

	RegisterSignal(basic_mob, POST_BASIC_MOB_UPDATE_VARSPEED, PROC_REF(update_speed))
	RegisterSignal(basic_mob, COMSIG_MOB_ATE, PROC_REF(on_mob_eat))

	return ..() //Run parent at end

/datum/ai_controller/basic_controller/able_to_run()
	. = ..()
	if(isliving(pawn))
		var/mob/living/living_pawn = pawn
		if(IS_DEAD_OR_INCAP(living_pawn))
			return FALSE
	return TRUE

/datum/ai_controller/basic_controller/proc/update_speed(mob/living/basic/basic_mob)
	SIGNAL_HANDLER
	movement_delay = basic_mob.cached_multiplicative_slowdown

/datum/ai_controller/basic_controller/proc/on_mob_eat()
	SIGNAL_HANDLER
	var/food_cooldown = blackboard[BB_EAT_FOOD_COOLDOWN] || EAT_FOOD_COOLDOWN
	set_blackboard_key(BB_NEXT_FOOD_EAT, world.time + food_cooldown)
