/obj/effect/temp_visual/peppino_trail
	icon = 'icons/effects/peppino_trail.dmi'
	icon_state = "trail"
	randomdir = FALSE
	duration = 4
	color = COLOR_WHITE
	layer = TURF_LAYER + 0.07
	mouse_opacity = 0

/obj/effect/temp_visual/peppino_trail/New(where, color)
	. = ..(where)
	src.color = color
	animate(src, alpha = 0, time = 4, easing = BOUNCE_EASING)

