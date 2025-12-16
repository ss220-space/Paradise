/// Temporary visual effects.
/obj/effect/temp_visual
	icon_state = "nothing"
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// How long before the temp_visual gets deleted.
	var/duration = 1 SECONDS
	/// Timer that our duration is stored in.
	var/timerid
	/// Gives our effect a random direction on init.
	var/randomdir = TRUE

/obj/effect/temp_visual/Initialize(mapload)
	. = ..()
	if(randomdir)
		setDir(pick(GLOB.cardinal))

	timerid = QDEL_IN_STOPPABLE(src, duration)

/obj/effect/temp_visual/Destroy()
	. = ..()
	deltimer(timerid)

/obj/effect/temp_visual/singularity_act()
	return

/obj/effect/temp_visual/singularity_pull()
	return

/obj/effect/temp_visual/ex_act()
	return

/obj/effect/temp_visual/dir_setting
	randomdir = FALSE

/obj/effect/temp_visual/dir_setting/Initialize(mapload, set_dir)
	if(set_dir)
		setDir(set_dir)
	. = ..()

/obj/effect/temp_visual/target_angled
	randomdir = FALSE

/obj/effect/temp_visual/target_angled/Initialize(mapload, atom/target)
	. = ..()
	if(target)
		var/matrix/M = new
		M.Turn(get_angle(src, target))
		transform = M

/obj/effect/temp_visual/block
	name = "block"
	icon = 'icons/effects/effects.dmi'
	icon_state = "slash"
	duration = 6.7
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/block_shield
	name = "block shield"
	icon = 'icons/effects/effects.dmi'
	icon_state = "punch"
	duration = 6.7
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/block/Initialize(mapload, color)
	. = ..()
	if(color)
		src.color = color
	if(prob(50))
		var/matrix/flip_matrix = matrix()
		flip_matrix.Scale(-1, 1)
		src.transform = flip_matrix
	animate(src, alpha = 200, time = 1, easing = SINE_EASING)
	animate(alpha = 0, time = duration-1, easing = SINE_EASING)
