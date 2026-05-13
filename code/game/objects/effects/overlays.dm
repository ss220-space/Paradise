/obj/effect/overlay
	name = "overlay"

/obj/effect/overlay/singularity_act()
	return

/obj/effect/overlay/singularity_pull(atom/singularity, current_size)
	return

// Not actually a projectile, just an effect.
/obj/effect/overlay/beam
	name = "beam"
	icon = 'icons/effects/beam.dmi'
	icon_state = "b_beam"

/obj/effect/overlay/beam/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 10)

/obj/effect/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = TRUE
	layer = 5

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = TRUE
	layer = 5

/obj/effect/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"

/obj/effect/overlay/sparkles
	gender = PLURAL
	name = "sparkles"
	icon_state = "shieldsparkles"

/obj/effect/overlay/adminoverlay
	name = "adminoverlay"
	icon_state = "admin"
	layer = 4.1

/obj/effect/overlay/wall_rot
	name = "Wallrot"
	desc = "Ick..."
	icon = 'icons/effects/wallrot.dmi'
	density = TRUE
	layer = 5
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/overlay/wall_rot/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-10, 10)
	pixel_y = base_pixel_y + rand(-10, 10)
