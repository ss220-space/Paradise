/obj/effect/temp_visual/mook_dust
	name = "dust"
	ru_names = list( 
		NOMINATIVE = "пыль",
		GENITIVE = "пыли",
		DATIVE = "пыли",
		ACCUSATIVE = "пыль",
		INSTRUMENTAL = "пылью",
		PREPOSITIONAL = "пыли"
	)
	desc = "Это просто облако пыли!"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "mook_leap_cloud"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	pixel_x = -16
	pixel_y = -16
	base_pixel_y = -16
	base_pixel_x = -16
	duration = 1 SECONDS

/obj/effect/temp_visual/mook_dust/small

/obj/effect/temp_visual/mook_dust/small/Initialize(mapload)
	. = ..()
	transform = transform.Scale(0.5)
