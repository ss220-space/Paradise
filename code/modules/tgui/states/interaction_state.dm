

GLOBAL_DATUM_INIT(interaction_state, /datum/ui_state/hold_or_view_state, new)

/datum/ui_state/interaction_state/can_use_topic(src_object, mob/user)
	if(user.stat != CONSCIOUS)
		return UI_CLOSE
	if(user.incapacitated(ALL))
		return UI_CLOSE
	if((src_object in view(user)))
		return UI_INTERACTIVE
	return UI_CLOSE
