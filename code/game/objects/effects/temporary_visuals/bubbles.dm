/obj/effect/temp_visual/bubbles
	name = "bubbles"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bubbles"
	layer = CLEANABLES_LAYER
	duration = 30
	randomdir = FALSE

/obj/effect/temp_visual/bubbles/Initialize(mapload, duration_override)
	if(duration_override)
		duration = duration_override
	. = ..()
