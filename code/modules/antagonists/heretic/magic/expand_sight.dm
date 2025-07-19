// Action for Raw Prophets that boosts up or shrinks down their sight range.
/obj/effect/proc_holder/spell/view_range/expand_sight
	name = "Expand Sight"
	desc = "Boosts your sight range considerably, allowing you to see enemies from much further away."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "eye"
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	view_ranges = list(
		"default",
		"17x17",
		"19x19",
		"21x21",
		"23x23",
		"25x25",
	)
