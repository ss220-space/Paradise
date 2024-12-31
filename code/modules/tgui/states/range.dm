GLOBAL_DATUM_INIT(range_state, /datum/ui_state/range_state, new)

/datum/ui_state/range_state/can_use_topic(src_object, mob/user)
	var/dist = get_dist(src_object, user)
	if(dist <= 1)
		return UI_INTERACTIVE

	else if(dist <= 6)
		return UI_UPDATE

	return UI_CLOSE
