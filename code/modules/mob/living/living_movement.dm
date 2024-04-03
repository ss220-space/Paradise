/mob/living/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	update_turf_movespeed(loc)
	if(HAS_TRAIT(src, TRAIT_NEGATES_GRAVITY))
		if(!isgroundlessturf(loc))
			ADD_TRAIT(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)
		else
			REMOVE_TRAIT(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)

	var/turf/old_turf = get_turf(OldLoc)
	var/turf/new_turf = get_turf(src)
	// If we're moving to/from nullspace, refresh
	// Easier then adding nullchecks to all this shit, and technically right since a null turf means nograv
	if(isnull(old_turf) || isnull(new_turf))
		if(!QDELING(src))
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


/mob/living/toggle_move_intent()
	if(SEND_SIGNAL(src, COMSIG_MOB_MOVE_INTENT_TOGGLE, m_intent) & COMPONENT_BLOCK_INTENT_TOGGLE)
		return

	var/icon_toggle
	if(m_intent == MOVE_INTENT_RUN)
		m_intent = MOVE_INTENT_WALK
		icon_toggle = "walking"
	else
		m_intent = MOVE_INTENT_RUN
		icon_toggle = "running"

	if(hud_used && hud_used.move_intent && hud_used.static_inventory)
		hud_used.move_intent.icon_state = icon_toggle
		for(var/obj/screen/mov_intent/selector in hud_used.static_inventory)
			selector.update_icon()

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

