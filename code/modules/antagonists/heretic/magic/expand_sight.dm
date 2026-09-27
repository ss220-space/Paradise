/datum/action/cooldown/spell/view_range/expand_sight
	name = "Глаза, что Видели Запретное"
	desc = "Позволяет значительно увеличивать дальность обзора, чтобы \
			видеть врагов с гораздо большего расстояния."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	spell_requirements = NONE

/datum/action/cooldown/spell/view_range/expand_sight/get_view_ranges()
	return ..() + list(6, 7)
