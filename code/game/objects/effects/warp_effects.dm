// MARK: BASE
/obj/effect/warp_effect
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	icon = 'icons/effects/seismic_stomp_effect.dmi'
	icon_state = "stomp_effect"
	pixel_y = -16
	pixel_x = -16

/obj/effect/warp_effect/ex_act(severity, target)
	return

/obj/effect/warp_effect/singularity_act()
	return FALSE

// MARK: Supermatter
/obj/effect/warp_effect/supermatter
	icon = 'icons/effects/light_352.dmi'
	icon_state = "light"
	pixel_x = -176
	pixel_y = -176

// MARK: Heart
/obj/effect/warp_effect/heart
	var/range = 12

/obj/effect/warp_effect/heart/Initialize(mapload)
	. = ..()
	if(GLOB.heart)
		range = GLOB.heart.pulse_range * 4
	var/matrix/scale_matrix = matrix() * 0.5
	transform = scale_matrix
	animate(src, transform = scale_matrix * range, time = 0.1 * range SECONDS, alpha = 0)
	QDEL_IN(src, 0.1 * range SECONDS)

// MARK: Gravity generator
/obj/effect/warp_effect/gravity_generator

/obj/effect/warp_effect/gravity_generator/Initialize(mapload)
	. = ..()
	var/matrix/scale_matrix = matrix() * 0.5
	transform = scale_matrix
	animate(src, transform = scale_matrix * 40, time = 0.8 SECONDS, alpha = 128, easing = CIRCULAR_EASING | EASE_IN)
	QDEL_IN(src, 0.8 SECONDS)

// MARK: BSG
/obj/effect/warp_effect/bsg

/obj/effect/warp_effect/bsg/Initialize(mapload)
	. = ..()
	var/matrix/scale_matrix = matrix() * 0.5
	transform = scale_matrix
	animate(src, transform = scale_matrix * 8, time = 0.8 SECONDS, alpha = 0)
	QDEL_IN(src, 0.8 SECONDS)
