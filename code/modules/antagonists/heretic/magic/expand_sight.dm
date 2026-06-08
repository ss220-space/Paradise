// Action for Raw Prophets that boosts up or shrinks down their sight range.
/obj/effect/proc_holder/spell/view_range/expand_sight
	name = "Глаза что видели запретное"
	desc = "Позволяет значительно увеличивать дальность обзора, чтобы \
			видеть врагов с гораздо большего расстояния."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "eye"
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	human_req = FALSE
	view_ranges = list(
		"default",
		"17x17",
		"19x19",
		"21x21",
		"23x23",
		"25x25",
	)
