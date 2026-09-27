/datum/ai_controller/basic_controller
	movement_delay = 0.4 SECONDS

/datum/ai_controller/basic_controller/TryPossessPawn(atom/new_pawn)
	// master220 adaptation: the heretic summons are /mob/living/simple_animal (not tg's basic mobs), and
	// their behaviors were ported to drive them (AttackingTarget/abilities + the melee_attack shim on
	// heretic_summon). Refusing them here made the controller CRASH + self-delete on every summon spawn,
	// which also broke everything that needs a live controller (obeys_commands, the friends blackboard).
	if(!isbasicmob(new_pawn) && !is_simple_animal(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	// A possessed simple_animal must not ALSO be driven by its native wakeup AI - park it, the
	// controller is its brain now (same idiom the heretic shapeshift uses).
	if(is_simple_animal(new_pawn))
		var/mob/living/simple_animal/animal_pawn = new_pawn
		animal_pawn.toggle_ai(AI_OFF)
		animal_pawn.shouldwakeup = FALSE

	var/mob/living/basic_mob = new_pawn

	update_speed(basic_mob)

	RegisterSignal(basic_mob, POST_BASIC_MOB_UPDATE_VARSPEED, PROC_REF(update_speed))

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
