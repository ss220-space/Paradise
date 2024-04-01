/mob/living/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	update_turf_movespeed(loc)


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

