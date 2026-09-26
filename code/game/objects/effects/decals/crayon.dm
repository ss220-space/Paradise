/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	color = BLOOD_COLOR_RED
	layer = MID_TURF_LAYER
	plane = GAME_PLANE //makes the graffiti visible over a wall.
	mergeable_decal = FALSE // Allows crayon drawings to overlap one another.

/obj/effect/decal/cleanable/crayon/Initialize(mapload, main = color, type = icon_state, e_name = name)
	. = ..()

	name = e_name
	desc = "A [name] drawn in crayon."

	icon_state = type
	color = main

/obj/effect/decal/cleanable/crayon/never_should_have_come_here(turf/here_turf)
	return isgroundlessturf(here_turf)
