/mob/living/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	step_count++
	update_turf_movespeed(loc)
	if(HAS_TRAIT(src, TRAIT_NEGATES_GRAVITY))
		if(!isgroundlessturf(loc))
			ADD_TRAIT(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)
		else
			REMOVE_TRAIT(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)

	var/turf/old_turf = get_turf(old_loc)
	var/turf/new_turf = get_turf(src)
	// If we're moving to/from nullspace, refresh
	// Easier then adding nullchecks to all this shit, and technically right since a null turf means nograv
	if(isnull(old_turf) || isnull(new_turf))
		if(!QDELING(src))
			refresh_gravity()
		return

	// We are moved to/from atom contents, this atom was not a turf
	// forceMove cases mostly
	if(loc != old_loc && (!isturf(loc) || !isturf(old_loc)))
		refresh_gravity()
		return

	// If the turf gravity has changed, then it's possible that our state has changed, so update
	if(HAS_TRAIT(old_turf, TRAIT_FORCED_GRAVITY) != HAS_TRAIT(new_turf, TRAIT_FORCED_GRAVITY) || new_turf.force_no_gravity != old_turf.force_no_gravity)
		refresh_gravity()

	// Going to do area gravity checking here
	var/area/old_area = old_turf.loc
	var/area/new_area = new_turf.loc
	// If the area gravity has changed, then it's possible that our state has changed, so update
	if(old_area.has_gravity != new_area.has_gravity)
		refresh_gravity()


/mob/living/update_config_movespeed()
	update_move_intent_slowdown()
	return ..()


/mob/living/proc/update_move_intent_slowdown()
	add_movespeed_modifier((m_intent == MOVE_INTENT_WALK) ? /datum/movespeed_modifier/config_walk_run/walk : /datum/movespeed_modifier/config_walk_run/run)


/mob/living/proc/update_turf_movespeed(turf/check_turf)
	if(isturf(check_turf) && !HAS_TRAIT(check_turf, TRAIT_TURF_IGNORE_SLOWDOWN))
		if(check_turf.slowdown != current_turf_slowdown)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/turf_slowdown, multiplicative_slowdown = check_turf.slowdown)
			current_turf_slowdown = check_turf.slowdown
	else if(current_turf_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/turf_slowdown)
		current_turf_slowdown = 0


/mob/living/proc/update_pull_movespeed()
	SEND_SIGNAL(src, COMSIG_LIVING_UPDATING_PULL_MOVESPEED)

	if(!pulling)
		remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)
		return

	if(isliving(pulling))
		var/mob/living/pulling_mob = pulling
		if(!slowed_by_pull_and_push || pulling_mob.body_position == STANDING_UP || grab_state > GRAB_PASSIVE)
			remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)
			return
		if(!pulling_mob.buckled)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = PULL_LYING_MOB_SLOWDOWN)
			return
		var/slowdown_value = 0
		if(isobj(pulling_mob.buckled))
			var/obj/pulling_buckled_obj = pulling_mob.buckled
			if(pulling_buckled_obj.pull_push_slowdown)
				slowdown_value = pulling_buckled_obj.pull_push_slowdown
		else if(isliving(pulling_mob.buckled))
			var/mob/living/pulling_buckled_mob = pulling_mob.buckled
			if(pulling_buckled_mob.body_position == LYING_DOWN)
				slowdown_value = PULL_LYING_MOB_SLOWDOWN
		if(slowdown_value)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = slowdown_value)
		else
			remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)

	else if(isobj(pulling))
		var/obj/pulling_obj = pulling
		if(!slowed_by_pull_and_push || !pulling_obj.pull_push_slowdown)
			remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)
			return
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = pulling_obj.pull_push_slowdown)


/mob/living/proc/update_push_movespeed()
	if(!now_pushing && COOLDOWN_FINISHED(src, pushing_delay))
		remove_movespeed_modifier(/datum/movespeed_modifier/bulky_push)
		return

	COOLDOWN_START(src, pushing_delay, 0.1 SECONDS)	// we need this timestamp to add move delay on the next client move

	if(isliving(now_pushing))
		var/mob/living/pushing_mob = now_pushing
		if(!slowed_by_pull_and_push || pushing_mob.body_position == LYING_DOWN)
			remove_movespeed_modifier(/datum/movespeed_modifier/bulky_push)
			return
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_push, multiplicative_slowdown = PUSH_STANDING_MOB_SLOWDOWN)

	else if(isobj(now_pushing))
		var/obj/pushing_obj = now_pushing
		if(!slowed_by_pull_and_push || !pushing_obj.pull_push_slowdown)
			remove_movespeed_modifier(/datum/movespeed_modifier/bulky_push)
			return
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_push, multiplicative_slowdown = pushing_obj.pull_push_slowdown)


/mob/living/proc/can_change_move_intent(silent = FALSE)
	return TRUE


/mob/living/toggle_move_intent(new_move_intent)
	if(new_move_intent && m_intent == new_move_intent)
		return
	if(SEND_SIGNAL(src, COMSIG_MOB_MOVE_INTENT_TOGGLE, m_intent) & COMPONENT_BLOCK_INTENT_TOGGLE)
		return
	if(!can_change_move_intent())
		return

	if(new_move_intent)
		m_intent = new_move_intent
	else
		switch(m_intent)
			if(MOVE_INTENT_RUN)
				m_intent = MOVE_INTENT_WALK
			if(MOVE_INTENT_WALK)
				m_intent = MOVE_INTENT_RUN

	hud_used?.move_intent?.update_icon(UPDATE_ICON_STATE)

	update_move_intent_slowdown()
	SEND_SIGNAL(src, COMSIG_MOB_MOVE_INTENT_TOGGLED)


/// Living Mob use event based gravity
/// We check here to ensure we haven't dropped any gravity changes
/mob/living/proc/gravity_setup()
	on_negate_gravity(src)
	refresh_gravity()


/// Handles gravity effects. Call if something about our gravity has potentially changed!
/mob/living/proc/refresh_gravity()
	var/old_grav_state = gravity_state
	gravity_state = has_gravity()
	if(gravity_state == old_grav_state)
		return

	update_gravity(gravity_state)

	if(gravity_state > STANDARD_GRAVITY)
		gravity_animate()
	else if(old_grav_state > STANDARD_GRAVITY)
		remove_filter("gravity")


/mob/living/mob_negates_gravity()
	return HAS_TRAIT_FROM(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)


/mob/living/forceMove(atom/destination)
	if(buckled)
		addtimer(CALLBACK(src, PROC_REF(check_buckled)), 1, TIMER_UNIQUE)
	if(has_buckled_mobs())
		for(var/buckled_mob in buckled_mobs)
			addtimer(CALLBACK(buckled_mob, PROC_REF(check_buckled)), 1, TIMER_UNIQUE)
	if(!currently_z_moving)
		stop_pulling()

/*
	if(!currently_z_moving)
		stop_pulling()
		buckled?.unbuckle_mob(src, force = TRUE)
		if(has_buckled_mobs())
			unbuckle_all_mobs(force = TRUE)
*/
	. = ..()
	if(. && client)
		reset_perspective()


/**
 * We want to relay the zmovement to the buckled atom when possible
 * and only run what we can't have on buckled.zMove() or buckled.can_z_move() here.
 * This way we can avoid esoteric bugs, copypasta and inconsistencies.
 */
/mob/living/zMove(dir, turf/target, z_move_flags = ZMOVE_FLIGHT_FLAGS)
	if(buckled)
		if(buckled.currently_z_moving)
			return FALSE
		if(!(z_move_flags & ZMOVE_ALLOW_BUCKLED))
			buckled.unbuckle_mob(src, force = TRUE, can_fall = FALSE)
		else
			if(!target)
				target = can_z_move(dir, get_turf(src), null, z_move_flags, src)
				if(!target)
					return FALSE
			return buckled.zMove(dir, target, z_move_flags) // Return value is a loc.
	return ..()

/mob/living/can_z_move(direction, turf/start, turf/destination, z_move_flags = ZMOVE_FLIGHT_FLAGS, mob/living/rider)
	if(z_move_flags & ZMOVE_INCAPACITATED_CHECKS && incapacitated())
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider || src, "<span class='warning'>[rider ? src : "You"] can't do that right now!</span>")
		return FALSE
	if(!buckled || !(z_move_flags & ZMOVE_ALLOW_BUCKLED))
		if(!(z_move_flags & ZMOVE_FALL_CHECKS) && incorporeal_move && (!rider || rider.incorporeal_move))
			//An incorporeal mob will ignore obstacles unless it's a potential fall (it'd suck hard) or is carrying corporeal mobs.
			//Coupled with flying/floating, this allows the mob to move up and down freely.
			//By itself, it only allows the mob to move down.
			z_move_flags |= ZMOVE_IGNORE_OBSTACLES
		return ..()
	if(!(z_move_flags & ZMOVE_CAN_FLY_CHECKS) && !buckled.anchored) // may be issues with vehicles...
		return buckled.can_z_move(direction, start, destination, z_move_flags, src)
	if(z_move_flags & ZMOVE_FEEDBACK)
		to_chat(src, "<span class='notice'>Unbuckle from [buckled] first.<span>")
	return FALSE

/mob/set_currently_z_moving(value)
	if(buckled)
		return buckled.set_currently_z_moving(value)
	return ..()

///Checks if the user is incapacitated or on cooldown.
/mob/living/proc/can_look_up()
	return !(incapacitated(INC_IGNORE_RESTRAINED) || !isturf(loc))

/**
 * look_up Changes the perspective of the mob to any openspace turf above the mob
 *
 * This also checks if an openspace turf is above the mob before looking up or resets the perspective if already looking up
 *
 */
/mob/living/proc/look_up()
	if(client.perspective != MOB_PERSPECTIVE) //We are already looking up.
		stop_look_up()
	if(!can_look_up())
		return
	changeNext_move(CLICK_CD_LOOK_UP_DOWN)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(stop_look_up), override = TRUE) //We stop looking up if we move.
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(start_look_up), override = TRUE) //We start looking again after we move.
	start_look_up()

/mob/living/proc/start_look_up()
	SIGNAL_HANDLER
	var/turf/ceiling = get_step_multiz(src, UP)
	if(!ceiling) //We are at the highest z-level.
		end_look_up() // Why would you look from highest? cancel trying.
		if (prob(0.1))
			to_chat(src, span_warning("You gaze out into the infinite vastness of deep space, for a moment, you have the impulse to continue travelling, out there, out into the deep beyond, before your conciousness reasserts itself and you decide to stay within travelling distance of the station."))
			return
		to_chat(src, span_warning("There's nothing interesting up there."))
		return
	else if(!ceiling.transparent_floor) //There is no turf we can look through above us
		var/turf/front_hole = get_step(ceiling, dir)
		if(front_hole.transparent_floor)
			ceiling = front_hole
		else
			for(var/turf/checkhole in RANGE_TURFS(1, ceiling))
				if(checkhole.transparent_floor)
					ceiling = checkhole
					break
		if(!ceiling.transparent_floor)
			to_chat(src, span_warning("You can't see through the floor above you."))
			return

	reset_perspective(ceiling)

/mob/living/proc/stop_look_up()
	SIGNAL_HANDLER
	reset_perspective()

/mob/living/proc/end_look_up()
	stop_look_up()
	UnregisterSignal(src, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/**
 * look_down Changes the perspective of the mob to any openspace turf below the mob
 *
 * This also checks if an openspace turf is below the mob before looking down or resets the perspective if already looking up
 *
 */
/mob/living/proc/look_down()
	if(client.perspective != MOB_PERSPECTIVE) //We are already looking down.
		stop_look_down()
	if(!can_look_up()) //if we cant look up, we cant look down.
		return
	changeNext_move(CLICK_CD_LOOK_UP_DOWN)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(stop_look_down), override = TRUE) //We stop looking down if we move.
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(start_look_down), override = TRUE) //We start looking again after we move.
	start_look_down()

/mob/living/proc/start_look_down()
	SIGNAL_HANDLER
	var/turf/floor = get_turf(src)
	var/turf/lower_level = get_step_multiz(floor, DOWN)
	if(!lower_level) //We are at the lowest z-level.
		to_chat(src, span_warning("You can't see through the floor below you."))
		end_look_down() // Looking to the bottom, no need to try.
		return
	else if(!floor.transparent_floor) //There is no turf we can look through below us
		var/turf/front_hole = get_step(floor, dir)
		if(front_hole.transparent_floor)
			floor = front_hole
			lower_level = get_step_multiz(front_hole, DOWN)
		else
			// Try to find a hole near us
			for(var/turf/checkhole in RANGE_TURFS(1, floor))
				if(checkhole.transparent_floor)
					floor = checkhole
					lower_level = get_step_multiz(checkhole, DOWN)
					break
		if(!floor.transparent_floor)
			to_chat(src, span_warning("You can't see through the floor below you."))
			return

	reset_perspective(lower_level)

/mob/living/proc/stop_look_down()
	SIGNAL_HANDLER
	reset_perspective()

/mob/living/proc/end_look_down()
	stop_look_down()
	UnregisterSignal(src, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)


/mob/living/verb/lookup()
	set name = "Look Up"
	set category = "IC"

	if(client.perspective != MOB_PERSPECTIVE)
		end_look_up()
	else
		look_up()

/mob/living/verb/lookdown()
	set name = "Look Down"
	set category = "IC"

	if(client.perspective != MOB_PERSPECTIVE)
		end_look_down()
	else
		look_down()


/mob/living/keybind_face_direction(direction)
	if(stat > CONSCIOUS)
		return
	return ..()

