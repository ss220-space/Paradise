
/mob/living/carbon/alien/larva/regenerate_icons()
	cut_overlays()
	update_icons()

/mob/living/carbon/alien/larva/update_icons()
	var/prefix = evolution_points > 150 ? "bloody_larva" : "larva"
	var/incapacitated = HAS_TRAIT(src, TRAIT_INCAPACITATED)

	if(stat == DEAD)
		icon_state = "[prefix]_dead"
	else if(handcuffed || legcuffed)
		icon_state = "[prefix]_idle"
	else if(body_position == LYING_DOWN || incapacitated)
		icon_state = "[prefix]_sleep"
	else if(m_intent == MOVE_INTENT_RUN)
		icon_state = "[prefix]_run"
	else
		icon_state = "[prefix]_idle"

/mob/living/carbon/alien/larva/toggle_move_intent(new_move_intent)
	var/old_m_intent = m_intent
	. = ..()
	if(old_m_intent != m_intent)
		update_icons()

/mob/living/carbon/alien/larva/update_transform() //All this is handled in update_icons()
	. = ..()
	update_icons()

/mob/living/carbon/alien/larva/lying_angle_on_lying_down(new_lying_angle)
	return // Larvas don't rotate on lying down, they have their own custom icons.

