/obj/effect/proc_holder/spell/view_range/expand_sight
	name = "Глаза, что Видели Запретное"
	desc = "Позволяет значительно увеличивать дальность обзора, чтобы \
			видеть врагов с гораздо большего расстояния."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "eye"
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	human_req = FALSE

/obj/effect/proc_holder/spell/view_range/expand_sight/get_view_ranges()
	var/static/list/view_ranges
	if(!view_ranges)
		view_ranges = ..() + list("23x23", "25x25")
	return view_ranges
